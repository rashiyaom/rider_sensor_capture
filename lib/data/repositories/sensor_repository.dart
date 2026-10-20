import '../local_db/database.dart';
import '../../ble/models/raw_sensor_data.dart';
import '../../providers/db_providers.dart';

abstract class SensorRepository {
  void setActiveEventId(int? eventId);
  int? get activeEventId;

  void setActiveTripId(int? tripId);
  int? get activeTripId;

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

  // Trip / Journey persistence methods
  Future<int> createTrip(TripsCompanion trip);
  Future<void> updateTrip(Trip trip);
  Future<Trip?> getTrip(int tripId);
  Stream<List<Trip>> watchAllTrips();
  Future<void> deleteTrip(int tripId);
  Future<int> getReadingCountForTrip(int tripId);
  Future<int> getEventCountForTrip(int tripId);
  Future<int> insertLocationReading(LocationReadingsCompanion reading);

  /// Analyzes BLE sequence numbers for the trip to detect packet loss and continuity
  Future<BleQualityStats> getTripBleQuality(int tripId);

  // ── Predictive pre-alert & feedback learning loop ────────────────────────

  /// Registers a geo-tagged road event (hazard) in the knowledge base.
  Future<int> insertRoadEvent(RoadEventsCompanion event);

  /// Loads the geo-tagged road events within [radiusMeters] of a position.
  Future<List<RoadEvent>> getRoadEventsNear({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  });

  /// All known road events (hazards), newest first.
  Stream<List<RoadEvent>> watchRoadEvents();

  /// Persists a spoken pre-alert.
  Future<int> insertPreAlert(PreAlertsCompanion alert);

  /// Watch stream of all pre-alerts (newest first).
  Stream<List<PreAlert>> watchPreAlerts();

  /// The most recent pre-alert, optionally restricted to a trip.
  Future<PreAlert?> getMostRecentPreAlert({int? tripId});

  /// Persists a rider feedback record.
  Future<int> insertEventFeedback(EventFeedbacksCompanion feedback);

  /// Updates a feedback record with the LLM analysis.
  Future<void> updateEventFeedback(EventFeedbacksCompanion feedback);

  /// Watch stream of all feedback records (newest first).
  Stream<List<EventFeedback>> watchEventFeedbacks();

  /// Feedback recorded for a specific labeled event.
  Future<List<EventFeedback>> getFeedbackForEvent(int eventId);

  /// Number of feedback records recorded for an event.
  Future<int> getFeedbackCountForEvent(int eventId);

  /// Deletes raw continuous sensor readings that are not associated with any labeled event,
  /// preserving labeled ground-truth event segments and freeing SQLite storage.
  Future<int> deleteUntaggedReadingsForTrip(int tripId);

  /// Delete all sensor readings (Clear Ride Telemetry)
  Future<void> deleteAllReadings();

  /// Delete a single event record and its associated sensor readings
  Future<void> deleteEvent(int eventId);

  /// Flushes any in-memory buffered readings immediately to SQLite
  Future<void> flushPendingBuffer();

  void dispose();
}

class BleQualityStats {
  final int totalPackets;
  final int droppedPackets;
  final double receptionPercentage;
  final int gapCount;

  const BleQualityStats({
    required this.totalPackets,
    required this.droppedPackets,
    required this.receptionPercentage,
    required this.gapCount,
  });
}
