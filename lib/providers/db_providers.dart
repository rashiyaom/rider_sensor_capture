import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ble/models/ble_device_model.dart';
import '../data/local_db/database.dart';
import '../data/repositories/sensor_repository.dart';
import '../data/repositories/sensor_repository_impl.dart';
import 'ble_providers.dart';
import 'ride_recording_provider.dart';

// Database Singleton Provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Sensor Repository Provider
final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = SensorRepositoryImpl(db);
  ref.onDispose(() => repo.dispose());
  return repo;
});

// Bridge provider: streams raw sensor packets from BLE connection manager directly to database ONLY when ride recording is actively started
final bleToDbBridgeProvider = Provider<void>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  final isRecording = ref.watch(isRideRecordingActiveProvider);
  final rawDataAsync = ref.watch(rawSensorDataStreamProvider);
  final mountMap = ref.watch(deviceMountLocationMapProvider);

  rawDataAsync.whenData((data) {
    if (isRecording) {
      final mountLoc = mountMap[data.deviceId] ??
          (data.deviceType == DeviceType.verityBand
              ? 'forearm'
              : (data.mountLocation.isNotEmpty ? data.mountLocation : 'fork'));
      repo.insertReading(data.copyWith(mountLocation: mountLoc));
      ref.read(rideRecordingProvider.notifier).incrementRowCount(1);
    }
  });
});

// Real-time write statistics model
class DbWriteStats {
  final int totalRows;
  final Map<String, int> deviceCounts;
  final DateTime? lastWriteTime;

  const DbWriteStats({
    this.totalRows = 0,
    this.deviceCounts = const {},
    this.lastWriteTime,
  });
}

/// Real-time SQLite statistics stream updating instantly on every batch insert
final dbWriteStatsStreamProvider = StreamProvider.autoDispose<DbWriteStats>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.watchStats();
});
