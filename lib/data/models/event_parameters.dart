import 'dart:convert';

/// Parameter set for Bump events
class BumpParameters {
  final double peakAccelMagnitude; // m/s^2
  final double peakGForce;         // in g (1g = 9.80665 m/s^2)
  final double accelDelta;         // max - min magnitude in window
  final double peakToPeakChange;   // max positive swing
  final int durationMs;            // window duration in milliseconds
  final double? approxSpeedKmh;    // approximate speed if available
  final String severity;           // mild, moderate, severe
  final double? jerkPeakMagnitude; // m/s^3
  final double? baselineNoiseFloor;// baseline noise floor (g)
  final bool? calibrationValid;

  const BumpParameters({
    required this.peakAccelMagnitude,
    required this.peakGForce,
    required this.accelDelta,
    required this.peakToPeakChange,
    required this.durationMs,
    this.approxSpeedKmh,
    required this.severity,
    this.jerkPeakMagnitude,
    this.baselineNoiseFloor,
    this.calibrationValid,
  });

  Map<String, dynamic> toJson() => {
    'peakAccelMagnitude': peakAccelMagnitude,
    'peakGForce': peakGForce,
    'accelDelta': accelDelta,
    'peakToPeakChange': peakToPeakChange,
    'durationMs': durationMs,
    'approxSpeedKmh': approxSpeedKmh,
    'severity': severity,
    'jerkPeakMagnitude': jerkPeakMagnitude,
    'baselineNoiseFloor': baselineNoiseFloor,
    'calibrationValid': calibrationValid,
  };

  factory BumpParameters.fromJson(Map<String, dynamic> json) {
    return BumpParameters(
      peakAccelMagnitude: (json['peakAccelMagnitude'] as num?)?.toDouble() ?? 0.0,
      peakGForce: (json['peakGForce'] as num?)?.toDouble() ?? 0.0,
      accelDelta: (json['accelDelta'] as num?)?.toDouble() ?? 0.0,
      peakToPeakChange: (json['peakToPeakChange'] as num?)?.toDouble() ?? 0.0,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      approxSpeedKmh: (json['approxSpeedKmh'] as num?)?.toDouble(),
      severity: json['severity'] as String? ?? 'moderate',
      jerkPeakMagnitude: (json['jerkPeakMagnitude'] as num?)?.toDouble(),
      baselineNoiseFloor: (json['baselineNoiseFloor'] as num?)?.toDouble(),
      calibrationValid: json['calibrationValid'] as bool?,
    );
  }

  String get summary => 'Peak ${peakGForce.toStringAsFixed(1)}g (${severity.toUpperCase()}), ${durationMs}ms'
      '${jerkPeakMagnitude != null ? ', Jerk: ${jerkPeakMagnitude!.toStringAsFixed(1)} m/s³' : ''}';
}

/// Parameter set for Speed/Braking events
class SpeedParameters {
  final double averageSpeedKmh;
  final double peakSpeedKmh;
  final double avgAcceleration;    // m/s^2
  final bool isBraking;
  final double decelMagnitude;
  final int durationMs;
  final double? jerkPeakMagnitude;

  const SpeedParameters({
    required this.averageSpeedKmh,
    required this.peakSpeedKmh,
    required this.avgAcceleration,
    required this.isBraking,
    required this.decelMagnitude,
    required this.durationMs,
    this.jerkPeakMagnitude,
  });

  Map<String, dynamic> toJson() => {
    'averageSpeedKmh': averageSpeedKmh,
    'peakSpeedKmh': peakSpeedKmh,
    'avgAcceleration': avgAcceleration,
    'isBraking': isBraking,
    'decelMagnitude': decelMagnitude,
    'durationMs': durationMs,
    'jerkPeakMagnitude': jerkPeakMagnitude,
  };

