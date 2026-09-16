import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/core/utils/angular_units.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/features/events/parameter_engine.dart';

void main() {
  group('Complementary Filter Lean Angle Fusion Tests', () {
    test('static upright position yields ~0 deg roll', () {
      final now = DateTime.now().toUtc();
      final readings = List.generate(20, (i) {
        return SensorReading(
          id: i + 1,
          deviceId: 'fork_imu_01',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: i + 1,
          timestampUtc: now.add(Duration(milliseconds: i * 20)),
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: AngularUnits.standardGravity,
          gyroX: 0.0,
          gyroY: 0.0,
          gyroZ: 0.0,
        );
      });

      final leanDeg = ParameterEngine.computeMaxLeanAngleDeg(readings);
      expect(leanDeg, lessThan(1.0));
    });

    test('static 30-degree lean yields ~30 deg roll', () {
      final now = DateTime.now().toUtc();
      final targetAngleRad = AngularUnits.degToRad(30.0);
      final g = AngularUnits.standardGravity;

      // 30 degree tilt around X axis: ay = g*sin(30), az = g*cos(30)
      final ay = g * math.sin(targetAngleRad);
      final az = g * math.cos(targetAngleRad);

      final readings = List.generate(25, (i) {
        return SensorReading(
          id: i + 1,
          deviceId: 'fork_imu_01',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: i + 1,
          timestampUtc: now.add(Duration(milliseconds: i * 20)),
          sensorType: 'imu',
          accelX: 0.0,
          accelY: ay,
          accelZ: az,
          gyroX: 0.0,
          gyroY: 0.0,
          gyroZ: 0.0,
        );
      });

      final leanDeg = ParameterEngine.computeMaxLeanAngleDeg(readings);
      expect((leanDeg - 30.0).abs(), lessThan(1.0));
    });

    test('cornering with lateral accel does not corrupt complementary fused roll', () {
      final now = DateTime.now().toUtc();
      final g = AngularUnits.standardGravity;

      // Simulate a dynamic turn where gyro measures 0.35 rad/s roll rate then levels off
      // Accelerometer experiences high centrifugal lateral accel (e.g. 4.0 m/s^2)
      final readings = <SensorReading>[];
      DateTime curTime = now;
      double roll = 0.0;

      for (int i = 0; i < 30; i++) {
        curTime = curTime.add(const Duration(milliseconds: 20));
        final gx = (i < 15) ? 0.2 : 0.0; // rad/s
        roll += gx * 0.02;

        readings.add(
          SensorReading(
            id: i + 1,
            deviceId: 'fork_imu_01',
            deviceType: 'watch',
            mountLocation: 'fork',
            sequenceNo: i + 1,
            timestampUtc: curTime,
            sensorType: 'imu',
            accelX: 0.0,
            accelY: g * math.sin(roll) + 3.0, // Centrifugal component
            accelZ: g * math.cos(roll),
            gyroX: gx,
            gyroY: 0.0,
            gyroZ: 0.25,
          ),
        );
      }

      final leanDeg = ParameterEngine.computeMaxLeanAngleDeg(readings);
      expect(leanDeg, greaterThan(5.0));
      expect(leanDeg, lessThan(45.0));
    });
  });
}
