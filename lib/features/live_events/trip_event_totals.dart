import 'package:drift/drift.dart';
import '../../data/local_db/database.dart';

/// Keep trip history counts consistent after event confirmation or editing.
Future<void> refreshTripEventTotals(AppDatabase db, int tripId) async {
  final trip = await (db.select(db.trips)..where((t) => t.id.equals(tripId))).getSingleOrNull();
  if (trip == null) return;
  final rows = await (db.select(db.eventRecords)
    ..where((t) => t.tripId.equals(tripId) & t.status.equals('completed'))).get();
  int count(bool Function(EventRecord) matches) => rows.where(matches).length;
  final bumps = count((e) => e.eventType.contains('bump') || e.eventType == 'pothole');
  final turns = count((e) => e.eventType.contains('turn'));
  final brakes = count((e) => e.eventType.contains('brak') || e.eventType.toLowerCase() == 'speedtest');
  final distance = trip.distanceMeters / 1000;
  await (db.update(db.trips)..where((t) => t.id.equals(tripId))).write(TripsCompanion(
    totalEventsCount: Value(rows.length), bumpCount: Value(bumps), harshTurnCount: Value(turns),
    harshBrakeCount: Value(brakes), harshAccelCount: Value(count((e) => e.eventType.contains('accel'))),
    confirmedEventCount: Value(count((e) => e.crossConfirmed)),
    eventsPerKm: Value(distance > .05 ? rows.length / distance : null),
    driverScore: Value((100.0 - brakes * 4 - turns * 2.5 - bumps).clamp(10.0, 100.0)),
  ));
}
