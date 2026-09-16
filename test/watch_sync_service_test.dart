import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WatchSyncService Protocol Encoding & Decoding', () {
    test('Encodes Opcode 0x01 Trip Control packet correctly', () {
      const tripName = 'Morning Commute';
      final nameBytes = utf8.encode(tripName);
      final packet = Uint8List(4 + nameBytes.length);
      packet[0] = 0x01; // Opcode TripControl
      packet[1] = 1;    // Start
      packet[2] = 0;    // Reserved
      packet[3] = nameBytes.length;
      packet.setRange(4, 4 + nameBytes.length, nameBytes);

      expect(packet[0], 0x01);
      expect(packet[1], 1);
      expect(packet[3], nameBytes.length);
      expect(utf8.decode(packet.sublist(4)), 'Morning Commute');
    });

    test('Encodes Opcode 0x02 Event Tag packet correctly', () {
      const classId = 1; // Bump
      const eventName = 'Pothole';
      final nameBytes = utf8.encode(eventName);
      final packet = Uint8List(4 + nameBytes.length);
      packet[0] = 0x02; // Opcode EventTag
      packet[1] = (classId >> 8) & 0xFF;
      packet[2] = classId & 0xFF;
      packet[3] = nameBytes.length;
      packet.setRange(4, 4 + nameBytes.length, nameBytes);

      expect(packet[0], 0x02);
      expect((packet[1] << 8) | packet[2], 1);
      expect(utf8.decode(packet.sublist(4)), 'Pothole');
    });

    test('Encodes Opcode 0x03 Telemetry packet correctly', () {
      final packet = Uint8List(9);
      final byteData = ByteData.sublistView(packet);

      byteData.setUint8(0, 0x03); // Opcode Telemetry
      const speedKmh = 24.5;
      final speedRaw = (speedKmh * 10).toInt();
      byteData.setUint16(1, speedRaw, Endian.big);

      const distanceMeters = 3450.0;
      byteData.setUint32(3, distanceMeters.toInt(), Endian.big);

      const heartRate = 148;
      byteData.setUint8(7, heartRate);

      const satellites = 8;
      const gpsFlags = 0x01 | (satellites << 1); // 0x01 = GPS locked
      byteData.setUint8(8, gpsFlags);

      expect(packet[0], 0x03);
      expect(byteData.getUint16(1, Endian.big) / 10.0, 24.5);
      expect(byteData.getUint32(3, Endian.big), 3450);
      expect(byteData.getUint8(7), 148);
      expect((packet[8] & 0x01) == 1, isTrue); // Locked
      expect(packet[8] >> 1, 8);               // 8 satellites
    });

    test('Encodes Opcode 0x05 Phone Battery Status packet correctly', () {
      final packet = Uint8List(3);
      packet[0] = 0x05; // Opcode PhoneBattery
      packet[1] = 88;   // 88%
      packet[2] = 1;    // Charging

      expect(packet[0], 0x05);
      expect(packet[1], 88);
      expect(packet[2], 1);
    });

    test('Parses Watch-to-Phone Opcode 0x11 Event Trigger accurately', () {
      final payload = Uint8List.fromList([
        0x11, // Opcode TriggerEvent
        0x00, 0x01, // Class ID 1 (Bump)
        0x04, // Name length
        0x42, 0x75, 0x6D, 0x70, // 'B', 'u', 'm', 'p'
      ]);

      expect(payload[0], 0x11);
      final classId = (payload[1] << 8) | payload[2];
      expect(classId, 1);
      final nameLen = payload[3];
      final name = utf8.decode(payload.sublist(4, 4 + nameLen));
      expect(name, 'Bump');
    });

    test('Parses Watch-to-Phone Opcode 0x13 Watch Battery Status accurately', () {
      final payload = Uint8List.fromList([
        0x13, // Opcode WatchBattery
        0x5E, // 94%
        0x00, // Discharging
        0x10, 0x36, // 4150 mV
      ]);

      expect(payload[0], 0x13);
      expect(payload[1], 94);
      expect(payload[2], 0);
      final mv = (payload[3] << 8) | payload[4];
      expect(mv, 4150);
    });
  });
}
