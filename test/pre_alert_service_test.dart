import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/location/location_service.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_engine.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_service.dart';
import 'package:ride_sensor_capture/prealert/road_event_registry.dart';
import 'package:ride_sensor_capture/voice/voice_alert_service.dart';

const _ttsChannel = MethodChannel('flutter_tts');

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
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late PreAlertService service;

  setUp(() {
    db = _makeTestDb();
    // TTS disabled so no platform channel is touched in unit tests.
    service = PreAlertService(
      db: db,
      clock: () => DateTime.utc(2026, 10, 20, 10),
      voiceService: VoiceAlertService(ttsEnabled: false),
    );
  });

  tearDown(() async {
    await service.stop();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, null);
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
        latitude: kLat + 220 * kDegPerMeter,
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
      expect(alert.distanceMeters, closeTo(220.0, 10.0));
      expect(alert.speedKmh, closeTo(90.0, 0.1));
      expect(alert.timeToEventSeconds, closeTo(8.8, 0.5));
      expect(alert.spokenText, contains('Speed bump ahead'));
      expect(alert.spokenText, contains('220'));
    });

    test('does not warn twice about the same hazard', () async {
      await service.registerDetectedRoadEvent(
        kind: RoadEventKind.bump,
        latitude: kLat + 220 * kDegPerMeter,
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
        latitude: kLat + 220 * kDegPerMeter,
        longitude: kLon,
      );

      await service.start();
      await service.handleLocationFix(_fix(speedKmh: 2));

      final alerts = await db.select(db.preAlerts).get();
      expect(alerts, isEmpty);
    });

    test('expired warning is logged without invoking speech', () async {
      final clock = DateTime.utc(2026, 10, 20, 10);
      service = PreAlertService(
        db: db,
        clock: () => clock,
        voiceService: VoiceAlertService(ttsEnabled: false),
      );
      final decision = PreAlertDecision(
        candidate: RoadEventCandidate(
          kind: RoadEventKind.bump,
          latitude: kLat,
          longitude: kLon,
          detectedAtUtc: clock,
        ),
        evaluatedAtUtc: clock.subtract(const Duration(seconds: 30)),
        distanceMeters: 100,
        bearingDeg: 0,
        relativeBearingDeg: 0,
        speedKmh: 80,
        timeToEventSeconds: 4.5,
        recommendedSpeedKmh: 30,
        urgency: PreAlertUrgency.warning,
        window: PreAlertWindow.inWindow,
        shouldSpeak: true,
      );
      final id = await service.issueAlert(decision);
      final row = await (db.select(
        db.preAlerts,
      )..where((t) => t.id.equals(id!))).getSingle();
      expect(row.deliveryStatus, 'expired');
      expect(row.deliveredAtUtc, isNull);
      expect(row.deliveryFailure, contains('expired'));
      expect(service.activeAlert, isNull);
    });

    test(
      'failed playback is recorded as failed and does not count as delivered',
      () async {
        await service.registerDetectedRoadEvent(
          kind: RoadEventKind.pothole,
          latitude: kLat + 120 * kDegPerMeter,
          longitude: kLon,
          severity: .9,
        );
        final received = <PreAlertDecision>[];
        final sub = service.alertStream.listen(received.add);
        await service.start();
        await service.handleLocationFix(_fix(speedKmh: 60));
        final row = (await db.select(db.preAlerts).getSingle());
        expect(row.deliveryStatus, 'failed');
        expect(row.deliveredAtUtc, isNull);
        expect(row.deliveryFailure, contains('did not complete'));
        expect(row.roadEventId, isNotNull);
        expect(
          (await RoadEventRegistry(db).getById(row.roadEventId!))!.alertCount,
          0,
        );
        expect(received, isEmpty);
        expect(service.activeAlert, isNull);
        await sub.cancel();
      },
    );

    test(
      'completed playback is the only state counted and streamed as delivered',
      () async {
        await service.stop();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_ttsChannel, (call) async => 1);
        service = PreAlertService(
          db: db,
          clock: () => DateTime.utc(2026, 10, 20, 10),
          voiceService: VoiceAlertService(tts: FlutterTts()),
        );
        await service.registerDetectedRoadEvent(
          kind: RoadEventKind.pothole,
          latitude: kLat + 120 * kDegPerMeter,
          longitude: kLon,
          severity: .9,
        );
        final received = <PreAlertDecision>[];
        final sub = service.alertStream.listen(received.add);
        await service.start();
        await service.handleLocationFix(_fix(speedKmh: 60));
        final row = await db.select(db.preAlerts).getSingle();
        expect(row.deliveryStatus, 'delivered');
        expect(row.deliveredAtUtc, isNotNull);
        expect(row.deliveryFailure, isNull);
        expect(
          (await RoadEventRegistry(db).getById(row.roadEventId!))!.alertCount,
          1,
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
        expect(received, hasLength(1));
        expect(service.activeAlert, isNotNull);
        await sub.cancel();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_ttsChannel, null);
      },
    );

    test('attributes the warning to the active trip', () async {
      await service.registerDetectedRoadEvent(
        kind: RoadEventKind.bump,
        latitude: kLat + 220 * kDegPerMeter,
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
    test(
      'links the most recent delivered warning to a completed event',
      () async {
        await service.stop();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_ttsChannel, (call) async => 1);
        service = PreAlertService(
          db: db,
          clock: () => DateTime.utc(2026, 10, 20, 10),
          voiceService: VoiceAlertService(tts: FlutterTts()),
        );
        await service.registerDetectedRoadEvent(
          kind: RoadEventKind.bump,
          latitude: kLat + 220 * kDegPerMeter,
          longitude: kLon,
        );
        service.setActiveTripId(7);

        await service.start();
        await service.handleLocationFix(_fix(speedKmh: 90));

        final alert = await service.findMostRecentPreAlert(
          within: const Duration(minutes: 5),
        );
        expect(alert, isNotNull);

        await service.linkEventToPreAlert(123);

        final updated = await db.select(db.preAlerts).getSingle();
        expect(updated.eventId, 123);
      },
    );

    test(
      'findMostRecentPreAlert returns null when nothing was spoken',
      () async {
        final alert = await service.findMostRecentPreAlert(
          within: const Duration(minutes: 5),
        );
        expect(alert, isNull);
      },
    );
  });
}
