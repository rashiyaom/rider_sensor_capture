import 'dart:convert';
import 'dart:typed_data';
import '../../core/utils/angular_units.dart';
import '../models/raw_sensor_data.dart';
import '../models/ble_device_model.dart';

/// Binary & String parser for the ESP32-S3 Watch 6-Axis IMU Telemetry firmware.
///
/// BLE GATT Protocol Specifications:
/// - Advertised Device Name: `ESP32-Watch`
/// - Service UUID: `0000FFE0-0000-1000-8000-00805F9B34FB` (Short UUID: `0xFFE0` / `ffe0`)
/// - Characteristic UUID: `0000FFE1-0000-1000-8000-00805F9B34FB` (Short UUID: `0xFFE1` / `ffe1`)
/// - Descriptor: CCCD `0x2902` (00002902-0000-1000-8000-00805F9B34FB)
///
/// Supported Payload Structures:
/// 1. 28-Byte Binary (Standard 50Hz 6-Axis + Timestamp):
///    - Offset 0..3 (4 bytes, uint32 little-endian): `timestamp_ms`
///    - Offset 4..7 (4 bytes, float32 little-endian): `acc_x` (in g or m/s²)
///    - Offset 8..11 (4 bytes, float32 little-endian): `acc_y` (in g or m/s²)
///    - Offset 12..15 (4 bytes, float32 little-endian): `acc_z` (in g or m/s²)
///    - Offset 16..19 (4 bytes, float32 little-endian): `gyro_x` (in dps or rad/s)
///    - Offset 20..23 (4 bytes, float32 little-endian): `gyro_y` (in dps or rad/s)
///    - Offset 24..27 (4 bytes, float32 little-endian): `gyro_z` (in dps or rad/s)
///
/// 2. 24-Byte Binary (50Hz 6-Axis Floats):
///    - Offset 0..11: `acc_x, acc_y, acc_z` (3x float32)
///    - Offset 12..23: `gyro_x, gyro_y, gyro_z` (3x float32)
///
/// 3. 16-Byte Binary (Timestamp + 3-Axis Accel Floats):
///    - Offset 0..3: `timestamp_ms` (uint32)
///    - Offset 4..15: `acc_x, acc_y, acc_z` (3x float32)
///
/// 4. 12-Byte Binary (3-Axis Accel Floats):
///    - Offset 0..11: `acc_x, acc_y, acc_z` (3x float32)
///
/// 5. ASCII CSV String Fallback:
///    - Comma-delimited text like `acc_x,acc_y,acc_z,gyro_x,gyro_y,gyro_z`
class Esp32WatchParser {
  static const String esp32DeviceName = 'ESP32-Watch';
  static const String esp32ServiceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String esp32DataCharUuid = '0000ffe1-0000-1000-8000-00805f9b34fb';
  static const String shortServiceUuid = 'ffe0';
  static const String shortCharUuid = 'ffe1';
  static const String cccdDescriptorUuid = '00002902-0000-1000-8000-00805f9b34fb';
  static const String shortCccdDescriptorUuid = '2902';

