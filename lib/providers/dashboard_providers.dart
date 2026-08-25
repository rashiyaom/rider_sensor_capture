import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ble/models/raw_sensor_data.dart';
import '../core/services/battery_service.dart';
import 'battery_providers.dart';
import 'ble_providers.dart';

// Dashboard paused state provider
final dashboardPausedProvider = StateProvider<bool>((ref) => false);

// Data structure for the rolling telemetry window
class DashboardTelemetryState {
  final List<FlSpot> hrSpots;
  final List<FlSpot> accelXSpots;
  final List<FlSpot> accelYSpots;
  final List<FlSpot> accelZSpots;
  final List<FlSpot> gyroXSpots;
  final List<FlSpot> gyroYSpots;
  final List<FlSpot> gyroZSpots;

  final int? latestHr;
  final double? latestAccelX;
  final double? latestAccelY;
  final double? latestAccelZ;
  final double? latestGyroX;
  final double? latestGyroY;
  final double? latestGyroZ;

  const DashboardTelemetryState({
    this.hrSpots = const [],
    this.accelXSpots = const [],
    this.accelYSpots = const [],
    this.accelZSpots = const [],
    this.gyroXSpots = const [],
    this.gyroYSpots = const [],
    this.gyroZSpots = const [],
    this.latestHr,
    this.latestAccelX,
    this.latestAccelY,
    this.latestAccelZ,
    this.latestGyroX,
    this.latestGyroY,
    this.latestGyroZ,
  });

  DashboardTelemetryState copyWith({
    List<FlSpot>? hrSpots,
    List<FlSpot>? accelXSpots,
    List<FlSpot>? accelYSpots,
    List<FlSpot>? accelZSpots,
    List<FlSpot>? gyroXSpots,
    List<FlSpot>? gyroYSpots,
    List<FlSpot>? gyroZSpots,
    int? latestHr,
    double? latestAccelX,
    double? latestAccelY,
    double? latestAccelZ,
    double? latestGyroX,
    double? latestGyroY,
    double? latestGyroZ,
  }) {
    return DashboardTelemetryState(
      hrSpots: hrSpots ?? this.hrSpots,
      accelXSpots: accelXSpots ?? this.accelXSpots,
      accelYSpots: accelYSpots ?? this.accelYSpots,
      accelZSpots: accelZSpots ?? this.accelZSpots,
      gyroXSpots: gyroXSpots ?? this.gyroXSpots,
      gyroYSpots: gyroYSpots ?? this.gyroYSpots,
      gyroZSpots: gyroZSpots ?? this.gyroZSpots,
      latestHr: latestHr ?? this.latestHr,
      latestAccelX: latestAccelX ?? this.latestAccelX,
      latestAccelY: latestAccelY ?? this.latestAccelY,
      latestAccelZ: latestAccelZ ?? this.latestAccelZ,
      latestGyroX: latestGyroX ?? this.latestGyroX,
      latestGyroY: latestGyroY ?? this.latestGyroY,
      latestGyroZ: latestGyroZ ?? this.latestGyroZ,
    );
  }
}

// Bounded sliding buffer implementation with power-aware throttled chart updates
class DashboardTelemetryNotifier extends StateNotifier<DashboardTelemetryState> {
  final Ref ref;
  StreamSubscription<RawSensorData>? _dataSubscription;
  Timer? _renderTimer;

  static const int maxHrPoints = 60;
  static const int maxMotionPoints = 120;

  final List<FlSpot> _hrBuffer = [];
  final List<FlSpot> _accelXBuffer = [];
  final List<FlSpot> _accelYBuffer = [];
  final List<FlSpot> _accelZBuffer = [];
  final List<FlSpot> _gyroXBuffer = [];
  final List<FlSpot> _gyroYBuffer = [];
  final List<FlSpot> _gyroZBuffer = [];

  int _hrTick = 0;
  int _motionTick = 0;

  int? _latestHr;
  double? _latestAccelX;
  double? _latestAccelY;
  double? _latestAccelZ;
  double? _latestGyroX;
  double? _latestGyroY;
  double? _latestGyroZ;

  bool _dirty = false;

