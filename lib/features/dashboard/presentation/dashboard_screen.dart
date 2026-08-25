import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ble/models/ble_device_model.dart';
import '../../../core/services/battery_service.dart';
import '../../../core/services/session_health_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/battery_providers.dart';
import '../../../providers/ble_providers.dart';
import '../../../providers/dashboard_providers.dart';
import '../../../providers/db_providers.dart';
import '../../../providers/session_health_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bleToDbBridgeProvider);

    final isPaused = ref.watch(dashboardPausedProvider);
    final alertsAsync = ref.watch(activeHealthAlertsProvider);
    final alerts = alertsAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 26,
                height: 26,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.show_chart_rounded,
                  size: 22,
                  color: AppColors.accentGreen,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Live Ride Telemetry'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: isPaused ? AppColors.accentAmber : AppColors.textPrimary,
            ),
            tooltip: isPaused ? 'Resume live stream' : 'Pause live stream',
            onPressed: () {
              ref.read(dashboardPausedProvider.notifier).state = !isPaused;
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear telemetry buffers',
            onPressed: () {
              ref.read(dashboardTelemetryProvider.notifier).reset();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Hero Card ──
            const _HeroActionSection(),

            const SizedBox(height: 14),

            // ── 2. Three-Column Stat Metric Bento ──
            const _ThreeColumnMetricBentoSection(),

            const SizedBox(height: 14),

            // ── 3. Session Continuity Grid ──
            const _ContinuityPillGridSection(),

            const SizedBox(height: 14),

            // ── 4. Split Two-Column Bento ──
            const _SplitBentoSection(),

            const SizedBox(height: 14),

            // ── 5. Waveform Cards ──
            const _HeartRateWaveformSection(),

            const SizedBox(height: 14),

            const _AccelerometerWaveformSection(),

            const SizedBox(height: 14),

            const _GyroscopeWaveformSection(),

            if (alerts.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildAlertsBanner(context, alerts, ref),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildAlertsBanner(
    BuildContext context,
    List<HealthAlert> alerts,
    WidgetRef ref,
  ) {
    final healthService = ref.read(sessionHealthServiceProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentAmberBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: alerts.map((alert) {
          return Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.accentAmber, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${alert.title}: ${alert.message}',
                  style: const TextStyle(color: AppColors.accentAmber, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => healthService.dismissAlert(alert.id),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── 1. Hero Action Section ──────────────────────────────────────────────────
class _HeroActionSection extends ConsumerWidget {
  const _HeroActionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaused = ref.watch(dashboardPausedProvider);
    final connectionStatesAsync = ref.watch(connectionStatesStreamProvider);
    final connectionMap = connectionStatesAsync.value ?? {};
    final batteryAsync = ref.watch(batteryInfoStreamProvider);
    final battery = batteryAsync.value ?? const BatteryInfo();

    final connectedCount = connectionMap.values
        .where((d) => d.connectionState == BleConnectionState.connected)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session Ingest',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      isPaused
                          ? 'Paused'
                          : (connectedCount > 0 ? 'Live Capture' : 'Standby'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      battery.isCharging ? Icons.battery_charging_full : Icons.battery_std,
                      color: battery.isLowBattery ? AppColors.accentAmber : AppColors.accentGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${battery.batteryLevel}%',
                      style: TextStyle(
                        color: battery.isLowBattery ? AppColors.accentAmber : AppColors.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            connectedCount > 0
                ? '$connectedCount BLE sensor${connectedCount > 1 ? "s" : ""} streaming at 50Hz'
                : 'No sensor connected · Connect BLE hardware in Devices tab',
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMiniChip(
                Icons.access_time_rounded,
                '~${battery.estimatedRideHoursRemaining.toStringAsFixed(1)}h battery',
              ),
              const SizedBox(width: 8),
              _buildMiniChip(
                Icons.sensors_rounded,
                '$connectedCount sensor${connectedCount != 1 ? "s" : ""} active',
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryWhite,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: () {
                ref.read(dashboardPausedProvider.notifier).state = !isPaused;
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPaused ? 'Resume Telemetry' : 'Pause Live Stream',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Three-Column Stat Metric Bento Section ───────────────────────────────
class _ThreeColumnMetricBentoSection extends ConsumerWidget {
  const _ThreeColumnMetricBentoSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(dashboardTelemetryProvider);
    final dbStatsAsync = ref.watch(dbWriteStatsStreamProvider);
    final dbStats = dbStatsAsync.value ?? const DbWriteStats();

    final hr = telemetry.latestHr;
    final accelX = telemetry.latestAccelX;
    final accelY = telemetry.latestAccelY;
    final accelZ = telemetry.latestAccelZ;

    double? mag;
    if (accelX != null && accelY != null && accelZ != null) {
      mag = math.sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ) / 9.80665;
    }

    final totalRows = dbStats.totalRows;
    final formattedRows = totalRows > 1000
        ? '${(totalRows / 1000).toStringAsFixed(1)}k'
        : '$totalRows';

    return Row(
      children: [
        Expanded(
          child: _buildBentoCard(
            icon: Icons.favorite_rounded,
            badge: hr != null ? 'Live' : 'Off',
            value: hr != null ? '$hr' : '--',
            unit: 'bpm',
            label: 'heart rate',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.speed_rounded,
            badge: mag != null ? '50Hz' : 'Idle',
            value: mag != null ? mag.toStringAsFixed(1) : '--',
            unit: 'g',
            label: 'peak g-force',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.inventory_2_outlined,
            badge: 'SQLite',
            value: formattedRows,
            unit: 'rows',
            label: 'persisted',
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required String badge,
    required String value,
    required String unit,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accentGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge, style: AppStyles.badgeGreen),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppStyles.heroNumber.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppStyles.statLabel,
          ),
        ],
      ),
    );
  }
}

// ── 3. Session Continuity Grid Section ──────────────────────────────────────
class _ContinuityPillGridSection extends ConsumerWidget {
  const _ContinuityPillGridSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(dashboardTelemetryProvider);
    final isPaused = ref.watch(dashboardPausedProvider);
    final connectionStatesAsync = ref.watch(connectionStatesStreamProvider);
    final connectionMap = connectionStatesAsync.value ?? {};

    final hasActiveConnection = connectionMap.values.any(
      (d) => d.connectionState == BleConnectionState.connected,
    );
    final hasData = telemetry.latestAccelX != null || telemetry.latestHr != null;

    final isStreaming = hasActiveConnection && !isPaused;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Telemetry Continuity',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                isPaused
                    ? 'Paused'
                    : (isStreaming
                        ? (hasData ? 'Live · 50Hz Ingest' : 'Connected · Ready')
                        : 'Standby · No Sensor'),
                style: TextStyle(
                  color: isStreaming ? AppColors.accentGreen : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildPillRow(
                isStreaming
                    ? [true, true, true, true, true, true, true, true, true, true]
                    : List.filled(10, false),
              ),
              const SizedBox(height: 8),
              _buildPillRow(
                isStreaming
                    ? [true, true, true, true, true, true, true, true, true, true]
                    : List.filled(10, false),
              ),
              const SizedBox(height: 8),
              _buildPillRow(
                isStreaming
                    ? [true, true, true, true, true, true, true, true, true, true]
                    : List.filled(10, false),
                isCurrent: isStreaming,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillRow(List<bool> states, {bool isCurrent = false}) {
    return Row(
      children: List.generate(states.length, (index) {
        final isFilled = states[index];
        final isLatest = isCurrent && index == states.length - 1;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            height: 14,
            decoration: BoxDecoration(
              color: isLatest
                  ? AppColors.primaryWhite
                  : (isFilled
                      ? const Color(0xFFE5E5EA)
                      : Colors.white.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(7),
              border: isLatest
                  ? Border.all(color: AppColors.accentCyan, width: 2)
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// ── 4. Split Two-Column Bento Section ───────────────────────────────────────
class _SplitBentoSection extends ConsumerWidget {
  const _SplitBentoSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(dashboardTelemetryProvider);

    final accelX = telemetry.latestAccelX ?? 0.0;
    final accelY = telemetry.latestAccelY ?? 0.0;
    final accelZ = telemetry.latestAccelZ ?? 0.0;
    final hasAccel = telemetry.latestAccelX != null;

    final mag = hasAccel
        ? math.sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ)
        : 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Bento: Rolling Energy Trend
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 180,
            decoration: AppStyles.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.bolt_rounded, color: AppColors.accentCyan, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Motion Energy',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Text('rolling buffer', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                const SizedBox(height: 6),
                Text(
                  hasAccel ? '${(mag / 9.8).toStringAsFixed(2)}g' : '--',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                RepaintBoundary(
                  child: SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _DynamicSparklinePainter(
                        spots: telemetry.accelZSpots,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Right Bento: 3-Axis Motion Live Bars
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 180,
            decoration: AppStyles.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.view_in_ar_rounded, color: AppColors.textSecondary, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '3-Axis Live',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: hasAccel ? AppColors.accentGreenBg : AppColors.cardElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        hasAccel ? '50Hz' : 'Idle',
                        style: hasAccel ? AppStyles.badgeGreen : AppStyles.statLabel,
                      ),
                    ),
                  ],
                ),
                const Text('accel vectors', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      hasAccel ? mag.toStringAsFixed(1) : '--',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (hasAccel) ...[
                      const SizedBox(width: 4),
                      const Text('m/s²', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPillMeter('X', hasAccel ? (accelX.abs() / 15.0).clamp(0.05, 1.0) : 0.0, hasAccel ? accelX.toStringAsFixed(0) : '0'),
                    _buildPillMeter('Y', hasAccel ? (accelY.abs() / 15.0).clamp(0.05, 1.0) : 0.0, hasAccel ? accelY.toStringAsFixed(0) : '0'),
                    _buildPillMeter('Z', hasAccel ? (accelZ.abs() / 15.0).clamp(0.05, 1.0) : 0.0, hasAccel ? accelZ.toStringAsFixed(0) : '0'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillMeter(String label, double fillPct, String topValue) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(topValue, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 14,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 14,
            height: (38 * fillPct).clamp(2.0, 38.0),
            decoration: BoxDecoration(
              color: const Color(0xFFD1D1D6),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ── 5. Heart Rate Waveform Section ──────────────────────────────────────────
class _HeartRateWaveformSection extends ConsumerWidget {
  const _HeartRateWaveformSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(dashboardTelemetryProvider);
    final spots = telemetry.hrSpots;
    final latest = telemetry.latestHr;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppStyles.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.favorite_rounded, color: AppColors.accentRed, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Polar Verity Heart Rate',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  latest != null ? '$latest BPM' : '-- BPM',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 130,
              child: spots.isEmpty
                  ? _buildEmptyWaveformPlaceholder('Awaiting Polar Verity Sense heart rate stream...')
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 30,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.white.withValues(alpha: 0.04),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 40,
                              getTitlesWidget: _buildLeftAxisTitle,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 40,
                        maxY: 200,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.25,
                            color: AppColors.primaryWhite,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      duration: Duration.zero, // Zero animation overhead for real-time streams
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 6. Accelerometer Waveform Section ───────────────────────────────────────
class _AccelerometerWaveformSection extends ConsumerWidget {
  const _AccelerometerWaveformSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(dashboardTelemetryProvider);
    final spotsX = telemetry.accelXSpots;
    final spotsY = telemetry.accelYSpots;
    final spotsZ = telemetry.accelZSpots;

    final hasData = spotsX.isNotEmpty;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppStyles.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.vibration_rounded, color: AppColors.accentCyan, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'IMU Accelerometer (XYZ)',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildTraceLegend('X', AppColors.primaryWhite, telemetry.latestAccelX),
                    const SizedBox(width: 8),
                    _buildTraceLegend('Y', AppColors.accentCyan, telemetry.latestAccelY),
                    const SizedBox(width: 8),
                    _buildTraceLegend('Z', AppColors.textSecondary, telemetry.latestAccelZ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 140,
              child: !hasData
                  ? _buildEmptyWaveformPlaceholder('Awaiting 3-axis accelerometer sensor stream...')
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 8,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.white.withValues(alpha: 0.04),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 10,
                              getTitlesWidget: _buildLeftAxisTitle,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: -20,
                        maxY: 25,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spotsX,
                            isCurved: false,
                            color: AppColors.primaryWhite,
                            barWidth: 1.5,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: spotsY,
                            isCurved: false,
                            color: AppColors.accentCyan,
                            barWidth: 1.5,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: spotsZ,
                            isCurved: false,
                            color: AppColors.textSecondary,
                            barWidth: 1.5,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                      duration: Duration.zero,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraceLegend(String label, Color color, double? value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          value != null ? '$label: ${value.toStringAsFixed(1)}' : label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ── 7. Gyroscope Waveform Section ───────────────────────────────────────────
class _GyroscopeWaveformSection extends ConsumerWidget {
  const _GyroscopeWaveformSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(dashboardTelemetryProvider);
    final spotsX = telemetry.gyroXSpots;
    final spotsY = telemetry.gyroYSpots;

    final hasData = spotsX.isNotEmpty;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppStyles.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.screen_rotation_alt_rounded, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Gyroscope Angular Velocity',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
                Text('rad/s', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 110,
              child: !hasData
                  ? _buildEmptyWaveformPlaceholder('Awaiting gyroscope telemetry...')
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.white.withValues(alpha: 0.04),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spotsX,
                            isCurved: false,
                            color: AppColors.primaryWhite,
                            barWidth: 1.2,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: spotsY,
                            isCurved: false,
                            color: AppColors.textSecondary,
                            barWidth: 1.2,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                      duration: Duration.zero,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Helpers ──────────────────────────────────────────────────────────
Widget _buildEmptyWaveformPlaceholder(String message) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.show_chart_rounded, size: 24, color: AppColors.textTertiary),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLeftAxisTitle(double value, TitleMeta meta) {
  return Text(
    value.toInt().toString(),
    style: const TextStyle(color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w600),
  );
}

// ── Dynamic Sparkline Painter ───────────────────────────────────────────────
class _DynamicSparklinePainter extends CustomPainter {
  final List<FlSpot> spots;

  _DynamicSparklinePainter({required this.spots});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    if (spots.length < 2) {
      // Draw a subtle flat baseline when no data is received
      canvas.drawLine(
        Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.5),
        paint..color = Colors.white.withValues(alpha: 0.15),
      );
      return;
    }

    final path = Path();
    final double minX = spots.first.x;
    final double maxX = spots.last.x;
    final double rangeX = (maxX - minX).abs() > 0.0001 ? (maxX - minX) : 1.0;

    double minY = spots.map((s) => s.y).reduce(math.min);
    double maxY = spots.map((s) => s.y).reduce(math.max);
    if ((maxY - minY).abs() < 0.001) {
      minY -= 1.0;
      maxY += 1.0;
    }

    for (int i = 0; i < spots.length; i++) {
      final s = spots[i];
      final px = ((s.x - minX) / rangeX) * size.width;
      final py = size.height - ((s.y - minY) / (maxY - minY)) * size.height;

      if (i == 0) {
        path.moveTo(px, py.clamp(0.0, size.height));
      } else {
        path.lineTo(px, py.clamp(0.0, size.height));
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DynamicSparklinePainter oldDelegate) => true;
}
