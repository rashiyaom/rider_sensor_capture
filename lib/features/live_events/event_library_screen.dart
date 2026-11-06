import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/db_providers.dart';
import '../../providers/pre_alert_providers.dart';
import '../../location/location_service.dart';
import '../events/event_recording_controller.dart';
import '../prealert/presentation/seed_road_hazard_sheet.dart';
import 'event_library_repository.dart';
import 'live_event_providers.dart';

final _liveMapFixProvider = StreamProvider<LocationFix>((ref) =>
    ref.watch(locationServiceProvider).fixStream);

class EventLibraryScreen extends ConsumerStatefulWidget {
  const EventLibraryScreen({super.key});
  @override
  ConsumerState<EventLibraryScreen> createState() => _EventLibraryScreenState();
}

class _EventLibraryScreenState extends ConsumerState<EventLibraryScreen> {
  final _map = MapController();
  String? _selected;
  String _filter = 'All';
  String _query = '';

  @override
  void dispose() { _map.dispose(); super.dispose(); }

  Future<void> _edit(ManagedEvent event) async {
    final lat = TextEditingController(text: event.latitude?.toString() ?? '');
    final lon = TextEditingController(text: event.longitude?.toString() ?? '');
    final note = TextEditingController(text: event.feedback ?? '');
    final types = {'bump', 'pothole', 'turn', 'braking', 'hazard', 'acceleration', 'unknown', event.type};
    var type = event.type;
    String? error;
    var saving = false;
    await showDialog<void>(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(title: const Text('Edit event'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(initialValue: type,
            items: types.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: saving ? null : (v) => type = v!, decoration: const InputDecoration(labelText: 'Event type')),
          TextField(controller: lat, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(labelText: 'Latitude')),
          TextField(controller: lon, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(labelText: 'Longitude')),
          TextField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'Feedback / note')),
          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
        ])), actions: [
          TextButton(onPressed: saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: saving ? null : () async {
            setDialogState(() { saving = true; error = null; });
            try {
              final latitude = lat.text.trim().isEmpty ? null : double.parse(lat.text.trim());
              final longitude = lon.text.trim().isEmpty ? null : double.parse(lon.text.trim());
              await EventLibraryRepository(ref.read(appDatabaseProvider)).edit(event,
                type: type, latitude: latitude, longitude: longitude, feedback: note.text.trim());
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              if (context.mounted) setDialogState(() { saving = false; error = 'Could not save: $e'; });
            }
          }, child: const Text('Save changes')),
        ],
      ),
    ));
    // Dialog animations can still use the fields until the route is removed.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    lat.dispose(); lon.dispose(); note.dispose();
  }

  Future<void> _delete(ManagedEvent event) async {
    final approved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Delete event?'), content: const Text('This removes the event and its future location alert. Trip sensor readings are retained.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))]));
    if (approved != true || !mounted) return;
    try { await EventLibraryRepository(ref.read(appDatabaseProvider)).delete(event); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not delete event: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    final roads = ref.watch(roadEventsStreamProvider);
    final reviews = ref.watch(allLiveEventReviewsProvider);
    final records = ref.watch(allEventRecordsStreamProvider);
    final fix = ref.watch(_liveMapFixProvider).value ?? ref.watch(locationServiceProvider).currentFix;
    final events = ManagedEvent.combine(roads.value ?? [], reviews.value ?? [], records.value ?? []);
    final filtered = events.where((e) =>
      (_filter == 'All' || (_filter == 'Saved alerts' ? e.roadId != null : e.reviewId != null)) &&
      '${e.type} ${e.source} ${e.feedback ?? ''} ${e.reply ?? ''}'.toLowerCase().contains(_query.toLowerCase())).toList();
    final points = filtered.where((e) => e.latitude != null && e.longitude != null).toList();
    final center = fix != null ? LatLng(fix.latitude, fix.longitude)
        : points.isNotEmpty ? LatLng(points.first.latitude!, points.first.longitude!) : const LatLng(20.5937, 78.9629);
    return Scaffold(appBar: AppBar(title: const Text('All events'), actions: [
      IconButton(tooltip: 'Add location', icon: const Icon(Icons.add_location_alt),
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true,
          builder: (_) => const SeedRoadHazardSheet())),
    ]), body: Column(children: [
      SizedBox(height: 240, child: FlutterMap(mapController: _map,
        options: MapOptions(initialCenter: center, initialZoom: points.isEmpty && fix == null ? 4 : 15),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ride_sensor_capture'),
          MarkerLayer(markers: [
            if (fix != null) Marker(point: LatLng(fix.latitude, fix.longitude), width: 32, height: 32,
              child: const Tooltip(message: 'Your current position', child: Icon(Icons.my_location, color: Colors.blue))),
            for (final event in points) Marker(point: LatLng(event.latitude!, event.longitude!), width: 44, height: 44,
              child: IconButton(tooltip: '${event.type} · ${event.status}',
                icon: Icon(Icons.location_on, color: _selected == event.key ? Colors.amber : event.roadId != null ? Colors.red : Colors.purple),
                onPressed: () => setState(() { _selected = event.key; }))),
          ]),
          const Align(alignment: Alignment.bottomRight, child: ColoredBox(color: Colors.white,
            child: Padding(padding: EdgeInsets.all(3), child: Text('© OpenStreetMap contributors', style: TextStyle(color: Colors.black, fontSize: 10))))),
        ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
        Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Search type, feedback or source', prefixIcon: Icon(Icons.search)),
          onChanged: (v) => setState(() => _query = v))),
        IconButton(tooltip: 'Your current position', onPressed: fix == null ? null : () => _map.move(LatLng(fix.latitude, fix.longitude), 16),
          icon: const Icon(Icons.my_location)),
      ])),
      Wrap(spacing: 8, children: [for (final filter in ['All', 'Saved alerts', 'Live ride'])
        ChoiceChip(label: Text(filter), selected: _filter == filter,
          onSelected: (_) => setState(() { _filter = filter; _selected = null; }))]),
      if (roads.hasError || reviews.hasError || records.hasError)
        const Text('Some events could not be loaded. Reopen this page to retry.'),
      Text('${filtered.length} events · blue marker: your position'),
      Expanded(child: ListView(children: [
        for (final event in [...filtered.where((e) => e.key == _selected), ...filtered.where((e) => e.key != _selected)])
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${event.type} · ${event.status}', style: Theme.of(context).textTheme.titleMedium),
            Text('${event.source} · ${event.at.toLocal()}'),
            Text(event.latitude == null ? 'No coordinate captured' : '${event.latitude!.toStringAsFixed(6)}, ${event.longitude!.toStringAsFixed(6)}'),
            if (event.reply != null) Text('Your reply: ${event.reply}'),
            if (event.feedback != null) Text('Feedback: ${event.feedback}'),
            Wrap(spacing: 8, children: [
              TextButton(onPressed: event.latitude == null ? null : () {
                _map.move(LatLng(event.latitude!, event.longitude!), 17);
                setState(() => _selected = event.key);
              }, child: const Text('Show on map')),
              TextButton(onPressed: () => _edit(event), child: const Text('Edit')),
              TextButton(onPressed: () => _delete(event), child: const Text('Delete')),
              if (event.reviewId != null && event.status == 'pending')
                TextButton(onPressed: () async {
                  try { await ref.read(liveEventRepositoryProvider).saveLocation(event.reviewId!); }
                  catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
                }, child: const Text('Save for alerts')),
            ]),
          ]))),
      ])),
    ]));
  }
}
