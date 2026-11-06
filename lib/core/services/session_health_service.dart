import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ble/models/ble_device_model.dart';
import '../../features/events/event_recording_controller.dart';
import '../../providers/battery_providers.dart';
import '../../providers/ble_providers.dart';
import '../../providers/db_providers.dart';
import '../../providers/pre_alert_providers.dart';
import '../../features/trips/trip_controller.dart';

enum AlertSeverity { info, warning, critical }

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

    final recoveryNotice = ref.read(tripControllerProvider).recoveryNotice;
    if (recoveryNotice != null &&
        !_dismissedAlertIds.contains('interrupted_trip_recovered')) {
      alerts.add(
        HealthAlert(
          id: 'interrupted_trip_recovered',
          title: 'Ride recovered after app stop',
          message: recoveryNotice,
          severity: AlertSeverity.warning,
          timestamp: now,
        ),
      );
    }
    final backgroundLifetimeError = ref
        .read(tripControllerProvider)
        .backgroundLifetimeError;
    if (ref.read(tripControllerProvider).isJourneyActive &&
        backgroundLifetimeError != null &&
        !_dismissedAlertIds.contains('background_recording_unavailable')) {
      alerts.add(
        HealthAlert(
          id: 'background_recording_unavailable',
          title: 'Background recording unavailable',
          message: backgroundLifetimeError,
          severity: AlertSeverity.critical,
          timestamp: now,
        ),
      );
    }

    final writes = ref.read(dbWriteStatsStreamProvider).value;
    if (writes?.writeError != null) {
      alerts.add(
        HealthAlert(
          id: 'storage_write_failed',
          title: 'Recording storage failed',
          message:
              '${writes!.writeError} ${writes.pendingRows} samples pending. Keep the app open while storage recovers.',
          severity: AlertSeverity.critical,
          timestamp: now,
        ),
      );
    }

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
              message:
                  '${device.name.isEmpty ? device.id : device.name} lost connection after 6 retries.',
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
                message:
                    'No sensor packets from ${device.name.isEmpty ? device.id : device.name} for >6s.',
                severity: AlertSeverity.warning,
                timestamp: now,
                deviceId: device.id,
              ),
            );
          }
        }
      }
    }

    if (ref.read(tripControllerProvider).isJourneyActive) {
      final location = ref.read(locationServiceProvider);
      final preAlerts = ref.read(preAlertServiceProvider);
      if (!location.hasFreshFix || preAlerts.startupError != null) {
        alerts.add(
          HealthAlert(
            id: 'trip_gps_unavailable',
            title: 'Live GPS unavailable',
            message: preAlerts.startupError ?? location.lastError ?? 'Waiting for a fresh GPS fix. Location warnings may be unavailable.',
            severity: AlertSeverity.warning,
            timestamp: now,
          ),
        );
      }
      if (preAlerts.lastDeliveryError != null &&
          !_dismissedAlertIds.contains('prealert_delivery_failed')) {
        alerts.add(
          HealthAlert(
            id: 'prealert_delivery_failed',
            title: 'Voice warning not confirmed',
            message: preAlerts.lastDeliveryError!,
            severity: AlertSeverity.critical,
            timestamp: now,
          ),
        );
      }
    }

    // 2. Check Active Event GPS Fix
    final eventState = ref.read(eventRecordingControllerProvider);
    if (eventState.state == RecordingState.recording &&
        eventState.startGps == null) {
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
            severity: batteryInfo.isCriticalBattery
                ? AlertSeverity.critical
                : AlertSeverity.warning,
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
