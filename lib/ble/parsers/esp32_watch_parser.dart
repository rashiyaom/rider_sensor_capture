import 'dart:typed_data';
import '../models/raw_sensor_data.dart';
import '../models/ble_device_model.dart';

class Esp32WatchParser {
  // TODO: Replace placeholder GATT UUIDs with actual ESP32-S3 firmware UUIDs
  static const String esp32ServiceUuid = 'ffe0';
  static const String esp32DataCharUuid = 'ffe1';

  static RawSensorData? parseEsp32Payload(
    String deviceId,
    String deviceName,
    List<int> dataBytes,
  ) {
    if (dataBytes.isEmpty) return null;

    int? hr;
    double? ax, ay, az;

    try {
      final bytes = ByteData.sublistView(Uint8List.fromList(dataBytes));

      // Packet Format Assumption:
      // Byte 0: HR (uint8)
      // Bytes 1-4: Accel X (float32)
      // Bytes 5-8: Accel Y (float32)
      // Bytes 9-12: Accel Z (float32)
      if (dataBytes.isNotEmpty) {
        hr = dataBytes[0];
      }

      if (dataBytes.length >= 13) {
        ax = bytes.getFloat32(1, Endian.little);
        ay = bytes.getFloat32(5, Endian.little);
        az = bytes.getFloat32(9, Endian.little);
      }
    } catch (_) {
      // Fallback parser if custom raw stream is sent
    }

    return RawSensorData(
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: DeviceType.watch,
      timestamp: DateTime.now(),
      heartRate: hr,
      accelX: ax,
      accelY: ay,
      accelZ: az,
      rawBytes: dataBytes,
    );
  }
}
