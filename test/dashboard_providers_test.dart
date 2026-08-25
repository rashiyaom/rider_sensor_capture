import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ride_sensor_capture/providers/dashboard_providers.dart';

void main() {
  test('DashboardTelemetryState copyWith retains points and updates values', () {
    const state = DashboardTelemetryState(
      hrSpots: [FlSpot(0, 70), FlSpot(1, 75)],
      latestHr: 75,
    );

    final updated = state.copyWith(
      latestHr: 80,
      latestAccelX: 1.2,
    );

    expect(updated.hrSpots.length, 2);
    expect(updated.latestHr, 80);
    expect(updated.latestAccelX, 1.2);
  });

  test('Dashboard pause state provider toggles properly', () {
    final container = ProviderContainer();
    expect(container.read(dashboardPausedProvider), false);

    container.read(dashboardPausedProvider.notifier).state = true;
    expect(container.read(dashboardPausedProvider), true);
  });
}
