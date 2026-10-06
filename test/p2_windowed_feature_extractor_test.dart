import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/data/services/windowed_feature_extractor_service.dart';
import 'package:ride_sensor_capture/features/export/models/export_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase db;
  late ExportRepositoryImpl exportRepo;
  late WindowedFeatureExtractorService extractor;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('p2_window_test_');

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async => tempDir.path,
    );

    db = AppDatabase.forTesting(NativeDatabase.memory());
    exportRepo = ExportRepositoryImpl(db);
    extractor = const WindowedFeatureExtractorService(
      sampleRateHz: 50.0,
      windowDurationSec: 1.0, // 50 samples
      strideDurationSec: 0.5, // 25 samples
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('P2: WindowedFeatureExtractorService Feature Extraction Tests', () {
    test('extracts correct statistical, vector magnitude, and FFT features', () {
      final now = DateTime.now().toUtc();
      final readings = <SensorReading>[];

      // Generate 100 samples (2.0s @ 50Hz) with synthetic 5Hz sine wave on fork Z
      for (int i = 0; i < 100; i++) {
        final t = now.add(Duration(milliseconds: i * 20));
        final timeSec = i / 50.0;
        final sineVal = math.sin(2 * math.pi * 5.0 * timeSec) * 2.0;

        readings.add(SensorReading(
          id: i + 1,
          tripId: 1,
          deviceId: 'watch_fork',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: i,
          timestampUtc: t,
          sensorType: 'imu',
          accelX: 0.5,
          accelY: 0.0,
          accelZ: 9.8 + sineVal,
          gyroX: 0.1,
          gyroY: 0.2,
          gyroZ: 0.3,
          heartRate: 75,
        ));
      }

      final windows = extractor.extractWindows(
        readings: readings,
        tripId: 1,
      );

      // 100 samples with window=50, stride=25 -> (100-50)/25 + 1 = 3 windows
      expect(windows.length, equals(3));

      final firstWin = windows.first;
      expect(firstWin['window_index'], equals(1));
      expect(firstWin['sample_count'], equals(50));
      expect(firstWin['target_label'], equals('normal_riding'));
      expect(firstWin['target_label_id'], equals(0));

      // Check Watch 1 mean & RMS features
      expect(firstWin['w1_accel_x_mean'], closeTo(0.5, 0.01));
      expect(firstWin['w1_accel_z_mean'], closeTo(9.8, 0.5));
      expect(firstWin['w1_accel_mag_mean'], greaterThan(9.0));

      // Check FFT peak frequency is near 5Hz
      expect(firstWin['w1_accel_z_dominant_freq_hz'], closeTo(5.0, 1.5));
      expect(firstWin['w1_accel_z_spectral_energy'], greaterThan(0.0));
    });

    test('correctly computes Fork vs Footboard cross-correlation and lag', () {
      final now = DateTime.now().toUtc();
      final readings = <SensorReading>[];

      // Simulate a bump impulse on Fork at sample 20, and on Footboard at sample 22 (40ms lag)
      for (int i = 0; i < 50; i++) {
        final t = now.add(Duration(milliseconds: i * 20));

        final forkImpulse = (i == 20) ? 25.0 : 9.8;
        final footImpulse = (i == 22) ? 22.0 : 9.8;

        // Fork reading
        readings.add(SensorReading(
          id: i * 2 + 1,
          tripId: 1,
          deviceId: 'watch_fork',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: i,
          timestampUtc: t,
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: forkImpulse,
        ));

        // Footboard reading
        readings.add(SensorReading(
          id: i * 2 + 2,
          tripId: 1,
          deviceId: 'watch_footboard',
          deviceType: 'watch',
          mountLocation: 'footboard',
          sequenceNo: i,
          timestampUtc: t,
          sensorType: 'imu',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: footImpulse,
        ));
      }

      final windows = extractor.extractWindows(readings: readings, tripId: 1);
      expect(windows.isNotEmpty, isTrue);

      final win = windows.first;
      expect(win['fork_foot_corr_peak'], greaterThan(0.7));
      // Lag should be positive ~40ms
      expect(win['fork_foot_lag_ms'], closeTo(40.0, 25.0));
    });

    test('accurately maps ground-truth labels and integer encodings', () {
      final now = DateTime.now().toUtc();
      final readings = <SensorReading>[];

      // Create an event record for a bump
      final bumpEvent = EventRecord(
        id: 101,
        eventType: 'bump',
        startTimestamp: now.add(const Duration(milliseconds: 200)),
        endTimestamp: now.add(const Duration(milliseconds: 800)),
        status: 'completed',
        classification: 'severe',
        crossConfirmed: true,
        hrSpikeConfirmed: true,
      );

      for (int i = 0; i < 50; i++) {
        final t = now.add(Duration(milliseconds: i * 20));
        // Tag samples 10 to 40 with event ID 101
        final isEvent = i >= 10 && i <= 40;

        readings.add(SensorReading(
          id: i + 1,
          tripId: 1,
          deviceId: 'watch_fork',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: i,
          timestampUtc: t,
          sensorType: 'imu',
          eventId: isEvent ? 101 : null,
          accelX: 0.0,
          accelY: 0.0,
          accelZ: isEvent ? 25.0 : 9.8,
        ));
      }

      final windows = extractor.extractWindows(
        readings: readings,
        events: [bumpEvent],
        tripId: 1,
      );

      expect(windows.isNotEmpty, isTrue);
      final win = windows.first;
      expect(win['target_label'], equals('bump'));
      expect(win['target_label_id'], equals(1)); // 1 = bump
      expect(win['event_id'], equals(101));
      expect(win['event_classification'], equals('severe'));
      expect(win['event_cross_confirmed'], equals(1));
      expect(win['event_hr_spike_confirmed'], equals(1));
    });

    test('buildCsv formats tabular CSV string with complete headers and valid numeric format', () {
      final now = DateTime.now().toUtc();
      final readings = List.generate(
        50,
        (i) => SensorReading(
          id: i + 1,
          tripId: 1,
          deviceId: 'watch_fork',
          deviceType: 'watch',
          mountLocation: 'fork',
          sequenceNo: i,
          timestampUtc: now.add(Duration(milliseconds: i * 20)),
          sensorType: 'imu',
          accelX: 0.1234,
          accelY: 0.5678,
          accelZ: 9.8100,
        ),
      );

      final windows = extractor.extractWindows(readings: readings, tripId: 1);
      final csvString = extractor.buildCsv(windows);

      expect(csvString.isNotEmpty, isTrue);
      final lines = csvString.trim().split('\n');
      expect(lines.length, equals(2)); // Header + 1 data row

      final header = lines.first;
      expect(header.contains('window_index'), isTrue);
      expect(header.contains('dataset_split'), isTrue);
      expect(header.contains('target_label'), isTrue);
      expect(header.contains('w1_accel_z_mean'), isTrue);
      expect(header.contains('w1_accel_z_spectral_energy'), isTrue);
      expect(header.contains('fork_foot_corr_peak'), isTrue);
    });
  });

  group('P2: ExportRepository Integration with Pre-Windowed Feature Tables', () {
    test('generateTripExportFiles generates features_windowed CSV file', () async {
      final now = DateTime.now().toUtc();
      final tripId = await db.into(db.trips).insert(
            TripsCompanion.insert(
              startTimeUtc: now.subtract(const Duration(minutes: 2)),
              durationSeconds: const drift.Value(120),
              riderName: const drift.Value('Om'),
              wristSide: const drift.Value('Both Hands'),
            ),
          );

      // Insert 60 sensor readings
      for (int i = 0; i < 60; i++) {
        await db.into(db.sensorReadings).insert(
              SensorReadingsCompanion.insert(
                tripId: drift.Value(tripId),
                deviceId: 'watch_fork',
                mountLocation: const drift.Value('fork'),
                deviceType: 'watch',
                sequenceNo: i,
                timestampUtc: now.add(Duration(milliseconds: i * 20)),
                sensorType: 'imu',
                accelX: const drift.Value(0.1),
                accelY: const drift.Value(0.2),
                accelZ: const drift.Value(9.8),
              ),
            );
      }

      final files = await exportRepo.generateTripExportFiles(tripId, format: ExportFormat.csv);

      // Should include raw CSV, features_windowed CSV, and Python ML script
      expect(files.length, equals(3));

      final windowedFile = files.firstWhere((f) => f.path.contains('features_windowed_'));
      expect(await windowedFile.exists(), isTrue);

      final content = await windowedFile.readAsString();
      expect(content.contains('target_label'), isTrue);
      expect(content.contains('dataset_split'), isTrue);
      expect(content.contains('w1_accel_z_rms'), isTrue);
    });
  });
}
