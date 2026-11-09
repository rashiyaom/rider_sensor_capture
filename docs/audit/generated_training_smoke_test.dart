import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/services/ml_starter_script_generator.dart';

void main() {
  test('generated Python trainer accepts string event labels', () async {
    final directory = await Directory.systemTemp.createTemp('ride_ml_smoke_');
    try {
      final script = File('${directory.path}/train_baseline.py');
      await script.writeAsString(
        MlStarterScriptGenerator.generateTrainBaselineScript(),
      );
      final result = await Process.run('python3', [
        '-c',
        r'''
import importlib.util
import sys
import pandas as pd

spec = importlib.util.spec_from_file_location('ride_trainer', sys.argv[1])
trainer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(trainer)

rows = 150
frame = pd.DataFrame({
    'accel_x': [0.1] * rows,
    'accel_y': [0.2] * rows,
    'accel_z': [9.81] * rows,
    'event_type': ['road_impact'] * 30 + ['normal_riding'] * (rows - 30),
})
features, labels = trainer.build_windowed_dataset(frame, 'event_type')
assert len(features) > 0
assert labels.iloc[0] == 'road_impact', list(labels)
print('labeled window accepted')
''',
        script.path,
      ]);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      expect(result.stdout, contains('labeled window accepted'));
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('generated trainer uses exported splits and rejects raw rows', () async {
    final directory = await Directory.systemTemp.createTemp('ride_ml_export_');
    try {
      final script = File('${directory.path}/train_baseline.py');
      await script.writeAsString(
        MlStarterScriptGenerator.generateTrainBaselineScript(),
      );
      final features = File('${directory.path}/features_windowed_fixture.csv');
      final csv = StringBuffer(
        'window_index,trip_id,dataset_split,split_strategy,target_label,target_label_id,event_id,event_cross_confirmed,w1_z_rms,w1_peak_jerk_mps3\n',
      );
      for (var i = 0; i < 60; i++) {
        final split = i < 40 ? 'train' : (i < 50 ? 'val' : 'test');
        final impact = i.isOdd;
        csv.writeln(
          '${i + 1},1,$split,chronological_disjoint_samples,${impact ? 'bump' : 'normal_riding'},${impact ? 1 : 0},${impact ? i + 1 : ''},${impact ? 1 : 0},${impact ? 17 : 10},${impact ? 110 : 2}',
        );
      }
      await features.writeAsString(csv.toString());
      final trained = await Process.run('python3', [
        script.path,
        '--csv',
        features.path,
      ], workingDirectory: directory.path);
      expect(
        trained.exitCode,
        0,
        reason: '${trained.stdout}\n${trained.stderr}',
      );
      expect(
        await File('${directory.path}/trained_ride_classifier.joblib').exists(),
        isTrue,
      );

      final metadata = await Process.run('python3', [
        '-c',
        r'''
import joblib, sys
model = joblib.load(sys.argv[1])
assert model['feature_names'] == ['w1_z_rms', 'w1_peak_jerk_mps3'], model['feature_names']
''',
        '${directory.path}/trained_ride_classifier.joblib',
      ]);
      expect(
        metadata.exitCode,
        0,
        reason: '${metadata.stdout}\n${metadata.stderr}',
      );

      final raw = File('${directory.path}/raw.csv');
      await raw.writeAsString(
        'timestamp_iso8601,event_type,accel_x\n2026-11-08T00:00:00Z,bump,12\n',
      );
      final rejected = await Process.run('python3', [
        script.path,
        '--csv',
        raw.path,
      ], workingDirectory: directory.path);
      expect(rejected.exitCode, isNot(0));
      expect(rejected.stdout, contains('raw sensor CSVs cannot be trained'));
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
