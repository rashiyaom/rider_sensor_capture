import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/services/hr_event_gate.dart';

void main() {
  group('HrEventGate Tests', () {
    test('computes correct median baseline', () {
      final oddHrs = [70, 75, 80, 85, 90];
      expect(HrEventGate.computeBaseline(oddHrs), equals(80.0));

      final evenHrs = [70, 74, 80, 86];
      expect(HrEventGate.computeBaseline(evenHrs), equals(77.0));
    });

    test('HR spike >= 8 bpm within 5s of event onset confirms physiological response', () {
      final eventStart = DateTime.utc(2026, 9, 12, 12, 0, 10);
      final tripReadings = <SensorReading>[];

      // 60s baseline: readings hovering around 75 bpm
      for (int i = 60; i >= 1; i--) {
        tripReadings.add(
          SensorReading(
            id: i,
            deviceId: 'polar_01',
            deviceType: 'verityBand',
            mountLocation: 'forearm',
            sequenceNo: i,
            timestampUtc: eventStart.subtract(Duration(seconds: i)),
            sensorType: 'hr',
            heartRate: 74 + (i % 3),
          ),
        );
      }

      // Post-event 5s: HR spikes to 88 bpm (+13 bpm jump)
      tripReadings.add(
        SensorReading(
          id: 101,
          deviceId: 'polar_01',
          deviceType: 'verityBand',
          mountLocation: 'forearm',
          sequenceNo: 101,
          timestampUtc: eventStart.add(const Duration(seconds: 2)),
          sensorType: 'hr',
          heartRate: 88,
        ),
      );

      final result = HrEventGate.evaluateEventHr(
        eventStartUtc: eventStart,
        tripReadings: tripReadings,
      );

      expect(result.hrSpikeConfirmed, isTrue);
      expect(result.hrDeltaAtEvent, greaterThanOrEqualTo(8.0));
    });

    test('minor HR fluctuation (< 8 bpm) rejects spike confirmation', () {
      final eventStart = DateTime.utc(2026, 9, 12, 12, 0, 10);
      final tripReadings = <SensorReading>[];

      // 60s baseline around 75 bpm
      for (int i = 60; i >= 1; i--) {
        tripReadings.add(
          SensorReading(
            id: i,
            deviceId: 'polar_01',
            deviceType: 'verityBand',
            mountLocation: 'forearm',
            sequenceNo: i,
            timestampUtc: eventStart.subtract(Duration(seconds: i)),
            sensorType: 'hr',
            heartRate: 75,
          ),
        );
      }

      // Post-event reading: 78 bpm (+3 bpm only)
      tripReadings.add(
        SensorReading(
          id: 101,
          deviceId: 'polar_01',
          deviceType: 'verityBand',
          mountLocation: 'forearm',
          sequenceNo: 101,
          timestampUtc: eventStart.add(const Duration(seconds: 2)),
          sensorType: 'hr',
          heartRate: 78,
        ),
      );

      final result = HrEventGate.evaluateEventHr(
        eventStartUtc: eventStart,
        tripReadings: tripReadings,
      );

      expect(result.hrSpikeConfirmed, isFalse);
      expect(result.hrDeltaAtEvent, equals(3.0));
    });
  });
}
