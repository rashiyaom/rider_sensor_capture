import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_device_model.dart';
import '../parsers/esp32_watch_parser.dart';

class BleScanner {
  final Map<String, BleDeviceModel> _discoveredDevicesMap = {};
  final StreamController<List<BleDeviceModel>> _discoveredDevicesController =
      StreamController<List<BleDeviceModel>>.broadcast();

  StreamSubscription? _scanSubscription;
  bool _demoMode = false;

  BleScanner() {
    refreshConnectedAndSystemDevices();
  }

  Stream<List<BleDeviceModel>> get discoveredDevicesStream =>
      _discoveredDevicesController.stream;

  List<BleDeviceModel> get currentDiscoveredDevices =>
      _discoveredDevicesMap.values.toList();

  bool get isDemoMode => _demoMode;

  void _notifyListeners() {
    if (!_discoveredDevicesController.isClosed) {
      _discoveredDevicesController.add(_discoveredDevicesMap.values.toList());
    }
  }

  void toggleDemoDevices(bool enable) {
    _demoMode = enable;
    if (!enable) {
      _discoveredDevicesMap.removeWhere((key, _) => key.startsWith('sim_'));
      _notifyListeners();
    } else {
      _addDemoDevices();
    }
  }

  void _addDemoDevices() {
    final now = DateTime.now();
    _discoveredDevicesMap['sim_verity_1'] = BleDeviceModel(
      id: 'sim_verity_1',
      name: 'Polar Verity Sense [Demo]',
      type: DeviceType.verityBand,
      rssi: -58,
      lastSeen: now,
    );
    _discoveredDevicesMap['sim_watch_1'] = BleDeviceModel(
      id: 'sim_watch_1',
      name: '${Esp32WatchParser.esp32DeviceName} [Demo]',
      type: DeviceType.watch,
      rssi: -64,
      lastSeen: now,
    );
    _notifyListeners();
  }

  /// Helper to check if a device has a real, identifiable name
  static bool isValidNamedDevice(String? name) {
    if (name == null) return false;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    if (lower == 'unknown' ||
        lower == 'unknown device' ||
        lower == 'null' ||
        lower == 'n/a') {
      return false;
    }
    return true;
  }

  Future<void> refreshConnectedAndSystemDevices() async {
    if (!kIsWeb) {
      try {
        // 1. Query devices already connected to this app
        for (final device in FlutterBluePlus.connectedDevices) {
          final deviceName = device.platformName.isNotEmpty
              ? device.platformName
              : (device.advName.isNotEmpty ? device.advName : '');

          if (!isValidNamedDevice(deviceName)) continue;

          final deviceId = device.remoteId.str;
          final type = BleDeviceModel.inferDeviceType(deviceName);

          _discoveredDevicesMap[deviceId] = BleDeviceModel(
            id: deviceId,
            name: deviceName,
            type: type,
            rssi: -55,
            lastSeen: DateTime.now(),
            connectionState: BleConnectionState.connected,
          );
        }

        // 2. Query system bonded/connected devices
        try {
          final systemDevices = await FlutterBluePlus.systemDevices([
            Guid(Esp32WatchParser.esp32ServiceUuid),
          ]);
          for (final device in systemDevices) {
            final deviceName = device.platformName.isNotEmpty
                ? device.platformName
                : (device.advName.isNotEmpty ? device.advName : '');

            if (!isValidNamedDevice(deviceName)) continue;

            final deviceId = device.remoteId.str;
            final type = BleDeviceModel.inferDeviceType(deviceName);

            _discoveredDevicesMap.putIfAbsent(
              deviceId,
              () => BleDeviceModel(
                id: deviceId,
                name: deviceName,
                type: type,
                rssi: -65,
                lastSeen: DateTime.now(),
              ),
            );
          }
        } catch (_) {}
      } catch (_) {}
    }

    if (_demoMode) {
      _addDemoDevices();
    } else {
      _notifyListeners();
    }
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 15)}) async {
    _scanSubscription?.cancel();
    _discoveredDevicesMap.clear();

    await refreshConnectedAndSystemDevices();

    if (kIsWeb) return;

    try {
      await FlutterBluePlus.startScan(
        timeout: timeout,
      );
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          final deviceName = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : (r.advertisementData.advName.isNotEmpty
                  ? r.advertisementData.advName
                  : '');

          // Strictly filter out any devices without a real, human-readable name
          if (!isValidNamedDevice(deviceName)) {
            continue;
          }

          final deviceId = r.device.remoteId.str;
          final type = BleDeviceModel.inferDeviceType(deviceName);

          _discoveredDevicesMap[deviceId] = BleDeviceModel(
            id: deviceId,
            name: deviceName,
            type: type,
            rssi: r.rssi,
            lastSeen: DateTime.now(),
          );
        }
        _notifyListeners();
      });
    } catch (e) {
      // Ignore scan exceptions in non-mobile environments or if Bluetooth disabled
    }
  }

  Future<void> stopScan() async {
    if (!kIsWeb) {
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}
    }
    _scanSubscription?.cancel();
  }

  void dispose() {
    stopScan();
    _discoveredDevicesController.close();
  }
}
