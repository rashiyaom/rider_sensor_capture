import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../camera/camera_detection_repository.dart';
import '../camera/camera_ingest_server.dart';
import '../camera/camera_capture_repository.dart';
import '../data/local_db/database.dart';
import 'db_providers.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final cameraDetectionRepositoryProvider = Provider<CameraDetectionRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  final sensorRepo = ref.watch(sensorRepositoryProvider);
  return CameraDetectionRepository(db, sensorRepo);
});

final cameraCaptureRepositoryProvider = Provider<CameraCaptureRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  final sensorRepo = ref.watch(sensorRepositoryProvider);
  return CameraCaptureRepository(db, sensorRepo);
});

// ── Server ────────────────────────────────────────────────────────────────────

final cameraIngestServerProvider = Provider<CameraIngestServer>((ref) {
  final repo = ref.watch(cameraDetectionRepositoryProvider);
  final server = CameraIngestServer(repo);
  ref.onDispose(() => server.dispose());
  return server;
});

// ── Streams ───────────────────────────────────────────────────────────────────

final cameraServerStatusProvider = StreamProvider<CameraServerStatus>((
  ref,
) async* {
  final server = ref.watch(cameraIngestServerProvider);
  // Emit initial stopped status
  yield const CameraServerStatus();
  yield* server.statusStream;
});

final recentCameraDetectionsProvider = StreamProvider<List<CameraDetection>>((
  ref,
) {
  final repo = ref.watch(cameraDetectionRepositoryProvider);
  return repo.watchRecentDetections(limit: 20);
});

/// Per-event camera detections stream (family).
final cameraDetectionsForEventProvider =
    StreamProvider.family<List<CameraDetection>, int>((ref, eventId) {
      final repo = ref.watch(cameraDetectionRepositoryProvider);
      return repo.watchDetectionsForEvent(eventId);
    });

final recentCameraCapturesProvider = StreamProvider<List<CameraCapture>>((ref) {
  return ref.watch(cameraCaptureRepositoryProvider).watchRecent();
});

final cameraCapturesForEventProvider =
    StreamProvider.family<List<CameraCapture>, int>((ref, eventId) {
      return ref.watch(cameraCaptureRepositoryProvider).watchForEvent(eventId);
    });

final cameraCapturesForTripProvider =
    StreamProvider.family<List<CameraCapture>, int>((ref, tripId) {
      return ref.watch(cameraCaptureRepositoryProvider).watchForTrip(tripId);
    });
