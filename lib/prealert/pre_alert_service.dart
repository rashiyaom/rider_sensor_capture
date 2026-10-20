import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../data/local_db/database.dart';
import '../location/location_service.dart';
import '../voice/voice_alert_service.dart';
import 'pre_alert_engine.dart';
import 'road_event_registry.dart';

/// Orchestrates the predictive pre-alert system.
///
/// Responsibilities:
/// * consume GPS fixes and the geo-tagged road-event knowledge base,
/// * decide *when* a warning should be spoken (see [PreAlertEngine]),
/// * speak the warning through the TTS engine,
/// * persist every warning so the post-event feedback loop can later score
///   whether the timing was right.
class PreAlertService {
  final AppDatabase db;
  final RoadEventRegistry registry;
  final VoiceAlertService voiceService;
  final PreAlertEngine engine;
  final LocationService? locationService;

  final StreamController<PreAlertDecision> _alertController =
      StreamController<PreAlertDecision>.broadcast();

  StreamSubscription<LocationFix>? _fixSubscription;

  /// Road-event ids that have already been warned about during this session.
  final Set<int> _alertedEventIds = <int>{};

  /// Last time each road-event id was warned about (for re-alert cooldowns).
  final Map<int, DateTime> _lastAlertAt = <int, DateTime>{};

  /// The most recent decision that was surfaced to the rider.
  PreAlertDecision? _activeAlert;

  bool _running = false;

  /// Minimum time before the *same* hazard may be warned about again.
  final Duration reAlertCooldown;

  PreAlertService({
    required this.db,
    VoiceAlertService? voiceService,
    PreAlertEngine? engine,
    this.locationService,
    this.reAlertCooldown = const Duration(minutes: 2),
  })  : registry = RoadEventRegistry(db),
        voiceService = voiceService ?? VoiceAlertService(),
        engine = engine ?? const PreAlertEngine();

  /// Stream of warnings that were actually issued.
  Stream<PreAlertDecision> get alertStream => _alertController.stream;

  /// The warning currently shown in the UI.
  PreAlertDecision? get activeAlert => _activeAlert;

  /// True while the service is consuming GPS fixes.
  bool get isRunning => _running;

  /// Starts GPS tracking and begins evaluating hazards.
  Future<void> start() async {
    if (_running) return;
    _running = true;

    final service = locationService;
    if (service != null) {
      _fixSubscription = service.fixStream.listen(_onFix);
      unawaited(service.startTracking(intervalMs: 1000));
    }
  }

  /// Stops GPS tracking and clears the session state.
  Future<void> stop() async {
    _running = false;
    await _fixSubscription?.cancel();
    _fixSubscription = null;
    await locationService?.stopTracking();
    _alertedEventIds.clear();
    _lastAlertAt.clear();
    _activeAlert = null;
  }

  /// Injects a GPS fix directly (used by tests and by the trip controller).
  Future<void> handleLocationFix(LocationFix fix) => _onFix(fix);

