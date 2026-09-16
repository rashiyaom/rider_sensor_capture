import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../providers/db_providers.dart';
import '../trip_controller.dart';
import 'trip_detail_screen.dart';

class TripsHistoryScreen extends ConsumerWidget {
  const TripsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(allTripsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journey Log Book'),
      ),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Icon(Icons.route_rounded, color: AppColors.textSecondary, size: 30),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Journeys Recorded Yet',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Connect your ESP32-Watch or sensor, then tap "Start Journey" on the Dashboard to record trips with GPS & 50Hz telemetry.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return _TripCard(trip: trip);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryWhite)),
        error: (err, _) => Center(child: Text('Error loading journeys: $err', style: const TextStyle(color: AppColors.accentRed))),
      ),
    );
  }
}

class _TripCard extends ConsumerWidget {
  final Trip trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final dateStr = dateFormat.format(trip.startTimeUtc.toLocal());
    final durationMins = (trip.durationSeconds / 60.0).toStringAsFixed(1);
    final distanceKm = (trip.distanceMeters / 1000.0).toStringAsFixed(2);

    return Dismissible(
      key: ValueKey('trip_${trip.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.accentRedBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Journey?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            content: Text(
              'Permanently delete Journey #${trip.id} (${trip.riderName}) and its recorded sensor data?',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        final repo = ref.read(sensorRepositoryProvider);
        repo.deleteTrip(trip.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Journey #${trip.id} deleted')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppStyles.cardDecoration(),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyanBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            trip.riderName,
                            style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Journey #${trip.id}',
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem(Icons.timer_outlined, '$durationMins min'),
                    const SizedBox(width: 14),
                    _buildStatItem(Icons.route_rounded, '$distanceKm km'),
                    const SizedBox(width: 14),
                    _buildStatItem(Icons.storage_rounded, '${trip.totalSensorRows} rows'),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
