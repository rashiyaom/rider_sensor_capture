import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../trips/trip_controller.dart';

/// Live embedded OpenStreetMap using flutter_map + OpenStreetMap tiles.
/// Shows the real-time GPS breadcrumb route during an active journey.
/// Replaces the old custom 2D canvas route painter on the dashboard.
class LiveMapSection extends ConsumerWidget {
  const LiveMapSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripControllerProvider);
    final routePoints = tripState.routePoints;
    final currentPos = tripState.currentPosition;

    // Convert stored route breadcrumbs to LatLng
    final latLngs = routePoints
        .where((p) => p['lat'] != null && p['lng'] != null)
        .map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()))
        .toList();

    // Current GPS position for map centering
    final center = currentPos != null
        ? LatLng(currentPos.latitude, currentPos.longitude)
        : (latLngs.isNotEmpty ? latLngs.last : const LatLng(20.5937, 78.9629)); // India default

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.map_rounded, color: AppColors.accentCyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Live GPS Route Map',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (latLngs.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreenBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${latLngs.length} pts · OSM Live',
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cardElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Text(
                    'Awaiting GPS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Map
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: latLngs.isEmpty && currentPos == null
                  ? _buildNoGpsPlaceholder()
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                        ),
                      ),
                      children: [
                        // OpenStreetMap tile layer (free, open-source)
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.rashiyaom.ride_sensor_capture',
                          maxNativeZoom: 19,
                        ),

                        // Route polyline
                        if (latLngs.length >= 2)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: latLngs,
                                strokeWidth: 4.0,
                                color: const Color(0xFF00D4FF),
                                borderStrokeWidth: 1.0,
                                borderColor: Colors.white.withValues(alpha: 0.3),
                              ),
                            ],
                          ),

                        // Start marker (green dot)
                        if (latLngs.isNotEmpty)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: latLngs.first,
                                width: 14,
                                height: 14,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF30D158),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0xFF30D158), blurRadius: 6),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // Current position marker (pulsing white)
                        if (currentPos != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(currentPos.latitude, currentPos.longitude),
                                width: 18,
                                height: 18,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF00D4FF), width: 3),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF00D4FF),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
            ),
          ),

          // Attribution
          const SizedBox(height: 6),
          const Text(
            '© OpenStreetMap contributors · Tiles: OSM',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoGpsPlaceholder() {
    return Container(
      color: const Color(0xFF141418),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_searching_rounded,
              color: Colors.white.withValues(alpha: 0.25),
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'Waiting for GPS fix...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Map will load once GPS lock is acquired',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static post-trip route map (for trip_detail_screen).
/// Shows the full breadcrumb trail from stored route JSON.
class TripRouteMapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> routePoints;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;

  const TripRouteMapWidget({
    super.key,
    required this.routePoints,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
  });

  @override
  Widget build(BuildContext context) {
    final latLngs = routePoints
        .where((p) => p['lat'] != null && p['lng'] != null)
        .map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()))
        .toList();

    if (latLngs.isEmpty) {
      final sl = startLat;
      final slng = startLng;
      if (sl != null && slng != null) {
        latLngs.add(LatLng(sl, slng));
      }
    }

    final center = latLngs.isNotEmpty
        ? latLngs[latLngs.length ~/ 2]
        : const LatLng(20.5937, 78.9629);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: latLngs.isEmpty
            ? Container(
                color: const Color(0xFF141418),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_rounded,
                          color: Colors.white.withValues(alpha: 0.3), size: 36),
                      const SizedBox(height: 8),
                      const Text(
                        'No GPS breadcrumbs recorded for this journey',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            : FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.rashiyaom.ride_sensor_capture',
                    maxNativeZoom: 19,
                  ),
                  if (latLngs.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: latLngs,
                          strokeWidth: 4.0,
                          color: const Color(0xFF00D4FF),
                          borderStrokeWidth: 1.0,
                          borderColor: Colors.white.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (latLngs.isNotEmpty)
                        Marker(
                          point: latLngs.first,
                          width: 14,
                          height: 14,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF30D158),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      if (latLngs.length > 1)
                        Marker(
                          point: latLngs.last,
                          width: 14,
                          height: 14,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF453A),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
