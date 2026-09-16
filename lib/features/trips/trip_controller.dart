import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;

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
    this.wristSide = 'Left',
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
    state = state.copyWith(wristSide: side.trim().isEmpty ? 'Left' : side.trim());
  }

  Future<bool> startJourney({String? riderName, String wristSide = 'Left'}) async {
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
        startLat: drift.Value(startPos?.latitude),
        startLng: drift.Value(startPos?.longitude),
        routeCoordinatesJson: drift.Value(_routePoints.isNotEmpty ? jsonEncode(_routePoints) : null),
      ),
    );

    repo.setActiveTripId(tripId);
    ref.read(rideRecordingProvider.notifier).startRecording();

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
      ).listen((pos) {
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

        state = state.copyWith(
          currentPosition: pos,
          distanceMeters: totalDist,
          currentSpeedKmh: speedKmh,
          peakSpeedKmh: newPeak,
          routePoints: List.unmodifiable(_routePoints),
        );
      });
    } catch (_) {}

    return true;
  }

  Future<Trip?> endJourney() async {
    if (!state.isJourneyActive || state.activeTripId == null) return null;

    final tripId = state.activeTripId!;
    _elapsedTimer?.cancel();
    _positionSubscription?.cancel();

    Position? endPos;
    try {
      if (await Geolocator.isLocationServiceEnabled()) {
        endPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 3),
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
    }

    // Stop recording and flush buffers
    await ref.read(rideRecordingProvider.notifier).stopRecording();
    final repo = ref.read(sensorRepositoryProvider);

    final durationSec = state.elapsed.inSeconds;
    final totalRows = await repo.getReadingCountForTrip(tripId);
    final totalEvents = await repo.getEventCountForTrip(tripId);

    double avgSpeed = 0.0;
    if (durationSec > 0 && state.distanceMeters > 0) {
      avgSpeed = (state.distanceMeters / durationSec) * 3.6; // m/s to km/h
    }

    final existingTrip = await repo.getTrip(tripId);
    if (existingTrip != null) {
      final updated = existingTrip.copyWith(
        endTimeUtc: drift.Value(DateTime.now().toUtc()),
        durationSeconds: durationSec,
        endLat: drift.Value(endPos?.latitude),
        endLng: drift.Value(endPos?.longitude),
        distanceMeters: state.distanceMeters,
        avgSpeedKmh: drift.Value(avgSpeed),
        peakSpeedKmh: drift.Value(state.peakSpeedKmh),
        totalSensorRows: totalRows,
        totalEventsCount: totalEvents,
        routeCoordinatesJson: drift.Value(_routePoints.isNotEmpty ? jsonEncode(_routePoints) : null),
      );
      await repo.updateTrip(updated);
      repo.setActiveTripId(null);

      // Pass null explicitly — the _undefined sentinel pattern allows this
      state = state.copyWith(
        isJourneyActive: false,
        activeTripId: null,
        endPosition: endPos,
        sensorRowsCount: totalRows,
        eventsCount: totalEvents,
        routePoints: List.unmodifiable(_routePoints),
        lastCompletedTrip: updated,
      );

      return updated;
    }

    repo.setActiveTripId(null);
    state = state.copyWith(isJourneyActive: false, activeTripId: null);
    return null;
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
