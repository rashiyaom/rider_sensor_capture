import 'dart:async';

import 'package:drift/drift.dart';

import '../data/local_db/database.dart';
import '../data/models/event_parameters.dart';
import '../llm/feedback_analyzer.dart';
import '../prealert/pre_alert_engine.dart';
import 'feedback_transcriber.dart';

/// The question shown to the rider after an event has completed.
class FeedbackPrompt {
  final String eventType;
  final String question;

  /// Tappable one-word answers shown alongside the free-text field.
  final List<String> quickReplies;

  const FeedbackPrompt({
    required this.eventType,
    required this.question,
    this.quickReplies = const [],
  });
}

/// Runs the post-event feedback & learning loop.
///
/// Flow:
/// 1. An event completes → [buildPrompt] produces a contextual question.
/// 2. The rider answers by voice (transcribed by [FeedbackTranscriber]) or by
///    typing.
/// 3. The answer is stored, then scored by the LLM evaluator
///    ([FeedbackAnalyzer]) which judges how effective the pre-alert was.
/// 4. The analysis is compiled into the final export report.
class FeedbackService {
  final AppDatabase db;
  final FeedbackAnalyzer analyzer;
  final FeedbackTranscriber? transcriber;

  FeedbackService({
    required this.db,
    this.analyzer = const FeedbackAnalyzer(),
    this.transcriber,
  });

  /// True when an LLM (Groq) is reachable for analysis.
  bool get isLlmAvailable => analyzer.isLlmAvailable;

  /// Builds the contextual feedback question for a completed event.
  static FeedbackPrompt buildPrompt({
    required String eventType,
    EventParameters? parameters,
  }) {
    final kind = RoadEventKind.fromString(eventType);

    switch (kind) {
      case RoadEventKind.bump:
        return const FeedbackPrompt(
          eventType: 'bump',
          question: 'How smooth was the bump?',
          quickReplies: ['Smooth', 'Rough', 'Very rough', 'Nearly lost control'],
        );
      case RoadEventKind.pothole:
        return const FeedbackPrompt(
          eventType: 'pothole',
          question: 'How smooth was the pothole?',
          quickReplies: ['Smooth', 'Rough', 'Very rough', 'Nearly lost control'],
        );
      case RoadEventKind.turn:
        return const FeedbackPrompt(
          eventType: 'turn',
          question: 'Did you face any difficulty navigating that turn?',
          quickReplies: ['Easy', 'Tight', 'Difficult', 'Too fast'],
        );
      case RoadEventKind.braking:
        return const FeedbackPrompt(
          eventType: 'braking',
          question: 'Did you face any difficulty navigating that event?',
          quickReplies: ['Early', 'On time', 'Late', 'Sudden'],
        );
      case RoadEventKind.hazard:
        return const FeedbackPrompt(
          eventType: 'hazard',
          question: 'Did you face any difficulty navigating that event?',
          quickReplies: ['Easy', 'Tight', 'Difficult', 'Too fast'],
        );
      case RoadEventKind.unknown:
        return const FeedbackPrompt(
          eventType: 'unknown',
          question: 'Did you face any difficulty navigating that event?',
          quickReplies: ['Easy', 'Tight', 'Difficult', 'Too fast'],
        );
    }
  }

  /// Stores a typed (or quick-reply) answer and analyses it.
  Future<EventFeedback> recordTextFeedback({
    required int eventId,
    required String eventType,
    required String prompt,
    required String responseText,
    String responseSource = 'text',
    int? tripId,
    int? roadEventId,
    int? preAlertId,
    double? timeToEventSeconds,
    double? distanceMeters,
    double? speedKmh,
    double? recommendedSpeedKmh,
    double? severity,
    double? peakGForce,
  }) async {
    final id = await db.into(db.eventFeedbacks).insert(
          EventFeedbacksCompanion.insert(
            eventId: Value(eventId),
            tripId: Value(tripId),
            roadEventId: Value(roadEventId),
            preAlertId: Value(preAlertId),
            eventType: eventType,
            prompt: prompt,
            responseText: responseText,
            responseSource: responseSource,
            createdAtUtc: DateTime.now().toUtc(),
          ),
        );

    await _analyze(
      feedbackId: id,
      eventType: eventType,
      prompt: prompt,
      responseText: responseText,
      timeToEventSeconds: timeToEventSeconds,
      distanceMeters: distanceMeters,
      speedKmh: speedKmh,
      recommendedSpeedKmh: recommendedSpeedKmh,
      severity: severity,
      peakGForce: peakGForce,
    );

    return _getById(id);
  }

