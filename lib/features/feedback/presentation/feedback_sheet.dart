import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../feedback/feedback_service.dart';
import '../../../providers/feedback_providers.dart';

/// Bottom sheet that asks the rider how an event went and captures the answer
/// (by voice or by text) so the pre-alert system can learn from it.
class FeedbackSheet extends ConsumerStatefulWidget {
  final int eventId;
  final String eventType;
  final int? tripId;
  final int? roadEventId;
  final int? preAlertId;
  final double? timeToEventSeconds;
  final double? distanceMeters;
  final double? speedKmh;
  final double? recommendedSpeedKmh;
  final double? severity;
  final double? peakGForce;

  const FeedbackSheet({
    super.key,
    required this.eventId,
    required this.eventType,
    this.tripId,
    this.roadEventId,
    this.preAlertId,
    this.timeToEventSeconds,
    this.distanceMeters,
    this.speedKmh,
    this.recommendedSpeedKmh,
    this.severity,
    this.peakGForce,
  });

  /// Shows the feedback sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required int eventId,
    required String eventType,
    int? tripId,
    int? roadEventId,
    int? preAlertId,
    double? timeToEventSeconds,
    double? distanceMeters,
    double? speedKmh,
    double? recommendedSpeedKmh,
    double? severity,
    double? peakGForce,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FeedbackSheet(
        eventId: eventId,
        eventType: eventType,
        tripId: tripId,
        roadEventId: roadEventId,
        preAlertId: preAlertId,
        timeToEventSeconds: timeToEventSeconds,
        distanceMeters: distanceMeters,
        speedKmh: speedKmh,
        recommendedSpeedKmh: recommendedSpeedKmh,
        severity: severity,
        peakGForce: peakGForce,
      ),
    );
  }

  @override
  ConsumerState<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<FeedbackSheet> {
  late final FeedbackPrompt _prompt;
  final TextEditingController _textController = TextEditingController();

  /// Auto-dismiss timer shown after a successful save.
  Timer? _dismissTimer;

  bool _isRecording = false;
  bool _isSaving = false;
  bool _saved = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _prompt = FeedbackService.buildPrompt(eventType: widget.eventType);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit(String response, String source) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    try {
      final service = ref.read(feedbackServiceProvider);
      if (source == 'voice') {
        await service.recordVoiceFeedback(
          eventId: widget.eventId,
          eventType: widget.eventType,
          prompt: _prompt.question,
          tripId: widget.tripId,
          roadEventId: widget.roadEventId,
          preAlertId: widget.preAlertId,
          timeToEventSeconds: widget.timeToEventSeconds,
          distanceMeters: widget.distanceMeters,
          speedKmh: widget.speedKmh,
          recommendedSpeedKmh: widget.recommendedSpeedKmh,
          severity: widget.severity,
          peakGForce: widget.peakGForce,
        );
      } else {
        await service.recordTextFeedback(
          eventId: widget.eventId,
          eventType: widget.eventType,
          prompt: _prompt.question,
          responseText: response,
          tripId: widget.tripId,
          roadEventId: widget.roadEventId,
          preAlertId: widget.preAlertId,
          timeToEventSeconds: widget.timeToEventSeconds,
          distanceMeters: widget.distanceMeters,
          speedKmh: widget.speedKmh,
          recommendedSpeedKmh: widget.recommendedSpeedKmh,
          severity: widget.severity,
          peakGForce: widget.peakGForce,
        );
      }

      if (!mounted) return;
      setState(() {
        _saved = true;
        _isSaving = false;
        _statusMessage = 'Thanks — your feedback improves the warnings.';
      });
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _statusMessage = 'Could not save feedback: $e';
      });
    }
  }

  Future<void> _recordVoice() async {
    if (_isRecording) return;
    setState(() {
      _isRecording = true;
      _statusMessage = 'Listening… speak your answer';
    });

    final service = ref.read(feedbackServiceProvider);
    final transcript = await service.transcriber?.listenOnce();
    if (!mounted) return;

    setState(() {
      _isRecording = false;
      if (transcript == null || transcript.trim().isEmpty) {
        _statusMessage = 'Did not catch that — try again or type below.';
        return;
      }
      _textController.text = transcript;
      _statusMessage = null;
    });

    if (transcript != null && transcript.trim().isNotEmpty) {
      await _submit(transcript.trim(), 'voice');
    }
  }

  Future<void> _skip() async {
    try {
      final service = ref.read(feedbackServiceProvider);
      await service.recordSkipped(
        eventId: widget.eventId,
        eventType: widget.eventType,
        prompt: _prompt.question,
        tripId: widget.tripId,
        roadEventId: widget.roadEventId,
        preAlertId: widget.preAlertId,
      );
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final llmAvailable = ref.watch(feedbackServiceProvider).isLlmAvailable;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentCyanBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      color: AppColors.accentCyan,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'How did that feel?',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          llmAvailable
                              ? 'Your answer is analysed by the on-device LLM evaluator.'
                              : 'Offline mode — keyword analysis is used.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // The contextual question
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: AppStyles.cardDecoration(
                  backgroundColor: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _prompt.question,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Quick replies
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _prompt.quickReplies.map((reply) {
                  return GestureDetector(
                    onTap: _saved ? null : () => _submit(reply, 'text'),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        reply,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Text input
              TextField(
                controller: _textController,
                enabled: !_saved,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type how it went…',
                  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.accentCyan),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Status
              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: _saved ? AppColors.accentGreen : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_saved || _isSaving) ? null : _recordVoice,
                      icon: Icon(
                        _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                        size: 18,
                      ),
                      label: Text(_isRecording ? 'Listening…' : 'Speak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentCyan,
                        side: const BorderSide(color: AppColors.accentCyan),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_saved || _isSaving)
                          ? null
                          : () {
                              final text = _textController.text.trim();
                              if (text.isEmpty) {
                                setState(() {
                                  _statusMessage = 'Type an answer or tap a quick reply.';
                                });
                                return;
                              }
                              _submit(text, 'text');
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryWhite,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(_isSaving ? 'Saving…' : 'Send'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Skip
              Center(
                child: TextButton(
                  onPressed: _saved ? null : _skip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact badge showing that an event has rider feedback attached.
class FeedbackBadge extends StatelessWidget {
  final int count;

  const FeedbackBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentCyanBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_rounded, size: 11, color: AppColors.accentCyan),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.accentCyan,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
