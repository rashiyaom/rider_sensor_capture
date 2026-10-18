import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_device_model.dart';
import '../models/raw_sensor_data.dart';
import '../parsers/polar_verity_parser.dart';
import '../parsers/esp32_watch_parser.dart';

class WatchCommand {
  final String deviceId;
  final List<int> bytes;
  const WatchCommand(this.deviceId, this.bytes);
}

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

  final StreamController<List<int>> _watchCommandController =
      StreamController<List<int>>.broadcast();

  final _watchControlController = StreamController<WatchCommand>.broadcast();
  Stream<WatchCommand> get watchControlStream => _watchControlController.stream;

  final Map<String, BluetoothCharacteristic> _esp32RxCharacteristics = {};

  BleConnectionManager() {
    _startHealthMonitor();
  }

  Stream<Map<String, BleDeviceModel>> get deviceStatesStream =>
      _deviceStatesController.stream;

  Stream<RawSensorData> get rawDataStream => _rawDataController.stream;

  Stream<List<int>> get watchCommandStream => _watchCommandController.stream;

  final Set<String> _readyWatchIds = {};
  final Set<String> _controlReadyIds = {};
  final Map<String, DateTime> _lastDiscoveryAttempt = {};
  Future<void> _watchWriteTail = Future.value();
  bool _disposed = false;
  Set<String> get readyWatchIds => Set.unmodifiable(_readyWatchIds);
  bool get isWatchConnected => _readyWatchIds.isNotEmpty;

  Map<String, BleDeviceModel> get currentDeviceStates =>
      Map.unmodifiable(_deviceModelsMap);

  Future<bool> writeToWatch(List<int> bytes, {String? deviceId}) {
    // Capture connection objects now so queued commands cannot cross a reconnect.
    final targets = {for (final id in _readyWatchIds)
      if ((deviceId == null || deviceId == id) && _esp32RxCharacteristics[id] != null) id: _esp32RxCharacteristics[id]!};
    final payload = List<int>.of(bytes);
    final result = _watchWriteTail.then((_) async {
      if (_disposed) return false;
      bool success = false;
      for (final entry in targets.entries) {
        if (!_readyWatchIds.contains(entry.key) ||
            !identical(_esp32RxCharacteristics[entry.key], entry.value)) {
          continue;
        }
        try {
          // Prefer acknowledged GATT writes for control reliability.
          await entry.value.write(payload, withoutResponse: !entry.value.properties.write);
          success = true;
        } catch (error) {
          debugPrint('[BLE] Watch write failed: $error');
        }
      }
      return success;
    });
    _watchWriteTail = result.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }

  /// 1500ms link health monitor measuring packet gap intervals
  void _startHealthMonitor() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      final now = DateTime.now();
      bool stateChanged = false;

      for (final deviceId in _deviceModelsMap.keys) {
        final model = _deviceModelsMap[deviceId]!;
        if (model.connectionState == BleConnectionState.connected) {
          if (model.type == DeviceType.watch && !_controlReadyIds.contains(deviceId) &&
              !deviceId.startsWith('sim_') && !deviceId.startsWith('demo_') &&
              now.difference(_lastDiscoveryAttempt[deviceId] ?? DateTime(2000)).inSeconds >= 5) {
            unawaited(_discoverServicesAndSubscribe(BluetoothDevice.fromId(deviceId), model));
          }
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
        final accelX = math.sin(simTick * 0.08) * 1.8;
        final accelY = math.cos(simTick * 0.09) * 1.4;
        final accelZ = 9.80665 + math.sin(simTick * 0.05) * 1.1;
        final gyroX = math.sin(simTick * 0.05) * 12.0;
        final gyroY = math.cos(simTick * 0.07) * 8.0;
        final gyroZ = math.sin(simTick * 0.03) * 45.0;

        // Construct standard 28-byte Little-Endian binary payload (timestamp + 6 floats)
        final byteData = ByteData(28);
        byteData.setUint32(0, simTick * 20, Endian.little);
        byteData.setFloat32(4, accelX, Endian.little);
        byteData.setFloat32(8, accelY, Endian.little);
        byteData.setFloat32(12, accelZ, Endian.little);
        byteData.setFloat32(16, gyroX, Endian.little);
        byteData.setFloat32(20, gyroY, Endian.little);
        byteData.setFloat32(24, gyroZ, Endian.little);
        final rawPayload = byteData.buffer.asUint8List();

        data = RawSensorData(
          deviceId: deviceId,
          deviceName: model.name,
          deviceType: DeviceType.watch,
          timestamp: now,
          heartRate: null, // Watch is a 6-axis IMU, not a HR band
          accelX: accelX,
          accelY: accelY,
          accelZ: accelZ,
          gyroX: gyroX,
          gyroY: gyroY,
          gyroZ: gyroZ,
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
    _invalidateWatchConnection(deviceId);
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
    _invalidateWatchConnection(deviceId);

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

  final Set<String> _discoveringDeviceIds = {};
  final Map<String, int> _connectionGenerations = {};
  void _invalidateWatchConnection(String deviceId) {
    _connectionGenerations[deviceId] = (_connectionGenerations[deviceId] ?? 0) + 1;
    _esp32RxCharacteristics.remove(deviceId);
    _readyWatchIds.remove(deviceId);
    _controlReadyIds.remove(deviceId);
    final keys = _charNotificationSubscriptions.keys.where((key) => key.startsWith(deviceId)).toList();
    for (final key in keys) { _charNotificationSubscriptions.remove(key)?.cancel(); }
  }

  Future<void> _discoverServicesAndSubscribe(
    BluetoothDevice device,
    BleDeviceModel model,
  ) async {
    final deviceId = model.id;
    if (_discoveringDeviceIds.contains(deviceId)) {
      debugPrint('[BLE] Already discovering services for $deviceId, skipping duplicate run');
      return;
    }
    _discoveringDeviceIds.add(deviceId);
    _lastDiscoveryAttempt[deviceId] = DateTime.now();
    final generation = _connectionGenerations[deviceId] ?? 0;

    try {
      debugPrint('[BLE] Beginning service discovery for ${model.name} ($deviceId)');
      // 1. Connection settling delay for Android GATT stack stability
      await Future.delayed(const Duration(milliseconds: 350));

      // 2. Safely negotiate high-throughput MTU (512)
      try {
        await device.requestMtu(512);
        await Future.delayed(const Duration(milliseconds: 200));
        debugPrint('[BLE] Negotiated MTU for ${model.name}');
      } catch (e) {
        debugPrint('[BLE] MTU negotiation non-fatal notice: $e');
      }

      // 3. Discover GATT services
      final services = await device.discoverServices();
      debugPrint('[BLE] Discovered ${services.length} services for ${model.name}');
      BluetoothCharacteristic? pmdControlChar;
      BluetoothCharacteristic? watchRx;
      bool watchControlSubscribed = false;

      if (_disposed || generation != (_connectionGenerations[deviceId] ?? 0)) return;
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (_disposed || generation != (_connectionGenerations[deviceId] ?? 0)) return;
          final cUuid = characteristic.uuid.toString().toLowerCase();
          final sUuid = service.uuid.toString().toLowerCase();

          if (cUuid.contains('fb005c81')) {
            pmdControlChar = characteristic;
          }

          final isPolarHr = cUuid.contains('2a37');
          final isPolarPmd = cUuid.contains('fb005c82');
          final isEsp32Data = cUuid.contains('ffe1');
          final isEsp32Rx = cUuid.contains('ffe2');
          final isEsp32Ctrl = cUuid.contains('ffe3');
          final isEsp32Fallback = sUuid.contains('ffe0') && !isPolarHr && !isPolarPmd && !isEsp32Rx && !isEsp32Ctrl;

          if (isEsp32Rx && (characteristic.properties.write || characteristic.properties.writeWithoutResponse)) {
            watchRx = characteristic;
            debugPrint('[BLE] Registered ESP32 RX command characteristic 0xFFE2');
          }

          if (isEsp32Ctrl) {
            if (characteristic.properties.notify || characteristic.properties.indicate) {
              _charNotificationSubscriptions[model.id + cUuid]?.cancel();
              _charNotificationSubscriptions[model.id + cUuid] =
                  characteristic.onValueReceived.listen((valueBytes) {
                if (!_disposed && valueBytes.isNotEmpty) {
                  _watchCommandController.add(valueBytes);
                  _watchControlController.add(WatchCommand(model.id, List.of(valueBytes)));
                }
              });
              try {
                await characteristic.setNotifyValue(true);
                await Future.delayed(const Duration(milliseconds: 150));
                watchControlSubscribed = characteristic.isNotifying;
                debugPrint('[BLE] Successfully subscribed to ESP32 Ctrl (0xFFE3)');
              } catch (e) {
                debugPrint('[BLE] Error enabling notifications on Ctrl (0xFFE3): $e');
              }
            }
          }

          // Subscriptions for HR & PMD Accelerometer / ESP32 custom characteristic (0xFFE1 or 0xFFE0 service)
          if (isPolarHr || isPolarPmd || isEsp32Data || isEsp32Fallback) {
            if (characteristic.properties.notify || characteristic.properties.indicate) {
              _charNotificationSubscriptions[model.id + cUuid]?.cancel();
              _charNotificationSubscriptions[model.id + cUuid] =
                  characteristic.onValueReceived.listen((valueBytes) {
                if (valueBytes.isEmpty) return;

                RawSensorData? parsedData;
                if (isPolarHr) {
                  parsedData = PolarVerityParser.parseHeartRate(
                    model.id,
                    model.name,
                    valueBytes,
                  );
                } else if (isPolarPmd) {
                  parsedData = PolarVerityParser.parsePmdAccel(
                    model.id,
                    model.name,
                    valueBytes,
                  );
                } else if (isEsp32Data || isEsp32Fallback) {
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
              try {
                await characteristic.setNotifyValue(true);
                await Future.delayed(const Duration(milliseconds: 150));
                debugPrint('[BLE] Successfully subscribed to Data Characteristic: $cUuid for ${model.name}');
              } catch (e) {
                debugPrint('[BLE] Error enabling notifications on $cUuid: $e');
              }
            }
          }
        }
      }

      if (!_disposed && generation == (_connectionGenerations[deviceId] ?? 0) && watchRx != null &&
          _deviceModelsMap[deviceId]?.connectionState == BleConnectionState.connected) {
        _esp32RxCharacteristics[deviceId] = watchRx;
        _readyWatchIds.add(deviceId);
        if (watchControlSubscribed) _controlReadyIds.add(deviceId);
        // RX stays usable even while the control subscription is being retried.
        // Transport connected happens before discovery; notify again when both directions are ready.
        _updateState(deviceId, _deviceModelsMap[deviceId]!);
      }

      // If Polar PMD control point is present, request ACC stream
      if (pmdControlChar != null) {
        try {
          await pmdControlChar.write([
            0x02, 0x02, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0x08, 0x00
          ]);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[BLE] Exception during _discoverServicesAndSubscribe for ${model.name}: $e');
    } finally {
      _discoveringDeviceIds.remove(deviceId);
      if (!_disposed && generation != (_connectionGenerations[deviceId] ?? 0) &&
          _deviceModelsMap[deviceId]?.connectionState == BleConnectionState.connected) {
        unawaited(_discoverServicesAndSubscribe(device, model));
      }
    }
  }

  Future<void> repairWatchConnection(String deviceId) async {
    final model = _deviceModelsMap[deviceId];
    if (model == null || model.connectionState != BleConnectionState.connected) return;
    final device = BluetoothDevice.fromId(deviceId);
    _invalidateWatchConnection(deviceId);
    _updateState(deviceId, model);
    // Firmware updates can leave Android holding a previous GATT table.
    if (defaultTargetPlatform == TargetPlatform.android) {
      try { await device.clearGattCache(); } catch (error) { debugPrint('[BLE] Cache refresh: $error'); }
    }
    await _discoverServicesAndSubscribe(device, model);
  }

  void _updateState(String deviceId, BleDeviceModel updatedModel) {
    _deviceModelsMap[deviceId] = updatedModel;
    if (!_deviceStatesController.isClosed) {
      _deviceStatesController.add(Map.unmodifiable(_deviceModelsMap));
    }
  }

  void dispose() {
    _disposed = true;
    _readyWatchIds.clear();
    _controlReadyIds.clear();
    _esp32RxCharacteristics.clear();
    _watchCommandController.close();
    _watchControlController.close();
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
