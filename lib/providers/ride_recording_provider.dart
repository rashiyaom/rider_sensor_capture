import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db_providers.dart';

class RideRecordingState {
  final bool isRecording;
  final DateTime? startTime;
  final Duration elapsed;
  final int sessionRowCount;

  const RideRecordingState({
    this.isRecording = false,
    this.startTime,
    this.elapsed = Duration.zero,
    this.sessionRowCount = 0,
  });

  String get formattedElapsed {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) {
      return '$h:$m:$s';
    }
    return '$m:$s';
  }

  RideRecordingState copyWith({
    bool? isRecording,
    DateTime? startTime,
    Duration? elapsed,
    int? sessionRowCount,
  }) {
    return RideRecordingState(
      isRecording: isRecording ?? this.isRecording,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
      sessionRowCount: sessionRowCount ?? this.sessionRowCount,
    );
  }
}

class RideRecordingNotifier extends StateNotifier<RideRecordingState> {
  final Ref ref;
  Timer? _ticker;

  RideRecordingNotifier(this.ref) : super(const RideRecordingState());

  void startRecording() {
    if (state.isRecording) return;
    _ticker?.cancel();
    final now = DateTime.now();
    state = RideRecordingState(
      isRecording: true,
      startTime: now,
      elapsed: Duration.zero,
      sessionRowCount: 0,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !state.isRecording || state.startTime == null) return;
      final diff = DateTime.now().difference(state.startTime!);
      state = state.copyWith(elapsed: diff);
    });
  }

  Future<void> stopRecording() async {
    if (!state.isRecording) return;
    _ticker?.cancel();
    state = state.copyWith(isRecording: false);

    // Flush any remaining buffered readings to SQLite database
    try {
      final repo = ref.read(sensorRepositoryProvider);
      await repo.flushPendingBuffer();
    } catch (_) {}
  }

  void incrementRowCount(int count) {
    if (state.isRecording) {
      state = state.copyWith(sessionRowCount: state.sessionRowCount + count);
    }
  }

  void reset() {
    _ticker?.cancel();
    state = const RideRecordingState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final rideRecordingProvider =
    StateNotifierProvider<RideRecordingNotifier, RideRecordingState>((ref) {
  return RideRecordingNotifier(ref);
});

/// Boolean convenience provider indicating whether ride recording is active
final isRideRecordingActiveProvider = Provider<bool>((ref) {
  return ref.watch(rideRecordingProvider.select((s) => s.isRecording));
});
