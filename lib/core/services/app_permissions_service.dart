import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermissionType {
  bluetooth,
  location,
  notification,
}

class AppPermissionStatus {
  final bool isBluetoothGranted;
  final bool isLocationGranted;
  final bool isNotificationGranted;

  const AppPermissionStatus({
    this.isBluetoothGranted = false,
    this.isLocationGranted = false,
    this.isNotificationGranted = false,
  });

  bool get areAllGranted => isBluetoothGranted && isLocationGranted;

  bool get isCriticalMissing => !isBluetoothGranted || !isLocationGranted;
}

class AppPermissionsService {
  /// Request all essential permissions on cold start (Bluetooth, Location, Notification).
  static Future<AppPermissionStatus> requestAllInitialPermissions() async {
    if (kIsWeb) {
      return const AppPermissionStatus(
        isBluetoothGranted: true,
        isLocationGranted: true,
        isNotificationGranted: true,
      );
    }

    if (Platform.isAndroid) {
      // 1. Android Bluetooth & Location
      final btStatuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse,
      ].request();

      final btGranted = (btStatuses[Permission.bluetoothScan]?.isGranted ?? false) &&
          (btStatuses[Permission.bluetoothConnect]?.isGranted ?? false);
      final locGranted = btStatuses[Permission.locationWhenInUse]?.isGranted ?? false;

      // 2. Notification for session alerts
      final notifStatus = await Permission.notification.request();
      final notifGranted = notifStatus.isGranted;

      return AppPermissionStatus(
        isBluetoothGranted: btGranted,
        isLocationGranted: locGranted,
        isNotificationGranted: notifGranted,
      );
    }

    if (Platform.isIOS) {
      final btStatus = await Permission.bluetooth.request();
      final locStatus = await Permission.locationWhenInUse.request();
      final notifStatus = await Permission.notification.request();

      final btGranted = btStatus.isGranted || btStatus.isLimited;
      final locGranted = locStatus.isGranted || locStatus.isLimited;
      final notifGranted = notifStatus.isGranted;

      return AppPermissionStatus(
        isBluetoothGranted: btGranted,
        isLocationGranted: locGranted,
        isNotificationGranted: notifGranted,
      );
    }

    return const AppPermissionStatus(
      isBluetoothGranted: true,
      isLocationGranted: true,
      isNotificationGranted: true,
    );
  }

  /// Check current status without prompting.
  static Future<AppPermissionStatus> checkCurrentStatus() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return const AppPermissionStatus(
        isBluetoothGranted: true,
        isLocationGranted: true,
        isNotificationGranted: true,
      );
    }

    if (Platform.isAndroid) {
      final scan = await Permission.bluetoothScan.isGranted;
      final connect = await Permission.bluetoothConnect.isGranted;
      final loc = await Permission.locationWhenInUse.isGranted;
      final notif = await Permission.notification.isGranted;

      return AppPermissionStatus(
        isBluetoothGranted: scan && connect,
        isLocationGranted: loc,
        isNotificationGranted: notif,
      );
    }

    if (Platform.isIOS) {
      final bt = await Permission.bluetooth.isGranted;
      final loc = await Permission.locationWhenInUse.isGranted;
      final notif = await Permission.notification.isGranted;

      return AppPermissionStatus(
        isBluetoothGranted: bt,
        isLocationGranted: loc,
        isNotificationGranted: notif,
      );
    }

    return const AppPermissionStatus(
      isBluetoothGranted: true,
      isLocationGranted: true,
      isNotificationGranted: true,
    );
  }
}
