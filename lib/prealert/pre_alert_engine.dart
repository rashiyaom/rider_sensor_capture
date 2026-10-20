import 'dart:math' as math;

import '../../location/geo_math.dart';

/// The kinds of road events the predictive pre-alert system understands.
enum RoadEventKind {
  bump,
  pothole,
  turn,
  braking,
  hazard,
  unknown;

  /// Maps the loose `eventType` strings coming from the ML / camera pipelines
  /// onto the canonical kinds used by the pre-alert system.
  static RoadEventKind fromString(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v.contains('pothole')) return RoadEventKind.pothole;
    if (v.contains('bump') || v.contains('speedbump') || v.contains('speed_bump')) {
      return RoadEventKind.bump;
    }
    if (v.contains('turn') || v.contains('corner') || v.contains('curve')) {
      return RoadEventKind.turn;
    }
    if (v.contains('brak') || v.contains('decel') || v.contains('speedtest')) {
      return RoadEventKind.braking;
    }
    if (v.contains('hazard') || v.contains('obstacle') || v.contains('debris')) {
      return RoadEventKind.hazard;
    }
    return RoadEventKind.unknown;
  }

  /// Human-readable label used in the spoken alert and in the UI.
  String get label {
    switch (this) {
      case RoadEventKind.bump:
        return 'Speed bump';
      case RoadEventKind.pothole:
        return 'Pothole';
      case RoadEventKind.turn:
        return 'Sharp turn';
      case RoadEventKind.braking:
        return 'Braking zone';
      case RoadEventKind.hazard:
        return 'Road hazard';
      case RoadEventKind.unknown:
        return 'Road event';
    }
  }
}

/// A geo-tagged hazard known to the pre-alert system.
class RoadEventCandidate {
  /// Row id in the `road_events` table (null for unsaved candidates).
  final int? id;
  final RoadEventKind kind;
  final double latitude;
  final double longitude;

  /// Normalized 0..1 severity.
  final double severity;

  /// Model confidence 0..1.
  final double confidence;

  /// Origin of the detection: ml | camera | voice | manual.
  final String source;

  final DateTime detectedAtUtc;

  /// Ground speed at the time the hazard was detected.
  final double? speedKmhAtDetection;

  const RoadEventCandidate({
    this.id,
    required this.kind,
    required this.latitude,
    required this.longitude,
    this.severity = 0.5,
    this.confidence = 0.8,
    this.source = 'ml',
    required this.detectedAtUtc,
    this.speedKmhAtDetection,
  });
}

/// Where the hazard currently sits relative to the rider's warning window.
enum PreAlertWindow {
  /// The hazard is still too far away (in time) to be worth interrupting.
  tooEarly,

  /// The hazard is inside the usable warning window — speak now.
  inWindow,

  /// The hazard is imminent; a pre-alert would arrive too late to be useful.
  tooLate,
}

/// How pressing the warning is.
enum PreAlertUrgency {
  advisory,
  warning,
  imminent,
}

/// The result of evaluating one hazard against the rider's current state.
class PreAlertDecision {
  final RoadEventCandidate candidate;
  final double distanceMeters;
  final double bearingDeg;

  /// Signed angle between the rider's heading and the hazard bearing.
  final double relativeBearingDeg;

  final double speedKmh;

  /// distance / speed — the seconds available to react.
  final double timeToEventSeconds;

  /// Speed the rider should adopt to clear the hazard safely.
  final double recommendedSpeedKmh;

  final PreAlertUrgency urgency;
  final PreAlertWindow window;

  /// True when the decision is worth speaking to the rider right now.
  final bool shouldSpeak;

  const PreAlertDecision({
    required this.candidate,
    required this.distanceMeters,
    required this.bearingDeg,
    required this.relativeBearingDeg,
    required this.speedKmh,
    required this.timeToEventSeconds,
    required this.recommendedSpeedKmh,
    required this.urgency,
    required this.window,
    required this.shouldSpeak,
  });

  /// True when the hazard is roughly in front of the rider.
  bool get isAhead => relativeBearingDeg.abs() <= 90.0;
}

/// Configuration + decision logic for the predictive pre-alert system.
///
/// The engine is deliberately **pure**: it takes the rider's current position,
/// heading and speed plus the list of known hazards, and returns the best
/// warning to speak. No I/O, no plugins — which makes the safety-critical
/// maths fully unit-testable.
class PreAlertEngine {
  /// Shortest time-to-event that is still worth interrupting the rider for.
  /// Below this the warning would arrive after the hazard.
  final double minWarningSeconds;

  /// Longest time-to-event that is still worth interrupting the rider for.
  /// Above this the rider has plenty of time and would find it noisy.
  final double maxWarningSeconds;

