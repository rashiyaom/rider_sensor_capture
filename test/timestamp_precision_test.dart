import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/features/export/models/export_options.dart';

class LegacyDatabase extends AppDatabase {
  LegacyDatabase(super.executor) : super.forTesting();
  @override
  int get schemaVersion => 15;
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions();
  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
}

void main() {
  final base = DateTime.utc(2026, 11, 6, 12);
  Future<void> sample(AppDatabase db, DateTime at, int seq) async {
    await db
        .into(db.sensorReadings)
        .insert(
          SensorReadingsCompanion.insert(
            deviceId: 'watch',
            deviceType: 'watch',
            sequenceNo: seq,
            timestampUtc: at,
            sensorType: 'imu',
          ),
        );
  }

  test(
    'disk round trip preserves microseconds and export range boundaries',
    () async {
      final dir = await Directory.systemTemp.createTemp('timestamp_precision_');
      final file = File('${dir.path}/data.sqlite');
      var db = AppDatabase.forTesting(NativeDatabase(file));
      final offsets = [0, 20000, 41327, 987654];
      try {
        for (var i = 0; i < offsets.length; i++) {
          await sample(db, base.add(Duration(microseconds: offsets[i])), i);
        }
        await db.close();
        db = AppDatabase.forTesting(NativeDatabase(file));
        final rows = await (db.select(
          db.sensorReadings,
        )..orderBy([(t) => OrderingTerm.asc(t.timestampUtc)])).get();
        expect(
          rows.map((r) => r.timestampUtc.difference(base).inMicroseconds),
          offsets,
        );
        final csv = await ExportRepositoryImpl(db)
            .buildSensorTimeseriesCsvExport(
              mode: ExportMode.fullRawSession,
              startUtc: base.add(const Duration(milliseconds: 19)),
              endUtc: base.add(const Duration(milliseconds: 21)),
            );
        expect(csv.trim().split('\n'), hasLength(2));
        expect(csv, contains('.020'));
      } finally {
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );
  test(
    'v15 integer timestamps migrate with associations and nulls intact',
    () async {
      final dir = await Directory.systemTemp.createTemp('timestamp_migration_');
      final file = File('${dir.path}/data.sqlite');
      AppDatabase db = LegacyDatabase(NativeDatabase(file));
      try {
        final trip = await db
            .into(db.trips)
            .insert(TripsCompanion.insert(startTimeUtc: base));
        final event = await db
            .into(db.eventRecords)
            .insert(
              EventRecordsCompanion.insert(
                eventType: 'bump',
                status: 'completed',
                startTimestamp: base,
                tripId: Value(trip),
              ),
            );
        await db
            .into(db.sensorReadings)
            .insert(
              SensorReadingsCompanion.insert(
                deviceId: 'old',
                deviceType: 'watch',
                sequenceNo: 1,
                timestampUtc: base,
                sensorType: 'imu',
                tripId: Value(trip),
                eventId: Value(event),
              ),
            );
        expect(
          (await db
                  .customSelect(
                    'SELECT typeof(timestamp_utc) AS kind FROM sensor_readings',
                  )
                  .getSingle())
              .read<String>('kind'),
          'integer',
        );
        // LegacyDatabase creates tables through the current generated schema;
        // remove v17-only fields so this file matches an actual v15 database.
        await db.customStatement(
          'ALTER TABLE pre_alerts DROP COLUMN delivery_status',
        );
        await db.customStatement(
          'ALTER TABLE pre_alerts DROP COLUMN delivered_at_utc',
        );
        await db.customStatement(
          'ALTER TABLE pre_alerts DROP COLUMN delivery_failure',
        );
        await db.customStatement(
          'ALTER TABLE live_event_reviews DROP COLUMN gps_accuracy_m',
        );
        await db.close();
        db = AppDatabase.forTesting(NativeDatabase(file));
        final old = await db.select(db.sensorReadings).getSingle();
        expect(old.timestampUtc, base);
        expect(old.eventId, event);
        expect(old.tripId, trip);
        expect(
          (await db.select(db.eventRecords).getSingle()).endTimestamp,
          isNull,
        );
        expect((await db.select(db.trips).getSingle()).startTimeUtc, base);
        expect(
          (await db.customSelect('PRAGMA table_info(sensor_readings)').get())
              .firstWhere((r) => r.read<String>('name') == 'timestamp_utc')
              .read<String>('type'),
          'TEXT',
        );
        await sample(db, base.add(const Duration(milliseconds: 20)), 2);
        await db.close();
        db = AppDatabase.forTesting(NativeDatabase(file));
        expect(
          (await db.select(db.sensorReadings).get()).last.timestampUtc
              .difference(base)
              .inMilliseconds,
          20,
        );
      } finally {
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );
}
