import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/location/location_service.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_engine.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_service.dart';
import 'package:ride_sensor_capture/prealert/road_event_registry.dart';
import 'package:ride_sensor_capture/voice/voice_alert_service.dart';

const double kLat = 12.9716;
const double kLon = 77.5946;
const double kDegPerMeter = 1.0 / 111195.0;

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

LocationFix _fix({
  double lat = kLat,
  double lon = kLon,
  double speedKmh = 90,
  double? headingDeg,
}) {
  return LocationFix(
    latitude: lat,
    longitude: lon,
    gpsSpeedMps: speedKmh / 3.6,
    gpsHeadingDeg: headingDeg,
    timestampUtc: DateTime.utc(2026, 10, 20, 10, 0, 0),
  );
}

void main() {
  late AppDatabase db;
  late PreAlertService service;

  setUp(() {
    db = _makeTestDb();
    // TTS disabled so no platform channel is touched in unit tests.
    service = PreAlertService(
      db: db,
      voiceService: VoiceAlertService(ttsEnabled: false),
    );
  });

  tearDown(() async {
    await service.stop();
    await db.close();
  });

  group('RoadEventRegistry', () {
    test('registers and retrieves a hazard within the search radius', () async {
      final registry = RoadEventRegistry(db);
      await registry.register(
        kind: RoadEventKind.bump,
        latitude: kLat + 400 * kDegPerMeter,
        longitude: kLon,
        severity: 0.7,
        confidence: 0.95,
        source: 'ml',
      );

      final near = await registry.loadCandidates(
        latitude: kLat,
        longitude: kLon,
        radiusMeters: 800,
      );
      expect(near, hasLength(1));
      expect(near.first.kind, RoadEventKind.bump);
      expect(near.first.severity, closeTo(0.7, 0.001));
      expect(near.first.confidence, closeTo(0.95, 0.001));
      expect(near.first.source, 'ml');
    });

    test('excludes hazards outside the search radius', () async {
      final registry = RoadEventRegistry(db);
      await registry.register(
        kind: RoadEventKind.pothole,
        latitude: kLat + 2000 * kDegPerMeter,
        longitude: kLon,
      );

      final near = await registry.loadCandidates(
        latitude: kLat,
        longitude: kLon,
        radiusMeters: 800,
      );
      expect(near, isEmpty);
    });

    test('tracks the alert counter for a hazard', () async {
      final registry = RoadEventRegistry(db);
      final id = await registry.register(
        kind: RoadEventKind.bump,
        latitude: kLat,
        longitude: kLon,
      );
      await registry.incrementAlertCount(id);
      await registry.incrementAlertCount(id);

      final row = await registry.getById(id);
      expect(row!.alertCount, 2);
      expect(row.lastAlertedAtUtc, isNotNull);
    });
  });

  group('PreAlertService — issuing a warning', () {
    test('speaks and persists a warning for a known hazard ahead', () async {
      await service.registerDetectedRoadEvent(
        kind: RoadEventKind.bump,
        latitude: kLat + 400 * kDegPerMeter,
        longitude: kLon,
        severity: 0.5,
        confidence: 0.95,
      );

      await service.start();
      await service.handleLocationFix(_fix(speedKmh: 90));

      final alerts = await db.select(db.preAlerts).get();
      expect(alerts, hasLength(1));

      final alert = alerts.first;
      expect(alert.eventType, 'bump');
      expect(alert.distanceMeters, closeTo(400.0, 10.0));
      expect(alert.speedKmh, closeTo(90.0, 0.1));
      expect(alert.timeToEventSeconds, closeTo(16.0, 0.5));
      expect(alert.spokenText, contains('Speed bump ahead'));
      expect(alert.spokenText, contains('400'));
    });

    test('does not warn twice about the same hazard', () async {
      await service.registerDetectedRoadEvent(
        kind: RoadEventKind.bump,
        latitude: kLat + 400 * kDegPerMeter,
        longitude: kLon,
        severity: 0.5,
      );

      await service.start();
      await service.handleLocationFix(_fix(speedKmh: 90));
      await service.handleLocationFix(_fix(speedKmh: 90));

      final alerts = await db.select(db.preAlerts).get();
      expect(alerts, hasLength(1));
    });

    test('does not warn when there is no known hazard', () async {
      await service.start();
      await service.handleLocationFix(_fix(speedKmh: 90));

      final alerts = await db.select(db.preAlerts).get();
      expect(alerts, isEmpty);
    });

    test('does not warn when the rider is nearly stopped', () async {
      await service.registerDetectedRoadEvent(
        kind: RoadEventKind.bump,
        latitude: kLat + 400 * kDegPerMeter,
        longitude: kLon,
      );

      await service.start();
      await service.handleLocationFix(_fix(speedKmh: 2));

      final alerts = await db.select(db.preAlerts).get();
      expect(alerts, isEmpty);
    });

    test('surfaces the decision on the alert stream', () async {
      await service.registerDetectedRoadEvent(
        kind: RoadEventKind.pothole,
        latitude: kLat + 120 * kDegPerMeter,
        longitude: kLon,
        severity: 0.9,
      );

      final received = <PreAlertDecision>[];
      final sub = service.alertStream.listen(received.add);

      await service.start();
      await service.handleLocationFix(_fix(speedKmh: 60));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(received, hasLength(1));
      expect(received.first.candidate.kind, RoadEventKind.pothole);
      // 120 m at 60 km/h -> ~7.2 s to the event -> "warning" urgency.
      expect(received.first.urgency, PreAlertUrgency.warning);
      expect(service.activeAlert, isNotNull);
    });

    test('attributes the warning to the active trip', () async {
      await service.registerDetectedRoadEvent(
        kind: RoadEventKind.bump,
        latitude: kLat + 400 * kDegPerMeter,
        longitude: kLon,
      );
      service.setActiveTripId(42);

      await service.start();
      await service.handleLocationFix(_fix(speedKmh: 90));

      final alerts = await db.select(db.preAlerts).get();
      expect(alerts.first.tripId, 42);
    });
  });

  group('PreAlertService — event linking', () {
    test('links the most recent warning to a completed event', () async {
      await service.registerDetectedRoadEvent(
        kind: RoadEventKind.bump,
        latitude: kLat + 400 * kDegPerMeter,
        longitude: kLon,
      );
      service.setActiveTripId(7);

      await service.start();
      await service.handleLocationFix(_fix(speedKmh: 90));

      final alert = await service.findMostRecentPreAlert(within: const Duration(minutes: 5));
      expect(alert, isNotNull);

      await service.linkEventToPreAlert(123);

      final updated = await db.select(db.preAlerts).getSingle();
      expect(updated.eventId, 123);
    });

    test('findMostRecentPreAlert returns null when nothing was spoken', () async {
      final alert = await service.findMostRecentPreAlert(within: const Duration(minutes: 5));
      expect(alert, isNull);
    });
  });
}
