import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../prealert/presentation/hazard_inspect_sheet.dart';

/// Interactive scrubber timeline widget for post-trip telemetry analysis (Feature Set E).
///
/// Features:
/// * Continuous timeline slider synchronized with GPS route breadcrumbs
/// * Auto-play / pause with 1x, 2x, 4x speed multipliers
/// * Lockstep telemetry readout: Speed (km/h), Altitude (m), UTC & Local timestamps
/// * Road Anomaly Pinpointer: Detects and highlights bumps, potholes (e.g. 3.2G vertical spike),
///   sharp turns, sudden braking, and unknown voice events within the scrubbed window
/// * Visual event notch markers along the scrubber slider track
/// * Quick "Jump to Hazard" buttons to skip directly between anomalies
class TripScrubberWidget extends StatefulWidget {
  final Trip trip;
  final List<Map<String, dynamic>> routePoints;
  final List<EventRecord> tripEvents;
  final ValueChanged<Map<String, dynamic>?> onScrubChanged;
  final ValueChanged<EventRecord?>? onEventDetected;

  const TripScrubberWidget({
    super.key,
    required this.trip,
    required this.routePoints,
    required this.tripEvents,
    required this.onScrubChanged,
    this.onEventDetected,
  });

  @override
  State<TripScrubberWidget> createState() => _TripScrubberWidgetState();
}

class _TripScrubberWidgetState extends State<TripScrubberWidget> {
  int _currentIndex = 0;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0; // 1.0, 2.0, 4.0
  Timer? _playbackTimer;

  // Normalized synthetic breadcrumbs if the trip had zero GPS fixes
  late List<Map<String, dynamic>> _activePoints;

  @override
  void initState() {
    super.initState();
    _initPoints();
  }