  Future<void> _onFix(LocationFix fix) async {
    if (!_running) return;

    final speedKmh = fix.speedKmh ?? 0.0;
    if (speedKmh <= 0) return;

    try {
      final candidates = await registry.loadCandidates(
        latitude: fix.latitude,
        longitude: fix.longitude,
        radiusMeters: engine.maxConsiderDistanceMeters,
      );
      if (candidates.isEmpty) return;

      final decision = engine.evaluate(
        latitude: fix.latitude,
        longitude: fix.longitude,
        speedKmh: speedKmh,
        candidates: candidates,
        alreadyAlertedIds: _alertedEventIds,
        headingDeg: fix.gpsHeadingDeg,
      );
      if (decision == null) return;

      _activeAlert = decision;

      if (!decision.shouldSpeak) return;

      final roadEventId = decision.candidate.id;
      if (roadEventId != null) {
        final last = _lastAlertAt[roadEventId];
        final now = DateTime.now().toUtc();
        if (last != null && now.difference(last) < reAlertCooldown) return;
        _lastAlertAt[roadEventId] = now;
        _alertedEventIds.add(roadEventId);
      }

      await issueAlert(decision);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PreAlertService: evaluation failed ($e)');
      }
    }
  }

  /// Speaks the warning and records it in the audit log.
  ///
  /// Returns the persisted `pre_alerts` row id, or null when the warning
  /// could not be persisted.
  Future<int?> issueAlert(PreAlertDecision decision) async {
    final message = PreAlertMessageBuilder.build(decision);

    // Haptics first so the rider perceives the warning even if TTS is slow.
    if (decision.urgency == PreAlertUrgency.imminent) {
      unawaited(voiceService.speak(message, pitch: 1.1, hapticFallback: false));
    } else {
      unawaited(voiceService.speak(message, hapticFallback: false));
    }

    try {
      final roadEventId = decision.candidate.id;
      final rowId = await db.into(db.preAlerts).insert(
            PreAlertsCompanion.insert(
              roadEventId: Value(roadEventId),
              tripId: Value(_activeTripId),
              eventType: decision.candidate.kind.name,
              latitude: decision.candidate.latitude,
              longitude: decision.candidate.longitude,
              distanceMeters: decision.distanceMeters,
              speedKmh: decision.speedKmh,
              timeToEventSeconds: decision.timeToEventSeconds,
              recommendedSpeedKmh: decision.recommendedSpeedKmh,
              urgency: decision.urgency.name,
              spokenText: message,
              alertedAtUtc: DateTime.now().toUtc(),
            ),
          );

      if (roadEventId != null) {
        await registry.incrementAlertCount(roadEventId);
      }

      if (!_alertController.isClosed) {
        _alertController.add(decision);
      }
      return rowId;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PreAlertService: failed to persist alert ($e)');
      }
      return null;
    }
  }

  int? _activeTripId;

  /// Sets the trip that subsequent warnings should be attributed to.
  void setActiveTripId(int? tripId) => _activeTripId = tripId;

  /// Registers a newly detected hazard so it can be warned about next time.
  Future<int> registerDetectedRoadEvent({
    required RoadEventKind kind,
    required double latitude,
    required double longitude,
    double severity = 0.5,
    double confidence = 0.8,
    String source = 'ml',
    double? speedKmhAtDetection,
    String? note,
  }) {
    return registry.register(
      kind: kind,
      latitude: latitude,
      longitude: longitude,
      severity: severity,
      confidence: confidence,
      source: source,
      tripId: _activeTripId,
      speedKmhAtDetection: speedKmhAtDetection,
      note: note,
    );
  }

  /// Finds the most recent warning issued for the current trip, so the
  /// post-event feedback loop can score its timing.
  Future<PreAlert?> findMostRecentPreAlert({int? tripId, Duration? within}) {
    var query = db.select(db.preAlerts)
      ..orderBy([(t) => OrderingTerm(expression: t.alertedAtUtc, mode: OrderingMode.desc)])
      ..limit(1);

    final effectiveTripId = tripId ?? _activeTripId;
    if (effectiveTripId != null) {
      query = query..where((t) => t.tripId.equals(effectiveTripId));
    }
    if (within != null) {
      query = query..where(
          (t) => t.alertedAtUtc.isBiggerOrEqualValue(DateTime.now().toUtc().subtract(within)));
    }

    return query.getSingleOrNull();
  }

  /// Links a completed labeled event to the warning that preceded it.
  Future<void> linkEventToPreAlert(int eventId) async {
    final alert = await findMostRecentPreAlert(within: const Duration(minutes: 10));
    if (alert == null) return;
    await (db.update(db.preAlerts)..where((t) => t.id.equals(alert.id))).write(
      PreAlertsCompanion(eventId: Value(eventId)),
    );
  }

  void dispose() {
    unawaited(stop());
    _alertController.close();
  }
}
