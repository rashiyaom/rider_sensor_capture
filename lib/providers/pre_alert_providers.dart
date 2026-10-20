import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_db/database.dart';
import '../location/location_service.dart';
import '../prealert/pre_alert_engine.dart';
import '../prealert/pre_alert_service.dart';
import '../prealert/road_event_watcher.dart';
import '../voice/voice_alert_service.dart';
import 'db_providers.dart';

/// Shared GPS stream used by the predictive pre-alert system.
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(service.dispose);
  return service;
});

/// Text-to-speech engine used for the spoken pre-alerts.
final voiceAlertServiceProvider = Provider<VoiceAlertService>((ref) {
  final service = VoiceAlertService();
  ref.onDispose(service.dispose);
  return service;
});

/// The predictive pre-alert orchestrator.
final preAlertServiceProvider = Provider<PreAlertService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final service = PreAlertService(
    db: db,
    voiceService: ref.watch(voiceAlertServiceProvider),
    locationService: ref.watch(locationServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Every warning that was actually spoken during this session.
final preAlertStreamProvider = StreamProvider<PreAlertDecision>((ref) {
  final service = ref.watch(preAlertServiceProvider);
  return service.alertStream;
});

/// The warning currently being displayed in the UI.
final activePreAlertProvider = Provider<PreAlertDecision?>((ref) {
  final service = ref.watch(preAlertServiceProvider);
  ref.watch(preAlertStreamProvider);
  return service.activeAlert;
});

/// The geo-tagged road-event knowledge base.
final roadEventsStreamProvider = StreamProvider<List<RoadEvent>>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.watchRoadEvents();
});

/// Learns new hazards from the live on-device ML classifier so the rider is
/// warned about them *before* they reach them on a later pass.
final roadEventWatcherProvider = Provider<RoadEventWatcher>((ref) {
  final watcher = RoadEventWatcher(
    preAlertService: ref.watch(preAlertServiceProvider),
    locationService: ref.watch(locationServiceProvider),
  );
  ref.onDispose(() => watcher.stop());
  return watcher;
});
