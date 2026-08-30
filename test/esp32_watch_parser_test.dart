import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/parsers/esp32_watch_parser.dart';

void main() {
  group('Esp32WatchParser 13-Byte Binary Protocol Tests', () {
    test('GATT Identifiers match firmware specifications', () {
      expect(Esp32WatchParser.esp32DeviceName, 'ESP32-Watch');
      expect(Esp32WatchParser.esp32ServiceUuid, '0000ffe0-0000-1000-8000-00805f9b34fb');
      expect(Esp32WatchParser.esp32DataCharUuid, '0000ffe1-0000-1000-8000-00805f9b34fb');
      expect(Esp32WatchParser.shortServiceUuid, 'ffe0');
      expect(Esp32WatchParser.shortCharUuid, 'ffe1');
      expect(Esp32WatchParser.cccdDescriptorUuid, '00002902-0000-1000-8000-00805f9b34fb');
      expect(Esp32WatchParser.expectedPayloadLength, 13);
    });

    test('Parses exact 13-byte Little-Endian binary payload accurately', () {
      const deviceId = 'AA:BB:CC:DD:EE:FF';
      const deviceName = 'ESP32-Watch';

      // 13-byte structure:
      // Offset 0: HR (uint8) = 78 BPM
      // Offset 1..4: Accel X (float32 little-endian) = 1.25 m/s²
      // Offset 5..8: Accel Y (float32 little-endian) = -2.50 m/s²
      // Offset 9..12: Accel Z (float32 little-endian) = 9.81 m/s²
      final byteData = ByteData(13);
      byteData.setUint8(0, 78);
      byteData.setFloat32(1, 1.25, Endian.little);
      byteData.setFloat32(5, -2.50, Endian.little);
      byteData.setFloat32(9, 9.81, Endian.little);

      final payloadBytes = byteData.buffer.asUint8List();
      expect(payloadBytes.length, 13);

      final parsed = Esp32WatchParser.parseEsp32Payload(
        deviceId,
        deviceName,
        payloadBytes,
      );

      expect(parsed, isNotNull);
      expect(parsed!.deviceId, deviceId);
      expect(parsed.deviceName, deviceName);
      expect(parsed.deviceType, DeviceType.watch);
      expect(parsed.heartRate, 78);
      expect(parsed.accelX, closeTo(1.25, 0.001));
      expect(parsed.accelY, closeTo(-2.50, 0.001));
      expect(parsed.accelZ, closeTo(9.81, 0.001));
      expect(parsed.rawBytes.length, 13);
      expect(parsed.rawHex, contains('0x4E')); // 78 in hex is 0x4E
    });

    test('Handles zero acceleration and boundary HR values', () {
      final byteData = ByteData(13);
      byteData.setUint8(0, 220); // High BPM
      byteData.setFloat32(1, 0.0, Endian.little);
      byteData.setFloat32(5, 0.0, Endian.little);
      byteData.setFloat32(9, 0.0, Endian.little);

      final parsed = Esp32WatchParser.parseEsp32Payload(
        'watch_test_2',
        'ESP32-Watch',
        byteData.buffer.asUint8List(),
      );

      expect(parsed, isNotNull);
      expect(parsed!.heartRate, 220);
      expect(parsed.accelX, 0.0);
      expect(parsed.accelY, 0.0);
      expect(parsed.accelZ, 0.0);
    });

    test('Handles partial / truncated byte arrays safely', () {
      // Empty input
      final emptyResult = Esp32WatchParser.parseEsp32Payload('watch_test_3', '', []);
      expect(emptyResult, isNull);

      // Single HR byte (1 byte only)
      final singleByteResult = Esp32WatchParser.parseEsp32Payload(
        'watch_test_3',
        'ESP32-Watch',
        [85],
      );
      expect(singleByteResult, isNotNull);
      expect(singleByteResult!.heartRate, 85);
      expect(singleByteResult.accelX, isNull);
      expect(singleByteResult.accelY, isNull);
      expect(singleByteResult.accelZ, isNull);
    });
  });
}
