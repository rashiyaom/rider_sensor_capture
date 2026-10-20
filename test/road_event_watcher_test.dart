import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/services/live_ml_inference_service.dart';
import 'package:ride_sensor_capture/location/location_service.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_engine.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_service.dart';
import 'package:ride_sensor_capture/prealert/road_event_watcher.dart';
import 'package:ride_sensor_capture/voice/voice_alert_service.dart';

const double kLat = 12.9716;
const double kLon = 77.5946;
const double kDegPerMeter = 1.0 / 111195.0;

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

LiveMlPrediction _prediction(
  MlPredictedEventType type, {
  double confidence = 0.95,
}) {
  return LiveMlPrediction(
    eventType: type,
    label: type.name,
    confidence: confidence,
    timestampUtc: DateTime.utc(2026, 10, 20, 10),
    topFeatures: const {},
    explanation: 'test',
  );
}

void main() {
  late AppDatabase db;
  late PreAlertService service;

  setUp(() {
    db = _makeTestDb();
    service = PreAlertService(
      db: db,
      voiceService: VoiceAlertService(ttsEnabled: false),
    );
  });

  tearDown(() async {
    await service.stop();
    await db.close();
  });

  group('RoadEventWatcher', () {
    test('registers a severe bump detection as a pothole hazard', () async {
      final locationService = LocationService();
      locationService.injectFixForTesting(
        LocationFix(
          latitude: kLat,
          longitude: kLon,
          gpsSpeedMps: 15,
          timestampUtc: DateTime.utc(2026, 10, 20, 10),
        ),
      );

      final watcher = RoadEventWatcher(
        preAlertService: service,
        locationService: locationService,
      );
      watcher.handlePrediction(
        _prediction(MlPredictedEventType.severeBump, confidence: 0.95),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final roadEvents = await db.select(db.roadEvents).get();
      expect(roadEvents, hasLength(1));
      expect(roadEvents.first.eventType, 'pothole');
      expect(roadEvents.first.source, 'ml');
      expect(roadEvents.first.latitude, closeTo(kLat, 0.0001));
      expect(roadEvents.first.speedKmhAtDetection, closeTo(54.0, 0.5));
    });

    test('registers a sharp turn as a turn hazard', () async {
      final locationService = LocationService();
      locationService.injectFixForTesting(
        LocationFix(
          latitude: kLat,
          longitude: kLon,
          timestampUtc: DateTime.utc(2026, 10, 20, 10),
        ),
      );

      final watcher = RoadEventWatcher(
        preAlertService: service,
        locationService: locationService,
      );
      watcher.handlePrediction(
        _prediction(MlPredictedEventType.sharpTurn, confidence: 0.9),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final roadEvents = await db.select(db.roadEvents).get();
      expect(roadEvents, hasLength(1));
      expect(roadEvents.first.eventType, 'turn');
    });

    test('ignores normal riding', () async {
      final locationService = LocationService();
      locationService.injectFixForTesting(
        LocationFix(
          latitude: kLat,
          longitude: kLon,
          timestampUtc: DateTime.utc(2026, 10, 20, 10),
        ),
      );

      final watcher = RoadEventWatcher(
        preAlertService: service,
        locationService: locationService,
      );
      watcher.handlePrediction(
        _prediction(MlPredictedEventType.normalRiding, confidence: 0.99),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final roadEvents = await db.select(db.roadEvents).get();
      expect(roadEvents, isEmpty);
    });

    test('ignores low-confidence detections', () async {
      final locationService = LocationService();
      locationService.injectFixForTesting(
        LocationFix(
          latitude: kLat,
          longitude: kLon,
          timestampUtc: DateTime.utc(2026, 10, 20, 10),
        ),
      );

      final watcher = RoadEventWatcher(
        preAlertService: service,
        locationService: locationService,
      );
      watcher.handlePrediction(
        _prediction(MlPredictedEventType.severeBump, confidence: 0.4),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final roadEvents = await db.select(db.roadEvents).get();
      expect(roadEvents, isEmpty);
    });

    test('deduplicates repeated detections of the same class', () async {
      final locationService = LocationService();
      locationService.injectFixForTesting(
        LocationFix(
          latitude: kLat,
          longitude: kLon,
          timestampUtc: DateTime.utc(2026, 10, 20, 10),
        ),
      );

      final watcher = RoadEventWatcher(
        preAlertService: service,
        locationService: locationService,
      );
      watcher.handlePrediction(
        _prediction(MlPredictedEventType.mildBump, confidence: 0.9),
      );
      watcher.handlePrediction(
        _prediction(MlPredictedEventType.mildBump, confidence: 0.9),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final roadEvents = await db.select(db.roadEvents).get();
      expect(roadEvents, hasLength(1));
    });
  });

  group('End-to-end learning loop', () {
    test('a learned hazard produces a warning, which is scored by the feedback',
        () async {
      // 1. The rider hits a bump for the first time — it is learned.
      final roadEventId = await service.registerDetectedRoadEvent(
        kind: RoadEventKind.bump,
        latitude: kLat + 400 * kDegPerMeter,
        longitude: kLon,
        severity: 0.6,
        confidence: 0.95,
        source: 'ml',
      );
      expect(roadEventId, greaterThan(0));

      // 2. On a later pass the rider is warned before reaching it.
      await service.start();
      await service.handleLocationFix(
        LocationFix(
          latitude: kLat,
          longitude: kLon,
          gpsSpeedMps: 25, // 90 km/h
          timestampUtc: DateTime.utc(2026, 10, 20, 11),
        ),
      );

      final alerts = await db.select(db.preAlerts).get();
      expect(alerts, hasLength(1));
      expect(alerts.first.roadEventId, roadEventId);
      expect(alerts.first.timeToEventSeconds, closeTo(16.0, 0.5));

      // 3. The hazard's alert counter reflects the warning.
      final roadEvent =
          await db.select(db.roadEvents).getSingle();
      expect(roadEvent.alertCount, 1);

      // 4. The warning is linked to the completed event.
      await service.linkEventToPreAlert(55);
      final linked = await db.select(db.preAlerts).getSingle();
      expect(linked.eventId, 55);
    });
  });
}
