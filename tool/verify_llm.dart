// Verification tool: exercises the real Groq evaluation path end to end.
//
//   dart run tool/verify_llm.dart
//
// Reads GROQ_API_KEY from the environment (or from a local .env file) and
// runs a sample rider feedback through the FeedbackAnalyzer, printing the
// structured result the app would store in the `event_feedbacks` table.

import 'dart:io';

import 'package:ride_sensor_capture/llm/feedback_analyzer.dart';
import 'package:ride_sensor_capture/llm/groq_client.dart';

String? _readKeyFromEnvFile() {
  final file = File('.env');
  if (!file.existsSync()) return null;
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('#') || !trimmed.contains('=')) continue;
    final key = trimmed.split('=').first.trim();
    if (key == 'GROQ_API_KEY') {
      return trimmed.split('=').skip(1).join('=').trim().replaceAll('"', '');
    }
  }
  return null;
}

Future<void> main() async {
  final apiKey = Platform.environment['GROQ_API_KEY'] ?? _readKeyFromEnvFile();

  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('No GROQ_API_KEY found (env var or .env file).');
    exit(2);
  }

  final client = GroqClient(
    config: GroqConfig(apiKey: apiKey, model: GroqConfig.defaultModel),
  );
  final analyzer = FeedbackAnalyzer(client: client);

  stdout.writeln('Model      : ${client.config.model}');
  stdout.writeln('LLM ready  : ${analyzer.isLlmAvailable}');
  stdout.writeln();

  const context = FeedbackAnalysisContext(
    eventType: 'bump',
    prompt: 'How smooth was the bump?',
    responseText:
        'The warning came far too late, I almost hit it hard. It was very rough.',
    timeToEventSeconds: 2.4,
    distanceMeters: 60,
    speedKmh: 88,
    recommendedSpeedKmh: 40,
    severity: 0.8,
  );

  final analysis = await analyzer.analyze(context);

  stdout.writeln('--- Analysis ---');
  stdout.writeln('effectiveness      : ${analysis.alertEffectiveness}');
  stdout.writeln('timing adequacy    : ${analysis.alertTimingAdequacy}');
  stdout.writeln('difficulty         : ${analysis.difficultyLevel}');
  stdout.writeln('rider summary      : ${analysis.riderSummary}');
  stdout.writeln('improvement        : ${analysis.improvementSuggestion}');
  stdout.writeln('confidence         : ${analysis.confidence}');
  stdout.writeln('analyzed by LLM    : ${analysis.analyzedByLlm}');

  if (!analysis.analyzedByLlm) {
    stderr.writeln('\nThe LLM path did not run — the heuristic fallback was used.');
    exit(1);
  }
  stdout.writeln('\n✅ Groq evaluation path verified.');
}
