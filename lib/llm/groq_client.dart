import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

/// Runtime configuration for the Groq LLM backend.
///
/// Groq is the **only** LLM provider used by this application.
class GroqConfig {
  /// GroqCloud OpenAI-compatible base URL.
  static const String defaultBaseUrl = 'https://api.groq.com/openai/v1';

  /// Default production model. Groq retired `llama-3.3-70b-versatile` in
  /// August 2026, so the flagship `openai/gpt-oss-120b` is used instead.
  static const String defaultModel = 'openai/gpt-oss-120b';

  /// Compile-time API key, supplied via:
  /// `flutter run --dart-define=GROQ_API_KEY=gsk_...`
  static const String _envApiKey = String.fromEnvironment('GROQ_API_KEY');

  /// Compile-time model override:
  /// `flutter run --dart-define=GROQ_MODEL=openai/gpt-oss-20b`
  static const String _envModel = String.fromEnvironment('GROQ_MODEL');

  /// Compile-time base URL override (useful for proxies / mock servers).
  static const String _envBaseUrl = String.fromEnvironment('GROQ_BASE_URL');

  final String apiKey;
  final String baseUrl;
  final String model;
  final Duration timeout;

  /// Reasoning models (gpt-oss) emit a separate `reasoning_content` field.
  /// We disable it to keep responses fast and to guarantee that the final
  /// answer lands in `message.content`.
  final bool includeReasoning;

  const GroqConfig({
    required this.apiKey,
    this.baseUrl = defaultBaseUrl,
    this.model = defaultModel,
    this.timeout = const Duration(seconds: 30),
    this.includeReasoning = false,
  });

  /// True when an API key is available and LLM calls can be made.
  bool get isConfigured => apiKey.trim().isNotEmpty;

  /// Builds a config from compile-time `--dart-define` values.
  factory GroqConfig.fromEnvironment() {
    return GroqConfig(
      apiKey: _envApiKey,
      baseUrl: _envBaseUrl.isEmpty ? defaultBaseUrl : _envBaseUrl,
      model: _envModel.isEmpty ? defaultModel : _envModel,
    );
  }
}

/// A single chat message.
class GroqMessage {
  final String role; // system | user | assistant
  final String content;

  const GroqMessage(this.role, this.content);

  const GroqMessage.system(this.content) : role = 'system';
  const GroqMessage.user(this.content) : role = 'user';
  const GroqMessage.assistant(this.content) : role = 'assistant';

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// A successful completion from Groq.
class GroqChatResult {
  final String content;
  final String? model;
  final String? finishReason;
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
  final double durationMs;

  const GroqChatResult({
    required this.content,
    this.model,
    this.finishReason,
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.durationMs = 0,
  });

  @override
  String toString() => 'GroqChatResult(model: $model, chars: ${content.length})';
}

/// Raised when a Groq call fails.
class GroqException implements Exception {
  final String message;
  final int? statusCode;
  final String? rawBody;

  const GroqException(this.message, {this.statusCode, this.rawBody});

  /// True when the failure was caused by a missing / invalid API key.
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// True when Groq rate-limited the request.
  bool get isRateLimited => statusCode == 429;

  @override
  String toString() => 'GroqException($message, statusCode: $statusCode)';
}

/// Thin, dependency-light client for the Groq chat-completions API.
class GroqClient {
  final GroqConfig config;
  final Dio _dio;

  GroqClient({GroqConfig? config, Dio? dio})
      : config = config ?? GroqConfig.fromEnvironment(),
        _dio = dio ?? Dio() {
    _dio.options = _dio.options.copyWith(
      baseUrl: this.config.baseUrl,
      connectTimeout: this.config.timeout,
      receiveTimeout: this.config.timeout,
      sendTimeout: this.config.timeout,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${this.config.apiKey}',
      },
      validateStatus: (status) => status != null && status < 500,
    );
  }

