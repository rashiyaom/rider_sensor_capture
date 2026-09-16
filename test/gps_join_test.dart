import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/features/export/models/export_options.dart';

void main() {
  late AppDatabase db;
  late ExportRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ExportRepositoryImpl(db);
  });

  tearDown(() => db.close());

  group('GPS Join Strategy Tests (Nearest-Timestamp <= 1.5s)', () {
    test('joins nearest GPS fix when within 1.5s tolerance and leaves empty when out of tolerance', () async {
      final t0 = DateTime.utc(2026, 9, 12, 10, 0, 0);

      // Insert GPS fix at t0 + 1000ms (10:00:01)
      await db.into(db.locationReadings).insert(
            LocationReadingsCompanion.insert(
              tripId: 1,
              timestampUtc: t0.add(const Duration(milliseconds: 1000)),
              latitude: 37.7749,
              longitude: -122.4194,
              gpsSpeedMps: const drift.Value(10.0), // 36 km/h
              gpsHeadingDeg: const drift.Value(180.0),
              gpsAccuracyM: const drift.Value(4.5),
            ),
          );

      // Reading 1: at t0 + 1200ms (diff = 200ms <= 1500ms) -> MUST join GPS
      await db.into(db.sensorReadings).insert(
            SensorReadingsCompanion.insert(
              deviceId: 'fork_01',
              deviceType: 'watch',
              mountLocation: const drift.Value('fork'),
              sequenceNo: 1,
              timestampUtc: t0.add(const Duration(milliseconds: 1200)),
              sensorType: 'imu',
              accelX: const drift.Value(0.1),
              accelY: const drift.Value(0.2),
              accelZ: const drift.Value(9.8),
            ),
          );

      // Reading 2: at t0 + 5000ms (diff = 4000ms > 1500ms) -> MUST NOT join GPS (null fields)
      await db.into(db.sensorReadings).insert(
            SensorReadingsCompanion.insert(
              deviceId: 'fork_01',
              deviceType: 'watch',
              mountLocation: const drift.Value('fork'),
              sequenceNo: 2,
              timestampUtc: t0.add(const Duration(milliseconds: 5000)),
              sensorType: 'imu',
              accelX: const drift.Value(0.1),
              accelY: const drift.Value(0.2),
              accelZ: const drift.Value(9.8),
            ),
          );

      final csv = await repo.buildSensorTimeseriesCsvExport(mode: ExportMode.fullRawSession);
      final lines = csv.trim().split('\n');

      expect(lines.length, equals(3)); // Header + 2 rows

      // Row 1 (index 1) should have coordinates 37.774900
      expect(lines[1], contains('37.774900'));
      expect(lines[1], contains('-122.419400'));
      expect(lines[1], contains('36.0')); // 10.0 m/s * 3.6

      // Row 2 (index 2) is beyond 1.5s tolerance, should have empty GPS fields
      final row2Cols = lines[2].split(',');
      expect(row2Cols[22], isEmpty);
      expect(lines[2], isNot(contains('37.774900')));
    });
  });
}
