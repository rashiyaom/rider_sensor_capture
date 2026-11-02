import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../location/geo_math.dart';

/// Heatmap rendering mode for GPS trajectories on the research map.
enum MapHeatmapMode {
  /// Single uniform high-visibility cyan trace.
  solidCyan,

  /// Segmented by GPS ground speed (Green: >45 km/h, Yellow: 25-45, Red: <25).
  speed,

  /// Segmented by road surface roughness / IRI (Green: Smooth, Yellow: Moderate, Red: Severe).
  roughness,
}

/// Helper methods for ML research map visualization:
/// * Segmented speed & roughness (IRI) heatmaps
/// * Predictive lookahead cone geometry (±70° forward bearing)
class MapResearchHelpers {
  /// Color thresholds for Speed Heatmap
  static Color getSpeedColor(double speedKmh) {
    if (speedKmh >= 45.0) {
      return const Color(0xFF30D158); // Green (> 45 km/h: Cruising speed)
    } else if (speedKmh >= 25.0) {
      return const Color(0xFFFFD60A); // Yellow (25 - 45 km/h: Moderate / City)
    } else if (speedKmh >= 10.0) {
      return const Color(0xFFFF9F0A); // Amber (10 - 25 km/h: Slow / Decelerating)
    } else {
      return const Color(0xFFFF453A); // Red (< 10 km/h: Crawling / Braked)
    }
  }

  /// Color thresholds for Road Roughness / IRI Heatmap
  /// Based on rolling vertical acceleration variance (m/s²).
  static Color getRoughnessColor(double roughnessVal) {
    if (roughnessVal < 1.0) {
      return const Color(0xFF30D158); // Green: Smooth asphalt (< 1.0 m/s²)
    } else if (roughnessVal <= 2.5) {
      return const Color(0xFFFFD60A); // Yellow: Moderate road / patch-work (1.0 - 2.5 m/s²)
    } else {
      return const Color(0xFFFF453A); // Red: Severe degradation / potholes / bumps (> 2.5 m/s²)
    }
  }

  /// Builds a segmented list of polylines colored according to the selected [mode].
  static List<Polyline> buildHeatmapPolylines({
    required List<Map<String, dynamic>> routePoints,
    required MapHeatmapMode mode,
    List<RoadEvent> knownHazards = const [],
  }) {
    if (routePoints.length < 2) return const [];

    // Fallback or solid cyan mode
    if (mode == MapHeatmapMode.solidCyan) {
      final points = routePoints
          .where((p) => p['lat'] != null && p['lng'] != null)
          .map((p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ))
          .toList();
      return [
        Polyline(
          points: points,
          strokeWidth: 4.5,
          color: const Color(0xFF00D4FF),
          borderStrokeWidth: 1.5,
          borderColor: Colors.black.withValues(alpha: 0.5),
        ),
      ];
    }

    final polylines = <Polyline>[];

    for (int i = 0; i < routePoints.length - 1; i++) {
      final p1 = routePoints[i];
      final p2 = routePoints[i + 1];

      if (p1['lat'] == null ||
          p1['lng'] == null ||
          p2['lat'] == null ||
          p2['lng'] == null) {
        continue;
      }

      final pt1 = LatLng(
        (p1['lat'] as num).toDouble(),
        (p1['lng'] as num).toDouble(),
      );
      final pt2 = LatLng(
        (p2['lat'] as num).toDouble(),
        (p2['lng'] as num).toDouble(),
      );

      Color segColor;

      if (mode == MapHeatmapMode.speed) {
        final speed = (p1['speed_kmh'] as num?)?.toDouble() ??
            (p2['speed_kmh'] as num?)?.toDouble() ??
            0.0;
        segColor = getSpeedColor(speed);
      } else {
        // Roughness mode
        double roughness =
            (p1['roughness'] as num?)?.toDouble() ?? 0.0;

        // If direct sensor roughness is not pre-computed, estimate from proximity to known hazards
        if (roughness == 0.0 && knownHazards.isNotEmpty) {
          double minDistance = double.infinity;
          double maxHazardSeverity = 0.5;

          for (final h in knownHazards) {
            final dist = GeoMath.distanceMeters(
              lat1: pt1.latitude,
              lon1: pt1.longitude,
              lat2: h.latitude,
              lon2: h.longitude,
            );
            if (dist < minDistance) {
              minDistance = dist;
              maxHazardSeverity = h.severity ?? 0.5;
            }
          }

          if (minDistance <= 25.0) {
            roughness = 2.8 * maxHazardSeverity; // High roughness near known bump/pothole
          } else if (minDistance <= 60.0) {
            roughness = 1.8 * maxHazardSeverity; // Moderate vibration zone
          } else {
            roughness = 0.6; // Normal asphalt
          }
        }

        segColor = getRoughnessColor(roughness);
      }

      polylines.add(
        Polyline(
          points: [pt1, pt2],
          strokeWidth: 5.0,
          color: segColor,
          borderStrokeWidth: 1.0,
          borderColor: Colors.black.withValues(alpha: 0.6),
        ),
      );
    }

    return polylines;
  }

  /// Constructs the forward predictive lookahead cone polygon.
  ///
  /// Conforms to PreAlertEngine's forward cone (±70° half-angle, lookahead distance).
  static Polygon? buildLookaheadCone({
    required double centerLat,
    required double centerLng,
    required double headingDeg,
    double speedKmh = 30.0,
    double coneHalfAngleDeg = 70.0,
    double maxDistanceMeters = 300.0,
  }) {
    // Dynamic lookahead distance scaled by speed: 100m minimum up to 450m
    final distanceMeters = (speedKmh * 6.0).clamp(120.0, maxDistanceMeters);

    final apex = LatLng(centerLat, centerLng);
    final arcPoints = <LatLng>[apex];

    // Compute points along the forward arc from (heading - 70°) to (heading + 70°)
    const int steps = 14;
    final startAngle = headingDeg - coneHalfAngleDeg;
    final endAngle = headingDeg + coneHalfAngleDeg;
    final stepAngle = (endAngle - startAngle) / steps;

    for (int s = 0; s <= steps; s++) {
      final angle = startAngle + s * stepAngle;
      final rad = angle * math.pi / 180.0;

      // Geodesic offset calculation
      final dLat = (distanceMeters * math.cos(rad)) / 111320.0;
      final cosLat = math.cos(centerLat * math.pi / 180.0).abs();
      final dLng = (distanceMeters * math.sin(rad)) / (111320.0 * (cosLat < 0.0001 ? 1.0 : cosLat));

      arcPoints.add(LatLng(centerLat + dLat, centerLng + dLng));
    }

    arcPoints.add(apex); // Close polygon back at rider

    return Polygon(
      points: arcPoints,
      color: AppColors.accentCyan.withValues(alpha: 0.16),
      borderColor: AppColors.accentCyan.withValues(alpha: 0.65),
      borderStrokeWidth: 1.5,
    );
  }
}
