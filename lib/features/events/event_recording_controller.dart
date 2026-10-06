import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/services/rider_feedback_service.dart';
import '../../data/local_db/database.dart';
import '../../data/models/event_parameters.dart';
import '../../providers/db_providers.dart';
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
    );
  }
}

class EventRecordingController extends StateNotifier<EventRecordingSessionState> {
  final Ref ref;

  Timer? _elapsedTimer;
  Timer? _autoHaltTimer;

  static const Duration maxRecordingDuration = Duration(seconds: 60);

  EventRecordingController(this.ref) : super(const EventRecordingSessionState(statusMessage: 'Ready to mark event'));

  Future<void> startEvent(EventType type, {String? triggerPhrase}) async {
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
        stopAndSaveEvent(reason: 'Max duration reached (30s)');
      }
    });
  }

  Future<void> stopAndSaveEvent({String reason = 'Manual stop'}) async {
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
    }

    state = state.copyWith(
      state: RecordingState.saved,
      endGps: endPos,
      lastComputedParameters: computedParams,
      statusMessage: 'Saved #$activeId: ${computedParams.summary}',
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        state = state.copyWith(
          state: RecordingState.idle,
          statusMessage: 'Ready to mark event',
        );
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _autoHaltTimer?.cancel();
    super.dispose();
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
