import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ride_sensor_capture/features/devices/presentation/watch_companion_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/ble/services/ble_connection_manager.dart';
import 'package:ride_sensor_capture/ble/services/watch_protocol.dart';
import 'package:ride_sensor_capture/ble/parsers/esp32_watch_parser.dart';
import 'package:ride_sensor_capture/core/services/battery_service.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/features/events/event_recording_controller.dart';
import 'package:ride_sensor_capture/features/trips/trip_controller.dart';
import 'package:ride_sensor_capture/providers/battery_providers.dart';
import 'package:ride_sensor_capture/providers/ble_providers.dart';
import 'package:ride_sensor_capture/voice/voice_command_config.dart';

class FakeBle implements BleConnectionManager {
  final commands = StreamController<List<int>>.broadcast(sync: true);
  final devices = StreamController<Map<String, BleDeviceModel>>.broadcast(
    sync: true,
  );
  final sensors = StreamController<RawSensorData>.broadcast(sync: true);
  final writes = <List<int>>[];
  final destinations = <String?>[];
  String commandSource = 'watch';
  final ids = <String>{};
  final states = <String, BleDeviceModel>{};
  @override
  Stream<List<int>> get watchCommandStream => commands.stream;
  @override
  Stream<WatchCommand> get watchControlStream =>
      commands.stream.map((bytes) => WatchCommand(commandSource, bytes));
  @override
  Stream<Map<String, BleDeviceModel>> get deviceStatesStream => devices.stream;
  @override
  Stream<RawSensorData> get rawDataStream => sensors.stream;
  @override
  Map<String, BleDeviceModel> get currentDeviceStates => states;
  @override
  Set<String> get readyWatchIds => Set.of(ids);
  @override
  bool get isWatchConnected => ids.isNotEmpty;
  @override
  Future<bool> writeToWatch(List<int> bytes, {String? deviceId}) async {
    if (!isWatchConnected) return false;
    writes.add(List.of(bytes));
    destinations.add(deviceId);
    return true;
  }

  void ready(String id) {
    ids.add(id);
    devices.add(states);
  }

  void lost() {
    ids.clear();
    devices.add(states);
  }

  @override
  void dispose() {
    commands.close();
    devices.close();
    sensors.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBattery implements BatteryService {
  @override
  BatteryInfo get currentInfo => const BatteryInfo(batteryLevel: 77);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTrip extends TripController {
  FakeTrip(super.ref);
  int starts = 0, ends = 0;
  Completer<void>? gate;
  bool fail = false;
  void phoneState(TripState value) {
    state = value;
  }

  @override
  Future<bool> startJourney({
    String? riderName,
    String wristSide = 'Both Hands',
  }) async {
    starts++;
    if (gate != null) await gate!.future;
    if (fail) throw StateError('Database unavailable');
    state = const TripState(isJourneyActive: true, riderName: 'Test rider');
    return true;
  }

  @override
  Future<Trip?> endJourney() async {
    ends++;
    state = const TripState();
    return null;
  }
}

class FakeEvents extends EventRecordingController {
  FakeEvents(super.ref);
  int starts = 0, stops = 0;
  @override
  Future<void> startEvent(EventType type, {String? triggerPhrase}) async {
    starts++;
    state = EventRecordingSessionState(
      state: RecordingState.recording,
      currentEventType: type,
    );
  }

  @override
  Future<void> stopAndSaveEvent({String reason = 'Manual stop'}) async {
    stops++;
    state = const EventRecordingSessionState(state: RecordingState.saved);
  }
}

void main() {
  group('Production companion protocol', () {
    test(
      'matches firmware golden packets and preserves UTF-8 at default MTU',
      () {
        expect(WatchProtocol.trip(true, 'Ride'), [
          1,
          1,
          0,
          4,
          82,
          105,
          100,
          101,
        ]);
        expect(WatchProtocol.event(2, 'Turn'), [2, 0, 2, 4, 84, 117, 114, 110]);
        expect(
          WatchProtocol.telemetry(
            speedKmh: 38.9,
            distanceMeters: 3450,
            heartRate: 128,
            gpsLocked: true,
          ),
          [3, 1, 133, 0, 0, 13, 122, 128, 1],
        );
        final name = WatchProtocol.trip(true, '🚲🚲🚲🚲🚲中文');
        expect(name.length, lessThanOrEqualTo(20));
        expect(utf8.decode(name.sublist(4)), '🚲🚲🚲🚲');
        expect(WatchProtocol.elapsed(const Duration(seconds: 300)), [
          8,
          0,
          0,
          1,
          44,
        ]);
        expect(WatchProtocol.appearance(1, 190), [7, 1, 190]);
      },
    );
    test('rejects nonfinite telemetry and clamps out of range readings', () {
      final packet = WatchProtocol.telemetry(
        speedKmh: double.nan,
        distanceMeters: double.infinity,
        heartRate: 999,
        gpsLocked: false,
        satellites: -1,
      );
      expect(packet, [3, 0, 0, 0, 0, 0, 0, 255, 0]);
      final time = WatchProtocol.time(DateTime.utc(2026, 10, 12));
      expect(
        ByteData.sublistView(time).getUint32(1, Endian.big),
        DateTime.utc(2026, 10, 12).millisecondsSinceEpoch ~/ 1000,
      );
    });
  });

  late FakeBle ble;
  late FakeTrip trip;
  late FakeEvents events;
  late ProviderContainer container;
  void init() {
    ble = FakeBle();
    container = ProviderContainer(
      overrides: [
        bleConnectionManagerProvider.overrideWithValue(ble),
        batteryServiceProvider.overrideWithValue(FakeBattery()),
        tripControllerProvider.overrideWith((ref) => trip = FakeTrip(ref)),
        eventRecordingControllerProvider.overrideWith(
          (ref) => events = FakeEvents(ref),
        ),
      ],
    );
    container.read(watchSyncServiceProvider);
  }

  void syncTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      init();
      try {
        await body(tester);
      } finally {
        container.dispose();
        ble.dispose();
      }
    });
  }

