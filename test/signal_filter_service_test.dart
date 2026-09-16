import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/services/signal_filter_service.dart';
import 'package:ride_sensor_capture/data/services/idle_calibration_service.dart';

void main() {
  group('SignalFilterService Tests', () {
    const fs = 50.0; // 50Hz sampling

    test('Zero-phase filtfilt introduces ZERO sample phase lag', () {
      const n = 128;
      final signal = List<double>.filled(n, 0.0);
      // Place a distinct peak in the middle
      const peakIndex = 64;
      signal[peakIndex] = 10.0;

      final coeffs = BiquadCoefficients.butterworthLowPass(fc: 3.0, fs: fs);
      final filtered = SignalFilterService.filtfilt(signal, coeffs);

      // Find index of maximum value in filtered output
      int maxIdx = 0;
      double maxVal = filtered[0];
      for (int i = 1; i < filtered.length; i++) {
        if (filtered[i] > maxVal) {
          maxVal = filtered[i];
          maxIdx = i;
        }
      }

      // Zero-phase means the peak is symmetrically centered at exactly peakIndex
      expect(maxIdx, equals(peakIndex));
    });

    test('Notch filter attenuates synthetic pure tone at calibrated frequency', () {
      const fNotch = 18.0;
      const n = 256;
      final tStep = 1.0 / fs;

      // Pure 18 Hz sinusoid: x(t) = sin(2 * pi * 18 * t)
      final input = List<double>.generate(n, (i) => math.sin(2.0 * math.pi * fNotch * (i * tStep)));

      final cal = IdleCalibrationResult(
        mountLocation: 'fork',
        engineNoiseFreqHz: fNotch,
        engineNoiseAmplitude: 1.0,
        calibratedAtUtc: DateTime.now().toUtc(),
        calibrationValid: true,
      );

      final output = SignalFilterService.applyEngineNotch(
        signal: input,
        calibration: cal,
        sampleRate: fs,
        qFactor: 12.0,
      );

      // Measure RMS of central window (avoiding edge boundaries)
      double sumIn = 0.0;
      double sumOut = 0.0;
      const start = 32;
      const end = n - 32;
      for (int i = start; i < end; i++) {
        sumIn += input[i] * input[i];
        sumOut += output[i] * output[i];
      }
      final rmsIn = math.sqrt(sumIn / (end - start));
      final rmsOut = math.sqrt(sumOut / (end - start));

      // Notch filter at Q=12 must attenuate the resonant tone by at least 75%
      expect(rmsOut, lessThan(rmsIn * 0.25));
    });

    test('Stage 4 gentle high-pass preserves transient bump impulse with <5% amplitude loss', () {
      const n = 128;
      // Synthesize steady DC baseline (gravity ~9.8 m/s^2) + sharp transient bump spike (duration ~100ms = 5 samples)
      final signal = List<double>.filled(n, 9.80665);
      const spikeCenter = 60;
      const spikeAmp = 15.0; // 15 m/s^2 impact spike

      // Triangular bump impulse over 5 samples (100ms)
      signal[spikeCenter - 2] += spikeAmp * 0.3;
      signal[spikeCenter - 1] += spikeAmp * 0.8;
      signal[spikeCenter] += spikeAmp;
      signal[spikeCenter + 1] += spikeAmp * 0.8;
      signal[spikeCenter + 2] += spikeAmp * 0.3;

      final hpFiltered = SignalFilterService.applyBumpHighPass(signal, cutoffHz: 0.4, sampleRate: fs);

      // Peak amplitude in high-pass output (DC is stripped)
      final hpPeak = hpFiltered[spikeCenter];

      // Verification: High-pass must preserve the transient spike peak within 5% (<5% attenuation)
      // Allowed range: spikeAmp * 0.95 to spikeAmp * 1.05
      expect(hpPeak, greaterThanOrEqualTo(spikeAmp * 0.95));
    });

    test('Notch filter is strict no-op when calibrationValid is false or null', () {
      final input = [1.2, 3.4, 5.6, 7.8, 9.0];

      // 1. null calibration
      final resNull = SignalFilterService.applyEngineNotch(signal: input, calibration: null);
      expect(resNull, equals(input));

      // 2. calibrationValid = false
      final calInvalid = IdleCalibrationResult.fallback(mountLocation: 'fork');
      final resInvalid = SignalFilterService.applyEngineNotch(signal: input, calibration: calInvalid);
      expect(resInvalid, equals(input));
    });

    test('Stage 3 Butterworth low-pass preserves 1Hz maneuvers and eliminates 20Hz vibration', () {
      const n = 256;
      final tStep = 1.0 / fs;

      // 1Hz maneuver + 20Hz high frequency engine jitter
      final maneuver = List<double>.generate(n, (i) => 5.0 * math.sin(2.0 * math.pi * 1.0 * (i * tStep)));
      final jitter = List<double>.generate(n, (i) => 2.0 * math.sin(2.0 * math.pi * 20.0 * (i * tStep)));
      final combined = List<double>.generate(n, (i) => maneuver[i] + jitter[i]);

      final lowPassed = SignalFilterService.applyManeuverLowPass(combined, cutoffHz: 3.0, sampleRate: fs);

      // Compare lowPassed to pure maneuver in middle region
      const start = 40;
      const end = n - 40;
      double diffSq = 0.0;
      for (int i = start; i < end; i++) {
        final d = lowPassed[i] - maneuver[i];
        diffSq += d * d;
      }
      final rmse = math.sqrt(diffSq / (end - start));

      // The 20Hz jitter should be strongly suppressed, RMSE relative to clean maneuver < 0.25
      expect(rmse, lessThan(0.25));
    });

    test('RMS Envelope correctly detects transient impulse envelope', () {
      final signal = [0.0, 0.0, 10.0, 10.0, 0.0, 0.0];
      final envelope = SignalFilterService.computeRmsEnvelope(signal, windowSamples: 2);

      expect(envelope.length, equals(signal.length));
      expect(envelope[2], greaterThan(5.0));
      expect(envelope[0], equals(0.0));
    });

    test('Adaptive threshold scales with baseline noise floor', () {
      const margin = 1.5;

      // No calibration fallback
      final tDefault = SignalFilterService.computeAdaptiveThreshold(fixedMargin: margin, calibration: null);
      expect(tDefault, equals(1.5));

      // Valid calibration with baseline noise 0.3g
      final cal = IdleCalibrationResult(
        mountLocation: 'footboard',
        engineNoiseFreqHz: 22.0,
        engineNoiseAmplitude: 0.35,
        calibratedAtUtc: DateTime.now().toUtc(),
        calibrationValid: true,
      );
      final tAdaptive = SignalFilterService.computeAdaptiveThreshold(fixedMargin: margin, calibration: cal);
      expect(tAdaptive, closeTo(1.85, 0.001));
    });

    test('Dashboard Causal EMA smooths display stream', () {
      double? ema;
      ema = SignalFilterService.applyDashboardCausalEma(currentValue: 10.0, previousFilteredValue: ema, alpha: 0.2);
      expect(ema, equals(10.0));

      ema = SignalFilterService.applyDashboardCausalEma(currentValue: 0.0, previousFilteredValue: ema, alpha: 0.2);
      // 0.2 * 0.0 + 0.8 * 10.0 = 8.0
      expect(ema, closeTo(8.0, 0.001));
    });
  });
}
