import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ble/models/ble_device_model.dart';
import '../../../ble/models/raw_sensor_data.dart';
import '../../../ble/services/ble_permission_service.dart';
import '../../../camera/camera_detection_model.dart';
import '../../../camera/camera_ingest_server.dart';
import '../../../core/services/battery_service.dart';
import '../../../core/services/session_health_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../providers/battery_providers.dart';
import '../../../providers/ble_providers.dart';
import '../../../providers/camera_providers.dart';
import '../../../providers/db_providers.dart';
import '../../../providers/session_health_providers.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  bool _isScanning = false;
  final List<RawSensorData> _recentLogs = [];
  StreamSubscription<RawSensorData>? _rawLogSubscription;
  StreamSubscription<CameraDetectionPayload>? _cameraPayloadSub;

  @override
  void initState() {
    super.initState();
    _subscribeToRawData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoStartCameraServer();
      ref.read(bleScannerProvider).refreshConnectedAndSystemDevices();
    });
  }

  void _subscribeToRawData() {
    final manager = ref.read(bleConnectionManagerProvider);
    _rawLogSubscription = manager.rawDataStream.listen((data) {
      if (mounted) {
        setState(() {
          _recentLogs.insert(0, data);
          if (_recentLogs.length > 30) _recentLogs.removeLast();
        });
      }
    });
  }

  Future<void> _autoStartCameraServer() async {
    final server = ref.read(cameraIngestServerProvider);
    if (!server.isRunning) {
      await server.start();
    }
    _cameraPayloadSub = server.detectionStream.listen((payload) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _rawLogSubscription?.cancel();
    _cameraPayloadSub?.cancel();
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

  Future<void> _toggleCameraServer() async {
    final server = ref.read(cameraIngestServerProvider);
    if (server.isRunning) {
      await server.stop();
    } else {
      await server.start();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(bleToDbBridgeProvider);

    final discoveredAsync = ref.watch(discoveredDevicesStreamProvider);
    final connectionStatesAsync = ref.watch(connectionStatesStreamProvider);
    final dbStatsAsync = ref.watch(dbWriteStatsStreamProvider);
    final cameraStatusAsync = ref.watch(cameraServerStatusProvider);
    final cameraDetectionsAsync = ref.watch(recentCameraDetectionsProvider);
    final batteryAsync = ref.watch(batteryInfoStreamProvider);
    final alertsAsync = ref.watch(activeHealthAlertsProvider);

    final isDemoActive = ref.watch(bleScannerProvider).isDemoMode;
    final discoveredDevices = discoveredAsync.value ?? [];
    final connectionMap = connectionStatesAsync.value ?? {};
    final dbStats = dbStatsAsync.value ?? const DbWriteStats();
    final cameraStatus = cameraStatusAsync.value ?? const CameraServerStatus();
    final cameraDetections = cameraDetectionsAsync.value ?? [];
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

            // ── 5. AI Camera Ingest Server Section ──
            _buildCameraServerCard(cameraStatus, cameraDetections),

            const SizedBox(height: 18),

            // ── 6. Raw Data Terminal ──
            _buildDebugConsole(),

            if (alerts.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildAlertsBanner(alerts),
            ],
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
    return Row(
      children: [
        Expanded(
          child: _buildBentoCard(
            icon: Icons.bluetooth_connected_rounded,
            badge: '+0%',
            value: '$activeCount',
            label: 'connected',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.speed_rounded,
            badge: '50Hz',
            value: '20ms',
            label: 'packet rate',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.battery_charging_full_rounded,
            badge: '$batteryPct%',
            value: '${(rows / 1000).toStringAsFixed(1)}k',
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

  // ── 5. AI Camera Server Card ──────────────────────────────────────────────
  Widget _buildCameraServerCard(CameraServerStatus status, List<CameraDetection> detections) {
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
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: status.isRunning ? AppColors.accentGreenBg : AppColors.cardElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.videocam_rounded,
                      color: status.isRunning ? AppColors.accentGreen : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'AI Camera Ingest Server',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _toggleCameraServer,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status.isRunning ? AppColors.accentRedBg : AppColors.accentGreenBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: status.isRunning ? AppColors.accentRed.withValues(alpha: 0.3) : AppColors.accentGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    status.isRunning ? 'Stop' : 'Start',
                    style: TextStyle(
                      color: status.isRunning ? AppColors.accentRed : AppColors.accentGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status.isRunning
                        ? 'http://${status.addressLabel}/camera-event'
                        : 'Server inactive',
                    style: const TextStyle(fontFamily: 'monospace', color: AppColors.textPrimary, fontSize: 11),
                  ),
                ),
                if (status.isRunning)
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'http://${status.addressLabel}/camera-event'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Endpoint copied to clipboard')),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Raw Data Terminal ──────────────────────────────────────────────────
  Widget _buildDebugConsole() {
    return Container(
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Live Ingest Terminal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                Text('${_recentLogs.length} frames', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Container(
            height: 140,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF070709),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child: _recentLogs.isEmpty
                ? const Center(
                    child: Text('No frames yet. Connect a sensor to view stream.', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  )
                : ListView.builder(
                    itemCount: _recentLogs.length,
                    itemBuilder: (context, index) {
                      final log = _recentLogs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Text(
                          log.toString(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: log.deviceType == DeviceType.verityBand
                                ? AppColors.accentGreen
                                : AppColors.accentCyan,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
