import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/map_offline_cache_service.dart';
import '../../../core/theme/app_theme.dart';

/// Modal sheet for managing offline Dark Mode map tile storage and pre-caching
/// remote test-track areas for zero-network field research.
class OfflineMapCacheSheet extends ConsumerWidget {
  final double centerLat;
  final double centerLng;

  const OfflineMapCacheSheet({
    super.key,
    required this.centerLat,
    required this.centerLng,
  });

  static Future<void> show(
    BuildContext context, {
    required double centerLat,
    required double centerLng,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OfflineMapCacheSheet(
        centerLat: centerLat,
        centerLng: centerLng,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(mapOfflineCacheServiceProvider);
    final cacheService = ref.read(mapOfflineCacheServiceProvider.notifier);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: const Color(0xF216161B),
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle pill
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

              // Title
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
                        child: const Icon(Icons.download_for_offline_rounded,
                            color: AppColors.accentCyan, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offline Dark Map Cache',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'CartoDB Dark Matter offline tile store',
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
              const SizedBox(height: 18),

              // Cache Stats Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E26),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      '${stats.tileCount}',
                      'Cached Tiles',
                      Icons.layers_rounded,
                      AppColors.accentCyan,
                    ),
                    Container(height: 32, width: 1, color: AppColors.cardBorder),
                    _buildStatColumn(
                      '${stats.sizeMb} MB',
                      'Storage Used',
                      Icons.storage_rounded,
                      const Color(0xFFFFD60A),
                    ),
                    Container(height: 32, width: 1, color: AppColors.cardBorder),
                    _buildStatColumn(
                      stats.tileCount > 0 ? 'Ready' : 'None',
                      'Offline Status',
                      Icons.wifi_off_rounded,
                      stats.tileCount > 0 ? AppColors.accentGreen : AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Download progress if active
              if (stats.isDownloading) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stats.statusText,
                      style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(stats.downloadProgress * 100).round()}%',
                      style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stats.downloadProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Explanatory note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pre-caching downloads road map tiles around your current location (zoom 14-15) directly into local flash storage. Your map will render smoothly even when cellular data is zero in mountains or remote tracks.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryWhite,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: stats.isDownloading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Icon(Icons.download_rounded, size: 18),
                        label: Text(
                          stats.isDownloading ? 'Downloading…' : 'Pre-Cache 2.5km Area',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        onPressed: stats.isDownloading
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                cacheService.preCacheArea(
                                  centerLat: centerLat,
                                  centerLng: centerLng,
                                );
                              },
                      ),
                    ),
                  ),
                  if (stats.tileCount > 0) ...[
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF383842)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      onPressed: stats.isDownloading
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              cacheService.clearCache();
                            },
                      child: const Text('Clear', style: TextStyle(color: AppColors.accentRed, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}
