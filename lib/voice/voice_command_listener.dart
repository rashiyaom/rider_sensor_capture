import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'voice_command_config.dart';

class VoiceCommandListener {
  final SpeechToText _speechToText = SpeechToText();
  final StreamController<VoiceCommandConfig> _commandStreamController =
      StreamController<VoiceCommandConfig>.broadcast();
  final StreamController<String> _recognizedWordsController =
      StreamController<String>.broadcast();
  final StreamController<bool> _isListeningController =
      StreamController<bool>.broadcast();

  bool _isInitialized = false;
  bool _shouldKeepListening = false;
  bool _isDisposed = false;
  Timer? _keepAliveTimer;

  Stream<VoiceCommandConfig> get commandStream => _commandStreamController.stream;
  Stream<String> get recognizedWordsStream => _recognizedWordsController.stream;
  Stream<bool> get isListeningStream => _isListeningController.stream;
  bool get isListening => _speechToText.isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    final micStatus = await Permission.microphone.request();
    await Permission.speech.request();

    if (!micStatus.isGranted && !micStatus.isLimited) return false;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (val) {
          if (kDebugMode) print('Speech recognition error: ${val.errorMsg}');
          if (_shouldKeepListening && !_isDisposed) {
            _restartListeningWithDelay();
          }
        },
        onStatus: (status) {
          if (!_isDisposed && !_isListeningController.isClosed) {
            _isListeningController.add(_speechToText.isListening);
          }
          if (status == 'done' || status == 'notListening') {
            if (_shouldKeepListening && !_isDisposed) {
              _restartListeningWithDelay();
            }
          }
        },
      );
      return _isInitialized;
    } catch (_) {
      return false;
    }
  }

  Future<void> startListening({List<VoiceCommandConfig>? customCommands}) async {
    if (_isDisposed) return;
    _shouldKeepListening = true;

    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    await _listenLoop(customCommands: customCommands);

    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_shouldKeepListening && !_speechToText.isListening && !_isDisposed) {
        _listenLoop(customCommands: customCommands);
      }
    });
  }

  Future<void> _listenLoop({List<VoiceCommandConfig>? customCommands}) async {
    if (!_shouldKeepListening || _isDisposed) return;

    try {
      if (_speechToText.isListening) return;

      await _speechToText.listen(
        onResult: (result) {
          if (_isDisposed) return;
          final words = result.recognizedWords;
          if (!_recognizedWordsController.isClosed) {
            _recognizedWordsController.add(words);
          }

          final matched = VoiceCommandConfig.matchPhrase(
            words,
            commands: customCommands ?? VoiceCommandConfig.defaultCommands,
          );

          if (matched != null && !_commandStreamController.isClosed) {
            _commandStreamController.add(matched);
          }
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.confirmation,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
        ),
      );
      if (!_isDisposed && !_isListeningController.isClosed) {
        _isListeningController.add(true);
      }
    } catch (_) {
      _restartListeningWithDelay();
    }
  }

  void _restartListeningWithDelay() {
    if (_isDisposed) return;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_shouldKeepListening && !_speechToText.isListening && !_isDisposed) {
        _listenLoop();
      }
    });
  }

  Future<void> stopListening() async {
    _shouldKeepListening = false;
    _keepAliveTimer?.cancel();
    try {
      await _speechToText.stop();
    } catch (_) {}
    if (!_isDisposed && !_isListeningController.isClosed) {
      _isListeningController.add(false);
    }
  }

  void dispose() {
    _isDisposed = true;
    _shouldKeepListening = false;
    _keepAliveTimer?.cancel();
    try {
      _speechToText.stop();
    } catch (_) {}
    _commandStreamController.close();
    _recognizedWordsController.close();
    _isListeningController.close();
  }
}
