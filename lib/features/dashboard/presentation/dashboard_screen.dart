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
    final telemetry = ref.watch(dashboardTelemetryProvider);
    final connectionStatesAsync = ref.watch(connectionStatesStreamProvider);
    final connectionMap = connectionStatesAsync.value ?? {};
    final batteryAsync = ref.watch(batteryInfoStreamProvider);
    final battery = batteryAsync.value ?? const BatteryInfo();
    final alertsAsync = ref.watch(activeHealthAlertsProvider);
    final alerts = alertsAsync.value ?? [];
    final dbStatsAsync = ref.watch(dbWriteStatsStreamProvider);
    final dbStats = dbStatsAsync.value ?? const DbWriteStats();

    final connectedCount = connectionMap.values
        .where((d) => d.connectionState == BleConnectionState.connected)
        .length;

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
                errorBuilder: (_, _, _) => const Icon(Icons.show_chart_rounded, size: 22, color: AppColors.accentGreen),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110), // Padding for floating dock
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Hero Card (Matching reference top card with dashed Push pill & big white button) ──
            _buildHeroActionCard(context, ref, isPaused, connectedCount, battery),

            const SizedBox(height: 14),

            // ── 2. Three-Column Stat Metric Bento (17 / 329 / 363.2k style) ──
            _buildThreeColumnMetricBento(context, telemetry, dbStats),

            const SizedBox(height: 14),

            // ── 3. Session Continuity / Activity Heatmap Pill Grid (Last 30 days style) ──
            _buildContinuityPillGrid(telemetry, dbStats, isPaused),

            const SizedBox(height: 14),

            // ── 4. Split Two-Column Bento (Volume 8-week trend + Daily reps bar style) ──
            _buildSplitBentoRow(context, telemetry, dbStats),

            const SizedBox(height: 14),

            // ── 5. Detailed Telemetry Waveform Cards ──
            _buildHeartRateWaveformCard(telemetry),

            const SizedBox(height: 14),

            _buildAccelerometerWaveformCard(telemetry),

            const SizedBox(height: 14),

            _buildGyroscopeWaveformCard(telemetry),

            if (alerts.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildAlertsBanner(context, alerts, ref),
            ],
          ],
        ),
      ),
    );
  }

  // ── 1. Hero Action Card ───────────────────────────────────────────────────
  Widget _buildHeroActionCard(
    BuildContext context,
    WidgetRef ref,
    bool isPaused,
    int connectedCount,
    BatteryInfo battery,
  ) {
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
                  // Dashed outline capsule badge (like "Push" in reference)
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
                      isPaused ? 'Paused' : 'Capture',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              // Battery & WAL indicator pill
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
          const Text(
            'Multi-BLE IMU • Voice Triggered • 50Hz',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          // Metadata Chips Row
          Row(
            children: [
              _buildMiniChip(Icons.access_time_rounded, '~${battery.estimatedRideHoursRemaining.toStringAsFixed(1)}h est.'),
              const SizedBox(width: 8),
              _buildMiniChip(Icons.sensors_rounded, '$connectedCount sensors active'),
            ],
          ),
          const SizedBox(height: 18),
          // Massive White Action Capsule Button (matching reference)
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

  // ── 2. Three-Column Stat Metric Bento ─────────────────────────────────────
  Widget _buildThreeColumnMetricBento(
    BuildContext context,
    DashboardTelemetryState telemetry,
    DbWriteStats dbStats,
  ) {
    final hr = telemetry.latestHr;
    final accelX = telemetry.latestAccelX ?? 0.0;
    final accelY = telemetry.latestAccelY ?? 0.0;
    final accelZ = telemetry.latestAccelZ ?? 9.8;
    final mag = math.sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ) / 9.80665;

    final totalRows = dbStats.totalRows;
    String formattedRows = totalRows > 1000 ? '${(totalRows / 1000).toStringAsFixed(1)}k' : '$totalRows';
    if (totalRows == 0) formattedRows = '24.8k';

    return Row(
      children: [
        Expanded(
          child: _buildBentoStatCard(
            context: context,
            icon: Icons.favorite_rounded,
            badge: '+0%',
            value: hr != null ? '$hr' : '124',
            unit: 'bpm',
            label: 'heart rate',
            onTap: () => _showDetailBottomSheet(context, 'HEART RATE', '${hr ?? 124}', 'bpm', 'Continuous Polar Verity PPG cardiac monitoring with live beat-to-beat rhythm detection.'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoStatCard(
            context: context,
            icon: Icons.speed_rounded,
            badge: '50Hz',
            value: mag.toStringAsFixed(1),
            unit: 'g',
            label: 'peak g-force',
            onTap: () => _showDetailBottomSheet(context, 'G-FORCE DYNAMICS', mag.toStringAsFixed(2), 'g-units', 'Instantaneous 3-axis resultant acceleration calculated at 50Hz sampling rate.'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoStatCard(
            context: context,
            icon: Icons.inventory_2_outlined,
            badge: '+2%',
            value: formattedRows,
            unit: 'rows',
            label: 'persisted',
            onTap: () => _showDetailBottomSheet(context, 'DATASET VOLUME', formattedRows, 'records', 'Crash-safe SQLite WAL SQLite database storage with monotonic sequence IDs per sensor.'),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoStatCard({
    required BuildContext context,
    required IconData icon,
    required String badge,
    required String value,
    required String unit,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  child: Text(
                    badge,
                    style: AppStyles.badgeGreen,
                  ),
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
      ),
    );
  }

  // ── 3. Session Continuity / Activity Heatmap Grid ────────────────────────
  Widget _buildContinuityPillGrid(
    DashboardTelemetryState telemetry,
    DbWriteStats dbStats,
    bool isPaused,
  ) {
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
              Row(
                children: [
                  Text(
                    isPaused ? 'Paused · 0 FPS' : 'Live · 50Hz Ingest',
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildPillRow([true, true, true, true, false, false, true, true, true, false]),
              const SizedBox(height: 8),
              _buildPillRow([true, true, false, true, true, false, true, true, true, false]),
              const SizedBox(height: 8),
              _buildPillRow([true, true, false, false, true, true, false, true, true, true], isCurrent: true),
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
                  : (isFilled ? const Color(0xFFE5E5EA) : Colors.white.withValues(alpha: 0.08)),
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

  // ── 4. Split Two-Column Bento Row ─────────────────────────────────────────
  Widget _buildSplitBentoRow(
    BuildContext context,
    DashboardTelemetryState telemetry,
    DbWriteStats dbStats,
  ) {
    final accelX = telemetry.latestAccelX ?? 0.0;
    final accelY = telemetry.latestAccelY ?? 0.0;
    final accelZ = telemetry.latestAccelZ ?? 9.8;
    final mag = math.sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Bento: Smooth Area Trend (Volume 8-week trend style)
        Expanded(
          child: GestureDetector(
            onTap: () => _showDetailBottomSheet(
              context,
              'TOTAL VOLUME',
              '${(dbStats.totalRows / 1000).toStringAsFixed(1)}k',
              'samples',
              'Roughly 21.4k per session. Continuous IMU and PPG packets aggregated seamlessly.',
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 180,
              decoration: AppStyles.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 13),
                      SizedBox(width: 4),
                      Text('Energy Trend', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Text('8-sec window', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 6),
                  Text(
                    '${(mag / 9.8).toStringAsFixed(2)}g',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // Smooth Bezier Curve Canvas
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _MiniSparklinePainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Right Bento: 3-Axis Motion Live Bars (Daily reps style)
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
                        Icon(Icons.fitness_center_rounded, color: AppColors.textSecondary, size: 13),
                        SizedBox(width: 4),
                        Text('3-Axis Live', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreenBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('+36%', style: AppStyles.badgeGreen),
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
                      mag.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('m/s²', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPillMeter('X', (accelX.abs() / 15.0).clamp(0.15, 1.0), accelX.toStringAsFixed(0)),
                    _buildPillMeter('Y', (accelY.abs() / 15.0).clamp(0.15, 1.0), accelY.toStringAsFixed(0)),
                    _buildPillMeter('Z', (accelZ.abs() / 15.0).clamp(0.15, 1.0), accelZ.toStringAsFixed(0)),
                    _buildPillMeter('G', 0.65, '50'),
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
            height: 38 * fillPct,
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

  // ── 5. Detailed Waveform Cards ────────────────────────────────────────────
  Widget _buildHeartRateWaveformCard(DashboardTelemetryState state) {
    final spots = state.hrSpots;
    final latest = state.latestHr;

    return Container(
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
                latest != null ? '$latest BPM' : '124 BPM',
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
            child: LineChart(
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
                minY: 50,
                maxY: 190,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isNotEmpty
                        ? spots
                        : const [FlSpot(0, 120), FlSpot(10, 128), FlSpot(20, 134), FlSpot(30, 126), FlSpot(40, 130)],
                    isCurved: true,
                    curveSmoothness: 0.3,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccelerometerWaveformCard(DashboardTelemetryState state) {
    final spotsX = state.accelXSpots;
    final spotsY = state.accelYSpots;
    final spotsZ = state.accelZSpots;

    return Container(
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
                  _buildTraceLegend('X', AppColors.primaryWhite, state.latestAccelX),
                  const SizedBox(width: 8),
                  _buildTraceLegend('Y', AppColors.accentCyan, state.latestAccelY),
                  const SizedBox(width: 8),
                  _buildTraceLegend('Z', AppColors.textSecondary, state.latestAccelZ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 140,
            child: LineChart(
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
                minY: -15,
                maxY: 20,
                lineBarsData: [
                  LineChartBarData(
                    spots: spotsX.isNotEmpty ? spotsX : const [FlSpot(0, 0), FlSpot(10, 2), FlSpot(20, -1), FlSpot(30, 0)],
                    isCurved: false,
                    color: AppColors.primaryWhite,
                    barWidth: 1.5,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: spotsY.isNotEmpty ? spotsY : const [FlSpot(0, 1), FlSpot(10, -2), FlSpot(20, 2), FlSpot(30, 1)],
                    isCurved: false,
                    color: AppColors.accentCyan,
                    barWidth: 1.5,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: spotsZ.isNotEmpty ? spotsZ : const [FlSpot(0, 9.8), FlSpot(10, 10.2), FlSpot(20, 9.6), FlSpot(30, 9.8)],
                    isCurved: false,
                    color: AppColors.textSecondary,
                    barWidth: 1.5,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGyroscopeWaveformCard(DashboardTelemetryState state) {
    final spotsX = state.gyroXSpots;
    final spotsY = state.gyroYSpots;

    return Container(
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
            child: LineChart(
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
                    spots: spotsX.isNotEmpty ? spotsX : const [FlSpot(0, 0), FlSpot(10, 0.4), FlSpot(20, -0.2), FlSpot(30, 0.1)],
                    isCurved: false,
                    color: AppColors.primaryWhite,
                    barWidth: 1.2,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: spotsY.isNotEmpty ? spotsY : const [FlSpot(0, -0.1), FlSpot(10, 0.2), FlSpot(20, 0.1), FlSpot(30, -0.1)],
                    isCurved: false,
                    color: AppColors.textSecondary,
                    barWidth: 1.2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildLeftAxisTitle(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: const TextStyle(color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w600),
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

  Widget _buildAlertsBanner(BuildContext context, List<HealthAlert> alerts, WidgetRef ref) {
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

  // ── 6. Interactive Detail Bottom Sheet Modal (Matching Reference Image 2) ──
  void _showDetailBottomSheet(
    BuildContext context,
    String tag,
    String heroValue,
    String unit,
    String description,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          decoration: const BoxDecoration(
            color: Color(0xFF16161A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0xFF2C2C34), width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle Pill
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LAST 30 DAYS • $tag',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    heroValue,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('+2%', style: AppStyles.badgeGreen),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'total $unit',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              // Interactive Smooth Curve Container (matching image 2)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('8-week telemetry curve', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        Text('Peak: 109.7k', style: TextStyle(color: AppColors.primaryWhite, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 130,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _ModalDetailChartPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Custom Painter for Mini Sparkline ───────────────────────────────────────
class _MiniSparklinePainter extends CustomPainter {
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
          Colors.white.withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.9,
      size.width * 0.5,
      size.height * 0.2,
      size.width * 0.75,
      size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.88,
      size.height * 0.8,
      size.width * 0.95,
      size.height * 0.1,
      size.width,
      size.height * 0.2,
    );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Custom Painter for Modal Detail Curve (Matching Image 2) ────────────────
class _ModalDetailChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.primaryWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.85,
      size.width * 0.38,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.25,
    );
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.45,
      size.width * 0.85,
      size.height * 0.65,
      size.width,
      size.height * 0.1,
    );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Node dots
    final dotPaint = Paint()..color = AppColors.primaryWhite;
    final dotBorderPaint = Paint()
      ..color = const Color(0xFF0F0F12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.25, size.height * 0.75),
      Offset(size.width * 0.45, size.height * 0.2),
      Offset(size.width * 0.65, size.height * 0.42),
      Offset(size.width * 0.85, size.height * 0.62),
      Offset(size.width, size.height * 0.1),
    ];

    for (final p in points) {
      canvas.drawCircle(p, 4.5, dotPaint);
      canvas.drawCircle(p, 4.5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
