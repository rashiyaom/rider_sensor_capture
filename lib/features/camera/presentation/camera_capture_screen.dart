import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skio_uvc_camera/skio_uvc_camera.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../providers/camera_providers.dart';
import '../../events/event_recording_controller.dart';

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  ConsumerState<CameraCaptureScreen> createState() =>
      _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  List<DeviceHandle> _devices = const [];
  UvcCamera? _camera;
  DeviceHandle? _selectedDevice;
  UvcCameraStatus? _status;
  StreamSubscription<DeviceEvent>? _deviceEventsSub;
  StreamSubscription<UvcCameraStatus>? _statusSub;
  StreamSubscription<void>? _buttonSub;
  bool _refreshing = false;
  bool _connecting = false;
  bool _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _deviceEventsSub = UvcCamera.events.listen((_) => _refreshDevices());
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDevices());
  }

  @override
  void dispose() {
    _deviceEventsSub?.cancel();
    _statusSub?.cancel();
    _buttonSub?.cancel();
    _camera?.close();
    super.dispose();
  }

  Future<void> _refreshDevices() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final devices = await UvcCamera.devices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _selectedDevice ??= devices.isEmpty ? null : devices.first;
        if (_selectedDevice != null && !devices.contains(_selectedDevice)) {
          _selectedDevice = devices.isEmpty ? null : devices.first;
        }
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = 'USB scan failed: $error');
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _connect() async {
    final device = _selectedDevice;
    if (device == null || _connecting) return;
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      final access = await UvcCamera.access.requestAccess(device);
      if (!access.isUsable) {
        throw StateError(
          access.hint ??
              'Camera/USB permission was not granted (${access.status.name})',
        );
      }

      await _disconnect();
      final camera = await UvcCamera.open(
        device,
        preferred: const [
          UvcSize(1280, 720, format: UvcFrameFormat.mjpeg),
          UvcSize(640, 480, format: UvcFrameFormat.mjpeg),
          UvcSize(320, 240, format: UvcFrameFormat.mjpeg),
        ],
      );
      _camera = camera;
      _status = camera.currentStatus;
      _statusSub = camera.status.listen((status) {
        if (mounted) setState(() => _status = status);
      });
      _buttonSub = camera.buttonPresses.listen((_) {
        unawaited(_capture('camera_button'));
      });
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => _error = 'Camera connection failed: $error');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _disconnect() async {
    await _statusSub?.cancel();
    await _buttonSub?.cancel();
    _statusSub = null;
    _buttonSub = null;
    final previous = _camera;
    _camera = null;
    _status = null;
    await previous?.close();
    if (mounted) setState(() {});
  }

  Future<void> _capture(String trigger) async {
    final camera = _camera;
    if (camera == null || !camera.isOpen || _capturing) return;
    setState(() {
      _capturing = true;
      _error = null;
    });
    try {
      final capturedAt = DateTime.now().toUtc();
      final bytes = await camera.captureBytes(quality: 92);
      final size = camera.previewSize;
      final row = await ref
          .read(cameraCaptureRepositoryProvider)
          .saveJpeg(
            bytes: bytes,
            deviceId: _persistentDeviceId(camera.device),
            width: size.width,
            height: size.height,
            capturedAtUtc: capturedAt,
            trigger: trigger,
          );
      HapticFeedback.mediumImpact();
      if (mounted && trigger == 'manual') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Photo #${row.sequenceNo} saved'
              '${row.linkedEventId == null ? '' : ' → event ${row.linkedEventId}'}',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Photo capture failed: $error');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  String _persistentDeviceId(DeviceHandle device) {
    String hex(int? value) =>
        value == null ? 'unknown' : value.toRadixString(16).padLeft(4, '0');
    final serial = device.serialNumber?.trim();
    return 'uvc:${hex(device.vendorId)}:${hex(device.productId)}:'
        '${serial == null || serial.isEmpty ? device.id : serial}';
  }

  @override
  Widget build(BuildContext context) {
    // The screen stays alive in the IndexedStack. Once connected, these
    // transitions capture visual brackets around every labeled incident even
    // while the rider uses Dashboard or Events.
    ref.listen<EventRecordingSessionState>(eventRecordingControllerProvider, (
      previous,
      next,
    ) {
      final wasRecording = previous?.state == RecordingState.recording;
      if (!wasRecording && next.state == RecordingState.recording) {
        unawaited(_capture('incident_start'));
      } else if (wasRecording && next.state != RecordingState.recording) {
        unawaited(_capture('incident_end'));
      }
    });

    final captures = ref.watch(recentCameraCapturesProvider).value ?? const [];
    final camera = _camera;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('USB Ride Camera'),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refreshDevices,
            tooltip: 'Rescan USB cameras',
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.usb_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          _buildConnectionCard(),
          const SizedBox(height: 14),
          Container(
            height: 270,
            clipBehavior: Clip.antiAlias,
            decoration: AppStyles.cardDecoration(),
            child: camera == null
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_off_outlined,
                          color: AppColors.textTertiary,
                          size: 44,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Connect the flashed DFR1154 camera',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: Colors.black,
                        child: UvcPreview(camera: camera),
                      ),
                      Positioned(left: 10, top: 10, child: _statusPill(camera)),
                    ],
                  ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.accentRed, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: camera == null || _capturing
                  ? null
                  : () => _capture('manual'),
              icon: _capturing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.camera_alt_rounded),
              label: Text(_capturing ? 'Saving JPEG…' : 'Capture & Map Photo'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CAPTURE MANIFEST',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${captures.length} recent',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (captures.isEmpty)
            _emptyManifest()
          else
            ...captures.map(_captureTile),
        ],
      ),
    );
  }

  Widget _buildConnectionCard() {
    final connected = _camera != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DFRobot DFR1154 • OV3660',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            connected
                ? 'USB-C UVC link active'
                : 'Attach with an OTG/data-capable USB-C cable',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (!connected) ...[
            DropdownButtonFormField<DeviceHandle>(
              initialValue: _selectedDevice,
              isExpanded: true,
              dropdownColor: AppColors.cardElevated,
              decoration: const InputDecoration(labelText: 'USB camera'),
              items: _devices
                  .map(
                    (device) => DropdownMenuItem(
                      value: device,
                      child: Text(
                        device.name ?? device.id,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedDevice = value),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _connecting
                  ? null
                  : connected
                  ? _disconnect
                  : _connect,
              icon: Icon(
                connected ? Icons.link_off_rounded : Icons.usb_rounded,
              ),
              label: Text(
                _connecting
                    ? 'Opening camera…'
                    : connected
                    ? 'Disconnect Camera'
                    : 'Connect USB Camera',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(UvcCamera camera) {
    final size = camera.previewSize;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_status?.name ?? 'previewing'} • ${size.width}×${size.height}',
        style: const TextStyle(
          color: AppColors.accentGreen,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _captureTile(CameraCapture capture) {
    final file = File(capture.filePath);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: AppStyles.cardDecoration(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: 76,
              height: 54,
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover, cacheWidth: 228)
                  : const ColoredBox(
                      color: AppColors.cardElevated,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHOTO ${capture.sequenceNo.toString().padLeft(6, '0')}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${DateFormat('HH:mm:ss.SSS').format(capture.capturedAtUtc.toLocal())}'
                  ' • ${capture.trigger.replaceAll('_', ' ')}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'trip ${capture.tripId ?? '—'} • event ${capture.linkedEventId ?? '—'}'
                  ' • ${capture.width}×${capture.height}',
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyManifest() => Container(
    padding: const EdgeInsets.all(18),
    decoration: AppStyles.cardDecoration(),
    child: const Text(
      'Captured photos will appear here in device sequence order and will '
      'be linked to the active ride and incident.',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
    ),
  );
}
