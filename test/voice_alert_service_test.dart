import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ride_sensor_capture/voice/voice_alert_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  late VoiceAlertService service;
  late FlutterTts engine;
  late List<String> spoken;
  late List<Completer<int>> playback;
  late bool awaitCompletion;
  late int stops;
  Completer<void>? initializationGate;

  setUp(() {
    spoken = [];
    playback = [];
    stops = 0;
    awaitCompletion = false;
    initializationGate = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'awaitSpeakCompletion':
              awaitCompletion = call.arguments as bool;
            case 'setLanguage':
              await initializationGate?.future;
            case 'speak':
              final args = call.arguments;
              spoken.add(args is String ? args : args['text'] as String);
              final completion = Completer<int>();
              playback.add(completion);
              return awaitCompletion ? completion.future : 1;
            case 'stop':
              stops++;
              for (final pending in playback) {
                if (!pending.isCompleted) pending.complete(0);
              }
          }
          return 1;
        });
    engine = FlutterTts();
    service = VoiceAlertService(tts: engine);
  });

  tearDown(() async {
    await service.stop();
    service.dispose();
    await pumpEventQueue();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'waits for the last word and keeps speaking state until completion',
    () async {
      var finished = false;
      final result = service.speak('Speed bump ahead. Slow down.').then((
        value,
      ) {
        finished = true;
        return value;
      });
      await pumpEventQueue();
      expect(awaitCompletion, isTrue);
      expect(finished, isFalse);
      expect(service.isSpeaking, isTrue);
      expect(service.currentUtterance, 'Speed bump ahead. Slow down.');
      playback.single.complete(1);
      expect(await result, isTrue);
      expect(service.isSpeaking, isFalse);
      expect(service.currentUtterance, isNull);
    },
  );

  test(
    'overlapping messages finish in order without stopping playback',
    () async {
      final first = service.speak('First sentence.');
      final second = service.speak('Second sentence.');
      await pumpEventQueue();
      expect(spoken, ['First sentence.']);
      expect(stops, 0);
      playback.first.complete(1);
      expect(await first, isTrue);
      await pumpEventQueue();
      expect(spoken, ['First sentence.', 'Second sentence.']);
      expect(service.isSpeaking, isTrue);
      playback.last.complete(1);
      expect(await second, isTrue);
      expect(stops, 0);
    },
  );

  test('concurrent initialization waits for the same ready engine', () async {
    initializationGate = Completer<void>();
    final first = service.ensureInitialized();
    await pumpEventQueue();
    var secondFinished = false;
    final second = service.ensureInitialized().then((ready) {
      secondFinished = true;
      return ready;
    });
    final speech = service.speak('Ready.');
    await pumpEventQueue();
    expect(secondFinished, isFalse);
    expect(spoken, isEmpty);
    initializationGate!.complete();
    expect(await first, isTrue);
    expect(await second, isTrue);
    await pumpEventQueue();
    playback.single.complete(1);
    expect(await speech, isTrue);
  });

  test(
    'stop cancels active and queued speech and permits later speech',
    () async {
      final first = service.speak('First.');
      final queued = service.speak('Queued.');
      await pumpEventQueue();
      await service.stop();
      expect(await first, isFalse);
      expect(await queued, isFalse);
      expect(spoken, ['First.']);
      final next = service.speak('New ride.');
      await pumpEventQueue();
      playback.last.complete(1);
      expect(await next, isTrue);
      expect(spoken, ['First.', 'New ride.']);
    },
  );

  test('explicit interruption cancels the previous message', () async {
    final first = service.speak('Long sentence.');
    await pumpEventQueue();
    final urgent = service.speak('Stop.', interrupt: true);
    expect(await first, isFalse);
    await pumpEventQueue();
    expect(spoken, ['Long sentence.', 'Stop.']);
    playback.last.complete(1);
    expect(await urgent, isTrue);
  });

  test(
    'native errors release the queue even without a completion callback',
    () async {
      final failed = service.speak('Failed.', hapticFallback: false);
      final next = service.speak('Next.');
      await pumpEventQueue();
      await engine.platformCallHandler(
        const MethodCall('speak.onError', 'engine error'),
      );
      expect(await failed, isFalse);
      await pumpEventQueue();
      expect(spoken, ['Failed.', 'Next.']);
      playback.last.complete(1);
      expect(await next, isTrue);
    },
  );

  test('stop during initialization prevents late playback', () async {
    initializationGate = Completer<void>();
    final speech = service.speak('Stale message.');
    await pumpEventQueue();
    await service.stop();
    initializationGate!.complete();
    expect(await speech, isFalse);
    expect(spoken, isEmpty);
  });

  test('dispose rejects new speech and cancels pending playback', () async {
    final speech = service.speak('In progress.');
    await pumpEventQueue();
    service.dispose();
    expect(await speech, isFalse);
    expect(await service.speak('Too late.'), isFalse);
    expect(service.isAvailable, isFalse);
  });
}
