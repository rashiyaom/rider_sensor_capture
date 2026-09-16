import 'dart:math' as math;
import 'idle_calibration_service.dart';

/// Second-order digital biquad filter coefficients
class BiquadCoefficients {
  final double b0;
  final double b1;
  final double b2;
  final double a1; // Normalized (a0 = 1.0)
  final double a2;

  const BiquadCoefficients({
    required this.b0,
    required this.b1,
    required this.b2,
    required this.a1,
    required this.a2,
  });

  /// 2nd-order IIR Notch filter with center frequency [f0], sample rate [fs], quality factor [q]
  factory BiquadCoefficients.notch({
    required double f0,
    double fs = 50.0,
    double q = 10.0,
  }) {
    final omega0 = 2.0 * math.pi * (f0 / fs);
    final alpha = math.sin(omega0) / (2.0 * q);
    final cosW0 = math.cos(omega0);

    final a0 = 1.0 + alpha;
    final b0 = 1.0 / a0;
    final b1 = (-2.0 * cosW0) / a0;
    final b2 = 1.0 / a0;
    final a1 = (-2.0 * cosW0) / a0;
    final a2 = (1.0 - alpha) / a0;

    return BiquadCoefficients(b0: b0, b1: b1, b2: b2, a1: a1, a2: a2);
  }

  /// 2nd-order Butterworth Low-Pass filter with cutoff [fc], sample rate [fs]
  factory BiquadCoefficients.butterworthLowPass({
    double fc = 3.0,
    double fs = 50.0,
  }) {
    final c = math.tan(math.pi * fc / fs);
    final cSq = c * c;
    final sqrt2C = math.sqrt(2.0) * c;

    final a0 = 1.0 + sqrt2C + cSq;
    final b0 = cSq / a0;
    final b1 = (2.0 * cSq) / a0;
    final b2 = cSq / a0;
    final a1 = (2.0 * (cSq - 1.0)) / a0;
    final a2 = (1.0 - sqrt2C + cSq) / a0;

    return BiquadCoefficients(b0: b0, b1: b1, b2: b2, a1: a1, a2: a2);
  }

  /// 2nd-order Butterworth High-Pass filter with cutoff [fc], sample rate [fs]
  factory BiquadCoefficients.butterworthHighPass({
    double fc = 0.4,
    double fs = 50.0,
  }) {
    final c = math.tan(math.pi * fc / fs);
    final cSq = c * c;
    final sqrt2C = math.sqrt(2.0) * c;

    final a0 = 1.0 + sqrt2C + cSq;
    final b0 = 1.0 / a0;
    final b1 = -2.0 / a0;
    final b2 = 1.0 / a0;
    final a1 = (2.0 * (cSq - 1.0)) / a0;
    final a2 = (1.0 - sqrt2C + cSq) / a0;

    return BiquadCoefficients(b0: b0, b1: b1, b2: b2, a1: a1, a2: a2);
  }
}

/// Zero-Phase Signal Filtering and Noise Rejection Subsystem
///
/// HARD RULES:
/// 1. Raw sensor readings are NEVER modified in place.
/// 2. All feature extraction filters MUST be zero-phase (filtfilt forward-backward).
/// 3. Notch filters are calibrated per-trip, per-device; NEVER applied to bump detection.
class SignalFilterService {
  static const double defaultSampleRate = 50.0;
  static const double maneuverLowPassCutoffHz = 3.0;
  static const double bumpHighPassCutoffHz = 0.4;
  static const double notchMinQFactor = 10.0;

  // ──────────────────────────────────────────────────────────────────────────
  // Zero-Phase Bidirectional Filtering (filtfilt)
  // ──────────────────────────────────────────────────────────────────────────

  /// Run zero-phase forward-backward (filtfilt) filtering on a signal with biquad coefficients
  static List<double> filtfilt(List<double> signal, BiquadCoefficients coeffs) {
    final n = signal.length;
    if (n < 4) {
      // For very short signals, filtering is trivial or not applicable
      return List.from(signal);
    }

    // Pad edges to minimize startup and trailing transients
    final padLen = math.min(12, n - 1);
    final padded = List<double>.filled(n + 2 * padLen, 0.0);

    // Initial padding: reflect around first sample
    final first = signal.first;
    for (int i = 0; i < padLen; i++) {
      padded[i] = 2.0 * first - signal[padLen - i];
    }
    // Main body
    for (int i = 0; i < n; i++) {
      padded[padLen + i] = signal[i];
    }
    // Trailing padding: reflect around last sample
    final last = signal.last;
    for (int i = 0; i < padLen; i++) {
      padded[padLen + n + i] = 2.0 * last - signal[n - 2 - i];
    }

    // Forward pass
    final forward = _filterDirect(padded, coeffs);

    // Reverse for backward pass
    final reversed = forward.reversed.toList();

    // Backward pass
    final backward = _filterDirect(reversed, coeffs);

    // Reverse back to original order
    final resultPadded = backward.reversed.toList();

    // Extract central window excluding padding
    return resultPadded.sublist(padLen, padLen + n);
  }

