import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drift/drift.dart' as drift;

import '../data/local_db/database.dart';
import '../features/live_events/live_event_repository.dart';
import '../data/services/live_ml_inference_service.dart';
import '../location/location_service.dart';
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
  final bool _ownsTts;
  Future<void> _voiceActions = Future<void>.value();
  int _voiceGeneration = 0;
  bool _liveConversationBusy = false;
  Completer<String?>? _answer;
  String? _latestAnswer;
  Future<void>? _starting;
  LiveEventRepository get _reviews => LiveEventRepository(db);

  /// Waits for cancelled conversations to finish persisting captured replies.
  Future<void> get idle => _voiceActions;

  // STT
  final SpeechToText _stt;
  bool _sttReady = false;
  bool _shouldKeepListening = false;
  bool _isDisposed = false;


  // Stream exposed to the UI layer
  final _stateController = StreamController<HandsfreeSessionState>.broadcast();
  Stream<HandsfreeSessionState> get stateStream => _stateController.stream;

  HandsfreeSessionState _state = const HandsfreeSessionState();
  HandsfreeSessionState get state => _state;


  // Keep-alive ping timer for the STT session
  Timer? _keepAliveTimer;

  // Debounce so rapid alerts are not spoken on top of each other
  DateTime? _lastSpeakAt;
  static const _speakDebounce = Duration(seconds: 3);

  HandsfreeSessionService({
    required this.db,
    VoiceAlertService? tts,
    SpeechToText? stt,
  }) : _tts = tts ?? VoiceAlertService(),
       _ownsTts = tts == null,
       _stt = stt ?? SpeechToText();

  bool _isCurrentVoiceAction(int generation) =>
      !_isDisposed && generation == _voiceGeneration;

  // Serialize the entire speak/record/resume cycle, not just TTS playback.
  // Otherwise one event can reopen the mic during another event's sentence.
  Future<void> _enqueueVoiceAction(Future<void> Function(int) action) {
    final generation = _voiceGeneration;
    final result = _voiceActions.then((_) async {
      if (_isCurrentVoiceAction(generation)) await action(generation);
    });
    _voiceActions = result.catchError((Object error) {
      if (kDebugMode) debugPrint('Handsfree voice action failed: $error');
    });
    return result;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Call once when a ride starts (or on app init).
  Future<void> start() {
    if (_starting != null) return _starting!;
    final operation = _start();
    _starting = operation;
    return operation.whenComplete(() => _starting = null);
  }

  Future<void> _start() async {
    if (_isDisposed || _state.mode != HandsfreeMode.off) return;
    final generation = _voiceGeneration;
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
            _finishAnswer();
            _restartListeningWithDelay();
          },
          onStatus: (s) {
            if (s == 'done') _finishAnswer();
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

    if (!_isCurrentVoiceAction(generation)) return;
    _sttReady = sttOk;
    _setState(
      _state.copyWith(
        mode: HandsfreeMode.listening,
        isAvailable: _tts.isAvailable,
      ),
    );
    _shouldKeepListening = true;
    _startListeningLoop();
    _startKeepAlive();
  }

  /// Call when the ride ends.
  Future<void> stop() async {
    _voiceGeneration++;
    _finishAnswer();
    _setState(_state.copyWith(mode: HandsfreeMode.off));
    _shouldKeepListening = false;
    _keepAliveTimer?.cancel();
    try {
      await _stt.stop();
    } catch (_) {}
    await _tts.stop();
    _setState(_state.copyWith(mode: HandsfreeMode.off));
  }

  void dispose() {
    _voiceGeneration++;
    _finishAnswer();
    _isDisposed = true;
    _shouldKeepListening = false;
    _keepAliveTimer?.cancel();
    try {
      _stt.stop();
    } catch (_) {}
    if (_ownsTts) _tts.dispose();
    _stateController.close();
  }

  // ---------------------------------------------------------------------------
  // Public API — called by PreAlertService / EventRecordingController
  // ---------------------------------------------------------------------------

  /// Speak a predictive pre-alert (bump/pothole/turn etc.).
  ///
  /// The mic is paused while speaking and automatically restarted afterward.
  Future<void> announcePreAlert(PreAlertDecision decision) {
    // A location warning takes priority over questions about a past event.
    // Finish the current sentence, but release any pending answer immediately.
    _voiceGeneration++;
    _finishAnswer();
    return _enqueueVoiceAction((generation) async {
      // Refresh distance after waiting for the current sentence to finish.
      final age = DateTime.now().toUtc().difference(decision.evaluatedAtUtc ??
          DateTime.now().toUtc()).inMilliseconds / 1000.0;
      final remaining = decision.distanceMeters - decision.speedKmh / 3.6 * age;
      if (remaining <= 0) return;
      await _speakOnly(PreAlertMessageBuilder.build(decision, distanceOverride: remaining));
      if (_isCurrentVoiceAction(generation)) _resumeListening();
    });
  }

  /// Persist immediately; questions never delay detection of subsequent events.
  Future<void> reviewLiveDetection({required int tripId,
    required LiveMlPrediction prediction, LocationFix? fix}) async {
    final generation = _voiceGeneration;
    final canAsk = !_liveConversationBusy && _state.mode == HandsfreeMode.listening;
    if (canAsk) _liveConversationBusy = true;
    try {
      final id = await _reviews.capture(tripId: tripId, prediction: prediction, fix: fix);
      if (!canAsk || !_isCurrentVoiceAction(generation)) return;
      await _enqueueVoiceAction((generation) => _confirmLiveEvent(id, generation));
    } finally {
      if (canAsk) _liveConversationBusy = false;
    }
  }

  static bool? confirmationFrom(String? reply) {
    if (reply == null) return null;
    final words = reply.toLowerCase().replaceAll(RegExp(r"[^a-z\s]"), ' ');
    if (RegExp(r'\b(no|nope|nah|not|incorrect)\b').hasMatch(words)) return false;
    if (RegExp(r'\b(yes|yeah|yep|correct|sure)\b').hasMatch(words)) return true;
    return null;
  }

  Future<void> _confirmLiveEvent(int id, int generation) async {
    final event = await _reviews.get(id);
    if (!_isCurrentVoiceAction(generation)) return;
    final question = switch (event.eventType) {
      'bump' => 'Was that a bump?',
      'turn' => 'Was that a sharp turn?',
      'braking' => 'Was that hard braking?',
      'acceleration' => 'Was that rapid acceleration?',
      _ => 'Was that a road hazard?',
    };
    try {
      await _speakOnly(question);
      if (!_isCurrentVoiceAction(generation)) return;
      var reply = await _listenForAnswer(generation);
      var confirmed = confirmationFrom(reply);
      await _reviews.recordConfirmation(id, reply, confirmed);
      if (!_isCurrentVoiceAction(generation)) return;
      if (confirmed == null && _sttReady) {
        await _speakOnly('Please say yes or no.');
        if (!_isCurrentVoiceAction(generation)) return;
        final retry = await _listenForAnswer(generation);
        if (retry != null) reply = retry;
        confirmed = confirmationFrom(retry);
        await _reviews.recordConfirmation(id, reply, confirmed);
      }
      if (!_isCurrentVoiceAction(generation)) return;
      if (confirmed == true) {
        await _speakOnly('How was it?');
        if (!_isCurrentVoiceAction(generation)) return;
        final feedback = await _listenForAnswer(generation, timeout: const Duration(seconds: 12));
        await _reviews.recordFeedback(id, feedback);
        if (!_isCurrentVoiceAction(generation)) return;
        await _speakOnly(feedback == null
            ? 'No feedback captured. You can review this event after the trip.'
            : 'Got it. Your feedback is saved for review after the trip.');
      } else {
        await _speakOnly(confirmed == false
            ? 'Okay, marked as not an event.'
            : 'You can review this detection after the trip.');
      }
    } finally {
      if (_isCurrentVoiceAction(generation)) _resumeListening();
    }
  }

  void _finishAnswer() {
    final answer = _answer;
    if (answer != null && !answer.isCompleted) answer.complete(_latestAnswer);
  }

  Future<String?> _listenForAnswer(int generation, {
    Duration timeout = const Duration(seconds: 7),
  }) async {
    if (!_sttReady || !_isCurrentVoiceAction(generation)) return null;
    _setState(_state.copyWith(mode: HandsfreeMode.awaitingUnknownEventAnswer));
    final answer = Completer<String?>();
    _answer = answer;
    _latestAnswer = null;
    final timer = Timer(timeout, _finishAnswer);
    try {
      await _stt.listen(
        onResult: (result) {
          if (answer.isCompleted || !_isCurrentVoiceAction(generation)) return;
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty) {
            _latestAnswer = words;
            _setState(_state.copyWith(lastRecognizedWords: words));
          }
          if (result.finalResult) _finishAnswer();
        },
        listenOptions: SpeechListenOptions(
          partialResults: true, cancelOnError: true, listenMode: ListenMode.dictation,
          listenFor: timeout, pauseFor: const Duration(seconds: 2),
        ),
      );
      return await answer.future;
    } catch (e) {
      if (kDebugMode) debugPrint('Could not capture rider answer: $e');
      return _latestAnswer;
    } finally {
      timer.cancel();
      _answer = null;
      try { await _stt.stop(); } catch (_) {}
    }
  }

  void _resumeListening() {
    if (_shouldKeepListening && !_isDisposed) {
      _setState(_state.copyWith(mode: HandsfreeMode.listening));
      _startListeningLoop();
    }
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
    final msg = detail != null
        ? '$label detected. $detail'
        : '$label detected.';
    await _speakAndResume(msg);
  }

  /// Manual recordings use the same yes/no and feedback flow as live events.
  Future<void> promptAndRecordEventFeedback({
    required int eventId, required String eventType, int? tripId,
    double? latitude, double? longitude, int? roadEventId, int? preAlertId,
  }) => _enqueueVoiceAction((generation) async {
    if (!_isCurrentVoiceAction(generation)) return;
    final record = await (db.select(db.eventRecords)..where((t) => t.id.equals(eventId))).getSingleOrNull();
    final effectiveTrip = tripId ?? record?.tripId;
    if (effectiveTrip == null || record == null) return;
    final id = await db.into(db.liveEventReviews).insert(LiveEventReviewsCompanion.insert(
      tripId: effectiveTrip, eventId: drift.Value(eventId), eventType: eventType,
      detectedAtUtc: record.startTimestamp, confidence: 1.0,
      sensorFeaturesJson: record.computedParameters ?? '{}',
      latitude: drift.Value(record.startGpsLat ?? latitude),
      longitude: drift.Value(record.startGpsLng ?? longitude),
    ));
    await _confirmLiveEvent(id, generation);
  });

  // ---------------------------------------------------------------------------
  // Internal — STT loops
  // ---------------------------------------------------------------------------

  void _startListeningLoop() {
    if (_isDisposed || !_shouldKeepListening || !_sttReady) return;
    if (_stt.isListening) return;
    if (_state.mode != HandsfreeMode.listening || _tts.isSpeaking) return;

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
  Future<void> _speakAndResume(String text) =>
      _enqueueVoiceAction((generation) async {
        if (_isDisposed) return;

        // Debounce: don't speak if we spoke very recently
        final now = DateTime.now();
        if (_lastSpeakAt != null &&
            now.difference(_lastSpeakAt!) < _speakDebounce) {
          return;
        }
        _lastSpeakAt = now;

        await _speakOnly(text);

        if (!_isCurrentVoiceAction(generation)) return;

        // Resume ambient listening
        if (!_isDisposed &&
            _shouldKeepListening &&
            _state.mode != HandsfreeMode.awaitingUnknownEventAnswer) {
          _setState(_state.copyWith(mode: HandsfreeMode.listening));
          await Future.delayed(const Duration(milliseconds: 200));
          _startListeningLoop();
        }
      });

  /// Speaks without resuming the ambient mic (used in answer-capture flow).
  Future<void> _speakOnly(String text) async {
    if (_isDisposed) return;
    _setState(
      _state.copyWith(mode: HandsfreeMode.speaking, lastSpokenText: text),
    );
    // Block restart callbacks before stopping recognition, including prompts.
    try {
      await _stt.stop();
    } catch (_) {}
    if (_isDisposed || _state.mode != HandsfreeMode.speaking) return;
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

}
