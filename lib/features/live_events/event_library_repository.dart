import 'package:drift/drift.dart';
import '../../data/local_db/database.dart';
import 'trip_event_totals.dart';

class ManagedEvent {
  final String key;
  final String type;
  final String source;
  final String status;
  final double? latitude;
  final double? longitude;
  final String? reply;
  final String? feedback;
  final DateTime at;
  final int? reviewId;
  final int? roadId;
  final int? eventId;
  const ManagedEvent({required this.key, required this.type, required this.source,
    required this.status, required this.at, this.latitude, this.longitude,
    this.reply, this.feedback, this.reviewId, this.roadId, this.eventId});

  static List<ManagedEvent> combine(List<RoadEvent> roads,
      List<LiveEventReview> reviews, List<EventRecord> records) {
    final roadById = {for (final r in roads) r.id: r};
    final linkedRoads = reviews.map((r) => r.roadEventId).toSet();
    final linkedRecords = reviews.map((r) => r.eventId).toSet();
    return [
      for (final r in reviews) ManagedEvent(key: 'review_${r.id}', type: r.eventType,
        source: 'Ride ${r.tripId}', status: r.confirmed == false ? 'Rejected' : r.reviewStatus,
        at: r.detectedAtUtc, latitude: r.latitude, longitude: r.longitude,
        reply: r.confirmationReply, feedback: r.feedback, reviewId: r.id,
        roadId: roadById.containsKey(r.roadEventId) ? r.roadEventId : null, eventId: r.eventId),
      for (final r in roads.where((r) => !linkedRoads.contains(r.id)))
        ManagedEvent(key: 'road_${r.id}', type: r.eventType, source: r.source,
          status: 'Saved for alerts', at: r.detectedAtUtc, latitude: r.latitude,
          longitude: r.longitude, feedback: r.note, roadId: r.id),
      for (final r in records.where((r) => !linkedRecords.contains(r.id)))
        ManagedEvent(key: 'event_${r.id}', type: r.eventType, source: 'Recorded event',
          status: r.status, at: r.startTimestamp, latitude: r.startGpsLat,
          longitude: r.startGpsLng, feedback: r.triggerPhrase, eventId: r.id),
    ]..sort((a, b) => b.at.compareTo(a.at));
  }
}

class EventLibraryRepository {
  final AppDatabase db;
  EventLibraryRepository(this.db);

  static void validateCoordinates(double? lat, double? lon) {
    if ((lat == null) != (lon == null)) throw ArgumentError('Enter both coordinates.');
    if (lat != null && (!lat.isFinite || lat < -90 || lat > 90)) {
      throw ArgumentError('Latitude must be between -90 and 90.');
    }
    if (lon != null && (!lon.isFinite || lon < -180 || lon > 180)) {
      throw ArgumentError('Longitude must be between -180 and 180.');
    }
  }

  Future<void> edit(ManagedEvent event, {required String type, double? latitude,
      double? longitude, required String feedback}) => db.transaction(() async {
    validateCoordinates(latitude, longitude);
    if (event.roadId != null && latitude == null) throw ArgumentError('Saved alerts need coordinates.');
    if (event.eventId != null) {
      final record = await (db.select(db.eventRecords)..where((t) => t.id.equals(event.eventId!))).getSingleOrNull();
      if (record?.status == 'active') throw StateError('Stop recording this event before editing it.');
    }
    if (event.reviewId != null) {
      await (db.update(db.liveEventReviews)..where((t) => t.id.equals(event.reviewId!))).write(
        LiveEventReviewsCompanion(eventType: Value(type), latitude: Value(latitude),
          longitude: Value(longitude), feedback: Value(feedback)));
    }
    if (event.roadId != null) {
      await (db.update(db.roadEvents)..where((t) => t.id.equals(event.roadId!))).write(
        RoadEventsCompanion(eventType: Value(type), latitude: Value(latitude!),
          longitude: Value(longitude!), note: Value(feedback)));
    }
    if (event.eventId != null) {
      await (db.update(db.eventRecords)..where((t) => t.id.equals(event.eventId!))).write(
        EventRecordsCompanion(eventType: Value(type), startGpsLat: Value(latitude), startGpsLng: Value(longitude)));
      await (db.update(db.eventFeedbacks)..where((t) => t.eventId.equals(event.eventId!))).write(
        EventFeedbacksCompanion(eventType: Value(type), responseText: Value(feedback), responseSource: const Value('text')));
      final record = await (db.select(db.eventRecords)..where((t) => t.id.equals(event.eventId!))).getSingleOrNull();
      if (record?.tripId != null) await refreshTripEventTotals(db, record!.tripId!);
    }
  });

  Future<void> delete(ManagedEvent event) => db.transaction(() async {
    if (event.eventId != null) {
      final record = await (db.select(db.eventRecords)..where((t) => t.id.equals(event.eventId!))).getSingleOrNull();
      if (record?.status == 'active') throw StateError('Stop recording this event before deleting it.');
      // Keep telemetry and photos; remove only their deleted event association.
      await (db.update(db.sensorReadings)..where((t) => t.eventId.equals(event.eventId!)))
          .write(const SensorReadingsCompanion(eventId: Value(null)));
      await (db.update(db.cameraCaptures)..where((t) => t.linkedEventId.equals(event.eventId!)))
          .write(const CameraCapturesCompanion(linkedEventId: Value(null)));
      await (db.update(db.cameraDetections)..where((t) => t.linkedEventId.equals(event.eventId!)))
          .write(const CameraDetectionsCompanion(linkedEventId: Value(null)));
      await (db.update(db.preAlerts)..where((t) => t.eventId.equals(event.eventId!)))
          .write(const PreAlertsCompanion(eventId: Value(null)));
      await (db.delete(db.eventFeedbacks)..where((t) => t.eventId.equals(event.eventId!))).go();
      await (db.delete(db.eventRecords)..where((t) => t.id.equals(event.eventId!))).go();
      if (record?.tripId != null) await refreshTripEventTotals(db, record!.tripId!);
    }
    if (event.reviewId != null) {
      await (db.delete(db.liveEventReviews)..where((t) => t.id.equals(event.reviewId!))).go();
    }
    if (event.roadId != null) {
      await (db.update(db.preAlerts)..where((t) => t.roadEventId.equals(event.roadId!)))
          .write(const PreAlertsCompanion(roadEventId: Value(null)));
      await (db.update(db.eventFeedbacks)..where((t) => t.roadEventId.equals(event.roadId!)))
          .write(const EventFeedbacksCompanion(roadEventId: Value(null)));
      await (db.update(db.liveEventReviews)..where((t) => t.roadEventId.equals(event.roadId!)))
          .write(const LiveEventReviewsCompanion(roadEventId: Value(null), reviewStatus: Value('discarded')));
      await (db.update(db.unknownEvents)..where((t) => t.promotedRoadEventId.equals(event.roadId!)))
          .write(const UnknownEventsCompanion(promotedRoadEventId: Value(null), promoted: Value(false)));
      await (db.delete(db.roadEvents)..where((t) => t.id.equals(event.roadId!))).go();
    }
  });
}
