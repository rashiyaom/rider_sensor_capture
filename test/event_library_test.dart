import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/features/live_events/event_library_repository.dart';

void main() {
  late AppDatabase db;
  late EventLibraryRepository repo;
  late ManagedEvent event;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = EventLibraryRepository(db);
    final now = DateTime.now().toUtc();
    final trip = await db.into(db.trips).insert(TripsCompanion.insert(startTimeUtc: now, endTimeUtc: Value(now)));
    final id = await db.into(db.eventRecords).insert(EventRecordsCompanion.insert(
      eventType: 'bump', startTimestamp: now, status: 'completed', tripId: Value(trip)));
    final road = await db.into(db.roadEvents).insert(RoadEventsCompanion.insert(
      eventType: 'bump', latitude: 12, longitude: 77, detectedAtUtc: now));
    final review = await db.into(db.liveEventReviews).insert(LiveEventReviewsCompanion.insert(
      tripId: trip, eventId: Value(id), roadEventId: Value(road), eventType: 'bump',
      detectedAtUtc: now, confidence: .8, sensorFeaturesJson: '{}', reviewStatus: const Value('saved')));
    await db.into(db.sensorReadings).insert(SensorReadingsCompanion.insert(
      deviceId: 'watch', deviceType: 'watch', sequenceNo: 1, timestampUtc: now,
      sensorType: 'imu', eventId: Value(id), tripId: Value(trip)));
    event = ManagedEvent(key: 'review_$review', type: 'bump', source: 'Live ride', status: 'saved',
      at: now, reviewId: review, roadId: road, eventId: id);
  });
  tearDown(() => db.close());
  test('library groups linked ride and alert records once', () async {
    final events = ManagedEvent.combine(await db.select(db.roadEvents).get(),
      await db.select(db.liveEventReviews).get(), await db.select(db.eventRecords).get());
    expect(events, hasLength(1));
    expect(events.single.roadId, event.roadId);
  });
  test('editing updates the alert, review and event atomically', () async {
    await repo.edit(event, type: 'pothole', latitude: 13, longitude: 78, feedback: 'Deep hole');
    expect((await db.select(db.roadEvents).getSingle()).latitude, 13);
    expect((await db.select(db.liveEventReviews).getSingle()).eventType, 'pothole');
    expect((await db.select(db.eventRecords).getSingle()).startGpsLng, 78);
    await expectLater(repo.edit(event, type: 'bump', latitude: 999, longitude: 78, feedback: ''), throwsArgumentError);
    expect((await db.select(db.roadEvents).getSingle()).eventType, 'pothole');
  });
  test('delete removes location warning, retains telemetry and clears its event link', () async {
    await repo.delete(event);
    expect(await db.select(db.roadEvents).get(), isEmpty);
    expect(await db.select(db.liveEventReviews).get(), isEmpty);
    expect(await db.select(db.eventRecords).get(), isEmpty);
    expect((await db.select(db.sensorReadings).getSingle()).eventId, isNull);
    expect((await db.select(db.trips).getSingle()).totalEventsCount, 0);
  });
}