  syncTest(
    'syncs after discovery, a second watch, and reconnect with elapsed and events',
    (tester) async {
      trip.phoneState(
        const TripState(isJourneyActive: true, elapsed: Duration(minutes: 5)),
      );
      await events.startEvent(EventType.turn);
      ble.ready('watch-a');
      await tester.pump();
      expect(ble.writes.map((p) => p[0]), containsAll([1, 2, 3, 4, 5, 6, 8]));
      expect(ble.writes.where((p) => p[0] == 8).last, [8, 0, 0, 1, 44]);
      expect(ble.writes.where((p) => p[0] == 2).last[2], 2);
      ble.writes.clear();
      ble.ready('watch-b');
      await tester.pump();
      expect(ble.writes.map((p) => p[0]), contains(4));
      ble.lost();
      ble.writes.clear();
      ble.ready('watch-a');
      await tester.pump();
      expect(ble.writes.where((p) => p[0] == 1).last[1], 1);
    },
  );
  syncTest(
    'waits for phone completion, rejects duplicate taps, then mirrors start and stop',
    (tester) async {
      ble.ready('watch');
      await tester.pump();
      ble.writes.clear();
      trip.gate = Completer<void>();
      ble.commands.add([0x10, 1, 42]);
      ble.commands.add([0x10, 1, 42]);
      await tester.pump(const Duration(seconds: 5));
      expect(trip.starts, 1);
      expect(ble.writes.where((p) => p[0] == 1), isEmpty);
      trip.gate!.complete();
      await tester.pump();
      expect(ble.writes.where((p) => p[0] == 1).last[1], 1);
      expect(ble.writes.where((p) => p[0] == 9).last, [9, 42, 0]);
      ble.commands.add([0x10, 0]);
      await tester.pump();
      expect(trip.ends, 1);
      expect(ble.writes.where((p) => p[0] == 1).last[1], 0);
    },
  );
  syncTest('failed start sends actual idle state back to watch', (
    tester,
  ) async {
    ble.ready('watch');
    await tester.pump();
    trip.fail = true;
    ble.commands.add([0x10, 1, 7]);
    await tester.pump();
    expect(ble.writes.where((p) => p[0] == 1).last[1], 0);
    expect(ble.writes.where((p) => p[0] == 9).last, [9, 7, 1]);
  });
  syncTest(
    'event commands require a ride; save, change and finish mirror confirmed state',
    (tester) async {
      ble.ready('watch');
      await tester.pump();
      ble.commands.add([0x11, 0, 1, 4, 66, 117, 109, 112]);
      await tester.pump();
      expect(events.starts, 0);
      trip.phoneState(const TripState(isJourneyActive: true));
      ble.commands.add([0x11, 0, 1, 4, 66, 117, 109, 112]);
      await tester.pump();
      expect(events.starts, 1);
      expect(ble.writes.where((p) => p[0] == 2).last[2], 1);
      ble.commands.add([0x11, 0, 99, 0]);
      await tester.pump();
      expect(events.starts, 1);
      ble.commands.add([0x11, 0, 4, 0]);
      await tester.pump();
      expect(ble.writes.where((p) => p[0] == 2).last[2], 0);
    },
  );
  syncTest(
    'forwards live Polar HR at idle and clears it when the source disconnects',
    (tester) async {
      ble.ready('watch');
      await tester.pump();
      ble.states['polar'] = BleDeviceModel(
        id: 'polar',
        name: 'Polar',
        type: DeviceType.verityBand,
        rssi: -50,
        lastSeen: DateTime.now(),
        connectionState: BleConnectionState.connected,
      );
      ble.sensors.add(
        RawSensorData(
          deviceId: 'polar',
          deviceName: 'Polar',
          deviceType: DeviceType.verityBand,
          timestamp: DateTime.now(),
          heartRate: 143,
          rawBytes: const [],
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(ble.writes.where((p) => p[0] == 3).last[7], 143);
      expect(
        ble.writes.where((p) => p[0] == 3).last[8],
        0,
      ); // No invented GPS satellites.
      ble.states.clear();
      await tester.pump(const Duration(seconds: 1));
      expect(ble.writes.where((p) => p[0] == 3).last[7], 0);
    },
  );
  syncTest(
    'appearance changes are confirmed by watch, not optimistically applied',
    (tester) async {
      ble.ready('watch');
      await tester.pump();
      final service = container.read(watchSyncServiceProvider);
      await service.setAppearance(face: 1, brightness: 150);
      expect(service.currentAppearance.face, 0);
      ble.commands.add([0x15, 1, 150]);
      await tester.pump();
      expect(service.currentAppearance.face, 1);
      expect(service.currentAppearance.brightness, 150);
    },
  );
  syncTest(
    'companion controls fit a narrow phone and confirm a face selection',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      ble.ready('watch');
      await tester.pump();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: WatchCompanionCard()),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Ride focus'));
      await tester.pump();
      expect(ble.writes.last, [7, 1, 190]);
      ble.commands.add([0x15, 1, 190]);
      await tester.pump();
      expect(
        container.read(watchSyncServiceProvider).currentAppearance.face,
        1,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
  syncTest(
    'each wrist handshake is independent and local recordings survive phone snapshots',
    (tester) async {
      ble.ready('left');
      ble.ready('right');
      await tester.pump();
      final service = container.read(watchSyncServiceProvider);
      expect(service.peers, isEmpty);
      ble.commandSource = 'left';
      ble.commands.add([0x16, 2, 1, 1, 1, 1, 1, 0, 0, 0, 50]);
      ble.commandSource = 'right';
      ble.commands.add([0x16, 2, 2, 0, 0, 0, 1, 0, 0, 0, 0]);
      await tester.pump();
      expect(service.peers['left']!.localControl, isTrue);
      expect(service.peers['right']!.localControl, isFalse);
      expect(container.read(deviceMountLocationMapProvider), {
        'left': 'left_hand',
        'right': 'right_hand',
      });
      ble.writes.clear();
      ble.destinations.clear();
      await service.sendTripStateToWatch(false);
      expect(ble.destinations, ['right']);
      await service.setWrist('right', 2);
      expect(ble.writes.last, [0x0A, 2]);
      expect(ble.destinations.last, 'right');
    },
  );
  test('binary IMU packets containing byte 0x2C are not treated as CSV', () {
    final data = ByteData(32)
      ..setUint32(0, 44, Endian.little)
      ..setUint8(6, 1)
      ..setFloat32(7, 1.5, Endian.little)
      ..setFloat32(15, 9.81, Endian.little);
    final sample = Esp32WatchParser.parseEsp32Payload(
      'watch',
      'ESP32-Watch-LEFT',
      data.buffer.asUint8List(),
    );
    expect(sample, isNotNull);
    expect(sample!.accelX, 1.5);
    expect(sample.accelZ, closeTo(9.81, 0.001));
  });
}
