import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/services/rider_feedback_service.dart';
import '../../data/local_db/database.dart';
import '../../providers/db_providers.dart';
import '../../providers/ride_recording_provider.dart';

const Object _undefined = Object();

class TripState {
  final bool isJourneyActive;
  final int? activeTripId;
  final String riderName;
  final DateTime? startTime;
  final Duration elapsed;
  final Position? startPosition;
  final Position? currentPosition;
  final Position? endPosition;
  final double distanceMeters;
  final double currentSpeedKmh;
  final double peakSpeedKmh;
  final int sensorRowsCount;
  final int eventsCount;
  final List<Map<String, dynamic>> routePoints;
  final Trip? lastCompletedTrip;
  final String wristSide;

  const TripState({
    this.isJourneyActive = false,
    this.activeTripId,
    this.riderName = 'Rider',
    this.startTime,
    this.elapsed = Duration.zero,
    this.startPosition,
    this.currentPosition,
    this.endPosition,
    this.distanceMeters = 0.0,
    this.currentSpeedKmh = 0.0,
    this.peakSpeedKmh = 0.0,
    this.sensorRowsCount = 0,
    this.eventsCount = 0,
    this.routePoints = const [],
    this.lastCompletedTrip,
    this.wristSide = 'Both Hands',
  });

  String get formattedElapsed {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) {
      return '$h:$m:$s';
    }
    return '$m:$s';
  }

  String get formattedDistanceKm => (distanceMeters / 1000.0).toStringAsFixed(2);

  TripState copyWith({
    bool? isJourneyActive,
    Object? activeTripId = _undefined,
    String? riderName,
    DateTime? startTime,
    Duration? elapsed,
    Position? startPosition,
    Position? currentPosition,
    Position? endPosition,
    double? distanceMeters,
    double? currentSpeedKmh,
    double? peakSpeedKmh,
    int? sensorRowsCount,
    int? eventsCount,
    List<Map<String, dynamic>>? routePoints,
    Trip? lastCompletedTrip,
    String? wristSide,
  }) {
    return TripState(
      isJourneyActive: isJourneyActive ?? this.isJourneyActive,
      activeTripId: activeTripId == _undefined ? this.activeTripId : activeTripId as int?,
      riderName: riderName ?? this.riderName,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
      startPosition: startPosition ?? this.startPosition,
      currentPosition: currentPosition ?? this.currentPosition,
      endPosition: endPosition ?? this.endPosition,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      peakSpeedKmh: peakSpeedKmh ?? this.peakSpeedKmh,
      sensorRowsCount: sensorRowsCount ?? this.sensorRowsCount,
      eventsCount: eventsCount ?? this.eventsCount,
      routePoints: routePoints ?? this.routePoints,
      lastCompletedTrip: lastCompletedTrip ?? this.lastCompletedTrip,
      wristSide: wristSide ?? this.wristSide,
    );
  }
}

class TripController extends StateNotifier<TripState> {
  final Ref ref;
  Timer? _elapsedTimer;
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastGpsPoint;
  final List<Map<String, dynamic>> _routePoints = [];

  TripController(this.ref) : super(const TripState());

  void setRiderName(String name) {
    state = state.copyWith(riderName: name.trim().isEmpty ? 'Rider' : name.trim());
  }

  void setWristSide(String side) {
    state = state.copyWith(wristSide: side.trim().isEmpty ? 'Both Hands' : side.trim());
  }

