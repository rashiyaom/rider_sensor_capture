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

    expect(lines[0], contains('reading_id,timestamp_utc,sequence_no'));
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
}
