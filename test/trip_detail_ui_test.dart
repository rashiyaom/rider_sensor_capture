import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/features/trips/presentation/trip_detail_screen.dart';
import 'package:ride_sensor_capture/features/trips/presentation/trips_history_screen.dart';
import 'package:ride_sensor_capture/features/trips/trip_controller.dart';

void main() {
  testWidgets('TripDetailScreen renders without throwing exceptions with 2 points', (tester) async {
    final trip = Trip(
      id: 1,
      riderName: 'Test Rider',
      wristSide: 'Left',
      startTimeUtc: DateTime.now().toUtc(),
      endTimeUtc: DateTime.now().toUtc(),
      durationSeconds: 120,
      totalDistanceKm: 1.2,
      totalDurationMin: 2.0,
      distanceMeters: 1200,
      totalSensorRows: 100,
      totalEventsCount: 1,
      harshBrakeCount: 0,
      harshAccelCount: 0,
      harshTurnCount: 0,
      bumpCount: 1,
      confirmedEventCount: 0,
      routeCoordinatesJson: jsonEncode([
        {'lat': 19.0760, 'lng': 72.8774, 'speed_kmh': 20.0, 'altitude': 10.0, 'timestamp_utc': DateTime.now().toUtc().toIso8601String()},
        {'lat': 19.0770, 'lng': 72.8784, 'speed_kmh': 25.0, 'altitude': 12.0, 'timestamp_utc': DateTime.now().toUtc().toIso8601String()},
      ]),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TripDetailScreen(trip: trip),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Journey Telemetry'), findsOneWidget);
  });

  testWidgets('TripDetailScreen renders with null routeCoordinatesJson and 0 sensor rows', (tester) async {
    final trip = Trip(
      id: 2,
      riderName: 'Rider Null',
      wristSide: 'Right',
      startTimeUtc: DateTime.now().toUtc(),
      endTimeUtc: null,
      durationSeconds: 0,
      distanceMeters: 0,
      totalSensorRows: 0,
      totalEventsCount: 0,
      harshBrakeCount: 0,
      harshAccelCount: 0,
      harshTurnCount: 0,
      bumpCount: 0,
      confirmedEventCount: 0,
      routeCoordinatesJson: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TripDetailScreen(trip: trip),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Journey Telemetry'), findsOneWidget);
  });

  testWidgets('TripDetailScreen renders with single GPS point (boundary condition)', (tester) async {
    final trip = Trip(
      id: 3,
      riderName: 'Single Point',
      wristSide: 'Left',
      startTimeUtc: DateTime.now().toUtc(),
      endTimeUtc: DateTime.now().toUtc(),
      durationSeconds: 5,
      distanceMeters: 10,
      totalSensorRows: 10,
      totalEventsCount: 0,
      harshBrakeCount: 0,
      harshAccelCount: 0,
      harshTurnCount: 0,
      bumpCount: 0,
      confirmedEventCount: 0,
      routeCoordinatesJson: jsonEncode([
        {'lat': 19.0760, 'lng': 72.8774, 'speed_kmh': 0.0, 'altitude': 10.0, 'timestamp_utc': DateTime.now().toUtc().toIso8601String()},
      ]),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TripDetailScreen(trip: trip),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Journey Telemetry'), findsOneWidget);
  });

  testWidgets('TripsHistoryScreen renders and navigates to TripDetailScreen cleanly', (tester) async {
    final trips = [
      Trip(
        id: 101,
        riderName: 'Logbook Rider',
        wristSide: 'Left',
        startTimeUtc: DateTime.now().subtract(const Duration(hours: 1)).toUtc(),
        endTimeUtc: DateTime.now().toUtc(),
        durationSeconds: 3600,
        distanceMeters: 15400,
        totalSensorRows: 8000,
        totalEventsCount: 3,
        harshBrakeCount: 1,
        harshAccelCount: 0,
        harshTurnCount: 1,
        bumpCount: 1,
        confirmedEventCount: 2,
        routeCoordinatesJson: jsonEncode([
          {'lat': 19.0760, 'lng': 72.8774, 'speed_kmh': 18.0, 'altitude': 10.0, 'timestamp_utc': DateTime.now().toUtc().toIso8601String()},
          {'lat': 19.0790, 'lng': 72.8800, 'speed_kmh': 24.0, 'altitude': 14.0, 'timestamp_utc': DateTime.now().toUtc().toIso8601String()},
        ]),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allTripsStreamProvider.overrideWith((ref) => Stream.value(trips)),
        ],
        child: const MaterialApp(
          home: TripsHistoryScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Journey Log Book'), findsOneWidget);
    expect(find.text('Logbook Rider'), findsOneWidget);
    expect(find.text('Journey #101'), findsOneWidget);

    // Tap to view the trip
    await tester.tap(find.text('Logbook Rider'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // finish route transition

    // Verify TripDetailScreen opened successfully without error
    expect(find.text('Journey Telemetry'), findsOneWidget);
  });
}
