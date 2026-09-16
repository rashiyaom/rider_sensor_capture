import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ble_connection_manager.dart';
import '../../providers/battery_providers.dart';
import '../../features/trips/trip_controller.dart';
import '../../features/events/event_recording_controller.dart';
import '../../voice/voice_command_config.dart';

class WatchBatteryInfo {
  final int batteryPercent;
  final bool isCharging;
  final int millivolts;

  const WatchBatteryInfo({
    this.batteryPercent = 100,
    this.isCharging = false,
    this.millivolts = 4150,
  });
}

class WatchSyncService {
  final BleConnectionManager _bleManager;
  final Ref _ref;

  StreamSubscription<List<int>>? _watchCommandSub;
  Timer? _periodicTelemetryTimer;

  WatchBatteryInfo _watchBattery = const WatchBatteryInfo();
  final _watchBatteryController = StreamController<WatchBatteryInfo>.broadcast();
  Stream<WatchBatteryInfo> get watchBatteryStream => _watchBatteryController.stream;
  WatchBatteryInfo get currentWatchBattery => _watchBattery;

  int _latestHeartRate = 0;

  WatchSyncService(this._bleManager, this._ref) {
    _initSubscriptions();
    _startPeriodicTelemetry();
  }

  void _initSubscriptions() {
    // 1. Listen for watch-to-phone commands (from 0xFFE3 characteristic)
    _watchCommandSub = _bleManager.watchCommandStream.listen(_handleWatchCommand);

    // 2. Track latest Heart Rate from Polar / BLE stream
    _bleManager.rawDataStream.listen((data) {
      if (data.heartRate != null && data.heartRate! > 0) {
        _latestHeartRate = data.heartRate!;
      }
    });

    // 3. Listen for phone trip state changes to mirror on watch immediately
    _ref.listen<TripState>(tripControllerProvider, (previous, next) {
      if (previous?.isJourneyActive != next.isJourneyActive) {
        sendTripStateToWatch(next.isJourneyActive, tripName: 'Ride Session');
      }
    });

    // 4. Listen for phone event changes (e.g. voice trigger) to mirror on watch immediately
    _ref.listen<EventRecordingSessionState>(eventRecordingControllerProvider, (previous, next) {
      if (previous?.currentEventType != next.currentEventType ||
          previous?.state != next.state) {
        if (next.state == RecordingState.recording && next.currentEventType != null) {
          int classId = 1;
          String name = 'Bump';
          if (next.currentEventType == EventType.turn) {
            classId = 2;
            name = 'Turn';
          } else if (next.currentEventType == EventType.speedTest) {
            classId = 3;
            name = 'Speed';
          }
          sendEventTagToWatch(classId, name);
        } else if (next.state == RecordingState.idle || next.state == RecordingState.halted) {
          sendEventTagToWatch(0, 'Normal');
        }
      }
    });
  }

  void _handleWatchCommand(List<int> bytes) {
    if (bytes.isEmpty) return;
    final opcode = bytes[0];

    switch (opcode) {
      case 0x10: // Trip Toggle
        final tripNotifier = _ref.read(tripControllerProvider.notifier);
        final isCurrentlyActive = _ref.read(tripControllerProvider).isJourneyActive;
        final requestedAction = bytes.length > 1 ? bytes[1] : (isCurrentlyActive ? 0 : 1);

        if (requestedAction == 1 && !isCurrentlyActive) {
          tripNotifier.startJourney();
        } else if (requestedAction == 0 && isCurrentlyActive) {
          tripNotifier.endJourney();
        }
        break;

      case 0x11: // Event Trigger from Watch Glove Buttons
        if (bytes.length >= 3) {
          final classId = (bytes[1] << 8) | bytes[2];
          String name = 'Watch Event';
          if (bytes.length >= 4) {
            final nameLen = bytes[3];
            if (bytes.length >= 4 + nameLen) {
              name = utf8.decode(bytes.sublist(4, 4 + nameLen), allowMalformed: true);
            }
          }

          final eventController = _ref.read(eventRecordingControllerProvider.notifier);
          if (classId == 4) {
            // Halt / Stop current event
            eventController.stopAndSaveEvent(reason: 'Watch Halt Action');
          } else {
            EventType type = EventType.bump;
            if (classId == 2) type = EventType.turn;
            if (classId == 3) type = EventType.speedTest;

            eventController.startEvent(type, triggerPhrase: 'Watch $name');
          }
        }
        break;

      case 0x12: // Export Request from Watch
        // Watch requested data export
        break;

      case 0x13: // Watch Battery Status
        if (bytes.length >= 3) {
          final pct = bytes[1];
          final isCharging = bytes[2] == 1;
          int mv = 4150;
          if (bytes.length >= 5) {
            mv = (bytes[3] << 8) | bytes[4];
          }
          _watchBattery = WatchBatteryInfo(
            batteryPercent: pct,
            isCharging: isCharging,
            millivolts: mv,
          );
          _watchBatteryController.add(_watchBattery);
        }
        break;

      default:
        break;
    }
  }

