import 'dart:convert';

/// Parameter set for Bump events
class BumpParameters {
  final double peakAccelMagnitude; // m/s^2
  final double peakGForce;         // in g (1g = 9.81 m/s^2)
  final double accelDelta;         // max - min magnitude in window
  final double peakToPeakChange;   // max positive swing
  final int durationMs;            // window duration in milliseconds
  final double? approxSpeedKmh;    // approximate speed if available
  final String severity;           // mild, moderate, severe

  const BumpParameters({
    required this.peakAccelMagnitude,
    required this.peakGForce,
    required this.accelDelta,
    required this.peakToPeakChange,
    required this.durationMs,
    this.approxSpeedKmh,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
    'peakAccelMagnitude': peakAccelMagnitude,
    'peakGForce': peakGForce,
    'accelDelta': accelDelta,
    'peakToPeakChange': peakToPeakChange,
    'durationMs': durationMs,
    'approxSpeedKmh': approxSpeedKmh,
    'severity': severity,
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
    );
  }

  String get summary => 'Peak ${peakGForce.toStringAsFixed(1)}g (${severity.toUpperCase()}), ${durationMs}ms';
}

/// Parameter set for Speed/Braking events
class SpeedParameters {
  final double averageSpeedKmh;
  final double peakSpeedKmh;
  final double avgAcceleration;    // m/s^2
  final bool isBraking;
  final double decelMagnitude;
  final int durationMs;

  const SpeedParameters({
    required this.averageSpeedKmh,
    required this.peakSpeedKmh,
    required this.avgAcceleration,
    required this.isBraking,
    required this.decelMagnitude,
    required this.durationMs,
  });

  Map<String, dynamic> toJson() => {
    'averageSpeedKmh': averageSpeedKmh,
    'peakSpeedKmh': peakSpeedKmh,
    'avgAcceleration': avgAcceleration,
    'isBraking': isBraking,
    'decelMagnitude': decelMagnitude,
    'durationMs': durationMs,
  };

  factory SpeedParameters.fromJson(Map<String, dynamic> json) {
    return SpeedParameters(
      averageSpeedKmh: (json['averageSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      peakSpeedKmh: (json['peakSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      avgAcceleration: (json['avgAcceleration'] as num?)?.toDouble() ?? 0.0,
      isBraking: json['isBraking'] as bool? ?? false,
      decelMagnitude: (json['decelMagnitude'] as num?)?.toDouble() ?? 0.0,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
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
  final int durationMs;
  final String classification;     // sharp, medium, easy

  const TurnParameters({
    required this.peakLateralAccel,
    required this.peakGyroDegPerSec,
    required this.durationMs,
    required this.classification,
  });

  Map<String, dynamic> toJson() => {
    'peakLateralAccel': peakLateralAccel,
    'peakGyroDegPerSec': peakGyroDegPerSec,
    'durationMs': durationMs,
    'classification': classification,
  };

  factory TurnParameters.fromJson(Map<String, dynamic> json) {
    return TurnParameters(
      peakLateralAccel: (json['peakLateralAccel'] as num?)?.toDouble() ?? 0.0,
      peakGyroDegPerSec: (json['peakGyroDegPerSec'] as num?)?.toDouble() ?? 0.0,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      classification: json['classification'] as String? ?? 'medium',
    );
  }

  String get summary => '${classification.toUpperCase()} turn (${peakLateralAccel.toStringAsFixed(1)} m/s² lat), ${durationMs}ms';
}

/// General event parameters container
class EventParameters {
  final BumpParameters? bump;
  final SpeedParameters? speed;
  final TurnParameters? turn;

  const EventParameters({this.bump, this.speed, this.turn});

  String get summary {
    if (bump != null) return bump!.summary;
    if (speed != null) return speed!.summary;
    if (turn != null) return turn!.summary;
    return 'Parameters computed';
  }

  String toJsonString() {
    final map = <String, dynamic>{};
    if (bump != null) map['bump'] = bump!.toJson();
    if (speed != null) map['speed'] = speed!.toJson();
    if (turn != null) map['turn'] = turn!.toJson();
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
      );
    } catch (_) {
      return null;
    }
  }
}
