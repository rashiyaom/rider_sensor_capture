import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/services/windowed_feature_extractor_service.dart';

void main() {
  final base = DateTime.utc(2026, 11, 6);
  SensorReading sample(int i, String device, {int step = 20, int jitter = 0}) =>
      SensorReading(
        id: i * 2 + (device == 'left' ? 1 : 2),
        deviceId: device,
        deviceType: 'watch',
        sequenceNo: i,
        timestampUtc: base.add(Duration(milliseconds: i * step + jitter)),
        sensorType: 'imu',
        mountLocation: '${device}_hand',
        accelX: 0,
        accelY: 0,
        accelZ: 9.81 + math.sin(2 * math.pi * 2 * i * step / 1000),
      );
  test(
    'adding second IMU and HR packets preserves physical window boundaries',
    () {
      final one = [for (var i = 0; i < 100; i++) sample(i, 'left')];
      final two = [
        ...one,
        for (var i = 0; i < 100; i++) sample(i, 'right'),
        SensorReading(
          id: 999,
          deviceId: 'hr',
          deviceType: 'verityBand',
          sequenceNo: 1,
          timestampUtc: base,
          sensorType: 'hr',
          heartRate: 80,
          mountLocation: 'forearm',
        ),
      ];
      const service = WindowedFeatureExtractorService();
      final a = service.extractWindows(readings: one);
      final b = service.extractWindows(readings: two.reversed.toList());
      expect(a.length, b.length);
      expect(b.first['duration_sec'], closeTo(1.48, .001));
      expect(b.first['sample_count'], 151);
      expect(
        b.first['w1_accel_z_mean'],
        closeTo(a.first['w1_accel_z_mean'] as double, .00001),
      );
      expect(b.first['w2_device_id'], 'right');
      expect(b.first['w1_sample_rate_hz'], 50);
    },
  );
  test('decimated signal uses measured rate, irregular cadence disables fixed-rate FFT', () {
    const service = WindowedFeatureExtractorService(windowDurationSec: 3);
    final regular = service
        .extractWindows(
          readings: [for (var i = 0; i < 30; i++) sample(i, 'left', step: 100)],
        )
        .first;
    expect(regular['w1_sample_rate_hz'], 10);
    expect(regular['w1_accel_z_dominant_freq_hz'], closeTo(2, .5));
    final irregular = service
        .extractWindows(
          readings: [
            for (var i = 0; i < 30; i++)
              sample(i, 'left', step: 100, jitter: i.isOdd ? 30 : 0),
          ],
        )
        .first;
    expect(irregular['w1_sample_rate_hz'], 0);
    expect(irregular['w1_accel_z_dominant_freq_hz'], 0);
    expect(irregular['w1_peak_jerk_mps3'], lessThan(30));
  });
  test('automatic split partitions raw samples before overlapping windows', () {
    const service = WindowedFeatureExtractorService();
    final windows = service.extractWindows(
      readings: [for (var i = 0; i < 400; i++) sample(i, 'left')],
    );
    final rowsBySplit = <String, Set<int>>{};
    for (final w in windows) {
      final ids = rowsBySplit.putIfAbsent(
        w['dataset_split'] as String,
        () => {},
      );
      for (
        var i = w['start_row_idx'] as int;
        i <= (w['end_row_idx'] as int);
        i++
      ) {
        ids.add(i);
      }
    }
    expect(rowsBySplit.keys.toSet(), {'train', 'val', 'test'});
    expect(rowsBySplit['train']!.intersection(rowsBySplit['val']!), isEmpty);
    expect(rowsBySplit['train']!.intersection(rowsBySplit['test']!), isEmpty);
    expect(rowsBySplit['val']!.intersection(rowsBySplit['test']!), isEmpty);
  });
}
