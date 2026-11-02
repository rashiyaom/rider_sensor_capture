import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../prealert/pre_alert_engine.dart';
import '../../../providers/handsfree_providers.dart';
import '../../../providers/pre_alert_providers.dart';
import '../../prealert/presentation/bulk_import_hazards_sheet.dart';
import '../../prealert/presentation/hazard_inspect_sheet.dart';
import '../../prealert/presentation/seed_road_hazard_sheet.dart';
import '../../trips/trip_controller.dart';
import 'map_research_helpers.dart';
import 'offline_map_cache_sheet.dart';

/// Live research map using flutter_map + CartoDB Dark tiles.
///
/// **Feature Sets A, B, C, D:**
/// * **Set A:** Long-press map to drop pre-coded hazards, or 1-tap bulk import CSV.
/// * **Set B:** Multi-layer colored pins (bumps, potholes, turns, braking, unknown voice).
///   Tap any pin to inspect coordinates, severity meter, voice feedback transcript.
/// * **Set C:** Segmented Speed and Road Roughness / IRI heatmaps.
/// * **Set D:** Real-time Predictive Lookahead Cone (±70° forward bearing) & pulsing alert circle.
class LiveMapSection extends ConsumerStatefulWidget {
  const LiveMapSection({super.key});

  @override
  ConsumerState<LiveMapSection> createState() => _LiveMapSectionState();
}

