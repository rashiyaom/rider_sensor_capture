import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

import 'location_quality.dart';

/// Structured GPS reading emitted by LocationService.
class LocationFix {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? gpsSpeedMps;
  final double? gpsHeadingDeg;
  final double? gpsAccuracyM;
  final DateTime timestampUtc;

  const LocationFix({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.gpsSpeedMps,
    this.gpsHeadingDeg,
    this.gpsAccuracyM,
    required this.timestampUtc,
  });

  double? get speedKmh => gpsSpeedMps != null ? gpsSpeedMps! * 3.6 : null;

  factory LocationFix.fromPosition(Position p) {
    return LocationFix(
      latitude: p.latitude,
      longitude: p.longitude,
      altitude: p.altitude,
      gpsSpeedMps: p.speed >= 0 ? p.speed : null,
      gpsHeadingDeg: p.heading >= 0 ? p.heading : null,
      gpsAccuracyM: p.accuracy,
      timestampUtc: p.timestamp.toUtc(),
    );
  }
}

/// Rolling features derived from high-frequency GPS stream.
class GpsDerivedFeatures {
  final double? gpsAccelMps2;
  final double? speedVarianceWindow;
  final bool overspeedFlag;
  final double? speedLimitKmh;

  const GpsDerivedFeatures({
    this.gpsAccelMps2,
    this.speedVarianceWindow,
    this.overspeedFlag = false,
    this.speedLimitKmh,
  });
}

/// Service wrapping Geolocator providing continuous position streaming and derived features.
class LocationService {
  final DateTime Function() now;
  LocationService({DateTime Function()? clock}) : now = clock ?? DateTime.now;
  int _generation = 0;
  bool isTracking = false;
  String? lastError;
  bool get hasFreshFix =>
      _lastFix != null &&
      now().toUtc().difference(_lastFix!.timestampUtc) <=
          const Duration(seconds: 10);

  StreamSubscription<Position>? _positionSubscription;
  final StreamController<LocationFix> _fixController =
      StreamController<LocationFix>.broadcast();
  final StreamController<GpsDerivedFeatures> _featuresController =
      StreamController<GpsDerivedFeatures>.broadcast();

  final List<LocationFix> _recentFixes = [];
  static const int _windowSize = 5;

  LocationFix? _lastFix;
  double? speedLimitKmh;

  Stream<LocationFix> get fixStream => _fixController.stream;
  Stream<GpsDerivedFeatures> get featuresStream => _featuresController.stream;
  LocationFix? get currentFix => _lastFix;

  /// Check and request location permissions.
  Future<bool> checkPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Start streaming GPS updates (1Hz default cadence).
  Future<bool> startTracking({
    int intervalMs = 1000,
    int distanceFilterM = 0,
  }) async {
    await stopTracking();
    final generation = _generation;
    final hasPerm = await checkPermission();
    if (generation != _generation) return false;
    if (!hasPerm) {
      lastError = 'Location permission or GPS service is unavailable.';
      return false;
    }

    // A stream-wide timeout cancels tracking after a short GPS outage.
    // Keep listening so fixes can resume when the rider leaves a tunnel.
    final LocationSettings locationSettings =
        defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: distanceFilterM,
            intervalDuration: Duration(milliseconds: intervalMs),
          )
        : LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: distanceFilterM,
          );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            if (generation != _generation) return;
            final fix = LocationFix.fromPosition(position);
            _onNewFix(fix);
          },
          onError: (err) {
            if (generation != _generation) return;
            lastError =
                'GPS updates failed. Check location services and permissions.';
            _lastFix = null;
          },
          onDone: () {
            if (generation != _generation) return;
            isTracking = false;
            lastError = 'GPS tracking stopped. Restart tracking to recover.';
            _lastFix = null;
          },
        );
    isTracking = true;
    lastError = null;
    return true;
  }

  /// Process new fix and compute derived features.
  void _onNewFix(LocationFix fix, {DateTime? observedAt}) {
    if (!LocationQuality.accepts(
      latitude: fix.latitude,
      longitude: fix.longitude,
      timestamp: fix.timestampUtc,
      now: observedAt ?? now().toUtc(),
      accuracy: fix.gpsAccuracyM,
      speedMps: fix.gpsSpeedMps,
      previousLatitude: _lastFix?.latitude,
      previousLongitude: _lastFix?.longitude,
      previousTime: _lastFix?.timestampUtc,
    ))
      return;
    lastError = null;
    _recentFixes.add(fix);
    if (_recentFixes.length > _windowSize) {
      _recentFixes.removeAt(0);
    }

    double? accelMps2;
    if (_lastFix != null &&
        fix.gpsSpeedMps != null &&
        _lastFix!.gpsSpeedMps != null) {
      final dt =
          fix.timestampUtc.difference(_lastFix!.timestampUtc).inMilliseconds /
          1000.0;
      if (dt > 0.05 && dt < 5.0) {
        accelMps2 = (fix.gpsSpeedMps! - _lastFix!.gpsSpeedMps!) / dt;
      }
    }

    double? speedVariance;
    final validSpeeds = _recentFixes
        .where((f) => f.gpsSpeedMps != null)
        .map((f) => f.gpsSpeedMps!)
        .toList();

    if (validSpeeds.length >= 3) {
      final mean = validSpeeds.reduce((a, b) => a + b) / validSpeeds.length;
      final sumSq = validSpeeds.fold<double>(
        0.0,
        (prev, s) => prev + (s - mean) * (s - mean),
      );
      speedVariance = sumSq / validSpeeds.length;
    }

    bool isOverspeed = false;
    if (speedLimitKmh != null && fix.speedKmh != null) {
      isOverspeed = fix.speedKmh! > speedLimitKmh!;
    }

    _lastFix = fix;

    final derived = GpsDerivedFeatures(
      gpsAccelMps2: accelMps2,
      speedVarianceWindow: speedVariance,
      overspeedFlag: isOverspeed,
      speedLimitKmh: speedLimitKmh,
    );

    if (!_fixController.isClosed) {
      _fixController.add(fix);
    }
    if (!_featuresController.isClosed) {
      _featuresController.add(derived);
    }
  }

  /// Manually inject a fix (useful for testing and replay).
  void injectFixForTesting(LocationFix fix) {
    _onNewFix(fix, observedAt: fix.timestampUtc);
  }

  /// Stop GPS tracking.
  Future<void> stopTracking() async {
    _generation++;
    isTracking = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _recentFixes.clear();
    _lastFix = null;
  }

  void dispose() {
    stopTracking();
    _fixController.close();
    _featuresController.close();
  }
}
