import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ble/models/ble_device_model.dart';
import '../data/local_db/database.dart';
import '../data/repositories/sensor_repository.dart';
import '../data/repositories/sensor_repository_impl.dart';
import '../features/trips/trip_controller.dart';
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

// Track auto-assigned watch wrist side (Watch 1 -> left_hand, Watch 2 -> right_hand)
final _autoAssignedWatchHands = <String, String>{};

// Bridge provider: streams raw sensor packets from BLE to database, with
// optional user-selectable sample-rate decimation.
final bleToDbBridgeProvider = Provider<void>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  final isRecording = ref.watch(isRideRecordingActiveProvider);
  final rawDataAsync = ref.watch(rawSensorDataStreamProvider);
  final mountMap = ref.watch(deviceMountLocationMapProvider);
  final intervalSec = ref.watch(sampleIntervalSecondsProvider);

  ref.onDispose(() {
    _deviceLastWriteMap.clear();
  });

  rawDataAsync.whenData((data) {
    if (!isRecording) {
      if (_deviceLastWriteMap.isNotEmpty) {
        _deviceLastWriteMap.clear();
      }
      return;
    }

    // Throttle: skip packet if it arrives before the interval has elapsed
    // (Bypassed during active labeled events so ML training bounding boxes retain 50Hz fidelity)
    final isActiveEvent = repo.activeEventId != null;
    final now = DateTime.now();
    final last = _deviceLastWriteMap[data.deviceId];
    if (!isActiveEvent && last != null && intervalSec > 0.02) {
      final elapsed = now.difference(last).inMicroseconds / 1e6;
      if (elapsed < intervalSec) return; // drop packet
    }
    _deviceLastWriteMap[data.deviceId] = now;

    // Resolve mount location:
    // 1. Explicit user selection in Devices tab
    // 2. Forearm for Verity Sense optical band
    // 3. Dual-watch auto-assignment: 1st ESP watch -> left_hand, 2nd ESP watch -> right_hand
    String mountLoc;
    if (mountMap.containsKey(data.deviceId)) {
      mountLoc = mountMap[data.deviceId]!;
    } else if (data.deviceType == DeviceType.verityBand) {
      mountLoc = 'forearm';
    } else {
      if (!_autoAssignedWatchHands.containsKey(data.deviceId)) {
        final idLower = data.deviceId.toLowerCase();
        final nameLower = data.deviceName.toLowerCase();
        if (idLower.contains('right') || nameLower.contains('right')) {
          _autoAssignedWatchHands[data.deviceId] = 'right_hand';
        } else if (idLower.contains('left') || nameLower.contains('left')) {
          _autoAssignedWatchHands[data.deviceId] = 'left_hand';
        } else if (!_autoAssignedWatchHands.values.contains('left_hand')) {
          _autoAssignedWatchHands[data.deviceId] = 'left_hand';
        } else if (!_autoAssignedWatchHands.values.contains('right_hand')) {
          _autoAssignedWatchHands[data.deviceId] = 'right_hand';
        } else {
          _autoAssignedWatchHands[data.deviceId] = 'left_hand';
        }
      }
      mountLoc = _autoAssignedWatchHands[data.deviceId]!;
    }

    repo.insertReading(data.copyWith(mountLocation: mountLoc));
    ref.read(rideRecordingProvider.notifier).incrementRowCount(1);
    ref.read(tripControllerProvider.notifier).incrementSensorRows(1);
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

/// BLE sequence number continuity & quality stats provider for a given trip
final tripBleQualityProvider = FutureProvider.family<BleQualityStats, int>((ref, tripId) async {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.getTripBleQuality(tripId);
});
