import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ble/models/ble_device_model.dart';
import '../../features/events/event_recording_controller.dart';
import '../../providers/battery_providers.dart';
import '../../providers/ble_providers.dart';

enum AlertSeverity {
  info,
  warning,
  critical,
}

class HealthAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String? deviceId;

  const HealthAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.deviceId,
  });
}

class SessionHealthService {
  final Ref ref;
  final StreamController<List<HealthAlert>> _alertsController =
      StreamController<List<HealthAlert>>.broadcast();

  Timer? _watchdogTimer;
  final Set<String> _dismissedAlertIds = {};
  List<HealthAlert> _activeAlerts = [];

  SessionHealthService(this.ref) {
    _startWatchdog();
  }

  Stream<List<HealthAlert>> get alertsStream => _alertsController.stream;
  List<HealthAlert> get activeAlerts => List.unmodifiable(_activeAlerts);

  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _runHealthCheck();
    });
  }

  void _runHealthCheck() {
    final now = DateTime.now();
    final alerts = <HealthAlert>[];

    // 1. Check BLE Device States & Silences
    final bleManager = ref.read(bleConnectionManagerProvider);
    final devices = bleManager.currentDeviceStates;

    for (final device in devices.values) {
      if (device.connectionState == BleConnectionState.lost) {
        final alertId = 'ble_lost_${device.id}';
        if (!_dismissedAlertIds.contains(alertId)) {
          alerts.add(
            HealthAlert(
              id: alertId,
              title: 'BLE Link Lost',
              message: '${device.name.isEmpty ? device.id : device.name} lost connection after 6 retries.',
              severity: AlertSeverity.critical,
              timestamp: now,
              deviceId: device.id,
            ),
          );
        }
      } else if (device.connectionState == BleConnectionState.connected) {
        if (device.health == ConnectionHealth.poor) {
          final alertId = 'ble_silence_${device.id}';
          if (!_dismissedAlertIds.contains(alertId)) {
            alerts.add(
              HealthAlert(
                id: alertId,
                title: 'Data Stream Stalled',
                message: 'No sensor packets from ${device.name.isEmpty ? device.id : device.name} for >6s.',
                severity: AlertSeverity.warning,
                timestamp: now,
                deviceId: device.id,
              ),
            );
          }
        }
      }
    }

    // 2. Check Active Event GPS Fix
    final eventState = ref.read(eventRecordingControllerProvider);
    if (eventState.state == RecordingState.recording && eventState.startGps == null) {
      const alertId = 'gps_fix_missing';
      if (!_dismissedAlertIds.contains(alertId)) {
        alerts.add(
          HealthAlert(
            id: alertId,
            title: 'GPS Fix Missing',
            message: 'Active event recording without GPS location lock.',
            severity: AlertSeverity.warning,
            timestamp: now,
          ),
        );
      }
    }

    // 3. Check Battery Level
    final batteryService = ref.read(batteryServiceProvider);
    final batteryInfo = batteryService.currentInfo;
    if (batteryInfo.isLowBattery) {
      const alertId = 'battery_low';
      if (!_dismissedAlertIds.contains(alertId)) {
        alerts.add(
          HealthAlert(
            id: alertId,
            title: 'Battery Low (${batteryInfo.batteryLevel}%)',
            message: 'Power saving active (chart redraw throttled). Data capture continues at 100%.',
            severity: batteryInfo.isCriticalBattery ? AlertSeverity.critical : AlertSeverity.warning,
            timestamp: now,
          ),
        );
      }
    }

    _activeAlerts = alerts;
    if (!_alertsController.isClosed) {
      _alertsController.add(List.unmodifiable(_activeAlerts));
    }
  }

  void dismissAlert(String alertId) {
    _dismissedAlertIds.add(alertId);
    _activeAlerts.removeWhere((a) => a.id == alertId);
    if (!_alertsController.isClosed) {
      _alertsController.add(List.unmodifiable(_activeAlerts));
    }
  }

  void resetDismissed() {
    _dismissedAlertIds.clear();
  }

  void dispose() {
    _watchdogTimer?.cancel();
    _alertsController.close();
  }
}
