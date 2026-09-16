import 'package:drift/drift.dart';

class Trips extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get riderName => text().withDefault(const Constant('Rider'))();

  // Legacy timestamps (required by existing codebase and tests)
  DateTimeColumn get startTimeUtc => dateTime()();
  DateTimeColumn get endTimeUtc => dateTime().nullable()();

  // Primary ML Driver Safety timestamps
  DateTimeColumn get startTimestampUtc => dateTime().nullable()();
  DateTimeColumn get endTimestampUtc => dateTime().nullable()();

  // Primary ML Driver Safety aggregates
  RealColumn get totalDistanceKm => real().nullable()();
  RealColumn get totalDurationMin => real().nullable()();
  RealColumn get avgSpeedKmh => real().nullable()();
  RealColumn get maxSpeedKmh => real().nullable()();
  IntColumn get harshBrakeCount => integer().withDefault(const Constant(0))();
  IntColumn get harshAccelCount => integer().withDefault(const Constant(0))();
  IntColumn get harshTurnCount => integer().withDefault(const Constant(0))();
  IntColumn get bumpCount => integer().withDefault(const Constant(0))();
  IntColumn get confirmedEventCount => integer().withDefault(const Constant(0))();
  RealColumn get eventsPerKm => real().nullable()();
  RealColumn get avgHr => real().nullable()();
  IntColumn get maxHr => integer().nullable()();
  RealColumn get hrSpikeConfirmedRatio => real().nullable()();
  RealColumn get nightDrivingPct => real().nullable()();
  RealColumn get driverScore => real().nullable()();

  // Legacy metrics (backward compatibility with earlier phases)
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  RealColumn get startLat => real().nullable()();
  RealColumn get startLng => real().nullable()();
  RealColumn get endLat => real().nullable()();
  RealColumn get endLng => real().nullable()();
  RealColumn get distanceMeters => real().withDefault(const Constant(0.0))();
  RealColumn get peakSpeedKmh => real().nullable()();
  IntColumn get totalSensorRows => integer().withDefault(const Constant(0))();
  IntColumn get totalEventsCount => integer().withDefault(const Constant(0))();

  // Route & telemetry attachments
  TextColumn get routeCoordinatesJson => text().nullable()();
  TextColumn get notes => text().nullable()();
}
