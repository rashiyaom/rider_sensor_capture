import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../providers/db_providers.dart';
import '../../../providers/export_providers.dart';
import '../../dashboard/presentation/live_map_widget.dart';
import '../../events/event_recording_controller.dart';
import '../../export/models/export_options.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final eventsAsync = ref.watch(allEventRecordsStreamProvider);
    final allEvents = eventsAsync.value ?? [];
    final tripEvents = allEvents.where((e) => e.tripId == trip.id).toList();

    final dateFormat = DateFormat('EEE, MMM d, yyyy • h:mm:ss a');
    final startTimeStr = dateFormat.format(trip.startTimeUtc.toLocal());
    final endTimeStr = trip.endTimeUtc != null
        ? dateFormat.format(trip.endTimeUtc!.toLocal())
        : 'Ongoing';

    final durationMins = (trip.durationSeconds / 60.0).toStringAsFixed(1);
    final distanceKm = (trip.distanceMeters / 1000.0).toStringAsFixed(2);

    // Parse route breadcrumbs
    List<Map<String, dynamic>> routePoints = [];
    if (trip.routeCoordinatesJson != null && trip.routeCoordinatesJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(trip.routeCoordinatesJson!) as List<dynamic>;
        routePoints = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journey Telemetry'),
        actions: [
          IconButton(
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryWhite),
                  )
                : const Icon(Icons.share_rounded, color: AppColors.accentCyan),
            tooltip: 'Export & Share Journey',
            onPressed: _isExporting ? null : () => _showExportOptionsSheet(context, trip),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
            tooltip: 'Delete Journey',
            onPressed: () => _confirmDeleteTrip(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Hero Journey Metric Card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppStyles.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyanBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_rounded, color: AppColors.accentCyan, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  trip.riderName,
                                  style: const TextStyle(color: AppColors.accentCyan, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cardElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Text('🤚', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  trip.wristSide.contains('Hand')
                                      ? trip.wristSide
                                      : '${trip.wristSide} Hand',
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Journey #${trip.id}',
                        style: const TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBlock('Duration', '$durationMins min', Icons.timer_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricBlock('Distance', '$distanceKm km', Icons.route_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBlock(
                          'Avg Speed',
                          trip.avgSpeedKmh != null ? '${trip.avgSpeedKmh!.toStringAsFixed(1)} km/h' : '--',
                          Icons.speed_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricBlock(
                          'Peak Speed',
                          trip.peakSpeedKmh != null ? '${trip.peakSpeedKmh!.toStringAsFixed(1)} km/h' : '--',
                          Icons.bolt_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── BLE Data Quality & RF Continuity Card ──
            ref.watch(tripBleQualityProvider(trip.id)).when(
              data: (quality) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bluetooth_connected_rounded, color: AppColors.accentCyan, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'BLE Telemetry Continuity',
                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: quality.receptionPercentage >= 95
                                ? AppColors.accentGreen.withValues(alpha: 0.15)
                                : (quality.receptionPercentage >= 85
                                    ? Colors.orange.withValues(alpha: 0.15)
                                    : AppColors.accentRed.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: quality.receptionPercentage >= 95
                                  ? AppColors.accentGreen
                                  : (quality.receptionPercentage >= 85 ? Colors.orange : AppColors.accentRed),
                            ),
                          ),
                          child: Text(
                            '${quality.receptionPercentage}% Reception',
                            style: TextStyle(
                              color: quality.receptionPercentage >= 95
                                  ? AppColors.accentGreen
                                  : (quality.receptionPercentage >= 85 ? Colors.orange : AppColors.accentRed),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricBlock(
                            'Packets OK',
                            '${quality.totalPackets}',
                            Icons.check_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricBlock(
                            'Packets Lost',
                            '${quality.droppedPackets}',
                            Icons.error_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricBlock(
                            'Seq Gaps',
                            '${quality.gapCount}',
                            Icons.graphic_eq_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),

            // ── 2. Visual GPS Journey Route Map & Navigation ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppStyles.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Journey GPS Route Track',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      if (routePoints.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            '${routePoints.length} GPS Points',
                            style: const TextStyle(color: AppColors.accentGreen, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // OpenStreetMap Route View
                  TripRouteMapWidget(
                    routePoints: routePoints,
                    startLat: trip.startLat,
                    startLng: trip.startLng,
                    endLat: trip.endLat,
                    endLng: trip.endLng,
                  ),

                  const SizedBox(height: 16),

                  // Map Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF3C3C44)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.directions_rounded, size: 16, color: AppColors.accentCyan),
                          label: const Text('Open in Google Maps', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                          onPressed: () => _openRouteInGoogleMaps(trip),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3C3C44)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        icon: const Icon(Icons.map_rounded, size: 16, color: AppColors.textSecondary),
                        label: const Text('Apple Maps', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        onPressed: () => _openRouteInAppleMaps(trip),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── 3. High-Precision Timespan & Telemetry Metadata ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppStyles.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Timespan & Clock Synchronization', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 14),
                  _buildTimelineRow('Start Time', startTimeStr, Icons.play_circle_fill_rounded, AppColors.accentGreen),
                  const SizedBox(height: 10),
                  _buildTimelineRow('End Time', endTimeStr, Icons.stop_circle_rounded, AppColors.accentRed),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 10),
                  _buildInfoRow('50Hz Telemetry Rows', '${trip.totalSensorRows} rows persisted'),
                  _buildInfoRow('Labeled ML Events', '${trip.totalEventsCount} tagged segments'),
                  _buildInfoRow('Start GPS Coordinates', trip.startLat != null ? '${trip.startLat!.toStringAsFixed(6)}, ${trip.startLng!.toStringAsFixed(6)}' : '--'),
                  _buildInfoRow('Destination Coordinates', trip.endLat != null ? '${trip.endLat!.toStringAsFixed(6)}, ${trip.endLng!.toStringAsFixed(6)}' : '--'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── 4. Detailed Event Breakdown & CSV Navigation Index ──
            if (tripEvents.isNotEmpty) ...[
              _buildDetailedEventsBreakdownSection(trip, tripEvents),
              const SizedBox(height: 14),
            ],

            // ── 5. Bottom Export Action Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryWhite,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text(
                  'Export Complete Journey Dataset (CSV & JSON)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                onPressed: _isExporting ? null : () => _showExportOptionsSheet(context, trip),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                icon: const Icon(Icons.cleaning_services_rounded, size: 16, color: AppColors.accentCyan),
                label: const Text(
                  'Prune Unlabeled Rows (Save Storage)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                onPressed: () => _confirmPruneUntaggedRows(context, trip),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedEventsBreakdownSection(Trip trip, List<EventRecord> events) {
    // Group event counts by type
    final typeCounts = <String, int>{};
    for (final e in events) {
      final key = e.eventType.toLowerCase();
      typeCounts[key] = (typeCounts[key] ?? 0) + 1;
    }

    final tripStart = trip.startTimeUtc;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Total Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.label_important_rounded, color: AppColors.accentCyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Tagged ML Events & Timeline',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentCyanBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${events.length} Total Events',
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Event type distribution pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: typeCounts.entries.map((entry) {
              final color = _getEventTypeColor(entry.key);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${entry.value} ${entry.key.toUpperCase()}${entry.value > 1 ? 'S' : ''}',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          // CSV Quick-Navigation Hint
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.accentCyan, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use the Start/End seconds and CSV Row Index below to locate exact event samples in exported CSV files without manual scrolling.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 10, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Chronological List of Events
          ...events.asMap().entries.map((item) {
            final idx = item.key + 1;
            final evt = item.value;
            final color = _getEventTypeColor(evt.eventType);

            // Compute relative start & end seconds from trip onset
            final startSec = evt.startTimestamp.difference(tripStart).inMilliseconds / 1000.0;
            final endSec = evt.endTimestamp != null
                ? evt.endTimestamp!.difference(tripStart).inMilliseconds / 1000.0
                : null;
            final durationSec = endSec != null ? (endSec - startSec) : null;

            // 50Hz approximate CSV row index: startSec * 50 to endSec * 50
            final startRowEstimate = (math.max(0.0, startSec) * 50).toInt() + 1;
            final endRowEstimate = endSec != null
                ? (math.max(0.0, endSec) * 50).toInt() + 1
                : (startRowEstimate + 50);

            final timeFmt = DateFormat('h:mm:ss.S a');

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Index, Event Type, Classification, and Peak Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '#$idx ${evt.eventType.toUpperCase()}',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          evt.classification ?? evt.triggerPhrase ?? 'Manual Trigger',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (evt.peakMetric != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyanBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Peak ${evt.peakMetric!.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: AppColors.accentCyan,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Row 2: Precise Timeline (Start second -> End second)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141418),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Start Second
                        Row(
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: AppColors.accentGreen, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Start: T+${startSec.toStringAsFixed(2)}s',
                              style: const TextStyle(
                                color: AppColors.accentGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // End Second & Duration
                        Row(
                          children: [
                            const Icon(Icons.stop_rounded, color: AppColors.accentRed, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              endSec != null
                                  ? 'End: T+${endSec.toStringAsFixed(2)}s (${durationSec!.toStringAsFixed(2)}s)'
                                  : 'End: In-Progress',
                              style: TextStyle(
                                color: endSec != null ? AppColors.accentRed : Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Row 3: CSV Navigation Row + Telemetry metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CSV Row helper tag
                      Row(
                        children: [
                          const Icon(Icons.table_rows_rounded, color: AppColors.accentAmber, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'CSV Rows: ~$startRowEstimate – ~$endRowEstimate',
                            style: const TextStyle(
                              color: AppColors.accentAmber,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Exact wall-clock start time
                      Text(
                        timeFmt.format(evt.startTimestamp.toLocal()),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  // Optional Row 4: Validation & Sensor Gating Tags
                  if (evt.crossConfirmed || evt.hrSpikeConfirmed || evt.gpsSpeedAtEventKmh != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: [
                        if (evt.crossConfirmed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '✓ Fork-Foot Validated${evt.forkFootLagMs != null ? ' (${evt.forkFootLagMs!.toStringAsFixed(0)}ms)' : ''}',
                              style: const TextStyle(color: AppColors.accentGreen, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (evt.hrSpikeConfirmed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.accentRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '✓ HR Spike +${evt.hrDeltaAtEvent?.toStringAsFixed(0) ?? '8'} bpm',
                              style: const TextStyle(color: AppColors.accentRed, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (evt.gpsSpeedAtEventKmh != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.cardBorder,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Speed: ${evt.gpsSpeedAtEventKmh!.toStringAsFixed(1)} km/h',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 8.5),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bump':
        return Colors.orange;
      case 'turn':
        return const Color(0xFF00D4FF); // Cyan
      case 'speedtest':
        return Colors.purpleAccent;
      case 'voicetag':
        return const Color(0xFF30D158); // Green
      case 'brake':
      case 'hardbrake':
        return Colors.redAccent;
      default:
        return AppColors.accentCyan;
    }
  }

  Widget _buildMetricBlock(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static Future<void> _openRouteInGoogleMaps(Trip trip) async {
    Uri uri;
    if (trip.startLat != null && trip.endLat != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${trip.startLat},${trip.startLng}&destination=${trip.endLat},${trip.endLng}&travelmode=driving',
      );
    } else if (trip.startLat != null) {
      uri = Uri.parse('https://maps.google.com/?q=${trip.startLat},${trip.startLng}');
    } else {
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _openRouteInAppleMaps(Trip trip) async {
    Uri uri;
    if (trip.startLat != null && trip.endLat != null) {
      uri = Uri.parse(
        'http://maps.apple.com/?saddr=${trip.startLat},${trip.startLng}&daddr=${trip.endLat},${trip.endLng}',
      );
    } else if (trip.startLat != null) {
      uri = Uri.parse('http://maps.apple.com/?q=${trip.startLat},${trip.startLng}');
    } else {
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showExportOptionsSheet(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Export Journey #${trip.id}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Export high-precision 50Hz sensor data & GPS route to CSV or JSON for ML analysis.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 20),
            _buildExportOptionTile(
              title: 'Export Both CSV & JSON (Recommended)',
              subtitle: 'Consolidated sensor sheet + complete nested metadata JSON',
              icon: Icons.inventory_2_rounded,
              color: AppColors.accentGreen,
              onTap: () {
                Navigator.pop(ctx);
                _performTripExport(trip, ExportFormat.both);
              },
            ),
            const SizedBox(height: 10),
            _buildExportOptionTile(
              title: 'Export CSV Only (Excel / Pandas)',
              subtitle: '50Hz sensor telemetry with timestamps down to the millisecond',
              icon: Icons.table_chart_rounded,
              color: AppColors.accentCyan,
              onTap: () {
                Navigator.pop(ctx);
                _performTripExport(trip, ExportFormat.csv);
              },
            ),
            const SizedBox(height: 10),
            _buildExportOptionTile(
              title: 'Export JSON Only (ML Hierarchy)',
              subtitle: 'Structured event hierarchy, route breadcrumbs, and metrics',
              icon: Icons.data_object_rounded,
              color: AppColors.accentAmber,
              onTap: () {
                Navigator.pop(ctx);
                _performTripExport(trip, ExportFormat.json);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _performTripExport(Trip trip, ExportFormat format) async {
    setState(() => _isExporting = true);
    try {
      final exportRepo = ref.read(exportRepositoryProvider);
      final files = await exportRepo.generateTripExportFiles(trip.id, format: format);
      if (files.isNotEmpty) {
        await exportRepo.shareFiles(files);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _confirmDeleteTrip(BuildContext context) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Journey', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          'Delete Journey #${widget.trip.id} and all associated sensor data?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              final repo = ref.read(sensorRepositoryProvider);
              await repo.deleteTrip(widget.trip.id);
              navigator.pop(); // Exit detail screen
              messenger.showSnackBar(
                const SnackBar(content: Text('Journey deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmPruneUntaggedRows(BuildContext context, Trip trip) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Prune Unlabeled Telemetry', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text(
          'Delete continuous sensor readings that are not tagged with any ML event?\n\n'
          '✓ Preserves all labeled event segments & markers\n'
          '✓ Frees SQLite storage on device\n\n'
          'Recommended after you have exported your CSV dataset.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentCyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(sensorRepositoryProvider);
              final deleted = await repo.deleteUntaggedReadingsForTrip(trip.id);
              ref.invalidate(tripBleQualityProvider(trip.id));
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('🧹 Pruned $deleted unlabeled telemetry rows. Event data preserved.'),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              }
            },
            child: const Text('Prune Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