  /// Sends a chat completion request and returns the assistant message.
  Future<GroqChatResult> chat({
    required List<GroqMessage> messages,
    double temperature = 0.2,
    int maxTokens = 700,
    bool jsonMode = false,
  }) async {
    if (!config.isConfigured) {
      throw const GroqException(
        'Groq API key is not configured. Provide it with '
        '--dart-define=GROQ_API_KEY=<key>.',
      );
    }

    final body = <String, dynamic>{
      'model': config.model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': temperature,
      'max_tokens': maxTokens,
    };
    if (jsonMode) {
      body['response_format'] = {'type': 'json_object'};
    }
    if (!config.includeReasoning) {
      body['include_reasoning'] = false;
    }

    final stopwatch = Stopwatch()..start();
    late final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>('/chat/completions', data: body);
    } on DioException catch (e) {
      stopwatch.stop();
      throw GroqException(
        'Network error while calling Groq: ${e.message}',
        rawBody: e.response?.data?.toString(),
      );
    }
    stopwatch.stop();

    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status >= 400 || data is! Map) {
      throw GroqException(
        _extractErrorMessage(data) ?? 'Groq request failed with HTTP $status',
        statusCode: status,
        rawBody: data?.toString(),
      );
    }

    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw GroqException(
        'Groq returned no choices',
        statusCode: status,
        rawBody: data.toString(),
      );
    }

    final first = choices.first;
    final message = (first is Map) ? first['message'] : null;
    String content = '';
    if (message is Map) {
      final raw = message['content'];
      if (raw is String) {
        content = raw;
      } else if (raw is List) {
        // Some providers return content as an array of parts.
        content = raw
            .whereType<Map>()
            .map((p) => p['text'])
            .whereType<String>()
            .join();
      }
    }

    final usage = data['usage'];
    return GroqChatResult(
      content: content,
      model: data['model']?.toString(),
      finishReason: first is Map ? first['finish_reason']?.toString() : null,
      promptTokens: usage is Map ? usage['prompt_tokens'] as int? : null,
      completionTokens: usage is Map ? usage['completion_tokens'] as int? : null,
      totalTokens: usage is Map ? usage['total_tokens'] as int? : null,
      durationMs: stopwatch.elapsedMilliseconds.toDouble(),
    );
  }

  /// Sends a chat request that is expected to return a JSON object and parses
  /// it. Falls back to extracting the first JSON object from the text when
  /// the model wraps it in markdown fences or prose.
  Future<Map<String, dynamic>> chatJson({
    required List<GroqMessage> messages,
    double temperature = 0.1,
    int maxTokens = 700,
  }) async {
    final result = await chat(
      messages: messages,
      temperature: temperature,
      maxTokens: maxTokens,
      jsonMode: true,
    );
    final parsed = extractJsonObject(result.content);
    if (parsed == null) {
      throw GroqException(
        'Groq response did not contain parsable JSON',
        rawBody: result.content,
      );
    }
    return parsed;
  }

  /// Extracts the first well-formed JSON object from an arbitrary string.
  static Map<String, dynamic>? extractJsonObject(String raw) {
    if (raw.trim().isEmpty) return null;

    // Fast path: the whole payload is JSON.
    try {
      final decoded = jsonDecode(raw.trim());
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // fall through to the scanning approach
    }

    // Strip markdown code fences.
    var text = raw.trim();
    if (text.startsWith('```')) {
      final firstNewline = text.indexOf('\n');
      if (firstNewline != -1) {
        text = text.substring(firstNewline + 1);
        final closing = text.lastIndexOf('```');
        if (closing != -1) text = text.substring(0, closing);
      }
    }
    text = text.trim();

    // Scan for the first balanced `{ ... }` block (respecting strings/escapes).
    final start = text.indexOf('{');
    if (start == -1) return null;

    var depth = 0;
    var inString = false;
    var escaped = false;
    for (var i = start; i < text.length; i++) {
      final ch = text[i];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (ch == r'\') {
          escaped = true;
        } else if (ch == '"') {
          inString = false;
        }
        continue;
      }
      if (ch == '"') {
        inString = true;
      } else if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) {
          final candidate = text.substring(start, i + 1);
          try {
            final decoded = jsonDecode(candidate);
            if (decoded is Map<String, dynamic>) return decoded;
            if (decoded is Map) return Map<String, dynamic>.from(decoded);
          } catch (_) {
            return null;
          }
        }
      }
    }
    return null;
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        final message = error['message'];
        if (message is String) return message;
      }
      if (error is String) return error;
    }
    return null;
  }
}
