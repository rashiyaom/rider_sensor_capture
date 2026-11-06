import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/features/events/event_recording_controller.dart';

void main() {
  test('explicit null clears event context, omitted values preserve it', () {
    final previous = EventRecordingSessionState(
      tripId: 7,
      activeEventId: 10,
      triggerPhrase: 'old',
      startTime: DateTime.utc(2026),
    );
    expect(previous.copyWith(statusMessage: 'updated').tripId, 7);
    final cleared = previous.copyWith(
      tripId: null,
      activeEventId: null,
      triggerPhrase: null,
      startTime: null,
    );
    expect(cleared.tripId, isNull);
    expect(cleared.activeEventId, isNull);
    expect(cleared.triggerPhrase, isNull);
    expect(cleared.startTime, isNull);
  });
}