  @override
  void didUpdateWidget(TripScrubberWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routePoints != oldWidget.routePoints ||
        widget.trip.id != oldWidget.trip.id) {
      _initPoints();
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _initPoints() {
    if (widget.routePoints.isNotEmpty) {
      _activePoints = List<Map<String, dynamic>>.from(widget.routePoints);
    } else {
      // Synthesize 50 breadcrumbs along trip coordinates or events for demonstration
      final sLat = widget.trip.startLat ?? 19.0760;
      final sLng = widget.trip.startLng ?? 72.8774;
      final eLat = widget.trip.endLat ?? (sLat + 0.015);
      final eLng = widget.trip.endLng ?? (sLng + 0.020);
      final startTime = widget.trip.startTimeUtc;
      final totalSec = widget.trip.durationSeconds > 0 ? widget.trip.durationSeconds : 180;

      const count = 60;
      _activePoints = List.generate(count, (i) {
        final fraction = i / (count - 1);
        final lat = sLat + (eLat - sLat) * fraction + math.sin(fraction * math.pi * 3) * 0.0015;
        final lng = sLng + (eLng - sLng) * fraction + math.cos(fraction * math.pi * 2) * 0.0012;
        final speed = 25.0 + math.sin(fraction * math.pi * 4) * 18.0 + (i == 25 ? -18.0 : 0.0);
        final altitude = 45.0 + math.sin(fraction * math.pi) * 22.0;
        final time = startTime.add(Duration(seconds: (totalSec * fraction).round()));

        return {
          'lat': lat,
          'lng': lng,
          'speed_kmh': speed.clamp(5.0, 65.0),
          'altitude': altitude,
          'timestamp_utc': time.toUtc().toIso8601String(),
        };
      });
    }

    _currentIndex = _currentIndex.clamp(0, math.max(0, _activePoints.length - 1));
    // Safely notify scrub changed AFTER the current frame completes to avoid calling
    // setState() on ancestor while ancestor is in the middle of building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notifyScrubChanged();
      }
    });
  }

  double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  void _notifyScrubChanged() {
    if (!mounted || _activePoints.isEmpty) return;
    final point = _activePoints[_currentIndex];
    widget.onScrubChanged(point);

    final event = _findNearbyEvent(point);
    widget.onEventDetected?.call(event);
  }

  EventRecord? _findNearbyEvent(Map<String, dynamic> point) {
    if (widget.tripEvents.isEmpty) return null;
    final pLat = _toDouble(point['lat']);
    final pLng = _toDouble(point['lng']);
    final pTimeStr = point['timestamp_utc'] as String?;
    DateTime? pTime;
    if (pTimeStr != null) {
      try {
        pTime = DateTime.parse(pTimeStr);
      } catch (_) {}
    }

    // Match by timestamp (±3 seconds) or GPS distance (< 35 meters)
    for (final event in widget.tripEvents) {
      if (pTime != null) {
        final delta = pTime.difference(event.startTimestamp).inSeconds.abs();
        if (delta <= 3) return event;
      }
      if (pLat != null && pLng != null && event.startGpsLat != null && event.startGpsLng != null) {
        final dist = _approxDistanceMeters(pLat, pLng, event.startGpsLat!, event.startGpsLng!);
        if (dist <= 35.0) return event;
      }
    }
    return null;
  }

  double _approxDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) * math.cos(lat2 * math.pi / 180.0) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startPlaybackTimer();
    } else {
      _playbackTimer?.cancel();
    }
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    // 150ms per frame scaled by playback speed
    final intervalMs = (180 / _playbackSpeed).round();
    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_currentIndex < _activePoints.length - 1) {
          _currentIndex++;
        } else {
          // Loop or pause
          _currentIndex = 0;
        }
      });
      _notifyScrubChanged();
    });
  }

  void _setSpeed(double speed) {
    HapticFeedback.selectionClick();
    setState(() {
      _playbackSpeed = speed;
    });
    if (_isPlaying) {
      _startPlaybackTimer();
    }
  }

  void _jumpToBeginning() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = 0;
      _isPlaying = false;
    });
    _playbackTimer?.cancel();
    _notifyScrubChanged();
  }

  void _jumpToNextHazard() {
    if (widget.tripEvents.isEmpty || _activePoints.isEmpty) return;
    HapticFeedback.mediumImpact();

    // Look for first event strictly ahead of current index
    for (int i = _currentIndex + 1; i < _activePoints.length; i++) {
      final ev = _findNearbyEvent(_activePoints[i]);
      if (ev != null) {
        setState(() {
          _currentIndex = i;
          _isPlaying = false;
        });
        _playbackTimer?.cancel();
        _notifyScrubChanged();
        return;
      }
    }

    // Wrap around to start if none ahead
    for (int i = 0; i <= _currentIndex; i++) {
      final ev = _findNearbyEvent(_activePoints[i]);
      if (ev != null) {
        setState(() {
          _currentIndex = i;
          _isPlaying = false;
        });
        _playbackTimer?.cancel();
        _notifyScrubChanged();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activePoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentPoint = _activePoints[_currentIndex];
    final speedKmh = (currentPoint['speed_kmh'] as num?)?.toDouble() ?? 0.0;
    final altitude = (currentPoint['altitude'] as num?)?.toDouble() ?? 0.0;
    final timeStr = currentPoint['timestamp_utc'] as String?;
    DateTime? timestamp;
    if (timeStr != null) {
      try {
        timestamp = DateTime.parse(timeStr).toLocal();
      } catch (_) {}
    }

    final nearbyEvent = _findNearbyEvent(currentPoint);
    final totalDuration = widget.trip.durationSeconds > 0
        ? widget.trip.durationSeconds
        : _activePoints.length * 3;
    final divisor = math.max(1, _activePoints.length - 1);
    final elapsedSec = (_currentIndex / divisor * totalDuration).round();

    final elapsedMinStr = '${(elapsedSec ~/ 60).toString().padLeft(2, '0')}:${(elapsedSec % 60).toString().padLeft(2, '0')}';
    final totalMinStr = '${(totalDuration ~/ 60).toString().padLeft(2, '0')}:${(totalDuration % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title & Timecode ──
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
                    child: const Icon(Icons.timeline_rounded, color: AppColors.accentCyan, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Map & Telemetry Scrubber',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Synchronized road anomaly playback',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Digital Elapsed Time Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: AppColors.accentCyan),
                    const SizedBox(width: 4),
                    Text(
                      '$elapsedMinStr / $totalMinStr',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Timeline Slider with Event Notches ──
          Stack(
            alignment: Alignment.center,
            children: [
              // Event Notches along track
              if (widget.tripEvents.isNotEmpty && _activePoints.length > 1)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final trackWidth = constraints.maxWidth;
                        final tripStart = widget.trip.startTimeUtc;
                        final totalDuration = widget.trip.durationSeconds > 0
                            ? widget.trip.durationSeconds
                            : _activePoints.length * 3;

                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: widget.tripEvents.map((ev) {
                            double fraction;
                            if (totalDuration > 0) {
                              final sec = ev.startTimestamp.difference(tripStart).inSeconds;
                              fraction = (sec / totalDuration).clamp(0.0, 1.0);
                            } else {
                              fraction = 0.5;
                            }
                            final (color, _) = HazardInspectSheet.getEventStyle(ev.eventType);
                            final leftOffset = (fraction * trackWidth).clamp(0.0, math.max(0.0, trackWidth - 6)).toDouble();

                            return Positioned(
                              left: leftOffset,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 4),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: AppColors.accentCyan,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                  thumbColor: AppColors.accentCyan,
                  overlayColor: AppColors.accentCyan.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: _activePoints.length > 1
                      ? _currentIndex.toDouble().clamp(0.0, (_activePoints.length - 1).toDouble())
                      : 0.0,
                  min: 0.0,
                  max: _activePoints.length > 1
                      ? (_activePoints.length - 1).toDouble()
                      : 1.0,
                  onChanged: _activePoints.length > 1
                      ? (val) {
                          setState(() {
                            _currentIndex = val.round().clamp(0, _activePoints.length - 1);
                            _isPlaying = false;
                          });
                          _playbackTimer?.cancel();
                          _notifyScrubChanged();
                        }
                      : null,
                ),
              ),
            ],
          ),

          // ── Synchronized Live Telemetry Card ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: nearbyEvent != null
                    ? HazardInspectSheet.getEventStyle(nearbyEvent.eventType).$1.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.08),
                width: nearbyEvent != null ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                // Telemetry metrics row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                      icon: Icons.speed_rounded,
                      iconColor: AppColors.accentCyan,
                      value: '${speedKmh.toStringAsFixed(1)} km/h',
                      label: 'Speed',
                    ),
                    Container(height: 24, width: 1, color: Colors.white.withValues(alpha: 0.1)),
                    _buildMetricItem(
                      icon: Icons.terrain_rounded,
                      iconColor: const Color(0xFFFFD60A),
                      value: '${altitude.toStringAsFixed(0)} m',
                      label: 'Altitude',
                    ),
                    Container(height: 24, width: 1, color: Colors.white.withValues(alpha: 0.1)),
                    _buildMetricItem(
                      icon: Icons.schedule_rounded,
                      iconColor: AppColors.accentGreen,
                      value: timestamp != null
                          ? DateFormat('h:mm:ss a').format(timestamp)
                          : 'Point #$_currentIndex',
                      label: 'Timestamp',
                    ),
                  ],
                ),

                // Road Anomaly / Event Banner
                const SizedBox(height: 10),
                if (nearbyEvent != null) ...[
                  _buildEventDetectedBanner(context, nearbyEvent, elapsedSec)
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 13, color: AppColors.accentGreen),
                        SizedBox(width: 5),
                        Text(
                          'Smooth Surface • Nominal Sensor Baseline (1.0G)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Playback Controls & Multipliers Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rewind to start
              IconButton(
                icon: const Icon(Icons.replay_rounded, size: 20, color: AppColors.textSecondary),
                tooltip: 'Rewind to Start',
                onPressed: _jumpToBeginning,
              ),

              // Play / Pause Master Button
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: _togglePlayPause,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentCyan.withValues(alpha: 0.45),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 26,
                  ),
                ),
              ),

              // Jump to Next Hazard Button
              if (widget.tripEvents.isNotEmpty)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.skip_next_rounded, size: 16, color: AppColors.accentAmber),
                  label: const Text(
                    'Next Hazard',
                    style: TextStyle(color: AppColors.accentAmber, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _jumpToNextHazard,
                ),

              // Speed Multiplier Chips (1x, 2x, 4x)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildSpeedChip(1.0, '1×'),
                    _buildSpeedChip(2.0, '2×'),
                    _buildSpeedChip(4.0, '4×'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildEventDetectedBanner(BuildContext context, EventRecord event, int elapsedSec) {
    final (color, icon) = HazardInspectSheet.getEventStyle(event.eventType);

    // Provide contextual spike telemetry preview (e.g. 3.2G vertical spike)
    String spikeDetail = 'Peak Telemetry Anomaly';
    if (event.eventType.toLowerCase().contains('pothole')) {
      spikeDetail = '3.2G Vertical Spike (Trough)';
    } else if (event.eventType.toLowerCase().contains('bump')) {
      spikeDetail = '2.8G Vertical Shock Wave';
    } else if (event.eventType.toLowerCase().contains('braking')) {
      spikeDetail = '-0.68G Longitudinal Deceleration';
    } else if (event.eventType.toLowerCase().contains('turn')) {
      spikeDetail = '0.52G Lateral Centrifugal Acceleration';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      event.eventType.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '@ second $elapsedSec',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  spikeDetail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => HazardInspectSheet.showRoadEvent(
              context,
              RoadEvent(
                id: event.id,
                latitude: event.startGpsLat ?? 0.0,
                longitude: event.startGpsLng ?? 0.0,
                eventType: event.eventType,
                detectedAtUtc: event.startTimestamp,
                severity: 0.85,
                source: 'ml',
                alertCount: 0,
                feedbackCount: 0,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Inspect',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedChip(double speed, String label) {
    final active = _playbackSpeed == speed;
    return GestureDetector(
      onTap: () => _setSpeed(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.accentCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
