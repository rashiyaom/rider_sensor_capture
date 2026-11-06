import 'dart:async';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/voice/handsfree_session_service.dart';
import 'package:ride_sensor_capture/voice/voice_alert_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:ride_sensor_capture/data/services/live_ml_inference_service.dart';
import 'package:ride_sensor_capture/location/location_service.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_engine.dart';

class _SpeechRecognition extends Fake implements SpeechToText {
  bool listening = false;
  int starts = 0;
  void Function(String)? onStatus;
  void Function()? onStop;
  void Function(SpeechRecognitionResult)? onResult;
  void answer(String words) => onResult?.call(
    SpeechRecognitionResult.init([
      SpeechRecognitionWords(words, null, 1.0),
    ], ResultType.finalResult),
  );

  @override
  bool get isListening => listening;

  @override
  Future<void> stop() async {
    onStop?.call();
    listening = false;
    onStatus?.call('notListening');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #initialize) {
      onStatus = invocation.namedArguments[#onStatus] as void Function(String)?;
      return Future<bool>.value(true);
    }
    if (invocation.memberName == #listen) {
      starts++;
      onResult =
          invocation.namedArguments[#onResult]
              as void Function(SpeechRecognitionResult)?;
      listening = true;
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

class _Voice extends VoiceAlertService {
  final messages = <String>[];
  final playback = <Completer<bool>>[];
  void Function()? onSpeak;
  bool disposed = false;

  @override
  Future<bool> ensureInitialized() async => true;
  @override
  bool get isAvailable => true;
  @override
  bool get isSpeaking => playback.any((p) => !p.isCompleted);

  @override
  Future<bool> speak(
    String text, {
    double rate = 0.55,
    double pitch = 1,
    bool interrupt = false,
    bool hapticFallback = true,
    bool Function()? shouldSpeak,
    String Function()? textProvider,
  }) {
    if (shouldSpeak != null && !shouldSpeak()) return Future.value(false);
    onSpeak?.call();
    messages.add(textProvider?.call() ?? text);
    final pending = Completer<bool>();
    playback.add(pending);
    return pending.future;
  }

  @override
  Future<void> stop() async {
    for (final pending in playback) {
      if (!pending.isCompleted) pending.complete(false);
    }
  }

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late _Voice voice;
  late _SpeechRecognition mic;
  late HandsfreeSessionService service;
  const permissions = MethodChannel('flutter.baseflow.com/permissions/methods');

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    voice = _Voice();
    mic = _SpeechRecognition();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissions, (call) async {
          if (call.method == 'requestPermissions') {
            return {for (final id in call.arguments as List) id: 1};
          }
          return 1;
        });
    await pumpEventQueue();
  });

  tearDown(() async {
    mic.onStop = null;
    await service.stop();
    service.dispose();
    await db.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissions, null);
  });

