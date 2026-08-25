import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'camera_detection_model.dart';
import 'camera_detection_repository.dart';

/// Status snapshot for the camera ingest server.
class CameraServerStatus {
  final bool isRunning;
  final String? localIp;
  final int port;
  final DateTime? lastEventReceivedAt;
  final int totalReceived;

  const CameraServerStatus({
    this.isRunning = false,
    this.localIp,
    this.port = CameraIngestServer.defaultPort,
    this.lastEventReceivedAt,
    this.totalReceived = 0,
  });

  String get addressLabel =>
      isRunning && localIp != null ? '$localIp:$port' : 'Server stopped';

  String get livenessLabel {
    if (!isRunning) return 'Stopped';
    if (lastEventReceivedAt == null) return 'No events yet';
    final ago = DateTime.now().difference(lastEventReceivedAt!);
    if (ago.inSeconds < 60) return '${ago.inSeconds}s ago';
    return '${ago.inMinutes}m ago';
  }
}

/// Lightweight embedded HTTP server using shelf that listens for camera
/// firmware detection pushes (POST /camera-event).
class CameraIngestServer {
  static const int defaultPort = 8765;

  final CameraDetectionRepository _repo;
  final int port;

  HttpServer? _server;
  final StreamController<CameraServerStatus> _statusController =
      StreamController<CameraServerStatus>.broadcast();
  final StreamController<CameraDetectionPayload> _detectionController =
      StreamController<CameraDetectionPayload>.broadcast();

  bool _isRunning = false;
  DateTime? _lastEventReceivedAt;
  int _totalReceived = 0;
  String? _localIp;

  CameraIngestServer(this._repo, {this.port = defaultPort});

  Stream<CameraServerStatus> get statusStream => _statusController.stream;
  Stream<CameraDetectionPayload> get detectionStream =>
      _detectionController.stream;
  bool get isRunning => _isRunning;
  String? get localIp => _localIp;

  /// Start the HTTP server. Returns true if started successfully.
  Future<bool> start() async {
    if (_isRunning) return true;

    try {
      _localIp = await _getLocalIp();

      final router = Router()
        ..post('/camera-event', _handleCameraEvent)
        ..get('/health', _handleHealth);

      final handler = Pipeline()
          .addMiddleware(logRequests(
            logger: (msg, isError) {
              if (kDebugMode) print('[CameraServer] $msg');
            },
          ))
          .addHandler(router.call);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
      _isRunning = true;
      _emitStatus();
      if (kDebugMode) {
        print('[CameraServer] Listening on $_localIp:$port');
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('[CameraServer] Failed to start: $e');
      _isRunning = false;
      _emitStatus();
      return false;
    }
  }

  /// Stop the HTTP server.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _isRunning = false;
    _emitStatus();
    if (kDebugMode) print('[CameraServer] Stopped');
  }

  Future<Response> _handleHealth(Request req) async {
    return Response.ok('ride_sensor_capture camera ingest OK');
  }

  Future<Response> _handleCameraEvent(Request req) async {
    final body = await req.readAsString();

    // Validate payload
    final payload = CameraDetectionPayload.fromJsonString(body);
    if (payload == null) {
      if (kDebugMode) print('[CameraServer] 400 Bad payload: $body');
      return Response(
        400,
        body: '{"error":"Missing or malformed fields. Required: '
            'event_class (string), confidence (0.0-1.0), '
            'camera_timestamp_utc (ISO8601), device_id (string)"}',
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Persist and link
    try {
      await _repo.insertDetection(payload);
      _lastEventReceivedAt = DateTime.now();
      _totalReceived++;
      _detectionController.add(payload);
      _emitStatus();
      if (kDebugMode) print('[CameraServer] Received: $payload');
      return Response.ok(
        '{"status":"ok","class":"${payload.eventClass}"}',
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      if (kDebugMode) print('[CameraServer] DB insert error: $e');
      return Response.internalServerError(
        body: '{"error":"Internal server error"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  void _emitStatus() {
    if (!_statusController.isClosed) {
      _statusController.add(CameraServerStatus(
        isRunning: _isRunning,
        localIp: _localIp,
        port: port,
        lastEventReceivedAt: _lastEventReceivedAt,
        totalReceived: _totalReceived,
      ));
    }
  }

  /// Gets the device's local WiFi IP address.
  Future<String?> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        // Prefer wlan / wi-fi interfaces
        final name = iface.name.toLowerCase();
        if (name.contains('wlan') ||
            name.contains('en0') ||
            name.contains('eth') ||
            name.contains('wifi')) {
          for (final addr in iface.addresses) {
            if (!addr.isLinkLocal && !addr.isLoopback) return addr.address;
          }
        }
      }
      // Fallback: first non-loopback IPv4
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    stop();
    _statusController.close();
    _detectionController.close();
  }
}
