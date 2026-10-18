
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';
import 'package:ride_sensor_capture/features/events/event_recording_controller.dart';
import 'package:ride_sensor_capture/providers/db_providers.dart';
import 'package:ride_sensor_capture/voice/voice_command_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('rapid phone/watch labels serialize; old saved timer cannot clear the next event', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = SensorRepositoryImpl(db);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sensorRepositoryProvider.overrideWithValue(repo),
      ],
    );
    try {
      final controller = container.read(
        eventRecordingControllerProvider.notifier,
      );
      final first = controller.startEvent(
        EventType.bump,
        triggerPhrase: 'phone',
      );
      final second = controller.startEvent(
        EventType.turn,
        triggerPhrase: 'watch',
      );
      await Future.wait([first, second]);
      final records = await repo.watchAllEvents().first;
      expect(records.length, 2);
      expect(records.where((r) => r.status == 'completed').length, 1);
      expect(
        container.read(eventRecordingControllerProvider).currentEventType,
        EventType.turn,
      );
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      expect(
        container.read(eventRecordingControllerProvider).state,
        RecordingState.recording,
      );
      await controller.stopAndSaveEvent();
      final saved = await repo.watchAllEvents().first;
      expect(saved.every((r) => r.status == 'completed'), isTrue);
    } finally {
      container.dispose();
      repo.dispose();
      await db.close();
    }
  });
}
