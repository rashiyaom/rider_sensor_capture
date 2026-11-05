import 'package:drift/drift.dart';

import 'tables/sensor_readings_table.dart';
import 'tables/event_records_table.dart';
import 'tables/camera_detections_table.dart';
import 'tables/trips_table.dart';
import 'tables/location_readings_table.dart';
import 'tables/trip_calibration_table.dart';
import 'tables/road_events_table.dart';
import 'tables/pre_alerts_table.dart';
import 'tables/event_feedback_table.dart';
import 'tables/unknown_events_table.dart';
import 'tables/camera_captures_table.dart';
import 'connection/connection.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    SensorReadings,
    EventRecords,
    CameraDetections,
    Trips,
    LocationReadings,
    TripCalibrations,
    RoadEvents,
    PreAlerts,
    EventFeedbacks,
    UnknownEvents,
    CameraCaptures,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppDatabase());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 14;

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
          try {
            await fn();
          } catch (_) {}
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
        await addIfMissing(
          () => m.addColumn(trips, trips.hrSpikeConfirmedRatio),
        );
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
          try {
            await fn();
          } catch (_) {}
        }

        await addIfMissing9(
          () => m.addColumn(sensorReadings, sensorReadings.gpsSpeedKmh),
        );
      }
      if (from < 10) {
        // Predictive pre-alert + post-event feedback learning loop.
        await m.createTable(roadEvents);
        await m.createTable(preAlerts);
        await m.createTable(eventFeedbacks);
      }
      if (from < 11) {
        // Hands-free rider: unknown IMU event capture with voice labelling.
        await m.createTable(unknownEvents);
      }
      if (from < 12) {
        // Advanced Academic Field Experiment Extensions (SAE / IEEE Benchmark):
        // Linear acceleration (gravity-free), attitude quaternions, monotonic hardware clock, and barometer altitude.
        Future<void> addIfMissing12(Future<void> Function() fn) async {
          try {
            await fn();
          } catch (_) {}
        }

        await addIfMissing12(
          () => m.addColumn(sensorReadings, sensorReadings.linearAccelX),
        );
        await addIfMissing12(
          () => m.addColumn(sensorReadings, sensorReadings.linearAccelY),
        );
        await addIfMissing12(
          () => m.addColumn(sensorReadings, sensorReadings.linearAccelZ),
        );
        await addIfMissing12(
          () => m.addColumn(sensorReadings, sensorReadings.quatW),
        );
        await addIfMissing12(
          () => m.addColumn(sensorReadings, sensorReadings.quatX),
        );
        await addIfMissing12(
          () => m.addColumn(sensorReadings, sensorReadings.quatY),
        );
        await addIfMissing12(
          () => m.addColumn(sensorReadings, sensorReadings.quatZ),
        );
        await addIfMissing12(
          () => m.addColumn(
            sensorReadings,
            sensorReadings.timestampMonotonicMicros,
          ),
        );
        await addIfMissing12(
          () => m.addColumn(sensorReadings, sensorReadings.barometerAltitudeM),
        );
      }
      if (from < 13) {
        // Ordered UVC image manifest. JPEG bytes stay in app-owned files;
        // this table carries the trip/event joins used for ML export.
        await m.createTable(cameraCaptures);
      }
      if (from < 14) {
        // Hands-free post-event 5-second audio clip path (.mp4/.m4a)
        Future<void> addIfMissing14(Future<void> Function() fn) async {
          try {
            await fn();
          } catch (_) {}
        }

        await addIfMissing14(
          () => m.addColumn(eventRecords, eventRecords.audioFilePath),
        );
        await addIfMissing14(
          () => m.addColumn(eventFeedbacks, eventFeedbacks.audioFilePath),
        );
        await addIfMissing14(
          () => m.addColumn(unknownEvents, unknownEvents.audioFilePath),
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode=WAL;');
      await customStatement('PRAGMA synchronous=NORMAL;');
      // Performance indexes for sensor readings and trips
      try {
        await customStatement('CREATE INDEX IF NOT EXISTS idx_sensor_readings_trip ON sensor_readings(trip_id);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_sensor_readings_event ON sensor_readings(event_id);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_event_records_trip ON event_records(trip_id);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_trips_id_desc ON trips(id DESC);');
      } catch (_) {}
      // Null-safety sanitization for trips with missing defaults
      try {
        await customStatement('UPDATE trips SET rider_name = "Rider" WHERE rider_name IS NULL;');
        await customStatement('UPDATE trips SET wrist_side = "Left" WHERE wrist_side IS NULL;');
        await customStatement('UPDATE trips SET harsh_brake_count = 0 WHERE harsh_brake_count IS NULL;');
        await customStatement('UPDATE trips SET harsh_accel_count = 0 WHERE harsh_accel_count IS NULL;');
        await customStatement('UPDATE trips SET harsh_turn_count = 0 WHERE harsh_turn_count IS NULL;');
        await customStatement('UPDATE trips SET bump_count = 0 WHERE bump_count IS NULL;');
        await customStatement('UPDATE trips SET confirmed_event_count = 0 WHERE confirmed_event_count IS NULL;');
        await customStatement('UPDATE trips SET duration_seconds = 0 WHERE duration_seconds IS NULL;');
        await customStatement('UPDATE trips SET distance_meters = 0.0 WHERE distance_meters IS NULL;');
        await customStatement('UPDATE trips SET total_sensor_rows = 0 WHERE total_sensor_rows IS NULL;');
        await customStatement('UPDATE trips SET total_events_count = 0 WHERE total_events_count IS NULL;');
      } catch (_) {}
    },
  );
}
