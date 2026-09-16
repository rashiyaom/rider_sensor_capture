import 'dart:async';
import 'package:drift/drift.dart';
import '../local_db/database.dart';
import '../../ble/models/raw_sensor_data.dart';
import '../../providers/db_providers.dart';
import 'sensor_repository.dart';

class SensorRepositoryImpl implements SensorRepository {
  final AppDatabase _db;
  final Map<String, int> _sequenceCounters = {};
  final List<RawSensorData> _buffer = [];
  Timer? _flushTimer;
  DateTime? _lastWriteTime;

  int _totalRowCount = 0;
  final Map<String, int> _deviceCounts = {};
  int? _activeEventId;
  int? _activeTripId;

  final StreamController<DbWriteStats> _statsController =
      StreamController<DbWriteStats>.broadcast();

  SensorRepositoryImpl(this._db) {
    _initCountersFromDb();
    _flushTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _flushBuffer();
    });
  }

  void _emitStats() {
    if (!_statsController.isClosed) {
      _statsController.add(
        DbWriteStats(
          totalRows: _totalRowCount,
          deviceCounts: Map.unmodifiable(_deviceCounts),
          lastWriteTime: _lastWriteTime,
        ),
      );
    }
  }

  Future<void> _initCountersFromDb() async {
    try {
      final countExp = _db.sensorReadings.id.count();
      final query = _db.selectOnly(_db.sensorReadings)..addColumns([countExp]);
      final result = await query.map((row) => row.read(countExp)).getSingleOrNull();
      _totalRowCount = result ?? 0;

      final deviceCol = _db.sensorReadings.deviceId;
      final devQuery = _db.selectOnly(_db.sensorReadings)
        ..addColumns([deviceCol, countExp])
        ..groupBy([deviceCol]);

      final devRows = await devQuery.get();
      _deviceCounts.clear();
      for (var row in devRows) {
        final dev = row.read(deviceCol);
        final c = row.read(countExp);
        if (dev != null && c != null) {
          _deviceCounts[dev] = c;
        }
      }
      _emitStats();
    } catch (_) {}
  }

  @override
  Stream<DbWriteStats> watchStats() async* {
    yield DbWriteStats(
      totalRows: _totalRowCount,
      deviceCounts: Map.unmodifiable(_deviceCounts),
      lastWriteTime: _lastWriteTime,
    );
    yield* _statsController.stream;
  }

  @override
  void setActiveEventId(int? eventId) {
    _activeEventId = eventId;
  }

  @override
  int? get activeEventId => _activeEventId;

  @override
  void setActiveTripId(int? tripId) {
    _activeTripId = tripId;
  }

  @override
  int? get activeTripId => _activeTripId;

  @override
  Future<void> insertReading(RawSensorData data) async {
    _buffer.add(data);
    if (_buffer.length >= 25) {
      await _flushBuffer();
    }
  }

  @override
  Future<int> getLastSequenceNoForDevice(String deviceId) async {
    if (_sequenceCounters.containsKey(deviceId)) {
      return _sequenceCounters[deviceId]!;
    }
    final maxSeqExp = _db.sensorReadings.sequenceNo.max();
    final query = _db.selectOnly(_db.sensorReadings)
      ..where(_db.sensorReadings.deviceId.equals(deviceId))
      ..addColumns([maxSeqExp]);
    final row = await query.getSingleOrNull();
    final maxVal = row?.read(maxSeqExp) ?? 0;
    _sequenceCounters[deviceId] = maxVal;
    return maxVal;
  }

  @override
  Future<void> insertReadingsBatch(List<RawSensorData> dataList) async {
    if (dataList.isEmpty) return;

    final companions = <SensorReadingsCompanion>[];

    for (final data in dataList) {
      if (!_sequenceCounters.containsKey(data.deviceId)) {
        await getLastSequenceNoForDevice(data.deviceId);
      }

      final currentSeq = (_sequenceCounters[data.deviceId] ?? 0) + 1;
      _sequenceCounters[data.deviceId] = currentSeq;

      String sType = 'unknown';
      if (data.heartRate != null && data.accelX != null) {
        sType = 'combined';
      } else if (data.heartRate != null) {
        sType = 'hr';
      } else if (data.accelX != null) {
        sType = 'imu';
      } else if (data.ppiMs != null) {
        sType = 'ppi';
      }

      companions.add(
        SensorReadingsCompanion.insert(
          deviceId: data.deviceId,
          deviceType: data.deviceType.name,
          sequenceNo: currentSeq,
          timestampUtc: data.timestamp.toUtc(),
          sensorType: sType,
          mountLocation: Value(data.mountLocation),
          eventId: Value(_activeEventId), // Tag with current active event
          tripId: Value(_activeTripId),   // Tag with current active journey/trip
          heartRate: Value(data.heartRate),
          accelX: Value(data.accelX),
          accelY: Value(data.accelY),
          accelZ: Value(data.accelZ),
          gyroX: Value(data.gyroX),
          gyroY: Value(data.gyroY),
          gyroZ: Value(data.gyroZ),
          ppiMs: Value(data.ppiMs),
          rawPayload: Value(data.rawBytes.toString()),
        ),
      );

      _deviceCounts[data.deviceId] = (_deviceCounts[data.deviceId] ?? 0) + 1;
    }

    _totalRowCount += dataList.length;
    _lastWriteTime = DateTime.now();

    await _db.batch((batch) {
      batch.insertAll(_db.sensorReadings, companions);
    });

    _emitStats();
  }

  Future<void> _flushBuffer() async {
    if (_buffer.isEmpty) return;

    final batchToInsert = List<RawSensorData>.from(_buffer);
    _buffer.clear();
    await insertReadingsBatch(batchToInsert);
  }

  @override
  Future<void> flushPendingBuffer() => _flushBuffer();

  @override
  Stream<List<SensorReading>> watchRecentReadings({int limit = 50}) {
    return (_db.select(_db.sensorReadings)
          ..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .watch();
  }

  @override
  Stream<List<SensorReading>> watchReadingsForDevice(String deviceId, {int limit = 50}) {
    return (_db.select(_db.sensorReadings)
          ..where((t) => t.deviceId.equals(deviceId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .watch();
  }

  @override
  Stream<List<SensorReading>> watchReadingsForEvent(int eventId) {
    return (_db.select(_db.sensorReadings)
          ..where((t) => t.eventId.equals(eventId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc)
          ]))
        .watch();
  }

  @override
  Future<int> getReadingCountForEvent(int eventId) async {
    final countExp = _db.sensorReadings.id.count();
    final query = _db.selectOnly(_db.sensorReadings)
      ..where(_db.sensorReadings.eventId.equals(eventId))
      ..addColumns([countExp]);
    final res = await query.map((row) => row.read(countExp)).getSingle();
    return res ?? 0;
  }

  @override
  Future<int> getTotalCount() async {
    final countExp = _db.sensorReadings.id.count();
    final query = _db.selectOnly(_db.sensorReadings)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingleOrNull();
    _totalRowCount = result ?? 0;
    return _totalRowCount;
  }

  @override
  Future<Map<String, int>> getCountPerDevice() async {
    final countExp = _db.sensorReadings.id.count();
    final deviceCol = _db.sensorReadings.deviceId;

    final query = _db.selectOnly(_db.sensorReadings)
      ..addColumns([deviceCol, countExp])
      ..groupBy([deviceCol]);

    final rows = await query.get();
    final result = <String, int>{};
    for (var row in rows) {
      final dev = row.read(deviceCol);
      final c = row.read(countExp);
      if (dev != null && c != null) {
        result[dev] = c;
        _deviceCounts[dev] = c;
      }
    }
    return Map.unmodifiable(result);
  }

  @override
  Future<DateTime?> getLastWriteTime() async => _lastWriteTime;

  @override
  Future<int> createEventRecord(EventRecordsCompanion event) async {
    return await _db.into(_db.eventRecords).insert(event);
  }

  @override
  Future<void> updateEventRecord(EventRecord event) async {
    await _db.update(_db.eventRecords).replace(event);
  }

  @override
  Stream<List<EventRecord>> watchAllEvents() {
    return (_db.select(_db.eventRecords)
          ..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // ── Trip / Journey Persistence Methods ──
  @override
  Future<int> createTrip(TripsCompanion trip) async {
    return await _db.into(_db.trips).insert(trip);
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    await _db.update(_db.trips).replace(trip);
  }

  @override
  Future<Trip?> getTrip(int tripId) async {
    return await (_db.select(_db.trips)..where((t) => t.id.equals(tripId))).getSingleOrNull();
  }

  @override
  Stream<List<Trip>> watchAllTrips() {
    return (_db.select(_db.trips)
          ..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  @override
  Future<void> deleteTrip(int tripId) async {
    await (_db.delete(_db.sensorReadings)..where((t) => t.tripId.equals(tripId))).go();
    await (_db.delete(_db.eventRecords)..where((t) => t.tripId.equals(tripId))).go();
    await (_db.delete(_db.trips)..where((t) => t.id.equals(tripId))).go();
    await _initCountersFromDb();
  }

  @override
  Future<int> getReadingCountForTrip(int tripId) async {
    final countExp = _db.sensorReadings.id.count();
    final query = _db.selectOnly(_db.sensorReadings)
      ..addColumns([countExp])
      ..where(_db.sensorReadings.tripId.equals(tripId));
    final row = await query.getSingleOrNull();
    return row?.read(countExp) ?? 0;
  }

  @override
  Future<int> getEventCountForTrip(int tripId) async {
    final countExp = _db.eventRecords.id.count();
    final query = _db.selectOnly(_db.eventRecords)
      ..addColumns([countExp])
      ..where(_db.eventRecords.tripId.equals(tripId));
    final row = await query.getSingleOrNull();
    return row?.read(countExp) ?? 0;
  }

  @override
  Future<void> deleteAllReadings() async {
    await _db.delete(_db.sensorReadings).go();
    _totalRowCount = 0;
    _deviceCounts.clear();
    _sequenceCounters.clear();
    _lastWriteTime = null;
    _emitStats();
  }

  @override
  Future<void> deleteEvent(int eventId) async {
    await (_db.delete(_db.sensorReadings)
          ..where((t) => t.eventId.equals(eventId)))
        .go();
    await (_db.delete(_db.eventRecords)
          ..where((t) => t.id.equals(eventId)))
        .go();
    // Recount totals from DB after deletion
    await _initCountersFromDb();
  }

  @override
  void dispose() {
    _flushTimer?.cancel();
    _flushBuffer();
    _statsController.close();
  }
}
