import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';

void main() {
  late AppDatabase db;
  late SensorRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SensorRepositoryImpl(db);
  });

  tearDown(() async {
    repo.dispose();
    await db.close();
  });

  group('SensorRepository In-Memory Batch Persistence Tests', () {
    test('Buffers individual readings and flushes when reaching 25-item threshold', () async {
      const deviceId = 'ESP32_WATCH_01';
      final baseTime = DateTime.now();

      // Insert 24 items -> should still be buffered in memory, not yet flushed to DB
      for (int i = 0; i < 24; i++) {
        await repo.insertReading(
          RawSensorData(
            deviceId: deviceId,
            deviceName: 'ESP32-Watch',
            deviceType: DeviceType.watch,
            timestamp: baseTime.add(Duration(milliseconds: i * 20)),
            heartRate: 70 + (i % 5),
            accelX: 0.1 * i,
            accelY: -0.1 * i,
            accelZ: 9.8,
            rawBytes: Uint8List(13),
          ),
        );
      }

      // 25th item triggers immediate batch insert
      await repo.insertReading(
        RawSensorData(
          deviceId: deviceId,
          deviceName: 'ESP32-Watch',
          deviceType: DeviceType.watch,
          timestamp: baseTime.add(const Duration(milliseconds: 24 * 20)),
          heartRate: 75,
          accelX: 2.4,
          accelY: -2.4,
          accelZ: 9.8,
          rawBytes: Uint8List(13),
        ),
      );

      final total = await repo.getTotalCount();
      expect(total, 25);

      final rows = await repo.watchReadingsForDevice(deviceId, limit: 100).first;
      expect(rows.length, 25);
      // Monotonic sequence numbering from 1 to 25
      expect(rows.first.sequenceNo, 25); // ordered desc
      expect(rows.last.sequenceNo, 1);
    });

    test('Periodic timer flushes sub-threshold buffer within 250ms', () async {
      const deviceId = 'ESP32_WATCH_02';
      final now = DateTime.now();

      // Insert 5 items (below 25 threshold)
      for (int i = 0; i < 5; i++) {
        await repo.insertReading(
          RawSensorData(
            deviceId: deviceId,
            deviceName: 'ESP32-Watch',
            deviceType: DeviceType.watch,
            timestamp: now.add(Duration(milliseconds: i * 20)),
            heartRate: 72,
            accelX: 0.05,
            accelY: -0.05,
            accelZ: 9.81,
            rawBytes: Uint8List(13),
          ),
        );
      }

      // Wait 300ms for the periodic 250ms flush timer to fire
      await Future.delayed(const Duration(milliseconds: 300));

      final total = await repo.getTotalCount();
      expect(total, 5);

      final rows = await repo.watchReadingsForDevice(deviceId).first;
      expect(rows.length, 5);
      expect(rows.first.sequenceNo, 5);
      expect(rows.last.sequenceNo, 1);
    });

    test('Associates active event ID with batched sensor readings', () async {
      const deviceId = 'ESP32_WATCH_03';
      final now = DateTime.now();

      // Set active event ID
      repo.setActiveEventId(42);
      expect(repo.activeEventId, 42);

      await repo.insertReadingsBatch([
        RawSensorData(
          deviceId: deviceId,
          deviceName: 'ESP32-Watch',
          deviceType: DeviceType.watch,
          timestamp: now,
          heartRate: 80,
          accelX: 0.2,
          accelY: 0.3,
          accelZ: 9.8,
          rawBytes: Uint8List(13),
        ),
      ]);

      final eventRows = await repo.watchReadingsForEvent(42).first;
      expect(eventRows.length, 1);
      expect(eventRows.first.eventId, 42);
      expect(eventRows.first.heartRate, 80);

      // Clear active event ID
      repo.setActiveEventId(null);
      await repo.insertReadingsBatch([
        RawSensorData(
          deviceId: deviceId,
          deviceName: 'ESP32-Watch',
          deviceType: DeviceType.watch,
          timestamp: now.add(const Duration(milliseconds: 20)),
          heartRate: 81,
          accelX: 0.3,
          accelY: 0.4,
          accelZ: 9.8,
          rawBytes: Uint8List(13),
        ),
      ]);

      final allRows = await repo.watchRecentReadings(limit: 10).first;
      expect(allRows.first.eventId, isNull);
      expect(allRows.last.eventId, 42);
    });
  });
}