  /// Hazards further away than this are ignored entirely.
  final double maxConsiderDistanceMeters;

  /// Below this speed the rider is crawling — a pre-alert is pointless.
  final double minSpeedKmh;

  /// Above this speed the GPS fix is considered unreliable.
  final double maxSpeedKmh;

  /// Half-angle of the forward cone in which hazards are considered "ahead".
  final double forwardConeDegrees;

  /// Pass speed (km/h) the rider should adopt for the most severe hazards.
  final double targetEventSpeedKmh;

  /// Pass speed (km/h) the rider may keep for a harmless hazard.
  final double mildEventSpeedKmh;

  /// Human reaction latency budget (seconds).
  final double reactionTimeSeconds;

  /// Comfortable maximum deceleration (m/s²) used for the speed advice.
  final double maxDecelerationMps2;

  /// Time-to-event at or below which the alert is flagged "imminent".
  final double imminentThresholdSeconds;

  /// Time-to-event at or below which the alert is flagged "warning".
  final double warningThresholdSeconds;

  const PreAlertEngine({
    this.minWarningSeconds = 2.0,
    this.maxWarningSeconds = 20.0,
    this.maxConsiderDistanceMeters = 800.0,
    this.minSpeedKmh = 8.0,
    this.maxSpeedKmh = 160.0,
    this.forwardConeDegrees = 70.0,
    this.targetEventSpeedKmh = 25.0,
    this.mildEventSpeedKmh = 55.0,
    this.reactionTimeSeconds = 1.2,
    this.maxDecelerationMps2 = 3.5,
    this.imminentThresholdSeconds = 4.0,
    this.warningThresholdSeconds = 9.0,
  });

  /// Evaluates every candidate and returns the single most important warning,
  /// or `null` when nothing should be said right now.
  ///
  /// Candidates are ranked by time-to-event (soonest first). Hazards that are
  /// behind the rider, out of range, or already alerted are discarded.
  PreAlertDecision? evaluate({
    required double latitude,
    required double longitude,
    required double speedKmh,
    required List<RoadEventCandidate> candidates,
    Set<int> alreadyAlertedIds = const {},
    double? headingDeg,
  }) {
    if (speedKmh < minSpeedKmh || speedKmh > maxSpeedKmh) return null;
    if (candidates.isEmpty) return null;

    final speedMps = GeoMath.kmhToMps(speedKmh);
    if (speedMps <= 0.01) return null;

    PreAlertDecision? best;

    for (final candidate in candidates) {
      if (candidate.id != null && alreadyAlertedIds.contains(candidate.id)) {
        continue;
      }

      if (!GeoMath.isWithinRadius(
        lat: candidate.latitude,
        lon: candidate.longitude,
        centerLat: latitude,
        centerLon: longitude,
        radiusMeters: maxConsiderDistanceMeters,
      )) {
        continue;
      }

      final distance = GeoMath.distanceMeters(
        lat1: latitude,
        lon1: longitude,
        lat2: candidate.latitude,
        lon2: candidate.longitude,
      );
      if (distance > maxConsiderDistanceMeters) continue;
      if (distance < 1.0) continue; // effectively on top of it

      final bearing = GeoMath.bearingDegrees(
        lat1: latitude,
        lon1: longitude,
        lat2: candidate.latitude,
        lon2: candidate.longitude,
      );

      // Without a heading we assume the rider is travelling towards the
      // hazard (the common case on a straight approach). With a heading we
      // require the hazard to sit inside the forward cone.
      double relativeBearing;
      if (headingDeg != null) {
        relativeBearing = GeoMath.signedAngleDifferenceDegrees(bearing, headingDeg);
        if (relativeBearing.abs() > forwardConeDegrees) continue;
      } else {
        relativeBearing = 0.0;
      }

      final timeToEvent = distance / speedMps;
      final recommended = recommendedSpeedKmh(
        distanceMeters: distance,
        currentSpeedKmh: speedKmh,
        severity: candidate.severity,
      );

      final window = classifyWindow(timeToEvent);
      final urgency = classifyUrgency(timeToEvent);
      final shouldSpeak = window == PreAlertWindow.inWindow;

      final decision = PreAlertDecision(
        candidate: candidate,
        distanceMeters: distance,
        bearingDeg: bearing,
        relativeBearingDeg: relativeBearing,
        speedKmh: speedKmh,
        timeToEventSeconds: timeToEvent,
        recommendedSpeedKmh: recommended,
        urgency: urgency,
        window: window,
        shouldSpeak: shouldSpeak,
      );

      if (best == null ||
          decision.timeToEventSeconds < best.timeToEventSeconds) {
        best = decision;
      }
    }

    return best;
  }

