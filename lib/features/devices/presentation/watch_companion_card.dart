import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/ble_providers.dart';
import '../../../ble/models/ble_device_model.dart';
import '../../../features/trips/trip_controller.dart';
import '../../../core/theme/app_theme.dart';

/// Appearance reflects watch confirmations, including changes made on the wrist.
class WatchCompanionCard extends ConsumerStatefulWidget {
  const WatchCompanionCard({super.key});
  @override
  ConsumerState<WatchCompanionCard> createState() => _WatchCompanionCardState();
}

class _WatchCompanionCardState extends ConsumerState<WatchCompanionCard> {
  bool _saving = false;
  double? _brightness;

  Future<void> _apply(int face, int brightness) async {
    if (_saving) return;
    setState(() => _saving = true);
    final service = ref.read(watchSyncServiceProvider);
    final confirmation = Completer<void>();
    final sub = service.appearanceStream.listen((value) {
      if (value.face == face &&
          value.brightness == brightness &&
          !confirmation.isCompleted) {
        confirmation.complete();
      }
    });
    try {
      final sent = await service.setAppearance(
        face: face,
        brightness: brightness,
      );
      if (!sent) {
        throw StateError('Watch is disconnected');
      }
      await confirmation.future.timeout(const Duration(seconds: 5));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The watch did not confirm. Check the connection and try again.',
            ),
          ),
        );
      }
    } finally {
      await sub.cancel();
      if (mounted) {
        setState(() {
          _saving = false;
          _brightness = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(connectionStatesStreamProvider);
    final service = ref.watch(watchSyncServiceProvider);
    final connected = ref.read(bleConnectionManagerProvider).isWatchConnected;
    final appearance =
        ref.watch(watchAppearanceProvider).value ?? service.currentAppearance;
    final battery =
        ref.watch(watchBatteryStreamProvider).value ??
        service.currentWatchBattery;
    final trip = ref.watch(tripControllerProvider);
    final manager = ref.read(bleConnectionManagerProvider);
    final peers = ref.watch(watchPeersProvider).value ?? service.peers;
    final watchIds = {
      ...manager.readyWatchIds,
      ...manager.currentDeviceStates.values
          .where(
            (d) =>
                d.type == DeviceType.watch &&
                d.connectionState == BleConnectionState.connected,
          )
          .map((d) => d.id),
    };
    const mint = Color(0xFF42DC99);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.watch_rounded, color: mint),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Your watches',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                connected && battery.batteryPercent <= 100
                    ? '${battery.batteryPercent}%'
                    : '—',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            connected
                ? '${peers.values.any((p) => p.fresh) ? 'Companion ready' : 'Bluetooth connected'} · ${trip.isJourneyActive ? 'Ride recording' : 'Ready to ride'}'
                : 'Connect your watch to sync rides and live values.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          for (final id in watchIds) ...[
            Text(
              '${peers[id]?.wrist ?? "Watch"} · ${id.length > 8 ? id.substring(id.length - 8) : id}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              peers[id]?.fresh == true
                  ? '${peers[id]!.localControl ? "Standalone" : "Companion verified"} · ${peers[id]!.tripActive ? "Recording" : "Idle"} · ${peers[id]!.sdReady ? "SD card" : "Internal flash"}\n${peers[id]!.samplesWritten} samples saved on watch'
                  : 'Bluetooth linked; waiting for watch handshake.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final role in [1, 2])
                  ChoiceChip(
                    label: Text(role == 1 ? 'Left' : 'Right'),
                    selected: peers[id]?.role == role,
                    onSelected: peers[id]?.tripActive == true
                        ? null
                        : (_) => service.setWrist(id, role),
                  ),
                TextButton(
                  onPressed: () => service.repairConnection(id),
                  child: const Text('Repair sync'),
                ),
                if (peers[id]?.localControl == true &&
                    peers[id]?.tripActive == false)
                  TextButton(
                    onPressed: () => service.usePhoneControls(id),
                    child: const Text('Use phone controls'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          const Text(
            'Appearance for connected watches',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(2, (face) {
              final selected = appearance.face == face;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: face == 0 ? 6 : 0,
                    left: face == 1 ? 6 : 0,
                  ),
                  child: Semantics(
                    selected: selected,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: connected && !_saving
                          ? () => _apply(face, appearance.brightness)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? mint : Colors.white12,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              face == 0 ? 'A E R O S Y N C' : 'R I D E',
                              style: const TextStyle(
                                color: mint,
                                fontSize: 9,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              face == 0 ? '10:09' : '24',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              face == 0 ? 'Digital' : 'Ride focus',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          const Text('Brightness', style: TextStyle(fontSize: 14)),
          Slider(
            value: _brightness ?? appearance.brightness.toDouble(),
            min: 30,
            max: 255,
            activeColor: mint,
            label:
                '${((_brightness ?? appearance.brightness) / 255 * 100).round()}%',
            onChanged: connected && !_saving
                ? (value) => setState(() => _brightness = value)
                : null,
            onChangeEnd: connected && !_saving
                ? (value) => _apply(appearance.face, value.round())
                : null,
          ),
          Text(
            _saving
                ? 'Waiting for watch confirmation…'
                : 'Tip: hold the time on the watch to switch faces.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
