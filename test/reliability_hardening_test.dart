import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battery_plus/battery_plus.dart';

import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/ble/services/ble_scanner.dart';
import 'package:ride_sensor_capture/ble/services/ble_connection_manager.dart';
import 'package:ride_sensor_capture/core/services/battery_service.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('BLE Model & Connection Health Tests', () {
    test('BleDeviceModel supports lost state and connection health flags', () {
      final now = DateTime.now();
      final device = BleDeviceModel(
        id: 'D1:23:45:67:89:AB',
        name: 'ESP32-S3 Watch',
        type: DeviceType.watch,
        connectionState: BleConnectionState.reconnecting,
        health: ConnectionHealth.degraded,
        rssi: -72,
        lastSeen: now,
        retryAttempts: 3,
        packetsReceived: 450,
      );

      expect(device.connectionState, BleConnectionState.reconnecting);
      expect(device.health, ConnectionHealth.degraded);
      expect(device.retryAttempts, 3);
      expect(device.packetsReceived, 450);

      final lostDevice = device.copyWith(
        connectionState: BleConnectionState.lost,
        health: ConnectionHealth.poor,
        retryAttempts: 6,
      );

      expect(lostDevice.connectionState, BleConnectionState.lost);
      expect(lostDevice.health, ConnectionHealth.poor);
      expect(lostDevice.retryAttempts, 6);
    });

    test('BleDeviceModel infers Polar Verity Sense and ESP32 watch types accurately', () {
      expect(BleDeviceModel.inferDeviceType('Polar Sense 1234'), DeviceType.verityBand);
      expect(BleDeviceModel.inferDeviceType('Verity Band PMD'), DeviceType.verityBand);
      expect(BleDeviceModel.inferDeviceType('ESP32-S3 AMOLED Watch'), DeviceType.watch);
      expect(BleDeviceModel.inferDeviceType('RideSensor_ESP'), DeviceType.watch);
      expect(BleDeviceModel.inferDeviceType('UnknownBT'), DeviceType.unknown);
    });
  });

  group('Sequence Number Continuation Tests', () {
    late AppDatabase db;
    late SensorRepositoryImpl repo;

    setUp(() {
      db = _makeTestDb();
      repo = SensorRepositoryImpl(db);
    });

    tearDown(() => db.close());

    test('resumes sequence numbers monotonically from database across disconnects or restarts', () async {
      const devId = 'watch-1';
      final now = DateTime.now();

      // Insert first batch (sequence 1, 2)
      await repo.insertReadingsBatch([
        RawSensorData(
          deviceId: devId,
          deviceName: 'Watch',
          deviceType: DeviceType.watch,
          timestamp: now,
          rawBytes: const [],
          accelX: 0.1,
          accelY: 0.2,
          accelZ: 9.8,
        ),
        RawSensorData(
          deviceId: devId,
          deviceName: 'Watch',
          deviceType: DeviceType.watch,
          timestamp: now.add(const Duration(milliseconds: 100)),
          rawBytes: const [],
          accelX: 0.2,
          accelY: 0.3,
          accelZ: 9.9,
        ),
      ]);

      final lastSeq = await repo.getLastSequenceNoForDevice(devId);
      expect(lastSeq, 2);

      // Simulate repository reload / reconnect
      final repo2 = SensorRepositoryImpl(db);
      await repo2.insertReadingsBatch([
        RawSensorData(
          deviceId: devId,
          deviceName: 'Watch',
          deviceType: DeviceType.watch,
          timestamp: now.add(const Duration(milliseconds: 200)),
          rawBytes: const [],
          accelX: 0.3,
          accelY: 0.4,
          accelZ: 10.0,
        ),
      ]);

      final updatedSeq = await repo2.getLastSequenceNoForDevice(devId);
      expect(updatedSeq, 3);

      final rows = await repo2.watchReadingsForDevice(devId).first;
      expect(rows.length, 3);
      expect(rows[0].sequenceNo, 3);
      expect(rows[1].sequenceNo, 2);
      expect(rows[2].sequenceNo, 1);

      repo2.dispose();
    });
  });

  group('Battery & Power Throttling Logic Tests', () {
    test('calculates remaining ride hours based on ~9% per hour discharge', () {
      const bat100 = BatteryInfo(batteryLevel: 100, state: BatteryState.discharging);
      expect(bat100.estimatedRideHoursRemaining, closeTo(11.1, 0.2));
      expect(bat100.isLowBattery, isFalse);
      expect(bat100.activePowerMode, PowerMode.normal);

      const bat18 = BatteryInfo(batteryLevel: 18, state: BatteryState.discharging);
      expect(bat18.isLowBattery, isTrue);
      expect(bat18.isCriticalBattery, isFalse);
      expect(bat18.activePowerMode, PowerMode.powerSaving);
      expect(bat18.estimatedRideHoursRemaining, closeTo(2.0, 0.1));

      const bat8 = BatteryInfo(batteryLevel: 8, state: BatteryState.discharging);
      expect(bat8.isCriticalBattery, isTrue);
      expect(bat8.activePowerMode, PowerMode.critical);

      const batForced = BatteryInfo(batteryLevel: 80, isPowerSavingForced: true);
      expect(batForced.activePowerMode, PowerMode.powerSaving);
    });
  });

  group('BLE Discovery and Simulated Sensor Tests', () {
    test('BleScanner supports toggling demo sensor devices', () {
      final scanner = BleScanner();
      scanner.toggleDemoDevices(true);
      final devices = scanner.currentDiscoveredDevices;
      expect(devices.any((d) => d.id == 'sim_verity_1'), isTrue);
      expect(devices.any((d) => d.id == 'sim_watch_1'), isTrue);

      scanner.toggleDemoDevices(false);
      expect(scanner.currentDiscoveredDevices.any((d) => d.id.startsWith('sim_')), isFalse);
      scanner.dispose();
    });

    test('BleConnectionManager connects to simulated sensor and streams data', () async {
      final manager = BleConnectionManager();
      final model = BleDeviceModel(
        id: 'sim_verity_1',
        name: 'Polar Verity Sense [Demo]',
        type: DeviceType.verityBand,
        rssi: -58,
        lastSeen: DateTime.now(),
      );

      final receivedData = <RawSensorData>[];
      final sub = manager.rawDataStream.listen((data) {
        receivedData.add(data);
      });

      await manager.connectToDevice(model);
      final state = manager.currentDeviceStates['sim_verity_1'];
      expect(state?.connectionState, BleConnectionState.connected);
      expect(state?.health, ConnectionHealth.good);

      // Wait a short moment to receive packets
      await Future.delayed(const Duration(milliseconds: 150));
      expect(receivedData.isNotEmpty, isTrue);
      expect(receivedData.first.deviceId, 'sim_verity_1');

      await manager.disconnectDevice('sim_verity_1');
      expect(manager.currentDeviceStates['sim_verity_1']?.connectionState, BleConnectionState.disconnected);

      await sub.cancel();
      manager.dispose();
    });
  });
}

