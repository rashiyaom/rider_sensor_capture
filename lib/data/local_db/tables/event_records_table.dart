import 'package:drift/drift.dart';

class EventRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventType => text()(); // bump, turn, speedTest, voiceTag
  DateTimeColumn get startTimestamp => dateTime()();
  DateTimeColumn get endTimestamp => dateTime().nullable()();
  RealColumn get startGpsLat => real().nullable()();
  RealColumn get startGpsLng => real().nullable()();
  RealColumn get endGpsLat => real().nullable()();
  RealColumn get endGpsLng => real().nullable()();
  TextColumn get status => text()(); // active, completed, discarded
  TextColumn get triggerPhrase => text().nullable()();

  // Computed parameters for ML training
  TextColumn get computedParameters => text().nullable()(); // JSON string
  RealColumn get peakMetric => real().nullable()();          // e.g. peak g-force or deg/s
  TextColumn get classification => text().nullable()();      // e.g. sharp/medium/easy or severe/mild

  // Linked active Trip / Journey ID (nullable)
  IntColumn get tripId => integer().nullable()();

  // Multi-sensor cross-validation & gating features
  BoolColumn get crossConfirmed => boolean().withDefault(const Constant(false))();
  RealColumn get forkFootLagMs => real().nullable()();
  BoolColumn get hrSpikeConfirmed => boolean().withDefault(const Constant(false))();
  RealColumn get hrDeltaAtEvent => real().nullable()();
  RealColumn get jerkPeakMagnitude => real().nullable()();
  RealColumn get gpsSpeedAtEventKmh => real().nullable()();
  RealColumn get gpsHeadingChangeDeg => real().nullable()();
}
