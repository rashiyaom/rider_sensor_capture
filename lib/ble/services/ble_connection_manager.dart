import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_device_model.dart';
import '../models/raw_sensor_data.dart';
import '../parsers/polar_verity_parser.dart';
import '../parsers/esp32_watch_parser.dart';

class BleConnectionManager {
  static const int maxReconnectAttempts = 6;
  static const int baseRetryDelaySeconds = 2;
  static const int maxRetryDelaySeconds = 20;

  final Map<String, BleDeviceModel> _deviceModelsMap = {};
  final Map<String, StreamSubscription> _connectionStateSubscriptions = {};
  final Map<String, StreamSubscription> _charNotificationSubscriptions = {};
  final Set<String> _userConnectedDeviceIds = {};
  final Map<String, int> _deviceRetryCounts = {};
  final Map<String, Timer?> _deviceReconnectTimers = {};
  final Map<String, Timer?> _simulatedDeviceTimers = {};

  Timer? _healthCheckTimer;

  final StreamController<Map<String, BleDeviceModel>> _deviceStatesController =
      StreamController<Map<String, BleDeviceModel>>.broadcast();

  final StreamController<RawSensorData> _rawDataController =
      StreamController<RawSensorData>.broadcast();

  BleConnectionManager() {
    _startHealthMonitor();
  }

  Stream<Map<String, BleDeviceModel>> get deviceStatesStream =>
      _deviceStatesController.stream;

  Stream<RawSensorData> get rawDataStream => _rawDataController.stream;

  Map<String, BleDeviceModel> get currentDeviceStates =>
      Map.unmodifiable(_deviceModelsMap);

  /// 1500ms link health monitor measuring packet gap intervals
  void _startHealthMonitor() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      final now = DateTime.now();
      bool stateChanged = false;

      for (final deviceId in _deviceModelsMap.keys) {
        final model = _deviceModelsMap[deviceId]!;
        if (model.connectionState == BleConnectionState.connected) {
          ConnectionHealth newHealth = ConnectionHealth.good;
          if (model.lastPacketTime != null) {
            final gapMs = now.difference(model.lastPacketTime!).inMilliseconds;
            if (gapMs > 15000) {
              newHealth = ConnectionHealth.poor;
            } else if (gapMs > 6000) {
              newHealth = ConnectionHealth.degraded;
            } else if (gapMs > 2500) {
              newHealth = ConnectionHealth.degraded;
            } else {
              newHealth = ConnectionHealth.good;
            }
          }

          if (model.health != newHealth) {
            _deviceModelsMap[deviceId] = model.copyWith(health: newHealth);
            stateChanged = true;
          }
        }
      }

