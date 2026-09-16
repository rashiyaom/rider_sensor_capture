import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../providers/db_providers.dart';
import '../../../providers/export_providers.dart';
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

                  // Route Canvas Map Box
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141418),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: routePoints.isNotEmpty
                          ? CustomPaint(
                              painter: _GpsRouteCanvasPainter(
                                routePoints: routePoints,
                                startLat: trip.startLat,
                                startLng: trip.startLng,
                                endLat: trip.endLat,
                                endLng: trip.endLng,
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_off_rounded, color: Colors.white.withValues(alpha: 0.3), size: 36),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No GPS breadcrumbs recorded for this journey',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                    ),
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

            // ── 4. Labeled Ground-Truth Events ──
            if (tripEvents.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppStyles.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tagged Ground-Truth Events', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 12),
                    ...tripEvents.map((evt) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(color: AppColors.accentCyan, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(evt.eventType.toUpperCase(), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(
                                    evt.classification ?? evt.triggerPhrase ?? 'manual trigger',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (evt.peakMetric != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppColors.accentCyanBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    'Peak ${evt.peakMetric!.toStringAsFixed(1)}',
                                    style: const TextStyle(color: AppColors.accentCyan, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
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
          ],
        ),
      ),
    );
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
}

/// Custom Canvas Painter that plots the full GPS Route Polyline & Markers
class _GpsRouteCanvasPainter extends CustomPainter {
  final List<Map<String, dynamic>> routePoints;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;

  _GpsRouteCanvasPainter({
    required this.routePoints,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw tech grid background
    final gridPaint = Paint()
      ..color = const Color(0xFF222228)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (routePoints.isEmpty) return;

    // 2. Compute bounding box
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final p in routePoints) {
      final lat = (p['lat'] as num?)?.toDouble();
      final lng = (p['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
        if (lng < minLng) minLng = lng;
        if (lng > maxLng) maxLng = lng;
      }
    }

    if (minLat == double.infinity) return;

    // Add margin if points are close together
    final latSpan = math.max(maxLat - minLat, 0.0005);
    final lngSpan = math.max(maxLng - minLng, 0.0005);

    const padding = 28.0;
    final drawWidth = size.width - (padding * 2);
    final drawHeight = size.height - (padding * 2);

    Offset toCanvasOffset(double lat, double lng) {
      final x = padding + ((lng - minLng) / lngSpan) * drawWidth;
      // Invert Y so north is UP
      final y = size.height - padding - ((lat - minLat) / latSpan) * drawHeight;
      return Offset(x, y);
    }

    // 3. Draw Polyline Route
    final path = Path();
    bool first = true;
    for (final p in routePoints) {
      final lat = (p['lat'] as num?)?.toDouble();
      final lng = (p['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final offset = toCanvasOffset(lat, lng);
        if (first) {
          path.moveTo(offset.dx, offset.dy);
          first = false;
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
    }

    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.accentCyan.withValues(alpha: 0.3)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint);

    // Main route line
    final routePaint = Paint()
      ..color = AppColors.accentCyan
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, routePaint);

    // 4. Draw Intermediate Breadcrumb Dots
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < routePoints.length; i += math.max(1, (routePoints.length ~/ 15))) {
      final lat = (routePoints[i]['lat'] as num?)?.toDouble();
      final lng = (routePoints[i]['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        canvas.drawCircle(toCanvasOffset(lat, lng), 2.5, dotPaint);
      }
    }

    // 5. Draw Start Pin (Green)
    final sLat = startLat ?? (routePoints.first['lat'] as num?)?.toDouble();
    final sLng = startLng ?? (routePoints.first['lng'] as num?)?.toDouble();
    if (sLat != null && sLng != null) {
      final startOffset = toCanvasOffset(sLat, sLng);
      _drawMarker(canvas, startOffset, 'START', AppColors.accentGreen);
    }

    // 6. Draw End Pin (Red)
    final eLat = endLat ?? (routePoints.last['lat'] as num?)?.toDouble();
    final eLng = endLng ?? (routePoints.last['lng'] as num?)?.toDouble();
    if (eLat != null && eLng != null) {
      final endOffset = toCanvasOffset(eLat, eLng);
      _drawMarker(canvas, endOffset, 'END', AppColors.accentRed);
    }
  }

  void _drawMarker(Canvas canvas, Offset offset, String label, Color color) {
    // Halo
    canvas.drawCircle(offset, 10, Paint()..color = color.withValues(alpha: 0.25));
    // Core dot
    canvas.drawCircle(offset, 6, Paint()..color = color);
    canvas.drawCircle(offset, 2.5, Paint()..color = Colors.white);

    // Label pill
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();

    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(offset.dx, offset.dy - 16),
        width: textPainter.width + 8,
        height: 14,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(pillRect, Paint()..color = const Color(0xFF1C1C22));
    canvas.drawRRect(
      pillRect,
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - 22));
  }

  @override
  bool shouldRepaint(covariant _GpsRouteCanvasPainter oldDelegate) {
    return oldDelegate.routePoints != routePoints;
  }
}
