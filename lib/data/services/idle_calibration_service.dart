import 'package:drift/drift.dart';
import '../../core/utils/fft_utils.dart';
import '../local_db/database.dart';

/// Result of an idle calibration attempt
class IdleCalibrationResult {
  final int? tripId;
  final String mountLocation; // 'fork' or 'footboard'
  final double engineNoiseFreqHz;
  final double engineNoiseAmplitude;
  final DateTime calibratedAtUtc;
  final bool calibrationValid;

  const IdleCalibrationResult({
    this.tripId,
    required this.mountLocation,
    required this.engineNoiseFreqHz,
    required this.engineNoiseAmplitude,
    required this.calibratedAtUtc,
    required this.calibrationValid,
  });

  /// Factory for a failed / fallback calibration state
  factory IdleCalibrationResult.fallback({
    int? tripId,
    required String mountLocation,
    DateTime? calibratedAtUtc,
  }) {
    return IdleCalibrationResult(
      tripId: tripId,
      mountLocation: mountLocation,
      engineNoiseFreqHz: 0.0,
      engineNoiseAmplitude: 0.0,
      calibratedAtUtc: calibratedAtUtc ?? DateTime.now().toUtc(),
      calibrationValid: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'tripId': tripId,
        'mountLocation': mountLocation,
        'engineNoiseFreqHz': engineNoiseFreqHz,
        'engineNoiseAmplitude': engineNoiseAmplitude,
        'calibratedAtUtc': calibratedAtUtc.toIso8601String(),
        'calibrationValid': calibrationValid,
      };
}

/// Service that passively detects stationary idle periods at trip start or during stops,
/// and uses FFT to discover the fundamental engine vibration frequency.
class IdleCalibrationService {
  final AppDatabase? db;

  // Stationary detection thresholds
  static const double maxStationaryGpsSpeedKmh = 1.2;
  static const double maxStationaryAccelVariance = 3.5; // (m/s^2)^2 (~0.036 g^2)
  static const double minEngineToneAmplitude = 0.04;    // m/s^2
  static const double minEngineNoiseFreqHz = 10.0;
  static const double maxEngineNoiseFreqHz = 24.5;      // Nyquist limit for 50Hz is 25Hz

  const IdleCalibrationService([this.db]);

  /// Check if a series of sensor readings represents a stationary vehicle
  static bool isStationary({
    required List<SensorReading> readings,
    double? gpsSpeedKmh,
    double maxVariance = maxStationaryAccelVariance,
  }) {
    if (readings.length < 32) return false;

    // Check GPS speed if available
    if (gpsSpeedKmh != null && gpsSpeedKmh > maxStationaryGpsSpeedKmh) {
      return false;
    }

    // Extract dominant / vertical acceleration axis
    final axisValues = extractDominantAxis(readings);
    if (axisValues.isEmpty) return false;

    // Compute sample variance
    final variance = computeVariance(axisValues);
    return variance <= maxVariance;
  }

  /// Compute sample variance: sum((x - mean)^2) / (N - 1)
  static double computeVariance(List<double> values) {
    if (values.length < 2) return 0.0;
    double mean = 0.0;
    for (final v in values) {
      mean += v;
    }
    mean /= values.length;

    double sumSq = 0.0;
    for (final v in values) {
      final diff = v - mean;
      sumSq += diff * diff;
    }
    return sumSq / (values.length - 1);
  }

  /// Extract vertical / dominant acceleration component (prefers Z or axis with largest mean magnitude)
  static List<double> extractDominantAxis(List<SensorReading> readings) {
    if (readings.isEmpty) return const [];

    // Check which axis has the highest absolute mean (typically Earth gravity ~9.8 m/s^2)
    double sumX = 0.0, sumY = 0.0, sumZ = 0.0;
    int count = 0;

    for (final r in readings) {
      if (r.accelX != null && r.accelY != null && r.accelZ != null) {
        sumX += r.accelX!.abs();
        sumY += r.accelY!.abs();
        sumZ += r.accelZ!.abs();
        count++;
      }
    }

    if (count == 0) return const [];

    // Dominant axis selection
    if (sumZ >= sumX && sumZ >= sumY) {
      return readings.where((r) => r.accelZ != null).map((r) => r.accelZ!).toList();
    } else if (sumY >= sumX) {
      return readings.where((r) => r.accelY != null).map((r) => r.accelY!).toList();
    } else {
      return readings.where((r) => r.accelX != null).map((r) => r.accelX!).toList();
    }
  }

