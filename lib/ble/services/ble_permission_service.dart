import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class BlePermissionService {
  static Future<bool> requestBlePermissions() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse,
      ].request();

      final allGranted = statuses.values.every(
        (status) => status.isGranted || status.isLimited,
      );
      return allGranted;
    }

    if (Platform.isIOS) {
      final bluetoothStatus = await Permission.bluetooth.request();
      final locationStatus = await Permission.locationWhenInUse.request();
      return (bluetoothStatus.isGranted || bluetoothStatus.isLimited) &&
          (locationStatus.isGranted || locationStatus.isLimited);
    }

    return true;
  }

  static Future<bool> hasBlePermissions() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final scanGranted = await Permission.bluetoothScan.isGranted;
      final connectGranted = await Permission.bluetoothConnect.isGranted;
      final locationGranted = await Permission.locationWhenInUse.isGranted;
      return scanGranted && connectGranted && locationGranted;
    }

    return await Permission.bluetooth.isGranted;
  }
}

