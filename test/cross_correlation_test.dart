import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/services/event_cross_validator.dart';

void main() {
  group('EventCrossValidator Tests', () {
    test('correlated fork and footboard bump within 120ms confirms event', () {
      final now = DateTime.now().toUtc();
      final readings = <SensorReading>[];

      // Fork spike at t = 100ms
      readings.add(
        SensorReading(
          id: 1,
          deviceId: 'fork_01',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: 1,
          timestampUtc: now.add(const Duration(milliseconds: 100)),
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: 24.0, // Significant spike > 1.25g
        ),
      );

      // Footboard spike at t = 180ms (80ms lag, front then rear wheel)
      readings.add(
        SensorReading(
          id: 2,
          deviceId: 'foot_01',
          deviceType: 'watch',
          mountLocation: 'footboard',
          sequenceNo: 1,
          timestampUtc: now.add(const Duration(milliseconds: 180)),
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: 20.0, // Correlated spike
        ),
      );

      final result = EventCrossValidator.validateEvent(
        eventType: 'bump',
        readings: readings,
      );

      expect(result.crossConfirmed, isTrue);
      expect(result.forkFootLagMs, equals(80.0));
    });

    test('isolated single-sensor spike rejects cross confirmation', () {
      final now = DateTime.now().toUtc();
      final readings = <SensorReading>[];

      // Only fork has spike
      readings.add(
        SensorReading(
          id: 1,
          deviceId: 'fork_01',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: 1,
          timestampUtc: now.add(const Duration(milliseconds: 100)),
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: 28.0,
        ),
      );

      // Footboard is baseline/quiet
      readings.add(
        SensorReading(
          id: 2,
          deviceId: 'foot_01',
          deviceType: 'watch',
          mountLocation: 'footboard',
          sequenceNo: 1,
          timestampUtc: now.add(const Duration(milliseconds: 100)),
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: 9.8,
        ),
      );

      final result = EventCrossValidator.validateEvent(
        eventType: 'bump',
        readings: readings,
      );

      expect(result.crossConfirmed, isFalse);
    });

    test('lag exceeding 300ms window rejects bump cross confirmation', () {
      final now = DateTime.now().toUtc();
      final readings = <SensorReading>[];

      readings.add(
        SensorReading(
          id: 1,
          deviceId: 'fork_01',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: 1,
          timestampUtc: now.add(const Duration(milliseconds: 100)),
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: 24.0,
        ),
      );

      // Footboard spike 500ms later (> 300ms threshold)
      readings.add(
        SensorReading(
          id: 2,
          deviceId: 'foot_01',
          deviceType: 'watch',
          mountLocation: 'footboard',
          sequenceNo: 1,
          timestampUtc: now.add(const Duration(milliseconds: 600)),
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: 22.0,
        ),
      );

      final result = EventCrossValidator.validateEvent(
        eventType: 'bump',
        readings: readings,
      );

      expect(result.crossConfirmed, isFalse);
    });
  });
}
