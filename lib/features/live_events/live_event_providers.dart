import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database.dart';
import '../../providers/db_providers.dart';
import 'live_event_repository.dart';

final liveEventRepositoryProvider = Provider((ref) =>
    LiveEventRepository(ref.watch(appDatabaseProvider)));
final tripLiveEventsProvider = StreamProvider.autoDispose.family<List<LiveEventReview>, int>(
    (ref, tripId) => ref.watch(liveEventRepositoryProvider).watchTrip(tripId));

final allLiveEventReviewsProvider = StreamProvider((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.liveEventReviews).watch();
});
