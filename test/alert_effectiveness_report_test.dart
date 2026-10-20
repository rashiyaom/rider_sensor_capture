import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/report/alert_effectiveness_report.dart';

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

Future<int> _insertAlert(
  AppDatabase db, {
  required int? roadEventId,
  required int? eventId,
  required String eventType,
  required double distanceMeters,
  required double speedKmh,
  required double timeToEventSeconds,
  required double recommendedSpeedKmh,
  required String urgency,
  DateTime? at,
}) {
  return db.into(db.preAlerts).insert(
        PreAlertsCompanion.insert(
          roadEventId: drift.Value(roadEventId),
          tripId: const drift.Value(1),
          eventId: drift.Value(eventId),
          eventType: eventType,
          latitude: 12.9716,
          longitude: 77.5946,
          distanceMeters: distanceMeters,
          speedKmh: speedKmh,
          timeToEventSeconds: timeToEventSeconds,
          recommendedSpeedKmh: recommendedSpeedKmh,
          urgency: urgency,
          spokenText: 'Speed bump ahead, 400 metres, 16 seconds.',
          alertedAtUtc: at ?? DateTime.utc(2026, 10, 20, 10, 0, 0),
        ),
      );
}

Future<int> _insertFeedback(
  AppDatabase db, {
  required int? eventId,
  required int? preAlertId,
  required String eventType,
  required String responseText,
  required double effectiveness,
  required String timing,
  required String difficulty,
  bool analyzedByLlm = true,
}) {
  return db.into(db.eventFeedbacks).insert(
        EventFeedbacksCompanion.insert(
          eventId: drift.Value(eventId),
          tripId: const drift.Value(1),
          preAlertId: drift.Value(preAlertId),
          eventType: eventType,
          prompt: 'How smooth was the bump?',
          responseText: responseText,
          responseSource: 'voice',
          alertEffectiveness: drift.Value(effectiveness),
          alertTimingAdequacy: drift.Value(timing),
          difficultyLevel: drift.Value(difficulty),
          riderSummary: const drift.Value('Rider handled it well.'),
          improvementSuggestion:
              const drift.Value('Keep the current warning window.'),
          analysisConfidence: const drift.Value(0.9),
          analyzedByLlm: drift.Value(analyzedByLlm),
          createdAtUtc: DateTime.utc(2026, 10, 20, 10, 0, 5),
          analyzedAtUtc: drift.Value(DateTime.utc(2026, 10, 20, 10, 0, 6)),
        ),
      );
}

