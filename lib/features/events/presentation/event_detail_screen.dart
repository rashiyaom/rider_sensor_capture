import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../data/models/event_parameters.dart';
import '../../../providers/db_providers.dart';

class EventDetailScreen extends ConsumerWidget {
  final EventRecord event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sensorRepositoryProvider);
    final readingsAsync = ref.watch(
      StreamProvider<List<SensorReading>>((ref) => repo.watchReadingsForEvent(event.id)),
    );

    final params = EventParameters.fromJsonString(event.computedParameters);

    final startFormatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(event.startTimestamp.toLocal());
    final endFormatted = event.endTimestamp != null
        ? DateFormat('HH:mm:ss').format(event.endTimestamp!.toLocal())
        : 'In progress';

    Duration duration = Duration.zero;
    if (event.endTimestamp != null) {
      duration = event.endTimestamp!.difference(event.startTimestamp);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${event.eventType.toUpperCase()} #${event.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
            tooltip: 'Delete event',
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.card,
                  title: const Text('Delete Event?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
                  content: const Text(
                    'This will permanently delete this event and all associated sensor readings. This cannot be undone.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await ref.read(sensorRepositoryProvider).deleteEvent(event.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Hero Stat Card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EVENT SUMMARY',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (event.classification != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.classification!.toUpperCase(),
                          style: AppStyles.badgeGreen,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.eventType.toUpperCase(),
                  style: AppStyles.heroNumber.copyWith(fontSize: 34),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(duration.inMilliseconds / 1000).toStringAsFixed(2)}s duration • $startFormatted',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),
                _buildInfoRow('Trigger', '"${event.triggerPhrase ?? "manual"}"'),
                _buildInfoRow('Time Interval', '$startFormatted → $endFormatted'),
                if (event.startGpsLat != null && event.startGpsLng != null)
                  _buildInfoRow('Start GPS', '${event.startGpsLat!.toStringAsFixed(5)}, ${event.startGpsLng!.toStringAsFixed(5)}'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Computed ML Parameters Card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ML Feature Parameters',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 14),
                if (params?.bump != null) _buildBumpDetails(params!.bump!),
                if (params?.turn != null) _buildTurnDetails(params!.turn!),
                if (params?.speed != null) _buildSpeedDetails(params!.speed!),
                if (params == null || (params.bump == null && params.turn == null && params.speed == null))
                  const Text('No parameters computed for this event.', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Open in Maps Button (if GPS available) ──
          if (params?.gpsLat != null && params?.gpsLng != null)
            GestureDetector(
              onTap: () => _openInMaps(params),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: AppStyles.cardDecoration(
                  border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
                  backgroundColor: AppColors.accentCyanBg,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_rounded, color: AppColors.accentCyan, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Open Event Location in Maps', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            '${params!.gpsLat!.toStringAsFixed(6)}, ${params.gpsLng!.toStringAsFixed(6)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new_rounded, color: AppColors.accentCyan, size: 16),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 14),

          // ── Raw Signal Trace Chart ──
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
                      'Acceleration Trace (XYZ)',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Row(
                      children: [
                        _buildDot(AppColors.primaryWhite, 'X'),
                        const SizedBox(width: 8),
                        _buildDot(AppColors.accentCyan, 'Y'),
                        const SizedBox(width: 8),
                        _buildDot(AppColors.textSecondary, 'Z'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: readingsAsync.when(
                    data: (readings) {
                      if (readings.isEmpty) {
                        return const Center(child: Text('No tagged readings found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)));
                      }

                      final spotsX = <FlSpot>[];
                      final spotsY = <FlSpot>[];
                      final spotsZ = <FlSpot>[];

                      for (int i = 0; i < readings.length; i++) {
                        final r = readings[i];
                        if (r.accelX != null && r.accelY != null && r.accelZ != null) {
                          final t = i.toDouble();
                          spotsX.add(FlSpot(t, r.accelX!));
                          spotsY.add(FlSpot(t, r.accelY!));
                          spotsZ.add(FlSpot(t, r.accelZ!));
                        }
                      }

                      if (spotsX.isEmpty) {
                        return const Center(child: Text('Readings contain no IMU acceleration.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)));
                      }

                      return LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 5,
                            getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: 0.04), strokeWidth: 1),
                          ),
                          titlesData: const FlTitlesData(
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(spots: spotsX, color: AppColors.primaryWhite, barWidth: 1.5, dotData: const FlDotData(show: false)),
                            LineChartBarData(spots: spotsY, color: AppColors.accentCyan, barWidth: 1.5, dotData: const FlDotData(show: false)),
                            LineChartBarData(spots: spotsZ, color: AppColors.textSecondary, barWidth: 1.5, dotData: const FlDotData(show: false)),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryWhite)),
                    error: (err, _) => Center(child: Text('Error loading trace: $err', style: const TextStyle(color: AppColors.accentRed))),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
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

  Widget _buildBumpDetails(BumpParameters b) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Peak Accel', '${b.peakGForce.toStringAsFixed(2)}g (${b.peakAccelMagnitude.toStringAsFixed(1)} m/s²)'),
          _buildInfoRow('Bump Severity', b.severity.toUpperCase()),
          _buildInfoRow('Accel Delta', '${b.accelDelta.toStringAsFixed(2)} m/s²'),
          _buildInfoRow('Duration', '${b.durationMs}ms'),
        ],
      ),
    );
  }

  Widget _buildTurnDetails(TurnParameters t) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Peak Lateral Accel', '${t.peakLateralAccel.toStringAsFixed(1)} m/s²'),
          _buildInfoRow('Peak Gyro Rate', '${t.peakGyroDegPerSec.toStringAsFixed(1)}°/s'),
          _buildInfoRow('Turn Severity', t.classification.toUpperCase()),
          _buildInfoRow('Duration', '${t.durationMs}ms'),
        ],
      ),
    );
  }

  Widget _buildSpeedDetails(SpeedParameters s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Decel Magnitude', '${s.decelMagnitude.toStringAsFixed(2)} m/s²'),
          _buildInfoRow('Avg Acceleration', '${s.avgAcceleration.toStringAsFixed(2)} m/s²'),
          _buildInfoRow('Peak Speed', '${s.peakSpeedKmh.toStringAsFixed(1)} km/h'),
          _buildInfoRow('Duration', '${s.durationMs}ms'),
        ],
      ),
    );
  }

  Widget _buildDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// Opens external maps if GPS coords are available in event metadata
  static Future<void> _openInMaps(EventParameters? params) async {
    final lat = params?.gpsLat;
    final lng = params?.gpsLng;
    if (lat == null || lng == null) return;

    final uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
