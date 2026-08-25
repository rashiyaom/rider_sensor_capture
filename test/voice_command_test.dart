import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/voice/voice_command_config.dart';

void main() {
  test('VoiceCommandConfig matches bump phrases accurately', () {
    final match1 = VoiceCommandConfig.matchPhrase('we are approaching a speed bump ahead');
    expect(match1, isNotNull);
    expect(match1!.eventType, EventType.bump);

    final match2 = VoiceCommandConfig.matchPhrase('start bump');
    expect(match2, isNotNull);
    expect(match2!.eventType, EventType.bump);

    final match3 = VoiceCommandConfig.matchPhrase('hit a pothole');
    expect(match3, isNotNull);
    expect(match3!.eventType, EventType.bump);
  });

  test('VoiceCommandConfig matches turn and speed triggers', () {
    final matchTurn = VoiceCommandConfig.matchPhrase('sharp hard turn right now');
    expect(matchTurn, isNotNull);
    expect(matchTurn!.eventType, EventType.turn);

    final matchSpeed = VoiceCommandConfig.matchPhrase('doing a speed test');
    expect(matchSpeed, isNotNull);
    expect(matchSpeed!.eventType, EventType.speedTest);
  });

  test('VoiceCommandConfig matches halt commands', () {
    final matchStop = VoiceCommandConfig.matchPhrase('stop recording');
    expect(matchStop, isNotNull);
    expect(matchStop!.isHaltCommand, true);

    final matchHalt = VoiceCommandConfig.matchPhrase('halt');
    expect(matchHalt, isNotNull);
    expect(matchHalt!.isHaltCommand, true);
  });

  test('VoiceCommandConfig returns null on unrelated speech', () {
    final noMatch = VoiceCommandConfig.matchPhrase('hello how is the weather today');
    expect(noMatch, isNull);
  });
}
