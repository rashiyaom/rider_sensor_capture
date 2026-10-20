import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/feedback/feedback_service.dart';
import 'package:ride_sensor_capture/llm/feedback_analyzer.dart';

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late FeedbackService service;

  setUp(() {
    db = _makeTestDb();
    service = FeedbackService(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('FeedbackService.buildPrompt', () {
    test('asks how smooth the bump was', () {
      final prompt = FeedbackService.buildPrompt(eventType: 'bump');
      expect(prompt.question, 'How smooth was the bump?');
      expect(prompt.quickReplies, contains('Smooth'));
    });

    test('asks about potholes', () {
      final prompt = FeedbackService.buildPrompt(eventType: 'pothole');
      expect(prompt.question, 'How smooth was the pothole?');
    });

    test('asks about difficulty navigating a turn', () {
      final prompt = FeedbackService.buildPrompt(eventType: 'turn');
      expect(prompt.question, 'Did you face any difficulty navigating that turn?');
    });

    test('asks about difficulty for a braking event', () {
      final prompt = FeedbackService.buildPrompt(eventType: 'speedTest');
      expect(prompt.question, 'Did you face any difficulty navigating that event?');
    });

    test('falls back to a generic question for unknown events', () {
      final prompt = FeedbackService.buildPrompt(eventType: 'somethingElse');
      expect(prompt.question, 'Did you face any difficulty navigating that event?');
    });
  });

  group('FeedbackService — capturing feedback', () {
    test('stores a typed answer and analyses it', () async {
      final feedback = await service.recordTextFeedback(
        eventId: 1,
        eventType: 'bump',
        prompt: 'How smooth was the bump?',
        responseText: 'Very rough, I nearly lost control.',
        tripId: 9,
        timeToEventSeconds: 8.0,
        distanceMeters: 220.0,
        speedKmh: 90.0,
        recommendedSpeedKmh: 40.0,
        severity: 0.7,
      );

      expect(feedback.id, greaterThan(0));
      expect(feedback.eventId, 1);
      expect(feedback.responseText, 'Very rough, I nearly lost control.');
      expect(feedback.responseSource, 'text');
      expect(feedback.analyzedByLlm, isFalse);
      expect(feedback.llmAnalysis, isNotNull);
      expect(feedback.alertEffectiveness, isNotNull);
      expect(feedback.difficultyLevel, 'severe');
      expect(feedback.analyzedAtUtc, isNotNull);
    });

    test('records a skipped response', () async {
      final id = await service.recordSkipped(
        eventId: 2,
        eventType: 'bump',
        prompt: 'How smooth was the bump?',
      );
      final row = await db.select(db.eventFeedbacks).getSingle();
      expect(row.id, id);
      expect(row.responseSource, 'skipped');
      expect(row.responseText, isEmpty);
    });

    test('stores an existing voice transcript without listening again', () async {
      final feedback = await service.recordTextFeedback(
        eventId: 3,
        eventType: 'turn',
        prompt: 'Did you face any difficulty navigating that turn?',
        responseText: 'It was easy.',
        responseSource: 'voice',
      );

      expect(feedback.responseText, 'It was easy.');
      expect(feedback.responseSource, 'voice');
    });

    test('detects existing feedback for an event', () async {
      expect(await service.hasFeedbackForEvent(5), isFalse);
      await service.recordTextFeedback(
        eventId: 5,
        eventType: 'turn',
        prompt: 'Did you face any difficulty navigating that turn?',
        responseText: 'Easy',
      );
      expect(await service.hasFeedbackForEvent(5), isTrue);
    });

    test('returns the feedback recorded for an event', () async {
      await service.recordTextFeedback(
        eventId: 6,
        eventType: 'bump',
        prompt: 'How smooth was the bump?',
        responseText: 'Smooth',
      );
      final list = await service.feedbackForEvent(6);
      expect(list, hasLength(1));
      expect(list.first.responseText, 'Smooth');
    });
  });

  group('FeedbackAnalyzer — offline heuristic fallback', () {
    const context = FeedbackAnalysisContext(
      eventType: 'bump',
      prompt: 'How smooth was the bump?',
      responseText: '',
    );

    test('detects a too-late warning', () {
      final analysis = FeedbackAnalyzer.heuristicAnalysis(
        const FeedbackAnalysisContext(
          eventType: 'bump',
          prompt: 'How smooth was the bump?',
          responseText: 'The warning came way too late, it was sudden.',
        ),
      );
      expect(analysis.alertTimingAdequacy, 'too_late');
      expect(analysis.alertEffectiveness, lessThan(0.5));
      expect(analysis.analyzedByLlm, isFalse);
    });

    test('detects a too-early warning', () {
      final analysis = FeedbackAnalyzer.heuristicAnalysis(
        const FeedbackAnalysisContext(
          eventType: 'bump',
          prompt: 'How smooth was the bump?',
          responseText: 'It was way too early, long before the bump.',
        ),
      );
      expect(analysis.alertTimingAdequacy, 'too_early');
    });

    test('detects an adequately timed warning', () {
      final analysis = FeedbackAnalyzer.heuristicAnalysis(
        const FeedbackAnalysisContext(
          eventType: 'bump',
          prompt: 'How smooth was the bump?',
          responseText: 'Perfect timing, I had enough time to slow down.',
        ),
      );
      expect(analysis.alertTimingAdequacy, 'adequate');
      expect(analysis.alertEffectiveness, greaterThan(0.8));
    });

    test('detects difficulty level', () {
      final severe = FeedbackAnalyzer.heuristicAnalysis(
        const FeedbackAnalysisContext(
          eventType: 'turn',
          prompt: 'Did you face any difficulty navigating that turn?',
          responseText: 'That was very difficult and dangerous.',
        ),
      );
      expect(severe.difficultyLevel, 'severe');

      final easy = FeedbackAnalyzer.heuristicAnalysis(
        const FeedbackAnalysisContext(
          eventType: 'turn',
          prompt: 'Did you face any difficulty navigating that turn?',
          responseText: 'No problem, it was smooth and easy.',
        ),
      );
      expect(easy.difficultyLevel, 'none');
    });

    test('always produces a usable improvement suggestion', () {
      final analysis = FeedbackAnalyzer.heuristicAnalysis(context);
      expect(analysis.improvementSuggestion, isNotEmpty);
      expect(analysis.riderSummary, isNotEmpty);
    });

    test('effectiveness is always within 0..1', () {
      final analysis = FeedbackAnalyzer.heuristicAnalysis(
        const FeedbackAnalysisContext(
          eventType: 'bump',
          prompt: 'q',
          responseText: 'too late very difficult',
        ),
      );
      expect(analysis.alertEffectiveness, inInclusiveRange(0.0, 1.0));
    });
  });

  group('FeedbackAnalysis — JSON round-trip', () {
    test('serialises and deserialises without losing data', () {
      const original = FeedbackAnalysis(
        alertEffectiveness: 0.82,
        alertTimingAdequacy: 'adequate',
        difficultyLevel: 'mild',
        riderSummary: 'Rider slowed down comfortably.',
        improvementSuggestion: 'Keep the current window.',
        confidence: 0.9,
        analyzedByLlm: true,
      );

      final restored = FeedbackAnalysis.fromJson(original.toJson());
      expect(restored.alertEffectiveness, closeTo(0.82, 0.001));
      expect(restored.alertTimingAdequacy, 'adequate');
      expect(restored.difficultyLevel, 'mild');
      expect(restored.riderSummary, original.riderSummary);
      expect(restored.improvementSuggestion, original.improvementSuggestion);
      expect(restored.analyzedByLlm, isTrue);
    });

    test('normalises free-form model output', () {
      final restored = FeedbackAnalysis.fromJson(const {
        'alertEffectiveness': 1.7,
        'alertTimingAdequacy': 'The warning was too late',
        'difficultyLevel': 'It was quite difficult',
        'riderSummary': 'x',
        'improvementSuggestion': 'y',
        'confidence': -3,
      });
      expect(restored.alertEffectiveness, 1.0);
      expect(restored.alertTimingAdequacy, 'too_late');
      expect(restored.difficultyLevel, 'moderate');
      expect(restored.confidence, 0.0);
    });
  });
}
