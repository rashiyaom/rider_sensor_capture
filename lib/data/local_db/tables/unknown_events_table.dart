import 'package:drift/drift.dart';

/// Persistent store for IMU-detected events whose kind was not recognised by
/// the on-device classifier.
///
/// When the ML pipeline detects an anomalous IMU signature that does not map
/// to any known event type the app asks the rider (via earbuds / TTS) what
/// happened.  The rider's voice answer is transcribed and stored here.
///
/// Later passes can re-classify the row or promote it to a [RoadEvents] entry.
class UnknownEvents extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The trip during which the anomaly was detected.
  IntColumn get tripId => integer().nullable()();

  /// GPS latitude at the moment the anomaly was detected.
  RealColumn get latitude => real().nullable()();

  /// GPS longitude at the moment the anomaly was detected.
  RealColumn get longitude => real().nullable()();

  /// Raw IMU signal statistics captured around the event window (JSON).
  TextColumn get imuSnapshotJson => text().nullable()();

  /// Peak acceleration magnitude (m/s²) during the anomaly window.
  RealColumn get peakAccelMagnitude => real().nullable()();

  /// Duration of the anomaly window in milliseconds.
  IntColumn get durationMs => integer().nullable()();

  /// The exact text spoken to the rider when asking "what was that?".
  TextColumn get questionSpoken => text()();

  /// The rider's raw transcribed answer.
  TextColumn get riderAnswerRaw => text().nullable()();

  /// STT confidence (0..1) for the rider's answer.
  RealColumn get transcriptConfidence => real().nullable()();

  /// Normalised event label derived from the rider's answer (e.g. "speed_bump").
  TextColumn get resolvedLabel => text().nullable()();

  /// Whether the resolved label was promoted to road_events.
  BoolColumn get promoted =>
      boolean().withDefault(const Constant(false))();

  /// The road_event row id created when the event was promoted (if any).
  IntColumn get promotedRoadEventId => integer().nullable()();

  /// Timestamp when the anomaly was first detected.
  DateTimeColumn get detectedAtUtc => dateTime()();

  /// Timestamp when the rider's answer was recorded.
  DateTimeColumn get answeredAtUtc => dateTime().nullable()();
}
