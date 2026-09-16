import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/features/events/parameter_engine.dart';

void main() {
  group('Jerk Computation Tests', () {
    test('smooth constant acceleration yields ~0 jerk', () {
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
          accelZ: 9.80665,
        );
      });

      final peakJerk = ParameterEngine.computePeakJerk(readings);
      expect(peakJerk, equals(0.0));
    });

    test('step-function acceleration spike produces correct derivative magnitude', () {
      final now = DateTime.now().toUtc();
      final readings = <SensorReading>[];

      // 10 readings of steady 9.8 m/s^2, then sudden jump of 10.0 m/s^2 in 20ms
      for (int i = 0; i < 10; i++) {
        readings.add(
          SensorReading(
            id: i + 1,
            deviceId: 'fork_imu_01',
            deviceType: 'watch',
            mountLocation: 'fork',
            sequenceNo: i + 1,
            timestampUtc: now.add(Duration(milliseconds: i * 20)),
            sensorType: 'imu',
            accelX: 0.0,
            accelY: 0.0,
            accelZ: 9.80665,
          ),
        );
      }

      // Step jump at index 10: delta_a = 10.0 m/s^2 over dt = 0.02s => jerk = 500 m/s^3
      readings.add(
        SensorReading(
          id: 11,
          deviceId: 'fork_imu_01',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: 11,
          timestampUtc: now.add(const Duration(milliseconds: 200)),
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: 19.80665,
        ),
      );

      final peakJerk = ParameterEngine.computePeakJerk(readings);
      expect((peakJerk - 500.0).abs(), lessThan(5.0));
    });
  });
}
