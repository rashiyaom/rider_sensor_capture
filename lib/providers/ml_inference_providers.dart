import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/live_ml_inference_service.dart';
import 'ble_providers.dart';

/// Provider for the singleton on-device Live ML Inference Service
final liveMlInferenceServiceProvider = Provider<LiveMlInferenceService>((ref) {
  final service = LiveMlInferenceService();

  // Pipe raw sensor data stream into the inference engine
  final sub = ref.listen(rawSensorDataStreamProvider, (_, next) {
    final data = next.value;
    if (data != null) {
      service.ingestReading(data);
    }
  });

  ref.onDispose(() {
    sub.close();
    service.dispose();
  });

  return service;
});

/// Stream of real-time predictions emitted by the Edge ML Classifier
final liveMlPredictionStreamProvider = StreamProvider.autoDispose<LiveMlPrediction>((ref) {
  final service = ref.watch(liveMlInferenceServiceProvider);
  return service.predictionStream;
});

/// State provider exposing the latest real-time ML prediction snapshot
final latestMlPredictionProvider = Provider.autoDispose<LiveMlPrediction>((ref) {
  final asyncVal = ref.watch(liveMlPredictionStreamProvider);
  return asyncVal.value ?? ref.watch(liveMlInferenceServiceProvider).latestPrediction;
});
