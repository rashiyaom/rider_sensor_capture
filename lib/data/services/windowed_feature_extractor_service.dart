import 'dart:math' as math;

import '../../core/utils/fft_utils.dart';
import '../local_db/database.dart';

/// Comprehensive on-device ML feature extraction service.
/// Transforms raw 50Hz time-series sensor streams into fixed-window tabular ML feature rows
/// (features_windowed.csv) complete with label encodings and train/val/test splits.
class WindowedFeatureExtractorService {
  final double sampleRateHz;
  final double windowDurationSec;
  final double strideDurationSec;

  static const Map<String, int> labelMapping = {
    'normal_riding': 0,
    'normal': 0,
    'bump': 1,
    'turn': 2,
    'speedtest': 3,
    'speed_test': 3,
    'hardbrake': 4,
    'brake': 4,
    'voicetag': 5,
    'voice_tag': 5,
  };

  const WindowedFeatureExtractorService({
    this.sampleRateHz = 50.0,
    this.windowDurationSec = 1.5,
    this.strideDurationSec = 0.5,
  });

  int get windowSizeSamples => (windowDurationSec * sampleRateHz).round();
  int get strideSamples => (strideDurationSec * sampleRateHz).round();

  /// Converts raw 50Hz sensor readings and events into tabular ML feature maps.
  List<Map<String, dynamic>> extractWindows({
    required List<SensorReading> readings,
    List<EventRecord> events = const [],
    int? tripId,
    String? forcedSplit, // 'train', 'val', 'test'
  }) {
    if (readings.isEmpty) return [];

    if (windowDurationSec <= 0 || strideDurationSec <= 0 || sampleRateHz <= 0) {
      throw ArgumentError('Window, stride and sample rate must be positive.');
    }
    final ordered = [...readings]
      ..sort((a, b) {
        final time = a.timestampUtc.compareTo(b.timestampUtc);
        return time != 0 ? time : a.id.compareTo(b.id);
      });
    final width = (windowDurationSec * 1000000).round();
    final stride = (strideDurationSec * 1000000).round();
    if (width < 1 || stride < 1) {
      throw ArgumentError('Window and stride must be at least one microsecond.');
    }
    final origin = ordered.first.timestampUtc.microsecondsSinceEpoch;
    // Include the last sample's nominal interval, using elapsed time rather
    // than the number of rows across all connected devices.
    final stop =
        ordered.last.timestampUtc.microsecondsSinceEpoch +
        (1000000 / sampleRateHz).round();
    if (forcedSplit == null && stop - origin >= width * 3) {
      // Partition raw time before windowing. Reserve at least one complete
      // window for each held-out partition; no sample may cross a boundary.
      final total = stop - origin;
      final testWidth = math.max(width, (total * .15).round());
      final validationWidth = math.max(width, (total * .15).round());
      final trainEnd = stop - testWidth - validationWidth;
      final validationEnd = stop - testWidth;
      final result = <Map<String, dynamic>>[];
      int offset = 0;
      for (final part in [
        ('train', origin, trainEnd),
        ('val', trainEnd, validationEnd),
        ('test', validationEnd, stop),
      ]) {
        final slice = ordered
            .where(
              (r) =>
                  r.timestampUtc.microsecondsSinceEpoch >= part.$2 &&
                  r.timestampUtc.microsecondsSinceEpoch < part.$3,
            )
            .toList();
        final extracted = extractWindows(
          readings: slice,
          events: events,
          tripId: tripId,
          forcedSplit: part.$1,
        );
        for (final row in extracted) {
          row['window_index'] = result.length + 1;
          row['start_row_idx'] = (row['start_row_idx'] as int) + offset;
          row['end_row_idx'] = (row['end_row_idx'] as int) + offset;
          row['split_strategy'] = 'chronological_disjoint_samples';
          result.add(row);
        }
        offset += slice.length;
      }
      return result;
    }
    final eventLookup = <int, EventRecord>{for (final e in events) e.id: e};
    final windows = <Map<String, dynamic>>[];
    int left = 0, right = 0;
    final count = math.max(1, ((stop - origin - width) ~/ stride) + 1);
    for (var index = 0; index < count; index++) {
      final start = origin + index * stride;
      final end = start + width;
      while (left < ordered.length &&
          ordered[left].timestampUtc.microsecondsSinceEpoch < start) {
        left++;
      }
      if (right < left) right = left;
      while (right < ordered.length &&
          ordered[right].timestampUtc.microsecondsSinceEpoch < end) {
        right++;
      }
      if (left == right) continue;
      windows.add(
        _extractSingleWindow(
          readings: ordered.sublist(left, right),
          events: events,
          eventLookup: eventLookup,
          windowIndex: windows.length + 1,
          startRowIdx: left + 1,
          endRowIdx: right,
          tripId: tripId,
          split: forcedSplit ?? 'train',
        ),
      );
    }

    return windows;
  }

