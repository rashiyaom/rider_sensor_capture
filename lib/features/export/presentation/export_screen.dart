import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/export_options.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/export_providers.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(exportFilterProvider);
    final filterNotifier = ref.read(exportFilterProvider.notifier);
    final summaryAsync = ref.watch(exportSummaryProvider);
    final exportState = ref.watch(exportControllerProvider);
    final exportController = ref.read(exportControllerProvider.notifier);
    final savedFilesAsync = ref.watch(savedExportFilesProvider);

    final summary = summaryAsync.value ?? const ExportSummary();
    final isExporting = exportState.status == ExportStatus.generating || exportState.status == ExportStatus.sharing;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dataset Export'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh summary',
            onPressed: () {
              ref.invalidate(exportSummaryProvider);
              ref.invalidate(savedExportFilesProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Hero Export Action Card ──
            _buildHeroExportCard(context, isExporting, exportState, exportController),

            const SizedBox(height: 14),

            // ── 2. Three-Column Export Metric Bento ──
            _buildThreeColumnExportBento(summary),

            const SizedBox(height: 14),

            // ── 3. Configuration Bento Cards (Mode & Format) ──
            _buildConfigBento(context, filter, filterNotifier),

            const SizedBox(height: 14),

            // ── 4. Time Range Filter Card ──
            _buildTimeRangeCard(context, filter, filterNotifier),

            const SizedBox(height: 18),

            // ── 5. Saved Export History ──
            _buildSavedExportsSection(context, savedFilesAsync, exportController),
          ],
        ),
      ),
    );
  }

  // ── 1. Hero Export Card ───────────────────────────────────────────────────
  Widget _buildHeroExportCard(
    BuildContext context,
    bool isExporting,
    ExportControllerState exportState,
    ExportController controller,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(),
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
                    'ML Training Pipeline',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
                    ),
                    child: const Text(
                      'DATASET',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.accentCyan, size: 13),
                    SizedBox(width: 4),
                    Text('PyTorch / TF', style: TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Multi-sensor time-aligned IMU & PPG telemetry with labeled event windows.',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 18),
          // Massive White Action Capsule Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryWhite,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: isExporting
                  ? null
                  : () async {
                      await controller.runExport();
                    },
              child: isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.file_download_rounded, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Export Dataset Now',
                          style: TextStyle(
                            color: Colors.black,
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

  // ── 2. Three-Column Export Bento ──────────────────────────────────────────
  Widget _buildThreeColumnExportBento(ExportSummary summary) {
    String formattedRows = summary.sensorReadingCount > 1000
        ? '${(summary.sensorReadingCount / 1000).toStringAsFixed(1)}k'
        : '${summary.sensorReadingCount}';

    return Row(
      children: [
        Expanded(
          child: _buildBentoCard(
            icon: Icons.storage_rounded,
            badge: 'SQLite',
            value: formattedRows,
            label: 'sensor rows',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.label_rounded,
            badge: 'Events',
            value: '${summary.eventCount}',
            label: 'labeled',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.videocam_rounded,
            badge: 'AI Cam',
            value: '${summary.cameraDetectionCount}',
            label: 'detections',
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

  // ── 3. Configuration Bento (Mode & Format) ────────────────────────────────
  Widget _buildConfigBento(
    BuildContext context,
    ExportFilterState filter,
    ExportFilterNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Format & Pipeline Mode',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 14),
          // Mode toggle
          Row(
            children: [
              Expanded(
                child: _buildSelectPill(
                  title: 'Events Only',
                  subtitle: 'Labeled windows only',
                  isSelected: filter.mode == ExportMode.eventsOnly,
                  onTap: () => notifier.setMode(ExportMode.eventsOnly),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSelectPill(
                  title: 'Full Raw Stream',
                  subtitle: 'All background IMU',
                  isSelected: filter.mode == ExportMode.fullRawSession,
                  onTap: () => notifier.setMode(ExportMode.fullRawSession),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Format selection pills
          Row(
            children: [
              Expanded(
                child: _buildFormatPill('JSON Dataset', filter.format == ExportFormat.json, () => notifier.setFormat(ExportFormat.json)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFormatPill('CSV Table', filter.format == ExportFormat.csv, () => notifier.setFormat(ExportFormat.csv)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFormatPill('Both Formats', filter.format == ExportFormat.both, () => notifier.setFormat(ExportFormat.both)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectPill({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryWhite : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatPill(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryWhite : AppColors.cardElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryWhite : AppColors.cardBorder),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // ── 4. Time Range Filter Card ─────────────────────────────────────────────
  Widget _buildTimeRangeCard(
    BuildContext context,
    ExportFilterState filter,
    ExportFilterNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Time Range Filter', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                filter.timeRangeType.name.toUpperCase(),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ExportTimeRangeType>(
                value: filter.timeRangeType,
                dropdownColor: AppColors.cardElevated,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                items: const [
                  DropdownMenuItem(value: ExportTimeRangeType.allData, child: Text('All Time')),
                  DropdownMenuItem(value: ExportTimeRangeType.today, child: Text('Today')),
                  DropdownMenuItem(value: ExportTimeRangeType.past7Days, child: Text('Past 7 Days')),
                  DropdownMenuItem(value: ExportTimeRangeType.thisSession, child: Text('This Session')),
                ],
                onChanged: (type) {
                  if (type != null) notifier.setTimeRange(type);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Saved Exports History ──────────────────────────────────────────────
  Widget _buildSavedExportsSection(
    BuildContext context,
    AsyncValue<List<File>> savedFilesAsync,
    ExportController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Dataset Archives',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        savedFilesAsync.when(
          data: (files) {
            if (files.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppStyles.cardDecoration(),
                child: const Center(
                  child: Text('No dataset files exported yet.', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                ),
              );
            }
            return Column(
              children: files.map((file) {
                final name = file.path.split('/').last;
                final sizeKb = (file.lengthSync() / 1024).toStringAsFixed(1);
                final isJson = name.endsWith('.json');

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: AppStyles.cardDecoration(),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isJson ? AppColors.accentCyanBg : AppColors.accentGreenBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isJson ? Icons.data_object_rounded : Icons.table_chart_rounded,
                          color: isJson ? AppColors.accentCyan : AppColors.accentGreen,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('$sizeKb KB', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_rounded, size: 16, color: AppColors.textSecondary),
                        onPressed: () => controller.reShareFiles([file]),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryWhite)),
          error: (err, _) => Text('Error loading files: $err', style: const TextStyle(color: AppColors.accentRed)),
        ),
      ],
    );
  }
}