  /// Run calibration on a stationary idle sample window (typically 128 or 256 samples, 2.5–5 seconds)
  IdleCalibrationResult calibrateWindow({
    required List<SensorReading> windowReadings,
    required String mountLocation,
    int? tripId,
    double? gpsSpeedKmh,
    DateTime? timestampUtc,
  }) {
    final now = timestampUtc ?? (windowReadings.isNotEmpty ? windowReadings.first.timestampUtc : DateTime.now().toUtc());

    if (windowReadings.length < 64) {
      // Insufficient sample window
      return IdleCalibrationResult.fallback(
        tripId: tripId,
        mountLocation: mountLocation,
        calibratedAtUtc: now,
      );
    }

    // Verify stationary condition
    final stationary = isStationary(readings: windowReadings, gpsSpeedKmh: gpsSpeedKmh);
    if (!stationary) {
      return IdleCalibrationResult.fallback(
        tripId: tripId,
        mountLocation: mountLocation,
        calibratedAtUtc: now,
      );
    }

    // Extract dominant axis signal
    final signal = extractDominantAxis(windowReadings);
    if (signal.length < 64) {
      return IdleCalibrationResult.fallback(
        tripId: tripId,
        mountLocation: mountLocation,
        calibratedAtUtc: now,
      );
    }

    // Perform Radix-2 FFT (target 128 or 256 samples)
    final fftSize = signal.length >= 256 ? 256 : 128;
    final fftResult = FftUtils.computeRealFft(
      signal,
      sampleRate: 50.0,
      targetSize: fftSize,
      useHannWindow: true,
    );

    // Identify dominant peak in engine noise band (10Hz - 24.5Hz)
    final peak = fftResult.findDominantPeak(
      minFreqHz: minEngineNoiseFreqHz,
      maxFreqHz: maxEngineNoiseFreqHz,
    );

    if (peak.frequencyHz <= 0 || peak.amplitude < minEngineToneAmplitude) {
      // No distinguishable engine peak
      return IdleCalibrationResult.fallback(
        tripId: tripId,
        mountLocation: mountLocation,
        calibratedAtUtc: now,
      );
    }

    return IdleCalibrationResult(
      tripId: tripId,
      mountLocation: mountLocation,
      engineNoiseFreqHz: peak.frequencyHz,
      engineNoiseAmplitude: peak.amplitude,
      calibratedAtUtc: now,
      calibrationValid: true,
    );
  }

  /// Store calibration record to SQLite if database is configured
  Future<void> persistCalibration(IdleCalibrationResult result) async {
    if (db == null || result.tripId == null) return;

    await db!.into(db!.tripCalibrations).insert(
          TripCalibrationsCompanion(
            tripId: Value(result.tripId!),
            mountLocation: Value(result.mountLocation),
            engineNoiseFreqHz: Value(result.engineNoiseFreqHz),
            engineNoiseAmplitude: Value(result.engineNoiseAmplitude),
            calibratedAtUtc: Value(result.calibratedAtUtc),
            calibrationValid: Value(result.calibrationValid),
          ),
        );
  }

  /// Retrieve the latest valid calibration for a specific trip and mount location
  Future<IdleCalibrationResult?> getLatestCalibration(int tripId, String mountLocation) async {
    if (db == null) return null;

    final query = db!.select(db!.tripCalibrations)
      ..where((t) => t.tripId.equals(tripId) & t.mountLocation.equals(mountLocation))
      ..orderBy([(t) => OrderingTerm(expression: t.calibratedAtUtc, mode: OrderingMode.desc)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return IdleCalibrationResult(
      tripId: row.tripId,
      mountLocation: row.mountLocation,
      engineNoiseFreqHz: row.engineNoiseFreqHz,
      engineNoiseAmplitude: row.engineNoiseAmplitude,
      calibratedAtUtc: row.calibratedAtUtc,
      calibrationValid: row.calibrationValid,
    );
  }
}
