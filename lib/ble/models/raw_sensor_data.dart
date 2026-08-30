import 'ble_device_model.dart';

class RawSensorData {
  final String deviceId;
  final String deviceName;
  final DeviceType deviceType;
  final DateTime timestamp;
  final int? heartRate;
  final double? accelX;
  final double? accelY;
  final double? accelZ;
  final int? ppiMs;
  final List<int> rawBytes;

  const RawSensorData({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.timestamp,
    this.heartRate,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.ppiMs,
    required this.rawBytes,
  });

  /// Formatted hex string representation of the raw byte stream (e.g. `0x00 0x7E 0x3F`)
  String get rawHex {
    if (rawBytes.isEmpty) return '[]';
    return rawBytes
        .map((b) => '0x${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
        .join(' ');
  }

  @override
  String toString() {
    final parts = <String>[];
    if (heartRate != null) parts.add('HR: ${heartRate}bpm');
    if (accelX != null && accelY != null && accelZ != null) {
      parts.add(
        'ACC: [${accelX!.toStringAsFixed(2)}, ${accelY!.toStringAsFixed(2)}, ${accelZ!.toStringAsFixed(2)}]',
      );
    }
    if (ppiMs != null) parts.add('PPI: ${ppiMs}ms');
    if (rawBytes.isNotEmpty) {
      parts.add('HEX: $rawHex');
    }
    return '[${deviceName.isEmpty ? deviceId : deviceName}] ${parts.join(" | ")}';
  }
}
