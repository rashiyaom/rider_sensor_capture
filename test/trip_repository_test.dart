import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';

void main() {
  late AppDatabase db;
  late SensorRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SensorRepositoryImpl(db);
  });

  tearDown(() async {
    repository.dispose();
    await db.close();
  });

  group('Trip / Journey Persistence & Lifecycle Tests', () {
    test('Creates a trip and tags incoming sensor readings with active trip ID', () async {
      final now = DateTime.now();

      final tripId = await repository.createTrip(
        TripsCompanion.insert(
          riderName: const drift.Value('Ramesh'),
          startTimeUtc: now.toUtc(),
          startLat: const drift.Value(19.0760),
          startLng: const drift.Value(72.8777),
        ),
      );

      expect(tripId, isPositive);
      repository.setActiveTripId(tripId);
      expect(repository.activeTripId, tripId);

      // Insert sensor readings while trip is active
      await repository.insertReadingsBatch([
        RawSensorData(
          deviceId: 'watch_01',
          deviceName: 'ESP32-Watch',
          deviceType: DeviceType.watch,
          timestamp: now,
          accelX: 0.1,
          accelY: 0.2,
          accelZ: 9.8,
          gyroX: 1.0,
          gyroY: 2.0,
          gyroZ: 3.0,
          rawBytes: const [],
        ),
        RawSensorData(
          deviceId: 'watch_01',
          deviceName: 'ESP32-Watch',
          deviceType: DeviceType.watch,
          timestamp: now.add(const Duration(milliseconds: 20)),
          accelX: 0.2,
          accelY: 0.3,
          accelZ: 9.9,
          gyroX: 1.1,
          gyroY: 2.1,
          gyroZ: 3.1,
          rawBytes: const [],
        ),
      ]);

      final count = await repository.getReadingCountForTrip(tripId);
      expect(count, 2);

      final storedTrip = await repository.getTrip(tripId);
      expect(storedTrip, isNotNull);
      expect(storedTrip!.riderName, 'Ramesh');
      expect(storedTrip.startLat, closeTo(19.0760, 0.0001));
      expect(storedTrip.startLng, closeTo(72.8777, 0.0001));
    });

    test('Completes and updates trip with ending coordinates, distance, and speeds', () async {
      final start = DateTime.now();
      final tripId = await repository.createTrip(
        TripsCompanion.insert(
          riderName: const drift.Value('Priya'),
          startTimeUtc: start.toUtc(),
          startLat: const drift.Value(28.6139),
          startLng: const drift.Value(77.2090),
        ),
      );

      final trip = await repository.getTrip(tripId);
      expect(trip, isNotNull);

      final end = start.add(const Duration(minutes: 15));
      final updated = trip!.copyWith(
        endTimeUtc: drift.Value(end.toUtc()),
        durationSeconds: 900,
        endLat: const drift.Value(28.7041),
        endLng: const drift.Value(77.1025),
        distanceMeters: 12500.0,
        avgSpeedKmh: const drift.Value(50.0),
        peakSpeedKmh: const drift.Value(68.5),
        totalSensorRows: 45000,
        totalEventsCount: 5,
      );

      await repository.updateTrip(updated);

      final fetched = await repository.getTrip(tripId);
      expect(fetched, isNotNull);
      expect(fetched!.durationSeconds, 900);
      expect(fetched.distanceMeters, 12500.0);
      expect(fetched.avgSpeedKmh, 50.0);
      expect(fetched.peakSpeedKmh, 68.5);
      expect(fetched.totalSensorRows, 45000);
      expect(fetched.totalEventsCount, 5);
      expect(fetched.endLat, closeTo(28.7041, 0.0001));
    });

    test('Deleting a trip removes associated sensor readings and event records', () async {
      final tripId = await repository.createTrip(
        TripsCompanion.insert(
          riderName: const drift.Value('Test'),
          startTimeUtc: DateTime.now().toUtc(),
        ),
      );

      repository.setActiveTripId(tripId);
      await repository.insertReading(
        RawSensorData(
          deviceId: 'dev_1',
          deviceName: 'ESP32-Watch',
          deviceType: DeviceType.watch,
          timestamp: DateTime.now(),
          accelX: 0,
          accelY: 0,
          accelZ: 9.8,
          rawBytes: const [],
        ),
      );
      await repository.flushPendingBuffer();

      expect(await repository.getReadingCountForTrip(tripId), 1);

      await repository.deleteTrip(tripId);

      expect(await repository.getTrip(tripId), isNull);
      expect(await repository.getReadingCountForTrip(tripId), 0);
    });
  });
}
