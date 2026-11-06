import 'package:drift/drift.dart';

import '../../data/local_db/database.dart';

/// Closes database trips left open after a process was stopped unexpectedly.
/// The end time is the newest durable sensor/GPS sample, so time after the
/// last saved reading is never represented as recorded ride time.
class InterruptedTripRecovery {
  static Future<List<Trip>> recover(AppDatabase db, {DateTime? now}) async {
    final recovered = <Trip>[];
    await db.transaction(() async {
      final openTrips =
          await (db.select(db.trips)
                ..where((trip) => trip.endTimeUtc.isNull())
                ..orderBy([(trip) => OrderingTerm.asc(trip.startTimeUtc)]))
              .get();
      final recoveryTime = (now ?? DateTime.now()).toUtc();

      for (final trip in openTrips) {
        final latestSensor =
            await (db.select(db.sensorReadings)
                  ..where((row) => row.tripId.equals(trip.id))
                  ..orderBy([(row) => OrderingTerm.desc(row.timestampUtc)])
                  ..limit(1))
                .getSingleOrNull();
        final latestLocation =
            await (db.select(db.locationReadings)
                  ..where((row) => row.tripId.equals(trip.id))
                  ..orderBy([(row) => OrderingTerm.desc(row.timestampUtc)])
                  ..limit(1))
                .getSingleOrNull();

        var endedAt = trip.startTimeUtc.toUtc();
        for (final timestamp in [
          latestSensor?.timestampUtc,
          latestLocation?.timestampUtc,
        ]) {
          if (timestamp != null && timestamp.isAfter(endedAt)) {
            endedAt = timestamp.toUtc();
          }
        }
        if (endedAt.isAfter(recoveryTime)) endedAt = recoveryTime;
        final durationSeconds = endedAt
            .difference(trip.startTimeUtc.toUtc())
            .inSeconds
            .clamp(0, 1 << 31);
        final sensorCount =
            await (db.selectOnly(db.sensorReadings)
                  ..addColumns([db.sensorReadings.id.count()])
                  ..where(db.sensorReadings.tripId.equals(trip.id)))
                .map((row) => row.read(db.sensorReadings.id.count()) ?? 0)
                .getSingle();
        final eventCount =
            await (db.selectOnly(db.eventRecords)
                  ..addColumns([db.eventRecords.id.count()])
                  ..where(db.eventRecords.tripId.equals(trip.id)))
                .map((row) => row.read(db.eventRecords.id.count()) ?? 0)
                .getSingle();
        final message =
            'Recovered after an unexpected app stop. Saved ride data ends at ${endedAt.toIso8601String()}; later activity may be missing.';
        final notes = trip.notes == null || trip.notes!.isEmpty
            ? message
            : '${trip.notes}\n$message';

        final updated = trip.copyWith(
          endTimeUtc: Value(endedAt),
          endTimestampUtc: Value(endedAt),
          durationSeconds: durationSeconds,
          totalDurationMin: Value(durationSeconds / 60),
          totalSensorRows: sensorCount,
          totalEventsCount: eventCount,
          notes: Value(notes),
        );
        await (db.update(db.trips)..where((row) => row.id.equals(trip.id)))
            .write(updated.toCompanion(true));
        recovered.add(updated);
      }
    });
    return recovered;
  }
}
