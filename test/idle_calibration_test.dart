import 'dart:math' as math;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/core/utils/fft_utils.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/services/idle_calibration_service.dart';

void main() {
  group('IdleCalibrationService & FFT Tests', () {
    const fs = 50.0; // 50 Hz

    test('FftUtils correctly identifies injected dominant frequency', () {
      const targetFreq = 18.5; // Hz
      const n = 128;
      final tStep = 1.0 / fs;

      // Synthesize tone at 18.5 Hz + DC offset (gravity)
      final signal = List<double>.generate(
        n,
        (i) => 9.8 + 1.5 * math.sin(2.0 * math.pi * targetFreq * (i * tStep)),
      );

      final fft = FftUtils.computeRealFft(signal, sampleRate: fs, targetSize: n);
      final peak = fft.findDominantPeak(minFreqHz: 10.0, maxFreqHz: 24.5);

      // Frequency bin resolution for 128 samples at 50Hz is ~0.39 Hz
      expect(peak.frequencyHz, closeTo(targetFreq, 0.5));
      expect(peak.amplitude, greaterThan(0.5));
    });

    test('Stationary window detection accepts low variance and rejects moving vehicle', () {
      final now = DateTime.now().toUtc();

      // 1. Stationary idle readings: steady gravity ~9.8 m/s^2 + small engine hum
      final stationaryReadings = List.generate(
        128,
        (i) => SensorReading(
          id: i,
          deviceId: 'dev-1',
          deviceType: 'watch',
          sequenceNo: i,
          timestampUtc: now.add(Duration(milliseconds: i * 20)),
          sensorType: 'imu',
          mountLocation: 'fork',
          accelX: 0.05 * math.sin(i * 0.4),
          accelY: 0.05 * math.cos(i * 0.4),
          accelZ: 9.8 + 0.2 * math.sin(i * 0.5),
        ),
      );

      final isStat = IdleCalibrationService.isStationary(
        readings: stationaryReadings,
        gpsSpeedKmh: 0.0,
      );
      expect(isStat, isTrue);

      // 2. Moving vehicle (high GPS speed)
      final isMovingGps = IdleCalibrationService.isStationary(
        readings: stationaryReadings,
        gpsSpeedKmh: 15.0,
      );
      expect(isMovingGps, isFalse);

      // 3. Moving vehicle (high accel variance from maneuvers/bumps)
      final movingReadings = List.generate(
        128,
        (i) => SensorReading(
          id: i,
          deviceId: 'dev-1',
          deviceType: 'watch',
          sequenceNo: i,
          timestampUtc: now.add(Duration(milliseconds: i * 20)),
          sensorType: 'imu',
          mountLocation: 'fork',
          accelX: 3.0 * math.sin(i * 0.2),
          accelY: 4.0 * math.cos(i * 0.2),
          accelZ: 9.8 + 10.0 * math.sin(i * 0.3), // High variance
        ),
      );

      final isMovingAccel = IdleCalibrationService.isStationary(
        readings: movingReadings,
        gpsSpeedKmh: 0.0,
      );
      expect(isMovingAccel, isFalse);
    });

    test('calibrateWindow returns valid calibration with detected peak frequency on stationary idle', () {
      final now = DateTime.now().toUtc();
      const engineFreq = 16.0; // Hz
      final tStep = 1.0 / fs;

      // 128 samples of stationary idle with 16Hz vibration
      final readings = List.generate(
        128,
        (i) => SensorReading(
          id: i,
          deviceId: 'dev-1',
          deviceType: 'watch',
          sequenceNo: i,
          timestampUtc: now.add(Duration(milliseconds: i * 20)),
          sensorType: 'imu',
          mountLocation: 'fork',
          accelX: 0.05 * math.sin(i * 0.1),
          accelY: 0.05 * math.cos(i * 0.1),
          accelZ: 9.8 + 0.6 * math.sin(2.0 * math.pi * engineFreq * (i * tStep)),
        ),
      );

      const service = IdleCalibrationService();
      final result = service.calibrateWindow(
        windowReadings: readings,
        mountLocation: 'fork',
        tripId: 42,
        gpsSpeedKmh: 0.1,
      );

      expect(result.calibrationValid, isTrue);
      expect(result.tripId, 42);
      expect(result.mountLocation, 'fork');
      expect(result.engineNoiseFreqHz, closeTo(engineFreq, 0.5));
      expect(result.engineNoiseAmplitude, greaterThan(0.2));
    });

    test('calibrateWindow falls back to calibrationValid: false when not stationary', () {
      final now = DateTime.now().toUtc();
      final readings = List.generate(
        128,
        (i) => SensorReading(
          id: i,
          deviceId: 'dev-1',
          deviceType: 'watch',
          sequenceNo: i,
          timestampUtc: now.add(Duration(milliseconds: i * 20)),
          sensorType: 'imu',
          mountLocation: 'footboard',
          accelX: 2.0,
          accelY: 3.0,
          accelZ: 20.0,
        ),
      );

      const service = IdleCalibrationService();
      final result = service.calibrateWindow(
        windowReadings: readings,
        mountLocation: 'footboard',
        tripId: 99,
        gpsSpeedKmh: 25.0, // Moving at 25 km/h
      );

      expect(result.calibrationValid, isFalse);
      expect(result.engineNoiseFreqHz, 0.0);
    });

    test('IdleCalibrationService persists and retrieves calibrations from database', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final service = IdleCalibrationService(db);

      final cal = IdleCalibrationResult(
        tripId: 10,
        mountLocation: 'fork',
        engineNoiseFreqHz: 19.5,
        engineNoiseAmplitude: 0.42,
        calibratedAtUtc: DateTime.utc(2026, 9, 12, 12, 0, 0),
        calibrationValid: true,
      );

      await service.persistCalibration(cal);

      final retrieved = await service.getLatestCalibration(10, 'fork');
      expect(retrieved, isNotNull);
      expect(retrieved!.tripId, 10);
      expect(retrieved.mountLocation, 'fork');
      expect(retrieved.engineNoiseFreqHz, closeTo(19.5, 0.01));
      expect(retrieved.engineNoiseAmplitude, closeTo(0.42, 0.01));
      expect(retrieved.calibrationValid, isTrue);

      await db.close();
    });
  });
}
