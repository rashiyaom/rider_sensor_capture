import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/services/live_ml_inference_service.dart';
import '../features/live_events/live_event_repository.dart';
import '../location/location_service.dart';
import 'pre_alert_service.dart';

/// Records distinct live sensor events for confirmation and trip-end review.
class RoadEventWatcher {
  final PreAlertService preAlertService;
  final LocationService? locationService;
  final double minConfidence;
  final Duration dedupeWindow;
  StreamSubscription<LiveMlPrediction>? _predictionSubscription;
  String? _episode;
  DateTime? _normalSince;
  DateTime? _lastDetectedAt;
  int? _tripId;
  final Set<Future<void>> _pending = {};

  RoadEventWatcher({required this.preAlertService, this.locationService,
    this.minConfidence = 0.70, this.dedupeWindow = const Duration(seconds: 3)});

  void beginTrip(int tripId) {
    _tripId = tripId;
    _episode = null;
    _normalSince = null;
    _lastDetectedAt = null;
  }

  void start(Stream<LiveMlPrediction> predictions) {
    _predictionSubscription?.cancel();
    _predictionSubscription = predictions.listen(handlePrediction);
  }

  void handlePrediction(LiveMlPrediction prediction) {
    final tripId = _tripId;
    if (tripId == null) return;
    if (!prediction.isAnomaly) {
      _normalSince ??= prediction.timestampUtc;
      if (prediction.timestampUtc.difference(_normalSince!) >= const Duration(milliseconds: 600)) {
        _episode = null;
      }
      return;
    }
    _normalSince = null;
    if (!prediction.confidence.isFinite || prediction.confidence < minConfidence) return;
    final type = LiveEventRepository.typeFor(prediction.eventType);
    if (_episode == type) return;
    if (_lastDetectedAt != null && prediction.timestampUtc.difference(_lastDetectedAt!) < dedupeWindow) return;
    _episode = type;
    _lastDetectedAt = prediction.timestampUtc;
    final fix = locationService?.currentFix;
    // Never stamp a new event with an old fix or a wildly inaccurate location.
    final validFix = fix != null &&
        prediction.timestampUtc.difference(fix.timestampUtc).inSeconds.abs() <= 10 &&
        (fix.gpsAccuracyM == null || fix.gpsAccuracyM! <= 50) ? fix : null;
    final hf = preAlertService.handsfreeService;
    final operation = (hf != null
        ? hf.reviewLiveDetection(tripId: tripId, prediction: prediction, fix: validFix)
        : LiveEventRepository(preAlertService.db).capture(
            tripId: tripId, prediction: prediction, fix: validFix).then<void>((_) {}))
        .catchError((Object error) {
          if (kDebugMode) debugPrint('Live event capture failed: $error');
        });
    _pending.add(operation);
    unawaited(operation.whenComplete(() => _pending.remove(operation)));
  }

  Future<void> stop() async {
    _tripId = null;
    await _predictionSubscription?.cancel();
    _predictionSubscription = null;
  }

  Future<void> flush() => Future.wait(_pending.toList());
}
