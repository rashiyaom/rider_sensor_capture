import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ble/models/ble_device_model.dart';
import '../data/local_db/database.dart';
import '../data/repositories/sensor_repository.dart';
import '../data/repositories/sensor_repository_impl.dart';
import 'ble_providers.dart';
import 'ride_recording_provider.dart';
import 'sample_rate_provider.dart';

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

// Per-device last write time — used to enforce user-selected sample interval.
final _deviceLastWriteMap = <String, DateTime>{};

// Bridge provider: streams raw sensor packets from BLE to database, with
// optional user-selectable sample-rate decimation.
final bleToDbBridgeProvider = Provider<void>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  final isRecording = ref.watch(isRideRecordingActiveProvider);
  final rawDataAsync = ref.watch(rawSensorDataStreamProvider);
  final mountMap = ref.watch(deviceMountLocationMapProvider);
  final intervalSec = ref.watch(sampleIntervalSecondsProvider);

  rawDataAsync.whenData((data) {
    if (!isRecording) return;

    // Throttle: skip packet if it arrives before the interval has elapsed
    final now = DateTime.now();
    final last = _deviceLastWriteMap[data.deviceId];
    if (last != null && intervalSec > 0.02) {
      final elapsed = now.difference(last).inMicroseconds / 1e6;
      if (elapsed < intervalSec) return; // drop packet
    }
    _deviceLastWriteMap[data.deviceId] = now;

    final mountLoc = mountMap[data.deviceId] ??
        (data.deviceType == DeviceType.verityBand
            ? 'forearm'
            : (data.mountLocation.isNotEmpty ? data.mountLocation : 'fork'));
    repo.insertReading(data.copyWith(mountLocation: mountLoc));
    ref.read(rideRecordingProvider.notifier).incrementRowCount(1);
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
