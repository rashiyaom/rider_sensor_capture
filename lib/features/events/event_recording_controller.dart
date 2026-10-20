import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/services/rider_feedback_service.dart';
import '../../data/local_db/database.dart';
import '../../data/models/event_parameters.dart';
import '../../prealert/pre_alert_engine.dart';
import '../../providers/db_providers.dart';
import '../../providers/pre_alert_providers.dart';
import '../../voice/voice_command_config.dart';
import '../trips/trip_controller.dart';
import 'parameter_engine.dart';

enum RecordingState {
  idle,
  listening,
  recording,
  halted,
  saved,
}

/// Telemetry of the predictive pre-alert that preceded a completed event.
///
/// It is handed to the post-event feedback prompt so the LLM evaluator can
/// judge whether the warning arrived at the right moment.
class PreAlertContext {
  final int? preAlertId;
  final int? roadEventId;
  final double? timeToEventSeconds;
  final double? distanceMeters;
  final double? speedKmh;
  final double? recommendedSpeedKmh;

  const PreAlertContext({
    this.preAlertId,
    this.roadEventId,
    this.timeToEventSeconds,
    this.distanceMeters,
    this.speedKmh,
    this.recommendedSpeedKmh,
  });

  static const PreAlertContext empty = PreAlertContext();
}

class EventRecordingSessionState {
  final RecordingState state;
  final EventType? currentEventType;
  final String? triggerPhrase;
  final int? activeEventId;
  final int? tripId;
  final DateTime? startTime;
  final Duration elapsed;
  final Position? startGps;
  final Position? endGps;
  final String lastRecognizedWords;
  final String statusMessage;
  final EventParameters? lastComputedParameters;

  /// The predictive pre-alert that preceded the last saved event.
  final PreAlertContext lastPreAlertContext;

  const EventRecordingSessionState({
    this.state = RecordingState.idle,
    this.currentEventType,
    this.triggerPhrase,
    this.activeEventId,
    this.tripId,
    this.startTime,
    this.elapsed = Duration.zero,
    this.startGps,
    this.endGps,
    this.lastRecognizedWords = '',
    this.statusMessage = 'Voice listener ready',
    this.lastComputedParameters,
    this.lastPreAlertContext = PreAlertContext.empty,
  });

  EventRecordingSessionState copyWith({
    RecordingState? state,
    EventType? currentEventType,
    String? triggerPhrase,
    int? activeEventId,
    int? tripId,
    DateTime? startTime,
    Duration? elapsed,
    Position? startGps,
    Position? endGps,
    String? lastRecognizedWords,
    String? statusMessage,
    EventParameters? lastComputedParameters,
    PreAlertContext? lastPreAlertContext,
  }) {
    return EventRecordingSessionState(
      state: state ?? this.state,
      currentEventType: currentEventType ?? this.currentEventType,
      triggerPhrase: triggerPhrase ?? this.triggerPhrase,
      activeEventId: activeEventId ?? this.activeEventId,
      tripId: tripId ?? this.tripId,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
      startGps: startGps ?? this.startGps,
      endGps: endGps ?? this.endGps,
      lastRecognizedWords: lastRecognizedWords ?? this.lastRecognizedWords,
      statusMessage: statusMessage ?? this.statusMessage,
      lastComputedParameters: lastComputedParameters ?? this.lastComputedParameters,
      lastPreAlertContext: lastPreAlertContext ?? this.lastPreAlertContext,
    );
  }
}

class EventRecordingController extends StateNotifier<EventRecordingSessionState> {
  final Ref ref;

  Timer? _elapsedTimer;
  Timer? _autoHaltTimer;
  Timer? _savedResetTimer;
  Future<void> _eventOperation = Future.value();

  Future<void> _serialize(Future<void> Function() operation) {
    final task = _eventOperation.then((_) async {
      if (mounted) await operation();
    });
    _eventOperation = task.catchError((Object error) {});
    return task;
  }

  static const Duration maxRecordingDuration = Duration(seconds: 60);

  EventRecordingController(this.ref) : super(const EventRecordingSessionState(statusMessage: 'Ready to mark event'));

  Future<void> startEvent(EventType type, {String? triggerPhrase}) =>
      _serialize(() async {
        await _stopAndSaveEvent(reason: 'Next event');
        await _startEvent(type, triggerPhrase: triggerPhrase);
      });

