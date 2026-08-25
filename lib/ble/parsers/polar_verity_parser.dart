import 'dart:typed_data';
import '../models/raw_sensor_data.dart';
import '../models/ble_device_model.dart';

class PolarVerityParser {
  // Standard GATT Heart Rate Service UUID
  static const String heartRateServiceUuid = '180d';
  static const String heartRateMeasurementCharUuid = '2a37';

  // Polar PMD Service UUID for raw accelerometer / IMU
  static const String polarPmdServiceUuid = 'fb005c80-02e7-f38b-9d58-b8c9f0f23d58';
  static const String polarPmdDataCharUuid = 'fb005c82-02e7-f38b-9d58-b8c9f0f23d58';

  static RawSensorData? parseHeartRate(
    String deviceId,
    String deviceName,
    List<int> dataBytes,
  ) {
    if (dataBytes.isEmpty) return null;

    final flags = dataBytes[0];
    final is16Bit = (flags & 0x01) != 0;
    int hr = 0;
    int index = 1;

    if (is16Bit) {
      if (dataBytes.length < 3) return null;
      final bytes = ByteData.sublistView(Uint8List.fromList(dataBytes));
      hr = bytes.getUint16(1, Endian.little);
      index = 3;
    } else {
      if (dataBytes.length < 2) return null;
      hr = dataBytes[1];
      index = 2;
    }

    int? ppi;
    // Check if RR-Interval / PPI data is present (Bit 4)
    final rrPresent = (flags & 0x10) != 0;
    if (rrPresent && dataBytes.length >= index + 2) {
      final bytes = ByteData.sublistView(Uint8List.fromList(dataBytes));
      // RR interval resolution is 1/1024 sec
      final rrRaw = bytes.getUint16(index, Endian.little);
      ppi = ((rrRaw / 1024.0) * 1000).round();
    }

    return RawSensorData(
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: DeviceType.verityBand,
      timestamp: DateTime.now(),
      heartRate: hr,
      ppiMs: ppi,
      rawBytes: dataBytes,
    );
  }

  static RawSensorData? parsePmdAccel(
    String deviceId,
    String deviceName,
    List<int> dataBytes,
  ) {
    if (dataBytes.length < 10) return null;
    // Polar PMD frame type 0x02 is ACC sample array
    // Byte 0: Frame Type, Bytes 1-9: Timestamp, Byte 10+: [X, Y, Z] samples
    try {
      final bytes = ByteData.sublistView(Uint8List.fromList(dataBytes));
      final xRaw = bytes.getInt16(10, Endian.little);
      final yRaw = bytes.getInt16(12, Endian.little);
      final zRaw = bytes.getInt16(14, Endian.little);

      // Convert mg to m/s^2
      return RawSensorData(
        deviceId: deviceId,
        deviceName: deviceName,
        deviceType: DeviceType.verityBand,
        timestamp: DateTime.now(),
        accelX: xRaw * 0.00981,
        accelY: yRaw * 0.00981,
        accelZ: zRaw * 0.00981,
        rawBytes: dataBytes,
      );
    } catch (_) {
      return null;
    }
  }
}
