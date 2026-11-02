import 'package:drift/drift.dart';

import 'event_records_table.dart';
import 'trips_table.dart';

/// Durable manifest for JPEGs captured from a connected UVC camera.
///
/// Image bytes live in app-owned storage. These rows keep every image ordered
/// and joined to the ride and incident that were active when it was captured.
class CameraCaptures extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get captureKey => text().unique()();
  TextColumn get deviceId => text()();
  IntColumn get sequenceNo => integer()();
  DateTimeColumn get capturedAtUtc => dateTime()();
  DateTimeColumn get receivedAtUtc => dateTime()();
  IntColumn get tripId => integer().nullable().references(
    Trips,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get linkedEventId => integer().nullable().references(
    EventRecords,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get filePath => text()();
  TextColumn get mimeType => text().withDefault(const Constant('image/jpeg'))();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  IntColumn get byteLength => integer()();
  TextColumn get sha256 => text()();

  /// manual | camera_button | incident | interval
  TextColumn get trigger => text().withDefault(const Constant('manual'))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {deviceId, sequenceNo},
  ];
}
