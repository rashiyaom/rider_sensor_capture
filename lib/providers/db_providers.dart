import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_db/database.dart';
import '../data/repositories/sensor_repository.dart';
import '../data/repositories/sensor_repository_impl.dart';
import 'ble_providers.dart';

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

// Bridge provider: streams raw sensor packets from BLE connection manager directly to database
final bleToDbBridgeProvider = Provider<void>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  final rawDataAsync = ref.watch(rawSensorDataStreamProvider);

  rawDataAsync.whenData((data) {
    repo.insertReading(data);
  });
});

// Periodic write statistics provider
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

final dbWriteStatsStreamProvider = StreamProvider.autoDispose<DbWriteStats>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  return Stream.periodic(const Duration(milliseconds: 500)).asyncMap((_) async {
    final total = await repo.getTotalCount();
    final counts = await repo.getCountPerDevice();
    final lastTime = await repo.getLastWriteTime();
    return DbWriteStats(
      totalRows: total,
      deviceCounts: counts,
      lastWriteTime: lastTime,
    );
  });
});
