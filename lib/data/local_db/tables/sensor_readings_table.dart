import 'package:drift/drift.dart';

class SensorReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  TextColumn get deviceType => text()();
  IntColumn get sequenceNo => integer()();
  DateTimeColumn get timestampUtc => dateTime()();
  TextColumn get sensorType => text()();

  // Linked active Event ID (nullable, directly tags readings belonging to a labeled ride event)
  IntColumn get eventId => integer().nullable()();

  // Explicit Metric Columns (high-performance querying for ML & Charts)
  IntColumn get heartRate => integer().nullable()();
  RealColumn get accelX => real().nullable()();
  RealColumn get accelY => real().nullable()();
  RealColumn get accelZ => real().nullable()();
  RealColumn get gyroX => real().nullable()();
  RealColumn get gyroY => real().nullable()();
  RealColumn get gyroZ => real().nullable()();
  IntColumn get ppiMs => integer().nullable()();

  // Raw payload for backward/forward compatibility
  TextColumn get rawPayload => text().nullable()();
}
