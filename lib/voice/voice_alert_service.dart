import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../core/services/rider_feedback_service.dart';

/// Text-to-speech wrapper used by the predictive pre-alert system to deliver
/// spoken warnings to the rider.
///
/// The service is intentionally defensive: if the platform TTS engine is
/// unavailable (older device, missing engine, unit-test environment) the
/// alert degrades to a haptic pulse instead of throwing.
class VoiceAlertService {
  /// Lazily created so that no platform channel is touched until speech is
  /// actually required (keeps unit tests and headless runs clean).
  FlutterTts? _tts;

  /// Set to false to disable speech synthesis entirely (haptics only).
  final bool ttsEnabled;
  final Duration speechTimeout;

  Future<bool>? _initialization;
  Future<void> _speechQueue = Future<void>.value();
  Future<void> _stopFuture = Future<void>.value();
  Completer<bool>? _activeSpeech;
  int _generation = 0;
  bool _disposed = false;
  bool _engineReady = false;
  bool _speaking = false;

  /// Text currently being spoken (useful for the UI "speaking" indicator).
  String? currentUtterance;

  VoiceAlertService({
    FlutterTts? tts,
    this.ttsEnabled = true,
    this.speechTimeout = const Duration(seconds: 15),
  }) {
    if (tts != null) _tts = tts;
  }

  /// True when the platform speech engine initialised successfully.
  bool get isAvailable => _engineReady;

  /// True while an utterance is in flight.
  bool get isSpeaking => _speaking;

  /// Lazily prepares the speech engine. Safe to call multiple times.
  Future<bool> ensureInitialized() {
    if (_disposed) return Future.value(false);
    return _initialization ??= _initialize();
  }

  Future<bool> _initialize() async {
    if (!ttsEnabled) {
      _engineReady = false;
      return false;
    }

    try {
      final engine = _tts ??= FlutterTts();
      // Keep callers waiting until the last word has actually finished.
      await engine.awaitSpeakCompletion(true);
      engine.setErrorHandler((message) {
        if (kDebugMode) debugPrint('VoiceAlertService: $message');
        final active = _activeSpeech;
        if (active != null && !active.isCompleted) active.complete(false);
      });
      await engine.setLanguage('en-US');
      await engine.setSpeechRate(0.55);
      await engine.setPitch(1.0);
      await engine.setVolume(1.0);
      _engineReady = !_disposed;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('VoiceAlertService: TTS unavailable ($e)');
      }
      _engineReady = false;
    }
    return _engineReady;
  }

  /// Speaks messages in order and returns true only after playback completes.
  /// Use [interrupt] explicitly when the current and queued messages must stop.
  Future<bool> speak(
    String text, {
    double rate = 0.55,
    double pitch = 1.0,
    bool interrupt = false,
    bool hapticFallback = true,
    bool Function()? shouldSpeak,
    String Function()? textProvider,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _disposed) return Future.value(false);
    if (interrupt) unawaited(stop());
    final generation = _generation;
    final result = _speechQueue.then(
      (_) => _speak(
        trimmed,
        rate: rate,
        pitch: pitch,
        hapticFallback: hapticFallback,
        generation: generation,
        shouldSpeak: shouldSpeak,
        textProvider: textProvider,
      ),
    );
    _speechQueue = result.then<void>((_) {});
    return result;
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  Future<bool> _speak(
    String text, {
    required double rate,
    required double pitch,
    required bool hapticFallback,
    required int generation,
    bool Function()? shouldSpeak,
    String Function()? textProvider,
  }) async {
    if (!_isCurrent(generation) || (shouldSpeak != null && !shouldSpeak()))
      return false;
    await _stopFuture;
    if (!_isCurrent(generation) || (shouldSpeak != null && !shouldSpeak()))
      return false;
    final ready = await ensureInitialized();
    if (!_isCurrent(generation)) return false;
    if (!ready) {
      if (hapticFallback) await _pulse();
      return false;
    }

    try {
      final engine = _tts!;
      await engine.setSpeechRate(rate);
      if (!_isCurrent(generation)) return false;
      await engine.setPitch(pitch);
      if (!_isCurrent(generation)) return false;
      if (shouldSpeak != null && !shouldSpeak()) return false;
      final active = Completer<bool>();
      _activeSpeech = active;
      final utterance = (textProvider?.call() ?? text).trim();
      if (utterance.isEmpty) return false;
      currentUtterance = utterance;
      _speaking = true;
      // Some native error/stop paths don't settle the plugin's speak future.
      final success = await Future.any<bool>([
        engine.speak(utterance).then((result) => result == 1),
        active.future,
      ]).timeout(speechTimeout, onTimeout: () => false);
      if (!_isCurrent(generation)) return false;
      if (!success) {
        await engine.stop();
        if (hapticFallback) await _pulse();
      }
      return success;
    } catch (e) {
      if (kDebugMode) debugPrint('VoiceAlertService: speak failed ($e)');
      if (_isCurrent(generation) && hapticFallback) await _pulse();
      return false;
    } finally {
      _activeSpeech = null;
      _speaking = false;
      currentUtterance = null;
    }
  }

  /// Cancels the current utterance and all messages queued before this call.
  Future<void> stop() {
    _generation++;
    final active = _activeSpeech;
    if (active != null && !active.isCompleted) active.complete(false);
    _speaking = false;
    currentUtterance = null;
    _stopFuture = _stopFuture.then((_) async {
      try {
        await _tts?.stop();
      } catch (_) {}
    });
    return _stopFuture;
  }

  /// Emergency pattern for the highest urgency alerts: two short pulses.
  Future<void> _pulse() async {
    try {
      await RiderFeedbackService.onPreAlertUrgent();
    } catch (_) {}
  }

  void dispose() {
    _disposed = true;
    _engineReady = false;
    unawaited(stop());
  }
}
