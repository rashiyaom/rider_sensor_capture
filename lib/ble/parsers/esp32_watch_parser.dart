import 'dart:typed_data';
import '../models/raw_sensor_data.dart';
import '../models/ble_device_model.dart';

/// Binary parser for the ESP32-S3 Watch IMU & Telemetry firmware.
///
/// BLE GATT Protocol Specifications:
/// - Advertised Device Name: `ESP32-Watch`
/// - Service UUID: `0000FFE0-0000-1000-8000-00805F9B34FB` (Short UUID: `0xFFE0` / `ffe0`)
/// - Characteristic UUID: `0000FFE1-0000-1000-8000-00805F9B34FB` (Short UUID: `0xFFE1` / `ffe1`)
/// - Descriptor: CCCD `0x2902` (00002902-0000-1000-8000-00805F9B34FB)
///
/// 13-Byte Binary Payload Structure:
/// - Offset 0 (1 byte, uint8): Heart Rate in BPM
/// - Offset 1..4 (4 bytes, float32 little-endian): Accelerometer X in m/s²
/// - Offset 5..8 (4 bytes, float32 little-endian): Accelerometer Y in m/s²
/// - Offset 9..12 (4 bytes, float32 little-endian): Accelerometer Z in m/s²
class Esp32WatchParser {
  static const String esp32DeviceName = 'ESP32-Watch';
  static const String esp32ServiceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String esp32DataCharUuid = '0000ffe1-0000-1000-8000-00805f9b34fb';
  static const String shortServiceUuid = 'ffe0';
  static const String shortCharUuid = 'ffe1';
  static const String cccdDescriptorUuid = '00002902-0000-1000-8000-00805f9b34fb';
  static const String shortCccdDescriptorUuid = '2902';

  static const int expectedPayloadLength = 13;

  /// Unpacks the 13-byte Little-Endian binary stream into a strongly-typed [RawSensorData] model.
  static RawSensorData? parseEsp32Payload(
    String deviceId,
    String deviceName,
    List<int> dataBytes,
  ) {
    if (dataBytes.isEmpty) return null;

    int? hr;
    double? ax, ay, az;

    try {
      final uint8List = dataBytes is Uint8List
          ? dataBytes
          : Uint8List.fromList(dataBytes);
      final byteData = ByteData.sublistView(uint8List);

      // Offset 0: Heart Rate (uint8)
      if (uint8List.isNotEmpty) {
        hr = byteData.getUint8(0);
      }

      // Offset 1..4: Accel X (float32 little-endian)
      // Offset 5..8: Accel Y (float32 little-endian)
      // Offset 9..12: Accel Z (float32 little-endian)
      if (uint8List.length >= expectedPayloadLength) {
        ax = byteData.getFloat32(1, Endian.little);
        ay = byteData.getFloat32(5, Endian.little);
        az = byteData.getFloat32(9, Endian.little);
      }
    } catch (_) {
      // Return partial or raw telemetry on parsing anomaly
    }

    return RawSensorData(
      deviceId: deviceId,
      deviceName: deviceName.isNotEmpty ? deviceName : esp32DeviceName,
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
