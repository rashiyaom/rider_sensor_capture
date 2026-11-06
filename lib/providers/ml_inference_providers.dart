import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/live_ml_inference_service.dart';
import 'ble_providers.dart';

/// Provider for the singleton on-device Live ML Inference Service
final liveMlInferenceServiceProvider = Provider<LiveMlInferenceService>((ref) {
  final service = LiveMlInferenceService();

  // Subscribe directly so every BLE sample reaches inference even between UI frames.
  final sub = ref.watch(bleConnectionManagerProvider).rawDataStream.listen((data) {
    final mount = ref.read(deviceMountLocationMapProvider)[data.deviceId];
    service.ingestReading(mount == null ? data : data.copyWith(mountLocation: mount));
  });

  ref.onDispose(() {
    sub.cancel();
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
