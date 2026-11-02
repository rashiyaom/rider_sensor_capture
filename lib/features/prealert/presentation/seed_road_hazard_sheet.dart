import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_theme.dart';
import '../../../prealert/pre_alert_engine.dart';
import '../../../providers/pre_alert_providers.dart';

/// Modal bottom sheet allowing researchers / riders to precode road hazards
/// (speed bumps, potholes, sharp turns, braking zones) at specific GPS coordinates.
class SeedRoadHazardSheet extends ConsumerStatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const SeedRoadHazardSheet({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  static Future<bool?> show(
    BuildContext context, {
    double? initialLat,
    double? initialLng,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SeedRoadHazardSheet(
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    );
  }

  @override
  ConsumerState<SeedRoadHazardSheet> createState() => _SeedRoadHazardSheetState();
}

class _SeedRoadHazardSheetState extends ConsumerState<SeedRoadHazardSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _noteController;

  RoadEventKind _selectedKind = RoadEventKind.bump;
  double _severity = 0.7;
  bool _isLocating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _latController = TextEditingController(
      text: widget.initialLat != null ? widget.initialLat!.toStringAsFixed(6) : '',
    );
    _lngController = TextEditingController(
      text: widget.initialLng != null ? widget.initialLng!.toStringAsFixed(6) : '',
    );
    _noteController = TextEditingController();

    if (widget.initialLat == null || widget.initialLng == null) {
      _fetchCurrentLocation();
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      if (mounted) {
        _latController.text = pos.latitude.toStringAsFixed(6);
        _lngController.text = pos.longitude.toStringAsFixed(6);
      }
    } catch (_) {
      // Keep empty or user can enter manually
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _saveHazard() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid GPS coordinates')),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final registry = ref.read(roadEventRegistryProvider);
      await registry.register(
        kind: _selectedKind,
        latitude: lat,
        longitude: lng,
        severity: _severity,
        confidence: 1.0, // Pre-coded ground truth is 100% confidence
        source: 'seeded',
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        detectedAtUtc: DateTime.now().toUtc(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.cardElevated,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pre-coded ${_selectedKind.label} saved! Predictive engine will now pre-alert approaching riders.',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save hazard: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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

                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_location_alt_rounded,
                                color: AppColors.accentAmber, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pre-Code Road Hazard',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Seed ground truth location for pre-alerts',
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

                  // 1. Hazard Kind selector
                  const Text(
                    'HAZARD KIND',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildKindChip(RoadEventKind.bump, 'Speed Bump', Icons.waves_rounded, AppColors.accentAmber),
                      _buildKindChip(RoadEventKind.pothole, 'Pothole', Icons.warning_amber_rounded, AppColors.accentRed),
                      _buildKindChip(RoadEventKind.turn, 'Sharp Turn', Icons.turn_sharp_right_rounded, const Color(0xFFFFD60A)),
                      _buildKindChip(RoadEventKind.braking, 'Braking Zone', Icons.pan_tool_rounded, const Color(0xFFFF375F)),
                      _buildKindChip(RoadEventKind.hazard, 'Road Hazard', Icons.report_problem_rounded, AppColors.accentCyan),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 2. GPS Coordinates Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'LOCATION COORDINATES (WGS84)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: _isLocating
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentCyan),
                              )
                            : const Icon(Icons.my_location_rounded, size: 14, color: AppColors.accentCyan),
                        label: const Text(
                          'Current GPS',
                          style: TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _isLocating ? null : _fetchCurrentLocation,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Latitude',
                            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF1E1E24),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final n = double.tryParse(v.trim());
                            if (n == null || n < -90 || n > 90) return 'Invalid lat';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _lngController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Longitude',
                            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF1E1E24),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final n = double.tryParse(v.trim());
                            if (n == null || n < -180 || n > 180) return 'Invalid lng';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3. Severity Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SEVERITY INTENSITY',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(_severity).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getSeverityColor(_severity).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '${(_severity * 100).round()}% · ${_getSeverityLabel(_severity)}',
                          style: TextStyle(
                            color: _getSeverityColor(_severity),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _getSeverityColor(_severity),
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                      thumbColor: Colors.white,
                      overlayColor: _getSeverityColor(_severity).withValues(alpha: 0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _severity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      onChanged: (v) => setState(() => _severity = v),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 4. Notes / Research Identifier
                  const Text(
                    'NOTES & BENCHMARK ID (OPTIONAL)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Test Track Sector B high-bump #04',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF1E1E24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryWhite,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.check_circle_rounded, size: 20),
                      label: Text(
                        _isSaving ? 'Saving Hazard...' : 'Save Ground-Truth Hazard',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      onPressed: _isSaving ? null : _saveHazard,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKindChip(
    RoadEventKind kind,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedKind == kind;
    return ChoiceChip(
      showCheckmark: false,
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.black : color),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedKind = kind),
      selectedColor: color,
      backgroundColor: const Color(0xFF1E1E24),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.white.withValues(alpha: 0.08),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  Color _getSeverityColor(double val) {
    if (val >= 0.8) return AppColors.accentRed;
    if (val >= 0.5) return AppColors.accentAmber;
    return AppColors.accentGreen;
  }

  String _getSeverityLabel(double val) {
    if (val >= 0.85) return 'Severe';
    if (val >= 0.65) return 'High';
    if (val >= 0.45) return 'Moderate';
    return 'Mild';
  }
}
