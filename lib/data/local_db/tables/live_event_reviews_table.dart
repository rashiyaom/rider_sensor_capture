import 'package:drift/drift.dart';

/// Sensor detections and rider responses, awaiting an explicit location decision.
class LiveEventReviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tripId => integer()();
  IntColumn get eventId => integer().nullable()();
  TextColumn get eventType => text()();
  DateTimeColumn get detectedAtUtc => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get gpsAccuracyM => real().nullable()();
  RealColumn get confidence => real()();
  TextColumn get sensorFeaturesJson => text()();
  TextColumn get confirmationReply => text().nullable()();
  BoolColumn get confirmed => boolean().nullable()();
  TextColumn get feedback => text().nullable()();

  /// pending | saved | discarded
  TextColumn get reviewStatus =>
      text().withDefault(const Constant('pending'))();
  IntColumn get roadEventId => integer().nullable()();
}
