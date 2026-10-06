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
  int get schemaVersion => 9;

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
          if (from < 8) {
            // Add all ML Driver Safety aggregate columns that were missing migrations.
            // SQLite "IF NOT EXISTS" equivalent: use try/catch per column.
            Future<void> addIfMissing(Future<void> Function() fn) async {
              try { await fn(); } catch (_) {}
            }
            await addIfMissing(() => m.addColumn(trips, trips.startTimestampUtc));
            await addIfMissing(() => m.addColumn(trips, trips.endTimestampUtc));
            await addIfMissing(() => m.addColumn(trips, trips.totalDistanceKm));
            await addIfMissing(() => m.addColumn(trips, trips.totalDurationMin));
            await addIfMissing(() => m.addColumn(trips, trips.avgSpeedKmh));
            await addIfMissing(() => m.addColumn(trips, trips.maxSpeedKmh));
            await addIfMissing(() => m.addColumn(trips, trips.harshBrakeCount));
            await addIfMissing(() => m.addColumn(trips, trips.harshAccelCount));
            await addIfMissing(() => m.addColumn(trips, trips.harshTurnCount));
            await addIfMissing(() => m.addColumn(trips, trips.bumpCount));
            await addIfMissing(() => m.addColumn(trips, trips.confirmedEventCount));
            await addIfMissing(() => m.addColumn(trips, trips.eventsPerKm));
            await addIfMissing(() => m.addColumn(trips, trips.avgHr));
            await addIfMissing(() => m.addColumn(trips, trips.maxHr));
            await addIfMissing(() => m.addColumn(trips, trips.hrSpikeConfirmedRatio));
            await addIfMissing(() => m.addColumn(trips, trips.nightDrivingPct));
            await addIfMissing(() => m.addColumn(trips, trips.driverScore));
            await addIfMissing(() => m.addColumn(trips, trips.peakSpeedKmh));
            await addIfMissing(() => m.addColumn(trips, trips.totalEventsCount));
            await addIfMissing(() => m.addColumn(trips, trips.distanceMeters));
            await addIfMissing(() => m.addColumn(trips, trips.notes));
            await addIfMissing(() => m.addColumn(trips, trips.startLat));
            await addIfMissing(() => m.addColumn(trips, trips.startLng));
            await addIfMissing(() => m.addColumn(trips, trips.endLat));
            await addIfMissing(() => m.addColumn(trips, trips.endLng));
          }
          if (from < 9) {
            // Add gps_speed_kmh to sensor_readings for live speedometer CSV column.
            Future<void> addIfMissing9(Future<void> Function() fn) async {
              try { await fn(); } catch (_) {}
            }
            await addIfMissing9(() => m.addColumn(sensorReadings, sensorReadings.gpsSpeedKmh));
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA journal_mode=WAL;');
          await customStatement('PRAGMA synchronous=NORMAL;');
        },
      );
}
