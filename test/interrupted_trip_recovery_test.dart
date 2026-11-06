import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/features/trips/interrupted_trip_recovery.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'closes open rides at the last durable sample and preserves a warning',
    () async {
      final start = DateTime.utc(2026, 11, 6, 10);
      final lastSample = start.add(const Duration(seconds: 12));
      final tripId = await db
          .into(db.trips)
          .insert(TripsCompanion.insert(startTimeUtc: start));
      final endedTripId = await db
          .into(db.trips)
          .insert(
            TripsCompanion.insert(
              startTimeUtc: start.subtract(const Duration(hours: 1)),
              endTimeUtc: drift.Value(start),
            ),
          );
      await db
          .into(db.sensorReadings)
          .insert(
            SensorReadingsCompanion.insert(
              deviceId: 'watch',
              deviceType: 'watch',
              sequenceNo: 1,
              timestampUtc: lastSample,
              sensorType: 'imu',
              tripId: drift.Value(tripId),
            ),
          );

      final recovered = await InterruptedTripRecovery.recover(
        db,
        now: start.add(const Duration(hours: 1)),
      );

      expect(recovered, hasLength(1));
      expect(recovered.single.id, tripId);
      expect(recovered.single.endTimeUtc, lastSample);
      expect(recovered.single.durationSeconds, 12);
      expect(recovered.single.totalSensorRows, 1);
      expect(recovered.single.notes, contains('unexpected app stop'));
      expect(recovered.single.notes, contains('later activity may be missing'));
      expect(
        (await db.select(db.trips).get())
            .singleWhere((t) => t.id == endedTripId)
            .endTimeUtc,
        start,
      );
      expect(await InterruptedTripRecovery.recover(db), isEmpty);
    },
  );

  test('a trip without saved samples closes at its start time', () async {
    final start = DateTime.utc(2026, 11, 6, 10);
    await db.into(db.trips).insert(TripsCompanion.insert(startTimeUtc: start));

    final recovered = await InterruptedTripRecovery.recover(
      db,
      now: start.add(const Duration(minutes: 5)),
    );

    expect(recovered.single.endTimeUtc, start);
    expect(recovered.single.durationSeconds, 0);
    expect(recovered.single.totalSensorRows, 0);
  });
}
