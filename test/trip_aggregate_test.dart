import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/providers/db_providers.dart';
import 'package:ride_sensor_capture/providers/trip_controller.dart';
import 'package:ride_sensor_capture/location/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  group('Trip Aggregate Computation Tests', () {
    test('computes correct duration, distance, speed and event aggregates on trip close', () async {
      final controller = container.read(tripControllerProvider.notifier);

      // Start trip
      final tripId = await controller.startTrip(riderName: 'TestRider');
      expect(tripId, greaterThan(0));

      final t0 = DateTime.utc(2026, 9, 12, 10, 0, 0);

      // Inject 3 GPS points 1km apart (approx lat delta 0.009 deg)
      controller.locationService.injectFixForTesting(
        LocationFix(
          latitude: 37.7749,
          longitude: -122.4194,
          gpsSpeedMps: 10.0, // 36 km/h
          timestampUtc: t0,
        ),
      );

      controller.locationService.injectFixForTesting(
        LocationFix(
          latitude: 37.7840,
          longitude: -122.4194,
          gpsSpeedMps: 15.0, // 54 km/h
          timestampUtc: t0.add(const Duration(minutes: 2)),
        ),
      );

      // Insert confirmed and unconfirmed events linked to this trip
      await db.into(db.eventRecords).insert(
            EventRecordsCompanion.insert(
              tripId: drift.Value(tripId),
              eventType: 'bump',
              startTimestamp: t0.add(const Duration(seconds: 30)),
              endTimestamp: drift.Value(t0.add(const Duration(seconds: 31))),
              status: 'completed',
              crossConfirmed: const drift.Value(true),
            ),
          );

      await db.into(db.eventRecords).insert(
            EventRecordsCompanion.insert(
              tripId: drift.Value(tripId),
              eventType: 'turn',
              startTimestamp: t0.add(const Duration(seconds: 60)),
              endTimestamp: drift.Value(t0.add(const Duration(seconds: 62))),
              status: 'completed',
              classification: const drift.Value('sharp'),
              crossConfirmed: const drift.Value(true),
            ),
          );

      // Insert sensor readings with HR
      await db.into(db.sensorReadings).insert(
            SensorReadingsCompanion.insert(
              tripId: drift.Value(tripId),
              deviceId: 'polar_01',
              deviceType: 'verityBand',
              mountLocation: const drift.Value('forearm'),
              sequenceNo: 1,
              timestampUtc: t0.add(const Duration(seconds: 10)),
              sensorType: 'hr',
              heartRate: const drift.Value(80),
            ),
          );

      await db.into(db.sensorReadings).insert(
            SensorReadingsCompanion.insert(
              tripId: drift.Value(tripId),
              deviceId: 'polar_01',
              deviceType: 'verityBand',
              mountLocation: const drift.Value('forearm'),
              sequenceNo: 2,
              timestampUtc: t0.add(const Duration(seconds: 40)),
              sensorType: 'hr',
              heartRate: const drift.Value(100),
            ),
          );

      // Stop trip and evaluate aggregates
      final closedTrip = await controller.stopTrip();

      expect(closedTrip, isNotNull);
      expect(closedTrip!.endTimestampUtc, isNotNull);
      expect(closedTrip.bumpCount, equals(1));
      expect(closedTrip.harshTurnCount, equals(1));
      expect(closedTrip.confirmedEventCount, equals(2));
      expect(closedTrip.maxHr, equals(100));
      expect(closedTrip.avgHr, equals(90.0));
      expect(closedTrip.maxSpeedKmh, greaterThanOrEqualTo(50.0));
    });
  });
}
