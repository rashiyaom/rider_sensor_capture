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

  bool _initialized = false;
  bool _engineReady = false;
  bool _speaking = false;

  /// Text currently being spoken (useful for the UI "speaking" indicator).
  String? currentUtterance;

  VoiceAlertService({FlutterTts? tts, this.ttsEnabled = true}) {
    if (tts != null) _tts = tts;
  }

  /// True when the platform speech engine initialised successfully.
  bool get isAvailable => _engineReady;

  /// True while an utterance is in flight.
  bool get isSpeaking => _speaking;

  /// Lazily prepares the speech engine. Safe to call multiple times.
  Future<bool> ensureInitialized() async {
    if (_initialized) return _engineReady;
    _initialized = true;

    if (!ttsEnabled) {
      _engineReady = false;
      return false;
    }

    try {
      final engine = _tts ??= FlutterTts();
      await engine.awaitSpeakCompletion(false);
      await engine.setLanguage('en-US');
      await engine.setSpeechRate(0.55);
      await engine.setPitch(1.0);
      await engine.setVolume(1.0);
      _engineReady = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('VoiceAlertService: TTS unavailable ($e)');
      }
      _engineReady = false;
    }
    return _engineReady;
  }

  /// Speaks the given text.
  ///
  /// Returns `true` when the utterance was handed to the speech engine.
  Future<bool> speak(
    String text, {
    double rate = 0.55,
    double pitch = 1.0,
    bool interrupt = true,
    bool hapticFallback = true,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final ready = await ensureInitialized();
    if (!ready) {
      if (hapticFallback) {
        await _pulse();
      }
      return false;
    }

    try {
      final engine = _tts;
      if (engine == null) {
        if (hapticFallback) await _pulse();
        return false;
      }
      if (interrupt) {
        await engine.stop();
      }
      await engine.setSpeechRate(rate);
      await engine.setPitch(pitch);
      currentUtterance = trimmed;
      _speaking = true;
      final result = await engine.speak(trimmed);
      _speaking = false;
      currentUtterance = null;
      return result == 1;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('VoiceAlertService: speak failed ($e)');
      }
      _speaking = false;
      currentUtterance = null;
      if (hapticFallback) {
        await _pulse();
      }
      return false;
    }
  }

  /// Stops any in-flight utterance.
  Future<void> stop() async {
    final engine = _tts;
    if (!ttsEnabled || engine == null) return;
    try {
      await engine.stop();
    } catch (_) {}
    _speaking = false;
    currentUtterance = null;
  }

  /// Emergency pattern for the highest urgency alerts: two short pulses.
  Future<void> _pulse() async {
    try {
      await RiderFeedbackService.onPreAlertUrgent();
    } catch (_) {}
  }

  void dispose() {
    unawaited(stop());
  }
}
