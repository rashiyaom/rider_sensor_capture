import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ble/models/ble_device_model.dart';
import '../ble/models/raw_sensor_data.dart';
import '../ble/services/ble_scanner.dart';
import '../ble/services/ble_connection_manager.dart';
import '../ble/services/ble_permission_service.dart';

// Singletons for BleScanner and BleConnectionManager
final bleScannerProvider = Provider<BleScanner>((ref) {
  final scanner = BleScanner();
  ref.onDispose(() => scanner.dispose());
  return scanner;
});

final bleConnectionManagerProvider = Provider<BleConnectionManager>((ref) {
  final manager = BleConnectionManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

// Permission state provider
final blePermissionsGrantedProvider = FutureProvider<bool>((ref) async {
  return await BlePermissionService.hasBlePermissions();
});

// Discovered Devices stream provider
final discoveredDevicesStreamProvider = StreamProvider<List<BleDeviceModel>>((ref) {
  final scanner = ref.watch(bleScannerProvider);
  return scanner.discoveredDevicesStream;
});

// Connection States map stream provider
final connectionStatesStreamProvider =
    StreamProvider<Map<String, BleDeviceModel>>((ref) {
  final manager = ref.watch(bleConnectionManagerProvider);
  return manager.deviceStatesStream;
});

// Raw Sensor Data stream provider
final rawSensorDataStreamProvider = StreamProvider<RawSensorData>((ref) {
  final manager = ref.watch(bleConnectionManagerProvider);
  return manager.rawDataStream;
});
