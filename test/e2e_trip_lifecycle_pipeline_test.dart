import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/features/trips/trip_controller.dart';
import 'package:ride_sensor_capture/features/events/event_recording_controller.dart';
import 'package:ride_sensor_capture/providers/db_providers.dart';
import 'package:ride_sensor_capture/voice/voice_command_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SensorRepositoryImpl sensorRepo;
  late ExportRepositoryImpl exportRepo;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sensorRepo = SensorRepositoryImpl(db);
    exportRepo = ExportRepositoryImpl(db);

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sensorRepositoryProvider.overrideWithValue(sensorRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    sensorRepo.dispose();
    await db.close();
  });

  test('E2E Pipeline Test: Dual-watch streaming, event bounding boxes, and CSV integrity', () async {
    final tripController = container.read(tripControllerProvider.notifier);
    final eventController = container.read(eventRecordingControllerProvider.notifier);

    // 1. Start Journey
    final startSuccess = await tripController.startJourney(
      riderName: 'TestRider',
      wristSide: 'Both Hands',
    );
    expect(startSuccess, isTrue);

    final tripState = container.read(tripControllerProvider);
    expect(tripState.isJourneyActive, isTrue);
    expect(tripState.activeTripId, isNotNull);
    final tripId = tripState.activeTripId!;

    final tripRecord = await sensorRepo.getTrip(tripId);
    expect(tripRecord, isNotNull);
    expect(tripRecord!.riderName, equals('TestRider'));
    expect(tripRecord.wristSide, equals('Both Hands'));

    // 2. Stream Cruise Telemetry from Dual ESP32 Watches (Before Event)
    final baseTime = DateTime.now().toUtc().subtract(const Duration(seconds: 4));

    for (int i = 0; i < 5; i++) {
      final t = baseTime.add(Duration(milliseconds: i * 200));
      // Watch 1: Left Hand
      await sensorRepo.insertReading(
        RawSensorData(
          deviceId: 'ESP32_WATCH_LEFT',
          deviceName: 'ESP32 Watch Left',
          deviceType: DeviceType.watch,
          timestamp: t,
          mountLocation: 'left_hand',
          accelX: 0.1,
          accelY: 0.2,
          accelZ: 9.8,
          gyroX: 0.01,
          gyroY: 0.02,
          gyroZ: 0.03,
          rawBytes: [0, 1, 2],
        ),
      );
      // Watch 2: Right Hand
      await sensorRepo.insertReading(
        RawSensorData(
          deviceId: 'ESP32_WATCH_RIGHT',
          deviceName: 'ESP32 Watch Right',
          deviceType: DeviceType.watch,
          timestamp: t,
          mountLocation: 'right_hand',
          accelX: -0.1,
          accelY: 0.3,
          accelZ: 9.79,
          gyroX: -0.01,
          gyroY: 0.01,
          gyroZ: 0.02,
          rawBytes: [0, 1, 2],
        ),
      );
    }
    await sensorRepo.flushPendingBuffer();

    // 3. User hits a road bump: Taps BUMP event
    await eventController.startEvent(EventType.bump, triggerPhrase: 'tap_BUMP');
    final activeEventId = sensorRepo.activeEventId;
    expect(activeEventId, isNotNull);

    // Stream bump impulse readings (tagged with activeEventId)
    final bumpTime = DateTime.now().toUtc();
    for (int i = 0; i < 10; i++) {
      final t = bumpTime.add(Duration(milliseconds: i * 20));
      final bumpImpulseG = (i == 5) ? 2.8 : 1.1; // Peak 2.8g bump spike

      await sensorRepo.insertReading(
        RawSensorData(
          deviceId: 'ESP32_WATCH_LEFT',
          deviceName: 'ESP32 Watch Left',
          deviceType: DeviceType.watch,
          timestamp: t,
          mountLocation: 'left_hand',
          accelX: 0.2,
          accelY: 0.4,
          accelZ: 9.8 * bumpImpulseG,
          gyroX: 0.05,
          gyroY: 0.12,
          gyroZ: 0.08,
          rawBytes: [0, 1, 2],
        ),
      );
      await sensorRepo.insertReading(
        RawSensorData(
          deviceId: 'ESP32_WATCH_RIGHT',
          deviceName: 'ESP32 Watch Right',
          deviceType: DeviceType.watch,
          timestamp: t,
          mountLocation: 'right_hand',
          accelX: -0.2,
          accelY: 0.35,
          accelZ: 9.8 * (bumpImpulseG * 0.95),
          gyroX: -0.04,
          gyroY: 0.10,
          gyroZ: 0.06,
          rawBytes: [0, 1, 2],
        ),
      );
    }
    await sensorRepo.flushPendingBuffer();

    // 4. Bump ends: User taps Stop & Save Event
    await eventController.stopAndSaveEvent(reason: 'Tap Stop');
    expect(sensorRepo.activeEventId, isNull);

    // Stream Post-Event Cruise readings
    final postTime = DateTime.now().toUtc().add(const Duration(seconds: 1));
    for (int i = 0; i < 5; i++) {
      final t = postTime.add(Duration(milliseconds: i * 200));
      await sensorRepo.insertReading(
        RawSensorData(
          deviceId: 'ESP32_WATCH_LEFT',
          deviceName: 'ESP32 Watch Left',
          deviceType: DeviceType.watch,
          timestamp: t,
          mountLocation: 'left_hand',
          accelX: 0.12,
          accelY: 0.18,
          accelZ: 9.81,
          rawBytes: [0, 1, 2],
        ),
      );
      await sensorRepo.insertReading(
        RawSensorData(
          deviceId: 'ESP32_WATCH_RIGHT',
          deviceName: 'ESP32 Watch Right',
          deviceType: DeviceType.watch,
          timestamp: t,
          mountLocation: 'right_hand',
          accelX: -0.11,
          accelY: 0.19,
          accelZ: 9.80,
          rawBytes: [0, 1, 2],
        ),
      );
    }
    await sensorRepo.flushPendingBuffer();

    // 5. End Journey
    final completedTrip = await tripController.endJourney();
    expect(completedTrip, isNotNull);
    expect(container.read(tripControllerProvider).isJourneyActive, isFalse);

    final finalTripRecord = await sensorRepo.getTrip(tripId);
    expect(finalTripRecord!.endTimeUtc, isNotNull);
    expect(finalTripRecord.totalSensorRows, greaterThan(0));

    // 6. Generate & Validate Export CSV
    final csv = await exportRepo.exportTripCsv(tripId);
    expect(csv, isNotEmpty);

    final lines = csv.trim().split('\n');
    final header = lines.first;

    // Verify header columns
    expect(header, contains('reading_id'));
    expect(header, contains('mount_location'));
    expect(header, contains('trip_id'));
    expect(header, contains('event_id'));
    expect(header, contains('event_type'));
    expect(header, contains('bbox_marker'));

    // Verify dual-watch mount locations are present in CSV
    expect(csv, contains('left_hand'));
    expect(csv, contains('right_hand'));

    // Verify Bounding Box sentinel rows and event markers
    expect(csv, contains('EVENT_START'));
    expect(csv, contains('EVENT_END'));
    expect(csv, contains('EVENT_DATA'));

    // Check that EVENT_DATA rows correctly retain event metadata
    final eventDataLines = lines.where((l) => l.contains('EVENT_DATA')).toList();
    expect(eventDataLines, isNotEmpty);
    for (final line in eventDataLines) {
      expect(line, contains('bump'));
      expect(line, contains('$activeEventId'));
    }
  });
}
