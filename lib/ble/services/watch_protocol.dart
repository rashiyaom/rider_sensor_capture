import 'dart:convert';
import 'dart:typed_data';

/// Companion wire format. Multibyte fields are big endian, unlike IMU packets.
/// Packets stay within the default 20-byte ATT payload, even before MTU exchange.
class WatchProtocol {
  static List<int> _name(String name) {
    final bytes = <int>[];
    for (final rune in name.runes) {
      final encoded = utf8.encode(String.fromCharCode(rune));
      if (bytes.length + encoded.length > 16) break;
      bytes.addAll(encoded);
    }
    return bytes;
  }

  static List<int> trip(bool active, String name) {
    final bytes = _name(name);
    return [0x01, active ? 1 : 0, 0, bytes.length, ...bytes];
  }

  static List<int> event(int id, String name) {
    final bytes = _name(name);
    return [0x02, (id >> 8) & 255, id & 255, bytes.length, ...bytes];
  }

  static Uint8List telemetry({
    required double speedKmh,
    required double distanceMeters,
    required int heartRate,
    required bool gpsLocked,
    int satellites = 0,
  }) {
    final packet = Uint8List(9);
    final data = ByteData.sublistView(packet);
    data.setUint8(0, 0x03);
    data.setUint16(
      1,
      speedKmh.isFinite ? (speedKmh * 10).clamp(0, 65535).toInt() : 0,
      Endian.big,
    );
    data.setUint32(
      3,
      distanceMeters.isFinite ? distanceMeters.clamp(0, 4294967295).toInt() : 0,
      Endian.big,
    );
    data.setUint8(7, heartRate.clamp(0, 255));
    data.setUint8(8, (gpsLocked ? 1 : 0) | (satellites.clamp(0, 127) << 1));
    return packet;
  }

  static Uint8List time(DateTime now) {
    final packet = Uint8List(7);
    final data = ByteData.sublistView(packet);
    data.setUint8(0, 0x04);
    data.setUint32(1, now.millisecondsSinceEpoch ~/ 1000, Endian.big);
    data.setInt16(5, now.timeZoneOffset.inMinutes, Endian.big);
    return packet;
  }

  static Uint8List elapsed(Duration elapsed) {
    final packet = Uint8List(5);
    final data = ByteData.sublistView(packet);
    data.setUint8(0, 0x08);
    data.setUint32(1, elapsed.inSeconds.clamp(0, 4294967295), Endian.big);
    return packet;
  }

  static List<int> appearance(int face, int brightness) => [
    0x07,
    face.clamp(0, 1),
    brightness.clamp(30, 255),
  ];
}
