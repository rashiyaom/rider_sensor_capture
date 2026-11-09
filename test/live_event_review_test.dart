import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/services/live_ml_inference_service.dart';
import 'package:ride_sensor_capture/features/live_events/live_event_repository.dart';
import 'package:ride_sensor_capture/location/location_service.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_service.dart';
import 'package:ride_sensor_capture/voice/voice_alert_service.dart';

void main() {
  late AppDatabase db;
  late LiveEventRepository repo;
  late int tripId;
  final now = DateTime.now().toUtc();
  final prediction = LiveMlPrediction(
    eventType: MlPredictedEventType.mildBump,
    label: 'Bump',
    confidence: 0.75,
    timestampUtc: now,
    topFeatures: const {'z_peak_mps2': 15},
    explanation: 'test',
  );
  final fix = LocationFix(
    latitude: 12.9736,
    longitude: 77.5946,
    timestampUtc: now,
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = LiveEventRepository(db);
    tripId = await db
        .into(db.trips)
        .insert(TripsCompanion.insert(startTimeUtc: now));
  });
  tearDown(() => db.close());

  Future<int> capture({bool withGps = true}) => repo.capture(
    tripId: tripId,
    prediction: prediction,
    fix: withGps ? fix : null,
  );
  Future<void> endTrip() =>
      (db.update(db.trips)..where((t) => t.id.equals(tripId)))
          .write(TripsCompanion(endTimeUtc: Value(now)))
          .then((_) {});

  test('stores event coordinates, confirmation and feedback without creating a hazard', () async {
    final id = await capture();
    await repo.recordConfirmation(id, 'yes', true);
    await repo.recordFeedback(id, 'okayish and bumpy');
    final event = await repo.get(id);
    expect(event.latitude, fix.latitude);
    expect(event.confirmationReply, 'yes');
    expect(event.feedback, 'okayish and bumpy');
    expect(event.reviewStatus, 'pending');
    expect(await db.select(db.roadEvents).get(), isEmpty);
    expect((await db.select(db.eventRecords).get()).single.tripId, tripId);
    expect(
      (await db.select(db.eventFeedbacks).get()).single.responseText,
      'okayish and bumpy',
    );
  });

  test('saving after trip creates exactly one future alert and persists review choice', () async {
    final id = await capture();
    await repo.recordConfirmation(id, 'yes', true);
    await repo.recordFeedback(id, 'bumpy');
    await expectLater(repo.saveLocation(id), throwsStateError);
    await endTrip();
    await Future.wait([repo.saveLocation(id), repo.saveLocation(id)]);
    final roads = await db.select(db.roadEvents).get();
    expect(roads, hasLength(1));
    expect(roads.single.latitude, fix.latitude);
    expect(roads.single.note, contains('bumpy'));
    expect((await repo.get(id)).reviewStatus, 'saved');
    await repo.discard(id);
    expect((await repo.get(id)).reviewStatus, 'saved');
    final service = PreAlertService(
      db: db,
      clock: () => now,
      voiceService: VoiceAlertService(ttsEnabled: false),
    );
    await service.start();
    await service.handleLocationFix(
      LocationFix(
        latitude: 12.9718,
        longitude: 77.5946,
        gpsSpeedMps: 80 / 3.6,
        gpsHeadingDeg: 0,
        timestampUtc: now,
      ),
    );
    expect(await db.select(db.preAlerts).get(), hasLength(1));
    await service.stop();
  });

  test(
    'discard, no reply and negative reply never silently create hazards',
    () async {
      final discarded = await capture();
      await repo.discard(discarded);
      final rejected = await capture();
      await repo.recordConfirmation(rejected, 'no it was not', false);
      await endTrip();
      await repo.saveLocation(discarded);
      await expectLater(repo.saveLocation(rejected), throwsStateError);
      expect(await db.select(db.roadEvents).get(), isEmpty);
      expect((await repo.get(discarded)).reviewStatus, 'discarded');
      expect((await db.select(db.eventRecords).get()).last.status, 'discarded');
    },
  );

  test(
    'missing GPS remains visible for review but cannot become an alert',
    () async {
      final id = await capture(withGps: false);
      await endTrip();
      await expectLater(repo.saveLocation(id), throwsStateError);
      expect((await repo.watchTrip(tripId).first).single.latitude, isNull);
    },
  );

  test(
    'v16 upgrade preserves trips and adds delivery plus crowd report state',
    () async {
      final temp = await Directory.systemTemp.createTemp(
        'ride_review_migration_',
      );
      final file = File('${temp.path}/migration.sqlite');
      var migrationDb = AppDatabase.forTesting(NativeDatabase(file));
      try {
        await migrationDb
            .into(migrationDb.trips)
            .insert(TripsCompanion.insert(startTimeUtc: now));
        await migrationDb.customStatement(
          'ALTER TABLE pre_alerts DROP COLUMN delivery_status',
        );
        await migrationDb.customStatement(
          'ALTER TABLE pre_alerts DROP COLUMN delivered_at_utc',
        );
        await migrationDb.customStatement(
          'ALTER TABLE pre_alerts DROP COLUMN delivery_failure',
        );
        await migrationDb.customStatement(
          'ALTER TABLE live_event_reviews DROP COLUMN gps_accuracy_m',
        );
        await migrationDb.customStatement('PRAGMA user_version = 16');
        await migrationDb.close();
        migrationDb = AppDatabase.forTesting(NativeDatabase(file));
        expect(await migrationDb.select(migrationDb.trips).get(), hasLength(1));
        expect(
          await migrationDb.select(migrationDb.liveEventReviews).get(),
          isEmpty,
        );
        expect(
          (await migrationDb
                  .customSelect('PRAGMA table_info(pre_alerts)')
                  .get())
              .map((r) => r.read<String>('name')),
          containsAll([
            'delivery_status',
            'delivered_at_utc',
            'delivery_failure',
          ]),
        );
        expect(
          await migrationDb.select(migrationDb.crowdEventReports).get(),
          isEmpty,
        );
        expect(migrationDb.schemaVersion, 19);
      } finally {
        await migrationDb.close();
        await temp.delete(recursive: true);
      }
    },
  );
}
