import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../local_db/database.dart';
import 'crowd_event_report_repository.dart';

class CrowdEventSyncResult {
  final int uploaded;
  final int failed;

  const CrowdEventSyncResult({required this.uploaded, required this.failed});
}

class CrowdReportServerResult {
  final String resultStatus;
  final String? sharedEventId;
  final String? verificationStatus;
  final String? reasonCode;

  const CrowdReportServerResult({
    required this.resultStatus,
    this.sharedEventId,
    this.verificationStatus,
    this.reasonCode,
  });

  static CrowdReportServerResult? fromMap(Map<String, dynamic> data) {
    final resultStatus = data['resultStatus'];
    if (resultStatus == 'published') {
      final sharedEventId = data['sharedEventId'];
      final verificationStatus = data['verificationStatus'];
      if (sharedEventId is! String ||
          verificationStatus is! String ||
          !const {
            'candidate',
            'corroborated',
            'verified',
            'disputed',
          }.contains(verificationStatus)) {
        return null;
      }
      return CrowdReportServerResult(
        resultStatus: resultStatus,
        sharedEventId: sharedEventId,
        verificationStatus: verificationStatus,
      );
    }
    if (resultStatus == 'rejected' || resultStatus == 'stale') {
      return CrowdReportServerResult(
        resultStatus: resultStatus,
        reasonCode: data['reasonCode'] is String
            ? data['reasonCode'] as String
            : null,
      );
    }
    return null;
  }
}

/// Uploads local reports to a private Firestore inbox. A Cloud Function is
/// responsible for validating, corroborating, and publishing shared hazards.
class FirebaseCrowdEventSyncService {
  static const reportsCollection = 'crowdReports';

  final CrowdEventReportRepository local;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseCrowdEventSyncService({
    required this.local,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : auth = auth ?? FirebaseAuth.instance,
       firestore = firestore ?? FirebaseFirestore.instance;

  Future<CrowdEventSyncResult> syncPendingReports({
    int limit = 50,
    String? prioritizeReportKey,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before uploading crowd-sourced reports.');
    }

    final reports = await local.pendingUploads(
      limit: limit,
      ownerUid: user.uid,
    );
    if (prioritizeReportKey != null) {
      final prioritized = await local.getByReportKey(prioritizeReportKey);
      if (const {
        'queued',
        'uploading',
        'failed',
      }.contains(prioritized.syncStatus)) {
        reports.removeWhere((report) => report.id == prioritized.id);
        reports.insert(0, prioritized);
        if (reports.length > limit) reports.removeLast();
      }
    }
    var uploaded = 0;
    var failed = 0;
    for (final report in reports) {
      try {
        if (report.ownerUid != user.uid) {
          throw StateError('Report belongs to a different signed-in driver.');
        }
        await local.markUploading(report.id);
        await firestore
            .collection(reportsCollection)
            .doc(report.reportKey)
            .set(toFirestore(report));
        await local.markUploaded(report.id);
        uploaded++;
      } catch (error) {
        await local.markFailed(report.id, error.toString());
        failed++;
      }
    }
    return CrowdEventSyncResult(uploaded: uploaded, failed: failed);
  }

  /// Checks pending server outcomes after an upload or when the app resumes.
  /// A report remains locally "candidate" until the function writes its result.
  Future<int> refreshUploadedResults({int limit = 50}) async {
    final user = auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before checking crowd-report results.');
    }
    final reports = await local.reportsAwaitingServerResult(
      limit: limit,
      ownerUid: user.uid,
    );
    var updated = 0;
    for (final report in reports) {
      try {
        final snapshot = await firestore
            .collection('crowdReportResults')
            .doc(report.reportKey)
            .get();
        final data = snapshot.data();
        if (data == null || data['ownerUid'] != report.ownerUid) continue;
        final outcome = CrowdReportServerResult.fromMap(data);
        if (outcome == null) continue;
        await local.applyServerOutcome(
          id: report.id,
          resultStatus: outcome.resultStatus,
          cloudEventId: outcome.sharedEventId,
          verificationStatus: outcome.verificationStatus,
          reasonCode: outcome.reasonCode,
        );
        updated++;
      } on FirebaseException {
        // Delivery already succeeded; a result-read failure must not turn the
        // report into a failed upload or cause another write attempt.
      }
    }
    return updated;
  }

  /// Waits briefly for the server trigger after the foreground submit action.
  Future<CrowdReportServerResult?> waitForServerResult(
    String reportKey, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final snapshot = await firestore
          .collection('crowdReportResults')
          .doc(reportKey)
          .snapshots()
          .firstWhere((snapshot) => snapshot.exists)
          .timeout(timeout);
      final data = snapshot.data();
      return data == null ? null : CrowdReportServerResult.fromMap(data);
    } on TimeoutException {
      return null;
    } on FirebaseException {
      return null;
    }
  }

  /// Pure payload mapping kept public for schema-level unit tests.
  static Map<String, Object?> toFirestore(CrowdEventReport report) {
    Object? evidence;
    final rawEvidence = report.evidenceJson;
    if (rawEvidence != null && rawEvidence.isNotEmpty) {
      try {
        evidence = jsonDecode(rawEvidence);
      } on FormatException {
        evidence = {'raw': rawEvidence};
      }
    }
    return {
      'reportKey': report.reportKey,
      'ownerUid': report.ownerUid,
      'tripId': report.tripId,
      'localReviewId': report.localReviewId,
      'eventType': report.eventType,
      'latitude': report.latitude,
      'longitude': report.longitude,
      'horizontalAccuracyM': report.horizontalAccuracyM,
      'observedAtUtc': Timestamp.fromDate(report.observedAtUtc.toUtc()),
      'headingDeg': report.headingDeg,
      'speedKmh': report.speedKmh,
      'source': report.source,
      'evidenceKind': report.evidenceKind,
      'evidenceConfidence': report.evidenceConfidence,
      'evidence': evidence,
      'driverConfirmed': report.driverConfirmed,
      'locationShareConsented': report.locationShareConsented,
    };
  }
}
