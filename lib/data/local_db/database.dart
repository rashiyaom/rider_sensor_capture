import 'package:drift/drift.dart';

import 'tables/sensor_readings_table.dart';
import 'tables/event_records_table.dart';
import 'tables/camera_detections_table.dart';
import 'tables/trips_table.dart';
import 'tables/location_readings_table.dart';
import 'tables/trip_calibration_table.dart';
import 'connection/connection.dart';

part 'database.g.dart';

@DriftDatabase(tables: [SensorReadings, EventRecords, CameraDetections, Trips, LocationReadings, TripCalibrations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppDatabase());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(cameraDetections);
          }
          if (from < 3) {
            await m.createTable(trips);
            await m.addColumn(sensorReadings, sensorReadings.tripId);
            await m.addColumn(eventRecords, eventRecords.tripId);
          }
          if (from < 4) {
            await m.addColumn(trips, trips.routeCoordinatesJson);
          }
          if (from < 5) {
            await m.createTable(locationReadings);
            await m.addColumn(sensorReadings, sensorReadings.mountLocation);
            await m.addColumn(eventRecords, eventRecords.crossConfirmed);
            await m.addColumn(eventRecords, eventRecords.forkFootLagMs);
            await m.addColumn(eventRecords, eventRecords.hrSpikeConfirmed);
            await m.addColumn(eventRecords, eventRecords.hrDeltaAtEvent);
            await m.addColumn(eventRecords, eventRecords.jerkPeakMagnitude);
            await m.addColumn(eventRecords, eventRecords.gpsSpeedAtEventKmh);
            await m.addColumn(eventRecords, eventRecords.gpsHeadingChangeDeg);
          }
          if (from < 6) {
            await m.createTable(tripCalibrations);
          }
          if (from < 7) {
            await m.addColumn(trips, trips.wristSide);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA journal_mode=WAL;');
          await customStatement('PRAGMA synchronous=NORMAL;');
        },
      );
}
