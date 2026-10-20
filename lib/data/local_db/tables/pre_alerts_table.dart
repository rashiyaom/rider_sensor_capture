import 'package:drift/drift.dart';

/// Audit log of every predictive pre-alert that was spoken to the rider.
///
/// Each row captures the exact kinematics that were used to compute the
/// warning (distance, speed, time-to-event, recommended speed) so that the
/// post-event feedback loop can later score whether the warning arrived at
/// the right moment.
class PreAlerts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The geo-tagged hazard that triggered the warning.
  IntColumn get roadEventId => integer().nullable()();

  IntColumn get tripId => integer().nullable()();

  /// The labeled event that this pre-alert was associated with, once known.
  IntColumn get eventId => integer().nullable()();

  TextColumn get eventType => text()();

  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  /// Straight-line distance from the rider to the hazard at alert time.
  RealColumn get distanceMeters => real()();

  /// Ground speed at alert time.
  RealColumn get speedKmh => real()();

  /// distance / speed — the number of seconds the rider had to react.
  RealColumn get timeToEventSeconds => real()();

  /// Speed the rider should be at (km/h) to clear the hazard safely.
  RealColumn get recommendedSpeedKmh => real()();

  /// imminent | warning | advisory
  TextColumn get urgency => text()();

  /// The exact text that was spoken by the TTS engine.
  TextColumn get spokenText => text()();

  DateTimeColumn get alertedAtUtc => dateTime()();

  /// Set once the rider passed the hazard (used for timing evaluation).
  BoolColumn get acknowledged => boolean().withDefault(const Constant(false))();
}
