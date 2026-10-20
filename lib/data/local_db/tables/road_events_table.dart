import 'package:drift/drift.dart';

/// Persistent registry of road events (bumps, potholes, turns, braking zones)
/// discovered by the on-device ML pipeline, the AI camera ingest, or the rider.
///
/// This table is the knowledge base that powers the predictive pre-alert
/// system: every row is a geo-tagged hazard that the phone can warn the rider
/// about *before* they physically reach it on a later pass.
class RoadEvents extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Trip that first reported this road event (nullable for seeded hazards).
  IntColumn get tripId => integer().nullable()();

  /// bump | pothole | turn | braking | hazard | unknown
  TextColumn get eventType => text()();

  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  /// Normalized 0..1 severity derived from the ML confidence / g-force.
  RealColumn get severity => real().nullable()();

  /// Model confidence for the detection (0..1).
  RealColumn get confidence => real().nullable()();

  /// ml | camera | voice | manual
  TextColumn get source => text().withDefault(const Constant('ml'))();

  DateTimeColumn get detectedAtUtc => dateTime()();

  /// Ground speed at the moment the hazard was detected.
  RealColumn get speedKmhAtDetection => real().nullable()();

  /// How many pre-alerts have been spoken for this hazard.
  IntColumn get alertCount => integer().withDefault(const Constant(0))();

  /// How many rider feedback records are linked to this hazard.
  IntColumn get feedbackCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get lastAlertedAtUtc => dateTime().nullable()();

  TextColumn get note => text().nullable()();
}
