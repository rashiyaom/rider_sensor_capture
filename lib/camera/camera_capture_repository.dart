import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/local_db/database.dart';
import '../data/repositories/sensor_repository.dart';

const int kCaptureEventLinkWindowSeconds = 10;

/// Saves UVC JPEGs and their ordered trip/event manifest as one operation.
class CameraCaptureRepository {
  CameraCaptureRepository(this._db, this._sensorRepo, {this._storageRoot});

  final AppDatabase _db;
  final SensorRepository _sensorRepo;
  final Directory? _storageRoot;
  final Map<String, int> _sequenceCounters = {};

  Future<CameraCapture> saveJpeg({
    required Uint8List bytes,
    required String deviceId,
    required int width,
    required int height,
    DateTime? capturedAtUtc,
    String trigger = 'manual',
  }) async {
    if (bytes.length < 4 ||
        bytes[0] != 0xff ||
        bytes[1] != 0xd8 ||
        bytes[bytes.length - 2] != 0xff ||
        bytes[bytes.length - 1] != 0xd9) {
      throw const FormatException('Camera frame is not a complete JPEG');
    }
    if (deviceId.trim().isEmpty) {
      throw ArgumentError.value(deviceId, 'deviceId', 'must not be empty');
    }
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Camera dimensions must be positive');
    }

    final captured = (capturedAtUtc ?? DateTime.now()).toUtc();
    final received = DateTime.now().toUtc();
    final normalizedDeviceId = deviceId.trim();
    final sequenceNo = await _nextSequence(normalizedDeviceId);
    final tripId = _sensorRepo.activeTripId;
    final eventId = await _resolveLinkedEventId(captured, tripId);
    final captureKey =
        '$normalizedDeviceId:$sequenceNo:${captured.microsecondsSinceEpoch}';

    final root =
        _storageRoot ??
        Directory(
          p.join(
            (await getApplicationDocumentsDirectory()).path,
            'camera_captures',
          ),
        );
    final tripFolder = tripId == null
        ? 'unassigned'
        : 'trip_${tripId.toString().padLeft(6, '0')}';
    final dayFolder = _dayFolder(captured);
    final targetDir = Directory(p.join(root.path, tripFolder, dayFolder));
    await targetDir.create(recursive: true);

    final safeDevice = normalizedDeviceId
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        .toLowerCase();
    final fileName =
        '${safeDevice}_${sequenceNo.toString().padLeft(8, '0')}_${_compactUtc(captured)}.jpg';
    final target = File(p.join(targetDir.path, fileName));
    final temporary = File('${target.path}.partial');

    try {
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(target.path);

      final rowId = await _db
          .into(_db.cameraCaptures)
          .insert(
            CameraCapturesCompanion.insert(
              captureKey: captureKey,
              deviceId: normalizedDeviceId,
              sequenceNo: sequenceNo,
              capturedAtUtc: captured,
              receivedAtUtc: received,
              tripId: Value(tripId),
              linkedEventId: Value(eventId),
              filePath: target.path,
              width: width,
              height: height,
              byteLength: bytes.length,
              sha256: sha256.convert(bytes).toString(),
              trigger: Value(trigger),
            ),
          );
      return await (_db.select(
        _db.cameraCaptures,
      )..where((t) => t.id.equals(rowId))).getSingle();
    } catch (_) {
      if (await temporary.exists()) await temporary.delete();
      if (await target.exists()) await target.delete();
      _sequenceCounters[normalizedDeviceId] = sequenceNo - 1;
      rethrow;
    }
  }

  Future<int> _nextSequence(String deviceId) async {
    var current = _sequenceCounters[deviceId];
    if (current == null) {
      final maxSequence = _db.cameraCaptures.sequenceNo.max();
      final row =
          await (_db.selectOnly(_db.cameraCaptures)
                ..where(_db.cameraCaptures.deviceId.equals(deviceId))
                ..addColumns([maxSequence]))
              .getSingleOrNull();
      current = row?.read(maxSequence) ?? 0;
    }
    final next = current + 1;
    _sequenceCounters[deviceId] = next;
    return next;
  }

  Future<int?> _resolveLinkedEventId(DateTime captured, int? tripId) async {
    final active = _sensorRepo.activeEventId;
    if (active != null) return active;

    final windowStart = captured.subtract(
      const Duration(seconds: kCaptureEventLinkWindowSeconds),
    );
    final windowEnd = captured.add(
      const Duration(seconds: kCaptureEventLinkWindowSeconds),
    );
    var query = _db.select(_db.eventRecords)
      ..where(
        (t) =>
            t.status.equals('completed') &
            t.endTimestamp.isBiggerOrEqualValue(windowStart) &
            t.startTimestamp.isSmallerOrEqualValue(windowEnd),
      );
    if (tripId != null) {
      query = query..where((t) => t.tripId.equals(tripId));
    }
    final rows =
        await (query
              ..orderBy([(t) => OrderingTerm.desc(t.endTimestamp)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.id;
  }

  Stream<List<CameraCapture>> watchRecent({int limit = 50}) {
    return (_db.select(_db.cameraCaptures)
          ..orderBy([
            (t) => OrderingTerm.desc(t.capturedAtUtc),
            (t) => OrderingTerm.desc(t.sequenceNo),
          ])
          ..limit(limit))
        .watch();
  }

  Stream<List<CameraCapture>> watchForEvent(int eventId) {
    return (_db.select(_db.cameraCaptures)
          ..where((t) => t.linkedEventId.equals(eventId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.capturedAtUtc),
            (t) => OrderingTerm.asc(t.sequenceNo),
          ]))
        .watch();
  }

  Stream<List<CameraCapture>> watchForTrip(int tripId) {
    return (_db.select(_db.cameraCaptures)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.capturedAtUtc),
            (t) => OrderingTerm.asc(t.sequenceNo),
          ]))
        .watch();
  }

  Future<void> deleteCapture(CameraCapture capture) async {
    await (_db.delete(
      _db.cameraCaptures,
    )..where((t) => t.id.equals(capture.id))).go();
    final file = File(capture.filePath);
    if (await file.exists()) await file.delete();
  }

  static String _dayFolder(DateTime utc) =>
      '${utc.year.toString().padLeft(4, '0')}'
      '${utc.month.toString().padLeft(2, '0')}'
      '${utc.day.toString().padLeft(2, '0')}';

  static String _compactUtc(DateTime utc) =>
      '${utc.year.toString().padLeft(4, '0')}'
      '${utc.month.toString().padLeft(2, '0')}'
      '${utc.day.toString().padLeft(2, '0')}_'
      '${utc.hour.toString().padLeft(2, '0')}'
      '${utc.minute.toString().padLeft(2, '0')}'
      '${utc.second.toString().padLeft(2, '0')}_'
      '${utc.millisecond.toString().padLeft(3, '0')}Z';
}
