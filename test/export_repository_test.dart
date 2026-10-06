import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/data/models/event_parameters.dart';
import 'package:ride_sensor_capture/features/export/models/export_options.dart';

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late ExportRepositoryImpl repo;

  setUp(() async {
    db = _makeTestDb();
    repo = ExportRepositoryImpl(db);

    final now = DateTime.now().toUtc();

    // 1. Insert EventRecord
    const bumpParams = BumpParameters(
      peakAccelMagnitude: 24.5,
      peakGForce: 2.5,
      accelDelta: 14.7,
      peakToPeakChange: 14.7,
      durationMs: 1200,
      severity: 'severe',
    );
    final eventParams = EventParameters(bump: bumpParams);

    final eventId = await db.into(db.eventRecords).insert(
          EventRecordsCompanion.insert(
            eventType: 'bump',
            startTimestamp: now.subtract(const Duration(seconds: 5)),
            endTimestamp: Value(now.subtract(const Duration(seconds: 3))),
            startGpsLat: const Value(37.7749),
            startGpsLng: const Value(-122.4194),
            endGpsLat: const Value(37.7750),
            endGpsLng: const Value(-122.4195),
            status: 'completed',
            triggerPhrase: const Value('start bump'),
            computedParameters: Value(eventParams.toJsonString()),
            peakMetric: const Value(2.5),
            classification: const Value('severe'),
          ),
        );

    // 2. Insert SensorReadings for this event (out of order sequence to test sorting)
    await db.into(db.sensorReadings).insert(
          SensorReadingsCompanion.insert(
            deviceId: 'dev-watch-1',
            deviceType: 'watch',
            sequenceNo: 2,
            timestampUtc: now.subtract(const Duration(seconds: 4)),
            sensorType: 'imu',
            eventId: Value(eventId),
            accelX: const Value(1.0),
            accelY: const Value(2.0),
            accelZ: const Value(24.0),
          ),
        );

    await db.into(db.sensorReadings).insert(
          SensorReadingsCompanion.insert(
            deviceId: 'dev-watch-1',
            deviceType: 'watch',
            sequenceNo: 1,
            timestampUtc: now.subtract(const Duration(seconds: 5)),
            sensorType: 'imu',
            eventId: Value(eventId),
            accelX: const Value(0.2),
            accelY: const Value(0.5),
            accelZ: const Value(9.8),
          ),
        );

    // 3. Insert Unlinked Background Sensor Reading (for raw session testing)
    await db.into(db.sensorReadings).insert(
          SensorReadingsCompanion.insert(
            deviceId: 'dev-watch-1',
            deviceType: 'watch',
            sequenceNo: 3,
            timestampUtc: now.subtract(const Duration(seconds: 1)),
            sensorType: 'imu',
            eventId: const Value(null),
            accelX: const Value(0.1),
            accelY: const Value(0.1),
            accelZ: const Value(9.8),
          ),
        );

    // 4. Insert CameraDetection linked to the event
    await db.into(db.cameraDetections).insert(
          CameraDetectionsCompanion.insert(
            deviceId: 'esp32-cam-01',
            eventClass: 'pothole',
            confidence: 0.88,
            cameraTimestampUtc: now.subtract(const Duration(seconds: 4)),
            receivedAtUtc: now.subtract(const Duration(seconds: 4)),
            linkedEventId: Value(eventId),
          ),
        );
  });

  tearDown(() => db.close());

  test('getExportSummary calculates correct counts for events-only vs raw mode', () async {
    final summaryEventsOnly = await repo.getExportSummary(
      mode: ExportMode.eventsOnly,
    );
    expect(summaryEventsOnly.eventCount, 1);
    expect(summaryEventsOnly.sensorReadingCount, 2);
    expect(summaryEventsOnly.cameraDetectionCount, 1);

    final summaryRaw = await repo.getExportSummary(
      mode: ExportMode.fullRawSession,
    );
    expect(summaryRaw.eventCount, 1);
    expect(summaryRaw.sensorReadingCount, 3);
    expect(summaryRaw.cameraDetectionCount, 1);
  });

  test('buildJsonExport produces correctly structured and sorted hierarchy', () async {
    final jsonExport = await repo.buildJsonExport(
      mode: ExportMode.eventsOnly,
    );

    expect(jsonExport['total_events'], 1);
    expect(jsonExport['export_mode'], 'events_only');

    final events = jsonExport['events'] as List<dynamic>;
    expect(events.length, 1);

    final eventObj = events.first as Map<String, dynamic>;
    expect(eventObj['event_type'], 'bump');
    expect(eventObj['classification'], 'severe');
    expect(eventObj['peak_metric'], 2.5);
    expect(eventObj['parameters']['bump']['peakGForce'], 2.5);

    // Verify sensor readings are sorted by sequenceNo ascending (1 then 2)
    final readings = eventObj['sensor_readings'] as List<dynamic>;
    expect(readings.length, 2);
    expect(readings[0]['sequence_no'], 1);
    expect(readings[1]['sequence_no'], 2);

    // Verify linked camera detections
    final detections = eventObj['camera_detections'] as List<dynamic>;
    expect(detections.length, 1);
    expect(detections[0]['event_class'], 'pothole');
    expect(detections[0]['confidence'], closeTo(0.88, 0.001));
  });

  test('buildJsonExport in fullRawSession mode includes unlinked background telemetry', () async {
    final jsonExport = await repo.buildJsonExport(
      mode: ExportMode.fullRawSession,
    );

    expect(jsonExport['export_mode'], 'full_raw_session');
    expect(jsonExport.containsKey('raw_unlabeled_sensor_readings'), isTrue);

    final unlinked = jsonExport['raw_unlabeled_sensor_readings'] as List<dynamic>;
    expect(unlinked.length, 1);
    expect(unlinked[0]['sequence_no'], 3);
  });

  test('buildSensorCsvExport generates valid CSV headers and data rows', () async {
    final csv = await repo.buildSensorCsvExport(
      mode: ExportMode.eventsOnly,
    );

    final lines = csv.trim().split('\n');
    expect(lines.length, 3); // 1 header line + 2 reading rows

    expect(lines[0], contains('reading_id,timestamp_iso8601,timestamp_local'));
    expect(lines[0], contains('event_type,event_classification'));
    expect(lines[1], contains('dev-watch-1'));
    expect(lines[1], contains('bump'));
    expect(lines[1], contains('severe'));
  });

  test('buildCameraCsvExport generates valid CSV format for camera detections', () async {
    final csv = await repo.buildCameraCsvExport(
      mode: ExportMode.eventsOnly,
    );

    final lines = csv.trim().split('\n');
    expect(lines.length, 2); // 1 header line + 1 detection row
    expect(lines[0], contains('detection_id,camera_timestamp_utc'));
    expect(lines[1], contains('esp32-cam-01'));
    expect(lines[1], contains('pothole'));
  });

  test('buildPerSensorCsvExports generates separate CSV data sheets per distinct device', () async {
    final perSensorMap = await repo.buildPerSensorCsvExports(
      mode: ExportMode.fullRawSession,
    );

    expect(perSensorMap.containsKey('dev-watch-1'), isTrue);
    final watchCsv = perSensorMap['dev-watch-1']!;
    final lines = watchCsv.trim().split('\n');
    expect(lines.length, 4); // 1 header + 3 readings
    expect(lines[0], contains('reading_id,timestamp_iso8601,timestamp_local'));
    expect(lines[1], contains('dev-watch-1'));
  });

  test('exportTripCsv and exportTripJson produce complete journey datasets with GPS route points', () async {
    final now = DateTime.now().toUtc();
    final tripId = await db.into(db.trips).insert(
      TripsCompanion.insert(
        riderName: const Value('Om'),
        startTimeUtc: now.subtract(const Duration(minutes: 10)),
        endTimeUtc: Value(now),
        durationSeconds: const Value(600),
        distanceMeters: const Value(3500.0),
        avgSpeedKmh: const Value(21.0),
        peakSpeedKmh: const Value(34.2),
        startLat: const Value(19.0760),
        startLng: const Value(72.8777),
        endLat: const Value(19.0800),
        endLng: const Value(72.8850),
        routeCoordinatesJson: const Value('[{"lat":19.0760,"lng":72.8777},{"lat":19.0800,"lng":72.8850}]'),
      ),
    );

    // Tag sensor reading with tripId
    await db.into(db.sensorReadings).insert(
      SensorReadingsCompanion.insert(
        deviceId: 'dev-watch-1',
        deviceType: 'watch',
        sequenceNo: 10,
        timestampUtc: now.subtract(const Duration(minutes: 5)),
        sensorType: 'imu',
        tripId: Value(tripId),
        accelX: const Value(0.3),
        accelY: const Value(-0.1),
        accelZ: const Value(9.8),
      ),
    );

    final tripCsv = await repo.exportTripCsv(tripId);
    final csvLines = tripCsv.trim().split('\n');
    expect(csvLines.length, 2); // Header + 1 reading
    expect(csvLines[0], contains('reading_id,timestamp_iso8601,timestamp_local,timestamp_epoch_ms'));
    expect(csvLines[1], contains('$tripId'));

    final tripJson = await repo.exportTripJson(tripId);
    expect(tripJson['trip_id'], tripId);
    expect(tripJson['rider_name'], 'Om');
    expect(tripJson['distance_meters'], 3500.0);
    expect(tripJson['avg_speed_kmh'], 21.0);
    final routePoints = tripJson['gps_route_breadcrumbs'] as List<dynamic>;
    expect(routePoints.length, 2);
    final readings = tripJson['sensor_readings'] as List<dynamic>;
    expect(readings.length, 1);
  });

  test('All CSV export formats have strictly uniform column counts on every row (header, sentinels, data)', () async {
    final now = DateTime.now().toUtc();
    final tripId = await db.into(db.trips).insert(
      TripsCompanion.insert(
        riderName: const Value('Om'),
        wristSide: const Value('left_hand'),
        startTimeUtc: now.subtract(const Duration(minutes: 5)),
        endTimeUtc: Value(now),
        startTimestampUtc: Value(now.subtract(const Duration(minutes: 5))),
        endTimestampUtc: Value(now),
        totalDistanceKm: const Value(2.5),
        totalDurationMin: const Value(5.0),
        avgSpeedKmh: const Value(30.0),
        maxSpeedKmh: const Value(45.0),
        bumpCount: const Value(2),
        harshTurnCount: const Value(1),
        harshBrakeCount: const Value(1),
        harshAccelCount: const Value(0),
        confirmedEventCount: const Value(3),
        eventsPerKm: const Value(1.2),
        avgHr: const Value(78.5),
        maxHr: const Value(110),
        driverScore: const Value(92.0),
      ),
    );

    // Event with context window
    final eventId = await db.into(db.eventRecords).insert(
      EventRecordsCompanion.insert(
        tripId: Value(tripId),
        eventType: 'bump',
        status: 'completed',
        startTimestamp: now.subtract(const Duration(seconds: 10)),
        endTimestamp: Value(now.subtract(const Duration(seconds: 8))),
        peakMetric: const Value(2.8),
        classification: const Value('severe'),
        crossConfirmed: const Value(true),
      ),
    );

    // Readings: one before event (context pre), one during event (event data), one after (context post)
    await db.into(db.sensorReadings).insert(
      SensorReadingsCompanion.insert(
        deviceId: 'ESP32-LEFT',
        deviceType: 'watch',
        mountLocation: const Value('left_hand'),
        sequenceNo: 100,
        timestampUtc: now.subtract(const Duration(seconds: 12)),
        sensorType: 'imu',
        tripId: Value(tripId),
        accelX: const Value(0.1),
        accelY: const Value(0.2),
        accelZ: const Value(9.8),
      ),
    );

    await db.into(db.sensorReadings).insert(
      SensorReadingsCompanion.insert(
        deviceId: 'ESP32-LEFT',
        deviceType: 'watch',
        mountLocation: const Value('left_hand'),
        sequenceNo: 101,
        timestampUtc: now.subtract(const Duration(seconds: 9)),
        sensorType: 'imu',
        tripId: Value(tripId),
        eventId: Value(eventId),
        accelX: const Value(0.5),
        accelY: const Value(0.8),
        accelZ: const Value(22.4),
      ),
    );

    await db.into(db.sensorReadings).insert(
      SensorReadingsCompanion.insert(
        deviceId: 'ESP32-RIGHT',
        deviceType: 'watch',
        mountLocation: const Value('right_hand'),
        sequenceNo: 102,
        timestampUtc: now.subtract(const Duration(seconds: 7)),
        sensorType: 'imu',
        tripId: Value(tripId),
        accelX: const Value(0.2),
        accelY: const Value(0.3),
        accelZ: const Value(9.7),
      ),
    );

    // Location reading
    await db.into(db.locationReadings).insert(
      LocationReadingsCompanion.insert(
        tripId: tripId,
        timestampUtc: now.subtract(const Duration(seconds: 9)),
        latitude: 19.0760,
        longitude: 72.8777,
        gpsSpeedMps: const Value(8.5),
        gpsHeadingDeg: const Value(90.0),
        gpsAccuracyM: const Value(2.0),
      ),
    );

    // 1. Validate exportTripCsv (32 columns per row)
    final tripCsv = await repo.exportTripCsv(tripId);
    final tripCsvLines = tripCsv.trim().split('\n');
    expect(tripCsvLines.length, greaterThanOrEqualTo(5)); // Header, EVENT_START, 3 readings, EVENT_END
    final expectedTripCols = tripCsvLines[0].split(',').length;
    expect(expectedTripCols, 32, reason: 'Header must have 32 columns');
    for (int i = 0; i < tripCsvLines.length; i++) {
      final cols = tripCsvLines[i].split(',').length;
      expect(cols, 32, reason: 'Line $i ($tripCsvLines[i]) must have exactly 32 columns');
    }

    // 2. Validate buildSensorTimeseriesCsvExport (31 columns per row)
    final timeseriesCsv = await repo.buildSensorTimeseriesCsvExport(mode: ExportMode.fullRawSession);
    final tsLines = timeseriesCsv.trim().split('\n');
    expect(tsLines.length, greaterThanOrEqualTo(2));
    final expectedTsCols = tsLines[0].split(',').length;
    expect(expectedTsCols, 31, reason: 'Timeseries header must have 31 columns');
    for (int i = 0; i < tsLines.length; i++) {
      final cols = tsLines[i].split(',').length;
      expect(cols, 31, reason: 'Timeseries line $i must have exactly 31 columns');
    }

    // 3. Validate buildEventRecordsCsvExport (24 columns per row)
    final eventCsv = await repo.buildEventRecordsCsvExport();
    final evLines = eventCsv.trim().split('\n');
    expect(evLines.length, greaterThanOrEqualTo(2));
    final expectedEvCols = evLines[0].split(',').length;
    expect(expectedEvCols, 24, reason: 'Event records header must have 24 columns');
    for (int i = 0; i < evLines.length; i++) {
      final cols = evLines[i].split(',').length;
      expect(cols, 24, reason: 'Event line $i must have exactly 24 columns');
    }

    // 4. Validate buildTripSummaryCsvExport (22 columns per row)
    final summaryCsv = await repo.buildTripSummaryCsvExport();
    final sumLines = summaryCsv.trim().split('\n');
    expect(sumLines.length, greaterThanOrEqualTo(2));
    final expectedSumCols = sumLines[0].split(',').length;
    expect(expectedSumCols, 22, reason: 'Trip summary header must have 22 columns');
    for (int i = 0; i < sumLines.length; i++) {
      final cols = sumLines[i].split(',').length;
      expect(cols, 22, reason: 'Summary line $i must have exactly 22 columns');
    }
  });
}

