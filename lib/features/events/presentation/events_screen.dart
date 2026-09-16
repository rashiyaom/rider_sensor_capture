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
        title: const Text('Event Labeler'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _TapEventHeroCard(),
            SizedBox(height: 14),
            _EventsThreeColumnBento(),
            SizedBox(height: 14),
            _QuickActionTriggers(),
            SizedBox(height: 18),
            _RecordedEventsSection(),
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

// ── Big Tap-to-Mark Hero Card ─────────────────────────────────────────────────
class _TapEventHeroCard extends ConsumerWidget {
  const _TapEventHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(eventRecordingControllerProvider);
    final controller = ref.read(eventRecordingControllerProvider.notifier);
    final isRecording = session.state == RecordingState.recording;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(
        border: isRecording
            ? Border.all(color: AppColors.accentRed.withValues(alpha: 0.6), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ground-Truth Event Labeler',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
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
                        '\${session.elapsed.inMinutes.toString().padLeft(2, "0")}:\${(session.elapsed.inSeconds % 60).toString().padLeft(2, "0")}',
                        style: const TextStyle(color: AppColors.accentRed, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isRecording
                ? 'Recording \${session.currentEventType?.name.toUpperCase() ?? "EVENT"} — tap STOP when done'
                : 'Tap a quick button below or the big button to mark a BUMP event',
            style: TextStyle(
              color: isRecording ? AppColors.accentRed : AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 68,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? AppColors.accentRed : AppColors.primaryWhite,
                foregroundColor: isRecording ? Colors.white : Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
              ),
              onPressed: () {
                if (isRecording) {
                  controller.stopAndSaveEvent(reason: 'Tap Stop');
                } else {
                  controller.startEvent(EventType.bump, triggerPhrase: 'tap');
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isRecording ? Icons.stop_rounded : Icons.touch_app_rounded, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    isRecording ? 'STOP — Save Event' : 'TAP to Mark Event',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                  ),
                ],
              ),
            ),
          ),
          if (isRecording) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentRedBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.accentRed, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bounding window open · Event #\${session.activeEventId ?? "?"} · \${session.currentEventType?.name.toUpperCase()}',
                      style: const TextStyle(color: AppColors.accentRed, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Three-Column Metric Bento ─────────────────────────────────────────────────
class _EventsThreeColumnBento extends ConsumerWidget {
  const _EventsThreeColumnBento();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(allEventRecordsStreamProvider).value ?? [];
    final bumpCount = events.where((e) => e.eventType.toLowerCase().contains('bump')).length;
    final turnCount = events.where((e) => e.eventType.toLowerCase().contains('turn')).length;
    final total = events.length;

    Widget card(IconData icon, String badge, String value, String label) {
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
                  decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(6)),
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

    return Row(
      children: [
        Expanded(child: card(Icons.vibration_rounded, 'IMU', '$bumpCount', 'bumps')),
        const SizedBox(width: 10),
        Expanded(child: card(Icons.turn_right_rounded, 'Gyro', '$turnCount', 'turns')),
        const SizedBox(width: 10),
        Expanded(child: card(Icons.label_rounded, 'Total', '$total', 'events')),
      ],
    );
  }
}

// ── Quick Trigger Pills + Custom Label ────────────────────────────────────────
class _QuickActionTriggers extends ConsumerWidget {
  const _QuickActionTriggers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(eventRecordingControllerProvider.select((s) => s.state));
    final isRecording = sessionState == RecordingState.recording;
    final controller = ref.read(eventRecordingControllerProvider.notifier);

    final triggers = [
      {'type': EventType.bump, 'label': 'BUMP', 'icon': Icons.vibration_rounded},
      {'type': EventType.turn, 'label': 'TURN', 'icon': Icons.turn_sharp_right_rounded},
      {'type': EventType.speedTest, 'label': 'HARD BRAKE', 'icon': Icons.speed_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Event Triggers',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                            controller.stopAndSaveEvent(reason: 'Quick: $label');
                          } else {
                            controller.startEvent(type, triggerPhrase: 'tap_$label');
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
                              Icon(icon, color: isRecording ? AppColors.accentRed : AppColors.textPrimary, size: 14),
                              const SizedBox(width: 6),
                              Text(label,
                                  style: TextStyle(
                                    color: isRecording ? AppColors.accentRed : AppColors.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showCustomLabelSheet(context, controller, isRecording),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_rounded, color: AppColors.accentCyan, size: 14),
                    SizedBox(width: 6),
                    Text('Custom',
                        style: TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomLabelSheet(BuildContext context, EventRecordingController controller, bool isRecording) {
    if (isRecording) {
      controller.stopAndSaveEvent(reason: 'Custom stop');
      return;
    }
    final textCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Custom Event Label',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Type what you are about to record:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 14),
              TextField(
                controller: textCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g. pothole, speed breaker, U-turn...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.cardElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentCyan)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryWhite,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  onPressed: () {
                    final label = textCtrl.text.trim();
                    Navigator.pop(ctx);
                    controller.startEvent(EventType.voiceTag, triggerPhrase: label.isEmpty ? 'custom' : label);
                  },
                  child: const Text('Start Recording This Event',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recorded Events List ───────────────────────────────────────────────────────
class _RecordedEventsSection extends ConsumerWidget {
  const _RecordedEventsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(allEventRecordsStreamProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Captured ML Events',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
            Text('${events.length} saved', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        if (events.isEmpty)
          const _EmptyEventsPlaceholder()
        else
          ...events.map((e) => _SwipeToDeleteEventCard(key: ValueKey(e.id), item: e)),
      ],
    );
  }
}

class _SwipeToDeleteEventCard extends ConsumerWidget {
  final EventRecord item;
  const _SwipeToDeleteEventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismissible_\${item.id}'),
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
            content: const Text('This will permanently delete the event and its sensor readings.',
                style: TextStyle(color: AppColors.textSecondary)),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted')));
        }
      },
      child: _EventCard(key: ValueKey('card_\${item.id}'), item: item),
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
        ? '\${(item.endTimestamp!.difference(item.startTimestamp).inMilliseconds / 1000).toStringAsFixed(1)}s'
        : 'In progress';
    final params = EventParameters.fromJsonString(item.computedParameters);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: item))),
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
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                  child: Text(item.eventType.toUpperCase(),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                if (item.classification != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(item.classification!.toUpperCase(), style: AppStyles.badgeGreen),
                  ),
                const Spacer(),
                Text(start, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                  Text('Peak: \${params!.bump!.peakGForce.toStringAsFixed(1)}g',
                      style: const TextStyle(color: AppColors.accentCyan, fontSize: 12, fontWeight: FontWeight.bold)),
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
      child: const Column(
        children: [
          Icon(Icons.touch_app_rounded, color: AppColors.textSecondary, size: 36),
          SizedBox(height: 12),
          Text('No labeled events yet.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Tap the big button or a quick trigger above to record an event.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
