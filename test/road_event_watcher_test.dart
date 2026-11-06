import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/services/live_ml_inference_service.dart';
import 'package:ride_sensor_capture/location/location_service.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_service.dart';
import 'package:ride_sensor_capture/prealert/road_event_watcher.dart';
import 'package:ride_sensor_capture/voice/voice_alert_service.dart';

void main() {
  late AppDatabase db;
  late LocationService location;
  late PreAlertService alerts;
  late RoadEventWatcher watcher;
  final now = DateTime.now().toUtc();
  LiveMlPrediction prediction(MlPredictedEventType type, int millis, {double confidence = .9}) =>
    LiveMlPrediction(eventType: type, label: type.name, confidence: confidence,
      timestampUtc: now.add(Duration(milliseconds: millis)), topFeatures: const {}, explanation: 'test');
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    location = LocationService();
    location.injectFixForTesting(LocationFix(latitude: 12.97, longitude: 77.59, timestampUtc: now));
    alerts = PreAlertService(db: db, voiceService: VoiceAlertService(ttsEnabled: false));
    watcher = RoadEventWatcher(preAlertService: alerts, locationService: location);
  });
  tearDown(() async {
    await watcher.stop();
    await watcher.flush();
    location.dispose();
    await db.close();
  });
  test('detects only during a journey and never automatically registers a hazard', () async {
    watcher.handlePrediction(prediction(MlPredictedEventType.severeBump, 0));
    await watcher.flush();
    expect(await db.select(db.liveEventReviews).get(), isEmpty);
    watcher.beginTrip(1);
    watcher.handlePrediction(prediction(MlPredictedEventType.severeBump, 0));
    await watcher.flush();
    final events = await db.select(db.liveEventReviews).get();
    expect(events, hasLength(1));
    expect(events.single.eventType, 'bump'); // An impulse alone cannot prove a pothole.
    expect(events.single.latitude, 12.97);
    expect(await db.select(db.roadEvents).get(), isEmpty);
  });
  test('mild bumps are reviewable and normal/low-confidence readings ignored', () async {
    watcher.beginTrip(1);
    watcher.handlePrediction(prediction(MlPredictedEventType.normalRiding, 0));
    watcher.handlePrediction(prediction(MlPredictedEventType.severeBump, 1000, confidence: .3));
    watcher.handlePrediction(prediction(MlPredictedEventType.mildBump, 2000, confidence: .75));
    await watcher.flush();
    expect(await db.select(db.liveEventReviews).get(), hasLength(1));
  });
  test('one sustained episode yields one event, distinct later bumps are retained', () async {
    watcher.beginTrip(1);
    for (var i = 0; i < 10; i++) {
      watcher.handlePrediction(prediction(MlPredictedEventType.mildBump, i * 1000));
    }
    watcher.handlePrediction(prediction(MlPredictedEventType.normalRiding, 10000));
    watcher.handlePrediction(prediction(MlPredictedEventType.normalRiding, 10800));
    watcher.handlePrediction(prediction(MlPredictedEventType.mildBump, 11000));
    await watcher.flush();
    expect(await db.select(db.liveEventReviews).get(), hasLength(2));
  });
  test('stale GPS cannot stamp a new event and stopping stops detection', () async {
    watcher.beginTrip(1);
    watcher.handlePrediction(prediction(MlPredictedEventType.mildBump, 30000));
    await watcher.flush();
    expect((await db.select(db.liveEventReviews).get()).single.latitude, isNull);
    await watcher.stop();
    watcher.handlePrediction(prediction(MlPredictedEventType.sharpTurn, 35000));
    await watcher.flush();
    expect(await db.select(db.liveEventReviews).get(), hasLength(1));
  });
  test('a new trip resets event suppression', () async {
    watcher.beginTrip(1);
    watcher.handlePrediction(prediction(MlPredictedEventType.mildBump, 0));
    await watcher.flush();
    watcher.beginTrip(2);
    watcher.handlePrediction(prediction(MlPredictedEventType.mildBump, 500));
    await watcher.flush();
    expect((await db.select(db.liveEventReviews).get()).map((e) => e.tripId), [1, 2]);
  });
}
