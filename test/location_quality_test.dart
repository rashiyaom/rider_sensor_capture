import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/location/location_quality.dart';
import 'package:ride_sensor_capture/location/location_service.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/prealert/pre_alert_service.dart';

class DeniedLocation extends LocationService {
  @override
  Future<bool> startTracking({
    int intervalMs = 1000,
    int distanceFilterM = 0,
  }) async => false;
}

void main() {
  final now = DateTime.utc(2026, 11, 6, 12);
  bool valid({
    double lat = 12,
    double lon = 77,
    double? speed = 10,
    double? accuracy = 4,
    int age = 0,
    double? previousLat,
    DateTime? previousTime,
  }) => LocationQuality.accepts(
    latitude: lat,
    longitude: lon,
    timestamp: now.subtract(Duration(seconds: age)),
    now: now,
    accuracy: accuracy,
    speedMps: speed,
    previousLatitude: previousLat,
    previousLongitude: 77,
    previousTime: previousTime,
  );
  test('rejects stale, future, inaccurate and nonfinite live fixes', () {
    expect(valid(), isTrue);
    expect(valid(age: 11), isFalse);
    expect(valid(age: -3), isFalse);
    expect(valid(lat: double.nan), isFalse);
    expect(valid(lon: 181), isFalse);
    expect(valid(accuracy: 51), isFalse);
    expect(valid(accuracy: double.nan), isFalse);
    expect(valid(speed: double.infinity), isFalse);
    expect(valid(speed: 91), isFalse);
  });
  test('rejects jumps and reversed timestamps but permits recovery after an outage', () {
    expect(
      valid(
        previousLat: 11,
        previousTime: now.subtract(const Duration(seconds: 1)),
      ),
      isFalse,
    );
    expect(valid(previousLat: 12, previousTime: now), isFalse);
    expect(
      valid(
        previousLat: 11,
        previousTime: now.subtract(const Duration(seconds: 20)),
      ),
      isTrue,
    );
  });
  test(
    'invalid update cannot replace accepted location and freshness expires',
    () {
      var clock = now;
      final service = LocationService(clock: () => clock);
      service.injectFixForTesting(
        LocationFix(latitude: 12, longitude: 77, timestampUtc: now),
      );
      service.injectFixForTesting(
        LocationFix(latitude: double.nan, longitude: 77, timestampUtc: now),
      );
      expect(service.currentFix!.latitude, 12);
      expect(service.hasFreshFix, isTrue);
      clock = now.add(const Duration(seconds: 11));
      expect(service.hasFreshFix, isFalse);
      service.dispose();
    },
  );
  test('GPS start failure does not leave pre-alert service running', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final location = DeniedLocation();
    final alerts = PreAlertService(db: db, locationService: location);
    await alerts.start();
    expect(alerts.isRunning, isFalse);
    expect(alerts.startupError, isNotNull);
    await alerts.stop();
    location.dispose();
    await db.close();
  });
}
