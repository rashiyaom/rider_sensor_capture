import 'package:drift/drift.dart';

import '../data/local_db/database.dart';
import '../data/repositories/sensor_repository.dart';
import 'camera_detection_model.dart';

/// Time window (seconds) around a recently-completed event's endTimestamp
/// within which a camera detection will be retroactively linked.
const int kRecentEventLinkWindowSeconds = 10;

class CameraDetectionRepository {
  final AppDatabase _db;
  final SensorRepository _sensorRepo;

  CameraDetectionRepository(this._db, this._sensorRepo);

  /// Persists a validated camera detection and attempts to link it to an event.
  /// Returns the inserted row's id.
  Future<int> insertDetection(CameraDetectionPayload payload) async {
    final now = DateTime.now().toUtc();
    final linkedEventId = await _resolveLinkedEventId(payload.cameraTimestampUtc);

    final companion = CameraDetectionsCompanion.insert(
      deviceId: payload.deviceId,
      eventClass: payload.eventClass,
      confidence: payload.confidence,
      cameraTimestampUtc: payload.cameraTimestampUtc,
      receivedAtUtc: now,
      linkedEventId: Value(linkedEventId),
    );

    return await _db.into(_db.cameraDetections).insert(companion);
  }

  /// Determines which EventRecord (if any) this camera timestamp should be
  /// linked to. Priority:
  /// 1. Currently-active recording event.
  /// 2. Most recent completed event whose time window covers camera timestamp ±10s.
  Future<int?> _resolveLinkedEventId(DateTime cameraTs) async {
    // 1. Active event (currently recording)
    final activeId = _sensorRepo.activeEventId;
    if (activeId != null) return activeId;

    // 2. Recently-completed events — check within the linking window
    final windowStart =
        cameraTs.subtract(Duration(seconds: kRecentEventLinkWindowSeconds));
    final windowEnd =
        cameraTs.add(Duration(seconds: kRecentEventLinkWindowSeconds));

    final recentEvents = await (_db.select(_db.eventRecords)
          ..where((t) =>
              t.status.equals('completed') &
              t.endTimestamp.isBiggerOrEqualValue(windowStart) &
              t.startTimestamp.isSmallerOrEqualValue(windowEnd))
          ..orderBy([(t) => OrderingTerm.desc(t.endTimestamp)])
          ..limit(1))
        .get();

    return recentEvents.isEmpty ? null : recentEvents.first.id;
  }

  /// Live stream of the most recent camera detections.
  Stream<List<CameraDetection>> watchRecentDetections({int limit = 20}) {
    return (_db.select(_db.cameraDetections)
          ..orderBy([(t) => OrderingTerm.desc(t.receivedAtUtc)])
          ..limit(limit))
        .watch();
  }

  /// Live stream of camera detections linked to a specific event.
  Stream<List<CameraDetection>> watchDetectionsForEvent(int eventId) {
    return (_db.select(_db.cameraDetections)
          ..where((t) => t.linkedEventId.equals(eventId))
          ..orderBy([(t) => OrderingTerm.asc(t.cameraTimestampUtc)]))
        .watch();
  }

  /// Count of all stored detections.
  Future<int> getTotalCount() async {
    final count = _db.cameraDetections.id.count();
    final query = _db.selectOnly(_db.cameraDetections)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