  /// Causal direct-form II / I biquad filter
  static List<double> _filterDirect(List<double> input, BiquadCoefficients coeffs) {
    final n = input.length;
    final output = List<double>.filled(n, 0.0);

    double x1 = input.first;
    double x2 = input.first;
    double y1 = input.first;
    double y2 = input.first;

    for (int i = 0; i < n; i++) {
      final x0 = input[i];
      final y0 = coeffs.b0 * x0 + coeffs.b1 * x1 + coeffs.b2 * x2 - coeffs.a1 * y1 - coeffs.a2 * y2;

      output[i] = y0;

      x2 = x1;
      x1 = x0;
      y2 = y1;
      y1 = y0;
    }

    return output;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stage 2: Adaptive Narrow Notch Filter (removes steady-state engine hum)
  // ──────────────────────────────────────────────────────────────────────────

  /// Filter out narrow-band engine vibration from a signal using calibrated frequency.
  ///
  /// CRITICAL RULES:
  /// - If [calibration] is null or [calibration.calibrationValid] is false, this is a strict no-op.
  /// - Notch filter is NEVER applied to the bump detection channel.
  static List<double> applyEngineNotch({
    required List<double> signal,
    required IdleCalibrationResult? calibration,
    double sampleRate = defaultSampleRate,
    double qFactor = notchMinQFactor,
  }) {
    if (signal.isEmpty) return const [];

    // Fallback: If calibration is absent or invalid, return original signal untouched
    if (calibration == null || !calibration.calibrationValid) {
      return List.from(signal);
    }

    final f0 = calibration.engineNoiseFreqHz;
    // Frequency must be strictly below Nyquist and above 5Hz
    if (f0 <= 5.0 || f0 >= (sampleRate / 2.0)) {
      return List.from(signal);
    }

    final coeffs = BiquadCoefficients.notch(
      f0: f0,
      fs: sampleRate,
      q: math.max(qFactor, notchMinQFactor),
    );

    return filtfilt(signal, coeffs);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stage 3: Low-Pass for Maneuvers & Lean Angle (0–3Hz band)
  // ──────────────────────────────────────────────────────────────────────────

  /// 2nd-order zero-phase Butterworth low-pass at 3.0 Hz.
  /// Feeds lean angle, yaw rate smoothing, and sustained turn/brake detection.
  static List<double> applyManeuverLowPass(
    List<double> signal, {
    double cutoffHz = maneuverLowPassCutoffHz,
    double sampleRate = defaultSampleRate,
  }) {
    if (signal.isEmpty) return const [];
    final coeffs = BiquadCoefficients.butterworthLowPass(fc: cutoffHz, fs: sampleRate);
    return filtfilt(signal, coeffs);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stage 4: High-Pass + Envelope for Bump/Impact Detection (preserve transients)
  // ──────────────────────────────────────────────────────────────────────────

  /// Gentle 2nd-order zero-phase high-pass at 0.4 Hz to strip gravity/DC offset without
  /// touching transient impact signatures (5–25Hz).
  ///
  /// CRITICAL RULE: Peak severity scoring must ALWAYS read from this least-filtered channel.
  static List<double> applyBumpHighPass(
    List<double> signal, {
    double cutoffHz = bumpHighPassCutoffHz,
    double sampleRate = defaultSampleRate,
  }) {
    if (signal.isEmpty) return const [];
    final coeffs = BiquadCoefficients.butterworthHighPass(fc: cutoffHz, fs: sampleRate);
    return filtfilt(signal, coeffs);
  }

  /// Compute short-window RMS signal envelope (20–40ms sub-windows, e.g. 2 samples at 50Hz = 40ms)
  static List<double> computeRmsEnvelope(List<double> signal, {int windowSamples = 2}) {
    final n = signal.length;
    if (n == 0) return const [];
    if (n < windowSamples) {
      return signal.map((x) => x.abs()).toList();
    }

    final envelope = List<double>.filled(n, 0.0);
    final half = windowSamples ~/ 2;

    for (int i = 0; i < n; i++) {
      final start = math.max(0, i - half);
      final end = math.min(n, start + windowSamples);
      double sumSq = 0.0;
      for (int j = start; j < end; j++) {
        sumSq += signal[j] * signal[j];
      }
      envelope[i] = math.sqrt(sumSq / (end - start));
    }

    return envelope;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stage 5: Adaptive Noise Floor Thresholds
  // ──────────────────────────────────────────────────────────────────────────

  /// Compute adaptive threshold: baselineNoiseFloor + fixedMargin
  static double computeAdaptiveThreshold({
    required double fixedMargin,
    IdleCalibrationResult? calibration,
    double fallbackBaseline = 0.0,
  }) {
    final baseline = (calibration != null && calibration.calibrationValid)
        ? calibration.engineNoiseAmplitude
        : fallbackBaseline;

    return baseline + fixedMargin;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stage 6: Live Dashboard Display Filtering (Cosmetic Only — Causal EMA)
  // ──────────────────────────────────────────────────────────────────────────

  /// Simple causal exponential moving average for live 8 FPS UI display.
  ///
  /// HARD RULE: This data is cosmetic only and MUST NEVER feed the ML pipeline or DB.
  static double applyDashboardCausalEma({
    required double currentValue,
    required double? previousFilteredValue,
    double alpha = 0.25,
  }) {
    if (previousFilteredValue == null) return currentValue;
    return alpha * currentValue + (1.0 - alpha) * previousFilteredValue;
  }
}