  Future<void> until(bool Function() ready) async {
    for (var i = 0; i < 100 && !ready(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(ready(), isTrue);
  }

  testWidgets('mic stays paused through long speech and restart timers', (
    tester,
  ) async {
    service = HandsfreeSessionService(db: db, tts: voice, stt: mic);
    await service.start();
    expect(mic.starts, 1);
    mic.onStop = () => expectSync(service.state.mode, HandsfreeMode.speaking);
    voice.onSpeak = () => expectSync(mic.isListening, isFalse);
    final alert = service.announceEventAlert(eventType: 'bump');
    await tester.pump();
    expect(service.state.mode, HandsfreeMode.speaking);
    await tester.pump(const Duration(seconds: 8));
    expect(mic.starts, 1);
    expect(service.state.mode, HandsfreeMode.speaking);
    voice.playback.single.complete(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await alert;
    expect(mic.starts, 2);
    expect(service.state.mode, HandsfreeMode.listening);
    mic.onStop = null;
    await service.stop();
    await tester.pump(const Duration(seconds: 1));
  });

  test(
    'manual recording asks for confirmation after preceding speech',
    () async {
      service = HandsfreeSessionService(db: db, tts: voice, stt: mic);
      await service.start();
      final id = await db
          .into(db.eventRecords)
          .insert(
            EventRecordsCompanion.insert(
              eventType: 'bump',
              startTimestamp: DateTime.now().toUtc(),
              status: 'completed',
              tripId: const Value(1),
            ),
          );
      final alert = service.announceEventAlert(eventType: 'bump');
      await until(() => voice.messages.isNotEmpty);
      final feedback = service.promptAndRecordEventFeedback(
        eventId: id,
        eventType: 'bump',
        tripId: 1,
      );
      expect(voice.messages, hasLength(1));
      voice.playback.first.complete(true);
      await alert;
      await until(() => voice.messages.length == 2);
      expect(voice.messages.last, 'Was that a bump?');
      expect(mic.isListening, isFalse);
      await service.stop();
      await feedback;
      expect(service.state.mode, HandsfreeMode.off);
    },
  );

  testWidgets('stop cancels queued prompts', (tester) async {
    service = HandsfreeSessionService(db: db, tts: voice, stt: mic);
    await service.start();
    final alert = service.announceEventAlert(eventType: 'bump');
    await tester.pump();
    final feedback = service.promptAndRecordEventFeedback(
      eventId: 1,
      eventType: 'bump',
    );
    await service.stop();
    await tester.pump(const Duration(seconds: 1));
    await Future.wait([alert, feedback]);
    expect(voice.messages, hasLength(1));
    expect(service.state.mode, HandsfreeMode.off);
  });

  test('disposing handsfree does not dispose the shared speech service', () {
    service = HandsfreeSessionService(db: db, tts: voice, stt: mic);
    service.dispose();
    expect(voice.disposed, isFalse);
  });
  Future<void> beginLiveEvent() async {
    service = HandsfreeSessionService(db: db, tts: voice, stt: mic);
    await service.start();
    unawaited(
      service.reviewLiveDetection(
        tripId: 1,
        prediction: LiveMlPrediction(
          eventType: MlPredictedEventType.mildBump,
          label: 'Bump',
          confidence: .8,
          timestampUtc: DateTime.now().toUtc(),
          topFeatures: const {},
          explanation: 'test',
        ),
        fix: LocationFix(
          latitude: 12.97,
          longitude: 77.59,
          timestampUtc: DateTime.now().toUtc(),
        ),
      ),
    );
    await until(() => voice.messages.isNotEmpty);
  }

  test('live bump asks confirmation, captures feedback, and waits for trip-end saving', () async {
    await beginLiveEvent();
    expect(voice.messages.single, 'Was that a bump?');
    expect(mic.isListening, isFalse);
    voice.playback.last.complete(true);
    await until(
      () => service.state.mode == HandsfreeMode.awaitingUnknownEventAnswer,
    );
    mic.answer('yes');
    await until(() => voice.messages.length == 2);
    expect(voice.messages.last, 'How was it?');
    expect(mic.isListening, isFalse);
    voice.playback.last.complete(true);
    await until(
      () => service.state.mode == HandsfreeMode.awaitingUnknownEventAnswer,
    );
    mic.answer('okayish and bumpy');
    await until(() => voice.messages.length == 3);
    voice.playback.last.complete(true);
    await service.idle;
    final row = (await db.select(db.liveEventReviews).get()).single;
    expect(row.confirmationReply, 'yes');
    expect(row.confirmed, isTrue);
    expect(row.feedback, 'okayish and bumpy');
    expect(row.latitude, 12.97);
    expect(row.reviewStatus, 'pending');
    expect(await db.select(db.roadEvents).get(), isEmpty);
  });

  test(
    'negative confirmation skips feedback and never enables future alerts',
    () async {
      await beginLiveEvent();
      voice.playback.last.complete(true);
      await until(
        () => service.state.mode == HandsfreeMode.awaitingUnknownEventAnswer,
      );
      mic.answer('no');
      await until(() => voice.messages.length == 2);
      expect(voice.messages.last, contains('not an event'));
      voice.playback.last.complete(true);
      await service.idle;
      expect(voice.messages, isNot(contains('How was it?')));
      expect(
        (await db.select(db.liveEventReviews).get()).single.confirmed,
        isFalse,
      );
      expect(await db.select(db.roadEvents).get(), isEmpty);
    },
  );

  test(
    'upcoming warning takes priority over an answer without cutting speech',
    () async {
      await beginLiveEvent();
      voice.playback.last.complete(true);
      await until(
        () => service.state.mode == HandsfreeMode.awaitingUnknownEventAnswer,
      );
      final now = DateTime.now().toUtc();
      final warning = service.announcePreAlert(
        PreAlertDecision(
          candidate: RoadEventCandidate(
            kind: RoadEventKind.bump,
            latitude: 12.97,
            longitude: 77.59,
            detectedAtUtc: now,
          ),
          evaluatedAtUtc: now,
          distanceMeters: 220,
          bearingDeg: 0,
          relativeBearingDeg: 0,
          speedKmh: 80,
          timeToEventSeconds: 9.9,
          recommendedSpeedKmh: 30,
          urgency: PreAlertUrgency.warning,
          window: PreAlertWindow.inWindow,
          shouldSpeak: true,
        ),
      );
      await until(() => voice.messages.length == 2);
      expect(voice.messages.last, contains('Slow down to 30'));
      expect(mic.isListening, isFalse);
      voice.playback.last.complete(true);
      expect(await warning, 'delivered');
      expect(service.state.mode, HandsfreeMode.listening);
      expect(
        (await db.select(db.liveEventReviews).get()).single.confirmed,
        isNull,
      );
    },
  );

  test('unknown replies are not interpreted as confirmation', () {
    service = HandsfreeSessionService(db: db, tts: voice, stt: mic);
    expect(HandsfreeSessionService.confirmationFrom('yesterday'), isNull);
    expect(
      HandsfreeSessionService.confirmationFrom('yes, no actually'),
      isFalse,
    );
    expect(HandsfreeSessionService.confirmationFrom(null), isNull);
  });
}