  /// Records a spoken answer: transcribes it first, then stores and analyses.
  ///
  /// Returns null when the speech recogniser produced nothing intelligible.
  Future<EventFeedback?> recordVoiceFeedback({
    required int eventId,
    required String eventType,
    required String prompt,
    int? tripId,
    int? roadEventId,
    int? preAlertId,
    double? timeToEventSeconds,
    double? distanceMeters,
    double? speedKmh,
    double? recommendedSpeedKmh,
    double? severity,
    double? peakGForce,
  }) async {
    final voiceTranscriber = transcriber;
    if (voiceTranscriber == null) return null;

    final transcript = await voiceTranscriber.listenOnce();
    if (transcript == null || transcript.trim().isEmpty) return null;

    final id = await db.into(db.eventFeedbacks).insert(
          EventFeedbacksCompanion.insert(
            eventId: Value(eventId),
            tripId: Value(tripId),
            roadEventId: Value(roadEventId),
            preAlertId: Value(preAlertId),
            eventType: eventType,
            prompt: prompt,
            responseText: transcript.trim(),
            responseSource: 'voice',
            createdAtUtc: DateTime.now().toUtc(),
          ),
        );

    await _analyze(
      feedbackId: id,
      eventType: eventType,
      prompt: prompt,
      responseText: transcript.trim(),
      timeToEventSeconds: timeToEventSeconds,
      distanceMeters: distanceMeters,
      speedKmh: speedKmh,
      recommendedSpeedKmh: recommendedSpeedKmh,
      severity: severity,
      peakGForce: peakGForce,
    );

    return _getById(id);
  }

  /// Records that the rider declined to give feedback.
  Future<int> recordSkipped({
    required int eventId,
    required String eventType,
    required String prompt,
    int? tripId,
    int? roadEventId,
    int? preAlertId,
  }) async {
    return db.into(db.eventFeedbacks).insert(
          EventFeedbacksCompanion.insert(
            eventId: Value(eventId),
            tripId: Value(tripId),
            roadEventId: Value(roadEventId),
            preAlertId: Value(preAlertId),
            eventType: eventType,
            prompt: prompt,
            responseText: '',
            responseSource: 'skipped',
            createdAtUtc: DateTime.now().toUtc(),
          ),
        );
  }

  /// Runs the LLM (or heuristic) analysis and writes the result back.
  Future<void> _analyze({
    required int feedbackId,
    required String eventType,
    required String prompt,
    required String responseText,
    double? timeToEventSeconds,
    double? distanceMeters,
    double? speedKmh,
    double? recommendedSpeedKmh,
    double? severity,
    double? peakGForce,
  }) async {
    final analysis = await analyzer.analyze(
      FeedbackAnalysisContext(
        eventType: eventType,
        prompt: prompt,
        responseText: responseText,
        timeToEventSeconds: timeToEventSeconds,
        distanceMeters: distanceMeters,
        speedKmh: speedKmh,
        recommendedSpeedKmh: recommendedSpeedKmh,
        severity: severity,
        peakGForce: peakGForce,
      ),
    );

    await (db.update(db.eventFeedbacks)..where((t) => t.id.equals(feedbackId))).write(
      EventFeedbacksCompanion(
        llmAnalysis: Value(analysis.toJsonString()),
        alertEffectiveness: Value(analysis.alertEffectiveness),
        alertTimingAdequacy: Value(analysis.alertTimingAdequacy),
        difficultyLevel: Value(analysis.difficultyLevel),
        riderSummary: Value(analysis.riderSummary),
        improvementSuggestion: Value(analysis.improvementSuggestion),
        analysisConfidence: Value(analysis.confidence),
        analyzedByLlm: Value(analysis.analyzedByLlm),
        analyzedAtUtc: Value(DateTime.now().toUtc()),
      ),
    );

    final roadEventId = await _roadEventIdFor(feedbackId);
    if (roadEventId != null) {
      await (db.update(db.roadEvents)..where((t) => t.id.equals(roadEventId))).write(
        const RoadEventsCompanion(feedbackCount: Value(1)),
      );
    }
  }

  Future<int?> _roadEventIdFor(int feedbackId) async {
    final row = await (db.select(db.eventFeedbacks)
          ..where((t) => t.id.equals(feedbackId)))
        .getSingleOrNull();
    return row?.roadEventId;
  }

  Future<EventFeedback> _getById(int id) async {
    return (db.select(db.eventFeedbacks)..where((t) => t.id.equals(id))).getSingle();
  }

  /// All feedback recorded for a given labeled event.
  Future<List<EventFeedback>> feedbackForEvent(int eventId) {
    return (db.select(db.eventFeedbacks)
          ..where((t) => t.eventId.equals(eventId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAtUtc)]))
        .get();
  }

  /// Watch stream of all feedback records.
  Stream<List<EventFeedback>> watchAllFeedback() {
    return (db.select(db.eventFeedbacks)
          ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .watch();
  }

  /// True when the rider has already answered for this event.
  Future<bool> hasFeedbackForEvent(int eventId) async {
    final count = db.eventFeedbacks.id.count();
    final row = await (db.selectOnly(db.eventFeedbacks)
          ..where(db.eventFeedbacks.eventId.equals(eventId))
          ..addColumns([count]))
        .getSingle();
    return (row.read(count) ?? 0) > 0;
  }
}
