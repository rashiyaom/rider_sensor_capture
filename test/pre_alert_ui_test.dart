import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/core/theme/app_theme.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/features/feedback/presentation/feedback_sheet.dart';
import 'package:ride_sensor_capture/features/prealert/presentation/pre_alert_banner.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_engine.dart';
import 'package:ride_sensor_capture/providers/db_providers.dart';

const double kLat = 12.9716;
const double kLon = 77.5946;

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

PreAlertDecision _decision({
  RoadEventKind kind = RoadEventKind.bump,
  PreAlertUrgency urgency = PreAlertUrgency.warning,
  double distanceMeters = 400,
  double timeToEventSeconds = 16,
}) {
  return PreAlertDecision(
    candidate: RoadEventCandidate(
      id: 1,
      kind: kind,
      latitude: kLat,
      longitude: kLon,
      severity: 0.5,
      confidence: 0.9,
      detectedAtUtc: DateTime.utc(2026, 10, 20, 10),
    ),
    distanceMeters: distanceMeters,
    bearingDeg: 0,
    relativeBearingDeg: 0,
    speedKmh: 90,
    timeToEventSeconds: timeToEventSeconds,
    recommendedSpeedKmh: 40,
    urgency: urgency,
    window: PreAlertWindow.inWindow,
    shouldSpeak: true,
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = _makeTestDb();
  });

  tearDown(() async {
    await db.close();
  });

  group('PreAlertBanner', () {
    testWidgets('shows the hazard, distance, time-to-event and advice',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: PreAlertBanner(decision: _decision()),
          ),
        ),
      );

      expect(find.text('SPEED BUMP AHEAD'), findsOneWidget);
      expect(find.textContaining('400 m'), findsOneWidget);
      expect(find.textContaining('16 s'), findsOneWidget);
      expect(find.textContaining('slow to 40'), findsOneWidget);
    });

    testWidgets('uses the pothole wording for potholes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: PreAlertBanner(
              decision: _decision(kind: RoadEventKind.pothole),
            ),
          ),
        ),
      );

      expect(find.text('POTHOLE AHEAD'), findsOneWidget);
    });

    testWidgets('renders without throwing for every urgency', (tester) async {
      for (final urgency in PreAlertUrgency.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              body: PreAlertBanner(decision: _decision(urgency: urgency)),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('FeedbackSheet', () {
    testWidgets('asks the contextual question and offers quick replies',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => FeedbackSheet.show(
                    context,
                    eventId: 1,
                    eventType: 'bump',
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('How smooth was the bump?'), findsOneWidget);
      expect(find.text('Smooth'), findsOneWidget);
      expect(find.text('Speak'), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('a quick reply stores the feedback and closes the sheet',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => FeedbackSheet.show(
                    context,
                    eventId: 42,
                    eventType: 'bump',
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Very rough'));
      await tester.pumpAndSettle();

      final feedback = await db.select(db.eventFeedbacks).get();
      expect(feedback, hasLength(1));
      expect(feedback.first.eventId, 42);
      expect(feedback.first.responseText, 'Very rough');
      expect(feedback.first.responseSource, 'text');
      expect(feedback.first.alertEffectiveness, isNotNull);
    });

    testWidgets('skipping records a skipped response', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => FeedbackSheet.show(
                    context,
                    eventId: 7,
                    eventType: 'turn',
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      final feedback = await db.select(db.eventFeedbacks).get();
      expect(feedback, hasLength(1));
      expect(feedback.first.responseSource, 'skipped');
      expect(feedback.first.eventId, 7);
    });
  });
}
