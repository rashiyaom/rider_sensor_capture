import 'dart:math' as math;

/// Represents a single peak in the frequency spectrum
class FftPeak {
  final double frequencyHz;
  final double amplitude;
  final int binIndex;

  const FftPeak({
    required this.frequencyHz,
    required this.amplitude,
    required this.binIndex,
  });

  @override
  String toString() => 'FftPeak(${frequencyHz.toStringAsFixed(2)} Hz, amp: ${amplitude.toStringAsFixed(4)})';
}

/// Result of an FFT analysis
class FftResult {
  final List<double> frequencies;
  final List<double> magnitudes;
  final double sampleRate;
  final int windowSize;

  const FftResult({
    required this.frequencies,
    required this.magnitudes,
    required this.sampleRate,
    required this.windowSize,
  });

  /// Find the dominant peak in a specified frequency range (e.g. 10 Hz - 24.5 Hz for 50Hz sampling)
  FftPeak findDominantPeak({double minFreqHz = 10.0, double maxFreqHz = 24.5}) {
    if (frequencies.isEmpty || magnitudes.isEmpty) {
      return const FftPeak(frequencyHz: 0.0, amplitude: 0.0, binIndex: 0);
    }

    double maxMag = -1.0;
    int maxIdx = -1;

    for (int i = 0; i < frequencies.length; i++) {
      final f = frequencies[i];
      if (f >= minFreqHz && f <= maxFreqHz) {
        if (magnitudes[i] > maxMag) {
          maxMag = magnitudes[i];
          maxIdx = i;
        }
      }
    }

    if (maxIdx == -1 || maxMag <= 0.0) {
      return const FftPeak(frequencyHz: 0.0, amplitude: 0.0, binIndex: 0);
    }

    return FftPeak(
      frequencyHz: frequencies[maxIdx],
      amplitude: magnitudes[maxIdx],
      binIndex: maxIdx,
    );
  }
}

/// Lightweight, standalone Radix-2 Cooley-Tukey FFT for on-device mobile DSP
class FftUtils {
  /// Check if an integer is a power of two
  static bool isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

  /// Next or nearest power of two <= maxVal or >= n
  static int nextPowerOfTwo(int n) {
    int p = 1;
    while (p < n) {
      p <<= 1;
    }
    return p;
  }

  /// Apply Hann window: w[n] = 0.5 * (1 - cos(2 * pi * n / (N - 1)))
  static List<double> applyHannWindow(List<double> signal) {
    final n = signal.length;
    if (n <= 1) return List.from(signal);

    final windowed = List<double>.filled(n, 0.0);
    final factor = 2.0 * math.pi / (n - 1);
    for (int i = 0; i < n; i++) {
      final w = 0.5 * (1.0 - math.cos(i * factor));
      windowed[i] = signal[i] * w;
    }
    return windowed;
  }

  /// Compute Radix-2 Cooley-Tukey FFT for a real input signal.
  /// If input length is not a power of two, it pads or truncates to [targetSize] (default 128 or 256).
  static FftResult computeRealFft(
    List<double> input, {
    double sampleRate = 50.0,
    int? targetSize,
    bool useHannWindow = true,
  }) {
    if (input.isEmpty) {
      return FftResult(
        frequencies: const [],
        magnitudes: const [],
        sampleRate: sampleRate,
        windowSize: 0,
      );
    }

    // Determine power-of-two size
    int n;
    if (targetSize != null) {
      n = isPowerOfTwo(targetSize) ? targetSize : nextPowerOfTwo(targetSize);
    } else {
      if (isPowerOfTwo(input.length)) {
        n = input.length;
      } else {
        // Default to 128 or 256 depending on length
        n = input.length >= 256 ? 256 : (input.length >= 128 ? 128 : nextPowerOfTwo(input.length));
      }
    }

    // Prepare real and imaginary buffers
    final real = List<double>.filled(n, 0.0);
    final imag = List<double>.filled(n, 0.0);

    final copyCount = math.min(input.length, n);
    for (int i = 0; i < copyCount; i++) {
      real[i] = input[i];
    }

    // Remove DC mean before windowing to prevent DC spectral leakage
    double mean = 0.0;
    for (int i = 0; i < copyCount; i++) {
      mean += real[i];
    }
    mean /= copyCount;
    for (int i = 0; i < copyCount; i++) {
      real[i] -= mean;
    }

    // Apply Hann window if requested
    double windowGain = 1.0;
    if (useHannWindow && n > 1) {
      final factor = 2.0 * math.pi / (n - 1);
      double winSum = 0.0;
      for (int i = 0; i < n; i++) {
        final w = 0.5 * (1.0 - math.cos(i * factor));
        real[i] *= w;
        winSum += w;
      }
      windowGain = winSum / n; // approx 0.5 for Hann
    }

    // In-place Radix-2 Cooley-Tukey FFT
    _radix2Fft(real, imag, n);

    // Compute one-sided magnitude spectrum (from 0 to N/2)
    final halfN = n ~/ 2;
    final frequencies = List<double>.filled(halfN + 1, 0.0);
    final magnitudes = List<double>.filled(halfN + 1, 0.0);

    final freqResolution = sampleRate / n;

    for (int k = 0; k <= halfN; k++) {
      frequencies[k] = k * freqResolution;
      final mag = math.sqrt(real[k] * real[k] + imag[k] * imag[k]);
      // Normalize magnitude
      if (k == 0 || k == halfN) {
        magnitudes[k] = mag / n;
      } else {
        // Factor of 2 for single-sided spectrum, normalized by window gain
        magnitudes[k] = (2.0 * mag) / (n * windowGain);
      }
    }

    return FftResult(
      frequencies: frequencies,
      magnitudes: magnitudes,
      sampleRate: sampleRate,
      windowSize: n,
    );
  }

  /// In-place decimation-in-time radix-2 FFT
  static void _radix2Fft(List<double> real, List<double> imag, int n) {
    // 1. Bit-reversal permutation
    int j = 0;
    for (int i = 0; i < n - 1; i++) {
      if (i < j) {
        final tempR = real[i];
        real[i] = real[j];
        real[j] = tempR;

        final tempI = imag[i];
        imag[i] = imag[j];
        imag[j] = tempI;
      }
      int k = n >> 1;
      while (k <= j) {
        j -= k;
        k >>= 1;
      }
      j += k;
    }

    // 2. Butterfly stages
    for (int len = 2; len <= n; len <<= 1) {
      final halfLen = len >> 1;
      final angle = -2.0 * math.pi / len;
      final wStepR = math.cos(angle);
      final wStepI = math.sin(angle);

      for (int i = 0; i < n; i += len) {
        double wR = 1.0;
        double wI = 0.0;

        for (int k = 0; k < halfLen; k++) {
          final uR = real[i + k];
          final uI = imag[i + k];

          final vR = real[i + k + halfLen] * wR - imag[i + k + halfLen] * wI;
          final vI = real[i + k + halfLen] * wI + imag[i + k + halfLen] * wR;

          real[i + k] = uR + vR;
          imag[i + k] = uI + vI;

          real[i + k + halfLen] = uR - vR;
          imag[i + k + halfLen] = uI - vI;

          final nextWR = wR * wStepR - wI * wStepI;
          final nextWI = wR * wStepI + wI * wStepR;
          wR = nextWR;
          wI = nextWI;
        }
      }
    }
  }
}
