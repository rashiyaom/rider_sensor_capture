import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_sensor_capture/providers/db_providers.dart';
import 'package:ride_sensor_capture/providers/ride_recording_provider.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';

void main() {
  late AppDatabase db;
  late SensorRepositoryImpl repo;
  RawSensorData sample(int i) => RawSensorData(
    deviceId: 'watch',
    deviceName: 'Watch',
    deviceType: DeviceType.watch,
    timestamp: DateTime.utc(2026, 11, 6).add(Duration(milliseconds: 20 * i)),
    rawBytes: const [],
  );
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SensorRepositoryImpl(db);
  });
  tearDown(() async {
    await repo.flushPendingBuffer();
    repo.dispose();
    await db.close();
  });
  test(
    'buffer retains arrival associations across event and trip boundaries',
    () async {
      repo.setActiveTripId(1);
      repo.setActiveEventId(10);
      await repo.insertReading(sample(1));
      repo.setActiveEventId(11);
      await repo.insertReading(sample(2));
      repo.setActiveTripId(null);
      repo.setActiveEventId(null);
      await repo.insertReading(sample(3));
      repo.setActiveTripId(2);
      repo.setActiveEventId(12);
      await repo.insertReading(sample(4));
      await repo.flushPendingBuffer();
      final rows = await db.select(db.sensorReadings).get();
      expect(rows.map((r) => r.eventId), [10, 11, null, 12]);
      expect(rows.map((r) => r.tripId), [1, 1, null, 2]);
    },
  );
  test(
    'direct batch captures context before asynchronous database work',
    () async {
      repo.setActiveTripId(1);
      repo.setActiveEventId(10);
      final write = repo.insertReadingsBatch([sample(1), sample(2)]);
      repo.setActiveTripId(2);
      repo.setActiveEventId(11);
      await write;
      final rows = await db.select(db.sensorReadings).get();
      expect(rows.map((r) => r.eventId), [10, 10]);
      expect(rows.map((r) => r.tripId), [1, 1]);
    },
  );
  test(
    'failed transaction retains samples and counters for a clean retry',
    () async {
      await db.customStatement(
        "CREATE TRIGGER fail_write BEFORE INSERT ON sensor_readings WHEN NEW.sequence_no = 2 BEGIN SELECT RAISE(ABORT, 'simulated full disk'); END;",
      );
      repo.setActiveTripId(1);
      repo.setActiveEventId(10);
      await repo.insertReading(sample(1));
      await repo.insertReading(sample(2));
      await expectLater(repo.flushPendingBuffer(), throwsA(anything));
      expect(await db.select(db.sensorReadings).get(), isEmpty);
      final failed = await repo.watchStats().first;
      expect(failed.totalRows, 0);
      expect(failed.writeError, isNotNull);
      expect(failed.pendingRows, 2);
      repo.setActiveTripId(2);
      repo.setActiveEventId(11);
      await repo.insertReading(sample(3));
      await db.customStatement('DROP TRIGGER fail_write');
      await repo.flushPendingBuffer();
      final rows = await db.select(db.sensorReadings).get();
      expect(rows.map((r) => r.sequenceNo), [1, 2, 3]);
      expect(rows.map((r) => r.eventId), [10, 10, 11]);
      final recovered = await repo.watchStats().first;
      expect(recovered.totalRows, 3);
      expect(recovered.pendingRows, 0);
      expect(recovered.writeError, isNull);
    },
  );
  test(
    'concurrent direct batches and flush barriers commit each sample once',
    () async {
      final writes = <Future<void>>[];
      for (var i = 0; i < 100; i++) {
        writes.add(repo.insertReadingsBatch([sample(i)]));
        if (i % 7 == 0) writes.add(repo.flushPendingBuffer());
      }
      await Future.wait(writes);
      await repo.flushPendingBuffer();
      final rows = await db.select(db.sensorReadings).get();
      expect(rows, hasLength(100));
      expect(rows.map((r) => r.sequenceNo).toSet(), hasLength(100));
      expect(rows.map((r) => r.timestampUtc).toSet(), hasLength(100));
      expect((await repo.watchStats().first).totalRows, 100);
    },
  );

  test(
    'recording stop reports failure and retries pending writes while paused',
    () async {
      final container = ProviderContainer(
        overrides: [sensorRepositoryProvider.overrideWithValue(repo)],
      );
      try {
        final recorder = container.read(rideRecordingProvider.notifier);
        recorder.startRecording();
        await repo.insertReading(sample(1));
        await db.customStatement(
          "CREATE TRIGGER fail_write BEFORE INSERT ON sensor_readings BEGIN SELECT RAISE(ABORT, 'disk full'); END;",
        );
        await expectLater(recorder.stopRecording(), throwsA(anything));
        expect(container.read(rideRecordingProvider).isRecording, isFalse);
        expect(await db.select(db.sensorReadings).get(), isEmpty);
        await db.customStatement('DROP TRIGGER fail_write');
        await recorder.stopRecording();
        expect(await db.select(db.sensorReadings).get(), hasLength(1));
      } finally {
        container.dispose();
      }
    },
  );
}