  /// Unpacks the binary or ASCII stream from the ESP32 watch into a strongly-typed [RawSensorData] model.
  static RawSensorData? parseEsp32Payload(
    String deviceId,
    String deviceName,
    List<int> dataBytes,
  ) {
    if (dataBytes.isEmpty) return null;

    double? ax, ay, az;
    double? gx, gy, gz;
    String? inferredMount;

    try {
      final uint8List = dataBytes is Uint8List
          ? dataBytes
          : Uint8List.fromList(dataBytes);
      final byteData = ByteData.sublistView(uint8List);
      final len = uint8List.length;

      final isV2 = len >= 32;

      // ── Format 1: ASCII CSV String (contains comma 0x2C) ──
      if (dataBytes.contains(0x2C)) {
        final text = utf8.decode(dataBytes, allowMalformed: true).trim();
        final tokens = text.split(',').map((s) => double.tryParse(s.trim())).toList();
        if (tokens.length >= 3 && tokens[0] != null) {
          // Check if first token is timestamp
          if (tokens.length >= 7 && (tokens[0]! > 1000 || tokens[0]! == tokens[0]!.roundToDouble())) {
            ax = tokens[1];
            ay = tokens[2];
            az = tokens[3];
            gx = tokens[4];
            gy = tokens[5];
            gz = tokens[6];
          } else if (tokens.length >= 6) {
            ax = tokens[0];
            ay = tokens[1];
            az = tokens[2];
            gx = tokens[3];
            gy = tokens[4];
            gz = tokens[5];
          } else if (tokens.length >= 3) {
            ax = tokens[0];
            ay = tokens[1];
            az = tokens[2];
          }
        }
      }
      // ── Format 2: 32-Byte Binary V2 (Timestamp + Seq + Role + 6-Axis Floats + Battery) ──
      else if (isV2) {
        final roleByte = byteData.getUint8(6);
        if (roleByte == 1) {
          inferredMount = 'fork';
        } else if (roleByte == 2) {
          inferredMount = 'footboard';
        }
        ax = byteData.getFloat32(7, Endian.little);
        ay = byteData.getFloat32(11, Endian.little);
        az = byteData.getFloat32(15, Endian.little);
        gx = byteData.getFloat32(19, Endian.little);
        gy = byteData.getFloat32(23, Endian.little);
        gz = byteData.getFloat32(27, Endian.little);
      }
      // ── Format 3: 28-Byte Binary (Timestamp + 6-Axis Floats) ──
      else if (len >= 28) {
        ax = byteData.getFloat32(4, Endian.little);
        ay = byteData.getFloat32(8, Endian.little);
        az = byteData.getFloat32(12, Endian.little);
        gx = byteData.getFloat32(16, Endian.little);
        gy = byteData.getFloat32(20, Endian.little);
        gz = byteData.getFloat32(24, Endian.little);
      }
      // ── Format 4: 24-Byte Binary (6-Axis Floats) ──
      else if (len >= 24) {
        ax = byteData.getFloat32(0, Endian.little);
        ay = byteData.getFloat32(4, Endian.little);
        az = byteData.getFloat32(8, Endian.little);
        gx = byteData.getFloat32(12, Endian.little);
        gy = byteData.getFloat32(16, Endian.little);
        gz = byteData.getFloat32(20, Endian.little);
      }
      // ── Format 5: 16-Byte Binary (Timestamp + 3-Axis Accel Floats) ──
      else if (len >= 16) {
        ax = byteData.getFloat32(4, Endian.little);
        ay = byteData.getFloat32(8, Endian.little);
        az = byteData.getFloat32(12, Endian.little);
      }
      // ── Format 6: 12-Byte Binary (3-Axis Accel Floats) ──
      else if (len >= 12) {
        ax = byteData.getFloat32(0, Endian.little);
        ay = byteData.getFloat32(4, Endian.little);
        az = byteData.getFloat32(8, Endian.little);
      }

      // Infer mount location from device name if not in packet
      if (inferredMount == null) {
        final upper = deviceName.toUpperCase();
        if (upper.contains('FORK')) {
          inferredMount = 'fork';
        } else if (upper.contains('FOOT')) {
          inferredMount = 'footboard';
        }
      }

      // Convert unit if watch reports in 'g' instead of 'm/s²' (normal range check for legacy packets only)
      if (!isV2 && ax != null && ay != null && az != null) {
        if (!ax.isFinite || !ay.isFinite || !az.isFinite) {
          ax = null;
          ay = null;
          az = null;
        } else {
          // If legacy values are within ±8 range, they might be in g's -> scale to m/s² for chart
          final mag = ax * ax + ay * ay + az * az;
          if (mag > 0.1 && mag < 16.0) {
            ax = ax * AngularUnits.standardGravity;
            ay = ay * AngularUnits.standardGravity;
            az = az * AngularUnits.standardGravity;
          }
        }
      }

      if (gx != null && (!gx.isFinite || !gy!.isFinite || !gz!.isFinite)) {
        gx = null;
        gy = null;
        gz = null;
      }
    } catch (_) {
      // Gracefully handle malformed frame
    }

    return RawSensorData(
      deviceId: deviceId,
      deviceName: deviceName.isNotEmpty ? deviceName : esp32DeviceName,
      deviceType: DeviceType.watch,
      timestamp: DateTime.now(),
      mountLocation: inferredMount ?? 'fork',
      heartRate: null, // ESP32 Watch is a dedicated 6-axis IMU, not a Polar HR band
      accelX: ax,
      accelY: ay,
      accelZ: az,
      gyroX: gx,
      gyroY: gy,
      gyroZ: gz,
      rawBytes: dataBytes,
    );
  }
}
