import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/data/services/live_ml_inference_service.dart';

void main() {
  group('P3: LiveMlInferenceService Real-Time Edge ML Tests', () {
    late LiveMlInferenceService service;

    setUp(() {
      service = LiveMlInferenceService(maxBufferSize: 75);
    });

    tearDown(() {
      service.dispose();
    });

    test('classifies stable baseline telemetry as normal riding', () async {
      final now = DateTime.now().toUtc();

      // Feed 20 normal samples
      for (int i = 0; i < 20; i++) {
        service.ingestReading(RawSensorData(
          deviceId: 'watch_fork',
          deviceName: 'Watch Fork',
          deviceType: DeviceType.watch,
          timestamp: now.add(Duration(milliseconds: i * 20)),
          mountLocation: 'fork',
          accelX: 0.1,
          accelY: 0.0,
          accelZ: 9.81,
          gyroX: 0.0,
          gyroY: 0.0,
          gyroZ: 0.0,
          rawBytes: const [],
        ));
      }

      final prediction = service.latestPrediction;
      expect(prediction.eventType, equals(MlPredictedEventType.normalRiding));
      expect(prediction.confidence, greaterThan(0.90));
      expect(prediction.isAnomaly, isFalse);
    });

    test('detects severe bump / pothole on high vertical shock impulse & jerk', () async {
      final now = DateTime.now().toUtc();

      // Feed baseline samples then a sharp 24 m/s^2 impulse spike
      for (int i = 0; i < 20; i++) {
        final az = (i == 15) ? 24.5 : 9.81;
        service.ingestReading(RawSensorData(
          deviceId: 'watch_fork',
          deviceName: 'Watch Fork',
          deviceType: DeviceType.watch,
          timestamp: now.add(Duration(milliseconds: i * 20)),
          mountLocation: 'fork',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: az,
          gyroX: 0.0,
          gyroY: 0.0,
          gyroZ: 0.0,
          rawBytes: const [],
        ));
      }

      final prediction = service.latestPrediction;
      expect(prediction.eventType, equals(MlPredictedEventType.severeBump));
      expect(prediction.isAnomaly, isTrue);
      expect(prediction.confidence, greaterThan(0.80));
      expect(prediction.topFeatures['z_peak_mps2'], closeTo(24.5, 0.1));
      expect(prediction.topFeatures['peak_jerk_mps3'], greaterThan(120.0));
      expect(prediction.explanation.contains('High vertical impulse'), isTrue);
    });

    test('detects sharp cornering turn on vehicle roll and yaw angular rate', () async {
      final now = DateTime.now().toUtc();

      // Feed 20 samples with lateral tilt (Ay=4.5, Az=8.5 => roll ~28 deg) and yaw gyro
      for (int i = 0; i < 20; i++) {
        service.ingestReading(RawSensorData(
          deviceId: 'watch_fork',
          deviceName: 'Watch Fork',
          deviceType: DeviceType.watch,
          timestamp: now.add(Duration(milliseconds: i * 20)),
          mountLocation: 'fork',
          accelX: 0.0,
          accelY: 4.8,
          accelZ: 8.5,
          gyroX: 0.1,
          gyroY: 0.2,
          gyroZ: 28.0, // 28 deg/s yaw
          rawBytes: const [],
        ));
      }

      final prediction = service.latestPrediction;
      expect(prediction.eventType, equals(MlPredictedEventType.sharpTurn));
      expect(prediction.isAnomaly, isTrue);
      expect(prediction.topFeatures['roll_deg'], greaterThan(20.0));
      expect(prediction.confidence, greaterThan(0.80));
    });

    test('detects hard braking event on negative longitudinal deceleration', () async {
      final now = DateTime.now().toUtc();

      for (int i = 0; i < 20; i++) {
        service.ingestReading(RawSensorData(
          deviceId: 'watch_fork',
          deviceName: 'Watch Fork',
          deviceType: DeviceType.watch,
          timestamp: now.add(Duration(milliseconds: i * 20)),
          mountLocation: 'fork',
          accelX: -4.2, // -4.2 m/s^2 deceleration
          accelY: 0.0,
          accelZ: 9.81,
          gyroX: 0.0,
          gyroY: 0.0,
          gyroZ: 0.0,
          rawBytes: const [],
        ));
      }

      final prediction = service.latestPrediction;
      expect(prediction.eventType, equals(MlPredictedEventType.hardBraking));
      expect(prediction.isAnomaly, isTrue);
      expect(prediction.topFeatures['longitudinal_ax'], closeTo(-4.2, 0.1));
      expect(prediction.confidence, greaterThan(0.80));
    });

    test('computes inter-sensor Fork vs Footboard correlation coefficient', () async {
      final now = DateTime.now().toUtc();

      // Feed synchronized bump impulse on both fork and footboard
      for (int i = 0; i < 20; i++) {
        final t = now.add(Duration(milliseconds: i * 20));
        final az = (i == 10) ? 22.0 : 9.81;

        service.ingestReading(RawSensorData(
          deviceId: 'watch_fork',
          deviceName: 'Watch Fork',
          deviceType: DeviceType.watch,
          timestamp: t,
          mountLocation: 'fork',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: az,
          rawBytes: const [],
        ));

        service.ingestReading(RawSensorData(
          deviceId: 'watch_footboard',
          deviceName: 'Watch Footboard',
          deviceType: DeviceType.watch,
          timestamp: t,
          mountLocation: 'footboard',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: az * 0.9,
          rawBytes: const [],
        ));
      }

      final prediction = service.latestPrediction;
      expect(prediction.topFeatures['fork_foot_corr'], greaterThan(0.70));
    });

    test('reset clears internal buffer and restores normal baseline', () {
      final now = DateTime.now().toUtc();
      for (int i = 0; i < 20; i++) {
        final az = (i == 15) ? 25.0 : 9.81;
        service.ingestReading(RawSensorData(
          deviceId: 'watch_fork',
          deviceName: 'Watch Fork',
          deviceType: DeviceType.watch,
          timestamp: now.add(Duration(milliseconds: i * 20)),
          mountLocation: 'fork',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: az,
          rawBytes: const [],
        ), forceInference: true);
      }

      expect(service.latestPrediction.eventType, equals(MlPredictedEventType.severeBump));

      service.reset();
      expect(service.latestPrediction.eventType, equals(MlPredictedEventType.normalRiding));
      expect(service.latestPrediction.isAnomaly, isFalse);
    });
  });
}

