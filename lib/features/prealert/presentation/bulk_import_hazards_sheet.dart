import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_theme.dart';
import '../../../prealert/pre_alert_engine.dart';
import '../../../providers/pre_alert_providers.dart';

/// Modal bottom sheet allowing bulk import of pre-recorded hazards via CSV text,
/// GeoJSON, or a 1-tap "Benchmark Track Preset" near the rider's current location.
class BulkImportHazardsSheet extends ConsumerStatefulWidget {
  const BulkImportHazardsSheet({super.key});

  static Future<int?> show(BuildContext context) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const BulkImportHazardsSheet(),
    );
  }

  @override
  ConsumerState<BulkImportHazardsSheet> createState() =>
      _BulkImportHazardsSheetState();
}

class _BulkImportHazardsSheetState extends ConsumerState<BulkImportHazardsSheet> {
  final TextEditingController _csvController = TextEditingController();
  bool _isImporting = false;
  String? _statusMessage;
  bool _isSuccess = false;

  static const String _sampleCsv = '''# lat, lng, type, severity, note
19.076090, 72.877426, bump, 0.8, High asphalt speed-breaker
19.078120, 72.879500, pothole, 0.9, Deep road crater in left lane
19.080450, 72.881200, turn, 0.7, Sharp 90-degree right turn
19.082900, 72.883500, braking, 0.6, Sudden pedestrian crossing zone
19.085100, 72.885800, bump, 0.5, Rumble strip series''';

  @override
  void initState() {
    super.initState();
    _csvController.text = _sampleCsv;
  }

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  Future<void> _importCsv() async {
    final text = _csvController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isImporting = true;
      _statusMessage = null;
    });
    HapticFeedback.mediumImpact();

    int importedCount = 0;
    final registry = ref.read(roadEventRegistryProvider);
    final lines = LineSplitter.split(text);

    try {
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#') || trimmed.startsWith('//')) {
          continue;
        }

        final parts = trimmed.split(',').map((p) => p.trim()).toList();
        if (parts.length < 3) continue;

        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat == null || lng == null) continue;

        final kind = RoadEventKind.fromString(parts[2]);
        final severity = parts.length > 3 ? (double.tryParse(parts[3]) ?? 0.7) : 0.7;
        final note = parts.length > 4 ? parts.sublist(4).join(', ') : null;

        await registry.register(
          kind: kind,
          latitude: lat,
          longitude: lng,
          severity: severity.clamp(0.1, 1.0),
          confidence: 1.0,
          source: 'seeded',
          note: note,
          detectedAtUtc: DateTime.now().toUtc(),
        );
        importedCount++;
      }

      setState(() {
        _isImporting = false;
        _isSuccess = importedCount > 0;
        _statusMessage = importedCount > 0
            ? 'Successfully imported $importedCount road hazards!'
            : 'No valid coordinate rows found in text.';
      });

      if (importedCount > 0 && mounted) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) Navigator.of(context).pop(importedCount);
        });
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _isSuccess = false;
        _statusMessage = 'Import error: $e';
      });
    }
  }

  Future<void> _seedNearbyBenchmarkTrack() async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Getting current GPS for test track layout...';
    });

    double centerLat = 19.0760;
    double centerLng = 72.8774;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
      centerLat = pos.latitude;
      centerLng = pos.longitude;
    } catch (_) {
      // Use fallback center
    }

    // Generate 5 benchmark hazards spaced ~100m apart in a forward path
    final benchmarkHazards = [
      (0.0008, 0.0004, RoadEventKind.bump, 0.85, 'Benchmark Track: Harsh speed breaker #1'),
      (0.0016, 0.0009, RoadEventKind.pothole, 0.90, 'Benchmark Track: Left lane pothole #2'),
      (0.0024, 0.0013, RoadEventKind.turn, 0.75, 'Benchmark Track: Sharp right curve #3'),
      (0.0032, 0.0018, RoadEventKind.braking, 0.70, 'Benchmark Track: Deceleration zone #4'),
      (0.0040, 0.0022, RoadEventKind.bump, 0.60, 'Benchmark Track: Multi-ridge bump #5'),
    ];

    int count = 0;
    final registry = ref.read(roadEventRegistryProvider);

    for (final h in benchmarkHazards) {
      await registry.register(
        kind: h.$3,
        latitude: centerLat + h.$1,
        longitude: centerLng + h.$2,
        severity: h.$4,
        confidence: 1.0,
        source: 'seeded',
        note: h.$5,
        detectedAtUtc: DateTime.now().toUtc(),
      );
      count++;
    }

    setState(() {
      _isImporting = false;
      _isSuccess = true;
      _statusMessage = 'Seeded $count benchmark test hazards near your GPS position!';
    });

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.of(context).pop(count);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: const Color(0xF216161B),
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.file_upload_outlined,
                              color: AppColors.accentCyan, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bulk Import Hazards',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Import CSV ground truth or test tracks',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick 1-Tap Action: Seed Nearby Test Track
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E26),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentAmber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: AppColors.accentAmber, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1-Tap Test Benchmark',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Generate 5 pre-coded hazards along your current GPS road',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentAmber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: _isImporting ? null : _seedNearbyBenchmarkTrack,
                        child: const Text('Seed Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // CSV text area
                const Text(
                  'PASTE CSV GROUND TRUTH (LAT, LNG, TYPE, SEVERITY, NOTE)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _csvController,
                  maxLines: 7,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF191920),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2C2C36)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.accentCyan),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 10),

                // Status message
                if (_statusMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (_isSuccess ? AppColors.accentGreen : AppColors.accentRed)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (_isSuccess ? AppColors.accentGreen : AppColors.accentRed)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                          color: _isSuccess ? AppColors.accentGreen : AppColors.accentRed,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              color: _isSuccess ? AppColors.accentGreen : AppColors.accentRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryWhite,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: _isImporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.file_download_done_rounded, size: 18),
                    label: Text(
                      _isImporting ? 'Importing Hazards...' : 'Import Parsed Hazards',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    onPressed: _isImporting ? null : _importCsv,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
