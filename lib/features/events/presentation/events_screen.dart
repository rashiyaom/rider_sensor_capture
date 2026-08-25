import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../event_recording_controller.dart';
import '../../../voice/voice_command_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../data/models/event_parameters.dart';
import '../../../providers/db_providers.dart';
import 'event_detail_screen.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bleToDbBridgeProvider);

    final session = ref.watch(eventRecordingControllerProvider);
    final controller = ref.read(eventRecordingControllerProvider.notifier);
    final eventsListAsync = ref.watch(allEventRecordsStreamProvider);
    final events = eventsListAsync.value ?? [];

    final bumpCount = events.where((e) => e.eventType.toLowerCase().contains('bump')).length;
    final turnCount = events.where((e) => e.eventType.toLowerCase().contains('turn')).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Voice Event Recorder'),
        actions: [
          IconButton(
            icon: Icon(
              session.state == RecordingState.listening
                  ? Icons.mic_rounded
                  : (session.state == RecordingState.recording
                      ? Icons.fiber_manual_record_rounded
                      : Icons.mic_none_rounded),
              color: session.state == RecordingState.recording
                  ? AppColors.accentRed
                  : (session.state == RecordingState.listening
                      ? AppColors.accentGreen
                      : AppColors.textPrimary),
            ),
            tooltip: session.state == RecordingState.listening ? 'Stop listening' : 'Start voice listener',
            onPressed: () {
              if (session.state == RecordingState.listening) {
                controller.stopListening();
              } else if (session.state == RecordingState.idle) {
                controller.startListening();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Hero Voice Action Card ──
            _buildHeroVoiceCard(context, session, controller),

            const SizedBox(height: 14),

            // ── 2. Three-Column Events Metric Bento ──
            _buildThreeColumnEventsBento(bumpCount, turnCount, events.length),

            const SizedBox(height: 14),

            // ── 3. Quick Action Trigger Capsule Pills ──
            _buildQuickActionTriggers(context, session, controller),

            const SizedBox(height: 18),

            // ── 4. Recorded Events List ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Captured ML Events',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  '${events.length} saved',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (events.isEmpty)
              _buildEmptyEventsCard()
            else
              ...events.map((event) => _buildEventCard(context, event)),
          ],
        ),
      ),
    );
  }

  // ── 1. Hero Voice Action Card ─────────────────────────────────────────────
  Widget _buildHeroVoiceCard(
    BuildContext context,
    EventRecordingSessionState session,
    EventRecordingController controller,
  ) {
    final isRecording = session.state == RecordingState.recording;
    final isListening = session.state == RecordingState.listening;

    String stateTag = 'IDLE';
    if (isRecording) stateTag = 'RECORDING';
    if (isListening) stateTag = 'LISTENING';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(
        border: isRecording ? Border.all(color: AppColors.accentRed.withValues(alpha: 0.5), width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Labeling Engine',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRecording ? AppColors.accentRed : Colors.white.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      stateTag,
                      style: TextStyle(
                        color: isRecording ? AppColors.accentRed : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentRedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record_rounded, color: AppColors.accentRed, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${session.elapsed.inMinutes.toString().padLeft(2, '0')}:${(session.elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppColors.accentRed, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isRecording
                ? 'Recording active event: ${session.currentEventType?.name.toUpperCase()}'
                : (isListening
                    ? 'Listening... Say "start bump", "start turn", or "speed test"'
                    : 'Hands-free ride labeling via speech keyword detection'),
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 18),
          // Massive White Action Capsule Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? AppColors.accentRed : AppColors.primaryWhite,
                foregroundColor: isRecording ? Colors.white : Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: () {
                if (isRecording) {
                  controller.stopAndSaveEvent(reason: 'Manual Button');
                } else if (isListening) {
                  controller.stopListening();
                } else {
                  controller.startListening();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRecording ? Icons.stop_rounded : (isListening ? Icons.mic_off_rounded : Icons.mic_rounded),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRecording ? 'Stop & Save Event' : (isListening ? 'Halt Voice Listener' : 'Start Voice Listener'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Three-Column Events Bento ──────────────────────────────────────────
  Widget _buildThreeColumnEventsBento(int bumps, int turns, int total) {
    return Row(
      children: [
        Expanded(
          child: _buildBentoCard(
            icon: Icons.vibration_rounded,
            badge: '+0%',
            value: '$bumps',
            label: 'bumps',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.turn_right_rounded,
            badge: '+2%',
            value: '$turns',
            label: 'turns',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.label_rounded,
            badge: 'Total',
            value: '$total',
            label: 'events',
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required String badge,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accentGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge, style: AppStyles.badgeGreen),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: AppStyles.heroNumber.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          Text(label, style: AppStyles.statLabel),
        ],
      ),
    );
  }

  // ── 3. Quick Action Trigger Capsule Pills ─────────────────────────────────
  Widget _buildQuickActionTriggers(
    BuildContext context,
    EventRecordingSessionState session,
    EventRecordingController controller,
  ) {
    final isRecording = session.state == RecordingState.recording;

    final triggers = [
      {'type': EventType.bump, 'label': 'BUMP', 'icon': Icons.vibration_rounded},
      {'type': EventType.turn, 'label': 'SHARP TURN', 'icon': Icons.turn_sharp_right_rounded},
      {'type': EventType.speedTest, 'label': 'SPEED TEST', 'icon': Icons.speed_rounded},
      {'type': EventType.voiceTag, 'label': 'TAG', 'icon': Icons.tag_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: triggers.map((t) {
          final type = t['type'] as EventType;
          final label = t['label'] as String;
          final icon = t['icon'] as IconData;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (isRecording) {
                  controller.stopAndSaveEvent(reason: 'Quick trigger switch');
                } else {
                  controller.startEvent(type, triggerPhrase: 'manual_touch');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.textPrimary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 4. Event Card ─────────────────────────────────────────────────────────
  Widget _buildEventCard(BuildContext context, EventRecord item) {
    final start = DateFormat('HH:mm:ss').format(item.startTimestamp.toLocal());
    final duration = item.endTimestamp != null
        ? '${(item.endTimestamp!.difference(item.startTimestamp).inMilliseconds / 1000).toStringAsFixed(1)}s'
        : 'In progress';

    final params = EventParameters.fromJsonString(item.computedParameters);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.eventType.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (item.classification != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.classification!.toUpperCase(),
                      style: AppStyles.badgeGreen,
                    ),
                  ),
                const Spacer(),
                Text(
                  start,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Duration: $duration', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                if (params?.bump != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Peak: ${params!.bump!.peakGForce.toStringAsFixed(1)}g',
                    style: const TextStyle(color: AppColors.accentCyan, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEventsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        children: const [
          Icon(Icons.graphic_eq_rounded, color: AppColors.textSecondary, size: 36),
          SizedBox(height: 12),
          Text(
            'No labeled events captured yet.',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Say "start bump" or tap a trigger pill above to record.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
