import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/session_health_service.dart';

final sessionHealthServiceProvider = Provider<SessionHealthService>((ref) {
  final service = SessionHealthService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

final activeHealthAlertsProvider = StreamProvider<List<HealthAlert>>((ref) {
  final service = ref.watch(sessionHealthServiceProvider);
  return service.alertsStream;
});
