import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/location/geo_math.dart';

void main() {
  group('GeoMath.distanceMeters', () {
    test('returns zero for identical coordinates', () {
      final d = GeoMath.distanceMeters(lat1: 12.9716, lon1: 77.5946, lat2: 12.9716, lon2: 77.5946);
      expect(d, closeTo(0.0, 0.001));
    });

    test('matches a known 1-degree latitude span (~111.2 km)', () {
      final d = GeoMath.distanceMeters(lat1: 0, lon1: 0, lat2: 1, lon2: 0);
      expect(d, closeTo(111195.0, 100.0));
    });

    test('is symmetric', () {
      final a = GeoMath.distanceMeters(lat1: 12.9, lon1: 77.5, lat2: 13.1, lon2: 77.7);
      final b = GeoMath.distanceMeters(lat1: 13.1, lon1: 77.7, lat2: 12.9, lon2: 77.5);
      expect(a, closeTo(b, 0.001));
    });

    test('computes a realistic 400 m straight-line approach', () {
      // 0.0036 degrees of latitude is ~400 m.
      final d = GeoMath.distanceMeters(lat1: 12.9716, lon1: 77.5946, lat2: 12.9752, lon2: 77.5946);
      expect(d, closeTo(400.0, 5.0));
    });
  });

  group('GeoMath.bearingDegrees', () {
    test('due north is 0 degrees', () {
      final b = GeoMath.bearingDegrees(lat1: 0, lon1: 0, lat2: 1, lon2: 0);
      expect(b, closeTo(0.0, 0.01));
    });

    test('due east is 90 degrees', () {
      final b = GeoMath.bearingDegrees(lat1: 0, lon1: 0, lat2: 0, lon2: 1);
      expect(b, closeTo(90.0, 0.5));
    });

    test('due south is 180 degrees', () {
      final b = GeoMath.bearingDegrees(lat1: 1, lon1: 0, lat2: 0, lon2: 0);
      expect(b, closeTo(180.0, 0.01));
    });
  });

  group('GeoMath angle helpers', () {
    test('normalizeBearing wraps negative and >360 values', () {
      expect(GeoMath.normalizeBearing(-90), closeTo(270.0, 0.001));
      expect(GeoMath.normalizeBearing(450), closeTo(90.0, 0.001));
      expect(GeoMath.normalizeBearing(0), closeTo(0.0, 0.001));
    });

    test('angleDifferenceDegrees returns the smallest separation', () {
      expect(GeoMath.angleDifferenceDegrees(10, 350), closeTo(20.0, 0.001));
      expect(GeoMath.angleDifferenceDegrees(90, 0), closeTo(90.0, 0.001));
    });

    test('signedAngleDifferenceDegrees reports left/right', () {
      expect(GeoMath.signedAngleDifferenceDegrees(90, 0), closeTo(90.0, 0.001));
      expect(GeoMath.signedAngleDifferenceDegrees(270, 0), closeTo(-90.0, 0.001));
    });
  });

  group('GeoMath.destinationPoint', () {
    test('dead reckoning 400 m north matches the direct distance', () {
      final p = GeoMath.destinationPoint(
        latitude: 12.9716,
        longitude: 77.5946,
        bearingDeg: 0,
        distanceMeters: 400,
      );
      final d = GeoMath.distanceMeters(
        lat1: 12.9716,
        lon1: 77.5946,
        lat2: p.latitude,
        lon2: p.longitude,
      );
      expect(d, closeTo(400.0, 0.5));
    });
  });

  group('GeoMath.isWithinRadius', () {
    test('accepts a point inside the radius', () {
      final inside = GeoMath.isWithinRadius(
        lat: 12.9720,
        lon: 77.5946,
        centerLat: 12.9716,
        centerLon: 77.5946,
        radiusMeters: 800,
      );
      expect(inside, isTrue);
    });

    test('rejects a point outside the radius', () {
      final outside = GeoMath.isWithinRadius(
        lat: 13.0,
        lon: 77.5946,
        centerLat: 12.9716,
        centerLon: 77.5946,
        radiusMeters: 800,
      );
      expect(outside, isFalse);
    });
  });

  group('GeoMath speed conversion', () {
    test('90 km/h converts to 25 m/s', () {
      expect(GeoMath.kmhToMps(90), closeTo(25.0, 0.0001));
    });

    test('25 m/s converts back to 90 km/h', () {
      expect(GeoMath.mpsToKmh(25), closeTo(90.0, 0.0001));
    });
  });
}
