enum EventType {
  bump,
  turn,
  speedTest,
  voiceTag,
  custom,
}

class VoiceCommandConfig {
  final String phrase;
  final EventType eventType;
  final bool isHaltCommand;

  const VoiceCommandConfig({
    required this.phrase,
    required this.eventType,
    this.isHaltCommand = false,
  });

  static const List<VoiceCommandConfig> defaultCommands = [
    // Bump / Pothole triggers
    VoiceCommandConfig(phrase: 'start bump', eventType: EventType.bump),
    VoiceCommandConfig(phrase: 'bump', eventType: EventType.bump),
    VoiceCommandConfig(phrase: 'pothole', eventType: EventType.bump),
    VoiceCommandConfig(phrase: 'speed bump', eventType: EventType.bump),

    // Turn / Corner triggers
    VoiceCommandConfig(phrase: 'start turn', eventType: EventType.turn),
    VoiceCommandConfig(phrase: 'turn', eventType: EventType.turn),
    VoiceCommandConfig(phrase: 'corner', eventType: EventType.turn),
    VoiceCommandConfig(phrase: 'hard turn', eventType: EventType.turn),

    // Speed / Acceleration triggers
    VoiceCommandConfig(phrase: 'start speed', eventType: EventType.speedTest),
    VoiceCommandConfig(phrase: 'speed test', eventType: EventType.speedTest),
    VoiceCommandConfig(phrase: 'acceleration', eventType: EventType.speedTest),
    VoiceCommandConfig(phrase: 'braking', eventType: EventType.speedTest),

    // Manual Stop triggers
    VoiceCommandConfig(phrase: 'stop recording', eventType: EventType.custom, isHaltCommand: true),
    VoiceCommandConfig(phrase: 'stop', eventType: EventType.custom, isHaltCommand: true),
    VoiceCommandConfig(phrase: 'halt', eventType: EventType.custom, isHaltCommand: true),
  ];

  static VoiceCommandConfig? matchPhrase(
    String recognizedText, {
    List<VoiceCommandConfig> commands = defaultCommands,
  }) {
    final cleanInput = recognizedText.toLowerCase().trim();
    if (cleanInput.isEmpty) return null;

    for (final cmd in commands) {
      if (cleanInput.contains(cmd.phrase)) {
        return cmd;
      }
    }
    return null;
  }
}