  void _startPeriodicTelemetry() {
    _periodicTelemetryTimer?.cancel();
    _periodicTelemetryTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (!_bleManager.isWatchConnected) return;

      final tripState = _ref.read(tripControllerProvider);
      final batteryInfo = _ref.read(batteryServiceProvider).currentInfo;

      // 1. Send live GPS & sensor telemetry to watch
      sendTelemetryToWatch(
        speedKmh: tripState.currentSpeedKmh,
        distanceMeters: tripState.distanceMeters,
        heartRate: _latestHeartRate,
        gpsLocked: tripState.currentPosition != null,
        satellites: tripState.currentPosition != null ? 8 : 0,
      );

      // 2. Send phone battery level & charging state
      sendPhoneBatteryToWatch(
        batteryPercent: batteryInfo.batteryLevel,
        isCharging: batteryInfo.isCharging,
      );
    });
  }

  /// Sends Opcode 0x01: Trip Control
  Future<void> sendTripStateToWatch(bool isStarting, {String tripName = 'Ride Session'}) async {
    final nameBytes = utf8.encode(tripName);
    final packet = Uint8List(4 + nameBytes.length);
    packet[0] = 0x01; // Opcode TripControl
    packet[1] = isStarting ? 1 : 0;
    packet[2] = 0;
    packet[3] = nameBytes.length;
    packet.setRange(4, 4 + nameBytes.length, nameBytes);

    await _bleManager.writeToWatch(packet);
  }

  /// Sends Opcode 0x02: Event Tag Confirmation
  Future<void> sendEventTagToWatch(int classId, String eventName) async {
    final nameBytes = utf8.encode(eventName);
    final packet = Uint8List(4 + nameBytes.length);
    packet[0] = 0x02; // Opcode EventTag
    packet[1] = (classId >> 8) & 0xFF;
    packet[2] = classId & 0xFF;
    packet[3] = nameBytes.length;
    packet.setRange(4, 4 + nameBytes.length, nameBytes);

    await _bleManager.writeToWatch(packet);
  }

  /// Sends Opcode 0x03: Telemetry (Speed, Distance, HR, GPS)
  Future<void> sendTelemetryToWatch({
    required double speedKmh,
    required double distanceMeters,
    required int heartRate,
    required bool gpsLocked,
    required int satellites,
  }) async {
    final packet = Uint8List(9);
    final byteData = ByteData.sublistView(packet);

    byteData.setUint8(0, 0x03); // Opcode Telemetry

    // Speed in km/h * 10 (uint16 big endian)
    final speedRaw = (speedKmh * 10).clamp(0, 65535).toInt();
    byteData.setUint16(1, speedRaw, Endian.big);

    // Distance in meters (uint32 big endian)
    final distRaw = distanceMeters.clamp(0, 4294967295).toInt();
    byteData.setUint32(3, distRaw, Endian.big);

    // Heart Rate BPM (uint8)
    byteData.setUint8(7, heartRate.clamp(0, 255));

    // GPS flags (bit 0 = locked, bits 1..7 = satellites)
    int gpsFlags = gpsLocked ? 0x01 : 0x00;
    gpsFlags |= ((satellites.clamp(0, 127)) << 1);
    byteData.setUint8(8, gpsFlags);

    await _bleManager.writeToWatch(packet);
  }

  /// Sends Opcode 0x04: Time Sync
  Future<void> sendTimeSyncToWatch() async {
    final now = DateTime.now();
    final epochSec = now.toUtc().millisecondsSinceEpoch ~/ 1000;
    final tzOffsetMin = now.timeZoneOffset.inMinutes;

    final packet = Uint8List(7);
    final byteData = ByteData.sublistView(packet);

    byteData.setUint8(0, 0x04); // Opcode TimeSync
    byteData.setUint32(1, epochSec, Endian.big);
    byteData.setInt16(5, tzOffsetMin, Endian.big);

    await _bleManager.writeToWatch(packet);
  }

  /// Sends Opcode 0x05: Phone Battery Status
  Future<void> sendPhoneBatteryToWatch({
    required int batteryPercent,
    required bool isCharging,
  }) async {
    final packet = Uint8List(3);
    packet[0] = 0x05; // Opcode PhoneBattery
    packet[1] = batteryPercent.clamp(0, 100);
    packet[2] = isCharging ? 1 : 0;

    await _bleManager.writeToWatch(packet);
  }

  void dispose() {
    _watchCommandSub?.cancel();
    _periodicTelemetryTimer?.cancel();
    _watchBatteryController.close();
  }
}