  /// Classifies a time-to-event into the warning window.
  PreAlertWindow classifyWindow(double timeToEventSeconds) {
    if (timeToEventSeconds > maxWarningSeconds) return PreAlertWindow.tooEarly;
    if (timeToEventSeconds < minWarningSeconds) return PreAlertWindow.tooLate;
    return PreAlertWindow.inWindow;
  }

  /// Classifies a time-to-event into an urgency level.
  PreAlertUrgency classifyUrgency(double timeToEventSeconds) {
    if (timeToEventSeconds <= imminentThresholdSeconds) {
      return PreAlertUrgency.imminent;
    }
    if (timeToEventSeconds <= warningThresholdSeconds) {
      return PreAlertUrgency.warning;
    }
    return PreAlertUrgency.advisory;
  }

  /// Computes the speed the rider should adopt so they can clear the hazard
  /// comfortably, given the distance available and their current speed.
  ///
  /// * The *pass speed* is interpolated from the hazard severity: a harmless
  ///   bump may be taken at [mildEventSpeedKmh], a severe pothole at
  ///   [targetEventSpeedKmh].
  /// * When there is enough runway to slow down to the pass speed, that pass
  ///   speed is recommended.
  /// * When the runway is too short, the maximum speed that is still
  ///   achievable (given the reaction time and the deceleration limit) is
  ///   solved for analytically and recommended instead.
  double recommendedSpeedKmh({
    required double distanceMeters,
    required double currentSpeedKmh,
    required double severity,
  }) {
    final currentMps = GeoMath.kmhToMps(currentSpeedKmh);
    if (currentMps <= 0.01) return 0.0;

    final targetMps = GeoMath.kmhToMps(passSpeedKmh(severity: severity));

    // Already slower than the pass speed: nothing to do.
    if (currentMps <= targetMps) return currentSpeedKmh;

    final a = maxDecelerationMps2;
    final tr = reactionTimeSeconds;

    final brakingDistance = (currentMps * currentMps - targetMps * targetMps) / (2 * a);
    final reactionDistance = currentMps * tr;

    if (distanceMeters >= brakingDistance + reactionDistance) {
      // Enough room: advise the pass speed.
      return GeoMath.mpsToKmh(targetMps);
    }

    // Solve v² + 2·a·tr·v − (2·a·d + target²) = 0 for the largest feasible v.
    final discriminant = (a * tr) * (a * tr) + 2 * a * distanceMeters + targetMps * targetMps;
    final solvedMps = -a * tr + math.sqrt(math.max(0.0, discriminant));

    final clampedMps = solvedMps.clamp(targetMps, currentMps);
    return GeoMath.mpsToKmh(clampedMps);
  }

  /// The pass speed (km/h) for a hazard of the given severity.
  double passSpeedKmh({required double severity}) {
    final s = severity.clamp(0.0, 1.0);
    final severe = targetEventSpeedKmh;
    final mild = mildEventSpeedKmh > severe ? mildEventSpeedKmh : severe;
    return mild + (severe - mild) * s;
  }
}

/// Builds the spoken (TTS-friendly) text for a pre-alert decision.
class PreAlertMessageBuilder {
  const PreAlertMessageBuilder._();

  /// Composes a concise spoken warning.
  ///
  /// Example: *"Speed bump ahead, 400 metres, 16 seconds. Reduce to 30."*
  static String build(PreAlertDecision decision) {
    final kind = decision.candidate.kind;
    final distance = _formatDistance(decision.distanceMeters);
    final seconds = decision.timeToEventSeconds.round();

    final buffer = StringBuffer();
    buffer.write('${kind.label} ahead, $distance metres');
    if (seconds > 0) {
      buffer.write(', $seconds ${seconds == 1 ? 'second' : 'seconds'}');
    }
    buffer.write('.');

    final recommended = decision.recommendedSpeedKmh.round();
    final current = decision.speedKmh.round();
    if (recommended < current - 1) {
      buffer.write(' Reduce to $recommended.');
    } else if (decision.urgency == PreAlertUrgency.imminent) {
      buffer.write(' Ease off now.');
    }

    return buffer.toString();
  }

  /// Human-friendly distance rounding for speech.
  ///
  /// Rounds **down** so the spoken distance is never larger than the real
  /// one — overstating the distance would make the rider brake too early.
  static int _formatDistance(double meters) {
    if (meters < 100) return (meters / 10).floor() * 10;
    if (meters < 500) return (meters / 50).floor() * 50;
    return (meters / 100).floor() * 100;
  }
}
