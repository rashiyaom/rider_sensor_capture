import 'dart:convert';
import 'dart:math' as math;

import 'groq_client.dart';

/// Structured evaluation of a pre-alert, produced by the LLM evaluator.
class FeedbackAnalysis {
  /// How effective the pre-alert was, 0..1.
  final double alertEffectiveness;

  /// too_early | adequate | too_late | unknown
  final String alertTimingAdequacy;

  /// none | mild | moderate | severe | unknown
  final String difficultyLevel;

  /// One-line natural-language summary of what the rider experienced.
  final String riderSummary;

  /// Actionable recommendation for tuning the warning system.
  final String improvementSuggestion;

  /// Model confidence in the analysis, 0..1.
  final double confidence;

  /// False when the offline heuristic analyzer was used.
  final bool analyzedByLlm;

  /// The raw JSON payload returned by the model (null for heuristic results).
  final Map<String, dynamic>? raw;

  const FeedbackAnalysis({
    required this.alertEffectiveness,
    required this.alertTimingAdequacy,
    required this.difficultyLevel,
    required this.riderSummary,
    required this.improvementSuggestion,
    required this.confidence,
    this.analyzedByLlm = false,
    this.raw,
  });

  Map<String, dynamic> toJson() => {
        'alertEffectiveness': alertEffectiveness,
        'alertTimingAdequacy': alertTimingAdequacy,
        'difficultyLevel': difficultyLevel,
        'riderSummary': riderSummary,
        'improvementSuggestion': improvementSuggestion,
        'confidence': confidence,
        'analyzedByLlm': analyzedByLlm,
        if (raw != null) 'raw': raw,
      };

  String toJsonString() => jsonEncode(toJson());

  static FeedbackAnalysis fromJson(Map<String, dynamic> json) {
    return FeedbackAnalysis(
      alertEffectiveness: FeedbackAnalyzer._clamp01(json['alertEffectiveness'], 0.5),
      alertTimingAdequacy: _normalizeTiming(json['alertTimingAdequacy']),
      difficultyLevel: _normalizeDifficulty(json['difficultyLevel']),
      riderSummary: json['riderSummary']?.toString() ?? '',
      improvementSuggestion: json['improvementSuggestion']?.toString() ?? '',
      confidence: FeedbackAnalyzer._clamp01(json['confidence'], 0.5),
      analyzedByLlm: json['analyzedByLlm'] as bool? ?? false,
      raw: json['raw'] is Map
          ? Map<String, dynamic>.from(json['raw'] as Map)
          : null,
    );
  }

  static String _normalizeTiming(Object? value) {
    final v = value?.toString().toLowerCase().trim() ?? '';
    if (v.contains('too_early') || v.contains('too early') || v.contains('early')) {
      return 'too_early';
    }
    if (v.contains('too_late') || v.contains('too late') || v.contains('late')) {
      return 'too_late';
    }
    if (v.contains('adequate') || v.contains('right') || v.contains('perfect') ||
        v.contains('good') || v.contains('ok')) {
      return 'adequate';
    }
    return 'unknown';
  }

  static String _normalizeDifficulty(Object? value) {
    final v = value?.toString().toLowerCase().trim() ?? '';
    if (v.contains('severe') || v.contains('very hard') || v.contains('danger')) {
      return 'severe';
    }
    if (v.contains('moderate') || v.contains('hard') || v.contains('difficult')) {
      return 'moderate';
    }
    if (v.contains('mild') || v.contains('slight') || v.contains('a bit')) {
      return 'mild';
    }
    if (v.contains('none') || v.contains('no ') || v.contains('easy') ||
        v.contains('smooth') || v.contains('fine')) {
      return 'none';
    }
    return 'unknown';
  }
}

/// The context handed to the LLM when evaluating a rider's feedback.
class FeedbackAnalysisContext {
  final String eventType;
  final String prompt;
  final String responseText;
  final double? timeToEventSeconds;
  final double? distanceMeters;
  final double? speedKmh;
  final double? recommendedSpeedKmh;
  final double? severity;
  final double? peakGForce;

