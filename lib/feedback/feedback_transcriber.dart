import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Captures a single spoken answer for the post-event feedback prompt.
///
/// Unlike [VoiceCommandListener] (which runs a continuous keyword listener
/// for the whole ride) this transcriber performs a *one-shot* dictation so the
/// rider can answer the feedback question hands-free without the microphone
/// staying hot between events.
class FeedbackTranscriber {
  final SpeechToText _speechToText = SpeechToText();

  bool _initialized = false;
  bool _capturing = false;

  /// True when the platform speech recogniser is ready.
  bool get isReady => _initialized;

  /// True while a capture is in progress.
  bool get isCapturing => _capturing;

  /// Initialises the speech recogniser and requests microphone permission.
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      final mic = await Permission.microphone.request();
      await Permission.speech.request();
      if (!mic.isGranted && !mic.isLimited) return false;

      final ok = await _speechToText.initialize(
        onError: (val) {
          if (kDebugMode) debugPrint('FeedbackTranscriber error: ${val.errorMsg}');
        },
        onStatus: (status) {
          if (kDebugMode) debugPrint('FeedbackTranscriber status: $status');
        },
      );
      _initialized = ok;
      return ok;
    } catch (e) {
      if (kDebugMode) debugPrint('FeedbackTranscriber init failed: $e');
      return false;
    }
  }

  /// Records a single spoken answer.
  ///
  /// Returns the transcribed text, or null when nothing intelligible was
  /// captured within [timeout].
  Future<String?> listenOnce({
    Duration timeout = const Duration(seconds: 12),
    Duration maxDuration = const Duration(seconds: 20),
  }) async {
    if (_capturing) return null;
    if (!await initialize()) return null;

    _capturing = true;
    final completer = Completer<String?>();
    String latest = '';
    var gotFinal = false;

    void finish(String? value) {
      if (!completer.isCompleted) {
        completer.complete(value);
      }
    }

    final timer = Timer(timeout, () {
      try {
        _speechToText.stop();
      } catch (_) {}
      finish(latest.trim().isEmpty ? null : latest.trim());
    });

    try {
      await _speechToText.listen(
        onResult: (result) {
          latest = result.recognizedWords;
          if (result.finalResult) {
            gotFinal = true;
            try {
              _speechToText.stop();
            } catch (_) {}
            finish(latest.trim().isEmpty ? null : latest.trim());
          }
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          listenFor: maxDuration,
          pauseFor: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('FeedbackTranscriber listen failed: $e');
      finish(null);
    }

    final result = await completer.future;
    timer.cancel();
    _capturing = false;
    if (!gotFinal && result == null) return null;
    return result;
  }

  /// Stops any capture in progress.
  Future<void> stop() async {
    if (!_capturing) return;
    try {
      await _speechToText.stop();
    } catch (_) {}
    _capturing = false;
  }

  void dispose() {
    try {
      _speechToText.cancel();
    } catch (_) {}
    _initialized = false;
  }
}
