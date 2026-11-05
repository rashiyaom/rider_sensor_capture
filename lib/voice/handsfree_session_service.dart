import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drift/drift.dart' as drift;

import '../data/local_db/database.dart';
import '../prealert/pre_alert_engine.dart';
import 'voice_alert_service.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum HandsfreeMode {
  /// Service is stopped (e.g. no active ride).
  off,

  /// Actively listening for ambient commands; ready to speak an alert.
  listening,

  /// TTS is speaking — mic is muted to avoid echo.
  speaking,

  /// Waiting for the rider to answer "what was that?".
  awaitingUnknownEventAnswer,
}

class HandsfreeSessionState {
  final HandsfreeMode mode;
  final String? lastSpokenText;
  final String? lastRecognizedWords;
  final bool isAvailable;

  const HandsfreeSessionState({
    this.mode = HandsfreeMode.off,
    this.lastSpokenText,
    this.lastRecognizedWords,
    this.isAvailable = false,
  });

  HandsfreeSessionState copyWith({
    HandsfreeMode? mode,
    String? lastSpokenText,
    String? lastRecognizedWords,
    bool? isAvailable,
  }) {
    return HandsfreeSessionState(
      mode: mode ?? this.mode,
      lastSpokenText: lastSpokenText ?? this.lastSpokenText,
      lastRecognizedWords: lastRecognizedWords ?? this.lastRecognizedWords,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

// ---------------------------------------------------------------------------
// Pending unknown event (held while rider is asked)
// ---------------------------------------------------------------------------

class _PendingUnknown {
  final double? latitude;
  final double? longitude;
  final String? imuSnapshotJson;
  final double? peakAccelMagnitude;
  final int? durationMs;
  final int? tripId;
  final DateTime detectedAt;

  _PendingUnknown({
    this.latitude,
    this.longitude,
    this.imuSnapshotJson,
    this.peakAccelMagnitude,
    this.durationMs,
    this.tripId,
    required this.detectedAt,
  });
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Hands-free rider voice assistant.
///
/// **Responsibilities**
/// 1. Speak every road-event alert and event-save confirmation through the
///    device speaker / wireless earbuds.
/// 2. Resume mic listening after each utterance so the rider can give
///    confirmations or corrections at any time.
/// 3. When an *unknown* IMU anomaly is detected ask the rider "what was
///    that?", transcribe the answer, store it in [UnknownEvents], and speak
///    a confirmation.
///
/// **Thread safety**
/// All state changes happen on the Flutter UI isolate via [_setState].
class HandsfreeSessionService {
  final AppDatabase db;
  final VoiceAlertService _tts;

  // STT
  final SpeechToText _stt = SpeechToText();
  bool _sttReady = false;
  bool _shouldKeepListening = false;
  bool _isDisposed = false;

  // 5-second audio clip recorder (.mp4 / AAC)
  AudioRecorder? _audioRecorder;

  // Stream exposed to the UI layer
  final _stateController =
      StreamController<HandsfreeSessionState>.broadcast();
  Stream<HandsfreeSessionState> get stateStream => _stateController.stream;

  HandsfreeSessionState _state = const HandsfreeSessionState();
  HandsfreeSessionState get state => _state;

  // Unknown-event flow
  _PendingUnknown? _pendingUnknown;

  // Keep-alive ping timer for the STT session
  Timer? _keepAliveTimer;

  // Debounce so rapid alerts are not spoken on top of each other
  DateTime? _lastSpeakAt;
  static const _speakDebounce = Duration(seconds: 3);

  HandsfreeSessionService({required this.db, VoiceAlertService? tts})
      : _tts = tts ?? VoiceAlertService();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Call once when a ride starts (or on app init).
  Future<void> start() async {
    if (_state.mode != HandsfreeMode.off) return;

    await _tts.ensureInitialized();

    bool micOk = false;
    try {
      final micReq = await Permission.microphone.request();
      await Permission.speech.request();
      micOk = micReq.isGranted || micReq.isLimited;
    } catch (_) {}

    bool sttOk = false;
    if (micOk) {
      try {
        sttOk = await _stt.initialize(
          onError: (e) {
            if (kDebugMode) debugPrint('HandsfreeSTT error: ${e.errorMsg}');
            _restartListeningWithDelay();
          },
          onStatus: (s) {
            if (s == 'done' || s == 'notListening') {
              if (_shouldKeepListening && !_isDisposed) {
                _restartListeningWithDelay();
              }
            }
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('HandsfreeSTT init error: $e');
      }
    }

    _sttReady = sttOk;
    _setState(_state.copyWith(
      mode: HandsfreeMode.listening,
      isAvailable: _tts.isAvailable,
    ));
    _shouldKeepListening = true;
    _startListeningLoop();
    _startKeepAlive();
  }

  /// Call when the ride ends.
  Future<void> stop() async {
    _shouldKeepListening = false;
    _keepAliveTimer?.cancel();
    try {
      await _stt.stop();
    } catch (_) {}
    try {
      if (_audioRecorder != null && await _audioRecorder!.isRecording()) {
        await _audioRecorder!.stop();
      }
    } catch (_) {}
    await _tts.stop();
    _setState(_state.copyWith(mode: HandsfreeMode.off));
  }

  void dispose() {
    _isDisposed = true;
    _shouldKeepListening = false;
    _keepAliveTimer?.cancel();
    try {
      _stt.stop();
    } catch (_) {}
    try {
      _audioRecorder?.dispose();
    } catch (_) {}
    _tts.dispose();
    _stateController.close();
  }

  // ---------------------------------------------------------------------------
  // Public API — called by PreAlertService / EventRecordingController
  // ---------------------------------------------------------------------------

  /// Speak a predictive pre-alert (bump/pothole/turn etc.).
  ///
  /// The mic is paused while speaking and automatically restarted afterward.
  Future<void> announcePreAlert(PreAlertDecision decision) async {
    final msg = PreAlertMessageBuilder.build(decision);
    await _speakAndResume(msg);
  }

  /// Speak a confirmation that a known event was saved.
  ///
  /// Example: *"Speed bump recorded. Peak 1.8 g."*
  Future<void> announceEventSaved({
    required String eventType,
    String? classification,
    double? peakMetric,
    String? peakUnit,
  }) async {
    final label = _humanLabel(eventType);
    final buffer = StringBuffer('$label recorded.');
    if (classification != null && classification.isNotEmpty) {
      buffer.write(' $classification.');
    }
    if (peakMetric != null && peakUnit != null) {
      buffer.write(' Peak ${peakMetric.toStringAsFixed(1)} $peakUnit.');
    }
    await _speakAndResume(buffer.toString());
  }

  /// Speak a real-time event alert (detected during recording).
  Future<void> announceEventAlert({
    required String eventType,
    String? detail,
  }) async {
    final label = _humanLabel(eventType);
    final msg =
        detail != null ? '$label detected. $detail' : '$label detected.';
    await _speakAndResume(msg);
  }

  /// Called right after an event is saved during a ride.
  /// 1. Speaks "Event detected: [name]. How was it?" into rider's earbuds.
  /// 2. Records a 5-second voice clip (.mp4) and transcribes answer.
  /// 3. Automatically saves audio file path in EventRecords and EventFeedbacks tables.
  /// 4. Registers hazard in road_events at (latitude, longitude) for future pre-alerts.
  /// 5. Confirms saving via audio feedback.
  Future<void> promptAndRecordEventFeedback({
    required int eventId,
    required String eventType,
    int? tripId,
    double? latitude,
    double? longitude,
    int? roadEventId,
    int? preAlertId,
  }) async {
    if (_isDisposed) return;

    _setState(_state.copyWith(mode: HandsfreeMode.speaking));

    final humanName = _humanLabel(eventType);
    await _speakOnly('Event detected: $humanName. How was it?');
    await Future.delayed(const Duration(milliseconds: 300));

    _setState(_state.copyWith(mode: HandsfreeMode.awaitingUnknownEventAnswer));

    // 5-second voice clip capture
    final capture = await _record5SecondClip(prefix: 'event_$eventId');

    // Update EventRecord with the audio file path
    try {
      await (db.update(db.eventRecords)..where((t) => t.id.equals(eventId))).write(
        EventRecordsCompanion(
          audioFilePath: drift.Value(capture.audioFilePath),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update eventRecord audio path: $e');
    }

    // Insert into EventFeedbacks
    try {
      await db.into(db.eventFeedbacks).insert(
        EventFeedbacksCompanion.insert(
          eventId: drift.Value(eventId),
          tripId: drift.Value(tripId),
          roadEventId: drift.Value(roadEventId),
          preAlertId: drift.Value(preAlertId),
          eventType: eventType,
          prompt: 'Event detected: $humanName. How was it?',
          responseText: capture.transcript ?? '5-second voice clip recorded',
          responseSource: 'voice',
          transcriptConfidence:
              drift.Value(capture.confidence > 0 ? capture.confidence : null),
          audioFilePath: drift.Value(capture.audioFilePath),
          createdAtUtc: DateTime.now().toUtc(),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to insert event feedback: $e');
    }

    // Ensure geo-tagged hazard is stored in road_events for future warnings
    if (latitude != null && longitude != null && roadEventId == null) {
      final kind = RoadEventKind.fromString(eventType);
      if (kind != RoadEventKind.unknown) {
        try {
          await db.into(db.roadEvents).insert(
            RoadEventsCompanion.insert(
              tripId: drift.Value(tripId),
              eventType: kind.name,
              latitude: latitude,
              longitude: longitude,
              severity: const drift.Value(0.6),
              confidence: const drift.Value(0.85),
              source: const drift.Value('voice'),
              detectedAtUtc: DateTime.now().toUtc(),
              note: drift.Value('Event #$eventId: 5s audio clip recorded'),
            ),
          );
        } catch (_) {}
      }
    }

    // Confirm in earbuds
    await _speakOnly('Got it. 5-second audio clip and event saved.');

    // Resume ambient listening
    _setState(_state.copyWith(mode: HandsfreeMode.listening));
    await Future.delayed(const Duration(milliseconds: 300));
    _startListeningLoop();
  }

  /// Records a preset 5-second audio clip (.mp4 / AAC) to local storage.
  /// Also listens for speech transcription simultaneously.
  /// Automatically stops when 5 seconds elapse.
  Future<({String? audioFilePath, String? transcript, double confidence})>
      _record5SecondClip({required String prefix}) async {
    String? audioPath;
    String transcript = '';
    double confidence = 0.0;

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${docsDir.path}/event_audio');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      final ts = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${audioDir.path}/${prefix}_$ts.mp4';

      AudioRecorder? recorder;
      try {
        _audioRecorder ??= AudioRecorder();
        recorder = _audioRecorder;
      } catch (_) {}

      if (recorder != null) {
        try {
          final hasPermission = await recorder.hasPermission();
          if (hasPermission) {
            await recorder.start(
              const RecordConfig(
                encoder: AudioEncoder.aacLc,
                sampleRate: 44100,
                bitRate: 64000,
              ),
              path: targetPath,
            );
          }
        } catch (_) {}
      }

      // Simultaneously attempt to transcribe speech via STT
      if (_sttReady) {
        try {
          await _stt.listen(
            onResult: (result) {
              final words = result.recognizedWords.trim();
              if (words.isNotEmpty) {
                transcript = words;
                confidence = result.confidence;
              }
            },
            listenOptions: SpeechListenOptions(
              partialResults: true,
              cancelOnError: false,
              listenMode: ListenMode.dictation,
              listenFor: const Duration(seconds: 5),
              pauseFor: const Duration(seconds: 2),
            ),
          );
        } catch (_) {}
      }

      // Exactly 5-second preset audio recording clip
      await Future.delayed(const Duration(seconds: 5));

      // Stop audio recording
      if (recorder != null) {
        try {
          if (await recorder.isRecording()) {
            audioPath = await recorder.stop();
          }
        } catch (_) {}
      }

      // Stop STT
      try {
        await _stt.stop();
      } catch (_) {}
    } catch (e) {
      if (kDebugMode) debugPrint('Error during 5s audio recording: $e');
      try {
        if (_audioRecorder != null && await _audioRecorder!.isRecording()) {
          audioPath = await _audioRecorder!.stop();
        }
      } catch (_) {}
    }

    return (
      audioFilePath: audioPath,
      transcript: transcript.isNotEmpty ? transcript : null,
      confidence: confidence,
    );
  }

  /// Called by the IMU/ML pipeline when an anomaly does not map to any known
  /// event type. Asks the rider what it was, records the answer, and
  /// registers a new [RoadEvents] entry for future warnings.
  Future<void> reportUnknownImuEvent({
    double? latitude,
    double? longitude,
    String? imuSnapshotJson,
    double? peakAccelMagnitude,
    int? durationMs,
    int? tripId,
  }) async {
    if (_isDisposed) return;

    _pendingUnknown = _PendingUnknown(
      latitude: latitude,
      longitude: longitude,
      imuSnapshotJson: imuSnapshotJson,
      peakAccelMagnitude: peakAccelMagnitude,
      durationMs: durationMs,
      tripId: tripId,
      detectedAt: DateTime.now().toUtc(),
    );

    _setState(_state.copyWith(mode: HandsfreeMode.speaking));

    // Stop ambient listening so the answer capture is clean
    try {
      await _stt.stop();
    } catch (_) {}

    await _speakOnly('Event detected. How was it?');
    await Future.delayed(const Duration(milliseconds: 300));

    _setState(_state.copyWith(mode: HandsfreeMode.awaitingUnknownEventAnswer));

    // Record preset 5-second audio clip
    final capture = await _record5SecondClip(
      prefix: 'unknown_${DateTime.now().millisecondsSinceEpoch}',
    );

    await _handleUnknownAnswer(
      capture.transcript,
      confidence: capture.confidence,
      audioFilePath: capture.audioFilePath,
    );
  }

  // ---------------------------------------------------------------------------
  // Internal — STT loops
  // ---------------------------------------------------------------------------

  void _startListeningLoop() {
    if (_isDisposed || !_shouldKeepListening || !_sttReady) return;
    if (_stt.isListening) return;
    if (_state.mode == HandsfreeMode.awaitingUnknownEventAnswer) return;

    try {
      _stt.listen(
        onResult: (result) {
          if (_isDisposed) return;
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty) {
            _setState(_state.copyWith(lastRecognizedWords: words));
          }
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
        ),
      );
    } catch (_) {}
  }

  Future<void> _handleUnknownAnswer(
    String? answer, {
    required double confidence,
    String? audioFilePath,
  }) async {
    final pending = _pendingUnknown;
    _pendingUnknown = null;

    final resolvedLabel =
        answer != null ? _normaliseLabel(answer) : null;

    int? promotedRoadEventId;
    // Register as a permanent road hazard for future pre-alerts at these coordinates
    if (pending != null && pending.latitude != null && pending.longitude != null) {
      final labelToUse = resolvedLabel ?? 'bump';
      final kind = RoadEventKind.fromString(labelToUse);
      if (kind != RoadEventKind.unknown) {
        try {
          promotedRoadEventId = await db.into(db.roadEvents).insert(
            RoadEventsCompanion.insert(
              tripId: drift.Value(pending.tripId),
              eventType: kind.name,
              latitude: pending.latitude!,
              longitude: pending.longitude!,
              severity: const drift.Value(0.6),
              confidence: const drift.Value(0.85),
              source: const drift.Value('voice'),
              detectedAtUtc: pending.detectedAt,
              note: drift.Value(answer != null && answer.isNotEmpty
                  ? 'Voice classified: "$answer"'
                  : 'IMU anomaly at coords'),
            ),
          );
        } catch (e) {
          if (kDebugMode) debugPrint('Failed to save road event for future: $e');
        }
      }
    }

    // Persist to UnknownEvents table
    try {
      await db.into(db.unknownEvents).insert(
            UnknownEventsCompanion.insert(
              tripId: drift.Value(pending?.tripId),
              latitude: drift.Value(pending?.latitude),
              longitude: drift.Value(pending?.longitude),
              imuSnapshotJson: drift.Value(pending?.imuSnapshotJson),
              peakAccelMagnitude: drift.Value(pending?.peakAccelMagnitude),
              durationMs: drift.Value(pending?.durationMs),
              questionSpoken: 'Event detected. How was it?',
              riderAnswerRaw: drift.Value(answer),
              transcriptConfidence:
                  drift.Value(confidence > 0 ? confidence : null),
              resolvedLabel: drift.Value(resolvedLabel),
              promoted: drift.Value(promotedRoadEventId != null),
              promotedRoadEventId: drift.Value(promotedRoadEventId),
              audioFilePath: drift.Value(audioFilePath),
              detectedAtUtc:
                  pending?.detectedAt ?? DateTime.now().toUtc(),
              answeredAtUtc: drift.Value(DateTime.now().toUtc()),
            ),
          );
    } catch (e) {
      if (kDebugMode) debugPrint('HandsfreeService: DB insert failed: $e');
    }

    // Speak confirmation
    if (resolvedLabel != null && resolvedLabel.isNotEmpty) {
      final label = _humanLabel(resolvedLabel);
      if (promotedRoadEventId != null) {
        await _speakOnly('Got it. $label saved as road hazard for future warnings.');
      } else {
        await _speakOnly('Got it. $label has been recorded. Thank you.');
      }
    } else {
      if (promotedRoadEventId != null) {
        await _speakOnly('Got it. Event audio clip saved as hazard for future warnings.');
      } else {
        await _speakOnly('Event audio clip saved.');
      }
    }

    // Return to ambient listening
    _setState(_state.copyWith(mode: HandsfreeMode.listening));
    await Future.delayed(const Duration(milliseconds: 300));
    _startListeningLoop();
  }

  void _restartListeningWithDelay() {
    if (_isDisposed) return;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (_shouldKeepListening &&
          !_stt.isListening &&
          !_isDisposed &&
          _state.mode == HandsfreeMode.listening) {
        _startListeningLoop();
      }
    });
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_shouldKeepListening &&
          !_stt.isListening &&
          !_isDisposed &&
          _state.mode == HandsfreeMode.listening) {
        _startListeningLoop();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Internal — TTS helpers
  // ---------------------------------------------------------------------------

  /// Pauses mic, speaks, resumes mic.
  Future<void> _speakAndResume(String text) async {
    if (_isDisposed) return;

    // Debounce: don't speak if we spoke very recently
    final now = DateTime.now();
    if (_lastSpeakAt != null &&
        now.difference(_lastSpeakAt!) < _speakDebounce) {
      return;
    }
    _lastSpeakAt = now;

    // Pause mic so echo doesn't get fed back
    try {
      if (_stt.isListening) await _stt.stop();
    } catch (_) {}

    _setState(_state.copyWith(
      mode: HandsfreeMode.speaking,
      lastSpokenText: text,
    ));

    await _tts.speak(text);

    // Resume ambient listening
    if (!_isDisposed &&
        _shouldKeepListening &&
        _state.mode != HandsfreeMode.awaitingUnknownEventAnswer) {
      _setState(_state.copyWith(mode: HandsfreeMode.listening));
      await Future.delayed(const Duration(milliseconds: 200));
      _startListeningLoop();
    }
  }

  /// Speaks without resuming the ambient mic (used in answer-capture flow).
  Future<void> _speakOnly(String text) async {
    if (_isDisposed) return;
    _setState(_state.copyWith(
      mode: HandsfreeMode.speaking,
      lastSpokenText: text,
    ));
    await _tts.speak(text);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setState(HandsfreeSessionState next) {
    if (_isDisposed) return;
    _state = next;
    if (!_stateController.isClosed) _stateController.add(next);
  }

  /// Maps internal event type strings to a human-friendly spoken label.
  String _humanLabel(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'bump':
      case 'speed_bump':
      case 'speedbump':
        return 'Speed bump';
      case 'pothole':
        return 'Pothole';
      case 'turn':
      case 'corner':
      case 'curve':
        return 'Sharp turn';
      case 'braking':
      case 'decel':
      case 'speedtest':
        return 'Braking event';
      case 'hazard':
      case 'obstacle':
      case 'debris':
        return 'Road hazard';
      case 'acceleration':
        return 'Acceleration event';
      default:
        return raw.replaceAll('_', ' ');
    }
  }

  /// Normalises the rider's free-form voice answer to a canonical label.
  String? _normaliseLabel(String answer) {
    final a = answer.toLowerCase();
    if (a.contains('pothole')) return 'pothole';
    if (a.contains('bump') || a.contains('speed bump')) return 'speed_bump';
    if (a.contains('turn') || a.contains('corner') || a.contains('curve')) {
      return 'turn';
    }
    if (a.contains('brak') || a.contains('decel')) return 'braking';
    if (a.contains('hazard') ||
        a.contains('obstacle') ||
        a.contains('debris')) {
      return 'hazard';
    }
    if (a.contains('accel') || a.contains('accelerat')) {
      return 'acceleration';
    }
    return answer.trim().toLowerCase().replaceAll(' ', '_');
  }
}