  factory SpeedParameters.fromJson(Map<String, dynamic> json) {
    return SpeedParameters(
      averageSpeedKmh: (json['averageSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      peakSpeedKmh: (json['peakSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      avgAcceleration: (json['avgAcceleration'] as num?)?.toDouble() ?? 0.0,
      isBraking: json['isBraking'] as bool? ?? false,
      decelMagnitude: (json['decelMagnitude'] as num?)?.toDouble() ?? 0.0,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      jerkPeakMagnitude: (json['jerkPeakMagnitude'] as num?)?.toDouble(),
    );
  }

  String get summary => isBraking
      ? 'Braking: Decel ${decelMagnitude.toStringAsFixed(1)} m/s², ${durationMs}ms'
      : 'Peak ${peakSpeedKmh.toStringAsFixed(1)} km/h, Avg Accel ${avgAcceleration.toStringAsFixed(1)} m/s²';
}

/// Parameter set for Turn events
class TurnParameters {
  final double peakLateralAccel;   // m/s^2
  final double peakGyroDegPerSec;  // deg/s
  final double maxLeanAngleDeg;    // degrees from complementary filter
  final String turnDirection;      // 'left' or 'right'
  final int durationMs;
  final String classification;     // sharp, medium, easy
  final double? gpsHeadingDeltaDeg;// GPS heading delta correlation

  const TurnParameters({
    required this.peakLateralAccel,
    required this.peakGyroDegPerSec,
    this.maxLeanAngleDeg = 0.0,
    this.turnDirection = 'left',
    required this.durationMs,
    required this.classification,
    this.gpsHeadingDeltaDeg,
  });

  Map<String, dynamic> toJson() => {
    'peakLateralAccel': peakLateralAccel,
    'peakGyroDegPerSec': peakGyroDegPerSec,
    'maxLeanAngleDeg': maxLeanAngleDeg,
    'turnDirection': turnDirection,
    'durationMs': durationMs,
    'classification': classification,
    'gpsHeadingDeltaDeg': gpsHeadingDeltaDeg,
  };

  factory TurnParameters.fromJson(Map<String, dynamic> json) {
    return TurnParameters(
      peakLateralAccel: (json['peakLateralAccel'] as num?)?.toDouble() ?? 0.0,
      peakGyroDegPerSec: (json['peakGyroDegPerSec'] as num?)?.toDouble() ?? 0.0,
      maxLeanAngleDeg: (json['maxLeanAngleDeg'] as num?)?.toDouble() ?? 0.0,
      turnDirection: json['turnDirection'] as String? ?? 'left',
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      classification: json['classification'] as String? ?? 'medium',
      gpsHeadingDeltaDeg: (json['gpsHeadingDeltaDeg'] as num?)?.toDouble(),
    );
  }

  String get summary => '${classification.toUpperCase()} $turnDirection turn (${peakLateralAccel.toStringAsFixed(1)} m/s² lat, lean ${maxLeanAngleDeg.toStringAsFixed(1)}°), ${durationMs}ms';
}

/// General event parameters container
class EventParameters {
  final BumpParameters? bump;
  final SpeedParameters? speed;
  final TurnParameters? turn;
  final double? gpsLat;
  final double? gpsLng;
  final double? gpsSpeedKmh;
  final bool crossConfirmed;
  final double? forkFootLagMs;
  final bool hrSpikeConfirmed;
  final double? hrDeltaAtEvent;
  final bool? calibrationValid;
  final double? engineNoiseFreqHz;

  const EventParameters({
    this.bump,
    this.speed,
    this.turn,
    this.gpsLat,
    this.gpsLng,
    this.gpsSpeedKmh,
    this.crossConfirmed = false,
    this.forkFootLagMs,
    this.hrSpikeConfirmed = false,
    this.hrDeltaAtEvent,
    this.calibrationValid,
    this.engineNoiseFreqHz,
  });

  String get summary {
    String base = 'Parameters computed';
    if (bump != null) base = bump!.summary;
    if (speed != null) base = speed!.summary;
    if (turn != null) base = turn!.summary;

    final tags = <String>[];
    if (crossConfirmed) tags.add('CROSS-CONFIRMED');
    if (hrSpikeConfirmed) tags.add('HR-SPIKE (+${hrDeltaAtEvent?.toStringAsFixed(0)} bpm)');
    if (calibrationValid == false) tags.add('CALIBRATION-INVALID');

    return tags.isNotEmpty ? '$base [${tags.join(", ")}]' : base;
  }

  String toJsonString() {
    final map = <String, dynamic>{};
    if (bump != null) map['bump'] = bump!.toJson();
    if (speed != null) map['speed'] = speed!.toJson();
    if (turn != null) map['turn'] = turn!.toJson();
    if (gpsLat != null) map['gpsLat'] = gpsLat;
    if (gpsLng != null) map['gpsLng'] = gpsLng;
    if (gpsSpeedKmh != null) map['gpsSpeedKmh'] = gpsSpeedKmh;
    map['crossConfirmed'] = crossConfirmed;
    if (forkFootLagMs != null) map['forkFootLagMs'] = forkFootLagMs;
    map['hrSpikeConfirmed'] = hrSpikeConfirmed;
    if (hrDeltaAtEvent != null) map['hrDeltaAtEvent'] = hrDeltaAtEvent;
    if (calibrationValid != null) map['calibrationValid'] = calibrationValid;
    if (engineNoiseFreqHz != null) map['engineNoiseFreqHz'] = engineNoiseFreqHz;
    return jsonEncode(map);
  }

  static EventParameters? fromJsonString(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return EventParameters(
        bump: map['bump'] != null ? BumpParameters.fromJson(map['bump']) : null,
        speed: map['speed'] != null ? SpeedParameters.fromJson(map['speed']) : null,
        turn: map['turn'] != null ? TurnParameters.fromJson(map['turn']) : null,
        gpsLat: (map['gpsLat'] as num?)?.toDouble(),
        gpsLng: (map['gpsLng'] as num?)?.toDouble(),
        gpsSpeedKmh: (map['gpsSpeedKmh'] as num?)?.toDouble(),
        crossConfirmed: map['crossConfirmed'] as bool? ?? false,
        forkFootLagMs: (map['forkFootLagMs'] as num?)?.toDouble(),
        hrSpikeConfirmed: map['hrSpikeConfirmed'] as bool? ?? false,
        hrDeltaAtEvent: (map['hrDeltaAtEvent'] as num?)?.toDouble(),
        calibrationValid: map['calibrationValid'] as bool?,
        engineNoiseFreqHz: (map['engineNoiseFreqHz'] as num?)?.toDouble(),
      );
    } catch (_) {
      return null;
    }
  }
}