      if (stateChanged && !_deviceStatesController.isClosed) {
        _deviceStatesController.add(Map.unmodifiable(_deviceModelsMap));
      }
    });
  }

  Future<void> connectToDevice(BleDeviceModel model) async {
    final deviceId = model.id;
    _userConnectedDeviceIds.add(deviceId);
    _deviceRetryCounts[deviceId] = 0;
    _cancelReconnectTimer(deviceId);

    _updateState(
      deviceId,
      model.copyWith(
        connectionState: BleConnectionState.connecting,
        health: ConnectionHealth.disconnected,
        retryAttempts: 0,
      ),
    );

    // Simulated device handling
    if (deviceId.startsWith('sim_') || deviceId.startsWith('demo_')) {
      _startSimulatedDevice(model);
      return;
    }

    final device = BluetoothDevice.fromId(deviceId);

    try {
      _connectionStateSubscriptions[deviceId]?.cancel();
      _connectionStateSubscriptions[deviceId] =
          device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          _deviceRetryCounts[deviceId] = 0;
          _cancelReconnectTimer(deviceId);

          _updateState(
            deviceId,
            (_deviceModelsMap[deviceId] ?? model).copyWith(
              connectionState: BleConnectionState.connected,
              health: ConnectionHealth.good,
              retryAttempts: 0,
            ),
          );
          _discoverServicesAndSubscribe(device, model);
        } else if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection(device, model);
        }
      });

      await device.connect(timeout: const Duration(seconds: 10), autoConnect: false);
    } catch (e) {
      if (_userConnectedDeviceIds.contains(deviceId)) {
        _scheduleAutoReconnect(device, model);
      } else {
        _updateState(
          deviceId,
          model.copyWith(
            connectionState: BleConnectionState.disconnected,
            health: ConnectionHealth.disconnected,
          ),
        );
      }
    }
  }

  void _startSimulatedDevice(BleDeviceModel model) {
    final deviceId = model.id;
    _simulatedDeviceTimers[deviceId]?.cancel();

    _updateState(
      deviceId,
      model.copyWith(
        connectionState: BleConnectionState.connected,
        health: ConnectionHealth.good,
        retryAttempts: 0,
      ),
    );

    int simTick = 0;
    // 50Hz simulated telemetry packet emission (20ms interval)
    _simulatedDeviceTimers[deviceId] = Timer.periodic(const Duration(milliseconds: 20), (_) {
      simTick++;
      final now = DateTime.now();
      RawSensorData data;

      if (model.type == DeviceType.verityBand) {
        final hr = (125 + math.sin(simTick / 30.0) * 15).round();
        final accelX = math.sin(simTick * 0.04) * 0.5;
        final accelY = math.cos(simTick * 0.06) * 0.4;
        final accelZ = 9.8 + math.sin(simTick * 0.1) * 0.7;

        data = RawSensorData(
          deviceId: deviceId,
          deviceName: model.name,
          deviceType: DeviceType.verityBand,
          timestamp: now,
          heartRate: (simTick % 50 == 0) ? hr : null,
          accelX: accelX,
          accelY: accelY,
          accelZ: accelZ,
          ppiMs: 480 + (simTick % 20) * 2,
          rawBytes: [0x00, hr, (accelX * 100).toInt() & 0xFF],
        );
      } else {
        final hr = (74 + math.sin(simTick * 0.02) * 6).round();
        final accelX = math.sin(simTick * 0.08) * 1.8;
        final accelY = math.cos(simTick * 0.09) * 1.4;
        final accelZ = 9.8 + math.sin(simTick * 0.05) * 1.1;

        // Construct exact 13-byte Little-Endian binary payload
        final byteData = ByteData(13);
        byteData.setUint8(0, hr);
        byteData.setFloat32(1, accelX, Endian.little);
        byteData.setFloat32(5, accelY, Endian.little);
        byteData.setFloat32(9, accelZ, Endian.little);
        final rawPayload = byteData.buffer.asUint8List();

        data = RawSensorData(
          deviceId: deviceId,
          deviceName: model.name,
          deviceType: DeviceType.watch,
          timestamp: now,
          heartRate: hr,
          accelX: accelX,
          accelY: accelY,
          accelZ: accelZ,
          rawBytes: rawPayload,
        );
      }

      final existing = _deviceModelsMap[deviceId];
      if (existing != null) {
        _deviceModelsMap[deviceId] = existing.copyWith(
          lastPacketTime: now,
          health: ConnectionHealth.good,
          packetsReceived: existing.packetsReceived + 1,
        );
      }
      _rawDataController.add(data);
    });
  }

  void _handleDisconnection(BluetoothDevice device, BleDeviceModel model) {
    final deviceId = model.id;
    if (_userConnectedDeviceIds.contains(deviceId)) {
      // Out of range or dropped connection -> trigger exponential auto-reconnect
      _updateState(
        deviceId,
        (_deviceModelsMap[deviceId] ?? model).copyWith(
          connectionState: BleConnectionState.reconnecting,
          health: ConnectionHealth.disconnected,
        ),
      );
      _scheduleAutoReconnect(device, model);
    } else {
      // Intentional user disconnect
      _updateState(
        deviceId,
        (_deviceModelsMap[deviceId] ?? model).copyWith(
          connectionState: BleConnectionState.disconnected,
          health: ConnectionHealth.disconnected,
          retryAttempts: 0,
        ),
      );
    }
  }

  Future<void> retryDeviceConnection(String deviceId) async {
    final model = _deviceModelsMap[deviceId];
    if (model != null) {
      _userConnectedDeviceIds.add(deviceId);
      _deviceRetryCounts[deviceId] = 0;
      await connectToDevice(model);
    }
  }

  Future<void> disconnectDevice(String deviceId) async {
    _userConnectedDeviceIds.remove(deviceId);
    _deviceRetryCounts[deviceId] = 0;
    _cancelReconnectTimer(deviceId);

    _simulatedDeviceTimers[deviceId]?.cancel();
    _simulatedDeviceTimers.remove(deviceId);

    _connectionStateSubscriptions[deviceId]?.cancel();
    _charNotificationSubscriptions[deviceId]?.cancel();

    if (!deviceId.startsWith('sim_') && !deviceId.startsWith('demo_')) {
      try {
        final device = BluetoothDevice.fromId(deviceId);
        await device.disconnect();
      } catch (_) {}
    }

    final existing = _deviceModelsMap[deviceId];
    if (existing != null) {
      _updateState(
        deviceId,
        existing.copyWith(
          connectionState: BleConnectionState.disconnected,
          health: ConnectionHealth.disconnected,
          retryAttempts: 0,
        ),
      );
    }
  }

  void _cancelReconnectTimer(String deviceId) {
    _deviceReconnectTimers[deviceId]?.cancel();
    _deviceReconnectTimers[deviceId] = null;
  }

  void _scheduleAutoReconnect(
    BluetoothDevice device,
    BleDeviceModel model,
  ) {
    final deviceId = model.id;
    _cancelReconnectTimer(deviceId);

    int currentRetries = _deviceRetryCounts[deviceId] ?? 0;

    if (currentRetries >= maxReconnectAttempts) {
      // Retries exhausted: transition to persistent LOST state
      _updateState(
        deviceId,
        (_deviceModelsMap[deviceId] ?? model).copyWith(
          connectionState: BleConnectionState.lost,
          health: ConnectionHealth.disconnected,
          retryAttempts: currentRetries,
        ),
      );
      return;
    }

    currentRetries++;
    _deviceRetryCounts[deviceId] = currentRetries;

    // Exponential backoff: 2s, 4s, 8s, 16s, 20s...
    int delaySeconds = (baseRetryDelaySeconds * (1 << (currentRetries - 1)))
        .clamp(baseRetryDelaySeconds, maxRetryDelaySeconds);

    _updateState(
      deviceId,
      (_deviceModelsMap[deviceId] ?? model).copyWith(
        connectionState: BleConnectionState.reconnecting,
        health: ConnectionHealth.disconnected,
        retryAttempts: currentRetries,
      ),
    );

    _deviceReconnectTimers[deviceId] = Timer(Duration(seconds: delaySeconds), () async {
      if (!_userConnectedDeviceIds.contains(deviceId)) return;

      final currentState = _deviceModelsMap[deviceId]?.connectionState;
      if (currentState == BleConnectionState.connected) return;

      try {
        await device.connect(timeout: const Duration(seconds: 8), autoConnect: false);
      } catch (_) {
        if (_userConnectedDeviceIds.contains(deviceId)) {
          _scheduleAutoReconnect(device, model);
        }
      }
    });
  }

  Future<void> _discoverServicesAndSubscribe(
    BluetoothDevice device,
    BleDeviceModel model,
  ) async {
    try {
      // 1. Request 512 MTU for high-throughput 50Hz IMU stream
      try {
        await device.requestMtu(512);
      } catch (_) {}

      final services = await device.discoverServices();
      BluetoothCharacteristic? pmdControlChar;

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          final cUuid = characteristic.uuid.toString().toLowerCase();

          if (cUuid.contains('fb005c81')) {
            pmdControlChar = characteristic;
          }

          // Subscriptions for HR & PMD Accelerometer / ESP32 custom characteristic (0xFFE1)
          if (cUuid.contains('2a37') ||
              cUuid.contains('ffe1') ||
              cUuid.contains('fb005c82')) {
            if (characteristic.properties.notify || characteristic.properties.indicate) {
              _charNotificationSubscriptions[model.id + cUuid]?.cancel();
              _charNotificationSubscriptions[model.id + cUuid] =
                  characteristic.onValueReceived.listen((valueBytes) {
                if (valueBytes.isEmpty) return;

                RawSensorData? parsedData;
                if (cUuid.contains('2a37')) {
                  parsedData = PolarVerityParser.parseHeartRate(
                    model.id,
                    model.name,
                    valueBytes,
                  );
                } else if (cUuid.contains('fb005c82')) {
                  parsedData = PolarVerityParser.parsePmdAccel(
                    model.id,
                    model.name,
                    valueBytes,
                  );
                } else if (cUuid.contains('ffe1')) {
                  parsedData = Esp32WatchParser.parseEsp32Payload(
                    model.id,
                    model.name,
                    valueBytes,
                  );
                }

                if (parsedData != null) {
                  final now = DateTime.now();
                  final existing = _deviceModelsMap[model.id];
                  if (existing != null) {
                    _deviceModelsMap[model.id] = existing.copyWith(
                      lastPacketTime: now,
                      health: ConnectionHealth.good,
                      packetsReceived: existing.packetsReceived + 1,
                    );
                  }
                  _rawDataController.add(parsedData);
                }
              });

              // Subscribe to characteristic notifications via CCCD 0x2902
              await characteristic.setNotifyValue(true);
            }
          }
        }
      }

      // If Polar PMD control point is present, request ACC stream
      if (pmdControlChar != null) {
        try {
          await pmdControlChar.write([
            0x02, 0x02, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0x08, 0x00
          ]);
        } catch (_) {}
      }
    } catch (_) {}
  }

  void _updateState(String deviceId, BleDeviceModel updatedModel) {
    _deviceModelsMap[deviceId] = updatedModel;
    if (!_deviceStatesController.isClosed) {
      _deviceStatesController.add(Map.unmodifiable(_deviceModelsMap));
    }
  }

  void dispose() {
    _healthCheckTimer?.cancel();
    for (var timer in _simulatedDeviceTimers.values) {
      timer?.cancel();
    }
    for (var timer in _deviceReconnectTimers.values) {
      timer?.cancel();
    }
    for (var sub in _connectionStateSubscriptions.values) {
      sub.cancel();
    }
    for (var sub in _charNotificationSubscriptions.values) {
      sub.cancel();
    }
    _deviceStatesController.close();
    _rawDataController.close();
  }
}
