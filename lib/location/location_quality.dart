import 'geo_math.dart';

/// Shared acceptance rules for live GPS consumers. Recorded replay must supply
/// its replay clock explicitly instead of disabling freshness validation.
class LocationQuality {
  static bool accepts({
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required DateTime now,
    double? accuracy,
    double? speedMps,
    double? previousLatitude,
    double? previousLongitude,
    DateTime? previousTime,
  }) {
    if (!latitude.isFinite ||
        latitude.abs() > 90 ||
        !longitude.isFinite ||
        longitude.abs() > 180)
      return false;
    final age = now.difference(timestamp);
    if (age > const Duration(seconds: 10) || age < const Duration(seconds: -2))
      return false;
    if (accuracy != null &&
        (!accuracy.isFinite || accuracy < 0 || accuracy > 50))
      return false;
    if (speedMps != null &&
        (!speedMps.isFinite || speedMps < 0 || speedMps > 90))
      return false;
    if (previousTime != null &&
        previousLatitude != null &&
        previousLongitude != null) {
      final dt = timestamp.difference(previousTime).inMicroseconds / 1000000;
      if (dt <= 0) return false;
      // Do not bridge long outages with an assumed route segment.
      if (dt <= 10 &&
          GeoMath.distanceMeters(
                lat1: previousLatitude,
                lon1: previousLongitude,
                lat2: latitude,
                lon2: longitude,
              ) >
              90 * dt + 100)
        return false;
    }
    return true;
  }
}
