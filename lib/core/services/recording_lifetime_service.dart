import 'dart:io';

import 'package:flutter/services.dart';

/// Requests an OS-visible process lifetime while a ride is actively recording.
/// This does not guarantee execution on every device; OS and vendor policies
/// still require physical-device validation.
class RecordingLifetimeService {
  static const _channel = MethodChannel(
    'ride_sensor_capture/recording_lifetime',
  );

  Future<void> start() async {
    if (!Platform.isAndroid) return;
    final started = await _channel.invokeMethod<bool>('start');
    if (started != true) {
      throw StateError('Android recording foreground service did not start.');
    }
  }

  Future<void> stop() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('stop');
  }
}