  Future<bool> startJourney({String? riderName, String wristSide = 'Both Hands'}) async {
    if (state.isJourneyActive) return true;

    final chosenRider = (riderName != null && riderName.trim().isNotEmpty)
        ? riderName.trim()
        : state.riderName;

    Position? startPos;
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied || req == LocationPermission.deniedForever) {
          // Continue without GPS if denied
        }
      }
      if (await Geolocator.isLocationServiceEnabled()) {
        startPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
          ),
        );
      }
    } catch (_) {}

    final repo = ref.read(sensorRepositoryProvider);
    final now = DateTime.now();

    _routePoints.clear();
    if (startPos != null) {
      _routePoints.add({
        'lat': startPos.latitude,
        'lng': startPos.longitude,
        'speed_kmh': 0.0,
        'altitude': startPos.altitude,
        'timestamp_utc': now.toUtc().toIso8601String(),
      });
    }

    // Create new Trip record in SQLite
    final tripId = await repo.createTrip(
      TripsCompanion(
        riderName: drift.Value(chosenRider),
        wristSide: drift.Value(wristSide),
        startTimeUtc: drift.Value(now.toUtc()),
        startTimestampUtc: drift.Value(now.toUtc()),
        startLat: drift.Value(startPos?.latitude),
        startLng: drift.Value(startPos?.longitude),
        routeCoordinatesJson: drift.Value(_routePoints.isNotEmpty ? jsonEncode(_routePoints) : null),
      ),
    );

    // Persist start GPS fix to location_readings
    if (startPos != null) {
      try {
        await repo.insertLocationReading(
          LocationReadingsCompanion.insert(
            tripId: tripId,
            timestampUtc: now.toUtc(),
            latitude: startPos.latitude,
            longitude: startPos.longitude,
            altitude: drift.Value(startPos.altitude),
            gpsSpeedMps: drift.Value(0.0),
            gpsHeadingDeg: drift.Value(startPos.heading >= 0 ? startPos.heading : null),
            gpsAccuracyM: drift.Value(startPos.accuracy),
          ),
        );
      } catch (_) {}
    }

    repo.setActiveTripId(tripId);
    ref.read(rideRecordingProvider.notifier).startRecording();
    unawaited(RiderFeedbackService.onTripStarted());

    _lastGpsPoint = startPos;
    state = TripState(
      isJourneyActive: true,
      activeTripId: tripId,
      riderName: chosenRider,
      wristSide: wristSide,
      startTime: now,
      elapsed: Duration.zero,
      startPosition: startPos,
      currentPosition: startPos,
      distanceMeters: 0.0,
      currentSpeedKmh: 0.0,
      peakSpeedKmh: 0.0,
      sensorRowsCount: 0,
      eventsCount: 0,
      routePoints: List.unmodifiable(_routePoints),
    );

    // Start 1-second elapsed timer
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !state.isJourneyActive || state.startTime == null) return;
      final diff = DateTime.now().difference(state.startTime!);
      state = state.copyWith(elapsed: diff);
    });

    // Start live GPS tracking stream
    _positionSubscription?.cancel();
    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3, // Update every 3 meters
        ),
      ).listen(
        (pos) {
          if (!mounted || !state.isJourneyActive) return;

          double addedDist = 0.0;
          if (_lastGpsPoint != null) {
            addedDist = Geolocator.distanceBetween(
              _lastGpsPoint!.latitude,
              _lastGpsPoint!.longitude,
              pos.latitude,
              pos.longitude,
            );
          }
          _lastGpsPoint = pos;

          final speedKmh = pos.speed >= 0 ? pos.speed * 3.6 : 0.0;
          final newPeak = speedKmh > state.peakSpeedKmh ? speedKmh : state.peakSpeedKmh;
          final totalDist = state.distanceMeters + addedDist;

          _routePoints.add({
            'lat': pos.latitude,
            'lng': pos.longitude,
            'speed_kmh': speedKmh,
            'altitude': pos.altitude,
            'timestamp_utc': pos.timestamp.toUtc().toIso8601String(),
          });

          // Persist live GPS reading to SQLite
          try {
            repo.insertLocationReading(
              LocationReadingsCompanion.insert(
                tripId: tripId,
                timestampUtc: pos.timestamp.toUtc(),
                latitude: pos.latitude,
                longitude: pos.longitude,
                altitude: drift.Value(pos.altitude),
                gpsSpeedMps: drift.Value(pos.speed >= 0 ? pos.speed : null),
                gpsHeadingDeg: drift.Value(pos.heading >= 0 ? pos.heading : null),
                gpsAccuracyM: drift.Value(pos.accuracy),
              ),
            );
          } catch (_) {}

          state = state.copyWith(
            currentPosition: pos,
            distanceMeters: totalDist,
            currentSpeedKmh: speedKmh,
            peakSpeedKmh: newPeak,
            routePoints: List.unmodifiable(_routePoints),
          );
        },
        onError: (error) {
          // GPS stream error ignored cleanly
        },
        cancelOnError: false,
      );
    } catch (_) {}

    return true;
  }

  Future<Trip?> endJourney() async {
    if (!state.isJourneyActive) return null;

    final tripId = state.activeTripId;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;

    final repo = ref.read(sensorRepositoryProvider);
    final db = ref.read(appDatabaseProvider);
    Trip? savedTrip;

    try {
      // 1. Stop recording and flush buffers immediately
      try {
        await ref.read(rideRecordingProvider.notifier).stopRecording();
      } catch (_) {}

      // 2. Fetch end GPS position with a 2-second timeout
      Position? endPos;
      try {
        if (await Geolocator.isLocationServiceEnabled()) {
          endPos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 2),
            ),
          );
        }
      } catch (_) {}

      endPos ??= state.currentPosition ?? state.startPosition;

      if (endPos != null) {
        _routePoints.add({
          'lat': endPos.latitude,
          'lng': endPos.longitude,
          'speed_kmh': 0.0,
          'altitude': endPos.altitude,
          'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
        });

        if (tripId != null) {
          try {
            await repo.insertLocationReading(
              LocationReadingsCompanion.insert(
                tripId: tripId,
                timestampUtc: DateTime.now().toUtc(),
                latitude: endPos.latitude,
                longitude: endPos.longitude,
                altitude: drift.Value(endPos.altitude),
                gpsSpeedMps: drift.Value(0.0),
                gpsHeadingDeg: drift.Value(endPos.heading >= 0 ? endPos.heading : null),
                gpsAccuracyM: drift.Value(endPos.accuracy),
              ),
            );
          } catch (_) {}
        }
      }

      // 3. Update database record if tripId is present
      if (tripId != null) {
        final durationSec = state.elapsed.inSeconds;
        int totalRows = 0;
        int totalEvents = 0;
        try {
          totalRows = await repo.getReadingCountForTrip(tripId);
          totalEvents = await repo.getEventCountForTrip(tripId);
        } catch (_) {}

        double avgSpeed = 0.0;
        if (durationSec > 0 && state.distanceMeters > 0) {
          avgSpeed = (state.distanceMeters / durationSec) * 3.6; // m/s to km/h
        }

        final distKm = state.distanceMeters / 1000.0;
        final durationMin = durationSec / 60.0;

        // Query events to compute classification counts
        int bumps = 0;
        int turns = 0;
        int brakes = 0;
        int accels = 0;
        int confirmed = 0;
        try {
          final tripEvents = await (db.select(db.eventRecords)..where((t) => t.tripId.equals(tripId))).get();
          bumps = tripEvents.where((e) => e.eventType.toLowerCase().contains('bump')).length;
          turns = tripEvents.where((e) => e.eventType.toLowerCase().contains('turn')).length;
          brakes = tripEvents.where((e) => e.eventType.toLowerCase().contains('brake') || (e.classification?.contains('braking') ?? false)).length;
          accels = tripEvents.where((e) => e.eventType.toLowerCase().contains('accel') || (e.classification?.contains('accel') ?? false)).length;
          confirmed = tripEvents.where((e) => e.crossConfirmed).length;
        } catch (_) {}

        // Query heart rate readings
        double? avgHr;
        int? maxHr;
        try {
          final hrReadings = await (db.select(db.sensorReadings)
                ..where((t) => t.tripId.equals(tripId) & t.heartRate.isNotNull() & t.heartRate.isBiggerThanValue(30)))
              .get();
          if (hrReadings.isNotEmpty) {
            final hrs = hrReadings.map((r) => r.heartRate!).toList();
            maxHr = hrs.reduce(math.max);
            avgHr = hrs.reduce((a, b) => a + b) / hrs.length;
          }
        } catch (_) {}

        double? eventsPerKm;
        if (distKm > 0.05) {
          eventsPerKm = totalEvents / distKm;
        }
        final driverScore = (100.0 - (brakes * 4.0) - (turns * 2.5) - (bumps * 1.0)).clamp(10.0, 100.0);

        try {
          final existingTrip = await repo.getTrip(tripId);
          if (existingTrip != null) {
            final updated = existingTrip.copyWith(
              endTimeUtc: drift.Value(DateTime.now().toUtc()),
              endTimestampUtc: drift.Value(DateTime.now().toUtc()),
              durationSeconds: durationSec,
              totalDistanceKm: drift.Value(distKm),
              totalDurationMin: drift.Value(durationMin),
              endLat: drift.Value(endPos?.latitude),
              endLng: drift.Value(endPos?.longitude),
              distanceMeters: state.distanceMeters,
              avgSpeedKmh: drift.Value(avgSpeed),
              maxSpeedKmh: drift.Value(state.peakSpeedKmh),
              peakSpeedKmh: drift.Value(state.peakSpeedKmh),
              totalSensorRows: totalRows,
              totalEventsCount: totalEvents,
              bumpCount: bumps,
              harshTurnCount: turns,
              harshBrakeCount: brakes,
              harshAccelCount: accels,
              confirmedEventCount: confirmed,
              eventsPerKm: drift.Value(eventsPerKm),
              avgHr: drift.Value(avgHr),
              maxHr: drift.Value(maxHr),
              driverScore: drift.Value(driverScore),
              routeCoordinatesJson: drift.Value(_routePoints.isNotEmpty ? jsonEncode(_routePoints) : null),
            );
            await repo.updateTrip(updated);
            savedTrip = updated;
          }
        } catch (_) {}
      }
    } catch (_) {
      // Catch any unexpected exceptions to guarantee clean state transition
    } finally {
      try {
        repo.setActiveTripId(null);
      } catch (_) {}

      state = state.copyWith(
        isJourneyActive: false,
        activeTripId: null,
        endPosition: state.currentPosition ?? state.startPosition,
        lastCompletedTrip: savedTrip ?? state.lastCompletedTrip,
      );
      unawaited(RiderFeedbackService.onTripStopped());
    }

    return savedTrip;
  }

  void incrementSensorRows(int count) {
    if (state.isJourneyActive) {
      state = state.copyWith(sensorRowsCount: state.sensorRowsCount + count);
    }
  }

  void incrementEvents(int count) {
    if (state.isJourneyActive) {
      state = state.copyWith(eventsCount: state.eventsCount + count);
    }
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}

final tripControllerProvider =
    StateNotifierProvider<TripController, TripState>((ref) {
  return TripController(ref);
});

/// Stream of all saved trips from SQLite ordered by descending start time
final allTripsStreamProvider = StreamProvider.autoDispose<List<Trip>>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.watchAllTrips();
});