  const FeedbackAnalysisContext({
    required this.eventType,
    required this.prompt,
    required this.responseText,
    this.timeToEventSeconds,
    this.distanceMeters,
    this.speedKmh,
    this.recommendedSpeedKmh,
    this.severity,
    this.peakGForce,
  });
}

/// Evaluates rider feedback to determine how well the pre-alert system
/// performed.
///
/// Groq is the only LLM backend used. When no API key is configured — or the
/// API call fails — the analyzer degrades gracefully to a deterministic
/// keyword heuristic so the app keeps working fully offline.
class FeedbackAnalyzer {
  /// The Groq client used for LLM evaluation (null disables LLM analysis).
  final GroqClient? client;

  const FeedbackAnalyzer({this.client});

  /// True when an LLM is reachable (i.e. a Groq API key is configured).
  bool get isLlmAvailable => client?.config.isConfigured ?? false;

  static const String _systemPrompt = '''
You are the evaluation engine for a motorcycle predictive pre-alert system.
The app warns a rider about an upcoming road event (bump, pothole, sharp turn,
braking zone) using a spoken voice warning computed from GPS distance and speed.

You receive:
- the event type,
- the telemetry of the warning that was spoken (distance, speed, time-to-event,
  recommended speed, severity),
- the rider's free-text answer to a follow-up question.

Your job is to judge how EFFECTIVE the warning was, from the rider's point of view.

Return STRICT JSON only, with exactly these keys:
{
  "alertEffectiveness": <number 0.0-1.0>,
  "alertTimingAdequacy": "too_early" | "adequate" | "too_late" | "unknown",
  "difficultyLevel": "none" | "mild" | "moderate" | "severe" | "unknown",
  "riderSummary": "<one sentence, max 25 words, describing the rider's experience>",
  "improvementSuggestion": "<one concrete sentence on how to tune warning distance/timing>",
  "confidence": <number 0.0-1.0>
}

Guidance:
- If the rider says the warning came too late, set alertTimingAdequacy to "too_late"
  and lower alertEffectiveness (typically 0.1-0.4).
- If the rider says it was early but fine, use "too_early" (effectiveness 0.5-0.8).
- If the rider says the timing was right, use "adequate" (effectiveness 0.7-1.0).
- Difficulty reflects how hard the event was to ride, NOT how good the warning was.
- Never output markdown fences, prose, or any key outside the list above.
''';

  /// Runs the analysis, falling back to the heuristic when needed.
  Future<FeedbackAnalysis> analyze(FeedbackAnalysisContext context) async {
    final groq = client;
    if (groq == null || !groq.config.isConfigured) {
      return heuristicAnalysis(context);
    }

    try {
      final payload = await groq.chatJson(
        messages: [
          const GroqMessage.system(_systemPrompt),
          GroqMessage.user(_buildUserPrompt(context)),
        ],
        temperature: 0.1,
        maxTokens: 600,
      );

      return FeedbackAnalysis(
        alertEffectiveness: _clamp01(payload['alertEffectiveness'], 0.5),
        alertTimingAdequacy:
            FeedbackAnalysis._normalizeTiming(payload['alertTimingAdequacy']),
        difficultyLevel:
            FeedbackAnalysis._normalizeDifficulty(payload['difficultyLevel']),
        riderSummary: payload['riderSummary']?.toString() ?? '',
        improvementSuggestion: payload['improvementSuggestion']?.toString() ?? '',
        confidence: _clamp01(payload['confidence'], 0.6),
        analyzedByLlm: true,
        raw: payload,
      );
    } catch (_) {
      // Any network / parsing problem falls back to the offline heuristic.
      return heuristicAnalysis(context);
    }
  }

