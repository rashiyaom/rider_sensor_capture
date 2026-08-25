import 'dart:async';
import 'package:battery_plus/battery_plus.dart';

enum PowerMode {
  normal,       // Full live charting at 15 FPS
  powerSaving,  // Throttled charting at 1 FPS (100% data capture fidelity)
  critical,     // Paused live charting (100% data capture fidelity)
}

class BatteryInfo {
  final int batteryLevel; // 0 - 100
  final BatteryState state;
  final bool isPowerSavingForced;
  final bool isCharging;

  const BatteryInfo({
    this.batteryLevel = 100,
    this.state = BatteryState.full,
    this.isPowerSavingForced = false,
    this.isCharging = false,
  });

  /// Approximate consumption rate: ~9% per hour for BLE + GPS + Voice logging
  double get estimatedRideHoursRemaining {
    if (isCharging) return 24.0;
    return (batteryLevel / 9.0).clamp(0.0, 24.0);
  }

  bool get isLowBattery => batteryLevel <= 20 && !isCharging;
  bool get isCriticalBattery => batteryLevel <= 10 && !isCharging;

  PowerMode get activePowerMode {
    if (isPowerSavingForced) return PowerMode.powerSaving;
    if (isCriticalBattery) return PowerMode.critical;
    if (isLowBattery) return PowerMode.powerSaving;
    return PowerMode.normal;
  }

  BatteryInfo copyWith({
    int? batteryLevel,
    BatteryState? state,
    bool? isPowerSavingForced,
    bool? isCharging,
  }) {
    return BatteryInfo(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      state: state ?? this.state,
      isPowerSavingForced: isPowerSavingForced ?? this.isPowerSavingForced,
      isCharging: isCharging ?? this.isCharging,
    );
  }
}

class BatteryService {
  final Battery _battery = Battery();
  final StreamController<BatteryInfo> _infoController =
      StreamController<BatteryInfo>.broadcast();

  StreamSubscription<BatteryState>? _stateSubscription;
  Timer? _periodicPollTimer;

  BatteryInfo _currentInfo = const BatteryInfo();

  BatteryService() {
    _init();
  }

  Stream<BatteryInfo> get infoStream => _infoController.stream;
  BatteryInfo get currentInfo => _currentInfo;

  Future<void> _init() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      _currentInfo = _currentInfo.copyWith(
        batteryLevel: level,
        state: state,
        isCharging: state == BatteryState.charging || state == BatteryState.full,
      );
      _infoController.add(_currentInfo);
    } catch (_) {}

    _stateSubscription = _battery.onBatteryStateChanged.listen((state) async {
      int level = _currentInfo.batteryLevel;
      try {
        level = await _battery.batteryLevel;
      } catch (_) {}

      _currentInfo = _currentInfo.copyWith(
        batteryLevel: level,
        state: state,
        isCharging: state == BatteryState.charging || state == BatteryState.full,
      );
      if (!_infoController.isClosed) {
        _infoController.add(_currentInfo);
      }
    });

    // Poll every 30 seconds to catch gradual discharge
    _periodicPollTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final level = await _battery.batteryLevel;
        _currentInfo = _currentInfo.copyWith(batteryLevel: level);
        if (!_infoController.isClosed) {
          _infoController.add(_currentInfo);
        }
      } catch (_) {}
    });
  }

  void togglePowerSaving() {
    _currentInfo = _currentInfo.copyWith(
      isPowerSavingForced: !_currentInfo.isPowerSavingForced,
    );
    if (!_infoController.isClosed) {
      _infoController.add(_currentInfo);
    }
  }

  void dispose() {
    _periodicPollTimer?.cancel();
    _stateSubscription?.cancel();
    _infoController.close();
  }
}
