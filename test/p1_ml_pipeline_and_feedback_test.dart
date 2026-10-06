import 'dart:io';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/core/services/rider_feedback_service.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/data/services/ml_starter_script_generator.dart';
import 'package:ride_sensor_capture/features/export/models/export_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase db;
  late ExportRepositoryImpl exportRepo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ml_export_test_');

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async => tempDir.path,
    );

    db = AppDatabase.forTesting(NativeDatabase.memory());
    exportRepo = ExportRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('P1: Rider Feedback Service Tests', () {
    test('RiderFeedbackService methods execute without throwing unhandled exceptions', () async {
      // In unit test environment, HapticFeedback & SystemSound are safely handled
      await expectLater(RiderFeedbackService.onEventStarted(), completes);
      await expectLater(RiderFeedbackService.onEventStopped(), completes);
      await expectLater(RiderFeedbackService.onVoiceCommandTriggered(), completes);
      await expectLater(RiderFeedbackService.onTripStarted(), completes);
      await expectLater(RiderFeedbackService.onTripStopped(), completes);
    });
  });

  group('P1: ML Starter Script Generator Tests', () {
    test('generateTrainBaselineScript creates valid Python script with key ML modules', () {
      final script = MlStarterScriptGenerator.generateTrainBaselineScript(
        defaultCsvFilename: 'trip_1_ramesh_lefthand.csv',
      );

      // Verify imports
      expect(script.contains('import pandas as pd'), isTrue);
      expect(script.contains('import numpy as np'), isTrue);
      expect(script.contains('RandomForestClassifier'), isTrue);
      expect(script.contains('HistGradientBoostingClassifier'), isTrue);
      expect(script.contains('from scipy import signal, stats'), isTrue);
      expect(script.contains('import joblib'), isTrue);

      // Verify default CSV embedding
      expect(script.contains("'trip_1_ramesh_lefthand.csv'"), isTrue);

      // Verify feature engineering functions
      expect(script.contains('def extract_window_features('), isTrue);
      expect(script.contains('def build_windowed_dataset('), isTrue);
      expect(script.contains('def train_and_evaluate('), isTrue);

      // Verify multi-sensor cross correlation feature computation
      expect(script.contains('fork_foot_peak_corr'), isTrue);
      expect(script.contains('fork_foot_lag_ms'), isTrue);
      expect(script.contains('spectral_energy'), isTrue);
      expect(script.contains('dominant_freq_hz'), isTrue);

      // Verify model artifact persistence
      expect(script.contains('trained_ride_classifier.joblib'), isTrue);
      expect(script.contains('dataset_features_windowed_1s.csv'), isTrue);
    });
  });

  group('P1: Bundled ML Python Script in Trip & Dataset Exports', () {
    test('generateTripExportFiles bundles train_baseline.py alongside CSV export', () async {
      // Create test trip
      final now = DateTime.now().toUtc();
      final tripId = await db.into(db.trips).insert(
            TripsCompanion.insert(
              startTimeUtc: now.subtract(const Duration(minutes: 5)),
              durationSeconds: const drift.Value(300),
              riderName: const drift.Value('Ramesh'),
              wristSide: const drift.Value('Left Hand'),
            ),
          );

      // Add sensor reading
      await db.into(db.sensorReadings).insert(
            SensorReadingsCompanion.insert(
              tripId: drift.Value(tripId),
              deviceId: 'watch_fork',
              deviceType: 'watch',
              sequenceNo: 1,
              timestampUtc: now,
              sensorType: 'imu',
              accelX: const drift.Value(0.12),
              accelY: const drift.Value(0.34),
              accelZ: const drift.Value(9.81),
            ),
          );

      // Export with CSV format
      final files = await exportRepo.generateTripExportFiles(tripId, format: ExportFormat.csv);

      // Should produce raw CSV, features_windowed CSV, AND train_baseline_*.py
      expect(files.length, equals(3));
      final csvFile = files.firstWhere((f) => f.path.endsWith('.csv') && !f.path.contains('features_windowed'));
      final pyFile = files.firstWhere((f) => f.path.endsWith('.py'));

      expect(await csvFile.exists(), isTrue);
      expect(await pyFile.exists(), isTrue);

      final pyContent = await pyFile.readAsString();
      expect(pyContent.contains('RandomForestClassifier'), isTrue);
      expect(pyContent.contains(csvFile.path.split('/').last), isTrue);
    });

    test('generateExportFiles for full session bundles train_baseline.py', () async {
      final now = DateTime.now().toUtc();
      await db.into(db.sensorReadings).insert(
            SensorReadingsCompanion.insert(
              deviceId: 'watch_fork',
              deviceType: 'watch',
              sequenceNo: 1,
              timestampUtc: now,
              sensorType: 'imu',
              accelX: const drift.Value(0.0),
              accelY: const drift.Value(0.0),
              accelZ: const drift.Value(9.8),
            ),
          );

      final files = await exportRepo.generateExportFiles(
        mode: ExportMode.fullRawSession,
        format: ExportFormat.csv,
      );

      final pyFiles = files.where((f) => f.path.endsWith('.py')).toList();
      expect(pyFiles.isNotEmpty, isTrue);
      final pyContent = await pyFiles.first.readAsString();
      expect(pyContent.contains('extract_window_features'), isTrue);
    });
  });
}
