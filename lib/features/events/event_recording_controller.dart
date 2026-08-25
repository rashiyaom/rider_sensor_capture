import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;

import '../../data/local_db/database.dart';
import '../../data/models/event_parameters.dart';
import '../../providers/db_providers.dart';
import '../../providers/ble_providers.dart';
import '../../voice/voice_command_config.dart';
import '../../voice/voice_command_listener.dart';
import '../../ble/models/raw_sensor_data.dart';
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
  final VoiceCommandListener _voiceListener = VoiceCommandListener();

  StreamSubscription<VoiceCommandConfig>? _commandSubscription;
  StreamSubscription<String>? _wordsSubscription;
  StreamSubscription<RawSensorData>? _imuSubscription;
  Timer? _elapsedTimer;
  Timer? _autoHaltTimer;

  static const double gravityBaseline = 9.81;
  static const double motionThreshold = 1.8;
  static const Duration calmSettlingDuration = Duration(milliseconds: 2500);
  static const Duration maxRecordingDuration = Duration(seconds: 30);

  DateTime? _lastSignificantMotionTime;
  bool _hasExperiencedMotionSpike = false;

  EventRecordingController(this.ref) : super(const EventRecordingSessionState()) {
    _initVoiceSubscriptions();
    _initMotionStream();
  }

  void _initVoiceSubscriptions() {
    _commandSubscription = _voiceListener.commandStream.listen((cmd) {
      if (cmd.isHaltCommand) {
        if (state.state == RecordingState.recording) {
          stopAndSaveEvent(reason: 'Voice command ("${cmd.phrase}")');
        }
      } else {
        if (state.state == RecordingState.listening || state.state == RecordingState.idle) {
          startEvent(cmd.eventType, triggerPhrase: cmd.phrase);
        }
      }
    });

    _wordsSubscription = _voiceListener.recognizedWordsStream.listen((words) {
      state = state.copyWith(lastRecognizedWords: words);
    });
  }

  void _initMotionStream() {
    final bleManager = ref.read(bleConnectionManagerProvider);
    _imuSubscription = bleManager.rawDataStream.listen((packet) {
      if (state.state != RecordingState.recording) return;

      if (packet.accelX != null && packet.accelY != null && packet.accelZ != null) {
        final mag = math.sqrt(
          packet.accelX! * packet.accelX! +
          packet.accelY! * packet.accelY! +
          packet.accelZ! * packet.accelZ!,
        );

        final delta = (mag - gravityBaseline).abs();

        if (delta > motionThreshold) {
          _lastSignificantMotionTime = DateTime.now();
          _hasExperiencedMotionSpike = true;
        } else {
          if (_hasExperiencedMotionSpike && _lastSignificantMotionTime != null) {
            final calmElapsed = DateTime.now().difference(_lastSignificantMotionTime!);
            if (calmElapsed >= calmSettlingDuration) {
              stopAndSaveEvent(reason: 'Auto-halt: motion settled (${calmElapsed.inSeconds}s calm)');
            }
          }
        }
      }
    });
  }

  Future<void> startListening() async {
    final ok = await _voiceListener.initialize();
    if (!ok) {
      state = state.copyWith(statusMessage: 'Microphone permission needed');
      return;
    }

    await _voiceListener.startListening();
    state = state.copyWith(
      state: RecordingState.listening,
      statusMessage: 'Listening for voice commands (e.g. "start bump", "start turn")...',
    );
  }

  Future<void> stopListening() async {
    await _voiceListener.stopListening();
    if (state.state == RecordingState.listening) {
      state = state.copyWith(
        state: RecordingState.idle,
        statusMessage: 'Voice listening stopped',
      );
    }
  }

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

    final companion = EventRecordsCompanion.insert(
      eventType: type.name,
      startTimestamp: now,
      startGpsLat: drift.Value(startPos?.latitude),
      startGpsLng: drift.Value(startPos?.longitude),
      status: 'active',
      triggerPhrase: drift.Value(triggerPhrase ?? 'manual'),
    );

    final eventId = await repo.createEventRecord(companion);
    repo.setActiveEventId(eventId);

    _hasExperiencedMotionSpike = false;
    _lastSignificantMotionTime = DateTime.now();

    state = state.copyWith(
      state: RecordingState.recording,
      currentEventType: type,
      triggerPhrase: triggerPhrase ?? 'manual',
      activeEventId: eventId,
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
      );

      await repo.updateEventRecord(updatedEvent);
    }

    state = state.copyWith(
      state: RecordingState.saved,
      endGps: endPos,
      lastComputedParameters: computedParams,
      statusMessage: 'Saved #$activeId: ${computedParams.summary}',
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        startListening();
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _autoHaltTimer?.cancel();
    _commandSubscription?.cancel();
    _wordsSubscription?.cancel();
    _imuSubscription?.cancel();
    _voiceListener.dispose();
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
