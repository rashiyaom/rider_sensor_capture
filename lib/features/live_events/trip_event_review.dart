import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database.dart';
import '../../prealert/pre_alert_engine.dart';
import 'live_event_providers.dart';

class TripEventReview extends ConsumerStatefulWidget {
  final int tripId;
  final bool tripEnded;
  const TripEventReview({super.key, required this.tripId, required this.tripEnded});
  @override
  ConsumerState<TripEventReview> createState() => _TripEventReviewState();
}

class _TripEventReviewState extends ConsumerState<TripEventReview> {
  final Set<int> _saving = {};

  Future<void> _decide(LiveEventReview event, bool save) async {
    setState(() => _saving.add(event.id));
    try {
      final repo = ref.read(liveEventRepositoryProvider);
      if (save) { await repo.saveLocation(event.id); }
      else { await repo.discard(event.id); }
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your choice: $e'))); }
    } finally {
      if (mounted) setState(() => _saving.remove(event.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(tripLiveEventsProvider(widget.tripId)).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Text('Could not load detected events. Reopen this journey to retry.'),
      data: (events) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total detected events: ${events.length}',
          style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(widget.tripEnded
          ? 'Review your replies and choose which locations should give future alerts.'
          : 'Events are saved as you ride. Review their locations when the journey ends.'),
        if (events.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('No sensor events detected during this journey.')),
        for (final event in events) _eventCard(context, event),
      ]),
    );
  }

  Widget _eventCard(BuildContext context, LiveEventReview event) {
    final kind = RoadEventKind.fromString(event.eventType);
    final hasLocation = event.latitude != null && event.longitude != null;
    final canSave = hasLocation && event.confirmed != false && kind != RoadEventKind.unknown;
    final label = event.eventType == 'acceleration' ? 'Acceleration' : kind.label;
    return Card(margin: const EdgeInsets.symmetric(vertical: 8), child: Padding(
      padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Text(TimeOfDay.fromDateTime(event.detectedAtUtc.toLocal()).format(context)),
          const SizedBox(height: 8),
          Text(hasLocation
              ? 'Coordinates: ${event.latitude!.toStringAsFixed(6)}, ${event.longitude!.toStringAsFixed(6)}'
              : 'Coordinates unavailable at detection'),
          Text('Your reply: ${event.confirmationReply ?? "No reply captured"}'),
          Text('Feedback: ${event.feedback ?? "No feedback captured"}'),
          if (event.confirmed == false) const Text('You said this was not an event.'),
          if (event.reviewStatus == 'pending' && widget.tripEnded) ...[
            const SizedBox(height: 12),
            const Text('Save this location for future alerts?'),
            if (!canSave) Text(!hasLocation ? 'A GPS coordinate is required to save an alert.'
                : event.confirmed == false ? 'Rejected detections can be discarded.'
                : 'This driving action is not a location hazard.'),
            Wrap(spacing: 12, children: [
              FilledButton(onPressed: canSave && !_saving.contains(event.id)
                  ? () => _decide(event, true) : null, child: const Text('Save location')),
              OutlinedButton(onPressed: !_saving.contains(event.id)
                  ? () => _decide(event, false) : null, child: const Text('Discard')),
            ]),
          ],
          if (event.reviewStatus == 'saved') const Text('Saved for future alerts'),
          if (event.reviewStatus == 'discarded') const Text('Discarded — no future alerts'),
        ],
      ),
    ));
  }
}

class TripEventReviewScreen extends StatelessWidget {
  final Trip trip;
  const TripEventReviewScreen({super.key, required this.trip});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Journey event review')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: TripEventReview(tripId: trip.id, tripEnded: trip.endTimeUtc != null)),
  );
}
