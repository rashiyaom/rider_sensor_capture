import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/services/app_permissions_service.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/devices/presentation/devices_screen.dart';
import 'features/events/presentation/events_screen.dart';
import 'features/export/presentation/export_screen.dart';

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

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _hasCheckedPermissions = false;
  AppPermissionStatus _permissionStatus = const AppPermissionStatus();

  final List<Widget> _screens = const [
    DashboardScreen(),
    DevicesScreen(),
    EventsScreen(),
    ExportScreen(),
  ];

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Screen contents with bottom padding for the floating dock
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Missing Permission Warning Banner at Top (if any permissions were permanently denied or missed)
          if (_hasCheckedPermissions && _permissionStatus.isCriticalMissing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: _buildPermissionWarningBanner(),
            ),

          // Floating Glassmorphic Pill Dock (matching the reference UI)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: _buildFloatingDock(),
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
            border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.4), width: 1),
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
              const Icon(Icons.shield_outlined, color: AppColors.accentRed, size: 20),
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
                      'Bluetooth, GPS & Mic needed for live ML capture.',
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await openAppSettings();
                  final updated = await AppPermissionsService.checkCurrentStatus();
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
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
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C2C32) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
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