  DashboardTelemetryNotifier(this.ref) : super(const DashboardTelemetryState()) {
    _initStream();
    _startRenderTimer(const Duration(milliseconds: 66));
  }

  void _startRenderTimer(Duration interval) {
    _renderTimer?.cancel();
    _renderTimer = Timer.periodic(interval, (_) {
      final powerMode = ref.read(currentPowerModeProvider);
      if (powerMode == PowerMode.critical) return; // Freeze chart redraw on critical battery
      _flushToState();
    });
  }

  void updatePowerMode(PowerMode mode) {
    switch (mode) {
      case PowerMode.normal:
        _startRenderTimer(const Duration(milliseconds: 66)); // 15 FPS
        break;
      case PowerMode.powerSaving:
        _startRenderTimer(const Duration(milliseconds: 1000)); // 1 FPS throttled
        break;
      case PowerMode.critical:
        _renderTimer?.cancel(); // Halt charting entirely to save power
        break;
    }
  }

  void _initStream() {
    final manager = ref.read(bleConnectionManagerProvider);
    _dataSubscription = manager.rawDataStream.listen((data) {
      final isPaused = ref.read(dashboardPausedProvider);
      if (isPaused) return;

      if (data.heartRate != null) {
        _latestHr = data.heartRate;
        _hrBuffer.add(FlSpot(_hrTick.toDouble(), data.heartRate!.toDouble()));
        _hrTick++;
        if (_hrBuffer.length > maxHrPoints) {
          _hrBuffer.removeAt(0);
        }
        _dirty = true;
      }

      if (data.accelX != null && data.accelY != null && data.accelZ != null) {
        _latestAccelX = data.accelX;
        _latestAccelY = data.accelY;
        _latestAccelZ = data.accelZ;

        final t = _motionTick.toDouble();
        _accelXBuffer.add(FlSpot(t, data.accelX!));
        _accelYBuffer.add(FlSpot(t, data.accelY!));
        _accelZBuffer.add(FlSpot(t, data.accelZ!));

        _motionTick++;
        if (_accelXBuffer.length > maxMotionPoints) {
          _accelXBuffer.removeAt(0);
          _accelYBuffer.removeAt(0);
          _accelZBuffer.removeAt(0);
        }
        _dirty = true;
      }
    });
  }

  void _flushToState() {
    if (!_dirty) return;
    _dirty = false;

    state = DashboardTelemetryState(
      hrSpots: List.unmodifiable(_hrBuffer),
      accelXSpots: List.unmodifiable(_accelXBuffer),
      accelYSpots: List.unmodifiable(_accelYBuffer),
      accelZSpots: List.unmodifiable(_accelZBuffer),
      gyroXSpots: List.unmodifiable(_gyroXBuffer),
      gyroYSpots: List.unmodifiable(_gyroYBuffer),
      gyroZSpots: List.unmodifiable(_gyroZBuffer),
      latestHr: _latestHr,
      latestAccelX: _latestAccelX,
      latestAccelY: _latestAccelY,
      latestAccelZ: _latestAccelZ,
      latestGyroX: _latestGyroX,
      latestGyroY: _latestGyroY,
      latestGyroZ: _latestGyroZ,
    );
  }

  void reset() {
    _hrBuffer.clear();
    _accelXBuffer.clear();
    _accelYBuffer.clear();
    _accelZBuffer.clear();
    _gyroXBuffer.clear();
    _gyroYBuffer.clear();
    _gyroZBuffer.clear();
    _hrTick = 0;
    _motionTick = 0;
    _latestHr = null;
    _latestAccelX = null;
    _latestAccelY = null;
    _latestAccelZ = null;
    _latestGyroX = null;
    _latestGyroY = null;
    _latestGyroZ = null;
    state = const DashboardTelemetryState();
  }

  @override
  void dispose() {
    _renderTimer?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }
}

final dashboardTelemetryProvider =
    StateNotifierProvider<DashboardTelemetryNotifier, DashboardTelemetryState>((ref) {
  final notifier = DashboardTelemetryNotifier(ref);
  ref.listen<PowerMode>(currentPowerModeProvider, (_, next) {
    notifier.updatePowerMode(next);
  });
  return notifier;
});