  String _buildUserPrompt(FeedbackAnalysisContext c) {
    final buffer = StringBuffer();
    buffer.writeln('Event type: ${c.eventType}');
    if (c.timeToEventSeconds != null) {
      buffer.writeln(
          'Time-to-event when warned: ${c.timeToEventSeconds!.toStringAsFixed(1)} seconds');
    }
    if (c.distanceMeters != null) {
      buffer.writeln(
          'Distance to event when warned: ${c.distanceMeters!.toStringAsFixed(0)} meters');
    }
    if (c.speedKmh != null) {
      buffer.writeln('Speed when warned: ${c.speedKmh!.toStringAsFixed(1)} km/h');
    }
    if (c.recommendedSpeedKmh != null) {
      buffer.writeln(
          'Recommended speed: ${c.recommendedSpeedKmh!.toStringAsFixed(1)} km/h');
    }
    if (c.severity != null) {
      buffer.writeln('Event severity: ${c.severity!.toStringAsFixed(2)}');
    }
    if (c.peakGForce != null) {
      buffer.writeln('Peak g-force: ${c.peakGForce!.toStringAsFixed(2)}');
    }
    buffer.writeln('');
    buffer.writeln('Question asked: "${c.prompt}"');
    buffer.writeln('Rider answer: "${c.responseText}"');
    return buffer.toString();
  }

  /// Deterministic offline analysis based on keyword matching.
  static FeedbackAnalysis heuristicAnalysis(FeedbackAnalysisContext context) {
    final text = context.responseText.toLowerCase();

    var effectiveness = 0.6;
    var timing = 'unknown';
    var difficulty = 'unknown';

    if (text.contains('too late') ||
        text.contains('very late') ||
        text.contains('sudden') ||
        text.contains('last second') ||
        text.contains('no warning') ||
        text.contains('too fast')) {
      timing = 'too_late';
      effectiveness -= 0.3;
    } else if (text.contains('too early') ||
        text.contains('very early') ||
        text.contains('way early') ||
        text.contains('long before')) {
      timing = 'too_early';
      effectiveness -= 0.1;
    } else if (text.contains('perfect') ||
        text.contains('right time') ||
        text.contains('just right') ||
        text.contains('good warning') ||
        text.contains('enough time') ||
        text.contains('in time')) {
      timing = 'adequate';
      effectiveness += 0.3;
    }

    if (text.contains('very difficult') ||
        text.contains('dangerous') ||
        text.contains('scary') ||
        text.contains('almost crashed') ||
        text.contains('lost control') ||
        text.contains('very hard') ||
        text.contains('very rough') ||
        text.contains('terrifying') ||
        text.contains('frightening') ||
        text.contains('horrible') ||
        text.contains('awful')) {
      difficulty = 'severe';
    } else if (text.contains('difficult') ||
        text.contains('hard') ||
        text.contains('uncomfortable') ||
        text.contains('worrying') ||
        text.contains('rough') ||
        text.contains('shaky') ||
        text.contains('unstable')) {
      difficulty = 'moderate';
    } else if (text.contains('a bit') ||
        text.contains('slightly') ||
        text.contains('slight') ||
        text.contains('mild')) {
      difficulty = 'mild';
    } else if (text.contains('smooth') ||
        text.contains('easy') ||
        text.contains('fine') ||
        text.contains('no problem') ||
        text.contains('good') ||
        text.contains('perfect') ||
        text.contains('flat')) {
      difficulty = 'none';
    }

    effectiveness = effectiveness.clamp(0.0, 1.0);

    final summary = context.responseText.trim().isEmpty
        ? 'Rider skipped the feedback prompt.'
        : 'Rider reported: ${context.responseText.trim()}';

    final suggestion = switch (timing) {
      'too_late' =>
        'Warn earlier: increase the maximum pre-alert time-to-event window for ${context.eventType} events.',
      'too_early' =>
        'Warn later: reduce the maximum pre-alert time-to-event window for ${context.eventType} events.',
      'adequate' =>
        'Current warning timing for ${context.eventType} events is well calibrated.',
      _ =>
        'Collect more rider feedback on ${context.eventType} events to calibrate warning timing.',
    };

    return FeedbackAnalysis(
      alertEffectiveness: effectiveness,
      alertTimingAdequacy: timing,
      difficultyLevel: difficulty,
      riderSummary: summary,
      improvementSuggestion: suggestion,
      confidence: 0.4,
      analyzedByLlm: false,
    );
  }

  /// Reads a numeric value and clamps it into the 0..1 range.
  static double _clamp01(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 1.0).toDouble();
    }
    return fallback;
  }

  /// Rounds a double for stable JSON output.
  static double round2(double value) => (value * 100).round() / 100;

  /// Clamp helper shared by the analyzer.
  static double clamp01(double value) => math.max(0.0, math.min(1.0, value));
}
