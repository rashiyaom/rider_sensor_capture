import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../prealert/pre_alert_engine.dart';

/// Floating banner that surfaces the active predictive pre-alert.
///
/// It shows the hazard type, the computed distance, the time-to-event and the
/// recommended speed so the rider can sanity-check the spoken warning at a
/// glance.
class PreAlertBanner extends StatelessWidget {
  final PreAlertDecision decision;

  /// Called when the rider dismisses the banner.
  final VoidCallback? onDismiss;

  const PreAlertBanner({
    super.key,
    required this.decision,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(decision.urgency);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xF01B1B20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconFor(decision.candidate.kind), color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${decision.candidate.kind.label.toUpperCase()} AHEAD',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${decision.distanceMeters.round()} m  ·  '
                  '${decision.timeToEventSeconds.round()} s  ·  '
                  'slow to ${decision.recommendedSpeedKmh.round()} km/h',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  static Color _colorFor(PreAlertUrgency urgency) {
    switch (urgency) {
      case PreAlertUrgency.imminent:
        return AppColors.accentRed;
      case PreAlertUrgency.warning:
        return AppColors.accentAmber;
      case PreAlertUrgency.advisory:
        return AppColors.accentCyan;
    }
  }

  static IconData _iconFor(RoadEventKind kind) {
    switch (kind) {
      case RoadEventKind.bump:
        return Icons.vibration_rounded;
      case RoadEventKind.pothole:
        return Icons.warning_amber_rounded;
      case RoadEventKind.turn:
        return Icons.turn_sharp_right_rounded;
      case RoadEventKind.braking:
        return Icons.speed_rounded;
      case RoadEventKind.hazard:
        return Icons.report_problem_rounded;
      case RoadEventKind.unknown:
        return Icons.warning_rounded;
    }
  }
}
