import 'dart:convert';
import 'package:drift/drift.dart';
import '../../data/local_db/database.dart';
import '../../data/services/live_ml_inference_service.dart';
import '../../location/location_service.dart';
import '../../prealert/pre_alert_engine.dart';
import 'trip_event_totals.dart';
import 'event_library_repository.dart';

class LiveEventRepository {
  final AppDatabase db;
  LiveEventRepository(this.db);

  Stream<List<LiveEventReview>> watchTrip(int tripId) =>
      (db.select(db.liveEventReviews)
        ..where((t) => t.tripId.equals(tripId))
        ..orderBy([(t) => OrderingTerm(expression: t.detectedAtUtc)]))
      .watch();

  static String typeFor(MlPredictedEventType type) => switch (type) {
    MlPredictedEventType.severeBump || MlPredictedEventType.mildBump => 'bump',
    MlPredictedEventType.sharpTurn => 'turn',
    MlPredictedEventType.hardBraking => 'braking',
    MlPredictedEventType.rapidAcceleration => 'acceleration',
    MlPredictedEventType.normalRiding => 'unknown',
  };

  Future<int> capture({required int tripId, required LiveMlPrediction prediction,
    LocationFix? fix}) => db.transaction(() async {
    final type = typeFor(prediction.eventType);
    final features = jsonEncode(prediction.topFeatures);
    final eventId = await db.into(db.eventRecords).insert(EventRecordsCompanion.insert(
      eventType: type, startTimestamp: prediction.timestampUtc,
      endTimestamp: Value(prediction.timestampUtc), status: 'pending_confirmation',
      tripId: Value(tripId), startGpsLat: Value(fix?.latitude),
      startGpsLng: Value(fix?.longitude), triggerPhrase: const Value('live_sensor'),
      computedParameters: Value(features), classification: Value(prediction.label),
      peakMetric: Value(prediction.topFeatures['z_peak_mps2']),
      jerkPeakMagnitude: Value(prediction.topFeatures['peak_jerk_mps3']),
      gpsSpeedAtEventKmh: Value(fix?.speedKmh),
    ));
    return db.into(db.liveEventReviews).insert(LiveEventReviewsCompanion.insert(
      tripId: tripId, eventId: Value(eventId), eventType: type,
      detectedAtUtc: prediction.timestampUtc, confidence: prediction.confidence,
      sensorFeaturesJson: features, latitude: Value(fix?.latitude),
      longitude: Value(fix?.longitude),
    ));
  });

  Future<LiveEventReview> get(int id) =>
      (db.select(db.liveEventReviews)..where((t) => t.id.equals(id))).getSingle();

  Future<void> recordConfirmation(int id, String? reply, bool? confirmed) =>
      db.transaction(() async {
        final row = await get(id);
        await (db.update(db.liveEventReviews)..where((t) => t.id.equals(id))).write(
          LiveEventReviewsCompanion(confirmationReply: Value(reply), confirmed: Value(confirmed),
            reviewStatus: Value(confirmed == false ? 'discarded' : 'pending')),
        );
        if (row.eventId != null) {
          await (db.update(db.eventRecords)..where((t) => t.id.equals(row.eventId!)))
              .write(EventRecordsCompanion(status: Value(confirmed == true ? 'completed' : confirmed == false ? 'discarded' : 'pending_confirmation')));
        }
        await refreshTripEventTotals(db, row.tripId);
      });

  Future<void> recordFeedback(int id, String? feedback) => db.transaction(() async {
    final row = await get(id);
    await (db.update(db.liveEventReviews)..where((t) => t.id.equals(id)))
        .write(LiveEventReviewsCompanion(feedback: Value(feedback)));
    if (row.confirmed != true || feedback == null || feedback.trim().isEmpty) return;
    await db.into(db.eventFeedbacks).insert(EventFeedbacksCompanion.insert(
      eventId: Value(row.eventId), tripId: Value(row.tripId), eventType: row.eventType,
      prompt: 'How was it?', responseText: feedback, responseSource: 'voice',
      createdAtUtc: DateTime.now().toUtc(),
    ));
  });

  /// This is the only live-detection path that enables future location alerts.
  Future<void> saveLocation(int id) => db.transaction(() async {
    final row = await get(id);
    if (row.confirmed == false) throw StateError('This event was rejected by the rider.');
    if (row.reviewStatus != 'pending') return;
    EventLibraryRepository.validateCoordinates(row.latitude, row.longitude);
    if (row.latitude == null || row.longitude == null) {
      throw StateError('No GPS coordinate was available for this event.');
    }
    if (row.confirmed == false) throw StateError('This event was rejected by the rider.');
    final trip = await (db.select(db.trips)..where((t) => t.id.equals(row.tripId))).getSingle();
    if (trip.endTimeUtc == null) throw StateError('End the journey before saving locations.');
    final kind = RoadEventKind.fromString(row.eventType);
    if (kind == RoadEventKind.unknown) throw StateError('This event is not a location hazard.');
    if (row.eventId != null) {
      await (db.update(db.eventRecords)..where((t) => t.id.equals(row.eventId!)))
          .write(const EventRecordsCompanion(status: Value('completed')));
    }
    await refreshTripEventTotals(db, row.tripId);
    final roadId = await db.into(db.roadEvents).insert(RoadEventsCompanion.insert(
      tripId: Value(row.tripId), eventType: kind.name, latitude: row.latitude!,
      longitude: row.longitude!, confidence: Value(row.confidence),
      severity: const Value(0.5), source: const Value('voice'),
      detectedAtUtc: row.detectedAtUtc,
      note: Value('Confirmation: ${row.confirmationReply ?? "Reviewed after trip"}. '
          'Feedback: ${row.feedback ?? "Not captured"}'),
    ));
    await (db.update(db.liveEventReviews)..where((t) => t.id.equals(id))).write(
      LiveEventReviewsCompanion(reviewStatus: const Value('saved'), roadEventId: Value(roadId)),
    );
  });

  Future<void> discard(int id) async {
    await (db.update(db.liveEventReviews)
      ..where((t) => t.id.equals(id) & t.reviewStatus.equals('pending')))
      .write(const LiveEventReviewsCompanion(reviewStatus: Value('discarded')));
  }
}
