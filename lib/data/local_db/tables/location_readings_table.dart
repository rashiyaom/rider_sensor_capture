import 'package:drift/drift.dart';

class LocationReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tripId => integer()();
  DateTimeColumn get timestampUtc => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get gpsSpeedMps => real().nullable()();
  RealColumn get gpsHeadingDeg => real().nullable()();
  RealColumn get gpsAccuracyM => real().nullable()();
}
