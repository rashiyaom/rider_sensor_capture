import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/data/services/live_ml_inference_service.dart';

void main() {
  test('replays the generated dual-wrist sample without claiming field accuracy', () async {
    final csvFile = File('../sample_dual_wrist_ride_dataset.csv');
    expect(await csvFile.exists(), isTrue);
    final extraction = await Process.run('python3', [
      '-c',
      r'''
import csv, json, sys
with open(sys.argv[1], newline='') as source:
    for row in csv.DictReader(source):
        if row['wrist_side'] == 'left_hand':
            print(json.dumps([row[k] for k in (
                'timestamp_iso8601', 'accel_x', 'accel_y', 'accel_z',
                'gyro_x', 'gyro_y', 'gyro_z', 'event_type'
            )]))
''',
      csvFile.path,
    ]);
    expect(extraction.exitCode, 0, reason: '${extraction.stderr}');

    final rows = const LineSplitter()
        .convert(extraction.stdout as String)
        .where((line) => line.isNotEmpty)
        .map((line) => (jsonDecode(line) as List).cast<String>())
        .toList();
    expect(rows.length, 15000);

    final truth = <(String, DateTime, DateTime)>[];
    String? currentLabel;
    DateTime? currentStart;
    DateTime? currentEnd;
    for (final row in rows) {
      final at = DateTime.parse(row[0]);
      final label = row[7];
      if (label != currentLabel) {
        if (currentLabel != null && currentLabel.isNotEmpty) {
          truth.add((currentLabel, currentStart!, currentEnd!));
        }
        currentLabel = label;
        currentStart = at;
      }
      currentEnd = at;
    }
    if (currentLabel != null && currentLabel.isNotEmpty) {
      truth.add((currentLabel, currentStart!, currentEnd!));
    }
    expect(truth.length, 7);

    final service = LiveMlInferenceService();
    final predictions = <(DateTime, MlPredictedEventType)>[];
    for (final row in rows) {
      final at = DateTime.parse(row[0]);
      service.ingestReading(
        RawSensorData(
          deviceId: 'sample_left_wrist',
          deviceName: 'Sample left wrist',
          deviceType: DeviceType.watch,
          timestamp: at,
          mountLocation: 'left_hand',
          accelX: double.parse(row[1]),
          accelY: double.parse(row[2]),
          accelZ: double.parse(row[3]),
          gyroX: double.parse(row[4]),
          gyroY: double.parse(row[5]),
          gyroZ: double.parse(row[6]),
          rawBytes: const [],
        ),
      );
      final prediction = service.latestPrediction;
      if (prediction.timestampUtc == at) {
        predictions.add((at, prediction.eventType));
      }
    }
    service.dispose();

    bool matches(String label, MlPredictedEventType prediction) =>
        switch (label) {
          'pothole' || 'speed_bump' =>
            prediction == MlPredictedEventType.mildBump ||
                prediction == MlPredictedEventType.severeBump,
          'sharp_turn' => prediction == MlPredictedEventType.sharpTurn,
          'hard_brake' => prediction == MlPredictedEventType.hardBraking,
          _ => false,
        };

    final hits = <String, int>{};
    for (final event in truth) {
      final detected = predictions.any(
        (p) =>
            !p.$1.isBefore(event.$2) &&
            !p.$1.isAfter(event.$3.add(const Duration(seconds: 1))) &&
            matches(event.$1, p.$2),
      );
      hits[event.$1] = (hits[event.$1] ?? 0) + (detected ? 1 : 0);
    }

    DateTime? previousFalseAlert;
    var falseAlertEpisodes = 0;
    for (final prediction in predictions) {
      if (prediction.$2 == MlPredictedEventType.normalRiding) continue;
      final nearTruth = truth.any(
        (event) =>
            !prediction.$1.isBefore(
              event.$2.subtract(const Duration(seconds: 1)),
            ) &&
            !prediction.$1.isAfter(
              event.$3.add(const Duration(milliseconds: 1500)),
            ),
      );
      if (nearTruth) continue;
      if (previousFalseAlert == null ||
          prediction.$1.difference(previousFalseAlert) >
              const Duration(seconds: 3)) {
        falseAlertEpisodes++;
      }
      previousFalseAlert = prediction.$1;
    }

    debugPrint(
      'Synthetic replay: ${truth.length} labeled events; hits by type $hits; '
      '$falseAlertEpisodes false-alert episodes in the 5-minute generated ride.',
    );
    expect(predictions, isNotEmpty);
  });
}
