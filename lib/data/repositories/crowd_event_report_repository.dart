import 'dart:math';

import 'package:drift/drift.dart';

import '../local_db/database.dart';

class CrowdEventReportDraft {
  final String ownerUid;
  final int? tripId;
  final int? localReviewId;
  final double latitude;
  final double longitude;
  final double horizontalAccuracyM;
  final DateTime observedAtUtc;
  final double? headingDeg;
  final double? speedKmh;
  final String source;
  final String evidenceKind;
  final double? evidenceConfidence;
  final String? evidenceJson;
  final bool driverConfirmed;
  final bool locationShareConsented;

  const CrowdEventReportDraft({
    required this.ownerUid,
    required this.latitude,
    required this.longitude,
    required this.horizontalAccuracyM,
    required this.observedAtUtc,
    required this.source,
    required this.evidenceKind,
    this.tripId,
    this.localReviewId,
    this.headingDeg,
    this.speedKmh,
    this.evidenceConfidence,
    this.evidenceJson,
    this.driverConfirmed = false,
    this.locationShareConsented = false,
  });
}

/// Persistence boundary for reports that may be uploaded to the shared system.
///
/// This repository only queues a driver's confirmed observation. It never
/// decides that a shared hazard is corroborated or verified.
class CrowdEventReportRepository {
  static const maxShareableGpsAccuracyM = 15.0;
  static const _sources = {'ml', 'camera', 'voice', 'manual'};

  final AppDatabase db;
  final Random _random;

  CrowdEventReportRepository(this.db, {Random? random})
    : _random = random ?? Random.secure();

  Future<CrowdEventReport> queue(CrowdEventReportDraft draft) async {
    _validate(draft);
    return db.transaction(() async {
      final reviewId = draft.localReviewId;
      if (reviewId != null && await hasReportForReview(reviewId)) {
        throw StateError('This live event review has already been submitted.');
      }
      final key = _newReportKey();
      final id = await db
          .into(db.crowdEventReports)
          .insert(
            CrowdEventReportsCompanion.insert(
              reportKey: key,
              ownerUid: draft.ownerUid.trim(),
              tripId: Value(draft.tripId),
              localReviewId: Value(draft.localReviewId),
              latitude: draft.latitude,
              longitude: draft.longitude,
              horizontalAccuracyM: draft.horizontalAccuracyM,
              observedAtUtc: draft.observedAtUtc.toUtc(),
              headingDeg: Value(draft.headingDeg),
              speedKmh: Value(draft.speedKmh),
              source: draft.source,
              evidenceKind: draft.evidenceKind,
              evidenceConfidence: Value(draft.evidenceConfidence),
              evidenceJson: Value(draft.evidenceJson),
              driverConfirmed: const Value(true),
              locationShareConsented: const Value(true),
              createdAtUtc: DateTime.now().toUtc(),
            ),
          );
      return (db.select(
        db.crowdEventReports,
      )..where((t) => t.id.equals(id))).getSingle();
    });
  }

