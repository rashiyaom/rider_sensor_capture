import 'package:drift/drift.dart' show OrderingMode, OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_db/database.dart';
import '../voice/handsfree_session_service.dart';
import 'db_providers.dart';
import 'pre_alert_providers.dart';

/// The singleton [HandsfreeSessionService] shared across the whole app.
///
/// It lazily creates the service and auto-disposes it when the last widget
/// watching the provider is removed.
final handsfreeSessionServiceProvider =
    Provider<HandsfreeSessionService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final voiceAlert = ref.watch(voiceAlertServiceProvider);
  final service = HandsfreeSessionService(db: db, tts: voiceAlert);
  ref.onDispose(service.dispose);
  return service;
});

/// Reactive stream of [HandsfreeSessionState] — used by the UI indicator pill.
final handsfreeStateStreamProvider =
    StreamProvider<HandsfreeSessionState>((ref) {
  final service = ref.watch(handsfreeSessionServiceProvider);
  return service.stateStream;
});

/// Current snapshot of [HandsfreeSessionState] for synchronous reads.
final handsfreeStateProvider = Provider<HandsfreeSessionState>((ref) {
  final service = ref.watch(handsfreeSessionServiceProvider);
  // Refresh whenever the stream emits
  ref.watch(handsfreeStateStreamProvider);
  return service.state;
});

/// A stream of all recorded unknown events, newest first.
final unknownEventsStreamProvider =
    StreamProvider<List<UnknownEvent>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.unknownEvents)
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.detectedAtUtc,
                mode: OrderingMode.desc,
              )
        ]))
      .watch();
});
