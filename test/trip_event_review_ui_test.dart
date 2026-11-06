import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/features/live_events/live_event_providers.dart';
import 'package:ride_sensor_capture/features/live_events/live_event_repository.dart';
import 'package:ride_sensor_capture/features/live_events/trip_event_review.dart';

class _Repo extends LiveEventRepository {
  int? saved;
  int? discarded;
  _Repo(super.db);
  @override
  Future<void> saveLocation(int id) async { saved = id; }
  @override
  Future<void> discard(int id) async { discarded = id; }
}
void main() {
  testWidgets('review shows coordinates and replies, and routes save/discard choices', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = _Repo(db);
    final row = LiveEventReview(id: 1, tripId: 4, eventType: 'bump',
      detectedAtUtc: DateTime.utc(2026), latitude: 12.97, longitude: 77.59,
      confidence: .8, sensorFeaturesJson: '{}', confirmationReply: 'yes',
      confirmed: true, feedback: 'okayish and bumpy', reviewStatus: 'pending');
    await tester.pumpWidget(ProviderScope(overrides: [
      liveEventRepositoryProvider.overrideWithValue(repo),
      tripLiveEventsProvider(4).overrideWith((ref) => Stream.value([row])),
    ], child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(
      child: TripEventReview(tripId: 4, tripEnded: true))))));
    await tester.pumpAndSettle();
    expect(find.text('Total detected events: 1'), findsOneWidget);
    expect(find.text('Coordinates: 12.970000, 77.590000'), findsOneWidget);
    expect(find.text('Your reply: yes'), findsOneWidget);
    expect(find.text('Feedback: okayish and bumpy'), findsOneWidget);
    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();
    expect(repo.saved, 1);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(repo.discarded, 1);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
