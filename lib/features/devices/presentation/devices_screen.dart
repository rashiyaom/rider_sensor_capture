import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ble/models/ble_device_model.dart';
import '../../../ble/models/raw_sensor_data.dart';
import '../../../ble/services/ble_permission_service.dart';
import '../../../core/services/battery_service.dart';
import '../../../core/services/session_health_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/battery_providers.dart';
import '../../../providers/ble_providers.dart';
import '../../../providers/db_providers.dart';
import '../../../providers/session_health_providers.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  bool _isScanning = false;
  String? _selectedTerminalDeviceId;
  final List<RawSensorData> _recentLogs = [];
  final List<RawSensorData> _incomingLogBuffer = [];
  StreamSubscription<RawSensorData>? _rawLogSubscription;
  Timer? _logThrottleTimer;

  @override
  void initState() {
    super.initState();
    _subscribeToRawData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bleScannerProvider).refreshConnectedAndSystemDevices();
    });
  }

  void _subscribeToRawData() {
    final manager = ref.read(bleConnectionManagerProvider);
    _rawLogSubscription = manager.rawDataStream.listen((data) {
      _incomingLogBuffer.insert(0, data);
      if (_incomingLogBuffer.length > 50) _incomingLogBuffer.removeLast();
    });

    // Throttled UI refresh to prevent high-frequency 50Hz frame drops
    _logThrottleTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (_incomingLogBuffer.isNotEmpty && mounted) {
        setState(() {
          _recentLogs.clear();
          _recentLogs.addAll(_incomingLogBuffer);
        });
      }
    });
  }

  @override
  void dispose() {
    _logThrottleTimer?.cancel();
    _rawLogSubscription?.cancel();
    super.dispose();
  }

  void _toggleDemoSensors(bool enable) {
    ref.read(bleScannerProvider).toggleDemoDevices(enable);
    setState(() {});
  }

  Future<void> _toggleScan() async {
    final hasPerms = await BlePermissionService.requestBlePermissions();
    if (!hasPerms) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth permissions denied')),
        );
      }
      return;
    }

    final scanner = ref.read(bleScannerProvider);
    if (_isScanning) {
      await scanner.stopScan();
      setState(() => _isScanning = false);
    } else {
      setState(() => _isScanning = true);
      await scanner.startScan();
      if (mounted) {
        Future.delayed(const Duration(seconds: 15), () {
          if (mounted && _isScanning) {
            setState(() => _isScanning = false);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(bleToDbBridgeProvider);

    final discoveredAsync = ref.watch(discoveredDevicesStreamProvider);
    final connectionStatesAsync = ref.watch(connectionStatesStreamProvider);
    final dbStatsAsync = ref.watch(dbWriteStatsStreamProvider);
    final batteryAsync = ref.watch(batteryInfoStreamProvider);
    final alertsAsync = ref.watch(activeHealthAlertsProvider);

    final isDemoActive = ref.watch(bleScannerProvider).isDemoMode;
    final discoveredDevices = discoveredAsync.value ?? [];
    final connectionMap = connectionStatesAsync.value ?? {};
    final dbStats = dbStatsAsync.value ?? const DbWriteStats();
    final battery = batteryAsync.value ?? const BatteryInfo();
    final alerts = alertsAsync.value ?? [];

    final connectedDevices = connectionMap.values
        .where((d) =>
            d.connectionState == BleConnectionState.connected ||
            d.connectionState == BleConnectionState.connecting ||
            d.connectionState == BleConnectionState.reconnecting ||
            d.connectionState == BleConnectionState.lost)
        .toList();

    final availableDevices = discoveredDevices.where((dev) {
      final active = connectionMap[dev.id];
      if (active != null &&
          (active.connectionState == BleConnectionState.connected ||
              active.connectionState == BleConnectionState.connecting ||
              active.connectionState == BleConnectionState.reconnecting ||
              active.connectionState == BleConnectionState.lost)) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Devices & Hardware'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Devices',
            onPressed: () {
              ref.read(bleScannerProvider).refreshConnectedAndSystemDevices();
            },
          ),
          IconButton(
            icon: Icon(
              _isScanning ? Icons.stop_circle_rounded : Icons.bluetooth_searching_rounded,
              color: _isScanning ? AppColors.accentCyan : AppColors.textPrimary,
            ),
            tooltip: _isScanning ? 'Stop Scan' : 'Start BLE Scan',
            onPressed: _toggleScan,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Hero Action Card ──
            _buildHeroDevicesCard(connectedDevices.length, isDemoActive),

            const SizedBox(height: 14),

            // ── 2. Three-Column Stat Metric Bento ──
            _buildThreeColumnDeviceBento(connectedDevices.length, dbStats.totalRows, battery.batteryLevel),

            const SizedBox(height: 14),

            // ── 3. Connected BLE Sensors Section ──
            if (connectedDevices.isNotEmpty) ...[
              _buildSectionHeader('Connected Hardware', '${connectedDevices.length} active', AppColors.accentGreen),
              const SizedBox(height: 8),
              ...connectedDevices.map((device) {
                final rowCount = dbStats.deviceCounts[device.id] ?? 0;
                return _buildDeviceCard(device, rowCount);
              }),
              const SizedBox(height: 14),
            ],

            // ── 4. Available / Nearby BLE Devices Section ──
            _buildSectionHeader('Available Nearby Devices', '${availableDevices.length} found', AppColors.textSecondary),
            const SizedBox(height: 8),
            if (availableDevices.isEmpty)
              _buildEmptyAvailableCard(isDemoActive)
            else
              ...availableDevices.map((device) {
                final activeModel = connectionMap[device.id] ?? device;
                final rowCount = dbStats.deviceCounts[device.id] ?? 0;
                return _buildDeviceCard(activeModel, rowCount);
              }),

            const SizedBox(height: 18),

            // ── 5. Raw Data Terminal ──
            _buildDebugConsole(),

            if (alerts.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildAlertsBanner(alerts),
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

  // ── 1. Hero Devices Card ──────────────────────────────────────────────────
  Widget _buildHeroDevicesCard(int activeCount, bool isDemoActive) {
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
                    'Bluetooth Low Energy',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
                    ),
                    child: const Text(
                      'HARDWARE',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _toggleDemoSensors(!isDemoActive),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDemoActive ? AppColors.accentAmberBg : AppColors.cardElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDemoActive ? AppColors.accentAmber.withValues(alpha: 0.4) : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: isDemoActive ? AppColors.accentAmber : AppColors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDemoActive ? 'Demo On' : 'Demo Mode',
                        style: TextStyle(
                          color: isDemoActive ? AppColors.accentAmber : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Polar Verity Sense PPG • ESP32-S3 Watch IMU',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
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
              onPressed: _toggleScan,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isScanning ? Icons.stop_circle_rounded : Icons.radar_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isScanning ? 'Stop BLE Hardware Scan' : 'Scan for BLE Sensors',
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

  // ── 2. Three-Column Device Bento ──────────────────────────────────────────
  Widget _buildThreeColumnDeviceBento(int activeCount, int rows, int batteryPct) {
    final formattedRows = rows > 1000 ? '${(rows / 1000).toStringAsFixed(1)}k' : '$rows';

    return Row(
      children: [
        Expanded(
          child: _buildBentoCard(
            icon: Icons.bluetooth_connected_rounded,
            badge: activeCount > 0 ? 'Active' : 'Idle',
            value: '$activeCount',
            label: 'connected',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.speed_rounded,
            badge: activeCount > 0 ? '50Hz' : '0Hz',
            value: activeCount > 0 ? '20ms' : '--',
            label: 'packet rate',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.battery_charging_full_rounded,
            badge: '$batteryPct%',
            value: formattedRows,
            label: 'seq rows',
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required String badge,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: AppStyles.cardDecoration(),
      child: Column(
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
          Text(value, style: AppStyles.heroNumber.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          Text(label, style: AppStyles.statLabel),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badgeText, Color badgeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            badgeText,
            style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ── 3 & 4. Device Tile Card ───────────────────────────────────────────────
  Widget _buildDeviceCard(BleDeviceModel device, int dbRowCount) {
    final manager = ref.read(bleConnectionManagerProvider);
    final connState = device.connectionState;
    final isConnected = connState == BleConnectionState.connected;

    String typeName = 'BLE Sensor';
    IconData typeIcon = Icons.bluetooth_rounded;
    if (device.type == DeviceType.verityBand) {
      typeName = 'Polar Verity Sense';
      typeIcon = Icons.favorite_rounded;
    } else if (device.type == DeviceType.watch) {
      typeName = 'ESP32-S3 Watch';
      typeIcon = Icons.watch_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration(
        backgroundColor: isConnected ? const Color(0xFF16161B) : AppColors.card,
        border: isConnected
            ? Border.all(color: Colors.white.withValues(alpha: 0.15))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isConnected ? AppColors.accentGreenBg : AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(
                  typeIcon,
                  color: isConnected ? AppColors.accentGreen : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name.isNotEmpty ? device.name : device.id,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$typeName  •  ${device.rssi} dBm',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isConnected)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3C3C44)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  onPressed: () => manager.disconnectDevice(device.id),
                  child: const Text('Disconnect', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryWhite,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  ),
                  onPressed: connState == BleConnectionState.connecting
                      ? null
                      : () => manager.connectToDevice(device),
                  child: Text(
                    connState == BleConnectionState.connecting ? '...' : 'Connect',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentGreen),
                  ),
                  const SizedBox(width: 6),
                  const Text('Live 50Hz Stream', style: TextStyle(color: AppColors.accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(
                    '$dbRowCount rows persisted',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyAvailableCard(bool isDemoActive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        children: [
          Icon(
            _isScanning ? Icons.radar_rounded : Icons.bluetooth_disabled_rounded,
            color: _isScanning ? AppColors.accentCyan : AppColors.textSecondary,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            _isScanning
                ? 'Scanning for Polar Verity Sense & ESP32 Watch...'
                : 'No nearby BLE hardware found.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3C3C44)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.textPrimary),
                label: const Text('Rescan', style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                onPressed: _toggleScan,
              ),
              if (!isDemoActive) ...[
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentAmberBg,
                    foregroundColor: AppColors.accentAmber,
                    elevation: 0,
                    side: BorderSide(color: AppColors.accentAmber.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 14),
                  label: const Text('Enable Demo Sensors', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _toggleDemoSensors(true),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. Raw Data Terminal ──────────────────────────────────────────────────
  Widget _buildDebugConsole() {
    final connectionStatesAsync = ref.watch(connectionStatesStreamProvider);
    final connectionMap = connectionStatesAsync.value ?? {};

    // Get connected device IDs + any distinct devices in recent logs
    final availableDeviceIds = <String>{};
    for (var d in connectionMap.values) {
      if (d.connectionState == BleConnectionState.connected) {
        availableDeviceIds.add(d.id);
      }
    }
    for (var l in _recentLogs) {
      availableDeviceIds.add(l.deviceId);
    }

    final filteredLogs = _selectedTerminalDeviceId == null
        ? _recentLogs
        : _recentLogs.where((l) => l.deviceId == _selectedTerminalDeviceId).toList();

    return RepaintBoundary(
      child: Container(
        decoration: AppStyles.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.terminal_rounded, size: 16, color: AppColors.accentGreen),
                      SizedBox(width: 8),
                      Text(
                        'Live Ingest Terminal',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${filteredLogs.length} frames',
                        style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _incomingLogBuffer.clear();
                            _recentLogs.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Text('Clear', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Device Filter Chips Bar for Live Ingest
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTerminalFilterChip(
                      label: 'All Devices',
                      isSelected: _selectedTerminalDeviceId == null,
                      onTap: () => setState(() => _selectedTerminalDeviceId = null),
                    ),
                    ...availableDeviceIds.map((devId) {
                      final name = connectionMap[devId]?.name ??
                          _recentLogs.firstWhere((l) => l.deviceId == devId, orElse: () => _recentLogs.first).deviceName;
                      final isWatch = devId.toLowerCase().contains('watch') || devId.toLowerCase().contains('esp');
                      final isSelected = _selectedTerminalDeviceId == devId;
                      return _buildTerminalFilterChip(
                        label: '${isWatch ? "⌚" : "💓"} ${name.isNotEmpty ? name : devId}',
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedTerminalDeviceId = devId),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Terminal Screen
            Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF070709),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
              ),
              child: filteredLogs.isEmpty
                  ? Center(
                      child: Text(
                        _selectedTerminalDeviceId != null
                            ? 'No incoming frames for selected device.'
                            : 'No frames yet. Connect ESP32-Watch or Polar sensor to view 50Hz binary stream.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        final isWatch = log.deviceType == DeviceType.watch;
                        final timeStr = '${log.timestamp.hour.toString().padLeft(2, "0")}:'
                            '${log.timestamp.minute.toString().padLeft(2, "0")}:'
                            '${log.timestamp.second.toString().padLeft(2, "0")}.'
                            '${(log.timestamp.millisecond ~/ 10).toString().padLeft(2, "0")}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    timeStr,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isWatch ? AppColors.accentCyanBg : AppColors.accentGreenBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      log.deviceName.isNotEmpty ? log.deviceName : log.deviceId,
                                      style: TextStyle(
                                        color: isWatch ? AppColors.accentCyan : AppColors.accentGreen,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (log.heartRate != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentRedBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '❤️ ${log.heartRate} BPM',
                                        style: const TextStyle(color: AppColors.accentRed, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  if (log.accelX != null && log.accelY != null && log.accelZ != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardElevated,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'X:${log.accelX!.toStringAsFixed(1)} Y:${log.accelY!.toStringAsFixed(1)} Z:${log.accelZ!.toStringAsFixed(1)}',
                                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 9, fontFamily: 'monospace'),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                'HEX: ${log.rawHex} (${log.rawBytes.length}B)',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9.5,
                                  color: Color(0xFF9E9EA7),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentGreen : AppColors.cardElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accentGreen : AppColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildAlertsBanner(List<HealthAlert> alerts) {
    final healthService = ref.read(sessionHealthServiceProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentAmberBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: alerts.map((alert) {
          return Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.accentAmber, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${alert.title}: ${alert.message}',
                  style: const TextStyle(color: AppColors.accentAmber, fontSize: 11),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 12, color: AppColors.textSecondary),
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
