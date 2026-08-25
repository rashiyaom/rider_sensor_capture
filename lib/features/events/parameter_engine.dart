import 'dart:math' as math;
import '../../data/local_db/database.dart';
import '../../data/models/event_parameters.dart';

class ParameterEngine {
  static const double gravity = 9.81; // standard gravity baseline

  // Turn classification thresholds (Placeholder constants to be fine-tuned with vehicle data)
  static const double turnSharpLateralThreshold = 5.0;  // m/s^2 lateral acceleration
  static const double turnMediumLateralThreshold = 2.5; // m/s^2 lateral acceleration

  // Bump classification thresholds (in g-force)
  static const double bumpSevereGThreshold = 2.2;  // > 2.2g peak
  static const double bumpModerateGThreshold = 1.4;// > 1.4g peak

  /// Smooth raw sequence with simple 3-point moving average to reduce sensor jitter
  static List<double> smoothMovingAverage(List<double> signal, {int windowSize = 3}) {
    if (signal.length < windowSize) return List.from(signal);

    final smoothed = <double>[];
    for (int i = 0; i < signal.length; i++) {
      int start = math.max(0, i - (windowSize ~/ 2));
      int end = math.min(signal.length, i + (windowSize ~/ 2) + 1);
      double sum = 0;
      for (int j = start; j < end; j++) {
        sum += signal[j];
      }
      smoothed.add(sum / (end - start));
    }
    return smoothed;
  }

  /// Compute parameters for an event window based on tagged sensor readings
  static EventParameters computeEventParameters({
    required String eventType,
    required List<SensorReading> readings,
  }) {
    if (readings.isEmpty) {
      return const EventParameters();
    }

    final durationMs = readings.length > 1
        ? readings.last.timestampUtc.difference(readings.first.timestampUtc).inMilliseconds
        : 500;

    switch (eventType) {
      case 'bump':
        final bump = _computeBumpParameters(readings, durationMs);
        return EventParameters(bump: bump);
      case 'turn':
        final turn = _computeTurnParameters(readings, durationMs);
        return EventParameters(turn: turn);
      case 'speedTest':
      default:
        final speed = _computeSpeedParameters(readings, durationMs);
        return EventParameters(speed: speed);
    }
  }

  static BumpParameters _computeBumpParameters(List<SensorReading> readings, int durationMs) {
    final rawMagnitudes = <double>[];

    for (final r in readings) {
      if (r.accelX != null && r.accelY != null && r.accelZ != null) {
        final mag = math.sqrt(r.accelX! * r.accelX! + r.accelY! * r.accelY! + r.accelZ! * r.accelZ!);
        rawMagnitudes.add(mag);
      }
    }

    if (rawMagnitudes.isEmpty) {
      return BumpParameters(
        peakAccelMagnitude: gravity,
        peakGForce: 1.0,
        accelDelta: 0.0,
        peakToPeakChange: 0.0,
        durationMs: durationMs,
        severity: 'mild',
      );
    }

    final smoothed = smoothMovingAverage(rawMagnitudes);
    double maxMag = smoothed.first;
    double minMag = smoothed.first;

    for (final val in smoothed) {
      if (val > maxMag) maxMag = val;
      if (val < minMag) minMag = val;
    }

    final peakG = maxMag / gravity;
    final delta = maxMag - minMag;
    final peakToPeak = maxMag - gravity;

    String severity = 'mild';
    if (peakG >= bumpSevereGThreshold) {
      severity = 'severe';
    } else if (peakG >= bumpModerateGThreshold) {
      severity = 'moderate';
    }

    return BumpParameters(
      peakAccelMagnitude: maxMag,
      peakGForce: peakG,
      accelDelta: delta,
      peakToPeakChange: peakToPeak,
      durationMs: durationMs,
      severity: severity,
    );
  }

  static TurnParameters _computeTurnParameters(List<SensorReading> readings, int durationMs) {
    double peakLat = 0.0;
    double peakGyro = 0.0;

    for (final r in readings) {
      // Lateral acceleration is primarily along X or Y axis depending on mount orientation
      if (r.accelX != null) {
        peakLat = math.max(peakLat, r.accelX!.abs());
      }
      if (r.accelY != null) {
        peakLat = math.max(peakLat, r.accelY!.abs());
      }
      if (r.gyroZ != null) {
        peakGyro = math.max(peakGyro, r.gyroZ!.abs());
      }
    }

    String classification = 'easy';
    if (peakLat >= turnSharpLateralThreshold || peakGyro > 45.0) {
      classification = 'sharp';
    } else if (peakLat >= turnMediumLateralThreshold || peakGyro > 20.0) {
      classification = 'medium';
    }

    return TurnParameters(
      peakLateralAccel: peakLat,
      peakGyroDegPerSec: peakGyro,
      durationMs: durationMs,
      classification: classification,
    );
  }

  static SpeedParameters _computeSpeedParameters(List<SensorReading> readings, int durationMs) {
    // Look for sustained longitudinal acceleration (along Z / X)
    double maxAccel = 0.0;
    double minAccel = 0.0;
    double totalAccel = 0.0;
    int count = 0;

    for (final r in readings) {
      if (r.accelY != null) {
        final a = r.accelY!;
        maxAccel = math.max(maxAccel, a);
        minAccel = math.min(minAccel, a);
        totalAccel += a;
        count++;
      }
    }

    final avgAccel = count > 0 ? (totalAccel / count) : 0.0;
    final isBraking = minAccel < -2.5; // Negative sustained acceleration indicates braking
    final decelMag = isBraking ? minAccel.abs() : 0.0;

    // Approximate speed proxy (integrated accel or default baseline)
    final approxPeakSpeed = math.max(0.0, avgAccel * (durationMs / 1000.0) * 3.6 + 15.0);

    return SpeedParameters(
      averageSpeedKmh: approxPeakSpeed * 0.8,
      peakSpeedKmh: approxPeakSpeed,
      avgAcceleration: avgAccel,
      isBraking: isBraking,
      decelMagnitude: decelMag,
      durationMs: durationMs,
    );
  }
}
