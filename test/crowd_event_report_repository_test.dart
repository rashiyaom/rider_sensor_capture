import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/crowd_event_report_repository.dart';
import 'package:ride_sensor_capture/data/repositories/firebase_crowd_event_sync_service.dart';

void main() {
  late AppDatabase db;
  late CrowdEventReportRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CrowdEventReportRepository(db);
  });

  tearDown(() => db.close());

  CrowdEventReportDraft validDraft({
    bool confirmed = true,
    bool consented = true,
    double accuracy = 8,
    int localReviewId = 12,
    String ownerUid = 'driver-uid-1',
  }) => CrowdEventReportDraft(
    ownerUid: ownerUid,
    tripId: 7,
    localReviewId: localReviewId,
    latitude: 12.9716,
    longitude: 77.5946,
    horizontalAccuracyM: accuracy,
    observedAtUtc: DateTime.utc(2026, 11, 6, 10),
    headingDeg: 90,
    speedKmh: 24,
    source: 'ml',
    evidenceKind: 'imu_impact',
    evidenceConfidence: .82,
    evidenceJson: '{"peak_g":1.4}',
    driverConfirmed: confirmed,
    locationShareConsented: consented,
  );

  test(
    'queues a confirmed consented report as candidate, never verified',
    () async {
      final report = await repository.queue(validDraft());

      expect(report.reportKey, hasLength(32));
      expect(report.ownerUid, 'driver-uid-1');
      expect(report.eventType, 'road_impact');
      expect(report.horizontalAccuracyM, 8);
      expect(report.driverConfirmed, isTrue);
      expect(report.locationShareConsented, isTrue);
      expect(report.syncStatus, 'queued');
      expect(report.verificationStatus, 'candidate');
      expect(await repository.pendingUploads(), [report]);
    },
  );

  test(
    'requires explicit confirmation, consent, and usable GPS accuracy',
    () async {
      await expectLater(
        repository.queue(validDraft(confirmed: false)),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        repository.queue(validDraft(consented: false)),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        repository.queue(validDraft(accuracy: 15.1)),
        throwsA(isA<ArgumentError>()),
      );
      expect(await db.select(db.crowdEventReports).get(), isEmpty);
    },
  );

  test(
    'pending uploads can be scoped to the current participant UID',
    () async {
      final first = await repository.queue(validDraft());
      final second = await repository.queue(
        validDraft(ownerUid: 'driver-uid-2', localReviewId: 13),
      );

      expect(
        (await repository.pendingUploads(ownerUid: 'driver-uid-1'))
            .map((report) => report.id),
        [first.id],
      );
      expect(
        (await repository.pendingUploads(ownerUid: 'driver-uid-2'))
            .map((report) => report.id),
        [second.id],
      );
    },
  );

  test(
    'persists retries and accepts verification state only via server sync API',
    () async {
      final report = await repository.queue(validDraft());
      await repository.markUploading(report.id);
      expect(
        (await repository.pendingUploads()).single.syncStatus,
        'uploading',
      );
      await repository.markFailed(report.id, 'network unavailable');
      expect((await repository.pendingUploads()).single.syncStatus, 'failed');

      await repository.applyServerState(
        report.id,
        cloudEventId: 'hazard-abc',
        verificationStatus: 'corroborated',
      );
      final synced = await (db.select(
        db.crowdEventReports,
      )..where((t) => t.id.equals(report.id))).getSingle();
      expect(synced.syncStatus, 'uploaded');
      expect(synced.cloudEventId, 'hazard-abc');
      expect(synced.verificationStatus, 'corroborated');
      expect(await repository.pendingUploads(), isEmpty);
    },
  );

  test(
    'rejects server status values outside the verification lifecycle',
    () async {
      final report = await repository.queue(validDraft());
      await expectLater(
        repository.applyServerState(
          report.id,
          cloudEventId: 'hazard-abc',
          verificationStatus: 'trusted',
        ),
        throwsA(isA<ArgumentError>()),
      );
    },
  );

  test(
    'records rejected and stale results without retrying rejected data',
    () async {
      final rejected = await repository.queue(validDraft());
      await repository.markUploaded(rejected.id);
      await repository.applyServerOutcome(
        id: rejected.id,
        resultStatus: 'rejected',
        reasonCode: 'invalid_evidence_source',
      );
      final rejectedRow = await repository.getById(rejected.id);
      expect(rejectedRow.syncStatus, 'uploaded');
      expect(rejectedRow.verificationStatus, 'rejected');
      expect(rejectedRow.lastSyncError, 'invalid_evidence_source');

      final stale = await repository.queue(validDraft(localReviewId: 13));
      await repository.markUploaded(stale.id);
      await repository.applyServerOutcome(
        id: stale.id,
        resultStatus: 'stale',
        reasonCode: 'stale_report',
      );
      expect((await repository.getById(stale.id)).verificationStatus, 'stale');
      expect(await repository.pendingUploads(), isEmpty);
      expect(await repository.reportsAwaitingServerResult(), isEmpty);
    },
  );

  test(
    'Firestore payload does not expose phone number or verification state',
    () async {
      final report = await repository.queue(validDraft());
      final payload = FirebaseCrowdEventSyncService.toFirestore(report);

      expect(payload['ownerUid'], 'driver-uid-1');
      expect(payload['eventType'], 'road_impact');
      expect(payload['driverConfirmed'], isTrue);
      expect(payload['locationShareConsented'], isTrue);
      expect(payload['evidence'], {'peak_g': 1.4});
      expect(payload.containsKey('phoneNumber'), isFalse);
      expect(payload.containsKey('verificationStatus'), isFalse);
    },
  );

  test('maps only known Cloud Function report outcomes', () {
    expect(
      CrowdReportServerResult.fromMap({
        'resultStatus': 'published',
        'sharedEventId': 'event-1',
        'verificationStatus': 'corroborated',
      })?.verificationStatus,
      'corroborated',
    );
    expect(
      CrowdReportServerResult.fromMap({
        'resultStatus': 'rejected',
        'reasonCode': 'invalid_location',
      })?.reasonCode,
      'invalid_location',
    );
    expect(
      CrowdReportServerResult.fromMap({
        'resultStatus': 'published',
        'sharedEventId': 'event-1',
        'verificationStatus': 'untrusted',
      }),
      isNull,
    );
    expect(
      CrowdReportServerResult.fromMap({'resultStatus': 'mystery'}),
      isNull,
    );
  });
}
