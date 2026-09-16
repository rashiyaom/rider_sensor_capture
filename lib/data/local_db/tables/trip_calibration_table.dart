import 'package:drift/drift.dart';

class TripCalibrations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tripId => integer()();
  TextColumn get mountLocation => text()(); // 'fork' or 'footboard'
  RealColumn get engineNoiseFreqHz => real()();
  RealColumn get engineNoiseAmplitude => real()();
  DateTimeColumn get calibratedAtUtc => dateTime()();
  BoolColumn get calibrationValid => boolean().withDefault(const Constant(true))();
}
