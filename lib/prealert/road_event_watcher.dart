import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/services/live_ml_inference_service.dart';
import '../location/location_service.dart';
import 'pre_alert_engine.dart';
import 'pre_alert_service.dart';

/// Watches the live on-device ML classifier and turns confirmed road events
/// into geo-tagged entries in the road-event knowledge base.
///
/// This is what makes the predictive pre-alert system *proactive*: the very
/// first time the rider hits a bump it is learned, and from then on the phone
/// warns them before they reach it again.
class RoadEventWatcher {
  final PreAlertService preAlertService;
  final LocationService? locationService;

  StreamSubscription<LiveMlPrediction>? _predictionSubscription;

  /// Minimum ML confidence required before a detection is trusted enough to
  /// be written into the knowledge base.
  final double minConfidence;

  /// Minimum seconds between two registrations of the same event class, so a
  /// single rough stretch of road does not spam the knowledge base.
  final Duration dedupeWindow;

  final Map<String, DateTime> _lastRegisteredAt = <String, DateTime>{};

  RoadEventWatcher({
    required this.preAlertService,
    this.locationService,
    this.minConfidence = 0.80,
    this.dedupeWindow = const Duration(seconds: 30),
  });

  /// Starts listening to the ML prediction stream.
  void start(Stream<LiveMlPrediction> predictions) {
    _predictionSubscription?.cancel();
    _predictionSubscription = predictions.listen(handlePrediction);
  }

  /// Feeds a prediction into the watcher (also usable directly in tests).
  void handlePrediction(LiveMlPrediction prediction) {
    if (!prediction.isAnomaly) return;
    if (prediction.confidence < minConfidence) return;

    final kind = _kindFor(prediction.eventType);
    if (kind == null) return;

    final now = DateTime.now().toUtc();
    final last = _lastRegisteredAt[kind.name];
    if (last != null && now.difference(last) < dedupeWindow) return;
    _lastRegisteredAt[kind.name] = now;

    final fix = locationService?.currentFix;
    if (fix == null) return;

    unawaited(
      preAlertService.registerDetectedRoadEvent(
        kind: kind,
        latitude: fix.latitude,
        longitude: fix.longitude,
        severity: prediction.confidence,
        confidence: prediction.confidence,
        source: 'ml',
        speedKmhAtDetection: fix.speedKmh,
        note: prediction.explanation,
      ),
    );
  }

  /// Maps an ML prediction class onto a road-event kind.
  static RoadEventKind? _kindFor(MlPredictedEventType type) {
    switch (type) {
      case MlPredictedEventType.severeBump:
        return RoadEventKind.pothole;
      case MlPredictedEventType.mildBump:
        return RoadEventKind.bump;
      case MlPredictedEventType.sharpTurn:
        return RoadEventKind.turn;
      case MlPredictedEventType.hardBraking:
        return RoadEventKind.braking;
      case MlPredictedEventType.rapidAcceleration:
      case MlPredictedEventType.normalRiding:
        return null;
    }
  }

  Future<void> stop() async {
    await _predictionSubscription?.cancel();
    _predictionSubscription = null;
    if (kDebugMode) {
      // Intentionally silent in release builds.
    }
  }
}
