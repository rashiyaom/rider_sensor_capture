import 'ble_device_model.dart';

class RawSensorData {
  final String deviceId;
  final String deviceName;
  final DeviceType deviceType;
  final DateTime timestamp;
  final String mountLocation; // 'fork', 'footboard', 'forearm'
  final int? heartRate;
  final double? accelX;
  final double? accelY;
  final double? accelZ;
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;
  final int? ppiMs;
  final List<int> rawBytes;

  const RawSensorData({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.timestamp,
    this.mountLocation = 'fork',
    this.heartRate,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.ppiMs,
    required this.rawBytes,
  });

  RawSensorData copyWith({
    String? mountLocation,
  }) {
    return RawSensorData(
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: deviceType,
      timestamp: timestamp,
      mountLocation: mountLocation ?? this.mountLocation,
      heartRate: heartRate,
      accelX: accelX,
      accelY: accelY,
      accelZ: accelZ,
      gyroX: gyroX,
      gyroY: gyroY,
      gyroZ: gyroZ,
      ppiMs: ppiMs,
      rawBytes: rawBytes,
    );
  }

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
    parts.add('MOUNT: $mountLocation');
    if (heartRate != null) parts.add('HR: ${heartRate}bpm');
    if (accelX != null && accelY != null && accelZ != null) {
      parts.add(
        'ACC: [${accelX!.toStringAsFixed(2)}, ${accelY!.toStringAsFixed(2)}, ${accelZ!.toStringAsFixed(2)}]',
      );
    }
    if (gyroX != null && gyroY != null && gyroZ != null) {
      parts.add(
        'GYRO: [${gyroX!.toStringAsFixed(1)}, ${gyroY!.toStringAsFixed(1)}, ${gyroZ!.toStringAsFixed(1)}]',
      );
    }
    if (ppiMs != null) parts.add('PPI: ${ppiMs}ms');
    if (rawBytes.isNotEmpty) {
      parts.add('HEX: $rawHex');
    }
    return '[${deviceName.isEmpty ? deviceId : deviceName}] ${parts.join(" | ")}';
  }
}
