import 'dart:async';
import 'package:drift/drift.dart';
import '../local_db/database.dart';
import '../../ble/models/raw_sensor_data.dart';
import 'sensor_repository.dart';

class SensorRepositoryImpl implements SensorRepository {
  final AppDatabase _db;
  final Map<String, int> _sequenceCounters = {};
  final List<RawSensorData> _buffer = [];
  Timer? _flushTimer;
  DateTime? _lastWriteTime;
  int? _activeEventId;

  int _totalRowCount = 0;
  final Map<String, int> _deviceCounts = {};
  bool _countsInitialized = false;

  SensorRepositoryImpl(this._db) {
    _initCountersFromDb();
    _flushTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _flushBuffer();
    });
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

      final rows = await devQuery.get();
      for (var row in rows) {
        final dev = row.read(deviceCol);
        final c = row.read(countExp);
        if (dev != null && c != null) {
          _deviceCounts[dev] = c;
        }
      }
      _countsInitialized = true;
    } catch (_) {}
  }

  @override
  void setActiveEventId(int? eventId) {
    _activeEventId = eventId;
  }

  @override
  int? get activeEventId => _activeEventId;

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
          eventId: Value(_activeEventId), // Tag with current active event
          heartRate: Value(data.heartRate),
          accelX: Value(data.accelX),
          accelY: Value(data.accelY),
          accelZ: Value(data.accelZ),
          ppiMs: Value(data.ppiMs),
          rawPayload: Value(data.rawBytes.toString()),
        ),
      );

      _deviceCounts[data.deviceId] = (_deviceCounts[data.deviceId] ?? 0) + 1;
    }

    _totalRowCount += dataList.length;

    await _db.batch((batch) {
      batch.insertAll(_db.sensorReadings, companions);
    });

    _lastWriteTime = DateTime.now();
  }

  Future<void> _flushBuffer() async {
    if (_buffer.isEmpty) return;

    final batchToInsert = List<RawSensorData>.from(_buffer);
    _buffer.clear();
    await insertReadingsBatch(batchToInsert);
  }

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
    if (_countsInitialized) return _totalRowCount;
    final countExp = _db.sensorReadings.id.count();
    final query = _db.selectOnly(_db.sensorReadings)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    _totalRowCount = result ?? 0;
    _countsInitialized = true;
    return _totalRowCount;
  }

  @override
  Future<Map<String, int>> getCountPerDevice() async {
    if (_countsInitialized) return Map.unmodifiable(_deviceCounts);
    final countExp = _db.sensorReadings.id.count();
    final deviceCol = _db.sensorReadings.deviceId;

    final query = _db.selectOnly(_db.sensorReadings)
      ..addColumns([deviceCol, countExp])
      ..groupBy([deviceCol]);

    final rows = await query.get();
    for (var row in rows) {
      final dev = row.read(deviceCol);
      final c = row.read(countExp);
      if (dev != null && c != null) {
        _deviceCounts[dev] = c;
      }
    }
    _countsInitialized = true;
    return Map.unmodifiable(_deviceCounts);
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

  @override
  void dispose() {
    _flushTimer?.cancel();
    _flushBuffer();
  }
}
