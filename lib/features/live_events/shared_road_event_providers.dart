import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../data/repositories/firebase_shared_road_event_repository.dart';

final sharedRoadEventsProvider =
    StreamProvider.family<
      List<SharedRoadEvent>,
      ({double latitude, double longitude})?
    >((ref, viewport) {
      if (Firebase.apps.isEmpty || viewport == null) {
        return const Stream.empty();
      }
      final repository = FirebaseSharedRoadEventRepository(
        FirebaseFirestore.instance,
      );
      return repository.watchNearby(
        LatLng(viewport.latitude, viewport.longitude),
      );
    });
