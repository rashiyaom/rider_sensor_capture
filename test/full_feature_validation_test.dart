import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';

import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/data/services/live_ml_inference_service.dart';
import 'package:ride_sensor_capture/features/dashboard/presentation/live_map_widget.dart';
import 'package:ride_sensor_capture/features/dashboard/presentation/speedometer_widget.dart';
import 'package:ride_sensor_capture/features/export/models/export_options.dart';
import 'package:ride_sensor_capture/providers/ml_inference_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase db;
  late ExportRepositoryImpl exportRepo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('full_val_test_');
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

  group('Full App Feature Validation Tests', () {
    testWidgets('1. SpeedometerWidget renders gauge dial, digital readout, and units', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SpeedometerWidget(
                speedKmh: 42.5,
                maxSpeed: 80.0,
                size: 220,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Validate speed readout
      expect(find.text('42.5'), findsOneWidget);
      expect(find.text('km/h'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('2. TripRouteMapWidget renders OpenStreetMap view without errors', (tester) async {
      final routePoints = [
        {'lat': 12.9716, 'lng': 77.5946},
        {'lat': 12.9720, 'lng': 77.5950},
        {'lat': 12.9730, 'lng': 77.5960},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripRouteMapWidget(
              routePoints: routePoints,
              startLat: 12.9716,
              startLng: 77.5946,
              endLat: 12.9730,
              endLng: 77.5960,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(TripRouteMapWidget), findsOneWidget);
    });

    testWidgets('3. Edge ML Inference live predictions dynamic update in UI', (tester) async {
      final mlService = LiveMlInferenceService();
      final now = DateTime.now().toUtc();

      // Feed severe bump impulse
      for (int i = 0; i < 20; i++) {
        final az = (i == 15) ? 26.0 : 9.81;
        mlService.ingestReading(RawSensorData(
          deviceId: 'watch_fork',
          deviceName: 'Watch Fork',
          deviceType: DeviceType.watch,
          timestamp: now.add(Duration(milliseconds: i * 20)),
          mountLocation: 'fork',
          accelX: 0.0,
          accelY: 0.0,
          accelZ: az,
          rawBytes: const [],
        ), forceInference: true);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveMlInferenceServiceProvider.overrideWithValue(mlService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final pred = ref.watch(latestMlPredictionProvider);
                  return Column(
                    children: [
                      Text(pred.label),
                      Text('${(pred.confidence * 100).toInt()}%'),
                      Text('Z: ${pred.topFeatures['z_peak_mps2']?.toStringAsFixed(1)}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Severe Bump / Pothole'), findsOneWidget);
      expect(find.text('Z: 26.0'), findsOneWidget);

      mlService.dispose();
    });

    test('4. End-to-end trip export bundles Raw CSV, Windowed Feature CSV, and train_baseline.py', () async {
      final now = DateTime.now().toUtc();

      final tripId = await db.into(db.trips).insert(
        TripsCompanion.insert(
          startTimeUtc: now,
          totalDistanceKm: const drift.Value(5.4),
          avgSpeedKmh: const drift.Value(24.5),
          maxSpeedKmh: const drift.Value(48.2),
        ),
      );

      // Seed 100 samples (2.0s @ 50Hz) to exceed 1.5s window
      final readings = <SensorReadingsCompanion>[];
      for (int i = 0; i < 100; i++) {
        readings.add(SensorReadingsCompanion.insert(
          tripId: drift.Value(tripId),
          deviceId: 'watch_1',
          deviceType: 'watch',
          mountLocation: const drift.Value('fork'),
          sequenceNo: i,
          timestampUtc: now.add(Duration(milliseconds: i * 20)),
          sensorType: 'imu',
          accelX: const drift.Value(0.1),
          accelY: const drift.Value(0.2),
          accelZ: const drift.Value(9.81),
          gyroX: const drift.Value(0.01),
          gyroY: const drift.Value(0.02),
          gyroZ: const drift.Value(0.03),
          heartRate: const drift.Value(78),
          gpsSpeedKmh: const drift.Value(25.0),
        ));
      }
      await db.batch((b) => b.insertAll(db.sensorReadings, readings));

      // Generate trip export files
      final files = await exportRepo.generateTripExportFiles(
        tripId,
        format: ExportFormat.csv,
      );

      expect(files.length, equals(3));
      
      final rawCsv = files.firstWhere((f) => f.path.endsWith('.csv') && !f.path.contains('features_windowed'));
      final windowedCsv = files.firstWhere((f) => f.path.contains('features_windowed'));
      final pythonScript = files.firstWhere((f) => f.path.endsWith('.py'));

      expect(await rawCsv.exists(), isTrue);
      expect(await windowedCsv.exists(), isTrue);
      expect(await pythonScript.exists(), isTrue);

      final rawContent = await rawCsv.readAsString();
      expect(rawContent.contains('gps_speed_kmh'), isTrue);

      final windowedContent = await windowedCsv.readAsString();
      expect(windowedContent.contains('z_rms'), isTrue);
      expect(windowedContent.contains('dataset_split'), isTrue);

      final pyContent = await pythonScript.readAsString();
      expect(pyContent.contains('RandomForestClassifier'), isTrue);
      expect(pyContent.contains('features_windowed'), isTrue);
    });
  });
}
