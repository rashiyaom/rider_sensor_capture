import 'dart:async';
import 'dart:math' as math;
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_db/database.dart';
import '../location/location_service.dart';
import 'db_providers.dart';

class TripState {
  final bool isTripActive;
  final int? activeTripId;
  final DateTime? startTimestampUtc;
  final double totalDistanceKm;
  final double currentSpeedKmh;
  final int locationFixCount;

  const TripState({
    this.isTripActive = false,
    this.activeTripId,
    this.startTimestampUtc,
    this.totalDistanceKm = 0.0,
    this.currentSpeedKmh = 0.0,
    this.locationFixCount = 0,
  });

  TripState copyWith({
    bool? isTripActive,
    int? activeTripId,
    DateTime? startTimestampUtc,
    double? totalDistanceKm,
    double? currentSpeedKmh,
    int? locationFixCount,
  }) {
    return TripState(
      isTripActive: isTripActive ?? this.isTripActive,
      activeTripId: activeTripId ?? this.activeTripId,
      startTimestampUtc: startTimestampUtc ?? this.startTimestampUtc,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      locationFixCount: locationFixCount ?? this.locationFixCount,
    );
  }
}

class TripController extends StateNotifier<TripState> {
  final Ref ref;
  final LocationService _locationService = LocationService();
  StreamSubscription<LocationFix>? _locSubscription;
  LocationFix? _previousFix;

  TripController(this.ref) : super(const TripState());

  LocationService get locationService => _locationService;

  /// Start a new Trip
  Future<int> startTrip({String riderName = 'Rider'}) async {
    if (state.isTripActive && state.activeTripId != null) {
      return state.activeTripId!;
    }

    final now = DateTime.now().toUtc();
    final db = ref.read(appDatabaseProvider);

    final tripCompanion = TripsCompanion.insert(
      riderName: Value(riderName),
      startTimeUtc: now,
      startTimestampUtc: Value(now),
    );

    final tripId = await db.into(db.trips).insert(tripCompanion);

    // Update repositories with active trip ID
    ref.read(sensorRepositoryProvider).setActiveTripId(tripId);

    state = TripState(
      isTripActive: true,
      activeTripId: tripId,
      startTimestampUtc: now,
      totalDistanceKm: 0.0,
      currentSpeedKmh: 0.0,
      locationFixCount: 0,
    );

    // Start Location Ingestion
    await _locationService.startTracking();
    _previousFix = null;

    _locSubscription?.cancel();
    _locSubscription = _locationService.fixStream.listen((fix) async {
      if (!mounted || !state.isTripActive || state.activeTripId == null) return;

      double addedDistKm = 0.0;
      if (_previousFix != null) {
        addedDistKm = _calculateDistanceKm(
          _previousFix!.latitude,
          _previousFix!.longitude,
          fix.latitude,
          fix.longitude,
        );
      }
      _previousFix = fix;

      final newDist = state.totalDistanceKm + addedDistKm;

      state = state.copyWith(
        totalDistanceKm: newDist,
        currentSpeedKmh: fix.speedKmh ?? 0.0,
        locationFixCount: state.locationFixCount + 1,
      );

      // Persist to location_readings
      try {
        await db.into(db.locationReadings).insert(
              LocationReadingsCompanion.insert(
                tripId: tripId,
                timestampUtc: fix.timestampUtc,
                latitude: fix.latitude,
                longitude: fix.longitude,
                altitude: Value(fix.altitude),
                gpsSpeedMps: Value(fix.gpsSpeedMps),
                gpsHeadingDeg: Value(fix.gpsHeadingDeg),
                gpsAccuracyM: Value(fix.gpsAccuracyM),
              ),
            );
      } catch (_) {}
    });

    return tripId;
  }

