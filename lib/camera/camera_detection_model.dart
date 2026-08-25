import 'dart:convert';

/// Validated payload parsed from the camera firmware's HTTP POST body.
class CameraDetectionPayload {
  final String eventClass;
  final double confidence;
  final DateTime cameraTimestampUtc;
  final String deviceId;

  const CameraDetectionPayload({
    required this.eventClass,
    required this.confidence,
    required this.cameraTimestampUtc,
    required this.deviceId,
  });

  /// Parses and validates a JSON body string.
  /// Returns null if any required field is missing or malformed.
  static CameraDetectionPayload? fromJsonString(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      return fromMap(map);
    } catch (_) {
      return null;
    }
  }

  static CameraDetectionPayload? fromMap(Map<String, dynamic> map) {
    final eventClass = map['event_class'];
    final confidence = map['confidence'];
    final cameraTs = map['camera_timestamp_utc'];
    final deviceId = map['device_id'];

    if (eventClass == null ||
        eventClass is! String ||
        eventClass.trim().isEmpty) {
      return null;
    }
    if (confidence == null || confidence is! num) {
      return null;
    }
    if (cameraTs == null || cameraTs is! String) {
      return null;
    }
    if (deviceId == null || deviceId is! String || deviceId.trim().isEmpty) {
      return null;
    }

    final parsedTs = DateTime.tryParse(cameraTs);
    if (parsedTs == null) return null;

    final confValue = confidence.toDouble();
    if (confValue < 0.0 || confValue > 1.0) return null;

    return CameraDetectionPayload(
      eventClass: eventClass.trim(),
      confidence: confValue,
      cameraTimestampUtc: parsedTs.toUtc(),
      deviceId: deviceId.trim(),
    );
  }

  @override
  String toString() =>
      'CameraDetectionPayload(class=$eventClass, conf=${confidence.toStringAsFixed(2)}, '
      'camTs=${cameraTimestampUtc.toIso8601String()}, device=$deviceId)';
}
