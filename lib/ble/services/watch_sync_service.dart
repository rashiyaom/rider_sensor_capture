import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ble_connection_manager.dart';
import 'watch_protocol.dart';
import '../models/raw_sensor_data.dart';
import '../models/ble_device_model.dart';
import '../../providers/battery_providers.dart';
import '../../providers/ble_providers.dart';
import '../../features/trips/trip_controller.dart';
import '../../features/events/event_recording_controller.dart';
import '../../voice/voice_command_config.dart';

class WatchBatteryInfo {
  final int batteryPercent;
  final bool isCharging;
  final int millivolts;
  const WatchBatteryInfo({
    this.batteryPercent = 255,
    this.isCharging = false,
    this.millivolts = 0,
  });
}

class WatchAppearance {
  final int face;
  final int brightness;
  const WatchAppearance({this.face = 0, this.brightness = 190});
}

class WatchPeerStatus {
  final int role;
  final bool localControl;
  final bool tripActive;
  final int recordingState;
  final bool sdReady;
  final int samplesWritten;
  final DateTime receivedAt;
  const WatchPeerStatus({
    required this.role,
    required this.localControl,
    required this.tripActive,
    required this.recordingState,
    required this.sdReady,
    required this.samplesWritten,
    required this.receivedAt,
  });
  bool get fresh => DateTime.now().difference(receivedAt).inSeconds < 15;
  String get wrist => role == 1
      ? 'Left'
      : role == 2
      ? 'Right'
      : 'Unassigned';
}

class WatchSyncService {
  final BleConnectionManager _bleManager;
  final Ref _ref;
  StreamSubscription<WatchCommand>? _watchCommandSub;
  StreamSubscription<dynamic>? _deviceSub;
  StreamSubscription<RawSensorData>? _sensorSub;
  Timer? _periodicTelemetryTimer;
  bool _disposed = false;
  bool _commandBusy = false;
  bool _sendingSnapshot = false;
  int _telemetryTick = 0;
  int _heartRate = 0;
  DateTime? _heartRateAt;
  String? _heartRateDevice;
  WatchBatteryInfo _watchBattery = const WatchBatteryInfo();
  WatchAppearance _appearance = const WatchAppearance();
  final Map<String, WatchPeerStatus> _peers = {};
  final _peerController =
      StreamController<Map<String, WatchPeerStatus>>.broadcast();
  Stream<Map<String, WatchPeerStatus>> get peerStream => _peerController.stream;
  Map<String, WatchPeerStatus> get peers => Map.unmodifiable(_peers);
  final _watchBatteryController =
      StreamController<WatchBatteryInfo>.broadcast();
  final _appearanceController = StreamController<WatchAppearance>.broadcast();
  Stream<WatchBatteryInfo> get watchBatteryStream =>
      _watchBatteryController.stream;
  Stream<WatchAppearance> get appearanceStream => _appearanceController.stream;
  WatchBatteryInfo get currentWatchBattery => _watchBattery;
  WatchAppearance get currentAppearance => _appearance;

