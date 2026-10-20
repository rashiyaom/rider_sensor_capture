import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/llm/groq_client.dart';

/// Canned HTTP adapter so the client can be exercised without network access.
class _FakeAdapter implements HttpClientAdapter {
  final Map<String, dynamic> body;

  _FakeAdapter(this.body);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  group('GroqConfig', () {
    test('is not configured without an API key', () {
      const config = GroqConfig(apiKey: '');
      expect(config.isConfigured, isFalse);
    });

    test('is configured with an API key', () {
      const config = GroqConfig(apiKey: 'gsk_test');
      expect(config.isConfigured, isTrue);
    });

    test('uses the Groq Cloud base URL by default', () {
      const config = GroqConfig(apiKey: 'gsk_test');
      expect(config.baseUrl, 'https://api.groq.com/openai/v1');
    });

    test('defaults to a currently supported production model', () {
      const config = GroqConfig(apiKey: 'gsk_test');
      expect(config.model, 'openai/gpt-oss-120b');
    });

    test('fromEnvironment reads the compile-time defines', () {
      final config = GroqConfig.fromEnvironment();
      // No key is baked into the test binary, so it must report unconfigured.
      expect(config.isConfigured, isFalse);
      expect(config.model, isNotEmpty);
    });
  });

  group('GroqMessage', () {
    test('serialises to the OpenAI chat-completions shape', () {
      const message = GroqMessage.system('hello');
      expect(message.toJson(), {'role': 'system', 'content': 'hello'});
    });
  });

  group('GroqClient.extractJsonObject', () {
    test('parses a plain JSON object', () {
      final parsed = GroqClient.extractJsonObject('{"a": 1, "b": "two"}');
      expect(parsed, isNotNull);
      expect(parsed!['a'], 1);
      expect(parsed['b'], 'two');
    });

    test('parses JSON wrapped in markdown fences', () {
      final parsed = GroqClient.extractJsonObject(
        '```json\n{"alertEffectiveness": 0.75}\n```',
      );
      expect(parsed, isNotNull);
      expect(parsed!['alertEffectiveness'], 0.75);
    });

    test('parses JSON embedded in prose', () {
      final parsed = GroqClient.extractJsonObject(
        'Here is my analysis: {"alertEffectiveness": 0.4, "difficultyLevel": "moderate"} — hope that helps.',
      );
      expect(parsed, isNotNull);
      expect(parsed!['alertEffectiveness'], 0.4);
      expect(parsed['difficultyLevel'], 'moderate');
    });

    test('handles nested objects and arrays', () {
      final parsed = GroqClient.extractJsonObject(
        '{"outer": {"inner": [1, 2, 3]}, "text": "a } brace inside a string"}',
      );
      expect(parsed, isNotNull);
      expect((parsed!['outer'] as Map)['inner'], [1, 2, 3]);
      expect(parsed['text'], 'a } brace inside a string');
    });

    test('returns null for non-JSON output', () {
      expect(GroqClient.extractJsonObject('not json at all'), isNull);
      expect(GroqClient.extractJsonObject(''), isNull);
    });

    test('returns null for truncated JSON', () {
      expect(GroqClient.extractJsonObject('{"a": 1'), isNull);
    });
  });

  group('GroqClient — request construction', () {
    late List<RequestOptions> captured;
    late Dio dio;

    setUp(() {
      captured = [];
      dio = Dio();
      dio.httpClientAdapter = _FakeAdapter({
        'model': 'openai/gpt-oss-120b',
        'choices': [
          {
            'message': {
              'role': 'assistant',
              'content': '{"alertEffectiveness": 0.9}',
            },
            'finish_reason': 'stop',
          }
        ],
        'usage': {
          'prompt_tokens': 120,
          'completion_tokens': 40,
          'total_tokens': 160,
        },
      });
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured.add(options);
            handler.next(options);
          },
        ),
      );
    });

    test('sends the model, messages and JSON mode to Groq', () async {
      final client = GroqClient(
        config: const GroqConfig(apiKey: 'gsk_test'),
        dio: dio,
      );

      final result = await client.chatJson(
        messages: const [GroqMessage.user('evaluate this')],
      );

      expect(result['alertEffectiveness'], 0.9);

      final request = captured.single;
      expect(request.path, '/chat/completions');
      expect(request.headers['Authorization'], 'Bearer gsk_test');

      final body = request.data as Map<String, dynamic>;
      expect(body['model'], 'openai/gpt-oss-120b');
      expect(body['response_format'], {'type': 'json_object'});
      expect(body['include_reasoning'], false);
      expect((body['messages'] as List).first['content'], 'evaluate this');
    });

    test('parses the usage metadata from the response', () async {
      final client = GroqClient(
        config: const GroqConfig(apiKey: 'gsk_test'),
        dio: dio,
      );
      final result = await client.chat(
        messages: const [GroqMessage.user('hi')],
      );
      expect(result.promptTokens, 120);
      expect(result.completionTokens, 40);
      expect(result.totalTokens, 160);
      expect(result.model, 'openai/gpt-oss-120b');
    });

    test('throws a clear error when no API key is configured', () async {
      final client = GroqClient(
        config: const GroqConfig(apiKey: ''),
        dio: dio,
      );
      expect(
        () => client.chat(messages: const [GroqMessage.user('hi')]),
        throwsA(isA<GroqException>()),
      );
    });
  });

  group('GroqException', () {
    test('classifies authentication and rate-limit errors', () {
      expect(const GroqException('x', statusCode: 401).isAuthError, isTrue);
      expect(const GroqException('x', statusCode: 403).isAuthError, isTrue);
      expect(const GroqException('x', statusCode: 429).isRateLimited, isTrue);
      expect(const GroqException('x', statusCode: 500).isAuthError, isFalse);
    });
  });
}
