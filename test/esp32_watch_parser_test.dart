import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/parsers/esp32_watch_parser.dart';

void main() {
  group('Esp32WatchParser 6-Axis IMU Protocol Tests', () {
    test('GATT Identifiers match firmware specifications', () {
      expect(Esp32WatchParser.esp32DeviceName, 'ESP32-Watch');
      expect(Esp32WatchParser.esp32ServiceUuid, '0000ffe0-0000-1000-8000-00805f9b34fb');
      expect(Esp32WatchParser.esp32DataCharUuid, '0000ffe1-0000-1000-8000-00805f9b34fb');
      expect(Esp32WatchParser.shortServiceUuid, 'ffe0');
      expect(Esp32WatchParser.shortCharUuid, 'ffe1');
      expect(Esp32WatchParser.cccdDescriptorUuid, '00002902-0000-1000-8000-00805f9b34fb');
    });

    test('Parses 28-byte Standard Binary Payload (uint32 timestamp + 6 floats)', () {
      const deviceId = 'AA:BB:CC:DD:EE:FF';
      const deviceName = 'ESP32-Watch';

      // 28-byte structure:
      // Offset 0..3: uint32 timestamp_ms = 12500
      // Offset 4..7: Accel X = 0.5 g -> converts to 4.903 m/s²
      // Offset 8..11: Accel Y = 1.0 g -> converts to 9.807 m/s²
      // Offset 12..15: Accel Z = 0.0 g -> 0.0 m/s²
      // Offset 16..19: Gyro X = 12.5 dps
      // Offset 20..23: Gyro Y = -4.2 dps
      // Offset 24..27: Gyro Z = 98.1 dps
      final byteData = ByteData(28);
      byteData.setUint32(0, 12500, Endian.little);
      byteData.setFloat32(4, 0.5, Endian.little);
      byteData.setFloat32(8, 1.0, Endian.little);
      byteData.setFloat32(12, 0.0, Endian.little);
      byteData.setFloat32(16, 12.5, Endian.little);
      byteData.setFloat32(20, -4.2, Endian.little);
      byteData.setFloat32(24, 98.1, Endian.little);

      final payloadBytes = byteData.buffer.asUint8List();
      expect(payloadBytes.length, 28);

      final parsed = Esp32WatchParser.parseEsp32Payload(
        deviceId,
        deviceName,
        payloadBytes,
      );

      expect(parsed, isNotNull);
      expect(parsed!.deviceId, deviceId);
      expect(parsed.deviceName, deviceName);
      expect(parsed.deviceType, DeviceType.watch);
      expect(parsed.heartRate, isNull); // ESP32 Watch has no false heart rate
      expect(parsed.accelX, closeTo(0.5 * 9.80665, 0.01));
      expect(parsed.accelY, closeTo(1.0 * 9.80665, 0.01));
      expect(parsed.accelZ, closeTo(0.0, 0.01));
      expect(parsed.gyroX, closeTo(12.5, 0.01));
      expect(parsed.gyroY, closeTo(-4.2, 0.01));
      expect(parsed.gyroZ, closeTo(98.1, 0.01));
      expect(parsed.rawBytes.length, 28);
    });

    test('Parses 32-byte V2 Binary Payload (Timestamp, Seq, MountRole FORK, 6 SI Floats, Battery)', () {
      final byteData = ByteData(32);
      byteData.setUint32(0, 150000, Endian.little); // timestamp_ms
      byteData.setUint16(4, 1024, Endian.little);   // seq
      byteData.setUint8(6, 1);                       // mount_role = 1 (FORK)
      byteData.setFloat32(7, 0.25, Endian.little);   // accel_x (m/s²)
      byteData.setFloat32(11, -0.15, Endian.little); // accel_y (m/s²)
      byteData.setFloat32(15, 9.81, Endian.little);  // accel_z (m/s²)
      byteData.setFloat32(19, 0.05, Endian.little);  // gyro_x (rad/s)
      byteData.setFloat32(23, -0.02, Endian.little); // gyro_y (rad/s)
      byteData.setFloat32(27, 0.01, Endian.little);  // gyro_z (rad/s)
      byteData.setUint8(31, 88);                     // battery_pct = 88%

      final parsed = Esp32WatchParser.parseEsp32Payload(
        'watch_fork_01',
        'ESP32-Watch-FORK',
        byteData.buffer.asUint8List(),
      );

      expect(parsed, isNotNull);
      expect(parsed!.mountLocation, 'fork');
      expect(parsed.accelX, closeTo(0.25, 0.01));
      expect(parsed.accelY, closeTo(-0.15, 0.01));
      expect(parsed.accelZ, closeTo(9.81, 0.01));
      expect(parsed.gyroX, closeTo(0.05, 0.005));
      expect(parsed.gyroY, closeTo(-0.02, 0.005));
      expect(parsed.gyroZ, closeTo(0.01, 0.005));
    });

    test('Parses 32-byte V2 Binary Payload with MountRole FOOTBOARD', () {
      final byteData = ByteData(32);
      byteData.setUint32(0, 150100, Endian.little);
      byteData.setUint16(4, 1025, Endian.little);
      byteData.setUint8(6, 2); // mount_role = 2 (FOOTBOARD)
      byteData.setFloat32(7, 1.10, Endian.little);
      byteData.setFloat32(11, -0.40, Endian.little);
      byteData.setFloat32(15, 9.80, Endian.little);
      byteData.setFloat32(19, 0.12, Endian.little);
      byteData.setFloat32(23, 0.00, Endian.little);
      byteData.setFloat32(27, -0.05, Endian.little);
      byteData.setUint8(31, 92);

      final parsed = Esp32WatchParser.parseEsp32Payload(
        'watch_foot_01',
        'ESP32-Watch-FOOT',
        byteData.buffer.asUint8List(),
      );

      expect(parsed, isNotNull);
      expect(parsed!.mountLocation, 'footboard');
      expect(parsed.accelX, closeTo(1.10, 0.01));
      expect(parsed.accelZ, closeTo(9.80, 0.01));
    });

    test('Parses 24-byte Binary Payload (6 floats directly)', () {
      final byteData = ByteData(24);
      byteData.setFloat32(0, 1.2, Endian.little);
      byteData.setFloat32(4, -0.8, Endian.little);
      byteData.setFloat32(8, 9.8, Endian.little);
      byteData.setFloat32(12, 0.1, Endian.little);
      byteData.setFloat32(16, -0.2, Endian.little);
      byteData.setFloat32(20, 0.3, Endian.little);

      final parsed = Esp32WatchParser.parseEsp32Payload(
        'watch_test_24b',
        'ESP32-Watch',
        byteData.buffer.asUint8List(),
      );

      expect(parsed, isNotNull);
      expect(parsed!.heartRate, isNull);
      expect(parsed.accelX, isNotNull);
      expect(parsed.accelY, isNotNull);
      expect(parsed.accelZ, isNotNull);
      expect(parsed.gyroX, closeTo(0.1, 0.01));
      expect(parsed.gyroY, closeTo(-0.2, 0.01));
      expect(parsed.gyroZ, closeTo(0.3, 0.01));
    });

    test('Parses ASCII CSV string fallback', () {
      final csvString = '5000,0.0134,0.9812,0.0451,-0.234,1.109,-0.516';
      final bytes = utf8.encode(csvString);

      final parsed = Esp32WatchParser.parseEsp32Payload(
        'watch_csv',
        'ESP32-Watch',
        bytes,
      );

      expect(parsed, isNotNull);
      expect(parsed!.heartRate, isNull);
      expect(parsed.accelX, isNotNull);
      expect(parsed.accelY, isNotNull);
      expect(parsed.accelZ, isNotNull);
      expect(parsed.gyroX, closeTo(-0.234, 0.01));
      expect(parsed.gyroY, closeTo(1.109, 0.01));
      expect(parsed.gyroZ, closeTo(-0.516, 0.01));
    });

    test('Handles empty input gracefully', () {
      final emptyResult = Esp32WatchParser.parseEsp32Payload('watch_test_3', '', []);
      expect(emptyResult, isNull);
    });
  });
}
