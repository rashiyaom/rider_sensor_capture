import 'package:drift/drift.dart';

import 'event_records_table.dart';

class CameraDetections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  TextColumn get eventClass => text()();
  RealColumn get confidence => real()();
  DateTimeColumn get cameraTimestampUtc => dateTime()();
  DateTimeColumn get receivedAtUtc => dateTime()();
  // Nullable FK: set when this detection falls within an active/recent EventRecord window
  IntColumn get linkedEventId =>
      integer().nullable().references(EventRecords, #id)();
}