  /// Stop the active trip and compute comprehensive aggregate features
  Future<Trip?> stopTrip() async {
    if (!state.isTripActive || state.activeTripId == null) return null;

    final tripId = state.activeTripId!;
    final now = DateTime.now().toUtc();

    await _locationService.stopTracking();
    await _locSubscription?.cancel();
    _locSubscription = null;

    final db = ref.read(appDatabaseProvider);
    final repo = ref.read(sensorRepositoryProvider);
    repo.setActiveTripId(null);

    // Compute aggregate metrics
    final start = state.startTimestampUtc ?? now;
    final durationMin = now.difference(start).inMilliseconds / (1000.0 * 60.0);

    // 1. Location readings aggregates
    final locs = await (db.select(db.locationReadings)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestampUtc)]))
        .get();

    double totalDistKm = state.totalDistanceKm;
    if (totalDistKm <= 0 && locs.length >= 2) {
      for (int i = 1; i < locs.length; i++) {
        totalDistKm += _calculateDistanceKm(
          locs[i - 1].latitude,
          locs[i - 1].longitude,
          locs[i].latitude,
          locs[i].longitude,
        );
      }
    }

    double? avgSpeedKmh;
    double? maxSpeedKmh;
    final speeds = locs
        .where((l) => l.gpsSpeedMps != null && l.gpsSpeedMps! >= 0)
        .map((l) => l.gpsSpeedMps! * 3.6)
        .toList();

    if (speeds.isNotEmpty) {
      avgSpeedKmh = speeds.reduce((a, b) => a + b) / speeds.length;
      maxSpeedKmh = speeds.reduce(math.max);
    }

    // 2. Events aggregates
    final events = await (db.select(db.eventRecords)
          ..where((t) => t.tripId.equals(tripId)))
        .get();

    int harshBrakeCount = 0;
    int harshAccelCount = 0;
    int harshTurnCount = 0;
    int bumpCount = 0;
    int confirmedCount = 0;

    for (final e in events) {
      if (e.eventType == 'bump') bumpCount++;
      if (e.eventType == 'turn' && e.classification == 'sharp') harshTurnCount++;
      if (e.eventType == 'speedTest' && e.classification == 'braking') harshBrakeCount++;
      if (e.crossConfirmed) confirmedCount++;
    }

    final eventsPerKm = totalDistKm > 0.05 ? confirmedCount / totalDistKm : null;

    // 3. Sensor readings aggregates (HR)
    final readings = await (db.select(db.sensorReadings)
          ..where((t) => t.tripId.equals(tripId)))
        .get();

    final hrValues = readings
        .where((r) => r.heartRate != null && r.heartRate! > 30 && r.heartRate! < 220)
        .map((r) => r.heartRate!)
        .toList();

    double? avgHr;
    int? maxHr;
    if (hrValues.isNotEmpty) {
      avgHr = hrValues.reduce((a, b) => a + b) / hrValues.length;
      maxHr = hrValues.reduce(math.max);
    }

    final hrSpikeConfirmedRatio =
        events.isNotEmpty ? (confirmedCount / events.length) : null;

    // 4. Night driving percentage (default 19:00 - 06:00)
    final nightDrivingPct = _calculateNightDrivingPct(start, now);

    // 5. Driver score calculation (baseline 100, penalized by harsh events/km)
    double score = 100.0;
    if (totalDistKm > 0.1) {
      final penaltyPerKm = (harshBrakeCount * 3.0 + harshTurnCount * 2.0 + bumpCount * 1.0) / totalDistKm;
      score = math.max(10.0, 100.0 - penaltyPerKm * 5.0);
    } else {
      score = 95.0;
    }

    // Update Trips table
    await (db.update(db.trips)..where((t) => t.id.equals(tripId))).write(
      TripsCompanion(
        endTimestampUtc: Value(now),
        totalDistanceKm: Value(totalDistKm),
        totalDurationMin: Value(durationMin),
        avgSpeedKmh: Value(avgSpeedKmh),
        maxSpeedKmh: Value(maxSpeedKmh),
        harshBrakeCount: Value(harshBrakeCount),
        harshAccelCount: Value(harshAccelCount),
        harshTurnCount: Value(harshTurnCount),
        bumpCount: Value(bumpCount),
        confirmedEventCount: Value(confirmedCount),
        eventsPerKm: Value(eventsPerKm),
        avgHr: Value(avgHr),
        maxHr: Value(maxHr),
        hrSpikeConfirmedRatio: Value(hrSpikeConfirmedRatio),
        nightDrivingPct: Value(nightDrivingPct),
        driverScore: Value(score),
      ),
    );

    state = const TripState();

    return (db.select(db.trips)..where((t) => t.id.equals(tripId))).getSingleOrNull();
  }

  /// Haversine distance in kilometers
  static double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth radius in km
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Calculate percentage of trip that occurred during night hours (19:00 - 06:00)
  static double _calculateNightDrivingPct(DateTime start, DateTime end) {
    final totalMs = end.difference(start).inMilliseconds;
    if (totalMs <= 0) return 0.0;

    int nightMs = 0;
    DateTime cur = start;
    while (cur.isBefore(end)) {
      final hour = cur.toLocal().hour;
      final isNight = hour >= 19 || hour < 6;
      if (isNight) {
        nightMs += 60000;
      }
      cur = cur.add(const Duration(minutes: 1));
    }

    return (nightMs / totalMs).clamp(0.0, 1.0) * 100.0;
  }

  @override
  void dispose() {
    _locSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }
}

final tripControllerProvider =
    StateNotifierProvider<TripController, TripState>((ref) {
  return TripController(ref);
});

final activeTripIdProvider = Provider<int?>((ref) {
  return ref.watch(tripControllerProvider.select((s) => s.activeTripId));
});
