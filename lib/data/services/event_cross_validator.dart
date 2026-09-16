import 'dart:math' as math;
import '../local_db/database.dart';
import '../../core/utils/angular_units.dart';

/// Result of multi-sensor cross-correlation validation between fork and footboard IMUs.
class CrossValidationResult {
  final bool crossConfirmed;
  final double? forkFootLagMs;
  final double? forkPeakJerk;
  final double? footboardPeakJerk;

  const CrossValidationResult({
    required this.crossConfirmed,
    this.forkFootLagMs,
    this.forkPeakJerk,
    this.footboardPeakJerk,
  });
}

class EventCrossValidator {
  /// Default temporal window to search for correlated spike (ms)
  static const int bumpWindowMs = 300;
  static const int turnBrakeWindowMs = 1000;

  /// Jerk / acceleration spike thresholds for validation
  static const double bumpJerkThreshold = 15.0; // m/s^3
  static const double turnBrakeAccelThreshold = 2.0; // m/s^2

  /// Validate an event window across fork and footboard sensor readings.
  static CrossValidationResult validateEvent({
    required String eventType,
    required List<SensorReading> readings,
  }) {
    final forkReadings = readings.where((r) => r.mountLocation == 'fork').toList();
    final footboardReadings = readings.where((r) => r.mountLocation == 'footboard').toList();

    if (forkReadings.isEmpty || footboardReadings.isEmpty) {
      // Missing one of the sensors -> cannot cross-confirm
      return const CrossValidationResult(crossConfirmed: false);
    }

    final maxLagAllowedMs = (eventType == 'bump') ? bumpWindowMs : turnBrakeWindowMs;

    if (eventType == 'bump') {
      return _validateBumpSpikes(forkReadings, footboardReadings, maxLagAllowedMs);
    } else {
      return _validateTurnBrakeSpikes(forkReadings, footboardReadings, maxLagAllowedMs);
    }
  }

  static CrossValidationResult _validateBumpSpikes(
    List<SensorReading> fork,
    List<SensorReading> foot,
    int maxLagMs,
  ) {
    // Find peak magnitude and instant on fork
    SensorReading? forkPeak;
    double forkMaxMag = 0.0;
    for (final r in fork) {
      if (r.accelX != null && r.accelY != null && r.accelZ != null) {
        final mag = math.sqrt(r.accelX! * r.accelX! + r.accelY! * r.accelY! + r.accelZ! * r.accelZ!);
        if (mag > forkMaxMag) {
          forkMaxMag = mag;
          forkPeak = r;
        }
      }
    }

    // Find peak magnitude and instant on footboard
    SensorReading? footPeak;
    double footMaxMag = 0.0;
    for (final r in foot) {
      if (r.accelX != null && r.accelY != null && r.accelZ != null) {
        final mag = math.sqrt(r.accelX! * r.accelX! + r.accelY! * r.accelY! + r.accelZ! * r.accelZ!);
        if (mag > footMaxMag) {
          footMaxMag = mag;
          footPeak = r;
        }
      }
    }

    if (forkPeak == null || footPeak == null) {
      return const CrossValidationResult(crossConfirmed: false);
    }

    // Both peaks must exceed baseline gravity significantly (e.g. > 1.25g)
    final minSpikeThreshold = AngularUnits.standardGravity * 1.25;
    final bothExceedThreshold = forkMaxMag >= minSpikeThreshold && footMaxMag >= minSpikeThreshold;

    final lagMs = footPeak.timestampUtc.difference(forkPeak.timestampUtc).inMilliseconds.toDouble();
    final isWithinWindow = lagMs.abs() <= maxLagMs;

    final confirmed = bothExceedThreshold && isWithinWindow;

    return CrossValidationResult(
      crossConfirmed: confirmed,
      forkFootLagMs: lagMs,
      forkPeakJerk: forkMaxMag,
      footboardPeakJerk: footMaxMag,
    );
  }

  static CrossValidationResult _validateTurnBrakeSpikes(
    List<SensorReading> fork,
    List<SensorReading> foot,
    int maxLagMs,
  ) {
    // For whole-vehicle maneuvers (turn, speed/brake), both sensors experience sustained lateral or longitudinal acceleration
    double forkMaxLat = 0.0;
    DateTime? forkTime;
    for (final r in fork) {
      final lat = math.max(r.accelX?.abs() ?? 0.0, r.accelY?.abs() ?? 0.0);
      if (lat > forkMaxLat) {
        forkMaxLat = lat;
        forkTime = r.timestampUtc;
      }
    }

    double footMaxLat = 0.0;
    DateTime? footTime;
    for (final r in foot) {
      final lat = math.max(r.accelX?.abs() ?? 0.0, r.accelY?.abs() ?? 0.0);
      if (lat > footMaxLat) {
        footMaxLat = lat;
        footTime = r.timestampUtc;
      }
    }

    if (forkTime == null || footTime == null) {
      return const CrossValidationResult(crossConfirmed: false);
    }

    final lagMs = footTime.difference(forkTime).inMilliseconds.toDouble();
    final bothAboveThreshold = forkMaxLat >= turnBrakeAccelThreshold && footMaxLat >= turnBrakeAccelThreshold;
    final isWithinWindow = lagMs.abs() <= maxLagMs;

    return CrossValidationResult(
      crossConfirmed: bothAboveThreshold && isWithinWindow,
      forkFootLagMs: lagMs,
    );
  }
}