  /// Exports feature list as a complete, self-contained CSV string.
  String buildCsv(List<Map<String, dynamic>> windows) {
    if (windows.isEmpty) return '';

    final headers = windows.first.keys.toList();
    final buffer = StringBuffer();
    buffer.writeln(headers.join(','));

    for (final row in windows) {
      final line = headers
          .map((h) {
            final val = row[h];
            if (val == null) return '';
            if (val is double) {
              return val.toStringAsFixed(4);
            }
            final str = val.toString();
            if (str.contains(',') || str.contains('"')) {
              return '"${str.replaceAll('"', '""')}"';
            }
            return str;
          })
          .join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  Map<String, dynamic> _extractSingleWindow({
    required List<SensorReading> readings,
    List<EventRecord> events = const [],
    Map<int, EventRecord>? eventLookup,
    required int windowIndex,
    required int startRowIdx,
    required int endRowIdx,
    int? tripId,
    required String split,
  }) {
    final startTime = readings.first.timestampUtc;
    final endTime = readings.last.timestampUtc;
    final durationSec = endTime.difference(startTime).inMilliseconds / 1000.0;

    // 1. Identify dominant ground-truth label in this window
    String targetLabel = 'normal_riding';
    int? activeEventId;
    EventRecord? matchedEvent;

    // Count non-null event IDs in window
    final eventCounts = <int, int>{};
    for (final r in readings) {
      if (r.eventId != null) {
        eventCounts[r.eventId!] = (eventCounts[r.eventId!] ?? 0) + 1;
      }
    }

    if (eventCounts.isNotEmpty) {
      // Pick most frequent event ID in this window
      int maxCount = 0;
      int bestId = eventCounts.keys.first;
      for (final entry in eventCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          bestId = entry.key;
        }
      }

      // If event covers at least 25% of window, assign event label
      if (maxCount >= (readings.length * 0.25)) {
        activeEventId = bestId;
        matchedEvent =
            eventLookup?[bestId] ??
            events.cast<EventRecord?>().firstWhere(
              (e) => e?.id == bestId,
              orElse: () => null,
            );
        if (matchedEvent != null) {
          targetLabel = matchedEvent.eventType.toLowerCase().trim();
        }
      }
    }

    final targetLabelId = labelMapping[targetLabel] ?? 6; // 6 = other/custom

    final row = <String, dynamic>{
      'window_index': windowIndex,
      'trip_id': tripId ?? readings.first.tripId,
      'dataset_split': split,
      'split_strategy': 'single_partition',
      'start_time_utc': startTime.toIso8601String(),
      'end_time_utc': endTime.toIso8601String(),
      'start_row_idx': startRowIdx,
      'end_row_idx': endRowIdx,
      'duration_sec': durationSec,
      'sample_count': readings.length,
      'target_label': targetLabel,
      'target_label_id': targetLabelId,
      'event_id': activeEventId,
      'event_classification': matchedEvent?.classification,
      'event_cross_confirmed': matchedEvent?.crossConfirmed == true ? 1 : 0,
      'event_hr_spike_confirmed': matchedEvent?.hrSpikeConfirmed == true
          ? 1
          : 0,
    };

    // Separate Watch 1 (Fork/Primary) vs Watch 2 (Footboard) vs Polar readings
    final w1Ax = <double>[];
    final w1Ay = <double>[];
    final w1Az = <double>[];
    final w1Gx = <double>[];
    final w1Gy = <double>[];
    final w1Gz = <double>[];
    final w1Roll = <double>[];
    final w1Pitch = <double>[];

    final w2Ax = <double>[];
    final w2Ay = <double>[];
    final w2Az = <double>[];
    final w2Gx = <double>[];
    final w2Gy = <double>[];
    final w2Gz = <double>[];

    final polarHrs = <double>[];
    final w1Hrs = <double>[];
    final w2Hrs = <double>[];

    final imuByDevice = <String, List<SensorReading>>{};
    for (final r in readings) {
      if (r.accelX?.isFinite == true &&
          r.accelY?.isFinite == true &&
          r.accelZ?.isFinite == true) {
        imuByDevice.putIfAbsent(r.deviceId, () => []).add(r);
      }
    }
    bool secondary(SensorReading r) =>
        r.mountLocation.toLowerCase().contains('foot') ||
        r.mountLocation.toLowerCase().contains('right') ||
        r.deviceId.contains('watch_2');
    final primaryDevices = imuByDevice.values
        .where((v) => !secondary(v.first))
        .toList();
    final secondaryDevices = imuByDevice.values
        .where((v) => secondary(v.first))
        .toList();
    final primary = primaryDevices.isEmpty
        ? <SensorReading>[]
        : primaryDevices.first;
    final secondaryRows = secondaryDevices.isEmpty
        ? <SensorReading>[]
        : secondaryDevices.first;
    final primaryRate = _regularRate(primary);
    final secondaryRate = _regularRate(secondaryRows);
    row['w1_device_id'] = primary.isEmpty ? '' : primary.first.deviceId;
    row['w2_device_id'] = secondaryRows.isEmpty
        ? ''
        : secondaryRows.first.deviceId;
    row['w1_sample_rate_hz'] = primaryRate;
    row['w2_sample_rate_hz'] = secondaryRate;
    row['extra_imu_devices'] = math.max(
      0,
      imuByDevice.length -
          (primary.isEmpty ? 0 : 1) -
          (secondaryRows.isEmpty ? 0 : 1),
    );
    for (final r in readings) {
      if ((r.accelX != null || r.accelY != null || r.accelZ != null) &&
          !(r.accelX?.isFinite == true &&
              r.accelY?.isFinite == true &&
              r.accelZ?.isFinite == true)) {
        continue;
      }
      final isW2 = secondary(r);
      if (r.accelX != null &&
          r.deviceId != (primary.isEmpty ? null : primary.first.deviceId) &&
          r.deviceId !=
              (secondaryRows.isEmpty ? null : secondaryRows.first.deviceId)) {
        continue;
      }

      final ax = r.accelX;
      final ay = r.accelY;
      final az = r.accelZ;
      final gx = r.gyroX;
      final gy = r.gyroY;
      final gz = r.gyroZ;
      final hr = r.heartRate?.toDouble();

      double? roll;
      double? pitch;
      if (ax != null && ay != null && az != null) {
        roll = math.atan2(ay, az) * (180.0 / math.pi);
        pitch =
            math.atan2(-ax, math.sqrt(ay * ay + az * az)) * (180.0 / math.pi);
      }

      if (isW2) {
        if (ax != null) w2Ax.add(ax);
        if (ay != null) w2Ay.add(ay);
        if (az != null) w2Az.add(az);
        if (gx != null) w2Gx.add(gx);
        if (gy != null) w2Gy.add(gy);
        if (gz != null) w2Gz.add(gz);
        if (hr != null && hr > 30) w2Hrs.add(hr);
      } else {
        if (ax != null) w1Ax.add(ax);
        if (ay != null) w1Ay.add(ay);
        if (az != null) w1Az.add(az);
        if (gx != null) w1Gx.add(gx);
        if (gy != null) w1Gy.add(gy);
        if (gz != null) w1Gz.add(gz);
        if (roll != null) w1Roll.add(roll);
        if (pitch != null) w1Pitch.add(pitch);
        if (hr != null && hr > 30) w1Hrs.add(hr);
      }

      if (r.deviceType.toLowerCase().contains('polar') &&
          hr != null &&
          hr > 30) {
        polarHrs.add(hr);
      }
    }

    // 2. Extract Watch 1 IMU Statistical & FFT Features
    _extractChannelFeatures(row, 'w1_accel_x', w1Ax, rate: primaryRate);
    _extractChannelFeatures(row, 'w1_accel_y', w1Ay, rate: primaryRate);
    _extractChannelFeatures(row, 'w1_accel_z', w1Az, rate: primaryRate);
    _extractChannelFeatures(row, 'w1_gyro_x', w1Gx, rate: primaryRate);
    _extractChannelFeatures(row, 'w1_gyro_y', w1Gy, rate: primaryRate);
    _extractChannelFeatures(row, 'w1_gyro_z', w1Gz, rate: primaryRate);
    _extractChannelFeatures(row, 'w1_roll_deg', w1Roll, rate: primaryRate);
    _extractChannelFeatures(row, 'w1_pitch_deg', w1Pitch, rate: primaryRate);

    // Watch 1 Vector Magnitudes
    final w1AccelMag = _computeVectorMagnitude(w1Ax, w1Ay, w1Az);
    _extractChannelFeatures(row, 'w1_accel_mag', w1AccelMag, rate: primaryRate);

    final w1GyroMag = _computeVectorMagnitude(w1Gx, w1Gy, w1Gz);
    _extractChannelFeatures(row, 'w1_gyro_mag', w1GyroMag, rate: primaryRate);

    // 3. Extract Watch 2 IMU Features
    _extractChannelFeatures(row, 'w2_accel_x', w2Ax, rate: secondaryRate);
    _extractChannelFeatures(row, 'w2_accel_y', w2Ay, rate: secondaryRate);
    _extractChannelFeatures(row, 'w2_accel_z', w2Az, rate: secondaryRate);
    _extractChannelFeatures(row, 'w2_gyro_x', w2Gx, rate: secondaryRate);
    _extractChannelFeatures(row, 'w2_gyro_y', w2Gy, rate: secondaryRate);
    _extractChannelFeatures(row, 'w2_gyro_z', w2Gz, rate: secondaryRate);

    final w2AccelMag = _computeVectorMagnitude(w2Ax, w2Ay, w2Az);
    _extractChannelFeatures(
      row,
      'w2_accel_mag',
      w2AccelMag,
      rate: secondaryRate,
    );

    // 4. Cross-Sensor Dual-Watch Inter-Correlation
    if (primaryRate > 0 &&
        (primaryRate - secondaryRate).abs() < 0.01 &&
        primary.length == secondaryRows.length &&
        primary.isNotEmpty &&
        List.generate(
          primary.length,
          (i) =>
              primary[i].timestampUtc
                  .difference(secondaryRows[i].timestampUtc)
                  .inMicroseconds
                  .abs() <
              1000,
        ).every((v) => v)) {
      final corrStats = _computeCrossCorrelation(w1Az, w2Az, primaryRate);
      row['fork_foot_corr_peak'] = corrStats.peakCorr;
      row['fork_foot_lag_ms'] = corrStats.lagMs;
    } else {
      row['fork_foot_corr_peak'] = 0.0;
      row['fork_foot_lag_ms'] = 0.0;
    }

    // 5. Physiological Features
    _extractHeartRateFeatures(row, 'polar_hr', polarHrs);
    _extractHeartRateFeatures(row, 'w1_hr', w1Hrs);
    _extractHeartRateFeatures(row, 'w2_hr', w2Hrs);

    // 6. Kinematics (Jerk & Dynamic Changes)
    if (w1AccelMag.length >= 2) {
      double maxJerk = 0.0;
      for (int i = 1; i < w1AccelMag.length; i++) {
        final dt =
            primary[i].timestampUtc
                .difference(primary[i - 1].timestampUtc)
                .inMicroseconds /
            1000000.0;
        if (dt <= 0) continue;
        final jerk = (w1AccelMag[i] - w1AccelMag[i - 1]).abs() / dt;
        if (jerk > maxJerk) maxJerk = jerk;
      }
      row['w1_peak_jerk_mps3'] = maxJerk;
    } else {
      row['w1_peak_jerk_mps3'] = 0.0;
    }

    return row;
  }

  // Irregular streams have no valid fixed-rate FFT. Keep statistical/elapsed
  // time features, but mark their spectral sampling rate unavailable (zero).
  double _regularRate(List<SensorReading> rows) {
    if (rows.length < 2) return 0;
    final intervals = [
      for (var i = 1; i < rows.length; i++)
        rows[i].timestampUtc
            .difference(rows[i - 1].timestampUtc)
            .inMicroseconds,
    ];
    if (intervals.any((dt) => dt <= 0)) return 0;
    final mean = intervals.reduce((a, b) => a + b) / intervals.length;
    if (intervals.any((dt) => (dt - mean).abs() > mean * .05)) return 0;
    return 1000000 / mean;
  }

  void _extractChannelFeatures(
    Map<String, dynamic> row,
    String prefix,
    List<double> values, {
    required double rate,
  }) {
    if (values.isEmpty) {
      row['${prefix}_mean'] = 0.0;
      row['${prefix}_std'] = 0.0;
      row['${prefix}_rms'] = 0.0;
      row['${prefix}_ptp'] = 0.0;
      row['${prefix}_min'] = 0.0;
      row['${prefix}_max'] = 0.0;
      row['${prefix}_zero_crossings'] = 0;
      row['${prefix}_spectral_energy'] = 0.0;
      row['${prefix}_dominant_freq_hz'] = 0.0;
      return;
    }

    // Mean
    double sum = 0.0;
    double min = values.first;
    double max = values.first;
    for (final v in values) {
      sum += v;
      if (v < min) min = v;
      if (v > max) max = v;
    }
    final mean = sum / values.length;

    // Variance, RMS, Zero Crossings
    double sumSqDiff = 0.0;
    double sumSq = 0.0;
    int zc = 0;

    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      final diff = v - mean;
      sumSqDiff += diff * diff;
      sumSq += v * v;

      if (i > 0) {
        final prevDiff = values[i - 1] - mean;
        if ((diff >= 0 && prevDiff < 0) || (diff < 0 && prevDiff >= 0)) {
          zc++;
        }
      }
    }

    final std = values.length > 1
        ? math.sqrt(sumSqDiff / (values.length - 1))
        : 0.0;
    final rms = math.sqrt(sumSq / values.length);
    final ptp = max - min;

    row['${prefix}_mean'] = mean;
    row['${prefix}_std'] = std;
    row['${prefix}_rms'] = rms;
    row['${prefix}_ptp'] = ptp;
    row['${prefix}_min'] = min;
    row['${prefix}_max'] = max;
    row['${prefix}_zero_crossings'] = zc;

    // Fast FFT for Spectral Energy & Dominant Frequency
    if (values.length >= 16 && rate > 0) {
      final fft = FftUtils.computeRealFft(
        values,
        sampleRate: rate,
        useHannWindow: true,
      );
      double spectralEnergy = 0.0;
      for (final mag in fft.magnitudes) {
        spectralEnergy += mag * mag;
      }
      final peak = fft.findDominantPeak(
        minFreqHz: 0.5,
        maxFreqHz: math.min(24.5, rate / 2),
      );
      row['${prefix}_spectral_energy'] = spectralEnergy;
      row['${prefix}_dominant_freq_hz'] = peak.frequencyHz;
    } else {
      row['${prefix}_spectral_energy'] = 0.0;
      row['${prefix}_dominant_freq_hz'] = 0.0;
    }
  }

