import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/camera/camera_detection_model.dart';
import 'package:ride_sensor_capture/camera/camera_detection_repository.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';

/// Simple stub that lets tests control activeEventId.
class _StubSensorRepository implements SensorRepository {
  @override
  int? activeEventId;

  _StubSensorRepository({this.activeEventId});

  // ── Unused interface members ────────────────────────────────────────────────
  @override
  void setActiveEventId(int? eventId) => activeEventId = eventId;
  @override
  Future<void> insertReading(RawSensorData data) async {}
  @override
  Future<void> insertReadingsBatch(List<RawSensorData> dataList) async {}
  @override
  Stream<List<SensorReading>> watchRecentReadings({int limit = 50}) =>
      const Stream.empty();
  @override
  Stream<List<SensorReading>> watchReadingsForDevice(String deviceId,
          {int limit = 50}) =>
      const Stream.empty();
  @override
  Stream<List<SensorReading>> watchReadingsForEvent(int eventId) =>
      const Stream.empty();
  @override
  Future<int> getReadingCountForEvent(int eventId) async => 0;
  @override
  Future<int> getTotalCount() async => 0;
  @override
  Future<Map<String, int>> getCountPerDevice() async => {};
  @override
  Future<DateTime?> getLastWriteTime() async => null;
  @override
  Future<int> getLastSequenceNoForDevice(String deviceId) async => 0;
  @override
  Future<int> createEventRecord(EventRecordsCompanion event) async => 0;
  @override
  Future<void> updateEventRecord(EventRecord event) async {}
  @override
  Stream<List<EventRecord>> watchAllEvents() => const Stream.empty();
  @override
  void dispose() {}
}

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  // ── Payload Validation ─────────────────────────────────────────────────────
  group('CameraDetectionPayload validation', () {
    test('accepts a fully valid payload', () {
      final p = CameraDetectionPayload.fromJsonString('''
        {
          "event_class": "pothole",
          "confidence": 0.87,
          "camera_timestamp_utc": "2026-08-20T18:10:00Z",
          "device_id": "esp32-cam-01"
        }
      ''');
      expect(p, isNotNull);
      expect(p!.eventClass, 'pothole');
      expect(p.confidence, closeTo(0.87, 0.001));
      expect(p.deviceId, 'esp32-cam-01');
      expect(p.cameraTimestampUtc.isUtc, isTrue);
    });

    test('rejects missing event_class', () {
      final p = CameraDetectionPayload.fromJsonString(
          '{"confidence":0.9,"camera_timestamp_utc":"2026-08-20T18:00:00Z","device_id":"cam"}');
      expect(p, isNull);
    });

    test('rejects confidence > 1.0', () {
      final p = CameraDetectionPayload.fromJsonString(
          '{"event_class":"bump","confidence":1.5,"camera_timestamp_utc":"2026-08-20T18:00:00Z","device_id":"cam"}');
      expect(p, isNull);
    });

    test('rejects confidence < 0.0', () {
      final p = CameraDetectionPayload.fromJsonString(
          '{"event_class":"bump","confidence":-0.1,"camera_timestamp_utc":"2026-08-20T18:00:00Z","device_id":"cam"}');
      expect(p, isNull);
    });

    test('rejects malformed ISO8601 timestamp', () {
      final p = CameraDetectionPayload.fromJsonString(
          '{"event_class":"bump","confidence":0.7,"camera_timestamp_utc":"not-a-date","device_id":"cam"}');
      expect(p, isNull);
    });

    test('rejects blank event_class after trimming', () {
      final p = CameraDetectionPayload.fromJsonString(
          '{"event_class":"   ","confidence":0.7,"camera_timestamp_utc":"2026-08-20T18:00:00Z","device_id":"cam"}');
      expect(p, isNull);
    });

    test('rejects invalid JSON body', () {
      expect(CameraDetectionPayload.fromJsonString('not json'), isNull);
    });

    test('rejects missing device_id', () {
      final p = CameraDetectionPayload.fromJsonString(
          '{"event_class":"bump","confidence":0.7,"camera_timestamp_utc":"2026-08-20T18:00:00Z"}');
      expect(p, isNull);
    });
  });

  // ── Repository ─────────────────────────────────────────────────────────────
  group('CameraDetectionRepository', () {
    late AppDatabase db;
    late _StubSensorRepository stubRepo;
    late CameraDetectionRepository repo;

    setUp(() {
      db = _makeTestDb();
      stubRepo = _StubSensorRepository(activeEventId: null);
      repo = CameraDetectionRepository(db, stubRepo);
    });

    tearDown(() => db.close());

    test('inserts detection with no active event → linkedEventId is null',
        () async {
      final payload = CameraDetectionPayload.fromMap({
        'event_class': 'pothole',
        'confidence': 0.91,
        'camera_timestamp_utc': '2026-08-20T18:00:00Z',
        'device_id': 'cam-01',
      })!;

      final id = await repo.insertDetection(payload);
      expect(id, greaterThan(0));

      final rows = await repo.watchRecentDetections().first;
      expect(rows.length, 1);
      expect(rows.first.eventClass, 'pothole');
      expect(rows.first.confidence, closeTo(0.91, 0.001));
      expect(rows.first.linkedEventId, isNull);
    });

    test('inserts detection with active event → linkedEventId is set', () async {
      stubRepo.activeEventId = 42;

      final payload = CameraDetectionPayload.fromMap({
        'event_class': 'bump',
        'confidence': 0.75,
        'camera_timestamp_utc': '2026-08-20T18:05:00Z',
        'device_id': 'cam-01',
      })!;

      await repo.insertDetection(payload);
      final rows = await repo.watchRecentDetections().first;
      expect(rows.first.linkedEventId, 42);
    });

    test('watchDetectionsForEvent returns only matching rows', () async {
      // Detection 1 — linked to event 7
      stubRepo.activeEventId = 7;
      await repo.insertDetection(CameraDetectionPayload.fromMap({
        'event_class': 'pothole',
        'confidence': 0.88,
        'camera_timestamp_utc': '2026-08-20T18:00:00Z',
        'device_id': 'cam-01',
      })!);

      // Detection 2 — no active event, no retroactive match
      stubRepo.activeEventId = null;
      await repo.insertDetection(CameraDetectionPayload.fromMap({
        'event_class': 'debris',
        'confidence': 0.62,
        'camera_timestamp_utc': '2026-08-20T19:00:00Z',
        'device_id': 'cam-01',
      })!);

      final forEvent7 = await repo.watchDetectionsForEvent(7).first;
      expect(forEvent7.length, 1);
      expect(forEvent7.first.eventClass, 'pothole');

      final forEvent99 = await repo.watchDetectionsForEvent(99).first;
      expect(forEvent99, isEmpty);
    });

    test('getTotalCount reflects all insertions', () async {
      stubRepo.activeEventId = null;
      for (int i = 0; i < 3; i++) {
        await repo.insertDetection(CameraDetectionPayload.fromMap({
          'event_class': 'class_$i',
          'confidence': 0.5,
          'camera_timestamp_utc': '2026-08-20T18:0$i:00Z',
          'device_id': 'cam',
        })!);
      }
      expect(await repo.getTotalCount(), 3);
    });
  });
}