  WatchSyncService(this._bleManager, this._ref) {
    _watchCommandSub = _bleManager.watchControlStream.listen((command) {
      unawaited(_handleWatchCommand(command.bytes, deviceId: command.deviceId));
    });
    _sensorSub = _bleManager.rawDataStream.listen((sample) {
      if (sample.heartRate != null && sample.heartRate! > 0) {
        _heartRate = sample.heartRate!;
        _heartRateAt = DateTime.now();
        _heartRateDevice = sample.deviceId;
      }
    });
    var lastReadyIds = <String>{};
    _deviceSub = _bleManager.deviceStatesStream.listen((_) {
      final readyIds = _bleManager.readyWatchIds;
      if (readyIds.difference(lastReadyIds).isNotEmpty) {
        unawaited(_initialSync());
      }
      _peers.removeWhere((id, _) => !readyIds.contains(id));
      _peerController.add(peers);
      lastReadyIds = readyIds;
    });
    _ref.listen<TripState>(tripControllerProvider, (previous, next) {
      if (previous?.isJourneyActive != next.isJourneyActive && !_commandBusy) {
        unawaited(_sendState());
      }
    });
    _ref.listen<EventRecordingSessionState>(eventRecordingControllerProvider, (
      previous,
      next,
    ) {
      if ((previous?.currentEventType != next.currentEventType ||
              previous?.state != next.state) &&
          !_commandBusy) {
        unawaited(_sendEventState());
      }
    });
    _periodicTelemetryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_disposed && _bleManager.isWatchConnected) {
        unawaited(_periodicSync());
      }
    });
    if (_bleManager.isWatchConnected) unawaited(_initialSync());
  }

  Future<void> _initialSync() async {
    await _bleManager.writeToWatch([0x0C]);
    await sendTimeSyncToWatch();
    await _sendState();
    await _sendEventState();
    await _sendLiveValues();
    await _sendBattery();
    if (_disposed) return;
    await _bleManager.writeToWatch([
      0x06,
    ]); // Request watch battery and saved appearance after CCCD subscription.
  }

  Future<void> _sendState() async {
    if (_disposed || _commandBusy) return;
    final trip = _ref.read(tripControllerProvider);
    await sendTripStateToWatch(trip.isJourneyActive, tripName: trip.riderName);
    await _bleManager.writeToWatch(WatchProtocol.elapsed(trip.elapsed));
  }

  Future<void> _sendEventState() async {
    if (_disposed || _commandBusy) return;
    final event = _ref.read(eventRecordingControllerProvider);
    int id = 0;
    String name = 'Normal';
    if (event.state == RecordingState.recording) {
      switch (event.currentEventType) {
        case EventType.bump:
          id = 1;
          name = 'Bump';
          break;
        case EventType.turn:
          id = 2;
          name = 'Turn';
          break;
        case EventType.speedTest:
          id = 3;
          name = 'Speed';
          break;
        default:
          break;
      }
    }
    await sendEventTagToWatch(id, name);
  }

  Future<void> _handleWatchCommand(
    List<int> bytes, {
    required String deviceId,
  }) async {
    if (_disposed || bytes.isEmpty) return;
    if (bytes[0] == 0x16 && bytes.length == 11 && bytes[1] >= 2) {
      _peers[deviceId] = WatchPeerStatus(
        role: bytes[2],
        localControl: bytes[3] != 0,
        tripActive: bytes[4] != 0,
        recordingState: bytes[5],
        sdReady: bytes[6] != 0,
        samplesWritten:
            (bytes[7] << 24) | (bytes[8] << 16) | (bytes[9] << 8) | bytes[10],
        receivedAt: DateTime.now(),
      );
      if (bytes[2] == 1 || bytes[2] == 2) {
        final map = _ref.read(deviceMountLocationMapProvider);
        final wrist = bytes[2] == 1 ? 'left_hand' : 'right_hand';
        if (map[deviceId] != wrist) {
          _ref.read(deviceMountLocationMapProvider.notifier).state = {
            ...map,
            deviceId: wrist,
          };
        }
      }
      _peerController.add(peers);
      return;
    }
    if (bytes[0] == 0x13 && bytes.length >= 3) {
      _watchBattery = WatchBatteryInfo(
        batteryPercent: bytes[1] <= 100 ? bytes[1] : 255,
        isCharging: bytes[2] == 1,
        millivolts: bytes.length >= 5 ? (bytes[3] << 8) | bytes[4] : 0,
      );
      _watchBatteryController.add(_watchBattery);
      return;
    }
    if (bytes[0] == 0x15 &&
        bytes.length == 3 &&
        bytes[1] <= 1 &&
        bytes[2] >= 30) {
      _appearance = WatchAppearance(face: bytes[1], brightness: bytes[2]);
      _appearanceController.add(_appearance);
      return;
    }
    if (_commandBusy || (bytes[0] != 0x10 && bytes[0] != 0x11)) return;
    // Serialize phone actions. Confirm the actual controller state after its async work.
    int? requestId;
    if (bytes[0] == 0x10 && bytes.length == 3) requestId = bytes[2];
    if (bytes[0] == 0x11 && bytes.length >= 5 && bytes.length == 5 + bytes[3]) {
      requestId = bytes.last;
    }
    bool succeeded = false;
    _commandBusy = true;
    try {
      final trip = _ref.read(tripControllerProvider);
      if (bytes[0] == 0x10 &&
          (bytes.length == 2 || bytes.length == 3) &&
          bytes[1] <= 1) {
        final controller = _ref.read(tripControllerProvider.notifier);
        if (bytes[1] == 1 && !trip.isJourneyActive) {
          await controller.startJourney();
        } else if (bytes[1] == 0 && trip.isJourneyActive) {
          await _ref
              .read(eventRecordingControllerProvider.notifier)
              .stopAndSaveEvent(reason: 'Ride ended from watch');
          await controller.endJourney();
        }
        succeeded =
            _ref.read(tripControllerProvider).isJourneyActive ==
            (bytes[1] == 1);
      } else if (bytes[0] == 0x11 &&
          bytes.length >= 4 &&
          trip.isJourneyActive) {
        final id = (bytes[1] << 8) | bytes[2];
        final length = bytes[3];
        if (id < 1 ||
            id > 4 ||
            length > 16 ||
            bytes.length != 4 + length + (requestId == null ? 0 : 1)) {
          return;
        }
        final name = utf8.decode(
          bytes.sublist(4, 4 + length),
          allowMalformed: true,
        );
        final controller = _ref.read(eventRecordingControllerProvider.notifier);
        if (id == 4) {
          await controller.stopAndSaveEvent(reason: 'Watch finish event');
        } else {
          // Save a previous label before starting another; never create overlapping windows.
          await controller.stopAndSaveEvent(reason: 'Next event from watch');
          await controller.startEvent(
            id == 2
                ? EventType.turn
                : id == 3
                ? EventType.speedTest
                : EventType.bump,
            triggerPhrase: 'Watch $name',
          );
        }
        succeeded = id == 4
            ? _ref.read(eventRecordingControllerProvider).state !=
                  RecordingState.recording
            : _ref.read(eventRecordingControllerProvider).state ==
                  RecordingState.recording;
      }
    } catch (error) {
      debugPrint('[Watch] Command failed: $error');
    } finally {
      _commandBusy = false;
      if (!_disposed) {
        await _sendState();
        await _sendEventState();
        if (requestId != null) {
          await _bleManager.writeToWatch([
            0x09,
            requestId,
            succeeded ? 0 : 1,
          ], deviceId: deviceId);
        }
      }
    }
  }

  Future<void> _sendLiveValues() async {
    if (_disposed) return;
    final trip = _ref.read(tripControllerProvider);
    final now = DateTime.now();
    final position = trip.currentPosition;
    final gpsFresh =
        trip.isJourneyActive &&
        position != null &&
        now.difference(position.timestamp).abs() < const Duration(seconds: 10);
    final hrFresh =
        _heartRateAt != null &&
        now.difference(_heartRateAt!) < const Duration(seconds: 6) &&
        _bleManager.currentDeviceStates[_heartRateDevice]?.connectionState ==
            BleConnectionState.connected;
    await sendTelemetryToWatch(
      speedKmh: gpsFresh ? trip.currentSpeedKmh : 0,
      distanceMeters: trip.distanceMeters,
      heartRate: hrFresh ? _heartRate : 0,
      gpsLocked: gpsFresh,
      satellites: 0, // The location API does not report satellite counts.
    );
  }

  Future<void> _sendBattery() async {
    if (_disposed) return;
    final battery = _ref.read(batteryServiceProvider).currentInfo;
    await sendPhoneBatteryToWatch(
      batteryPercent: battery.batteryLevel,
      isCharging: battery.isCharging,
    );
  }

  Future<void> _periodicSync() async {
    if (_sendingSnapshot) {
      return; // Do not accumulate telemetry behind a slow link.
    }
    _sendingSnapshot = true;
    try {
      await _sendLiveValues();
      _telemetryTick++;
      if (_telemetryTick % 5 == 0) {
        await _bleManager.writeToWatch([0x06]);
        await _sendState();
        await _sendEventState();
      }
      if (_telemetryTick % 15 == 0) await _sendBattery();
      if (_telemetryTick % 60 == 0) await sendTimeSyncToWatch();
    } finally {
      _sendingSnapshot = false;
    }
  }

  Future<void> sendTripStateToWatch(
    bool isStarting, {
    String tripName = 'Ride Session',
  }) async {
    for (final id in _bleManager.readyWatchIds) {
      if (_peers[id]?.localControl == true) continue;
      await _bleManager.writeToWatch(
        WatchProtocol.trip(isStarting, tripName),
        deviceId: id,
      );
    }
  }

  Future<void> sendEventTagToWatch(int classId, String eventName) async {
    for (final id in _bleManager.readyWatchIds) {
      if (_peers[id]?.localControl == true) continue;
      await _bleManager.writeToWatch(
        WatchProtocol.event(classId, eventName),
        deviceId: id,
      );
    }
  }

  Future<void> sendTelemetryToWatch({
    required double speedKmh,
    required double distanceMeters,
    required int heartRate,
    required bool gpsLocked,
    required int satellites,
  }) async {
    await _bleManager.writeToWatch(
      WatchProtocol.telemetry(
        speedKmh: speedKmh,
        distanceMeters: distanceMeters,
        heartRate: heartRate,
        gpsLocked: gpsLocked,
        satellites: satellites,
      ),
    );
  }

  Future<void> sendTimeSyncToWatch() async {
    await _bleManager.writeToWatch(WatchProtocol.time(DateTime.now()));
  }

  Future<void> sendPhoneBatteryToWatch({
    required int batteryPercent,
    required bool isCharging,
  }) async {
    await _bleManager.writeToWatch([
      0x05,
      batteryPercent < 0 ? 255 : batteryPercent.clamp(0, 100),
      isCharging ? 1 : 0,
    ]);
  }

  Future<bool> setAppearance({required int face, required int brightness}) =>
      _bleManager.writeToWatch(WatchProtocol.appearance(face, brightness));

  Future<bool> setWrist(String deviceId, int role) =>
      _bleManager.writeToWatch([0x0A, role], deviceId: deviceId);
  Future<void> usePhoneControls(String deviceId) async {
    await _bleManager.writeToWatch([0x0B], deviceId: deviceId);
    await _bleManager.writeToWatch([0x0C], deviceId: deviceId);
  }

  Future<void> repairConnection(String deviceId) async {
    await _bleManager.repairWatchConnection(deviceId);
    if (!_disposed) await _initialSync();
  }

  void dispose() {
    _disposed = true;
    _peerController.close();
    _watchCommandSub?.cancel();
    _deviceSub?.cancel();
    _sensorSub?.cancel();
    _periodicTelemetryTimer?.cancel();
    _watchBatteryController.close();
    _appearanceController.close();
  }
}
