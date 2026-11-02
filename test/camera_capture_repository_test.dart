import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/camera/camera_capture_repository.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/features/export/models/export_options.dart';

void main() {
  late AppDatabase db;
  late SensorRepositoryImpl sensorRepo;
  late Directory storage;
  late CameraCaptureRepository cameraRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sensorRepo = SensorRepositoryImpl(db);
    storage = await Directory.systemTemp.createTemp('ride-camera-test-');
    cameraRepo = CameraCaptureRepository(
      db,
      sensorRepo,
      storageRoot: storage,
    );
  });

  tearDown(() async {
    sensorRepo.dispose();
    await db.close();
    if (await storage.exists()) await storage.delete(recursive: true);
  });

  test('stores ordered JPEG manifest rows mapped to active trip and event',
      () async {
    final now = DateTime.utc(2026, 10, 28, 12, 30);
    final tripId = await db.into(db.trips).insert(
          TripsCompanion.insert(startTimeUtc: now),
        );
    final eventId = await db.into(db.eventRecords).insert(
          EventRecordsCompanion.insert(
            eventType: 'bump',
            startTimestamp: now,
            status: 'active',
            tripId: Value(tripId),
          ),
        );
    sensorRepo
      ..setActiveTripId(tripId)
      ..setActiveEventId(eventId);

    final jpeg = Uint8List.fromList([0xff, 0xd8, 1, 2, 3, 0xff, 0xd9]);
    final first = await cameraRepo.saveJpeg(
      bytes: jpeg,
      deviceId: 'uvc:303a:4002:ride-cam',
      width: 640,
      height: 480,
      capturedAtUtc: now,
      trigger: 'incident_start',
    );
    final second = await cameraRepo.saveJpeg(
      bytes: jpeg,
      deviceId: 'uvc:303a:4002:ride-cam',
      width: 640,
      height: 480,
      capturedAtUtc: now.add(const Duration(seconds: 1)),
      trigger: 'manual',
    );

    expect(first.sequenceNo, 1);
    expect(second.sequenceNo, 2);
    expect(first.tripId, tripId);
    expect(first.linkedEventId, eventId);
    expect(first.sha256, hasLength(64));
    expect(await File(first.filePath).exists(), isTrue);

    final eventRows = await cameraRepo.watchForEvent(eventId).first;
    expect(eventRows.map((row) => row.sequenceNo), [1, 2]);

    final manifest = await ExportRepositoryImpl(db).buildCameraCaptureCsvExport(
      mode: ExportMode.fullRawSession,
    );
    expect(manifest, contains('capture_key,trip_id,event_id'));
    expect(manifest, contains('incident_start'));
    expect(manifest, contains(first.sha256));
  });

  test('rejects an incomplete JPEG without creating a DB row', () async {
    expect(
      () => cameraRepo.saveJpeg(
        bytes: Uint8List.fromList([1, 2, 3]),
        deviceId: 'cam',
        width: 320,
        height: 240,
      ),
      throwsA(isA<FormatException>()),
    );
    expect(await db.select(db.cameraCaptures).get(), isEmpty);
  });
}
