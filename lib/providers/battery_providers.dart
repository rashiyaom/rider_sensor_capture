import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/battery_service.dart';

final batteryServiceProvider = Provider<BatteryService>((ref) {
  final service = BatteryService();
  ref.onDispose(() => service.dispose());
  return service;
});

final batteryInfoStreamProvider = StreamProvider<BatteryInfo>((ref) {
  final service = ref.watch(batteryServiceProvider);
  return service.infoStream;
});

final currentPowerModeProvider = Provider<PowerMode>((ref) {
  final infoAsync = ref.watch(batteryInfoStreamProvider);
  return infoAsync.value?.activePowerMode ?? PowerMode.normal;
});
