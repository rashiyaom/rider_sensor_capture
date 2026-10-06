import 'package:flutter/services.dart';

/// Provides tactile haptic feedback and acoustic alerts for the rider.
/// Allows the rider to safely confirm event triggers, voice commands, and journey lifecycle
/// without taking their eyes off the road.
class RiderFeedbackService {
  RiderFeedbackService._();

  /// Strong tactile impact and audio tone when an event starts (e.g. Bump, Turn, Speed Test)
  static Future<void> onEventStarted() async {
    try {
      await HapticFeedback.heavyImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Medium tactile impact when an active event completes
  static Future<void> onEventStopped() async {
    try {
      await HapticFeedback.mediumImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Pulsed vibration when a voice command is successfully matched
  static Future<void> onVoiceCommandTriggered() async {
    try {
      await HapticFeedback.vibrate();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Journey start feedback
  static Future<void> onTripStarted() async {
    try {
      await HapticFeedback.heavyImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Journey stop feedback
  static Future<void> onTripStopped() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.mediumImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
