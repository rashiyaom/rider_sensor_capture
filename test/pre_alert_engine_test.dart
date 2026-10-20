import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_engine.dart';

/// Reference point used by the tests (Bengaluru).
const double kLat = 12.9716;
const double kLon = 77.5946;

RoadEventCandidate _candidate({
  int? id = 1,
  RoadEventKind kind = RoadEventKind.bump,
  double distanceMeters = 400,
  double severity = 0.5,
  double confidence = 0.9,
}) {
  // Offset due north by the requested distance.
  const degPerMeter = 1.0 / 111195.0;
  return RoadEventCandidate(
    id: id,
    kind: kind,
    latitude: kLat + distanceMeters * degPerMeter,
    longitude: kLon,
    severity: severity,
    confidence: confidence,
    detectedAtUtc: DateTime.utc(2026, 10, 20, 10),
  );
}

void main() {
  group('PreAlertEngine — time-to-event calculation', () {
    const engine = PreAlertEngine();

    test('computes ~16 s to an event 400 m ahead at 90 km/h', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 400)],
      );

      expect(decision, isNotNull);
      // 400 m / 25 m/s = 16 s
      expect(decision!.timeToEventSeconds, closeTo(16.0, 0.3));
      expect(decision.distanceMeters, closeTo(400.0, 5.0));
    });

    test('time-to-event scales linearly with distance', () {
      final near = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 200)],
      );
      final far = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 400)],
      );
      expect(near!.timeToEventSeconds, closeTo(8.0, 0.3));
      expect(far!.timeToEventSeconds, closeTo(16.0, 0.3));
    });

    test('time-to-event scales inversely with speed', () {
      final slow = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 45,
        candidates: [_candidate(distanceMeters: 400)],
      );
      expect(slow!.timeToEventSeconds, closeTo(32.0, 0.5));
    });
  });

  group('PreAlertEngine — warning window', () {
    const engine = PreAlertEngine();

    test('an event inside the window is worth speaking', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 400)],
      );
      expect(decision!.window, PreAlertWindow.inWindow);
      expect(decision.shouldSpeak, isTrue);
    });

    test('a very distant event is too early to warn about', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 780)],
      );
      // 780 m / 25 m/s = 31 s > 20 s max warning window
      expect(decision!.window, PreAlertWindow.tooEarly);
      expect(decision.shouldSpeak, isFalse);
    });

    test('an imminent event is classified as too late to pre-warn', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 25)],
      );
      // 25 m / 25 m/s = 1 s < 2 s minimum
      expect(decision!.window, PreAlertWindow.tooLate);
      expect(decision.shouldSpeak, isFalse);
    });

    test('urgency escalates as the event approaches', () {
      final advisory = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 450)],
      );
      final warning = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 180)],
      );
      final imminent = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 70)],
      );

      expect(advisory!.urgency, PreAlertUrgency.advisory);
      expect(warning!.urgency, PreAlertUrgency.warning);
      expect(imminent!.urgency, PreAlertUrgency.imminent);
    });
  });

  group('PreAlertEngine — filtering', () {
    const engine = PreAlertEngine();

    test('returns null when the rider is nearly stopped', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 3,
        candidates: [_candidate()],
      );
      expect(decision, isNull);
    });

    test('returns null when there are no candidates', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 60,
        candidates: const [],
      );
      expect(decision, isNull);
    });

    test('ignores hazards that were already alerted', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(id: 7)],
        alreadyAlertedIds: const {7},
      );
      expect(decision, isNull);
    });

    test('ignores hazards outside the consideration radius', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 2000)],
      );
      expect(decision, isNull);
    });

    test('ignores hazards behind the rider when a heading is known', () {
      // Hazard is due north, rider is heading due south.
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 200)],
        headingDeg: 180,
      );
      expect(decision, isNull);
    });

    test('keeps hazards ahead when a heading is known', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 200)],
        headingDeg: 0,
      );
      expect(decision, isNotNull);
      expect(decision!.isAhead, isTrue);
    });

    test('picks the nearest of several hazards', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [
          _candidate(id: 1, distanceMeters: 600),
          _candidate(id: 2, distanceMeters: 150),
          _candidate(id: 3, distanceMeters: 350),
        ],
      );
      expect(decision!.candidate.id, 2);
    });
  });

  group('PreAlertEngine — recommended speed', () {
    const engine = PreAlertEngine();

    test('recommends the pass speed when there is enough runway', () {
      // 400 m of runway at 90 km/h is plenty to slow to the pass speed.
      final recommended = engine.recommendedSpeedKmh(
        distanceMeters: 400,
        currentSpeedKmh: 90,
        severity: 0.5,
      );
      expect(recommended, closeTo(40.0, 0.5));
    });

    test('recommends a slower pass speed for a more severe hazard', () {
      final mild = engine.recommendedSpeedKmh(
        distanceMeters: 400,
        currentSpeedKmh: 90,
        severity: 0.1,
      );
      final severe = engine.recommendedSpeedKmh(
        distanceMeters: 400,
        currentSpeedKmh: 90,
        severity: 1.0,
      );
      expect(severe, lessThan(mild));
      expect(severe, closeTo(25.0, 0.5));
    });

    test('never recommends a speed above the current speed', () {
      final recommended = engine.recommendedSpeedKmh(
        distanceMeters: 800,
        currentSpeedKmh: 40,
        severity: 0.0,
      );
      expect(recommended, lessThanOrEqualTo(40.0));
    });

    test('with too little runway it recommends the maximum achievable speed', () {
      final recommended = engine.recommendedSpeedKmh(
        distanceMeters: 20,
        currentSpeedKmh: 90,
        severity: 1.0,
      );
      // Cannot reach the 25 km/h pass speed from 90 km/h in 20 m, but the
      // advice must still be a reduction.
      expect(recommended, lessThan(90.0));
      expect(recommended, greaterThan(25.0));
    });

    test('pass speed interpolates linearly with severity', () {
      expect(engine.passSpeedKmh(severity: 0.0), closeTo(55.0, 0.001));
      expect(engine.passSpeedKmh(severity: 1.0), closeTo(25.0, 0.001));
      expect(engine.passSpeedKmh(severity: 0.5), closeTo(40.0, 0.001));
    });
  });

  group('PreAlertMessageBuilder', () {
    const engine = PreAlertEngine();

    test('composes a spoken warning with distance, time and advice', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 400, severity: 0.5)],
      )!;
      final message = PreAlertMessageBuilder.build(decision);

      expect(message, contains('Speed bump ahead'));
      expect(message, contains('400'));
      expect(message, contains('16 seconds'));
      expect(message, contains('Reduce to 40'));
    });

    test('uses the correct wording for a pothole', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 60,
        candidates: [
          _candidate(kind: RoadEventKind.pothole, distanceMeters: 100),
        ],
      )!;
      final message = PreAlertMessageBuilder.build(decision);
      expect(message, contains('Pothole ahead'));
    });

    test('rounds long distances to a human-friendly value', () {
      final decision = engine.evaluate(
        latitude: kLat,
        longitude: kLon,
        speedKmh: 90,
        candidates: [_candidate(distanceMeters: 430)],
      )!;
      final message = PreAlertMessageBuilder.build(decision);
      expect(message, contains('400'));
    });
  });

  group('RoadEventKind', () {
    test('maps raw event type strings onto canonical kinds', () {
      expect(RoadEventKind.fromString('bump'), RoadEventKind.bump);
      expect(RoadEventKind.fromString('speedBump'), RoadEventKind.bump);
      expect(RoadEventKind.fromString('pothole'), RoadEventKind.pothole);
      expect(RoadEventKind.fromString('sharpTurn'), RoadEventKind.turn);
      expect(RoadEventKind.fromString('HARD_BRAKE'), RoadEventKind.braking);
      expect(RoadEventKind.fromString('speedTest'), RoadEventKind.braking);
      expect(RoadEventKind.fromString('somethingElse'), RoadEventKind.unknown);
      expect(RoadEventKind.fromString(null), RoadEventKind.unknown);
    });
  });
}
