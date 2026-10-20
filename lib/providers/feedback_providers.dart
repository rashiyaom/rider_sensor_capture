import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_db/database.dart';
import '../feedback/feedback_service.dart';
import '../feedback/feedback_transcriber.dart';
import '../llm/feedback_analyzer.dart';
import '../llm/groq_client.dart';
import '../report/alert_effectiveness_report.dart';
import 'db_providers.dart';

/// The Groq LLM client. Configure the API key with:
/// `flutter run --dart-define=GROQ_API_KEY=gsk_...`
final groqClientProvider = Provider<GroqClient>((ref) {
  return GroqClient();
});

/// Evaluates rider feedback (LLM when a Groq key is present, heuristic otherwise).
final feedbackAnalyzerProvider = Provider<FeedbackAnalyzer>((ref) {
  return FeedbackAnalyzer(client: ref.watch(groqClientProvider));
});

/// One-shot speech transcriber used for spoken feedback answers.
final feedbackTranscriberProvider = Provider<FeedbackTranscriber>((ref) {
  final transcriber = FeedbackTranscriber();
  ref.onDispose(transcriber.dispose);
  return transcriber;
});

/// The post-event feedback & learning loop service.
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(
    db: ref.watch(appDatabaseProvider),
    analyzer: ref.watch(feedbackAnalyzerProvider),
    transcriber: ref.watch(feedbackTranscriberProvider),
  );
});

/// All rider feedback records (newest first).
final eventFeedbackStreamProvider = StreamProvider<List<EventFeedback>>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.watchEventFeedbacks();
});

/// Feedback recorded for a specific labeled event.
final feedbackForEventProvider =
    FutureProvider.family<List<EventFeedback>, int>((ref, eventId) {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.getFeedbackForEvent(eventId);
});

/// The compiled learning-loop report used by the export screen.
final alertEffectivenessReportProvider =
    FutureProvider<AlertEffectivenessReport>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final builder = AlertEffectivenessReportBuilder(db);
  return builder.build();
});
