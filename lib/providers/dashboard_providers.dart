import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ble/models/raw_sensor_data.dart';
import '../core/services/battery_service.dart';
import '../data/services/signal_filter_service.dart';
import 'battery_providers.dart';
import 'ble_providers.dart';

// Dashboard paused state provider
final dashboardPausedProvider = StateProvider<bool>((ref) => false);

// Selected device for live dashboard: null = Cumulative Multi-Sensor, or specific deviceId string
final dashboardSelectedDeviceIdProvider = StateProvider<String?>((ref) => null);

// Data structure for the rolling telemetry window
class DashboardTelemetryState {
  final String? selectedDeviceId;
  final String selectedDeviceName;
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
    this.selectedDeviceId,
    this.selectedDeviceName = 'Cumulative All Sensors',
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
    String? selectedDeviceId,
    String? selectedDeviceName,
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
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      selectedDeviceName: selectedDeviceName ?? this.selectedDeviceName,
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

class _DeviceTelemetryBuffer {
  final List<FlSpot> hr = [];
  final List<FlSpot> accelX = [];
  final List<FlSpot> accelY = [];
  final List<FlSpot> accelZ = [];
  final List<FlSpot> gyroX = [];
  final List<FlSpot> gyroY = [];
  final List<FlSpot> gyroZ = [];
  int hrTick = 0;
  int motionTick = 0;
  int? latestHr;
  double? latestAccelX;
  double? latestAccelY;
  double? latestAccelZ;
  double? latestGyroX;
  double? latestGyroY;
  double? latestGyroZ;

  // Cosmetic causal EMA states for live chart display (Section 5)
  double? emaAccelX;
  double? emaAccelY;
  double? emaAccelZ;
  double? emaGyroX;
  double? emaGyroY;
  double? emaGyroZ;

  String deviceName = '';
}

// Bounded sliding buffer implementation with power-aware throttled chart updates
class DashboardTelemetryNotifier extends StateNotifier<DashboardTelemetryState> {
  final Ref ref;
  StreamSubscription<RawSensorData>? _dataSubscription;
  Timer? _renderTimer;

  static const int maxHrPoints = 60;
  static const int maxMotionPoints = 120;

  final _DeviceTelemetryBuffer _cumulativeBuffer = _DeviceTelemetryBuffer();
  final Map<String, _DeviceTelemetryBuffer> _deviceBuffers = {};

  bool _dirty = false;

  DashboardTelemetryNotifier(this.ref) : super(const DashboardTelemetryState()) {
    _initStream();
    _startRenderTimer(const Duration(milliseconds: 125));
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
        _startRenderTimer(const Duration(milliseconds: 125)); // 8 FPS (smooth, low-CPU)
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

      final devBuf = _deviceBuffers.putIfAbsent(data.deviceId, () => _DeviceTelemetryBuffer());
      devBuf.deviceName = data.deviceName;

      // Update Device-Specific Buffer
      if (data.heartRate != null) {
        devBuf.latestHr = data.heartRate;
        devBuf.hr.add(FlSpot(devBuf.hrTick.toDouble(), data.heartRate!.toDouble()));
        devBuf.hrTick++;
        if (devBuf.hr.length > maxHrPoints) devBuf.hr.removeAt(0);

        _cumulativeBuffer.latestHr = data.heartRate;
        _cumulativeBuffer.hr.add(FlSpot(_cumulativeBuffer.hrTick.toDouble(), data.heartRate!.toDouble()));
        _cumulativeBuffer.hrTick++;
        if (_cumulativeBuffer.hr.length > maxHrPoints) _cumulativeBuffer.hr.removeAt(0);
        _dirty = true;
      }

      if (data.accelX != null && data.accelY != null && data.accelZ != null) {
        // Raw values for numeric tile display
        devBuf.latestAccelX = data.accelX;
        devBuf.latestAccelY = data.accelY;
        devBuf.latestAccelZ = data.accelZ;

        // Cosmetic Causal EMA filtering for 8 FPS chart display only (Section 5 / Section 4f)
        devBuf.emaAccelX = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.accelX!,
          previousFilteredValue: devBuf.emaAccelX,
        );
        devBuf.emaAccelY = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.accelY!,
          previousFilteredValue: devBuf.emaAccelY,
        );
        devBuf.emaAccelZ = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.accelZ!,
          previousFilteredValue: devBuf.emaAccelZ,
        );

