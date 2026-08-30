import '../local_db/database.dart';
import '../../ble/models/raw_sensor_data.dart';
import '../../providers/db_providers.dart';

abstract class SensorRepository {
  void setActiveEventId(int? eventId);
  int? get activeEventId;

  Future<void> insertReading(RawSensorData data);
  Future<void> insertReadingsBatch(List<RawSensorData> dataList);
  Stream<List<SensorReading>> watchRecentReadings({int limit = 50});
  Stream<List<SensorReading>> watchReadingsForDevice(String deviceId, {int limit = 50});
  Stream<List<SensorReading>> watchReadingsForEvent(int eventId);
  Future<int> getReadingCountForEvent(int eventId);
  Future<int> getTotalCount();
  Future<Map<String, int>> getCountPerDevice();
  Future<DateTime?> getLastWriteTime();
  Future<int> getLastSequenceNoForDevice(String deviceId);

  /// Real-time live SQLite database write and row count statistics
  Stream<DbWriteStats> watchStats();

  // Event persistence methods
  Future<int> createEventRecord(EventRecordsCompanion event);
  Future<void> updateEventRecord(EventRecord event);
  Stream<List<EventRecord>> watchAllEvents();

  /// Delete all sensor readings (Clear Ride Telemetry)
  Future<void> deleteAllReadings();

  /// Delete a single event record and its associated sensor readings
  Future<void> deleteEvent(int eventId);

  void dispose();
}