void main() {
  late AppDatabase db;
  late AlertEffectivenessReportBuilder builder;

  setUp(() {
    db = _makeTestDb();
    builder = AlertEffectivenessReportBuilder(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AlertEffectivenessReportBuilder', () {
    test('produces an empty report when nothing happened', () async {
      final report = await builder.build();
      expect(report.isEmpty, isTrue);
      expect(report.totalAlerts, 0);
      expect(report.entries, isEmpty);
      expect(report.insights, hasLength(1));
      expect(report.insights.first, contains('No predictive pre-alerts'));
    });

    test('aggregates alerts and their rider feedback', () async {
      final alertId = await _insertAlert(
        db,
        roadEventId: 1,
        eventId: 10,
        eventType: 'bump',
        distanceMeters: 400,
        speedKmh: 90,
        timeToEventSeconds: 16,
        recommendedSpeedKmh: 40,
        urgency: 'warning',
      );
      await _insertFeedback(
        db,
        eventId: 10,
        preAlertId: alertId,
        eventType: 'bump',
        responseText: 'The warning was perfect, I had enough time.',
        effectiveness: 0.9,
        timing: 'adequate',
        difficulty: 'mild',
      );

      final report = await builder.build();
      expect(report.totalAlerts, 1);
      expect(report.totalFeedback, 1);
      expect(report.alertsWithFeedback, 1);
      expect(report.analyzedByLlm, 1);
      expect(report.averageEffectiveness, closeTo(0.9, 0.001));
      expect(report.averageTimeToEventSeconds, closeTo(16.0, 0.001));
      expect(report.averageDistanceMeters, closeTo(400.0, 0.001));
      expect(report.timingBreakdown['adequate'], 1);
      expect(report.eventTypeBreakdown['bump'], 1);
      expect(report.effectivenessByEventType['bump'], closeTo(0.9, 0.001));
    });

    test('matches feedback to an alert through the preAlertId', () async {
      final alertId = await _insertAlert(
        db,
        roadEventId: null,
        eventId: null,
        eventType: 'turn',
        distanceMeters: 120,
        speedKmh: 60,
        timeToEventSeconds: 7.2,
        recommendedSpeedKmh: 35,
        urgency: 'warning',
      );
      await _insertFeedback(
        db,
        eventId: null,
        preAlertId: alertId,
        eventType: 'turn',
        responseText: 'It was too late.',
        effectiveness: 0.3,
        timing: 'too_late',
        difficulty: 'moderate',
      );

      final report = await builder.build();
      expect(report.entries.single.effectiveness, closeTo(0.3, 0.001));
      expect(report.entries.single.timingAdequacy, 'too_late');
      expect(report.entries.single.responseText, 'It was too late.');
    });

    test('compiles insights that mention the timing breakdown', () async {
      for (var i = 0; i < 2; i++) {
        final alertId = await _insertAlert(
          db,
          roadEventId: i,
          eventId: null,
          eventType: 'bump',
          distanceMeters: 300,
          speedKmh: 80,
          timeToEventSeconds: 13,
          recommendedSpeedKmh: 40,
          urgency: 'warning',
          at: DateTime.utc(2026, 10, 20, 10, i),
        );
        await _insertFeedback(
          db,
          eventId: null,
          preAlertId: alertId,
          eventType: 'bump',
          responseText: 'Too late.',
          effectiveness: 0.2,
          timing: 'too_late',
          difficulty: 'severe',
        );
      }

      final report = await builder.build();
      expect(report.totalAlerts, 2);
      expect(report.timingBreakdown['too_late'], 2);
      expect(report.insights.join(' '), contains('too late'));
      expect(report.insights.join(' '), contains('bump events scored lowest'));
    });

    test('filters by trip', () async {
      await _insertAlert(
        db,
        roadEventId: 1,
        eventId: null,
        eventType: 'bump',
        distanceMeters: 300,
        speedKmh: 80,
        timeToEventSeconds: 13,
        recommendedSpeedKmh: 40,
        urgency: 'warning',
      );
      final report = await builder.build(tripId: 999);
      expect(report.totalAlerts, 0);
    });
  });

  group('AlertEffectivenessReport rendering', () {
    test('renders a Markdown report with the key metrics', () async {
      final alertId = await _insertAlert(
        db,
        roadEventId: 1,
        eventId: 10,
        eventType: 'bump',
        distanceMeters: 400,
        speedKmh: 90,
        timeToEventSeconds: 16,
        recommendedSpeedKmh: 40,
        urgency: 'warning',
      );
      await _insertFeedback(
        db,
        eventId: 10,
        preAlertId: alertId,
        eventType: 'bump',
        responseText: 'Smooth enough',
        effectiveness: 0.85,
        timing: 'adequate',
        difficulty: 'mild',
      );

      final report = await builder.build();
      final markdown = report.toMarkdown();

      expect(markdown, contains('# Predictive Pre-Alert Effectiveness Report'));
      expect(markdown, contains('Pre-alerts issued | 1'));
      expect(markdown, contains('## Warning Timing'));
      expect(markdown, contains('## Alerts by Event Type'));
      expect(markdown, contains('## Insights'));
      expect(markdown, contains('## Per-Alert Detail'));
    });

    test('serialises to JSON for the dataset export', () async {
      final report = await builder.build();
      final json = report.toJson();
      expect(json['total_alerts'], 0);
      expect(json['insights'], isA<List>());
      expect(json['entries'], isA<List>());
    });
  });
}
