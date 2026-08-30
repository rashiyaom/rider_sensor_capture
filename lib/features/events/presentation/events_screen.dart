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

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ground-Truth Event Labeler'),
        actions: const [
          _VoiceMicAppBarAction(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // ── 1. Hero Voice Action Card (Isolated Rebuilds) ──
            _HeroVoiceActionCard(),

            SizedBox(height: 14),

            // ── 2. Interactive "How To Use" Guide & Instructions ──
            _EventsInstructionGuide(),

            SizedBox(height: 14),

            // ── 3. Three-Column Events Metric Bento ──
            _EventsThreeColumnBento(),

            SizedBox(height: 14),

            // ── 4. Quick Action Manual Trigger Pills ──
            _QuickActionTriggers(),

            SizedBox(height: 18),

            // ── 5. Recorded Events List ──
            _RecordedEventsSection(),

            // ── Footer branding ──
            SizedBox(height: 20),
            Center(
              child: Text(
                'made by rashiyaom',
                style: TextStyle(
                  color: Color(0x1FFFFFFF),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AppBar Mic Action ────────────────────────────────────────────────────────
class _VoiceMicAppBarAction extends ConsumerWidget {
  const _VoiceMicAppBarAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(
      eventRecordingControllerProvider.select((s) => s.state),
    );
    final controller = ref.read(eventRecordingControllerProvider.notifier);

    return IconButton(
      icon: Icon(
        sessionState == RecordingState.listening
            ? Icons.mic_rounded
            : (sessionState == RecordingState.recording
                ? Icons.fiber_manual_record_rounded
                : Icons.mic_none_rounded),
        color: sessionState == RecordingState.recording
            ? AppColors.accentRed
            : (sessionState == RecordingState.listening
                ? AppColors.accentGreen
                : AppColors.textPrimary),
      ),
      tooltip: sessionState == RecordingState.listening ? 'Stop listening' : 'Start voice listener',
      onPressed: () {
        if (sessionState == RecordingState.listening) {
          controller.stopListening();
        } else if (sessionState == RecordingState.idle) {
          controller.startListening();
        }
      },
    );
  }
}

// ── 1. Hero Voice Action Card (Isolated) ────────────────────────────────────
class _HeroVoiceActionCard extends ConsumerWidget {
  const _HeroVoiceActionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(eventRecordingControllerProvider);
    final controller = ref.read(eventRecordingControllerProvider.notifier);

    final isRecording = session.state == RecordingState.recording;
    final isListening = session.state == RecordingState.listening;

    String stateTag = 'IDLE';
    if (isRecording) stateTag = 'RECORDING ACTIVE EVENT';
    if (isListening) stateTag = 'VOICE LISTENER ACTIVE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(
        border: isRecording ? Border.all(color: AppColors.accentRed.withValues(alpha: 0.6), width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ground-Truth Labeling Engine',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isRecording ? AppColors.accentRedBg : Colors.white.withValues(alpha: 0.05),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentRedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.4)),
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
          const SizedBox(height: 10),
          Text(
            isRecording
                ? 'Tagging 50Hz IMU stream under event #${session.activeEventId ?? ""} · ${session.currentEventType?.name.toUpperCase()}'
                : (isListening
                    ? 'Say "Start Bump", "Start Turn", or "Hard Brake" to trigger event window'
                    : 'Hands-free voice recognition or 1-tap manual buttons for ML ground truth'),
            style: TextStyle(
              color: isRecording ? AppColors.textPrimary : AppColors.textTertiary,
              fontSize: 12,
              fontWeight: isRecording ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (session.lastRecognizedWords.isNotEmpty && isListening) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.graphic_eq_rounded, size: 14, color: AppColors.accentGreen),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Heard: "${session.lastRecognizedWords}"',
                      style: const TextStyle(color: AppColors.accentGreen, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
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
                    isRecording ? 'Stop & Save Labeled Event' : (isListening ? 'Halt Voice Listener' : 'Start Voice Listener'),
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
}

// ── 2. Interactive "How To Use" Guide & Instructions ────────────────────────
class _EventsInstructionGuide extends StatefulWidget {
  const _EventsInstructionGuide();

  @override
  State<_EventsInstructionGuide> createState() => _EventsInstructionGuideState();
}

class _EventsInstructionGuideState extends State<_EventsInstructionGuide> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.cardDecoration(),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.accentGreen),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'How to use Ground-Truth Labeling',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What is this page for?',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'When training machine learning models to detect road hazards or riding maneuvers, models need labeled ground truth data (exact start & stop timestamps of potholes, turns, bumps, etc.).',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    stepNum: '1',
                    title: 'Start an Event Window',
                    desc: 'Tap any Quick Action pill below (BUMP, TURN, SPEED TEST) or say "Start Bump" / "Start Turn" into your microphone.',
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNum: '2',
                    title: 'Ride Through Feature',
                    desc: 'While recording, all 50Hz IMU acceleration, gyro data, and camera frames are automatically linked to this Event ID.',
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNum: '3',
                    title: 'End & Compute Metrics',
                    desc: 'Tap "Stop & Save" (or say "Stop Bump"). The app calculates peak G-Force, turn angle, bump severity, and saves it in SQLite.',
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNum: '4',
                    title: 'Export Labeled Dataset',
                    desc: 'Head to the Export tab to download clean CSVs and JSON datasets with all event labels attached for model training.',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepItem({required String stepNum, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cardElevated,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(stepNum, style: const TextStyle(color: AppColors.accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 3. Three-Column Events Metric Bento ──────────────────────────────────────
class _EventsThreeColumnBento extends ConsumerWidget {
  const _EventsThreeColumnBento();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsListAsync = ref.watch(allEventRecordsStreamProvider);
    final events = eventsListAsync.value ?? [];

    final bumpCount = events.where((e) => e.eventType.toLowerCase().contains('bump')).length;
    final turnCount = events.where((e) => e.eventType.toLowerCase().contains('turn')).length;
    final total = events.length;

    return Row(
      children: [
        Expanded(
          child: _buildBentoCard(
            icon: Icons.vibration_rounded,
            badge: 'IMU',
            value: '$bumpCount',
            label: 'bumps',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.turn_right_rounded,
            badge: 'Gyro',
            value: '$turnCount',
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
}

// ── 4. Quick Action Manual Trigger Pills ────────────────────────────────────
class _QuickActionTriggers extends ConsumerWidget {
  const _QuickActionTriggers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(
      eventRecordingControllerProvider.select((s) => s.state),
    );
    final isRecording = sessionState == RecordingState.recording;
    final controller = ref.read(eventRecordingControllerProvider.notifier);

    final triggers = [
      {'type': EventType.bump, 'label': 'BUMP / POTHOLE', 'icon': Icons.vibration_rounded},
      {'type': EventType.turn, 'label': 'SHARP TURN', 'icon': Icons.turn_sharp_right_rounded},
      {'type': EventType.speedTest, 'label': 'HARD BRAKE / ACCEL', 'icon': Icons.speed_rounded},
      {'type': EventType.voiceTag, 'label': 'CUSTOM TAG', 'icon': Icons.tag_rounded},
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
                  controller.stopAndSaveEvent(reason: 'Manual Quick Trigger');
                } else {
                  controller.startEvent(type, triggerPhrase: 'manual_touch');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isRecording ? AppColors.accentRedBg : AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isRecording ? AppColors.accentRed.withValues(alpha: 0.5) : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isRecording ? AppColors.accentRed : AppColors.textPrimary,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: isRecording ? AppColors.accentRed : AppColors.textPrimary,
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
}

// ── 5. Recorded Events Section ──────────────────────────────────────────────
class _RecordedEventsSection extends ConsumerWidget {
  const _RecordedEventsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsListAsync = ref.watch(allEventRecordsStreamProvider);
    final events = eventsListAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          const _EmptyEventsPlaceholder()
        else
          ...events.map((event) => _SwipeToDeleteEventCard(key: ValueKey(event.id), item: event)),
      ],
    );
  }
}

/// Swipe-to-delete wrapper around [_EventCard]
class _SwipeToDeleteEventCard extends ConsumerWidget {
  final EventRecord item;
  const _SwipeToDeleteEventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismissible_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.accentRedBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: AppColors.accentRed, size: 22),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: AppColors.accentRed, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('Delete Event?', style: TextStyle(color: AppColors.textPrimary)),
            content: const Text(
              'This will permanently delete the event and its associated sensor readings.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await ref.read(sensorRepositoryProvider).deleteEvent(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted')),
          );
        }
      },
      child: _EventCard(key: ValueKey('card_${item.id}'), item: item),
    );
  }
}


class _EventCard extends StatelessWidget {
  final EventRecord item;

  const _EventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
}

class _EmptyEventsPlaceholder extends StatelessWidget {
  const _EmptyEventsPlaceholder();

  @override
  Widget build(BuildContext context) {
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
