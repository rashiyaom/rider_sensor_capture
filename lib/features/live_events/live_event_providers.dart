import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/crowd_event_report_repository.dart';
import '../../data/repositories/firebase_crowd_event_sync_service.dart';
import '../../data/local_db/database.dart';
import '../../providers/db_providers.dart';
import 'live_event_repository.dart';

final liveEventRepositoryProvider = Provider(
  (ref) => LiveEventRepository(ref.watch(appDatabaseProvider)),
);
final tripLiveEventsProvider = StreamProvider.autoDispose
    .family<List<LiveEventReview>, int>(
      (ref, tripId) => ref.watch(liveEventRepositoryProvider).watchTrip(tripId),
    );

final allLiveEventReviewsProvider = StreamProvider((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.liveEventReviews).watch();
});

final crowdEventReportRepositoryProvider = Provider(
  (ref) => CrowdEventReportRepository(ref.watch(appDatabaseProvider)),
);
final crowdEventReportsForOwnerProvider = StreamProvider.family((
  ref,
  String ownerUid,
) {
  return ref.watch(crowdEventReportRepositoryProvider).watchForOwner(ownerUid);
});
final crowdEventSyncServiceProvider = Provider(
  (ref) => FirebaseCrowdEventSyncService(
    local: ref.watch(crowdEventReportRepositoryProvider),
  ),
);
