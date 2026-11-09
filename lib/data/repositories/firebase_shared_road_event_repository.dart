import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class SharedRoadEvent {
  final String id;
  final String status;
  final double latitude;
  final double longitude;
  final int independentDriverCount;
  final int reportCount;
  final DateTime firstObservedAt;
  final DateTime lastObservedAt;

  const SharedRoadEvent({
    required this.id,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.independentDriverCount,
    required this.reportCount,
    required this.firstObservedAt,
    required this.lastObservedAt,
  });
}

/// Read-only driver feed. Client apps cannot create or update shared hazards.
class FirebaseSharedRoadEventRepository {
  static const radiusM = 10000.0;
  static const maxResults = 200;

  final FirebaseFirestore firestore;

  FirebaseSharedRoadEventRepository(this.firestore);

  Stream<List<SharedRoadEvent>> watchNearby(LatLng center) {
    final latRadius = radiusM / 111320;
    final cosLatitude = math.cos(center.latitude * math.pi / 180).abs();
    final lonRadius = math.min(
      180.0,
      radiusM / (111320 * math.max(0.01, cosLatitude)),
    );
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));

    return firestore
        .collection('sharedRoadEvents')
        .where(
          'latitude',
          isGreaterThanOrEqualTo: math.max(-90, center.latitude - latRadius),
        )
        .where(
          'latitude',
          isLessThanOrEqualTo: math.min(90, center.latitude + latRadius),
        )
        .where(
          'longitude',
          isGreaterThanOrEqualTo: math.max(-180, center.longitude - lonRadius),
        )
        .where(
          'longitude',
          isLessThanOrEqualTo: math.min(180, center.longitude + lonRadius),
        )
        .where(
          'lastObservedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff),
        )
        .orderBy('latitude')
        .orderBy('longitude')
        .orderBy('lastObservedAt', descending: true)
        .limit(maxResults)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(_fromDocument)
              .whereType<SharedRoadEvent>()
              .where(
                (event) =>
                    _distanceM(
                      center,
                      LatLng(event.latitude, event.longitude),
                    ) <=
                    radiusM,
              )
              .toList(),
        );
  }

  SharedRoadEvent? _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final latitude = data['latitude'];
    final longitude = data['longitude'];
    final lastObservedAt = data['lastObservedAt'];
    final firstObservedAt = data['firstObservedAt'];
    final status = data['status'];
    if (latitude is! num ||
        longitude is! num ||
        lastObservedAt is! Timestamp ||
        firstObservedAt is! Timestamp ||
        status is! String ||
        !{'candidate', 'corroborated', 'verified'}.contains(status)) {
      return null;
    }
    return SharedRoadEvent(
      id: document.id,
      status: status,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      independentDriverCount:
          (data['independentDriverCount'] as num?)?.toInt() ?? 1,
      reportCount: (data['reportCount'] as num?)?.toInt() ?? 1,
      firstObservedAt: firstObservedAt.toDate().toUtc(),
      lastObservedAt: lastObservedAt.toDate().toUtc(),
    );
  }

  static double _distanceM(LatLng a, LatLng b) {
    const earthRadiusM = 6371008.8;
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLat = lat2 - lat1;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
    return 2 * earthRadiusM * math.asin(math.min(1, math.sqrt(h)));
  }
}
