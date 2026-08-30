import 'package:drift/drift.dart';

import 'tables/sensor_readings_table.dart';
import 'tables/event_records_table.dart';
import 'tables/camera_detections_table.dart';
import 'connection/connection.dart';

part 'database.g.dart';

@DriftDatabase(tables: [SensorReadings, EventRecords, CameraDetections])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppDatabase());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(cameraDetections);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA journal_mode=WAL;');
          await customStatement('PRAGMA synchronous=NORMAL;');
        },
      );
}
