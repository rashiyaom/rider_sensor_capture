import 'dart:async';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
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
          // Start/Stop Ride Session
          IconButton(
            icon: const Icon(Icons.flag_rounded),
            tooltip: 'Session management',
            onPressed: () => _showSessionManagementSheet(context, ref),
          ),
          IconButton(
            icon: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: isPaused ? AppColors.accentAmber : AppColors.textPrimary,
            ),
            tooltip: isPaused ? 'Resume live stream' : 'Pause live stream',
            onPressed: () {
              HapticFeedback.lightImpact();
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
            // ── 0. Device Selector Bar (Cumulative vs Individual Sensors) ──
            const _DashboardDeviceSelectorSection(),

            // ── 1. Hero Card (or Zero-State CTA if no devices) ──
            const _HeroActionSection(),

            const SizedBox(height: 14),

            // ── 2. Three-Column Stat Metric Bento ──
            const _ThreeColumnMetricBentoSection(),

            const SizedBox(height: 14),

            // ── 3. Session Continuity Grid (Real Packet Rate) ──
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

            // ── Footer branding ──
            const SizedBox(height: 20),
            Center(
              child: Text(
                'made by rashiyaom',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.12),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showSessionManagementSheet(BuildContext context, WidgetRef ref) async {
    final dbStats = ref.read(dbWriteStatsStreamProvider).value ?? const DbWriteStats();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ride Session Management',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${dbStats.totalRows} sensor readings stored',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              // Reset Chart Buffers
              _buildSheetAction(
                icon: Icons.refresh_rounded,
                label: 'Reset Live Chart Buffers',
                subtitle: 'Clears in-memory waveforms only — SQLite data stays',
                color: AppColors.accentCyan,
                onTap: () {
                  ref.read(dashboardTelemetryProvider.notifier).reset();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Live chart buffers cleared')),
                  );
                },
              ),
              const SizedBox(height: 10),
              // Clear All Telemetry
              _buildSheetAction(
                icon: Icons.delete_sweep_rounded,
                label: 'Clear All Telemetry Data',
                subtitle: 'Permanently deletes ALL sensor readings from SQLite',
                color: AppColors.accentRed,
                isDestructive: true,
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.card,
                      title: const Text('Clear All Telemetry?', style: TextStyle(color: AppColors.textPrimary)),
                      content: const Text(
                        'This will permanently delete all sensor readings from SQLite. This action cannot be undone.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete All', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(sensorRepositoryProvider).deleteAllReadings();
                    ref.read(dashboardTelemetryProvider.notifier).reset();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🗑 All telemetry data cleared')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSheetAction({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: isDestructive ? AppColors.accentRed : AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 18),
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


// ── 0. Device Selector Bar (Cumulative vs Individual Sensors) ──────────────
class _DashboardDeviceSelectorSection extends ConsumerWidget {
  const _DashboardDeviceSelectorSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(dashboardSelectedDeviceIdProvider);
    final connectionStatesAsync = ref.watch(connectionStatesStreamProvider);
    final connectionMap = connectionStatesAsync.value ?? {};

    final activeDevices = connectionMap.values
        .where((d) =>
            d.connectionState == BleConnectionState.connected ||
            d.connectionState == BleConnectionState.connecting ||
            d.connectionState == BleConnectionState.reconnecting)
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildDeviceChip(
              label: '📊 Cumulative (All Sensors)',
              isSelected: selectedId == null,
              onTap: () {
                ref.read(dashboardSelectedDeviceIdProvider.notifier).state = null;
              },
            ),
            ...activeDevices.map((dev) {
              final isSelected = selectedId == dev.id;
              final icon = dev.type == DeviceType.watch ? '⌚' : '💓';
              return _buildDeviceChip(
                label: '$icon ${dev.name.isNotEmpty ? dev.name : dev.id}',
                isSelected: isSelected,
                onTap: () {
                  ref.read(dashboardSelectedDeviceIdProvider.notifier).state = dev.id;
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryWhite : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryWhite : AppColors.cardBorder,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 1. Hero Action Section ──────────────────────────────────────────────────
class _HeroActionSection extends ConsumerStatefulWidget {
  const _HeroActionSection();

  @override
  ConsumerState<_HeroActionSection> createState() => _HeroActionSectionState();
}

class _HeroActionSectionState extends ConsumerState<_HeroActionSection> {
  bool _showInfoGuide = false;

  @override
  Widget build(BuildContext context) {
    final isPaused = ref.watch(dashboardPausedProvider);
    final telemetry = ref.watch(dashboardTelemetryProvider);
    final selectedId = telemetry.selectedDeviceId;
    final connectionStatesAsync = ref.watch(connectionStatesStreamProvider);
    final connectionMap = connectionStatesAsync.value ?? {};
    final batteryAsync = ref.watch(batteryInfoStreamProvider);
    final battery = batteryAsync.value ?? const BatteryInfo();

    final connectedCount = connectionMap.values
        .where((d) => d.connectionState == BleConnectionState.connected)
        .length;

    // ── Zero-State Onboarding CTA ──
    if (connectedCount == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppStyles.cardDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyanBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.sensors_rounded, color: AppColors.accentCyan, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Sensors Connected',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Connect your ESP32-Watch or Polar Verity to start streaming',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Collapsible Info / Setup Guide Toggle
            GestureDetector(
              onTap: () => setState(() => _showInfoGuide = !_showInfoGuide),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _showInfoGuide ? AppColors.accentCyan.withValues(alpha: 0.4) : AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.accentCyan),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Quick Setup Instructions',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      _showInfoGuide ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            if (_showInfoGuide) ...[
              const SizedBox(height: 14),
              _buildSetupStep(num: '1', title: 'Connect BLE Hardware', desc: 'Tap Devices tab, scan for ESP32-S3 Watch or Polar Verity Sense.', color: AppColors.accentCyan),
              const SizedBox(height: 10),
              _buildSetupStep(num: '2', title: 'Start Riding & Streaming', desc: 'Once connected, 50Hz IMU + PPG telemetry appears live on this dashboard.', color: AppColors.accentGreen),
              const SizedBox(height: 10),
              _buildSetupStep(num: '3', title: 'Label Events & Export', desc: 'Tag bumps, turns, and brakes in Events tab, then export labeled CSV/JSON.', color: AppColors.accentAmber),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryWhite,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                onPressed: () => AppNavigator.goToDevices(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bluetooth_searching_rounded, color: Colors.black, size: 20),
                    SizedBox(width: 10),
                    Text('Scan & Connect Hardware', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentAmberBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppColors.accentAmber, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Enable Demo Mode in Devices tab to simulate live data without hardware.',
                      style: TextStyle(color: AppColors.accentAmber, fontSize: 10.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ── Live Connected Hero ──
    final isSpecificConnected = selectedId != null &&
        connectionMap[selectedId]?.connectionState == BleConnectionState.connected;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedId != null ? 'Dedicated Telemetry' : 'Session Ingest',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
                      ),
                      child: Text(
                        isPaused
                            ? 'Paused'
                            : (selectedId != null
                                ? (isSpecificConnected ? telemetry.selectedDeviceName : 'Sensor Standby')
                                : (connectedCount > 0 ? 'Live Cumulative' : 'Standby')),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.cardElevated, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)),
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
                      style: TextStyle(color: battery.isLowBattery ? AppColors.accentAmber : AppColors.accentGreen, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            selectedId != null
                ? (isSpecificConnected
                    ? 'Streaming 50Hz binary telemetry from ${telemetry.selectedDeviceName}'
                    : 'Target sensor disconnected or waiting for BLE connect')
                : (connectedCount > 0
                    ? '$connectedCount BLE sensor${connectedCount > 1 ? "s" : ""} streaming simultaneously at 50Hz'
                    : 'No sensor connected · Connect BLE hardware in Devices tab'),
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          // Wrap ensures no horizontal overflow on narrow screens
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMiniChip(Icons.access_time_rounded, '~${battery.estimatedRideHoursRemaining.toStringAsFixed(1)}h battery'),
              _buildMiniChip(
                Icons.sensors_rounded,
                selectedId != null
                    ? (isSpecificConnected ? '1 sensor active' : 'Offline')
                    : '$connectedCount sensor${connectedCount != 1 ? "s" : ""} active',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: () => ref.read(dashboardPausedProvider.notifier).state = !isPaused,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.black, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isPaused ? 'Resume Telemetry' : 'Pause Live Stream',
                    style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupStep({required String num, required String title, required String desc, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22, height: 22, alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.3))),
          child: Text(num, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.cardElevated, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 13),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
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

    final selectedId = telemetry.selectedDeviceId;
    final int rowsCount = selectedId != null
        ? (dbStats.deviceCounts[selectedId] ?? 0)
        : dbStats.totalRows;

    final formattedRows = rowsCount > 1000
        ? '${(rowsCount / 1000).toStringAsFixed(1)}k'
        : '$rowsCount';

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
            badge: 'Live SQLite',
            value: formattedRows,
            unit: 'rows',
            label: selectedId != null ? 'sensor rows' : 'persisted rows',
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

// ── 3. Session Continuity Grid Section (Real Packet Rate) ────────────────────
class _ContinuityPillGridSection extends ConsumerStatefulWidget {
  const _ContinuityPillGridSection();

  @override
  ConsumerState<_ContinuityPillGridSection> createState() => _ContinuityPillGridSectionState();
}

class _ContinuityPillGridSectionState extends ConsumerState<_ContinuityPillGridSection> {
  static const int _numPills = 30;
  static const int _windowMs = 200; // each pill = 200ms window
  final List<bool> _pillStates = List.filled(_numPills, false);
  DateTime? _lastPacketTime;
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    // Subscribe to raw data stream to track real packets
    final manager = ref.read(bleConnectionManagerProvider);
    manager.rawDataStream.listen((_) {
      _lastPacketTime = DateTime.now();
    });

    // Update pill grid every 200ms based on actual packet arrivals
    _uiTimer = Timer.periodic(const Duration(milliseconds: _windowMs), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      final receivedInWindow = _lastPacketTime != null &&
          now.difference(_lastPacketTime!).inMilliseconds <= _windowMs * 2;

      setState(() {
        // Shift all pills left, append new state at the end
        for (int i = 0; i < _numPills - 1; i++) {
          _pillStates[i] = _pillStates[i + 1];
        }
        _pillStates[_numPills - 1] = receivedInWindow;
      });
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = ref.watch(dashboardPausedProvider);
    final connectionStatesAsync = ref.watch(connectionStatesStreamProvider);
    final connectionMap = connectionStatesAsync.value ?? {};

    final hasActiveConnection = connectionMap.values.any(
      (d) => d.connectionState == BleConnectionState.connected,
    );

    final greenCount = _pillStates.where((p) => p).length;
    final pct = _numPills > 0 ? (greenCount / _numPills * 100).toStringAsFixed(0) : '0';

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
                'Packet Continuity',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                isPaused
                    ? 'Paused'
                    : (hasActiveConnection
                        ? '$pct% delivery · ${greenCount * 5}Hz est.'
                        : 'Standby · No Sensor'),
                style: TextStyle(
                  color: hasActiveConnection && !isPaused ? AppColors.accentGreen : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildPillRow(_pillStates.sublist(0, 10)),
              const SizedBox(height: 8),
              _buildPillRow(_pillStates.sublist(10, 20)),
              const SizedBox(height: 8),
              _buildPillRow(_pillStates.sublist(20, 30), isLatestRow: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillRow(List<bool> states, {bool isLatestRow = false}) {
    return Row(
      children: List.generate(states.length, (index) {
        final isFilled = states[index];
        final isLatest = isLatestRow && index == states.length - 1;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            height: 14,
            decoration: BoxDecoration(
              color: isLatest
                  ? AppColors.primaryWhite
                  : (isFilled
                      ? AppColors.accentGreen
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
