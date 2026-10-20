import 'package:drift/drift.dart';

/// Rider feedback captured after a road event has been completed.
///
/// The `responseText` is the raw (voice-transcribed or typed) answer from the
/// rider, while `llmAnalysis` holds the structured JSON produced by the LLM
/// evaluator (Groq) that scores how effective the pre-alert actually was.
class EventFeedbacks extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The labeled event this feedback belongs to.
  IntColumn get eventId => integer().nullable()();

  IntColumn get tripId => integer().nullable()();

  /// The geo-tagged hazard the rider was reacting to.
  IntColumn get roadEventId => integer().nullable()();

  /// The pre-alert that was spoken before the event, if any.
  IntColumn get preAlertId => integer().nullable()();

  TextColumn get eventType => text()();

  /// The question that was asked of the rider.
  TextColumn get prompt => text()();

  /// The rider's answer (transcribed speech or typed text).
  TextColumn get responseText => text()();

  /// voice | text | skipped
  TextColumn get responseSource => text()();

  /// Speech-to-text confidence (0..1) when the answer was spoken.
  RealColumn get transcriptConfidence => real().nullable()();

  /// Full JSON payload of the LLM analysis.
  TextColumn get llmAnalysis => text().nullable()();

  /// LLM-scored effectiveness of the pre-alert (0..1).
  RealColumn get alertEffectiveness => real().nullable()();

  /// too_early | adequate | too_late | unknown
  TextColumn get alertTimingAdequacy => text().nullable()();

  /// none | mild | moderate | severe | unknown
  TextColumn get difficultyLevel => text().nullable()();

  /// One-line natural-language summary of the rider's experience.
  TextColumn get riderSummary => text().nullable()();

  /// Actionable recommendation for improving alert timing / accuracy.
  TextColumn get improvementSuggestion => text().nullable()();

  RealColumn get analysisConfidence => real().nullable()();

  /// False when the heuristic (offline) analyzer was used instead of the LLM.
  BoolColumn get analyzedByLlm => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get analyzedAtUtc => dateTime().nullable()();
}
