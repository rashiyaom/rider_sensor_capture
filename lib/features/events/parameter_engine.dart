import 'dart:math' as math;
import '../../core/utils/angular_units.dart';
import '../../data/local_db/database.dart';
import '../../data/models/event_parameters.dart';
import '../../data/services/event_cross_validator.dart';
import '../../data/services/hr_event_gate.dart';
import '../../data/services/signal_filter_service.dart';
import '../../data/services/idle_calibration_service.dart';

class ParameterEngine {
  // Turn classification thresholds
  static const double turnSharpLateralThreshold = 5.0;  // m/s^2 lateral acceleration
  static const double turnMediumLateralThreshold = 2.5; // m/s^2 lateral acceleration
  static const double turnSharpLeanAngleThreshold = 28.0; // degrees roll
  static const double turnMediumLeanAngleThreshold = 14.0;

  // Bump classification thresholds (in g-force)
  static const double bumpSevereGThreshold = 2.2;  // > 2.2g peak
  static const double bumpModerateGThreshold = 1.4;// > 1.4g peak

  // Jerk classification thresholds (m/s^3)
  static const double bumpSevereJerkThreshold = 45.0;
  static const double bumpModerateJerkThreshold = 22.0;

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

  /// Compute continuous 3-axis jerk series and peak magnitude
  static double computePeakJerk(List<SensorReading> readings) {
    if (readings.length < 2) return 0.0;
    double maxJerk = 0.0;

    for (int i = 1; i < readings.length; i++) {
      final prev = readings[i - 1];
      final curr = readings[i];

      if (prev.accelX != null && prev.accelY != null && prev.accelZ != null &&
          curr.accelX != null && curr.accelY != null && curr.accelZ != null) {
        final dt = curr.timestampUtc.difference(prev.timestampUtc).inMilliseconds / 1000.0;
        if (dt > 0.005 && dt < 0.2) {
          final jx = (curr.accelX! - prev.accelX!) / dt;
          final jy = (curr.accelY! - prev.accelY!) / dt;
          final jz = (curr.accelZ! - prev.accelZ!) / dt;
          final mag = math.sqrt(jx * jx + jy * jy + jz * jz);
          if (mag > maxJerk) {
            maxJerk = mag;
          }
        }
      }
    }
    return maxJerk;
  }

  /// Compute roll angle profile using complementary filter fusing gyro-integrated roll with accelerometer roll
  /// Uses Stage 3 (zero-phase 3Hz Butterworth low-pass) for vehicle maneuver frequencies (0–3Hz).
  static double computeMaxLeanAngleDeg(
    List<SensorReading> readings, {
    double alpha = 0.98,
    bool applyManeuverFilter = true,
  }) {
    // Prefer fork-mounted readings as authoritative source
    final forkReadings = readings.where((r) => r.mountLocation == 'fork').toList();
    final sourceReadings = forkReadings.isNotEmpty ? forkReadings : readings;

    if (sourceReadings.isEmpty) return 0.0;

    // Optional 3Hz zero-phase Butterworth low-pass filtering on accelerometer and gyro channels
    List<double> axList = sourceReadings.map((r) => r.accelX ?? 0.0).toList();
    List<double> ayList = sourceReadings.map((r) => r.accelY ?? 0.0).toList();
    List<double> azList = sourceReadings.map((r) => r.accelZ ?? 0.0).toList();
    List<double> gxList = sourceReadings.map((r) => r.gyroX ?? 0.0).toList();

    if (applyManeuverFilter && sourceReadings.length >= 6) {
      axList = SignalFilterService.applyManeuverLowPass(axList);
      ayList = SignalFilterService.applyManeuverLowPass(ayList);
      azList = SignalFilterService.applyManeuverLowPass(azList);
      gxList = SignalFilterService.applyManeuverLowPass(gxList);
    }

    double rollRad = 0.0;
    double maxAbsRollDeg = 0.0;
    bool initialized = false;

    for (int i = 0; i < sourceReadings.length; i++) {
      final ax = axList[i];
      final ay = ayList[i];
      final az = azList[i];

      final rollAccelRad = math.atan2(ay, math.sqrt(ax * ax + az * az));

      if (!initialized) {
        rollRad = rollAccelRad;
        initialized = true;
      } else {
        final prev = sourceReadings[i - 1];
        final curr = sourceReadings[i];
        final dt = curr.timestampUtc.difference(prev.timestampUtc).inMilliseconds / 1000.0;

        if (dt > 0.002 && dt < 0.2) {
          final gx = gxList[i];
          final rollGyroRad = rollRad + gx * dt;
          rollRad = alpha * rollGyroRad + (1.0 - alpha) * rollAccelRad;
        } else {
          rollRad = rollAccelRad;
        }
      }

      final rollDeg = AngularUnits.radToDeg(rollRad).abs();
      if (rollDeg > maxAbsRollDeg) {
        maxAbsRollDeg = rollDeg;
      }
    }

    return maxAbsRollDeg;
  }

