import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/features/events/parameter_engine.dart';
import 'package:ride_sensor_capture/data/models/event_parameters.dart';

void main() {
  test('ParameterEngine computes bump peak and severity correctly', () {
    final now = DateTime.now().toUtc();
    final readings = [
      SensorReading(
        id: 1,
        deviceId: 'dev-1',
        deviceType: 'watch',
        mountLocation: 'fork',
        sequenceNo: 1,
        timestampUtc: now,
        sensorType: 'imu',
        accelX: 0.1,
        accelY: 0.2,
        accelZ: 9.8,
      ),
      SensorReading(
        id: 2,
        deviceId: 'dev-1',
        deviceType: 'watch',
        mountLocation: 'fork',
        sequenceNo: 2,
        timestampUtc: now.add(const Duration(milliseconds: 100)),
        sensorType: 'imu',
        accelX: 5.0,
        accelY: 10.0,
        accelZ: 22.0, // High bump impact ~24.6 m/s^2 (~2.5g)
      ),
      SensorReading(
        id: 3,
        deviceId: 'dev-1',
        deviceType: 'watch',
        mountLocation: 'fork',
        sequenceNo: 3,
        timestampUtc: now.add(const Duration(milliseconds: 200)),
        sensorType: 'imu',
        accelX: 0.2,
        accelY: 0.1,
        accelZ: 9.9,
      ),
    ];

    final params = ParameterEngine.computeEventParameters(
      eventType: 'bump',
      readings: readings,
    );

    expect(params.bump, isNotNull);
    expect(params.bump!.peakGForce, greaterThan(1.5));
    expect(params.bump!.severity, isIn(['moderate', 'severe']));
  });

  test('ParameterEngine classifies sharp and easy turns', () {
    final now = DateTime.now().toUtc();
    final sharpTurnReadings = [
      SensorReading(
        id: 1,
        deviceId: 'dev-1',
        deviceType: 'watch',
        mountLocation: 'fork',
        sequenceNo: 1,
        timestampUtc: now,
        sensorType: 'imu',
        accelX: 6.5, // High lateral acceleration
        accelY: 0.2,
        accelZ: 9.8,
      ),
    ];

    final turnParams = ParameterEngine.computeEventParameters(
      eventType: 'turn',
      readings: sharpTurnReadings,
    );

    expect(turnParams.turn, isNotNull);
    expect(turnParams.turn!.classification, 'sharp');
    expect(turnParams.turn!.peakLateralAccel, 6.5);
  });

  test('EventParameters JSON serialization and deserialization roundtrip', () {
    const bump = BumpParameters(
      peakAccelMagnitude: 23.5,
      peakGForce: 2.4,
      accelDelta: 13.7,
      peakToPeakChange: 13.7,
      durationMs: 850,
      severity: 'severe',
    );

    const original = EventParameters(bump: bump);
    final jsonStr = original.toJsonString();
    final parsed = EventParameters.fromJsonString(jsonStr);

    expect(parsed, isNotNull);
    expect(parsed!.bump, isNotNull);
    expect(parsed.bump!.peakGForce, 2.4);
    expect(parsed.bump!.severity, 'severe');
    expect(parsed.summary, contains('2.4g'));
  });
}
