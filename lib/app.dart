import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/services/app_permissions_service.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/devices/presentation/devices_screen.dart';
import 'features/events/presentation/events_screen.dart';
import 'features/camera/presentation/camera_capture_screen.dart';
import 'features/export/presentation/export_screen.dart';
import 'providers/db_providers.dart';
import 'providers/ble_providers.dart';
import 'providers/handsfree_providers.dart';
import 'providers/ml_inference_providers.dart';
import 'providers/pre_alert_providers.dart';
import 'data/services/live_ml_inference_service.dart';
import 'voice/handsfree_session_service.dart';

class RideSensorCaptureApp extends StatelessWidget {
  const RideSensorCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Ride Sensor Capture',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const MainNavigationShell(),
      ),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;
  bool _hasCheckedPermissions = false;
  AppPermissionStatus _permissionStatus = const AppPermissionStatus();

  final List<Widget> _screens = const [
    DashboardScreen(),
    DevicesScreen(),
    EventsScreen(),
    CameraCaptureScreen(),
    ExportScreen(),
  ];

  void navigateTo(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptPermissions();
    });
  }

  Future<void> _checkAndPromptPermissions() async {
    // Check initial state
    final initial = await AppPermissionsService.checkCurrentStatus();
    if (!initial.areAllGranted) {
      // Automatically request all system permissions immediately on app launch
      final result = await AppPermissionsService.requestAllInitialPermissions();
      if (mounted) {
        setState(() {
          _permissionStatus = result;
          _hasCheckedPermissions = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _permissionStatus = initial;
          _hasCheckedPermissions = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep BLE-to-DB stream bridge active globally across all navigation tabs
    ref.watch(bleToDbBridgeProvider);
    // Keep Watch Companion synchronization bridge active globally
    ref.watch(watchSyncServiceProvider);
    // Keep the predictive pre-alert engine alive (GPS -> spoken warning)
    ref.watch(preAlertServiceProvider);
    // Bootstrap the hands-free rider assistant and keep it alive globally
    ref.watch(handsfreeSessionServiceProvider);

    // Feed the live on-device ML classifier into the road-event knowledge
    // base so newly discovered hazards can be warned about ahead of time.
    ref.listen<AsyncValue<LiveMlPrediction>>(liveMlPredictionStreamProvider, (
      _,
      next,
    ) {
      next.whenData((prediction) {
        ref.read(roadEventWatcherProvider).handlePrediction(prediction);
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Screen contents with bottom padding for the floating dock
          IndexedStack(index: _currentIndex, children: _screens),

          // Missing Permission Warning Banner at Top
          if (_hasCheckedPermissions && _permissionStatus.isCriticalMissing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: _buildPermissionWarningBanner(),
            ),

          // Floating Glassmorphic Pill Dock + rashiyaom branding
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Hands-Free Status Pill ──
                const _HandsfreeStatusPill(),
                const SizedBox(height: 6),
                Center(child: _buildFloatingDock()),
                const SizedBox(height: 5),
                // ── rashiyaom branding watermark ──
                Text(
                  'made by rashiyaom',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.20),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWarningBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xE6241414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accentRed.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.accentRed,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Hardware Permissions Required',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Bluetooth & GPS needed for live ML capture.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryWhite,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await openAppSettings();
                  final updated =
                      await AppPermissionsService.checkCurrentStatus();
                  if (mounted) {
                    setState(() => _permissionStatus = updated);
                  }
                },
                child: const Text(
                  'Settings',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDock() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xE618181D),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.bar_chart_rounded,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Dashboard',
              ),
              const SizedBox(width: 4),
              _buildNavItem(
                index: 1,
                icon: Icons.bluetooth_rounded,
                activeIcon: Icons.bluetooth_connected_rounded,
                label: 'Devices',
              ),
              const SizedBox(width: 4),
              _buildNavItem(
                index: 2,
                icon: Icons.graphic_eq_rounded,
                activeIcon: Icons.mic_rounded,
                label: 'Events',
              ),
              const SizedBox(width: 4),
              _buildNavItem(
                index: 3,
                icon: Icons.videocam_outlined,
                activeIcon: Icons.videocam_rounded,
                label: 'Camera',
              ),
              const SizedBox(width: 4),
              _buildNavItem(
                index: 4,
                icon: Icons.file_upload_outlined,
                activeIcon: Icons.file_download_rounded,
                label: 'Export',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C2C32) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Utility class to navigate from child widgets to a specific tab
class AppNavigator {
  /// Navigate to Devices tab (index 1) from any descendant widget
  static void goToDevices(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    state?.navigateTo(1);
  }

  /// Navigate to a specific tab index from any descendant widget
  static void goTo(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    state?.navigateTo(index);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hands-Free Status Pill
// ─────────────────────────────────────────────────────────────────────────────

/// Floating pill that shows the current state of the hands-free assistant.
///
/// * **Off** — hidden (zero height)
/// * **Listening** — subtle green mic icon
/// * **Speaking** — amber waveform icon (mic muted)
/// * **Awaiting answer** — pulsing blue question-mark icon
class _HandsfreeStatusPill extends ConsumerWidget {
  const _HandsfreeStatusPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(handsfreeStateProvider);

    if (state.mode == HandsfreeMode.off) return const SizedBox.shrink();

    final (icon, color, label) = switch (state.mode) {
      HandsfreeMode.listening => (
        Icons.mic_rounded,
        const Color(0xFF4CAF50),
        'Listening',
      ),
      HandsfreeMode.speaking => (
        Icons.surround_sound_rounded,
        const Color(0xFFFFB300),
        'Speaking',
      ),
      HandsfreeMode.awaitingUnknownEventAnswer => (
        Icons.help_outline_rounded,
        const Color(0xFF42A5F5),
        'Awaiting your answer…',
      ),
      HandsfreeMode.off => (Icons.mic_off_rounded, Colors.grey, 'Off'),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Center(
        key: ValueKey(state.mode),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withValues(alpha: 0.45),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulseIcon(
                    icon: icon,
                    color: color,
                    pulse:
                        state.mode == HandsfreeMode.awaitingUnknownEventAnswer,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (state.lastSpokenText != null &&
                      state.mode == HandsfreeMode.speaking) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '"${state.lastSpokenText!}"',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.75),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool pulse;

  const _PulseIcon({
    required this.icon,
    required this.color,
    this.pulse = false,
  });

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.pulse) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulseIcon old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.pulse && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(widget.icon, color: widget.color, size: 14),
    );
  }
}
