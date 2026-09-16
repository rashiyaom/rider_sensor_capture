import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available sample interval options in seconds.
/// 0.02 = 50 Hz (raw, no decimation), 1.0 = 1 per second, etc.
class SampleRateOption {
  final String label;
  final double intervalSeconds;
  const SampleRateOption({required this.label, required this.intervalSeconds});
}

const List<SampleRateOption> kSampleRateOptions = [
  SampleRateOption(label: 'Raw (50 Hz)', intervalSeconds: 0.02),
  SampleRateOption(label: '1 per sec', intervalSeconds: 1.0),
  SampleRateOption(label: '1 per 2 sec', intervalSeconds: 2.0),
  SampleRateOption(label: '1 per 3 sec', intervalSeconds: 3.0),
  SampleRateOption(label: '1 per 4 sec', intervalSeconds: 4.0),
];

/// Currently selected sample interval in seconds.
/// Default: 0.02 (50 Hz raw — matches existing behaviour).
final sampleIntervalSecondsProvider = StateProvider<double>((ref) => 0.02);

/// Per-device last-write timestamp used by BLE bridge to throttle writes.
final lastSampleWriteTimesProvider =
    StateProvider<Map<String, DateTime>>((ref) => {});