class _LiveMapSectionState extends ConsumerState<LiveMapSection>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _isExpanded = false;
  bool _showHazards = true;
  bool _showRoute = true;
  bool _useDarkTiles = true;
  bool _showLookaheadCone = true;
  MapHeatmapMode _heatmapMode = MapHeatmapMode.solidCyan;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _cycleHeatmapMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _heatmapMode = switch (_heatmapMode) {
        MapHeatmapMode.solidCyan => MapHeatmapMode.speed,
        MapHeatmapMode.speed => MapHeatmapMode.roughness,
        MapHeatmapMode.roughness => MapHeatmapMode.solidCyan,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripControllerProvider);
    final routePoints = tripState.routePoints;
    final currentPos = tripState.currentPosition;
    final activeAlert = ref.watch(activePreAlertProvider);

    // Load registered road hazards & unknown voice events
    final roadEventsAsync = ref.watch(roadEventsStreamProvider);
    final unknownEventsAsync = ref.watch(unknownEventsStreamProvider);

    final roadEvents = roadEventsAsync.value ?? const <RoadEvent>[];
    final unknownEvents = unknownEventsAsync.value ?? const <UnknownEvent>[];

    // Convert stored route breadcrumbs to LatLng
    final latLngs = routePoints
        .where((p) => p['lat'] != null && p['lng'] != null)
        .map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()))
        .toList();

    // Center on rider position or last breadcrumb
    final center = currentPos != null
        ? LatLng(currentPos.latitude, currentPos.longitude)
        : (latLngs.isNotEmpty
            ? latLngs.last
            : (roadEvents.isNotEmpty
                ? LatLng(roadEvents.first.latitude, roadEvents.first.longitude)
                : const LatLng(19.0760, 72.8774))); // Mumbai default

    final tileUrl = _useDarkTiles
        ? 'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    // Build segmented polylines (Feature Set C)
    final polylines = _showRoute
        ? MapResearchHelpers.buildHeatmapPolylines(
            routePoints: routePoints,
            mode: _heatmapMode,
            knownHazards: roadEvents,
          )
        : <Polyline>[];

    // Build forward lookahead cone (Feature Set D)
    Polygon? lookaheadCone;
    if (_showLookaheadCone && currentPos != null) {
      final heading = currentPos.heading > 0
          ? currentPos.heading
          : (latLngs.length >= 2
              ? _calculateBearing(latLngs[latLngs.length - 2], latLngs.last)
              : 0.0);

      final speedKmh = currentPos.speed >= 0 ? currentPos.speed * 3.6 : 30.0;

      lookaheadCone = MapResearchHelpers.buildLookaheadCone(
        centerLat: currentPos.latitude,
        centerLng: currentPos.longitude,
        headingDeg: heading,
        speedKmh: speedKmh,
      );
    }

    // Active Pre-Alert target coordinate (Feature Set D)
    LatLng? alertTargetLatLng;
    if (activeAlert != null && activeAlert.shouldSpeak) {
      alertTargetLatLng = LatLng(
        activeAlert.candidate.latitude,
        activeAlert.candidate.longitude,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.map_rounded, color: AppColors.accentCyan, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Research Map',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Hold map to drop hazard pin',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Action Toolbar
              Row(
                children: [
                  // Heatmap Mode Badge/Button
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _cycleHeatmapMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getHeatmapModeColor().withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getHeatmapModeColor().withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.palette_rounded, size: 12, color: _getHeatmapModeColor()),
                          const SizedBox(width: 4),
                          Text(
                            _getHeatmapModeLabel(),
                            style: TextStyle(
                              color: _getHeatmapModeColor(),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Add Hazard Pin Button
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => SeedRoadHazardSheet.show(
                      context,
                      initialLat: currentPos?.latitude,
                      initialLng: currentPos?.longitude,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 2),
                          Text(
                            'Add Pin',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Bulk Import Button
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => BulkImportHazardsSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.file_upload_outlined, size: 16, color: AppColors.textSecondary),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Offline Tile Cache Button (Feature Set F)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => OfflineMapCacheSheet.show(
                      context,
                      centerLat: center.latitude,
                      centerLng: center.longitude,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.download_for_offline_rounded, size: 16, color: AppColors.accentGreen),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Expand Map Height Toggle
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isExpanded ? Icons.unfold_less_rounded : Icons.unfold_more_rounded,
                        size: 16,
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Map Viewport ──
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isExpanded ? 380 : 220,
              width: double.infinity,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 15.0,
                      onLongPress: (tapPosition, point) {
                        HapticFeedback.mediumImpact();
                        SeedRoadHazardSheet.show(
                          context,
                          initialLat: point.latitude,
                          initialLng: point.longitude,
                        );
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      // Tile layer
                      TileLayer(
                        urlTemplate: tileUrl,
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.rashiyaom.ride_sensor_capture',
                        maxNativeZoom: 19,
                      ),

                      // Feature D: Forward Predictive Lookahead Cone (±70° Polygon)
                      if (lookaheadCone != null)
                        PolygonLayer(polygons: [lookaheadCone]),

                      // Feature D: Vector line connecting rider to target hazard
                      if (alertTargetLatLng != null && currentPos != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [
                                LatLng(currentPos.latitude, currentPos.longitude),
                                alertTargetLatLng,
                              ],
                              strokeWidth: 2.5,
                              color: activeAlert?.urgency == PreAlertUrgency.imminent
                                  ? AppColors.accentRed
                                  : AppColors.accentAmber,
                              pattern: StrokePattern.dashed(segments: const [8, 4]),
                            ),
                          ],
                        ),

                      // Feature C: Segmented Heatmap Route Polylines
                      if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),

                      // Start marker
                      if (_showRoute && latLngs.isNotEmpty)
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

                      // Pre-coded Road Hazards Markers (Feature Set B)
                      if (_showHazards && roadEvents.isNotEmpty)
                        MarkerLayer(
                          markers: roadEvents.map((hazard) {
                            final (color, icon) = HazardInspectSheet.getEventStyle(hazard.eventType);
                            final isTarget = activeAlert != null &&
                                activeAlert.candidate.id == hazard.id;

                            return Marker(
                              point: LatLng(hazard.latitude, hazard.longitude),
                              width: isTarget ? 48 : 32,
                              height: isTarget ? 48 : 32,
                              child: GestureDetector(
                                onTap: () => HazardInspectSheet.showRoadEvent(context, hazard),
                                child: isTarget
                                    ? AnimatedBuilder(
                                        animation: _pulseAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _pulseAnimation.value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: activeAlert.urgency == PreAlertUrgency.imminent
                                                      ? AppColors.accentRed
                                                      : AppColors.accentAmber,
                                                  width: 3,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (activeAlert.urgency == PreAlertUrgency.imminent
                                                            ? AppColors.accentRed
                                                            : AppColors.accentAmber)
                                                        .withValues(alpha: 0.6),
                                                    blurRadius: 14,
                                                    spreadRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: _HazardMapBadge(
                                          color: color,
                                          icon: icon,
                                          severity: hazard.severity ?? 0.5,
                                        ),
                                      )
                                    : _HazardMapBadge(
                                        color: color,
                                        icon: icon,
                                        severity: hazard.severity ?? 0.5,
                                      ),
                              ),
                            );
                          }).toList(),
                        ),

                      // Unknown Voice-Labeled Events Markers (Feature Set B)
                      if (_showHazards && unknownEvents.isNotEmpty)
                        MarkerLayer(
                          markers: unknownEvents
                              .where((u) => u.latitude != null && u.longitude != null)
                              .map((u) {
                            return Marker(
                              point: LatLng(u.latitude!, u.longitude!),
                              width: 32,
                              height: 32,
                              child: GestureDetector(
                                onTap: () => HazardInspectSheet.showUnknownEvent(context, u),
                                child: const _HazardMapBadge(
                                  color: Color(0xFFBF5AF2),
                                  icon: Icons.help_outline_rounded,
                                  severity: 0.8,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      // Current rider position marker with direction cone apex
                      if (currentPos != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(currentPos.latitude, currentPos.longitude),
                              width: 22,
                              height: 22,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF00D4FF), width: 3.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF00D4FF),
                                      blurRadius: 12,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Floating Toolbar on bottom-right of map
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle Lookahead Cone (Feature D)
                        _buildFloatingMapTool(
                          icon: Icons.radar_rounded,
                          color: _showLookaheadCone ? AppColors.accentCyan : AppColors.textTertiary,
                          tooltip: 'Toggle Lookahead Cone',
                          onTap: () => setState(() => _showLookaheadCone = !_showLookaheadCone),
                        ),
                        const SizedBox(height: 6),
                        // Toggle Dark/Light Tile
                        _buildFloatingMapTool(
                          icon: _useDarkTiles ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: _useDarkTiles ? const Color(0xFFFFD60A) : Colors.white,
                          tooltip: 'Toggle Map Theme',
                          onTap: () => setState(() => _useDarkTiles = !_useDarkTiles),
                        ),
                        const SizedBox(height: 6),
                        // Toggle Hazards Visibility
                        _buildFloatingMapTool(
                          icon: Icons.layers_rounded,
                          color: _showHazards ? AppColors.accentAmber : AppColors.textTertiary,
                          tooltip: 'Toggle Hazards',
                          onTap: () => setState(() => _showHazards = !_showHazards),
                        ),
                        const SizedBox(height: 6),
                        // Offline Map Cache (Feature Set F)
                        _buildFloatingMapTool(
                          icon: Icons.download_for_offline_rounded,
                          color: AppColors.accentGreen,
                          tooltip: 'Offline Tile Cache',
                          onTap: () => OfflineMapCacheSheet.show(
                            context,
                            centerLat: center.latitude,
                            centerLng: center.longitude,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Recenter on Rider
                        if (currentPos != null)
                          _buildFloatingMapTool(
                            icon: Icons.my_location_rounded,
                            color: AppColors.accentCyan,
                            tooltip: 'Recenter GPS',
                            onTap: () {
                              _mapController.move(
                                LatLng(currentPos.latitude, currentPos.longitude),
                                16.0,
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  // Active Pre-Alert Overlay Card (Feature Set D)
                  if (activeAlert != null && activeAlert.shouldSpeak)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (activeAlert.urgency == PreAlertUrgency.imminent
                                  ? AppColors.accentRed
                                  : AppColors.accentAmber)
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              activeAlert.urgency == PreAlertUrgency.imminent
                                  ? Icons.warning_rounded
                                  : Icons.notifications_active_rounded,
                              color: Colors.black,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${activeAlert.candidate.kind.label} in ${activeAlert.distanceMeters.round()}m (${activeAlert.timeToEventSeconds.toStringAsFixed(1)}s)',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Live speed / point counter chip at top-left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        currentPos?.speed != null && currentPos!.speed > 0
                            ? '${(currentPos.speed * 3.6).toStringAsFixed(1)} km/h · ${latLngs.length} pts'
                            : (latLngs.isNotEmpty ? '${latLngs.length} pts recorded' : 'Live Map Ready'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Dynamic Legend (Feature Set C) ──
          const SizedBox(height: 10),
          _buildDynamicLegend(),
        ],
      ),
    );
  }

  Widget _buildDynamicLegend() {
    switch (_heatmapMode) {
      case MapHeatmapMode.speed:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('SPEED: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
              _buildLegendItem(const Color(0xFF30D158), '>45 km/h'),
              const SizedBox(width: 8),
              _buildLegendItem(const Color(0xFFFFD60A), '25-45'),
              const SizedBox(width: 8),
              _buildLegendItem(const Color(0xFFFF9F0A), '10-25'),
              const SizedBox(width: 8),
              _buildLegendItem(const Color(0xFFFF453A), '<10 km/h'),
              const SizedBox(width: 12),
              const Text('© CartoDB', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            ],
          ),
        );
      case MapHeatmapMode.roughness:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('ROUGHNESS (IRI): ', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
              _buildLegendItem(const Color(0xFF30D158), 'Smooth (<1.0G)'),
              const SizedBox(width: 8),
              _buildLegendItem(const Color(0xFFFFD60A), 'Moderate (1-2.5G)'),
              const SizedBox(width: 8),
              _buildLegendItem(const Color(0xFFFF453A), 'Severe (>2.5G)'),
              const SizedBox(width: 12),
              const Text('© CartoDB', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            ],
          ),
        );
      case MapHeatmapMode.solidCyan:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildLegendItem(AppColors.accentAmber, 'Speed Bump'),
              const SizedBox(width: 10),
              _buildLegendItem(AppColors.accentRed, 'Pothole'),
              const SizedBox(width: 10),
              _buildLegendItem(const Color(0xFFFFD60A), 'Turn'),
              const SizedBox(width: 10),
              _buildLegendItem(const Color(0xFFFF375F), 'Braking'),
              const SizedBox(width: 10),
              _buildLegendItem(const Color(0xFFBF5AF2), 'Voice Unknown'),
              const SizedBox(width: 14),
              const Text('© CartoDB', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            ],
          ),
        );
    }
  }

  Color _getHeatmapModeColor() {
    switch (_heatmapMode) {
      case MapHeatmapMode.solidCyan:
        return AppColors.accentCyan;
      case MapHeatmapMode.speed:
        return const Color(0xFF30D158);
      case MapHeatmapMode.roughness:
        return AppColors.accentRed;
    }
  }

  String _getHeatmapModeLabel() {
    switch (_heatmapMode) {
      case MapHeatmapMode.solidCyan:
        return 'Solid Trace';
      case MapHeatmapMode.speed:
        return 'Speed Heatmap';
      case MapHeatmapMode.roughness:
        return 'Roughness (IRI)';
    }
  }

  Widget _buildFloatingMapTool({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xE616161C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4),
            ],
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  static double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * (3.141592653589793 / 180.0);
    final lat2 = to.latitude * (3.141592653589793 / 180.0);
    final dLon = (to.longitude - from.longitude) * (3.141592653589793 / 180.0);

    final y = (dLon >= 0 ? 1 : -1) * (dLon).abs();
    final x = (lat2 - lat1);
    final rad = (y != 0 || x != 0) ? (3.141592653589793 / 2.0) - (x / (y.abs() + 0.0001)) : 0.0;
    return (rad * 180.0 / 3.141592653589793) % 360.0;
  }
}

/// Circular badge marker on the map representing a road hazard.
class _HazardMapBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double severity;

  const _HazardMapBadge({
    required this.color,
    required this.icon,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14141A),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

/// Static post-trip route map (for trip_detail_screen) with Heatmap toggle (Feature Set C)
/// and synchronized playback scrubber tracking (Feature Set E).
class TripRouteMapWidget extends StatefulWidget {
  final List<Map<String, dynamic>> routePoints;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final List<EventRecord>? tripEvents;
  final LatLng? scrubPosition;
  final double? scrubSpeedKmh;
  final double? scrubAltitude;
  final String? scrubEventName;

  const TripRouteMapWidget({
    super.key,
    required this.routePoints,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    this.tripEvents,
    this.scrubPosition,
    this.scrubSpeedKmh,
    this.scrubAltitude,
    this.scrubEventName,
  });

  @override
  State<TripRouteMapWidget> createState() => _TripRouteMapWidgetState();
}

class _TripRouteMapWidgetState extends State<TripRouteMapWidget> {
  MapHeatmapMode _mode = MapHeatmapMode.solidCyan;
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(TripRouteMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrubPosition != null && widget.scrubPosition != oldWidget.scrubPosition) {
      try {
        _mapController.move(widget.scrubPosition!, _mapController.camera.zoom);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final latLngs = widget.routePoints
        .where((p) => p['lat'] != null && p['lng'] != null)
        .map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()))
        .toList();

    if (latLngs.isEmpty) {
      final sl = widget.startLat;
      final slng = widget.startLng;
      if (sl != null && slng != null) {
        latLngs.add(LatLng(sl, slng));
      }
    }

    final center = widget.scrubPosition ??
        (latLngs.isNotEmpty
            ? latLngs[latLngs.length ~/ 2]
            : const LatLng(19.0760, 72.8774));

    final polylines = MapResearchHelpers.buildHeatmapPolylines(
      routePoints: widget.routePoints,
      mode: _mode,
    );

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 260,
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
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 14.5,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'com.rashiyaom.ride_sensor_capture',
                            maxNativeZoom: 19,
                          ),
                          if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                          // Start and End markers
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
                          // Labeled trip events pins
                          if (widget.tripEvents != null && widget.tripEvents!.isNotEmpty)
                            MarkerLayer(
                              markers: widget.tripEvents!
                                  .where((e) => e.startGpsLat != null && e.startGpsLng != null)
                                  .map((e) {
                                final (color, icon) = HazardInspectSheet.getEventStyle(e.eventType);
                                return Marker(
                                  point: LatLng(e.startGpsLat!, e.startGpsLng!),
                                  width: 24,
                                  height: 24,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16161D),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: color, width: 1.5),
                                    ),
                                    child: Icon(icon, color: color, size: 12),
                                  ),
                                );
                              }).toList(),
                            ),

                          // Synchronized Scrubbing Crosshair Marker (Feature Set E)
                          if (widget.scrubPosition != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: widget.scrubPosition!,
                                  width: 48,
                                  height: 48,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer pulsing ring
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: widget.scrubEventName != null
                                                ? const Color(0xFFFF453A)
                                                : const Color(0xFF00D4FF),
                                            width: 2.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (widget.scrubEventName != null
                                                      ? const Color(0xFFFF453A)
                                                      : const Color(0xFF00D4FF))
                                                  .withValues(alpha: 0.6),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Inner crosshair icon
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF141418),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.filter_center_focus_rounded,
                                          size: 16,
                                          color: widget.scrubEventName != null
                                              ? const Color(0xFFFF453A)
                                              : const Color(0xFF00D4FF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      // Floating Scrubber HUD Pill at top-center of map
                      if (widget.scrubPosition != null)
                        Positioned(
                          top: 8,
                          left: 12,
                          right: 12,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.scrubEventName != null
                                      ? const Color(0xFFFF453A)
                                      : AppColors.accentCyan.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.gps_fixed_rounded,
                                    size: 12,
                                    color: widget.scrubEventName != null
                                        ? const Color(0xFFFF453A)
                                        : AppColors.accentCyan,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${widget.scrubSpeedKmh?.toStringAsFixed(1) ?? '0.0'} km/h',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (widget.scrubAltitude != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${widget.scrubAltitude!.toStringAsFixed(0)}m',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                  if (widget.scrubEventName != null) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF453A).withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '⚠️ ${widget.scrubEventName!}',
                                        style: const TextStyle(
                                          color: Color(0xFFFF453A),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Heatmap switch pill at bottom-left of map
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMiniPill('Solid', MapHeatmapMode.solidCyan),
                              _buildMiniPill('Speed', MapHeatmapMode.speed),
                              _buildMiniPill('Roughness', MapHeatmapMode.roughness),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniPill(String label, MapHeatmapMode mode) {
    final active = _mode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _mode = mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: active ? AppColors.accentCyan.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: active ? Border.all(color: AppColors.accentCyan, width: 1) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
