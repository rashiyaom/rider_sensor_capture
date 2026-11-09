import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_engine.dart';
import 'package:ride_sensor_capture/prealert/road_event_registry.dart';

void main() {
  late AppDatabase database;
  late RoadEventRegistry registry;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    registry = RoadEventRegistry(database);
  });

  tearDown(() async => database.close());

  test(
    'rejects invalid coordinates and non-finite confidence before saving',
    () async {
      for (final point in <(double, double)>[
        (double.nan, 72),
        (91, 72),
        (23, double.infinity),
        (23, -181),
      ]) {
        await expectLater(
          registry.register(
            kind: RoadEventKind.pothole,
            latitude: point.$1,
            longitude: point.$2,
          ),
          throwsArgumentError,
        );
      }
      await expectLater(
        registry.register(
          kind: RoadEventKind.bump,
          latitude: 23,
          longitude: 72,
          confidence: double.nan,
        ),
        throwsArgumentError,
      );
      expect(await registry.countAll(), 0);
    },
  );

  test(
    'batch import rolls back on invalid row and deduplicates retries',
    () async {
      const valid = HazardImportRow(
        kind: RoadEventKind.pothole,
        latitude: 23.02,
        longitude: 72.57,
        severity: 0.8,
      );
      const invalid = HazardImportRow(
        kind: RoadEventKind.bump,
        latitude: 23.03,
        longitude: 72.58,
        severity: double.nan,
      );
      await expectLater(
        registry.importBatch([valid, invalid]),
        throwsArgumentError,
      );
      expect(await registry.countAll(), 0);

      expect(await registry.importBatch([valid, valid]), 1);
      expect(await registry.importBatch([valid]), 0);
      expect(await registry.countAll(), 1);
    },
  );
}