  Future<List<CrowdEventReport>> pendingUploads({
    int limit = 50,
    String? ownerUid,
  }) =>
      (db.select(db.crowdEventReports)
            ..where(
              (t) =>
                  t.syncStatus.isIn(['queued', 'uploading', 'failed']) &
                  (ownerUid == null
                      ? const Constant(true)
                      : t.ownerUid.equals(ownerUid)),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.createdAtUtc)])
            ..limit(limit))
          .get();

  Future<CrowdEventReport> getById(int id) => (db.select(
    db.crowdEventReports,
  )..where((t) => t.id.equals(id))).getSingle();

  Future<CrowdEventReport> getByReportKey(String reportKey) => (db.select(
    db.crowdEventReports,
  )..where((t) => t.reportKey.equals(reportKey))).getSingle();

  Stream<List<CrowdEventReport>> watchForOwner(String ownerUid) =>
      (db.select(db.crowdEventReports)
            ..where((t) => t.ownerUid.equals(ownerUid))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAtUtc,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<List<CrowdEventReport>> reportsAwaitingServerResult({
    int limit = 50,
    String? ownerUid,
  }) =>
      (db.select(db.crowdEventReports)
            ..where(
              (t) =>
                  t.syncStatus.equals('uploaded') &
                  t.cloudEventId.isNull() &
                  t.verificationStatus.equals('candidate') &
                  (ownerUid == null
                      ? const Constant(true)
                      : t.ownerUid.equals(ownerUid)),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.createdAtUtc)])
            ..limit(limit))
          .get();

  Future<bool> hasReportForReview(int localReviewId) async =>
      await (db.select(db.crowdEventReports)
            ..where((t) => t.localReviewId.equals(localReviewId))
            ..limit(1))
          .getSingleOrNull() !=
      null;

  Future<void> markUploading(int id) => _updateSync(
    id,
    const CrowdEventReportsCompanion(
      syncStatus: Value('uploading'),
      lastSyncError: Value(null),
    ),
  );

  Future<void> markFailed(int id, String message) => _updateSync(
    id,
    CrowdEventReportsCompanion(
      syncStatus: const Value('failed'),
      lastSyncError: Value(message),
    ),
  );

  /// Marks a report as delivered to Firestore. Its verification status remains
  /// candidate until a server-authoritative status is fetched separately.
  Future<void> markUploaded(int id) => _updateSync(
    id,
    const CrowdEventReportsCompanion(
      syncStatus: Value('uploaded'),
      lastSyncError: Value(null),
    ),
  );

  /// Applies server-returned state after an authenticated cloud sync.
  Future<void> applyServerState(
    int id, {
    required String cloudEventId,
    required String verificationStatus,
  }) async {
    const allowed = {'candidate', 'corroborated', 'verified', 'disputed'};
    if (!allowed.contains(verificationStatus)) {
      throw ArgumentError.value(verificationStatus, 'verificationStatus');
    }
    await _updateSync(
      id,
      CrowdEventReportsCompanion(
        syncStatus: const Value('uploaded'),
        cloudEventId: Value(cloudEventId),
        verificationStatus: Value(verificationStatus),
        lastSyncError: const Value(null),
      ),
    );
  }

  Future<void> applyServerOutcome({
    required int id,
    required String resultStatus,
    String? cloudEventId,
    String? verificationStatus,
    String? reasonCode,
  }) async {
    if (resultStatus == 'published') {
      if (cloudEventId == null || verificationStatus == null) {
        throw ArgumentError('Published reports require event ID and status.');
      }
      await applyServerState(
        id,
        cloudEventId: cloudEventId,
        verificationStatus: verificationStatus,
      );
      return;
    }
    if (resultStatus != 'rejected' && resultStatus != 'stale') {
      throw ArgumentError.value(resultStatus, 'resultStatus');
    }
    await _updateSync(
      id,
      CrowdEventReportsCompanion(
        syncStatus: const Value('uploaded'),
        verificationStatus: Value(resultStatus),
        cloudEventId: const Value(null),
        lastSyncError: Value(reasonCode),
      ),
    );
  }

  Future<void> _updateSync(int id, CrowdEventReportsCompanion values) async {
    final changed = await (db.update(
      db.crowdEventReports,
    )..where((t) => t.id.equals(id))).write(values);
    if (changed == 0) throw StateError('Crowd event report $id not found.');
  }

  void _validate(CrowdEventReportDraft draft) {
    if (draft.ownerUid.trim().isEmpty) {
      throw ArgumentError('A signed-in driver UID is required.');
    }
    if (!draft.driverConfirmed) {
      throw StateError('Only driver-confirmed reports can be shared.');
    }
    if (!draft.locationShareConsented) {
      throw StateError('Location sharing consent is required.');
    }
    if (!draft.latitude.isFinite ||
        draft.latitude < -90 ||
        draft.latitude > 90 ||
        !draft.longitude.isFinite ||
        draft.longitude < -180 ||
        draft.longitude > 180) {
      throw ArgumentError('A valid event location is required.');
    }
    if (!draft.horizontalAccuracyM.isFinite ||
        draft.horizontalAccuracyM <= 0 ||
        draft.horizontalAccuracyM > maxShareableGpsAccuracyM) {
      throw ArgumentError(
        'GPS accuracy must be between 0 and '
        '${maxShareableGpsAccuracyM.toStringAsFixed(0)} metres to share.',
      );
    }
    if (!_sources.contains(draft.source)) {
      throw ArgumentError.value(draft.source, 'source');
    }
    if (draft.evidenceKind.trim().isEmpty) {
      throw ArgumentError('Evidence kind is required.');
    }
    final confidence = draft.evidenceConfidence;
    if (confidence != null &&
        (!confidence.isFinite || confidence < 0 || confidence > 1)) {
      throw ArgumentError.value(confidence, 'evidenceConfidence');
    }
  }

  String _newReportKey() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
