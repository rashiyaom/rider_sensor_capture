import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../data/local_db/database.dart';
import '../location/location_service.dart';
import '../location/location_quality.dart';
import '../location/geo_math.dart';
import '../voice/handsfree_session_service.dart';
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
  final DateTime Function() now;
  String? startupError;

  final StreamController<PreAlertDecision> _alertController =
      StreamController<PreAlertDecision>.broadcast();

  StreamSubscription<LocationFix>? _fixSubscription;

  /// Road-event ids that have already been warned about during this session.
  final Set<int> _alertedEventIds = <int>{};
  final Set<int> _inFlightEventIds = <int>{};
  final Map<int, DateTime> _lastAttemptAt = {};
  String? lastDeliveryError;

  /// Last time each road-event id was warned about (for re-alert cooldowns).
  final Map<int, DateTime> _lastAlertAt = <int, DateTime>{};

  /// The most recent decision that was surfaced to the rider.
  PreAlertDecision? _activeAlert;

  bool _running = false;
  bool _evaluating = false;
  int _session = 0;
  LocationFix? _previousFix;

  /// Minimum time before the *same* hazard may be warned about again.
  final Duration reAlertCooldown;

  PreAlertService({
    required this.db,
    VoiceAlertService? voiceService,
    PreAlertEngine? engine,
    this.locationService,
    DateTime Function()? clock,
    this.reAlertCooldown = const Duration(minutes: 2),
    HandsfreeSessionService? handsfreeService,
  }) : now = clock ?? DateTime.now,
       registry = RoadEventRegistry(db),
       voiceService = voiceService ?? VoiceAlertService(),
       engine = engine ?? const PreAlertEngine(),
       _handsfreeService = handsfreeService;

  /// Optional hands-free orchestrator — when set, spoken alerts are routed
  /// through it (which pauses the mic, speaks, then resumes listening).
  final HandsfreeSessionService? _handsfreeService;
  HandsfreeSessionService? get handsfreeService => _handsfreeService;

  /// Stream of warnings that were actually issued.
  Stream<PreAlertDecision> get alertStream => _alertController.stream;

  /// The warning currently shown in the UI.
  PreAlertDecision? get activeAlert => _activeAlert;

  /// True while the service is consuming GPS fixes.
  bool get isRunning => _running;

  /// Starts GPS tracking and begins evaluating hazards.
  Future<void> start() async {
    if (_running) return;
    startupError = null;
    final service = locationService;
    if (service != null) {
      _fixSubscription = service.fixStream.listen(_onFix);
      final session = _session;
      try {
        final ready = await service.startTracking(intervalMs: 1000);
        if (session != _session) return;
        if (!ready) {
          _running = false;
          startupError = service.lastError ?? 'GPS tracking could not start.';
          await _fixSubscription?.cancel();
          _fixSubscription = null;
        } else {
          startupError = null;
          _running = true;
        }
      } catch (_) {
        if (session != _session) return;
        _running = false;
        startupError = 'GPS tracking could not start.';
        await _fixSubscription?.cancel();
        _fixSubscription = null;
      }
    } else {
      _running = true; // Explicit fix injection (replay/tests).
    }
  }

  /// Stops GPS tracking and clears the session state.
  Future<void> stop() async {
    _running = false;
    _session++;
    _previousFix = null;
    await _fixSubscription?.cancel();
    _fixSubscription = null;
    await locationService?.stopTracking();
    _alertedEventIds.clear();
    _inFlightEventIds.clear();
    _lastAttemptAt.clear();
    _lastAlertAt.clear();
    _activeAlert = null;
  }

  /// Injects a GPS fix directly (used by tests and by the trip controller).
  Future<void> handleLocationFix(LocationFix fix) => _onFix(fix);

  Future<void> _onFix(LocationFix fix) async {
    if (!_running || _evaluating) return;

    if (!LocationQuality.accepts(
      latitude: fix.latitude,
      longitude: fix.longitude,
      timestamp: fix.timestampUtc,
      now: now().toUtc(),
      accuracy: fix.gpsAccuracyM,
      speedMps: fix.gpsSpeedMps,
    ))
      return;
    final speedKmh = fix.speedKmh ?? 0.0;
    if (!speedKmh.isFinite || speedKmh <= 0) return;
    if (fix.gpsAccuracyM != null && fix.gpsAccuracyM! > 50) return;
    final session = _session;
    _evaluating = true;
    var heading = fix.gpsHeadingDeg;
    final previous = _previousFix;
    if (heading == null &&
        previous != null &&
        GeoMath.distanceMeters(
              lat1: previous.latitude,
              lon1: previous.longitude,
              lat2: fix.latitude,
              lon2: fix.longitude,
            ) >=
            5) {
      heading = GeoMath.bearingDegrees(
        lat1: previous.latitude,
        lon1: previous.longitude,
        lat2: fix.latitude,
        lon2: fix.longitude,
      );
    }
    _previousFix = fix;
    // Rearm after leaving a location and returning later, including in one trip.
    for (final id in _alertedEventIds.toList()) {
      final at = _lastAlertAt[id];
      if (at != null && fix.timestampUtc.difference(at) >= reAlertCooldown) {
        _alertedEventIds.remove(id);
      }
    }

    try {
      final candidates = await registry.loadCandidates(
        latitude: fix.latitude,
        longitude: fix.longitude,
        radiusMeters: engine.maxConsiderDistanceMeters,
      );
      if (!_running || session != _session || candidates.isEmpty) return;

      final decision = engine.evaluate(
        latitude: fix.latitude,
        longitude: fix.longitude,
        speedKmh: speedKmh,
        candidates: candidates,
        alreadyAlertedIds: _alertedEventIds,
        headingDeg: heading,
        evaluatedAtUtc: now().toUtc(),
      );
      if (decision == null) return;

      if (!decision.shouldSpeak) {
        _activeAlert = decision;
        return;
      }

      final roadEventId = decision.candidate.id;
      if (roadEventId != null) {
        if (_inFlightEventIds.contains(roadEventId)) return;
        final lastDelivered = _lastAlertAt[roadEventId];
        if (lastDelivered != null &&
            fix.timestampUtc.difference(lastDelivered) < reAlertCooldown)
          return;
        final lastAttempt = _lastAttemptAt[roadEventId];
        if (lastAttempt != null &&
            fix.timestampUtc.difference(lastAttempt) <
                const Duration(seconds: 5))
          return;
        _inFlightEventIds.add(roadEventId);
        _lastAttemptAt[roadEventId] = fix.timestampUtc;
      }
      try {
        await issueAlert(decision);
      } finally {
        if (roadEventId != null) _inFlightEventIds.remove(roadEventId);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PreAlertService: evaluation failed ($e)');
      }
    } finally {
      _evaluating = false;
    }
  }

  /// Speaks the warning and records it in the audit log.
  ///
  /// Returns the persisted `pre_alerts` row id, or null when the warning
  /// could not be persisted.
  Future<int?> issueAlert(PreAlertDecision decision) async {
    final message = _messageFor(decision);
    var spokenMessage = message;
    final isStillRelevant = () => _remainingMeters(decision) > 0;
    final roadEventId = decision.candidate.id;
    int? rowId;
    try {
      rowId = await db
          .into(db.preAlerts)
          .insert(
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
              alertedAtUtc: now().toUtc(),
              deliveryStatus: const Value('queued'),
            ),
          );
    } catch (error) {
      lastDeliveryError = 'Could not record warning attempt: $error';
      if (kDebugMode)
        debugPrint('PreAlertService: failed to create delivery log ($error)');
    }

    var delivery = 'failed';
    String? failure;
    try {
      final hf = _handsfreeService;
      if (hf != null && hf.state.mode != HandsfreeMode.off) {
        delivery = await hf
            .announcePreAlert(decision)
            .timeout(const Duration(seconds: 20), onTimeout: () => 'failed');
      } else {
        final success = await voiceService
            .speak(
              message,
              pitch: decision.urgency == PreAlertUrgency.imminent ? 1.1 : 1.0,
              hapticFallback: decision.urgency == PreAlertUrgency.imminent,
              shouldSpeak: isStillRelevant,
              textProvider: () {
                spokenMessage = _messageFor(decision);
                return spokenMessage;
              },
            )
            .timeout(const Duration(seconds: 20), onTimeout: () => false);
        delivery = success
            ? 'delivered'
            : isStillRelevant()
            ? 'failed'
            : 'expired';
      }
    } catch (error) {
      failure = error.toString();
      delivery = 'failed';
    }

    if (delivery == 'expired' || delivery == 'cancelled') {
      failure = delivery == 'expired'
          ? 'Warning expired before playback.'
          : 'Warning was cancelled before playback.';
    } else if (delivery == 'failed' && failure == null) {
      failure = 'Speech playback did not complete successfully.';
    }

    var deliveryLogged = rowId == null;
    if (rowId != null) {
      try {
        await (db.update(
          db.preAlerts,
        )..where((t) => t.id.equals(rowId!))).write(
          PreAlertsCompanion(
            spokenText: Value(spokenMessage),
            deliveryStatus: Value(delivery),
            deliveredAtUtc: Value(
              delivery == 'delivered' ? now().toUtc() : null,
            ),
            deliveryFailure: Value(failure),
          ),
        );
        deliveryLogged = true;
      } catch (error) {
        lastDeliveryError =
            'Speech $delivery, but its delivery status could not be saved: $error';
        if (kDebugMode) {
          debugPrint('PreAlertService: failed to update delivery log ($error)');
        }
      }
    }
    if (delivery == 'delivered') {
      if (deliveryLogged) lastDeliveryError = null;
      _activeAlert = decision;
      if (roadEventId != null) {
        _lastAlertAt[roadEventId] = decision.evaluatedAtUtc ?? now().toUtc();
        _alertedEventIds.add(roadEventId);
        await registry.incrementAlertCount(roadEventId, at: now().toUtc());
      }
      if (!_alertController.isClosed) _alertController.add(decision);
    } else {
      lastDeliveryError = failure;
      if (kDebugMode)
        debugPrint('PreAlertService: warning $delivery ($failure)');
    }
    return rowId;
  }

  double _remainingMeters(PreAlertDecision decision) {
    final evaluated = decision.evaluatedAtUtc;
    final age = evaluated == null
        ? 0.0
        : now().toUtc().difference(evaluated).inMilliseconds / 1000.0;
    if (age < -2 || age > 90) return 0;
    return decision.distanceMeters - decision.speedKmh / 3.6 * age;
  }

  String _messageFor(PreAlertDecision decision) => PreAlertMessageBuilder.build(
    decision,
    distanceOverride: _remainingMeters(decision),
  );

  int? _activeTripId;
  int? get activeTripId => _activeTripId;

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
      ..where((t) => t.deliveryStatus.equals('delivered'))
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.alertedAtUtc, mode: OrderingMode.desc),
      ])
      ..limit(1);

    final effectiveTripId = tripId ?? _activeTripId;
    if (effectiveTripId != null) {
      query = query..where((t) => t.tripId.equals(effectiveTripId));
    }
    if (within != null) {
      query = query
        ..where(
          (t) => t.alertedAtUtc.isBiggerOrEqualValue(
            now().toUtc().subtract(within),
          ),
        );
    }

    return query.getSingleOrNull();
  }

  /// Links a completed labeled event to the warning that preceded it.
  Future<void> linkEventToPreAlert(int eventId) async {
    final alert = await findMostRecentPreAlert(
      within: const Duration(minutes: 10),
    );
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
