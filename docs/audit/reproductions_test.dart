// Diagnostic acceptance tests for open audit findings. Run explicitly:
// flutter test --no-pub docs/audit/reproductions_test.dart
// These intentionally fail until the reported defects are fixed.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';
import 'package:ride_sensor_capture/data/services/windowed_feature_extractor_service.dart';
import 'package:ride_sensor_capture/features/events/event_recording_controller.dart';

void main() {
  late AppDatabase db;
  late SensorRepositoryImpl repo;
  final now = DateTime.utc(2026, 11, 6, 12);
  RawSensorData sample(int ms) => RawSensorData(
    deviceId: 'watch',
    deviceName: 'Watch',
    deviceType: DeviceType.watch,
    timestamp: now.add(Duration(milliseconds: ms)),
    accelX: 0,
    accelY: 0,
    accelZ: 9.81,
    rawBytes: const [],
  );
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SensorRepositoryImpl(db);
  });
  tearDown(() async {
    repo.dispose();
    await db.close();
  });

  test('AUD-05: a new manual event must be able to clear the previous trip', () {
    const previous = EventRecordingSessionState(tripId: 7, activeEventId: 10);
    final next = previous.copyWith(tripId: null, activeEventId: 11);
    expect(next.tripId, isNull);
  });

  test('AUD-06: training and validation windows must not share raw samples', () {
    final rows = List.generate(400, (i) => SensorReading(
      id: i + 1, deviceId: 'left', deviceType: 'watch', sequenceNo: i,
      timestampUtc: now.add(Duration(milliseconds: i * 20)), sensorType: 'imu',
      mountLocation: 'left_hand', accelX: 0, accelY: 0, accelZ: 9.81,
    ));
    final windows = const WindowedFeatureExtractorService().extractWindows(readings: rows);
    final lastTrain = windows.lastWhere((w) => w['dataset_split'] == 'train');
    final firstValidation = windows.firstWhere((w) => w['dataset_split'] == 'val');
    expect(firstValidation['start_row_idx'], greaterThan(lastTrain['end_row_idx'] as int));
  });

  test('AUD-01: database must preserve 20ms sample spacing', () async {
    await repo.insertReadingsBatch([sample(0), sample(20)]);
    final rows = await db.select(db.sensorReadings).get();
    expect(
      rows[1].timestampUtc.difference(rows[0].timestampUtc).inMilliseconds,
      20,
    );
  });
  test('AUD-02: buffered samples must retain event at arrival', () async {
    repo.setActiveTripId(1);
    repo.setActiveEventId(10);
    await repo.insertReading(sample(0));
    repo.setActiveEventId(11);
    await repo.flushPendingBuffer();
    expect((await db.select(db.sensorReadings).getSingle()).eventId, 10);
  });
  test('AUD-03: failed flush must retain samples for retry', () async {
    await db.customStatement(
      "CREATE TRIGGER fail_write BEFORE INSERT ON sensor_readings BEGIN SELECT RAISE(ABORT, 'simulated storage failure'); END;",
    );
    await repo.insertReading(sample(0));
    await expectLater(repo.flushPendingBuffer(), throwsA(anything));
    await db.customStatement('DROP TRIGGER fail_write');
    await repo.flushPendingBuffer();
    expect(await db.select(db.sensorReadings).get(), hasLength(1));
  });
  test('AUD-04: 1.5s windows must span 1.5s with two 50Hz devices', () {
    final rows = <SensorReading>[];
    for (var i = 0; i < 100; i++) {
      for (final id in ['left', 'right']) {
        rows.add(
          SensorReading(
            id: rows.length + 1,
            deviceId: id,
            deviceType: 'watch',
            sequenceNo: i,
            timestampUtc: now.add(Duration(milliseconds: i * 20)),
            sensorType: 'imu',
            mountLocation: '${id}_hand',
            accelX: 0,
            accelY: 0,
            accelZ: 9.81,
          ),
        );
      }
    }
    final windows = const WindowedFeatureExtractorService().extractWindows(
      readings: rows,
    );
    expect(windows.first['duration_sec'], greaterThanOrEqualTo(1.4));
  });
}
