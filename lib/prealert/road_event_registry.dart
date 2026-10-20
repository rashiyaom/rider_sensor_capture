import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../data/local_db/database.dart';
import '../location/geo_math.dart';
import 'pre_alert_engine.dart';

/// Persistence layer for the geo-tagged road-event knowledge base that powers
/// the predictive pre-alert system.
class RoadEventRegistry {
  final AppDatabase _db;

  RoadEventRegistry(this._db);

  /// Registers a newly detected hazard so it can be warned about later.
  Future<int> register({
    required RoadEventKind kind,
    required double latitude,
    required double longitude,
    double severity = 0.5,
    double confidence = 0.8,
    String source = 'ml',
    int? tripId,
    double? speedKmhAtDetection,
    String? note,
    DateTime? detectedAtUtc,
  }) async {
    return _db.into(_db.roadEvents).insert(
          RoadEventsCompanion.insert(
            tripId: Value(tripId),
            eventType: kind.name,
            latitude: latitude,
            longitude: longitude,
            severity: Value(severity),
            confidence: Value(confidence),
            source: Value(source),
            detectedAtUtc: detectedAtUtc ?? DateTime.now().toUtc(),
            speedKmhAtDetection: Value(speedKmhAtDetection),
            note: Value(note),
          ),
        );
  }

  /// Loads every hazard within [radiusMeters] of the given position.
  ///
  /// A cheap bounding-box pre-filter runs in SQL, then the exact haversine
  /// distance is computed in Dart.
  Future<List<RoadEventCandidate>> loadCandidates({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    final latDelta = _latDelta(radiusMeters);
    final cosLat = math.cos(latitude * math.pi / 180.0).abs();
    final lonDelta = cosLat < 0.0001
        ? 180.0
        : radiusMeters / (GeoMath.earthRadiusMeters * cosLat) * 180.0 / math.pi;

    final rows = await (_db.select(_db.roadEvents)
          ..where((t) =>
              t.latitude.isBiggerOrEqualValue(latitude - latDelta) &
              t.latitude.isSmallerOrEqualValue(latitude + latDelta) &
              t.longitude.isBiggerOrEqualValue(longitude - lonDelta) &
              t.longitude.isSmallerOrEqualValue(longitude + lonDelta)))
        .get();

    final candidates = <RoadEventCandidate>[];
    for (final row in rows) {
      final distance = GeoMath.distanceMeters(
        lat1: latitude,
        lon1: longitude,
        lat2: row.latitude,
        lon2: row.longitude,
      );
      if (distance > radiusMeters) continue;
      candidates.add(_toCandidate(row));
    }
    return candidates;
  }

  /// Fetches a single hazard row.
  Future<RoadEvent?> getById(int id) async {
    return (_db.select(_db.roadEvents)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Increments the alert counter for a hazard and stamps the alert time.
  Future<void> incrementAlertCount(int roadEventId, {DateTime? at}) async {
    final row = await getById(roadEventId);
    if (row == null) return;
    await (_db.update(_db.roadEvents)..where((t) => t.id.equals(roadEventId))).write(
      RoadEventsCompanion(
        alertCount: Value(row.alertCount + 1),
        lastAlertedAtUtc: Value(at ?? DateTime.now().toUtc()),
      ),
    );
  }

  /// Increments the feedback counter for a hazard.
  Future<void> incrementFeedbackCount(int roadEventId) async {
    final row = await getById(roadEventId);
    if (row == null) return;
    await (_db.update(_db.roadEvents)..where((t) => t.id.equals(roadEventId))).write(
      RoadEventsCompanion(feedbackCount: Value(row.feedbackCount + 1)),
    );
  }

  /// Removes a hazard from the knowledge base.
  Future<void> delete(int id) async {
    await (_db.delete(_db.roadEvents)..where((t) => t.id.equals(id))).go();
  }

  /// Counts the registered hazards.
  Future<int> countAll() async {
    final count = _db.roadEvents.id.count();
    final row = await (_db.selectOnly(_db.roadEvents)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  /// Converts a database row into an engine candidate.
  static RoadEventCandidate _toCandidate(RoadEvent row) {
    return RoadEventCandidate(
      id: row.id,
      kind: RoadEventKind.fromString(row.eventType),
      latitude: row.latitude,
      longitude: row.longitude,
      severity: row.severity ?? 0.5,
      confidence: row.confidence ?? 0.8,
      source: row.source,
      detectedAtUtc: row.detectedAtUtc,
      speedKmhAtDetection: row.speedKmhAtDetection,
    );
  }

  static double _latDelta(double radiusMeters) {
    return radiusMeters / GeoMath.earthRadiusMeters * 180.0 / math.pi;
  }
}
