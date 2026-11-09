import 'package:drift/drift.dart';

/// Local outbox of driver-confirmed road-impact reports awaiting cloud sync.
///
/// A report is an observation from one trip, not a globally verified hazard.
/// The server owns corroboration and verification status transitions.
class CrowdEventReports extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable client-generated idempotency key used by the cloud uploader.
  TextColumn get reportKey => text().unique()();

  /// Firebase Auth UID captured when the report is queued. Never a phone number.
  TextColumn get ownerUid => text()();

  IntColumn get tripId => integer().nullable()();
  IntColumn get localReviewId => integer().nullable()();

  /// MVP reports deliberately use this broad label; an IMU impact alone cannot
  /// distinguish potholes, speed bumps, or rough patches.
  TextColumn get eventType =>
      text().withDefault(const Constant('road_impact'))();

  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get horizontalAccuracyM => real()();
  DateTimeColumn get observedAtUtc => dateTime()();
  RealColumn get headingDeg => real().nullable()();
  RealColumn get speedKmh => real().nullable()();

  /// ml | camera | voice | manual
  TextColumn get source => text()();
  TextColumn get evidenceKind => text()();
  RealColumn get evidenceConfidence => real().nullable()();
  TextColumn get evidenceJson => text().nullable()();

  BoolColumn get driverConfirmed =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get locationShareConsented =>
      boolean().withDefault(const Constant(false))();

  /// queued | uploading | uploaded | failed
  TextColumn get syncStatus => text().withDefault(const Constant('queued'))();

  /// Server outcome: candidate | corroborated | verified | disputed | rejected | stale.
  TextColumn get verificationStatus =>
      text().withDefault(const Constant('candidate'))();
  TextColumn get cloudEventId => text().nullable()();
  TextColumn get lastSyncError => text().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();
}