  /// Compute parameters for an event window based on tagged sensor readings
  static EventParameters computeEventParameters({
    required String eventType,
    required List<SensorReading> readings,
    List<SensorReading>? tripHistoryReadings,
    double? gpsSpeedKmh,
    double? gpsHeadingChangeDeg,
    IdleCalibrationResult? calibration,
  }) {
    if (readings.isEmpty) {
      return const EventParameters();
    }

    final durationMs = readings.length > 1
        ? readings.last.timestampUtc.difference(readings.first.timestampUtc).inMilliseconds
        : 500;

    // 1. Cross-correlation validation across fork and footboard
    final crossVal = EventCrossValidator.validateEvent(
      eventType: eventType,
      readings: readings,
    );

    // 2. HR gating if trip history readings are available
    HrGateResult? hrResult;
    if (tripHistoryReadings != null && tripHistoryReadings.isNotEmpty) {
      hrResult = HrEventGate.evaluateEventHr(
        eventStartUtc: readings.first.timestampUtc,
        tripReadings: tripHistoryReadings,
      );
    }

    switch (eventType) {
      case 'bump':
        final bump = _computeBumpParameters(readings, durationMs, calibration: calibration);
        return EventParameters(
          bump: bump,
          gpsSpeedKmh: gpsSpeedKmh,
          crossConfirmed: crossVal.crossConfirmed,
          forkFootLagMs: crossVal.forkFootLagMs,
          hrSpikeConfirmed: hrResult?.hrSpikeConfirmed ?? false,
          hrDeltaAtEvent: hrResult?.hrDeltaAtEvent,
          calibrationValid: calibration?.calibrationValid,
          engineNoiseFreqHz: calibration?.engineNoiseFreqHz,
        );
      case 'turn':
        final turn = _computeTurnParameters(readings, durationMs, gpsHeadingChangeDeg, calibration: calibration);
        return EventParameters(
          turn: turn,
          gpsSpeedKmh: gpsSpeedKmh,
          crossConfirmed: crossVal.crossConfirmed,
          forkFootLagMs: crossVal.forkFootLagMs,
          hrSpikeConfirmed: hrResult?.hrSpikeConfirmed ?? false,
          hrDeltaAtEvent: hrResult?.hrDeltaAtEvent,
          calibrationValid: calibration?.calibrationValid,
          engineNoiseFreqHz: calibration?.engineNoiseFreqHz,
        );
      case 'speedTest':
      default:
        final speed = _computeSpeedParameters(readings, durationMs);
        return EventParameters(
          speed: speed,
          gpsSpeedKmh: gpsSpeedKmh,
          crossConfirmed: crossVal.crossConfirmed,
          forkFootLagMs: crossVal.forkFootLagMs,
          hrSpikeConfirmed: hrResult?.hrSpikeConfirmed ?? false,
          hrDeltaAtEvent: hrResult?.hrDeltaAtEvent,
          calibrationValid: calibration?.calibrationValid,
          engineNoiseFreqHz: calibration?.engineNoiseFreqHz,
        );
    }
  }

