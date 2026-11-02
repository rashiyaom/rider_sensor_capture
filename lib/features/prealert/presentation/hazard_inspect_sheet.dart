import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../prealert/pre_alert_engine.dart';
import '../../../providers/pre_alert_providers.dart';

/// Modal inspection sheet triggered when tapping any hazard marker on the live map.
class HazardInspectSheet extends ConsumerWidget {
  final RoadEvent? roadEvent;
  final UnknownEvent? unknownEvent;

  const HazardInspectSheet({
    super.key,
    this.roadEvent,
    this.unknownEvent,
  }) : assert(roadEvent != null || unknownEvent != null);

  static Future<void> showRoadEvent(BuildContext context, RoadEvent event) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HazardInspectSheet(roadEvent: event),
    );
  }

  static Future<void> showUnknownEvent(BuildContext context, UnknownEvent event) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HazardInspectSheet(unknownEvent: event),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final isUnknown = unknownEvent != null;
    final lat = isUnknown ? unknownEvent!.latitude : roadEvent!.latitude;
    final lng = isUnknown ? unknownEvent!.longitude : roadEvent!.longitude;
    final title = isUnknown
        ? (unknownEvent!.resolvedLabel ?? 'Unknown IMU Anomaly')
        : RoadEventKind.fromString(roadEvent!.eventType).label;
    final source = isUnknown ? 'voice' : roadEvent!.source;
    final severity = isUnknown
        ? ((unknownEvent!.peakAccelMagnitude ?? 0.0) / 20.0).clamp(0.1, 1.0)
        : (roadEvent!.severity ?? 0.5);
    final note = isUnknown
        ? (unknownEvent!.riderAnswerRaw != null
            ? 'Voice Answer: "${unknownEvent!.riderAnswerRaw}"'
            : 'No voice answer captured')
        : roadEvent!.note;

    final (color, icon) = getEventStyle(isUnknown ? 'unknown' : roadEvent!.eventType);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: const Color(0xF216161B),
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withValues(alpha: 0.35)),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Source: ${_formatSource(source)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Coordinates Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E26),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pin_drop_rounded, size: 16, color: AppColors.accentCyan),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lat != null && lng != null
                            ? '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
                            : 'Coordinates unavailable',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                      onPressed: lat != null && lng != null
                          ? () {
                              Clipboard.setData(ClipboardData(text: '$lat, $lng'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coordinates copied to clipboard')),
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Severity Meter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ESTIMATED SEVERITY',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${(severity * 100).round()}%',
                    style: TextStyle(
                      color: _getSeverityColor(severity),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: severity,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(_getSeverityColor(severity)),
                ),
              ),
              const SizedBox(height: 14),

              // Extra metrics
              if (note != null && note.isNotEmpty) ...[
                const Text(
                  'NOTES & CONTEXT',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    note,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Actions Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF383842)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.map_rounded, size: 16, color: AppColors.accentCyan),
                      label: const Text('Open in Maps', style: TextStyle(color: Colors.white, fontSize: 12)),
                      onPressed: lat != null && lng != null ? () => _openMap(lat, lng) : null,
                    ),
                  ),
                  if (!isUnknown && roadEvent != null) ...[
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentRed.withValues(alpha: 0.15),
                        foregroundColor: AppColors.accentRed,
                        elevation: 0,
                        side: BorderSide(color: AppColors.accentRed.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _confirmDelete(context, ref, roadEvent!.id),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static (Color, IconData) getEventStyle(String? raw) {
    final kind = RoadEventKind.fromString(raw);
    switch (kind) {
      case RoadEventKind.bump:
        return (AppColors.accentAmber, Icons.waves_rounded);
      case RoadEventKind.pothole:
        return (AppColors.accentRed, Icons.warning_amber_rounded);
      case RoadEventKind.turn:
        return (const Color(0xFFFFD60A), Icons.turn_sharp_right_rounded);
      case RoadEventKind.braking:
        return (const Color(0xFFFF375F), Icons.pan_tool_rounded);
      case RoadEventKind.hazard:
        return (AppColors.accentCyan, Icons.report_problem_rounded);
      case RoadEventKind.unknown:
        return (const Color(0xFFBF5AF2), Icons.help_outline_rounded);
    }
  }

  static String _formatSource(String source) {
    switch (source.toLowerCase()) {
      case 'seeded':
        return 'Pre-Coded Ground Truth';
      case 'voice':
        return 'Rider Voice Feedback';
      case 'ml':
        return 'On-Device ML Detector';
      case 'manual':
        return 'Manual Rider Tag';
      default:
        return source.toUpperCase();
    }
  }

  Color _getSeverityColor(double val) {
    if (val >= 0.8) return AppColors.accentRed;
    if (val >= 0.5) return AppColors.accentAmber;
    return AppColors.accentGreen;
  }

  Future<void> _openMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E26),
        title: const Text('Delete Hazard?', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'This will remove the hazard from the knowledge base. Pre-alerts will no longer fire for this location.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(roadEventRegistryProvider).delete(id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hazard deleted')),
        );
      }
    }
  }
}