  void _extractHeartRateFeatures(
    Map<String, dynamic> row,
    String prefix,
    List<double> hrs,
  ) {
    if (hrs.isEmpty) {
      row['${prefix}_mean_bpm'] = 0.0;
      row['${prefix}_delta_bpm'] = 0.0;
      return;
    }

    double sum = 0.0;
    for (final h in hrs) {
      sum += h;
    }
    row['${prefix}_mean_bpm'] = sum / hrs.length;
    row['${prefix}_delta_bpm'] = hrs.last - hrs.first;
  }

  List<double> _computeVectorMagnitude(
    List<double> x,
    List<double> y,
    List<double> z,
  ) {
    final len = math.min(x.length, math.min(y.length, z.length));
    final mags = List<double>.filled(len, 0.0);
    for (int i = 0; i < len; i++) {
      mags[i] = math.sqrt(x[i] * x[i] + y[i] * y[i] + z[i] * z[i]);
    }
    return mags;
  }

  _CorrResult _computeCrossCorrelation(
    List<double> s1,
    List<double> s2,
    double rate,
  ) {
    final len = math.min(s1.length, s2.length);
    if (len < 8) return const _CorrResult(0.0, 0.0);

    final sub1 = s1.sublist(0, len);
    final sub2 = s2.sublist(0, len);

    double m1 = 0.0;
    double m2 = 0.0;
    for (int i = 0; i < len; i++) {
      m1 += sub1[i];
      m2 += sub2[i];
    }
    m1 /= len;
    m2 /= len;

    double var1 = 0.0;
    double var2 = 0.0;
    for (int i = 0; i < len; i++) {
      final d1 = sub1[i] - m1;
      final d2 = sub2[i] - m2;
      var1 += d1 * d1;
      var2 += d2 * d2;
    }

    final denom = math.sqrt(var1 * var2);
    if (denom <= 1e-6) return const _CorrResult(0.0, 0.0);

    const maxLagSamples = 15; // ±300ms at 50Hz
    double maxCorr = -1.0;
    int bestLag = 0;

    for (int lag = -maxLagSamples; lag <= maxLagSamples; lag++) {
      double sum = 0.0;
      int count = 0;
      for (int i = 0; i < len; i++) {
        final j = i + lag;
        if (j >= 0 && j < len) {
          sum += (sub1[i] - m1) * (sub2[j] - m2);
          count++;
        }
      }
      if (count > 0) {
        final r = (sum / denom).abs();
        if (r > maxCorr) {
          maxCorr = r;
          bestLag = lag;
        }
      }
    }

    final lagMs = (bestLag / rate) * 1000.0;
    return _CorrResult(maxCorr, lagMs);
  }
}

class _CorrResult {
  final double peakCorr;
  final double lagMs;
  const _CorrResult(this.peakCorr, this.lagMs);
}
