import 'dart:math' as math;

/// Pure geodesic helpers shared by the predictive pre-alert system.
///
/// All distances are in **meters**, all angles in **degrees**, all speeds in
/// **km/h** unless the identifier explicitly says otherwise.
class GeoMath {
  GeoMath._();

  /// IUGG mean Earth radius (metres).
  static const double earthRadiusMeters = 6371008.8;

  /// Metres per second in one kilometre per hour.
  static const double metersPerSecondPerKmh = 1000.0 / 3600.0;

  /// Great-circle distance between two WGS84 coordinates in metres.
  static double distanceMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rLat1) * math.cos(rLat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(math.max(0.0, 1 - a)));
    return earthRadiusMeters * c;
  }

  /// Initial bearing (degrees clockwise from true north) from point 1 to point 2.
  static double bearingDegrees({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);
    final dLon = _toRadians(lon2 - lon1);

    final y = math.sin(dLon) * math.cos(rLat2);
    final x = math.cos(rLat1) * math.sin(rLat2) -
        math.sin(rLat1) * math.cos(rLat2) * math.cos(dLon);
    return normalizeBearing(_toDegrees(math.atan2(y, x)));
  }

  /// Normalizes any angle into the `[0, 360)` range.
  static double normalizeBearing(double degrees) {
    final v = degrees % 360.0;
    return v < 0 ? v + 360.0 : v;
  }

  /// Smallest absolute angle (0..180) between two bearings.
  static double angleDifferenceDegrees(double a, double b) {
    final diff = (normalizeBearing(a) - normalizeBearing(b)).abs();
    return diff > 180.0 ? 360.0 - diff : diff;
  }

  /// Signed relative bearing of [target] with respect to [reference].
  /// Negative = to the left, positive = to the right, in the range (-180, 180].
  static double signedAngleDifferenceDegrees(double target, double reference) {
    var diff = normalizeBearing(target) - normalizeBearing(reference);
    while (diff > 180.0) {
      diff -= 360.0;
    }
    while (diff <= -180.0) {
      diff += 360.0;
    }
    return diff;
  }

  /// Dead-reckons a destination point given a start, bearing and distance.
  static ({double latitude, double longitude}) destinationPoint({
    required double latitude,
    required double longitude,
    required double bearingDeg,
    required double distanceMeters,
  }) {
    final angular = distanceMeters / earthRadiusMeters;
    final theta = _toRadians(bearingDeg);
    final phi1 = _toRadians(latitude);
    final lambda1 = _toRadians(longitude);

    final sinPhi2 = math.sin(phi1) * math.cos(angular) +
        math.cos(phi1) * math.sin(angular) * math.cos(theta);
    final phi2 = math.asin(sinPhi2.clamp(-1.0, 1.0));
    final lambda2 = lambda1 +
        math.atan2(
          math.sin(theta) * math.sin(angular) * math.cos(phi1),
          math.cos(angular) - math.sin(phi1) * sinPhi2,
        );

    return (
      latitude: _toDegrees(phi2),
      longitude: _toDegrees(lambda2),
    );
  }

  /// Converts km/h to metres per second.
  static double kmhToMps(double kmh) => kmh * metersPerSecondPerKmh;

  /// Converts metres per second to km/h.
  static double mpsToKmh(double mps) => mps / metersPerSecondPerKmh;

  /// Bounding-box pre-filter helper: returns true when the point is inside the
  /// box that is [radiusMeters] around the centre. Cheap pre-filter before the
  /// exact haversine distance is computed.
  static bool isWithinRadius({
    required double lat,
    required double lon,
    required double centerLat,
    required double centerLon,
    required double radiusMeters,
  }) {
    final latDelta = _toDegrees(radiusMeters / earthRadiusMeters);
    final cosLat = math.cos(_toRadians(centerLat)).abs();
    final lonDelta = cosLat < 0.0001
        ? 180.0
        : _toDegrees(radiusMeters / (earthRadiusMeters * cosLat));
    return (lat - centerLat).abs() <= latDelta &&
        (lon - centerLon).abs() <= lonDelta;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;

  static double _toDegrees(double radians) => radians * 180.0 / math.pi;
}
