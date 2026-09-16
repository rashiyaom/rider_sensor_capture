import '../local_db/database.dart';

class HrGateResult {
  final bool hrSpikeConfirmed;
  final double? hrDeltaAtEvent;
  final double? hrBaseline;
  final int? peakHrInWindow;

  const HrGateResult({
    required this.hrSpikeConfirmed,
    this.hrDeltaAtEvent,
    this.hrBaseline,
    this.peakHrInWindow,
  });
}

class HrEventGate {
  /// Minimum HR increase (BPM) above baseline to register as confirmed physiological response
  static const int defaultThresholdDeltaBpm = 8;

  /// Compute rolling median HR baseline from readings in a given trailing window (e.g. 60 seconds)
  static double computeBaseline(List<int> hrReadings) {
    if (hrReadings.isEmpty) return 75.0; // Standard resting/cruise HR baseline fallback
    final sorted = List<int>.from(hrReadings)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) {
      return sorted[mid].toDouble();
    } else {
      return (sorted[mid - 1] + sorted[mid]) / 2.0;
    }
  }

  /// Evaluate if heart rate spiked following an event start timestamp
  static HrGateResult evaluateEventHr({
    required DateTime eventStartUtc,
    required List<SensorReading> tripReadings,
    int baselineWindowSec = 60,
    int postEventWindowSec = 5,
    int thresholdDeltaBpm = defaultThresholdDeltaBpm,
  }) {
    // 1. Collect readings before event start to establish baseline
    final baselineStart = eventStartUtc.subtract(Duration(seconds: baselineWindowSec));
    final baselineHrs = <int>[];

    // 2. Collect readings within postEventWindowSec after event start
    final postEventEnd = eventStartUtc.add(Duration(seconds: postEventWindowSec));
    final postEventHrs = <int>[];

    for (final r in tripReadings) {
      if (r.heartRate != null && r.heartRate! > 30 && r.heartRate! < 220) {
        if (r.timestampUtc.isAfter(baselineStart) && !r.timestampUtc.isAfter(eventStartUtc)) {
          baselineHrs.add(r.heartRate!);
        } else if (r.timestampUtc.isAfter(eventStartUtc) && !r.timestampUtc.isAfter(postEventEnd)) {
          postEventHrs.add(r.heartRate!);
        }
      }
    }

    if (baselineHrs.isEmpty && postEventHrs.isEmpty) {
      return const HrGateResult(hrSpikeConfirmed: false);
    }

    final baseline = computeBaseline(baselineHrs.isNotEmpty ? baselineHrs : postEventHrs);

    if (postEventHrs.isEmpty) {
      return HrGateResult(
        hrSpikeConfirmed: false,
        hrBaseline: baseline,
        hrDeltaAtEvent: 0.0,
      );
    }

    int peakHr = postEventHrs.first;
    for (final hr in postEventHrs) {
      if (hr > peakHr) peakHr = hr;
    }

    final delta = (peakHr - baseline).toDouble();
    final spikeConfirmed = delta >= thresholdDeltaBpm;

    return HrGateResult(
      hrSpikeConfirmed: spikeConfirmed,
      hrDeltaAtEvent: delta,
      hrBaseline: baseline,
      peakHrInWindow: peakHr,
    );
  }
}
