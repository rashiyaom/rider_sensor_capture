import 'dart:math' as math;

/// Centralized physical constants and unit conversion utilities.
/// All modules must use this module instead of hardcoding literal 9.8, 9.81, 57.3, etc.
class AngularUnits {
  /// Standard acceleration due to gravity on Earth in m/s^2 (ISO 80000-3).
  static const double standardGravity = 9.80665;

  /// Degrees to radians factor (pi / 180).
  static const double degToRadFactor = math.pi / 180.0;

  /// Radians to degrees factor (180 / pi).
  static const double radToDegFactor = 180.0 / math.pi;

  /// Convert degrees to radians.
  static double degToRad(double deg) => deg * degToRadFactor;

  /// Convert radians to degrees.
  static double radToDeg(double rad) => rad * radToDegFactor;

  /// Convert meters per second (m/s) to kilometers per hour (km/h).
  static double mpsToKmh(double mps) => mps * 3.6;

  /// Convert kilometers per hour (km/h) to meters per second (m/s).
  static double kmhToMps(double kmh) => kmh / 3.6;

  /// Convert acceleration in m/s^2 to g-force.
  static double accelToG(double accelMps2) => accelMps2 / standardGravity;

  /// Convert g-force to acceleration in m/s^2.
  static double gToAccel(double g) => g * standardGravity;
}
