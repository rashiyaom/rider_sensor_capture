import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/db_providers.dart';
import '../../providers/pre_alert_providers.dart';
import '../../location/location_service.dart';
import '../../data/local_db/database.dart';
import '../../data/repositories/crowd_event_report_repository.dart';
import '../events/event_recording_controller.dart';
import '../prealert/presentation/seed_road_hazard_sheet.dart';
import 'event_library_repository.dart';
import 'live_event_providers.dart';
import 'shared_road_event_providers.dart';

final _liveMapFixProvider = StreamProvider<LocationFix>(
  (ref) => ref.watch(locationServiceProvider).fixStream,
);

class EventLibraryScreen extends ConsumerStatefulWidget {
  const EventLibraryScreen({super.key});
  @override
  ConsumerState<EventLibraryScreen> createState() => _EventLibraryScreenState();
}

class _EventLibraryScreenState extends ConsumerState<EventLibraryScreen>
    with WidgetsBindingObserver {
  final _map = MapController();
  String? _selected;
  String _filter = 'All';
  String _query = '';
  bool _syncingCrowdReports = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCrowdReports(showResult: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _map.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncCrowdReports(showResult: false);
    }
  }

  Future<void> _syncCrowdReports({required bool showResult}) async {
    if (_syncingCrowdReports ||
        Firebase.apps.isEmpty ||
        FirebaseAuth.instance.currentUser == null) {
      return;
    }
    setState(() => _syncingCrowdReports = true);
    try {
      final sync = ref.read(crowdEventSyncServiceProvider);
      final result = await sync.syncPendingReports();
      await sync.refreshUploadedResults();
      if (showResult && mounted) {
        final message = result.failed > 0
            ? 'Some reports are still waiting for a connection. Tap retry when online.'
            : result.uploaded > 0
            ? '${result.uploaded} report(s) uploaded; server verification status refreshed.'
            : 'No community reports are waiting to sync.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      if (showResult && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not sync community reports: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _syncingCrowdReports = false);
    }
  }

  Future<void> _edit(ManagedEvent event) async {
    final lat = TextEditingController(text: event.latitude?.toString() ?? '');
    final lon = TextEditingController(text: event.longitude?.toString() ?? '');
    final note = TextEditingController(text: event.feedback ?? '');
    final types = {
      'bump',
      'pothole',
      'turn',
      'braking',
      'hazard',
      'acceleration',
      'unknown',
      event.type,
    };
    var type = event.type;
    String? error;
    var saving = false;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: types
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: saving ? null : (v) => type = v!,
                  decoration: const InputDecoration(labelText: 'Event type'),
                ),
                TextField(
                  controller: lat,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Latitude'),
                ),
                TextField(
                  controller: lon,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Longitude'),
                ),
                TextField(
                  controller: note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Feedback / note',
                  ),
                ),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      setDialogState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        final latitude = lat.text.trim().isEmpty
                            ? null
                            : double.parse(lat.text.trim());
                        final longitude = lon.text.trim().isEmpty
                            ? null
                            : double.parse(lon.text.trim());
                        await EventLibraryRepository(
                          ref.read(appDatabaseProvider),
                        ).edit(
                          event,
                          type: type,
                          latitude: latitude,
                          longitude: longitude,
                          feedback: note.text.trim(),
                        );
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          setDialogState(() {
                            saving = false;
                            error = 'Could not save: $e';
                          });
                        }
                      }
                    },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
    // Dialog animations can still use the fields until the route is removed.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    lat.dispose();
    lon.dispose();
    note.dispose();
  }

  Future<void> _delete(ManagedEvent event) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text(
          'This removes the event and its future location alert. Trip sensor readings are retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    try {
      await EventLibraryRepository(ref.read(appDatabaseProvider)).delete(event);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not delete event: $e')));
      }
    }
  }

  Future<void> _submitCommunityReport(ManagedEvent event) async {
    final reviewId = event.reviewId;
    if (reviewId == null || Firebase.apps.isEmpty) return;
    final driver = FirebaseAuth.instance.currentUser;
    if (driver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in before submitting a community report.'),
        ),
      );
      return;
    }

    final review = await ref.read(liveEventRepositoryProvider).get(reviewId);
    if (!mounted) return;
    if (review.confirmed != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirm the event before submitting it.'),
        ),
      );
      return;
    }
    final alreadyReported = await ref
        .read(crowdEventReportRepositoryProvider)
        .hasReportForReview(reviewId);
    if (!mounted) return;
    if (alreadyReported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This event was already submitted.')),
      );
      return;
    }
    final lat = review.latitude;
    final lon = review.longitude;
    final accuracy = review.gpsAccuracyM;
    if (lat == null ||
        lon == null ||
        accuracy == null ||
        accuracy <= 0 ||
        accuracy > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A GPS fix with accuracy of 15 m or better is required.',
          ),
        ),
      );
      return;
    }

    final consent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit road impact?'),
        content: Text(
          'Share this confirmed road impact with RideSense for review? The exact location '
          '(${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}), time, GPS accuracy, '
          'and sensor evidence will be sent under your driver account. It starts as a '
          'candidate and will not appear as a verified hazard until corroborated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (consent != true || !mounted) return;

    try {
      final repository = ref.read(crowdEventReportRepositoryProvider);
      final report = await repository.queue(
        CrowdEventReportDraft(
          ownerUid: driver.uid,
          tripId: review.tripId,
          localReviewId: review.id,
          latitude: lat,
          longitude: lon,
          horizontalAccuracyM: accuracy,
          observedAtUtc: review.detectedAtUtc,
          source: 'ml',
          evidenceKind: 'imu_impact',
          evidenceConfidence: review.confidence,
          evidenceJson: review.sensorFeaturesJson,
          driverConfirmed: true,
          locationShareConsented: true,
        ),
      );
      final sync = ref.read(crowdEventSyncServiceProvider);
      final result = await sync.syncPendingReports(
        prioritizeReportKey: report.reportKey,
      );
      final reportAfterUpload = await repository.getById(report.id);
      final serverResult = reportAfterUpload.syncStatus == 'uploaded'
          ? await sync.waitForServerResult(report.reportKey)
          : null;
      if (serverResult != null) {
        await repository.applyServerOutcome(
          id: report.id,
          resultStatus: serverResult.resultStatus,
          cloudEventId: serverResult.sharedEventId,
          verificationStatus: serverResult.verificationStatus,
          reasonCode: serverResult.reasonCode,
        );
      }
      if (!mounted) return;
      final message = result.failed > 0
          ? 'Report is saved on this device. Tap the cloud button to retry when online.'
          : serverResult == null
          ? 'Report uploaded; server processing is pending.'
          : serverResult.resultStatus == 'published'
          ? 'Report ${serverResult.verificationStatus}; shared road event ${serverResult.sharedEventId}.'
          : 'Report ${serverResult.resultStatus}: ${serverResult.reasonCode ?? 'server validation failed'}.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit report: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roads = ref.watch(roadEventsStreamProvider);
    final reviews = ref.watch(allLiveEventReviewsProvider);
    final records = ref.watch(allEventRecordsStreamProvider);
    final fix =
        ref.watch(_liveMapFixProvider).value ??
        ref.watch(locationServiceProvider).currentFix;
    final viewport = fix == null
        ? null
        : (
            latitude: (fix.latitude * 100).roundToDouble() / 100,
            longitude: (fix.longitude * 100).roundToDouble() / 100,
          );
    final currentDriver = FirebaseAuth.instance.currentUser;
    final crowdReports = currentDriver == null
        ? const <CrowdEventReport>[]
        : ref
                  .watch(crowdEventReportsForOwnerProvider(currentDriver.uid))
                  .value ??
              const <CrowdEventReport>[];
    final queuedCrowdReports = crowdReports
        .where(
          (report) =>
              report.syncStatus == 'queued' ||
              report.syncStatus == 'uploading' ||
              report.syncStatus == 'failed',
        )
        .toList();
    final shared = ref.watch(sharedRoadEventsProvider(viewport));
    final sharedEvents = shared.value ?? const [];
    final events = ManagedEvent.combine(
      roads.value ?? [],
      reviews.value ?? [],
      records.value ?? [],
    );
    final filtered = events
        .where(
          (e) =>
              (_filter == 'All' ||
                  (_filter == 'Saved alerts'
                      ? e.roadId != null
                      : e.reviewId != null)) &&
              '${e.type} ${e.source} ${e.feedback ?? ''} ${e.reply ?? ''}'
                  .toLowerCase()
                  .contains(_query.toLowerCase()),
        )
        .toList();
    final points = filtered
        .where((e) => e.latitude != null && e.longitude != null)
        .toList();
    final center = fix != null
        ? LatLng(fix.latitude, fix.longitude)
        : points.isNotEmpty
        ? LatLng(points.first.latitude!, points.first.longitude!)
        : const LatLng(20.5937, 78.9629);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All events'),
        actions: [
          if (Firebase.apps.isNotEmpty)
            IconButton(
              tooltip: 'Sync community reports',
              onPressed: _syncingCrowdReports
                  ? null
                  : () => _syncCrowdReports(showResult: true),
              icon: _syncingCrowdReports
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
            ),
          IconButton(
            tooltip: 'Add location',
            icon: const Icon(Icons.add_location_alt),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const SeedRoadHazardSheet(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 240,
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: center,
                initialZoom: points.isEmpty && fix == null ? 4 : 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ride_sensor_capture',
                ),
                MarkerLayer(
                  markers: [
                    if (fix != null)
                      Marker(
                        point: LatLng(fix.latitude, fix.longitude),
                        width: 32,
                        height: 32,
                        child: const Tooltip(
                          message: 'Your current position',
                          child: Icon(Icons.my_location, color: Colors.blue),
                        ),
                      ),
                    for (final event in points)
                      Marker(
                        point: LatLng(event.latitude!, event.longitude!),
                        width: 44,
                        height: 44,
                        child: IconButton(
                          tooltip: '${event.type} · ${event.status}',
                          icon: Icon(
                            Icons.location_on,
                            color: _selected == event.key
                                ? Colors.amber
                                : event.roadId != null
                                ? Colors.red
                                : Colors.purple,
                          ),
                          onPressed: () => setState(() {
                            _selected = event.key;
                          }),
                        ),
                      ),
                    for (final event in sharedEvents)
                      Marker(
                        point: LatLng(event.latitude, event.longitude),
                        width: 46,
                        height: 46,
                        child: Tooltip(
                          message:
                              'Community road impact · ${event.status} · ${event.independentDriverCount} drivers',
                          child: IconButton(
                            icon: Icon(
                              Icons.report,
                              color: event.status == 'verified'
                                  ? Colors.green
                                  : event.status == 'corroborated'
                                  ? Colors.orange
                                  : Colors.blueGrey,
                            ),
                            onPressed: () => setState(
                              () => _selected = 'shared_${event.id}',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(3),
                      child: Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search type, feedback or source',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                IconButton(
                  tooltip: 'Your current position',
                  onPressed: fix == null
                      ? null
                      : () =>
                            _map.move(LatLng(fix.latitude, fix.longitude), 16),
                  icon: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final filter in ['All', 'Saved alerts', 'Live ride'])
                ChoiceChip(
                  label: Text(filter),
                  selected: _filter == filter,
                  onSelected: (_) => setState(() {
                    _filter = filter;
                    _selected = null;
                  }),
                ),
            ],
          ),
          if (roads.hasError || reviews.hasError || records.hasError)
            const Text(
              'Some events could not be loaded. Reopen this page to retry.',
            ),
          Text(
            '${filtered.length} personal events · ${sharedEvents.length} community events within 10 km',
          ),
          if (shared.hasError)
            const Text(
              'Community events could not be loaded. Check your connection and retry.',
            ),
          if (fix == null && Firebase.apps.isNotEmpty)
            const Text('Enable location to see nearby community events.'),
          if (queuedCrowdReports.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_off_outlined),
                title: Text(
                  '${queuedCrowdReports.length} community report(s) waiting to sync',
                ),
                subtitle: const Text(
                  'They remain on this device until the upload succeeds.',
                ),
                trailing: TextButton(
                  onPressed: _syncingCrowdReports
                      ? null
                      : () => _syncCrowdReports(showResult: true),
                  child: const Text('Retry'),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                if (crowdReports.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your community submissions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          for (final report in crowdReports)
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(_crowdStatusLabel(report)),
                              subtitle: Text(
                                report.lastSyncError ??
                                    'Observed ${report.observedAtUtc.toLocal()}',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                for (final event in [
                  ...filtered.where((e) => e.key == _selected),
                  ...filtered.where((e) => e.key != _selected),
                ])
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${event.type} · ${event.status}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('${event.source} · ${event.at.toLocal()}'),
                          Text(
                            event.latitude == null
                                ? 'No coordinate captured'
                                : '${event.latitude!.toStringAsFixed(6)}, ${event.longitude!.toStringAsFixed(6)}',
                          ),
                          if (event.reply != null)
                            Text('Your reply: ${event.reply}'),
                          if (event.feedback != null)
                            Text('Feedback: ${event.feedback}'),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: event.latitude == null
                                    ? null
                                    : () {
                                        _map.move(
                                          LatLng(
                                            event.latitude!,
                                            event.longitude!,
                                          ),
                                          17,
                                        );
                                        setState(() => _selected = event.key);
                                      },
                                child: const Text('Show on map'),
                              ),
                              TextButton(
                                onPressed: () => _edit(event),
                                child: const Text('Edit'),
                              ),
                              TextButton(
                                onPressed: () => _delete(event),
                                child: const Text('Delete'),
                              ),
                              if (event.reviewId != null &&
                                  event.status == 'pending')
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(liveEventRepositoryProvider)
                                          .saveLocation(event.reviewId!);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(content: Text('$e')),
                                            );
                                      }
                                    }
                                  },
                                  child: const Text('Save for alerts'),
                                ),
                              if (event.reviewId != null &&
                                  event.type == 'bump' &&
                                  event.status != 'Rejected' &&
                                  Firebase.apps.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () =>
                                      _submitCommunityReport(event),
                                  icon: const Icon(Icons.public),
                                  label: const Text('Submit community report'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                for (final event in sharedEvents)
                  Card(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: ListTile(
                      leading: Icon(
                        Icons.report,
                        color: event.status == 'verified'
                            ? Colors.green
                            : event.status == 'corroborated'
                            ? Colors.orange
                            : Colors.blueGrey,
                      ),
                      title: Text('Community road impact · ${event.status}'),
                      subtitle: Text(
                        '${event.independentDriverCount} independent drivers · last seen ${event.lastObservedAt.toLocal()}\n${event.latitude.toStringAsFixed(5)}, ${event.longitude.toStringAsFixed(5)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Show community event on map',
                        icon: const Icon(Icons.map_outlined),
                        onPressed: () {
                          _map.move(
                            LatLng(event.latitude, event.longitude),
                            17,
                          );
                          setState(() => _selected = 'shared_${event.id}');
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _crowdStatusLabel(CrowdEventReport report) {
    if (report.syncStatus != 'uploaded') {
      return 'Upload ${report.syncStatus}';
    }
    return switch (report.verificationStatus) {
      'candidate' => 'Uploaded · awaiting server processing',
      'corroborated' => 'Corroborated by multiple drivers',
      'verified' => 'Verified by the current contribution threshold',
      'rejected' => 'Rejected by server validation',
      'stale' => 'Too old to publish',
      'disputed' => 'Disputed',
      _ => 'Uploaded · status unavailable',
    };
  }
}