  static BumpParameters _computeBumpParameters(
    List<SensorReading> readings,
    int durationMs, {
    IdleCalibrationResult? calibration,
  }) {
    final rawMagnitudes = <double>[];

    for (final r in readings) {
      if (r.accelX != null && r.accelY != null && r.accelZ != null) {
        final mag = math.sqrt(r.accelX! * r.accelX! + r.accelY! * r.accelY! + r.accelZ! * r.accelZ!);
        rawMagnitudes.add(mag);
      }
    }

    // Stage 4: Jerk magnitude from least-filtered (DC-removed / high-pass) channel
    final peakJerk = computePeakJerk(readings);

    if (rawMagnitudes.isEmpty) {
      return BumpParameters(
        peakAccelMagnitude: AngularUnits.standardGravity,
        peakGForce: 1.0,
        accelDelta: 0.0,
        peakToPeakChange: 0.0,
        durationMs: durationMs,
        severity: 'mild',
        jerkPeakMagnitude: 0.0,
      );
    }

    final smoothed = smoothMovingAverage(rawMagnitudes);
    double maxMag = smoothed.first;
    double minMag = smoothed.first;

    for (final val in smoothed) {
      if (val > maxMag) maxMag = val;
      if (val < minMag) minMag = val;
    }

    // Peak G-force is computed from least-filtered channel to protect true transient spike amplitude
    final peakG = AngularUnits.accelToG(maxMag);
    final delta = maxMag - minMag;
    final peakToPeak = maxMag - AngularUnits.standardGravity;

    // Stage 5: Noise floor subtraction for adaptive thresholding
    final baselineG = (calibration != null && calibration.calibrationValid)
        ? (calibration.engineNoiseAmplitude / AngularUnits.standardGravity)
        : 0.0;

    final severeGThreshold = math.max(bumpSevereGThreshold, baselineG + 1.2);
    final moderateGThreshold = math.max(bumpModerateGThreshold, baselineG + 0.4);

    // Classification uses jerk and adaptive G threshold
    String severity = 'mild';
    if (peakJerk >= bumpSevereJerkThreshold || peakG >= severeGThreshold) {
      severity = 'severe';
    } else if (peakJerk >= bumpModerateJerkThreshold || peakG >= moderateGThreshold) {
      severity = 'moderate';
    }

    return BumpParameters(
      peakAccelMagnitude: maxMag,
      peakGForce: peakG,
      accelDelta: delta,
      peakToPeakChange: peakToPeak,
      durationMs: durationMs,
      severity: severity,
      jerkPeakMagnitude: peakJerk,
      baselineNoiseFloor: baselineG,
      calibrationValid: calibration?.calibrationValid,
    );
  }

  static TurnParameters _computeTurnParameters(
    List<SensorReading> readings,
    int durationMs,
    double? gpsHeadingChangeDeg, {
    IdleCalibrationResult? calibration,
  }) {
    List<double> axList = readings.map((r) => r.accelX ?? 0.0).toList();
    List<double> ayList = readings.map((r) => r.accelY ?? 0.0).toList();
    List<double> gzList = readings.map((r) => r.gyroZ ?? 0.0).toList();

    // Stage 3: Low-pass filter (3Hz cutoff) for 0-3Hz maneuver channel
    if (readings.length >= 6) {
      axList = SignalFilterService.applyManeuverLowPass(axList);
      ayList = SignalFilterService.applyManeuverLowPass(ayList);
      gzList = SignalFilterService.applyManeuverLowPass(gzList);
    }

    double peakLat = 0.0;
    double peakGyro = 0.0;
    double netYaw = 0.0;

    for (int i = 0; i < readings.length; i++) {
      peakLat = math.max(peakLat, axList[i].abs());
      peakLat = math.max(peakLat, ayList[i].abs());

      final degS = AngularUnits.radToDeg(gzList[i].abs());
      peakGyro = math.max(peakGyro, degS);
      netYaw += gzList[i];
    }

    final maxLean = computeMaxLeanAngleDeg(readings);
    final direction = netYaw >= 0 ? 'right' : 'left';

    String classification = 'easy';
    if (peakLat >= turnSharpLateralThreshold || peakGyro > 45.0 || maxLean >= turnSharpLeanAngleThreshold) {
      classification = 'sharp';
    } else if (peakLat >= turnMediumLateralThreshold || peakGyro > 20.0 || maxLean >= turnMediumLeanAngleThreshold) {
      classification = 'medium';
    }

    return TurnParameters(
      peakLateralAccel: peakLat,
      peakGyroDegPerSec: peakGyro,
      maxLeanAngleDeg: maxLean,
      turnDirection: direction,
      durationMs: durationMs,
      classification: classification,
      gpsHeadingDeltaDeg: gpsHeadingChangeDeg,
    );
  }

  static SpeedParameters _computeSpeedParameters(List<SensorReading> readings, int durationMs) {
    double minAccel = 0.0;
    double totalAccel = 0.0;
    int count = 0;

    for (final r in readings) {
      if (r.accelY != null) {
        final a = r.accelY!;
        minAccel = math.min(minAccel, a);
        totalAccel += a;
        count++;
      }
    }

    final avgAccel = count > 0 ? (totalAccel / count) : 0.0;
    final isBraking = minAccel < -2.5;
    final decelMag = isBraking ? minAccel.abs() : 0.0;
    final peakJerk = computePeakJerk(readings);

    final approxPeakSpeed = math.max(0.0, avgAccel * (durationMs / 1000.0) * 3.6 + 15.0);

    return SpeedParameters(
      averageSpeedKmh: approxPeakSpeed * 0.8,
      peakSpeedKmh: approxPeakSpeed,
      avgAcceleration: avgAccel,
      isBraking: isBraking,
      decelMagnitude: decelMag,
      durationMs: durationMs,
      jerkPeakMagnitude: peakJerk,
    );
  }
}