  Future<void> _startEvent(EventType type, {String? triggerPhrase}) async {
    _savedResetTimer?.cancel();
    final repo = ref.read(sensorRepositoryProvider);
    final now = DateTime.now().toUtc();

    Position? startPos;
    try {
      startPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 2),
        ),
      );
    } catch (_) {}

    final currentTripId = repo.activeTripId;
    final companion = EventRecordsCompanion.insert(
      eventType: type.name,
      startTimestamp: now,
      startGpsLat: drift.Value(startPos?.latitude),
      startGpsLng: drift.Value(startPos?.longitude),
      status: 'active',
      triggerPhrase: drift.Value(triggerPhrase ?? 'manual'),
      tripId: drift.Value(currentTripId),
    );

    final eventId = await repo.createEventRecord(companion);
    repo.setActiveEventId(eventId);
    unawaited(RiderFeedbackService.onEventStarted());

    state = state.copyWith(
      state: RecordingState.recording,
      currentEventType: type,
      triggerPhrase: triggerPhrase ?? 'manual',
      activeEventId: eventId,
      tripId: currentTripId,
      startTime: now,
      elapsed: Duration.zero,
      startGps: startPos,
      statusMessage: 'RECORDING ${type.name.toUpperCase()}...',
    );

    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.startTime != null) {
        state = state.copyWith(
          elapsed: DateTime.now().toUtc().difference(state.startTime!),
        );
      }
    });

    _autoHaltTimer?.cancel();
    _autoHaltTimer = Timer(maxRecordingDuration, () {
      if (state.state == RecordingState.recording) {
        stopAndSaveEvent(reason: 'Max duration reached (60s)');
      }
    });
  }

  Future<void> stopAndSaveEvent({String reason = 'Manual stop'}) =>
      _serialize(() => _stopAndSaveEvent(reason: reason));

  Future<void> _stopAndSaveEvent({String reason = 'Manual stop'}) async {
    if (state.state != RecordingState.recording) return;

    _elapsedTimer?.cancel();
    _autoHaltTimer?.cancel();
    unawaited(RiderFeedbackService.onEventStopped());

    final activeId = state.activeEventId;
    final eventTypeStr = state.currentEventType?.name ?? 'unknown';
    final repo = ref.read(sensorRepositoryProvider);
    final now = DateTime.now().toUtc();

    state = state.copyWith(
      state: RecordingState.halted,
      statusMessage: 'Computing parameters ($reason)...',
    );

    // Detach active event id from incoming stream
    repo.setActiveEventId(null);

    Position? endPos;
    try {
      endPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 2),
        ),
      );
    } catch (_) {}

    // Compute parameters from tagged readings window
    EventParameters computedParams = const EventParameters();
    double? peakVal;
    String? classVal;
    var preAlertContext = PreAlertContext.empty;

    if (activeId != null) {
      // Brief delay to allow buffered readings in repository to finish flushing
      await Future.delayed(const Duration(milliseconds: 300));
      final readings = await repo.watchReadingsForEvent(activeId).first;
      computedParams = ParameterEngine.computeEventParameters(
        eventType: eventTypeStr,
        readings: readings,
      );

      if (computedParams.bump != null) {
        peakVal = computedParams.bump!.peakGForce;
        classVal = computedParams.bump!.severity;
      } else if (computedParams.turn != null) {
        peakVal = computedParams.turn!.peakLateralAccel;
        classVal = computedParams.turn!.classification;
      } else if (computedParams.speed != null) {
        peakVal = computedParams.speed!.peakSpeedKmh;
        classVal = computedParams.speed!.isBraking ? 'braking' : 'acceleration';
      }

      final updatedEvent = EventRecord(
        id: activeId,
        tripId: state.tripId ?? repo.activeTripId,
        eventType: eventTypeStr,
        startTimestamp: state.startTime ?? now,
        endTimestamp: now,
        startGpsLat: state.startGps?.latitude,
        startGpsLng: state.startGps?.longitude,
        endGpsLat: endPos?.latitude,
        endGpsLng: endPos?.longitude,
        status: 'completed',
        triggerPhrase: state.triggerPhrase,
        computedParameters: computedParams.toJsonString(),
        peakMetric: peakVal,
        classification: classVal,
        crossConfirmed: computedParams.crossConfirmed,
        forkFootLagMs: computedParams.forkFootLagMs,
        hrSpikeConfirmed: computedParams.hrSpikeConfirmed,
        hrDeltaAtEvent: computedParams.hrDeltaAtEvent,
        jerkPeakMagnitude: computedParams.bump?.jerkPeakMagnitude ?? computedParams.speed?.jerkPeakMagnitude,
        gpsSpeedAtEventKmh: computedParams.gpsSpeedKmh,
        gpsHeadingChangeDeg: computedParams.turn?.gpsHeadingDeltaDeg,
      );

      await repo.updateEventRecord(updatedEvent);
      try {
        ref.read(tripControllerProvider.notifier).incrementEvents(1);
      } catch (_) {}

      // ── Predictive pre-alert learning loop ──
      // Link the warning that preceded this event, then register the event as
      // a geo-tagged hazard so the rider is warned about it next time.
      preAlertContext = await _linkPreAlert(activeId);
      await _registerRoadEvent(
        eventId: activeId,
        eventType: eventTypeStr,
        startLat: state.startGps?.latitude,
        startLng: state.startGps?.longitude,
        computedParams: computedParams,
      );
    }

    state = state.copyWith(
      state: RecordingState.saved,
      endGps: endPos,
      lastComputedParameters: computedParams,
      lastPreAlertContext: preAlertContext,
      statusMessage: 'Saved #$activeId: ${computedParams.summary}',
    );

    _savedResetTimer?.cancel();
    _savedResetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && state.state == RecordingState.saved && state.activeEventId == activeId) {
        state = state.copyWith(
          state: RecordingState.idle,
          statusMessage: 'Ready to mark event',
        );
      }
    });
  }

  @override
  void dispose() {
    _savedResetTimer?.cancel();
    _elapsedTimer?.cancel();
    _autoHaltTimer?.cancel();
    super.dispose();
  }

  /// Links the predictive pre-alert (if any) that preceded this event and
  /// returns the telemetry that the feedback evaluator needs.
  Future<PreAlertContext> _linkPreAlert(int eventId) async {
    try {
      final service = ref.read(preAlertServiceProvider);
      final alert = await service.findMostRecentPreAlert(
        within: const Duration(minutes: 10),
      );
      if (alert == null) return PreAlertContext.empty;

      await service.linkEventToPreAlert(eventId);

      return PreAlertContext(
        preAlertId: alert.id,
        roadEventId: alert.roadEventId,
        timeToEventSeconds: alert.timeToEventSeconds,
        distanceMeters: alert.distanceMeters,
        speedKmh: alert.speedKmh,
        recommendedSpeedKmh: alert.recommendedSpeedKmh,
      );
    } catch (_) {
      return PreAlertContext.empty;
    }
  }

  /// Registers the completed event as a geo-tagged hazard so the rider gets a
  /// predictive pre-alert the next time they approach the same spot.
  Future<void> _registerRoadEvent({
    required int eventId,
    required String eventType,
    required double? startLat,
    required double? startLng,
    required EventParameters computedParams,
  }) async {
    if (startLat == null || startLng == null) return;

    // Ignore generic / user-defined labels — only real road events become
    // hazards that the pre-alert system will warn about.
    final kind = RoadEventKind.fromString(eventType);
    if (kind == RoadEventKind.unknown) return;

    double severity = 0.5;
    if (computedParams.bump != null) {
      severity = (computedParams.bump!.peakGForce / 3.0).clamp(0.2, 1.0);
    } else if (computedParams.turn != null) {
      severity = (computedParams.turn!.peakLateralAccel / 8.0).clamp(0.2, 1.0);
    } else if (computedParams.speed != null) {
      severity = computedParams.speed!.isBraking ? 0.7 : 0.4;
    }

    try {
      final service = ref.read(preAlertServiceProvider);
      await service.registerDetectedRoadEvent(
        kind: kind,
        latitude: startLat,
        longitude: startLng,
        severity: severity,
        confidence: computedParams.crossConfirmed ? 0.9 : 0.7,
        source: 'voice',
        speedKmhAtDetection: computedParams.gpsSpeedKmh,
        note: 'Labeled event #$eventId',
      );
    } catch (_) {}
  }
}

final eventRecordingControllerProvider =
    StateNotifierProvider<EventRecordingController, EventRecordingSessionState>((ref) {
  return EventRecordingController(ref);
});

final allEventRecordsStreamProvider = StreamProvider<List<EventRecord>>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.watchAllEvents();
});
