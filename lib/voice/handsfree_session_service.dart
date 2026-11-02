import 'dart:async';
import 'package:flutter/foundation.dart';
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

    final micOk = await Permission.microphone.request();
    await Permission.speech.request();

    bool sttOk = false;
    if (micOk.isGranted || micOk.isLimited) {
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

  /// Called by the IMU/ML pipeline when an anomaly does not map to any known
  /// event type.  Asks the rider what it was, records the answer, and
  /// optionally registers a new [RoadEvents] entry.
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

    _setState(
        _state.copyWith(mode: HandsfreeMode.awaitingUnknownEventAnswer));

    // Stop ambient listening so the answer capture is clean
    try {
      await _stt.stop();
    } catch (_) {}

    await _speakOnly('Unknown event detected. What was that?');
    await Future.delayed(const Duration(milliseconds: 400));

    // Start a short focused listening window for the rider's answer
    await _listenForAnswer();
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

  Future<void> _listenForAnswer() async {
    if (!_sttReady || _isDisposed) {
      await _handleUnknownAnswer(null, confidence: 0);
      return;
    }

    final completer = Completer<void>();
    String? capturedAnswer;
    double capturedConfidence = 0;

    try {
      await _stt.listen(
        onResult: (result) {
          if (result.finalResult) {
            capturedAnswer = result.recognizedWords.trim();
            capturedConfidence = result.confidence;
            if (!completer.isCompleted) completer.complete();
          }
        },
        listenOptions: SpeechListenOptions(
          partialResults: false,
          cancelOnError: false,
          listenMode: ListenMode.confirmation,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {}

    // Fallback timeout so we don't block forever
    Timer(const Duration(seconds: 16), () {
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future;

    await _handleUnknownAnswer(
      capturedAnswer?.isEmpty == true ? null : capturedAnswer,
      confidence: capturedConfidence,
    );
  }

  Future<void> _handleUnknownAnswer(
    String? answer, {
    required double confidence,
  }) async {
    final pending = _pendingUnknown;
    _pendingUnknown = null;

    final resolvedLabel =
        answer != null ? _normaliseLabel(answer) : null;

    // Persist to DB
    try {
      await db.into(db.unknownEvents).insert(
            UnknownEventsCompanion.insert(
              tripId: drift.Value(pending?.tripId),
              latitude: drift.Value(pending?.latitude),
              longitude: drift.Value(pending?.longitude),
              imuSnapshotJson: drift.Value(pending?.imuSnapshotJson),
              peakAccelMagnitude: drift.Value(pending?.peakAccelMagnitude),
              durationMs: drift.Value(pending?.durationMs),
              questionSpoken: 'Unknown event detected. What was that?',
              riderAnswerRaw: drift.Value(answer),
              transcriptConfidence:
                  drift.Value(confidence > 0 ? confidence : null),
              resolvedLabel: drift.Value(resolvedLabel),
              detectedAtUtc:
                  pending?.detectedAt ?? DateTime.now().toUtc(),
              answeredAtUtc: drift.Value(DateTime.now().toUtc()),
            ),
          );
    } catch (e) {
      if (kDebugMode) debugPrint('HandsfreeService: DB insert failed: $e');
    }

    // Speak confirmation
    if (answer != null && answer.isNotEmpty) {
      final label =
          resolvedLabel != null ? _humanLabel(resolvedLabel) : answer;
      await _speakOnly('Got it. $label has been recorded. Thank you.');
    } else {
      await _speakOnly('No answer captured. Event saved as unknown.');
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