        final t = devBuf.motionTick.toDouble();
        devBuf.accelX.add(FlSpot(t, devBuf.emaAccelX!));
        devBuf.accelY.add(FlSpot(t, devBuf.emaAccelY!));
        devBuf.accelZ.add(FlSpot(t, devBuf.emaAccelZ!));
        devBuf.motionTick++;
        if (devBuf.accelX.length > maxMotionPoints) {
          devBuf.accelX.removeAt(0);
          devBuf.accelY.removeAt(0);
          devBuf.accelZ.removeAt(0);
        }

        _cumulativeBuffer.latestAccelX = data.accelX;
        _cumulativeBuffer.latestAccelY = data.accelY;
        _cumulativeBuffer.latestAccelZ = data.accelZ;

        _cumulativeBuffer.emaAccelX = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.accelX!,
          previousFilteredValue: _cumulativeBuffer.emaAccelX,
        );
        _cumulativeBuffer.emaAccelY = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.accelY!,
          previousFilteredValue: _cumulativeBuffer.emaAccelY,
        );
        _cumulativeBuffer.emaAccelZ = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.accelZ!,
          previousFilteredValue: _cumulativeBuffer.emaAccelZ,
        );

        final cumT = _cumulativeBuffer.motionTick.toDouble();
        _cumulativeBuffer.accelX.add(FlSpot(cumT, _cumulativeBuffer.emaAccelX!));
        _cumulativeBuffer.accelY.add(FlSpot(cumT, _cumulativeBuffer.emaAccelY!));
        _cumulativeBuffer.accelZ.add(FlSpot(cumT, _cumulativeBuffer.emaAccelZ!));
        _cumulativeBuffer.motionTick++;
        if (_cumulativeBuffer.accelX.length > maxMotionPoints) {
          _cumulativeBuffer.accelX.removeAt(0);
          _cumulativeBuffer.accelY.removeAt(0);
          _cumulativeBuffer.accelZ.removeAt(0);
        }

        _dirty = true;
      }

      if (data.gyroX != null && data.gyroY != null && data.gyroZ != null) {
        // Raw values for numeric tile display
        devBuf.latestGyroX = data.gyroX;
        devBuf.latestGyroY = data.gyroY;
        devBuf.latestGyroZ = data.gyroZ;

        // Cosmetic Causal EMA filtering for 8 FPS chart display only (Section 5 / Section 4f)
        devBuf.emaGyroX = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.gyroX!,
          previousFilteredValue: devBuf.emaGyroX,
        );
        devBuf.emaGyroY = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.gyroY!,
          previousFilteredValue: devBuf.emaGyroY,
        );
        devBuf.emaGyroZ = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.gyroZ!,
          previousFilteredValue: devBuf.emaGyroZ,
        );

        final gt = devBuf.motionTick.toDouble();
        devBuf.gyroX.add(FlSpot(gt, devBuf.emaGyroX!));
        devBuf.gyroY.add(FlSpot(gt, devBuf.emaGyroY!));
        devBuf.gyroZ.add(FlSpot(gt, devBuf.emaGyroZ!));
        if (devBuf.gyroX.length > maxMotionPoints) {
          devBuf.gyroX.removeAt(0);
          devBuf.gyroY.removeAt(0);
          devBuf.gyroZ.removeAt(0);
        }

        _cumulativeBuffer.latestGyroX = data.gyroX;
        _cumulativeBuffer.latestGyroY = data.gyroY;
        _cumulativeBuffer.latestGyroZ = data.gyroZ;

        _cumulativeBuffer.emaGyroX = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.gyroX!,
          previousFilteredValue: _cumulativeBuffer.emaGyroX,
        );
        _cumulativeBuffer.emaGyroY = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.gyroY!,
          previousFilteredValue: _cumulativeBuffer.emaGyroY,
        );
        _cumulativeBuffer.emaGyroZ = SignalFilterService.applyDashboardCausalEma(
          currentValue: data.gyroZ!,
          previousFilteredValue: _cumulativeBuffer.emaGyroZ,
        );

        final cumGt = _cumulativeBuffer.motionTick.toDouble();
        _cumulativeBuffer.gyroX.add(FlSpot(cumGt, _cumulativeBuffer.emaGyroX!));
        _cumulativeBuffer.gyroY.add(FlSpot(cumGt, _cumulativeBuffer.emaGyroY!));
        _cumulativeBuffer.gyroZ.add(FlSpot(cumGt, _cumulativeBuffer.emaGyroZ!));
        if (_cumulativeBuffer.gyroX.length > maxMotionPoints) {
          _cumulativeBuffer.gyroX.removeAt(0);
          _cumulativeBuffer.gyroY.removeAt(0);
          _cumulativeBuffer.gyroZ.removeAt(0);
        }

        _dirty = true;
      }
    });
  }

  void _flushToState() {
    if (!_dirty) return;
    _dirty = false;

    final selectedId = ref.read(dashboardSelectedDeviceIdProvider);
    final _DeviceTelemetryBuffer target;
    final String label;

    if (selectedId != null && _deviceBuffers.containsKey(selectedId)) {
      target = _deviceBuffers[selectedId]!;
      label = target.deviceName.isNotEmpty ? target.deviceName : selectedId;
    } else {
      target = _cumulativeBuffer;
      label = 'Cumulative All Sensors';
    }

    state = DashboardTelemetryState(
      selectedDeviceId: selectedId,
      selectedDeviceName: label,
      hrSpots: List.unmodifiable(target.hr),
      accelXSpots: List.unmodifiable(target.accelX),
      accelYSpots: List.unmodifiable(target.accelY),
      accelZSpots: List.unmodifiable(target.accelZ),
      gyroXSpots: List.unmodifiable(target.gyroX),
      gyroYSpots: List.unmodifiable(target.gyroY),
      gyroZSpots: List.unmodifiable(target.gyroZ),
      latestHr: target.latestHr,
      latestAccelX: target.latestAccelX,
      latestAccelY: target.latestAccelY,
      latestAccelZ: target.latestAccelZ,
      latestGyroX: target.latestGyroX,
      latestGyroY: target.latestGyroY,
      latestGyroZ: target.latestGyroZ,
    );
  }

  void triggerRefresh() {
    _dirty = true;
    _flushToState();
  }

  void reset() {
    _cumulativeBuffer.hr.clear();
    _cumulativeBuffer.accelX.clear();
    _cumulativeBuffer.accelY.clear();
    _cumulativeBuffer.accelZ.clear();
    _cumulativeBuffer.gyroX.clear();
    _cumulativeBuffer.gyroY.clear();
    _cumulativeBuffer.gyroZ.clear();
    _cumulativeBuffer.hrTick = 0;
    _cumulativeBuffer.motionTick = 0;
    _cumulativeBuffer.latestHr = null;
    _cumulativeBuffer.latestAccelX = null;
    _cumulativeBuffer.latestAccelY = null;
    _cumulativeBuffer.latestAccelZ = null;

    for (var buf in _deviceBuffers.values) {
      buf.hr.clear();
      buf.accelX.clear();
      buf.accelY.clear();
      buf.accelZ.clear();
      buf.gyroX.clear();
      buf.gyroY.clear();
      buf.gyroZ.clear();
      buf.hrTick = 0;
      buf.motionTick = 0;
      buf.latestHr = null;
      buf.latestAccelX = null;
      buf.latestAccelY = null;
      buf.latestAccelZ = null;
    }

    state = DashboardTelemetryState(
      selectedDeviceId: ref.read(dashboardSelectedDeviceIdProvider),
    );
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
  ref.listen<String?>(dashboardSelectedDeviceIdProvider, (_, _) {
    notifier.triggerRefresh();
  });
  return notifier;
});
