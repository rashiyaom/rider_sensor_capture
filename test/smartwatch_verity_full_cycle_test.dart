import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/ble/parsers/esp32_watch_parser.dart';
import 'package:ride_sensor_capture/ble/parsers/polar_verity_parser.dart';
import 'package:ride_sensor_capture/ble/services/ble_connection_manager.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/features/trips/trip_controller.dart';
import 'package:ride_sensor_capture/providers/ble_providers.dart';
import 'package:ride_sensor_capture/providers/dashboard_providers.dart';
import 'package:ride_sensor_capture/providers/db_providers.dart';
import 'package:ride_sensor_capture/providers/ride_recording_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SensorRepositoryImpl sensorRepo;
  late ExportRepositoryImpl exportRepo;
  late BleConnectionManager bleManager;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sensorRepo = SensorRepositoryImpl(db);
    exportRepo = ExportRepositoryImpl(db);
    bleManager = BleConnectionManager();

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sensorRepositoryProvider.overrideWithValue(sensorRepo),
        bleConnectionManagerProvider.overrideWithValue(bleManager),
      ],
    );

    // Keep global bridge active
    container.read(bleToDbBridgeProvider);
  });

  tearDown(() async {
    bleManager.dispose();
    container.dispose();
    sensorRepo.dispose();
    await db.close();
  });

  group('Full Cycle Test: Smartwatch + Polar Verity Dual-Connection, Live Fetch & Start Journey', () {
    test('1. Protocol Parsers: Both Polar Verity and ESP32 Watch decode live payloads accurately', () {
      // 1A. Polar Verity Sense GATT 0x2A37 Heart Rate frame (flags=0x10 -> 8-bit HR + RR Interval)
      final polarHrBytes = [
        0x10, // flags: bit 0 = 0 (8-bit HR), bit 4 = 1 (RR interval present)
        138,  // HR = 138 bpm
        0x00, 0x03, // RR-interval = 768 / 1024 s = 750 ms
      ];
      final parsedPolar = PolarVerityParser.parseHeartRate(
        'POLAR_VERITY_01',
        'Polar Verity Sense',
        polarHrBytes,
      );

      expect(parsedPolar, isNotNull);
      expect(parsedPolar!.deviceId, 'POLAR_VERITY_01');
      expect(parsedPolar.deviceType, DeviceType.verityBand);
      expect(parsedPolar.heartRate, 138);
      expect(parsedPolar.ppiMs, 750);

      // 1B. ESP32-S3 Watch 32-Byte V2 Binary IMU frame (SI units)
      final watchByteData = ByteData(32);
      watchByteData.setUint32(0, 54200, Endian.little); // timestamp_ms
      watchByteData.setUint16(4, 2048, Endian.little);  // seq
      watchByteData.setUint8(6, 1);                     // mount_role = 1 (FORK/LEFT)
      watchByteData.setFloat32(7, 0.42, Endian.little);  // accel_x (m/s^2)
      watchByteData.setFloat32(11, -0.18, Endian.little); // accel_y (m/s^2)
      watchByteData.setFloat32(15, 9.81, Endian.little);  // accel_z (m/s^2)
      watchByteData.setFloat32(19, 0.08, Endian.little);  // gyro_x (rad/s)
      watchByteData.setFloat32(23, -0.04, Endian.little); // gyro_y (rad/s)
      watchByteData.setFloat32(27, 0.15, Endian.little);  // gyro_z (rad/s)
      watchByteData.setUint8(31, 95);                     // battery_pct = 95%

      final parsedWatch = Esp32WatchParser.parseEsp32Payload(
        'ESP32_WATCH_01',
        'ESP32-Watch',
        watchByteData.buffer.asUint8List(),
      );

      expect(parsedWatch, isNotNull);
      expect(parsedWatch!.deviceId, 'ESP32_WATCH_01');
      expect(parsedWatch.deviceType, DeviceType.watch);
      expect(parsedWatch.heartRate, isNull);
      expect(parsedWatch.accelX, closeTo(0.42, 0.01));
      expect(parsedWatch.accelY, closeTo(-0.18, 0.01));
      expect(parsedWatch.accelZ, closeTo(9.81, 0.01));
      expect(parsedWatch.gyroX, closeTo(0.08, 0.005));
      expect(parsedWatch.gyroY, closeTo(-0.04, 0.005));
      expect(parsedWatch.gyroZ, closeTo(0.15, 0.005));
    });

    test('2. Dual Connection Cycle: Both devices connect, stream live data, and load onto phone dashboard', () async {
      // Ensure DashboardTelemetryNotifier is active and listening to rawDataStream
      final dashboardNotifier = container.read(dashboardTelemetryProvider.notifier);
      final now = DateTime.now();

      // Create Watch model
      final watchModel = BleDeviceModel(
        id: 'sim_watch_01',
        name: 'ESP32-Watch',
        type: DeviceType.watch,
        rssi: -55,
        lastSeen: now,
      );

      // Create Polar Verity model
      final polarModel = BleDeviceModel(
        id: 'sim_polar_01',
        name: 'Polar Verity Sense',
        type: DeviceType.verityBand,
        rssi: -62,
        lastSeen: now,
      );

      // Connect both devices simultaneously
      await bleManager.connectToDevice(watchModel);
      await bleManager.connectToDevice(polarModel);

      // Verify connection state of both
      final currentStates = bleManager.currentDeviceStates;
      expect(currentStates['sim_watch_01']?.connectionState, BleConnectionState.connected);
      expect(currentStates['sim_polar_01']?.connectionState, BleConnectionState.connected);

      // Verify live telemetry stream emits data from BOTH devices
      final receivedDeviceIds = <String>{};
      bool hasHeartRate = false;
      final completer = Completer<void>();

      final sub = bleManager.rawDataStream.listen((data) {
        receivedDeviceIds.add(data.deviceId);
        if (data.deviceId == 'sim_polar_01' && data.heartRate != null) {
          hasHeartRate = true;
        }
        if (receivedDeviceIds.contains('sim_watch_01') &&
            hasHeartRate &&
            !completer.isCompleted) {
          completer.complete();
        }
      });

      // Wait for packets including Polar Verity HR packet
      await completer.future.timeout(const Duration(seconds: 3));
      await sub.cancel();

      expect(receivedDeviceIds, contains('sim_watch_01'));
      expect(receivedDeviceIds, contains('sim_polar_01'));

      // Check Dashboard Telemetry Notifier buffers both HR and IMU data
      dashboardNotifier.triggerRefresh();

      final telemetry = container.read(dashboardTelemetryProvider);
      expect(telemetry, isNotNull);
      expect(telemetry.hrSpots, isNotEmpty);
      expect(telemetry.latestHr, greaterThan(0));
      expect(telemetry.accelXSpots, isNotEmpty);
      expect(telemetry.latestAccelZ, closeTo(9.8, 2.0));
      expect(telemetry.gyroZSpots, isNotEmpty);
    });

    test('3. Complete Journey Cycle: Start Journey, stream dual data to SQLite, track stats, and End Journey', () async {
      final tripController = container.read(tripControllerProvider.notifier);

      // 1. User starts journey
      final started = await tripController.startJourney(
        riderName: 'Om Rider',
        wristSide: 'Left Hand',
      );
      expect(started, isTrue);

      final tripState = container.read(tripControllerProvider);
      expect(tripState.isJourneyActive, isTrue);
      expect(tripState.riderName, 'Om Rider');
      expect(tripState.wristSide, 'Left Hand');
      expect(tripState.activeTripId, isNotNull);
      final tripId = tripState.activeTripId!;

      // Verify recording is active
      expect(container.read(isRideRecordingActiveProvider), isTrue);

      // 2. Stream concurrent live packets from both Smartwatch and Polar Verity Band
      final startTime = DateTime.now().toUtc();

      for (int i = 0; i < 25; i++) {
        final t = startTime.add(Duration(milliseconds: i * 40));

        // Stream Polar Verity Heart Rate packet
        final hrPacket = RawSensorData(
          deviceId: 'POLAR_SENSE_01',
          deviceName: 'Polar Verity Sense',
          deviceType: DeviceType.verityBand,
          timestamp: t,
          heartRate: 140 + (i % 5),
          ppiMs: 430,
          rawBytes: [0x10, 140, 0x00, 0x02],
        );
        await sensorRepo.insertReading(hrPacket.copyWith(mountLocation: 'forearm'));

        // Stream ESP32 Watch 6-Axis IMU packet
        final watchPacket = RawSensorData(
          deviceId: 'ESP32_WATCH_01',
          deviceName: 'ESP32-Watch',
          deviceType: DeviceType.watch,
          timestamp: t,
          accelX: 0.15 + (i * 0.01),
          accelY: -0.22,
          accelZ: 9.81 + (i % 3 == 0 ? 0.4 : 0.0),
          gyroX: 0.02,
          gyroY: -0.01,
          gyroZ: 0.05,
          rawBytes: [0, 1, 2, 3],
        );
        await sensorRepo.insertReading(watchPacket.copyWith(mountLocation: 'left_hand'));
      }

      await sensorRepo.flushPendingBuffer();

      // Verify database records are tagged with tripId
      final allReadings = await (db.select(db.sensorReadings)..where((t) => t.tripId.equals(tripId))).get();
      expect(allReadings.length, equals(50)); // 25 Polar + 25 Watch

      final watchReadings = allReadings.where((r) => r.deviceType == 'watch').toList();
      final polarReadings = allReadings.where((r) => r.deviceType == 'verityBand').toList();

      expect(watchReadings.length, equals(25));
      expect(polarReadings.length, equals(25));

      for (final r in watchReadings) {
        expect(r.tripId, equals(tripId));
        expect(r.mountLocation, equals('left_hand'));
        expect(r.accelZ, isNotNull);
        expect(r.gyroZ, isNotNull);
      }

      for (final r in polarReadings) {
        expect(r.tripId, equals(tripId));
        expect(r.mountLocation, equals('forearm'));
        expect(r.heartRate, greaterThanOrEqualTo(140));
      }

      // 3. End Journey
      final completedTrip = await tripController.endJourney();
      expect(completedTrip, isNotNull);
      expect(container.read(tripControllerProvider).isJourneyActive, isFalse);

      final savedTrip = await sensorRepo.getTrip(tripId);
      expect(savedTrip, isNotNull);
      expect(savedTrip!.riderName, 'Om Rider');
      expect(savedTrip.wristSide, 'Left Hand');
      expect(savedTrip.endTimeUtc, isNotNull);
      expect(savedTrip.totalSensorRows, equals(50));

      // 4. Export CSV validation
      final csv = await exportRepo.exportTripCsv(tripId);
      expect(csv, isNotEmpty);
      expect(csv, contains('forearm'));
      expect(csv, contains('left_hand'));
      expect(csv, contains('POLAR_SENSE_01'));
      expect(csv, contains('ESP32_WATCH_01'));
    });
  });
}
