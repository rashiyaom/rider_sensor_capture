import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../local_db/database.dart';
import '../models/event_parameters.dart';
import '../../features/export/models/export_options.dart';
import 'export_repository.dart';

class ExportRepositoryImpl implements ExportRepository {
  final AppDatabase _db;

  ExportRepositoryImpl(this._db);

  @override
  Future<ExportSummary> getExportSummary({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
  }) async {
    final events = await _fetchEventsInRange(startUtc, endUtc);
    final eventIds = events.map((e) => e.id).toSet();

    int readingCount = 0;
    int detectionCount = 0;

    if (mode == ExportMode.eventsOnly) {
      if (eventIds.isNotEmpty) {
        final rCountExp = _db.sensorReadings.id.count();
        final rQuery = _db.selectOnly(_db.sensorReadings)
          ..where(_db.sensorReadings.eventId.isIn(eventIds))
          ..addColumns([rCountExp]);
        final rRow = await rQuery.getSingle();
        readingCount = rRow.read(rCountExp) ?? 0;

        final dCountExp = _db.cameraDetections.id.count();
        final dQuery = _db.selectOnly(_db.cameraDetections)
          ..where(_db.cameraDetections.linkedEventId.isIn(eventIds))
          ..addColumns([dCountExp]);
        final dRow = await dQuery.getSingle();
        detectionCount = dRow.read(dCountExp) ?? 0;
      }
    } else {
      // Full raw session mode - count all readings & detections in the time range
      var rQuery = _db.selectOnly(_db.sensorReadings);
      if (startUtc != null) {
        rQuery = rQuery..where(_db.sensorReadings.timestampUtc.isBiggerOrEqualValue(startUtc));
      }
      if (endUtc != null) {
        rQuery = rQuery..where(_db.sensorReadings.timestampUtc.isSmallerOrEqualValue(endUtc));
      }
      final rCountExp = _db.sensorReadings.id.count();
      rQuery.addColumns([rCountExp]);
      final rRow = await rQuery.getSingle();
      readingCount = rRow.read(rCountExp) ?? 0;

      var dQuery = _db.selectOnly(_db.cameraDetections);
      if (startUtc != null) {
        dQuery = dQuery..where(_db.cameraDetections.cameraTimestampUtc.isBiggerOrEqualValue(startUtc));
      }
      if (endUtc != null) {
        dQuery = dQuery..where(_db.cameraDetections.cameraTimestampUtc.isSmallerOrEqualValue(endUtc));
      }
      final dCountExp = _db.cameraDetections.id.count();
      dQuery.addColumns([dCountExp]);
      final dRow = await dQuery.getSingle();
      detectionCount = dRow.read(dCountExp) ?? 0;
    }

    // Estimate ~220 bytes per reading + ~180 bytes per detection + ~600 bytes per event
    final estSize = (events.length * 600) + (readingCount * 220) + (detectionCount * 180);

    return ExportSummary(
      eventCount: events.length,
      sensorReadingCount: readingCount,
      cameraDetectionCount: detectionCount,
      estimatedSizeBytes: estSize,
    );
  }

  Future<List<EventRecord>> _fetchEventsInRange(DateTime? startUtc, DateTime? endUtc) async {
    var query = _db.select(_db.eventRecords);
    if (startUtc != null) {
      query = query..where((t) => t.startTimestamp.isBiggerOrEqualValue(startUtc));
    }
    if (endUtc != null) {
      query = query..where((t) => t.startTimestamp.isSmallerOrEqualValue(endUtc));
    }
    return query.get();
  }

  @override
  Future<Map<String, dynamic>> buildJsonExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
  }) async {
    final now = DateTime.now().toUtc();
    final events = await _fetchEventsInRange(startUtc, endUtc);
    final eventMap = <int, EventRecord>{for (var e in events) e.id: e};
    final eventIds = eventMap.keys.toSet();

    // Fetch Sensor Readings
    List<SensorReading> allReadings;
    if (mode == ExportMode.eventsOnly) {
      if (eventIds.isEmpty) {
        allReadings = [];
      } else {
        allReadings = await (_db.select(_db.sensorReadings)
              ..where((t) => t.eventId.isIn(eventIds))
              ..orderBy([
                (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc),
                (t) => OrderingTerm(expression: t.timestampUtc, mode: OrderingMode.asc),
              ]))
            .get();
      }
    } else {
      var query = _db.select(_db.sensorReadings);
      if (startUtc != null) {
        query = query..where((t) => t.timestampUtc.isBiggerOrEqualValue(startUtc));
      }
      if (endUtc != null) {
        query = query..where((t) => t.timestampUtc.isSmallerOrEqualValue(endUtc));
      }
      allReadings = await (query
            ..orderBy([
              (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc),
              (t) => OrderingTerm(expression: t.timestampUtc, mode: OrderingMode.asc),
            ]))
          .get();
    }

    // Fetch Camera Detections
    List<CameraDetection> allDetections;
    if (mode == ExportMode.eventsOnly) {
      if (eventIds.isEmpty) {
        allDetections = [];
      } else {
        allDetections = await (_db.select(_db.cameraDetections)
              ..where((t) => t.linkedEventId.isIn(eventIds))
              ..orderBy([
                (t) => OrderingTerm(expression: t.cameraTimestampUtc, mode: OrderingMode.asc),
              ]))
            .get();
      }
    } else {
      var query = _db.select(_db.cameraDetections);
      if (startUtc != null) {
        query = query..where((t) => t.cameraTimestampUtc.isBiggerOrEqualValue(startUtc));
      }
      if (endUtc != null) {
        query = query..where((t) => t.cameraTimestampUtc.isSmallerOrEqualValue(endUtc));
      }
      allDetections = await (query
            ..orderBy([
              (t) => OrderingTerm(expression: t.cameraTimestampUtc, mode: OrderingMode.asc),
            ]))
          .get();
    }

    // Group readings and detections by eventId
    final readingsByEvent = <int, List<Map<String, dynamic>>>{};
    final unlinkedReadings = <Map<String, dynamic>>[];

    for (final r in allReadings) {
      final rMap = _formatReading(r);
      if (r.eventId != null && eventMap.containsKey(r.eventId)) {
        readingsByEvent.putIfAbsent(r.eventId!, () => []).add(rMap);
      } else {
        unlinkedReadings.add(rMap);
      }
    }

    final detectionsByEvent = <int, List<Map<String, dynamic>>>{};
    final unlinkedDetections = <Map<String, dynamic>>[];

    for (final d in allDetections) {
      final dMap = _formatDetection(d);
      if (d.linkedEventId != null && eventMap.containsKey(d.linkedEventId)) {
        detectionsByEvent.putIfAbsent(d.linkedEventId!, () => []).add(dMap);
      } else {
        unlinkedDetections.add(dMap);
      }
    }

    // Build structured events list
    final eventsJson = events.map((e) {
      Map<String, dynamic>? parsedParams;
      if (e.computedParameters != null) {
        try {
          parsedParams = jsonDecode(e.computedParameters!) as Map<String, dynamic>;
        } catch (_) {}
      }

      double? durationSec;
      if (e.endTimestamp != null) {
        durationSec = e.endTimestamp!.difference(e.startTimestamp).inMilliseconds / 1000.0;
      }

      return {
        'event_id': e.id,
        'event_type': e.eventType,
        'status': e.status,
        'trigger_phrase': e.triggerPhrase,
        'start_timestamp_utc': e.startTimestamp.toIso8601String(),
        'end_timestamp_utc': e.endTimestamp?.toIso8601String(),
        'duration_seconds': durationSec,
        'start_gps': (e.startGpsLat != null && e.startGpsLng != null)
            ? {'latitude': e.startGpsLat, 'longitude': e.startGpsLng}
            : null,
        'end_gps': (e.endGpsLat != null && e.endGpsLng != null)
            ? {'latitude': e.endGpsLat, 'longitude': e.endGpsLng}
            : null,
        'classification': e.classification,
        'peak_metric': e.peakMetric,
        'parameters': parsedParams,
        'sensor_readings': readingsByEvent[e.id] ?? [],
        'camera_detections': detectionsByEvent[e.id] ?? [],
      };
    }).toList();

    final exportJson = <String, dynamic>{
      'export_generated_at_utc': now.toIso8601String(),
      'time_range': {
        'start_utc': startUtc?.toIso8601String(),
        'end_utc': endUtc?.toIso8601String(),
      },
      'export_mode': mode == ExportMode.eventsOnly ? 'events_only' : 'full_raw_session',
      'total_events': events.length,
      'events': eventsJson,
    };

    if (mode == ExportMode.fullRawSession) {
      exportJson['raw_unlabeled_sensor_readings'] = unlinkedReadings;
      exportJson['raw_unlabeled_camera_detections'] = unlinkedDetections;
    }

    return exportJson;
  }

  Map<String, dynamic> _formatReading(SensorReading r) {
    return {
      'id': r.id,
      'device_id': r.deviceId,
      'device_type': r.deviceType,
      'sequence_no': r.sequenceNo,
      'timestamp_utc': r.timestampUtc.toIso8601String(),
      'sensor_type': r.sensorType,
      'event_id': r.eventId,
      'values': {
        'heart_rate': r.heartRate,
        'accel_x': r.accelX,
        'accel_y': r.accelY,
        'accel_z': r.accelZ,
        'gyro_x': r.gyroX,
        'gyro_y': r.gyroY,
        'gyro_z': r.gyroZ,
        'ppi_ms': r.ppiMs,
      },
      'raw_payload': r.rawPayload,
    };
  }

  Map<String, dynamic> _formatDetection(CameraDetection d) {
    final latencyMs = d.receivedAtUtc.difference(d.cameraTimestampUtc).inMilliseconds;
    return {
      'id': d.id,
      'device_id': d.deviceId,
      'event_class': d.eventClass,
      'confidence': d.confidence,
      'camera_timestamp_utc': d.cameraTimestampUtc.toIso8601String(),
      'received_at_utc': d.receivedAtUtc.toIso8601String(),
      'network_latency_ms': latencyMs,
      'linked_event_id': d.linkedEventId,
    };
  }

  @override
  Future<String> buildSensorCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
  }) async {
    final events = await _fetchEventsInRange(startUtc, endUtc);
    final eventMap = <int, EventRecord>{for (var e in events) e.id: e};
    final eventIds = eventMap.keys.toSet();

    List<SensorReading> readings;
    if (mode == ExportMode.eventsOnly) {
      if (eventIds.isEmpty) {
        readings = [];
      } else {
        readings = await (_db.select(_db.sensorReadings)
              ..where((t) => t.eventId.isIn(eventIds))
              ..orderBy([
                (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc),
                (t) => OrderingTerm(expression: t.timestampUtc, mode: OrderingMode.asc),
              ]))
            .get();
      }
    } else {
      var query = _db.select(_db.sensorReadings);
      if (startUtc != null) {
        query = query..where((t) => t.timestampUtc.isBiggerOrEqualValue(startUtc));
      }
      if (endUtc != null) {
        query = query..where((t) => t.timestampUtc.isSmallerOrEqualValue(endUtc));
      }
      readings = await (query
            ..orderBy([
              (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc),
              (t) => OrderingTerm(expression: t.timestampUtc, mode: OrderingMode.asc),
            ]))
          .get();
    }

    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln(
      'reading_id,timestamp_utc,sequence_no,device_id,device_type,sensor_type,'
      'heart_rate,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,ppi_ms,'
      'event_id,event_type,event_classification,event_peak_metric,event_trigger_phrase,event_start_lat,event_start_lng,param_summary',
    );

    for (final r in readings) {
      final evt = r.eventId != null ? eventMap[r.eventId] : null;
      final params = evt?.computedParameters != null
          ? EventParameters.fromJsonString(evt!.computedParameters)?.summary
          : '';

      final row = [
        r.id,
        r.timestampUtc.toIso8601String(),
        r.sequenceNo,
        _csvEscape(r.deviceId),
        _csvEscape(r.deviceType),
        _csvEscape(r.sensorType),
        r.heartRate ?? '',
        r.accelX?.toStringAsFixed(4) ?? '',
        r.accelY?.toStringAsFixed(4) ?? '',
        r.accelZ?.toStringAsFixed(4) ?? '',
        r.gyroX?.toStringAsFixed(4) ?? '',
        r.gyroY?.toStringAsFixed(4) ?? '',
        r.gyroZ?.toStringAsFixed(4) ?? '',
        r.ppiMs ?? '',
        r.eventId ?? '',
        _csvEscape(evt?.eventType ?? ''),
        _csvEscape(evt?.classification ?? ''),
        evt?.peakMetric?.toStringAsFixed(2) ?? '',
        _csvEscape(evt?.triggerPhrase ?? ''),
        evt?.startGpsLat?.toStringAsFixed(6) ?? '',
        evt?.startGpsLng?.toStringAsFixed(6) ?? '',
        _csvEscape(params ?? ''),
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  @override
  Future<String> buildCameraCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
  }) async {
    final events = await _fetchEventsInRange(startUtc, endUtc);
    final eventIds = events.map((e) => e.id).toSet();

    List<CameraDetection> detections;
    if (mode == ExportMode.eventsOnly) {
      if (eventIds.isEmpty) {
        detections = [];
      } else {
        detections = await (_db.select(_db.cameraDetections)
              ..where((t) => t.linkedEventId.isIn(eventIds))
              ..orderBy([
                (t) => OrderingTerm(expression: t.cameraTimestampUtc, mode: OrderingMode.asc),
              ]))
            .get();
      }
    } else {
      var query = _db.select(_db.cameraDetections);
      if (startUtc != null) {
        query = query..where((t) => t.cameraTimestampUtc.isBiggerOrEqualValue(startUtc));
      }
      if (endUtc != null) {
        query = query..where((t) => t.cameraTimestampUtc.isSmallerOrEqualValue(endUtc));
      }
      detections = await (query
            ..orderBy([
              (t) => OrderingTerm(expression: t.cameraTimestampUtc, mode: OrderingMode.asc),
            ]))
          .get();
    }

    final buffer = StringBuffer();
    buffer.writeln('detection_id,camera_timestamp_utc,received_at_utc,device_id,event_class,confidence,linked_event_id,latency_ms');

    for (final d in detections) {
      final latencyMs = d.receivedAtUtc.difference(d.cameraTimestampUtc).inMilliseconds;
      final row = [
        d.id,
        d.cameraTimestampUtc.toIso8601String(),
        d.receivedAtUtc.toIso8601String(),
        _csvEscape(d.deviceId),
        _csvEscape(d.eventClass),
        d.confidence.toStringAsFixed(4),
        d.linkedEventId ?? '',
        latencyMs,
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  String _csvEscape(String val) {
    if (val.contains(',') || val.contains('"') || val.contains('\n')) {
      return '"${val.replaceAll('"', '""')}"';
    }
    return val;
  }

  @override
  Future<List<File>> generateExportFiles({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportFormat format,
    required ExportMode mode,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(docsDir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final createdFiles = <File>[];

    if (format == ExportFormat.json || format == ExportFormat.both) {
      final jsonMap = await buildJsonExport(startUtc: startUtc, endUtc: endUtc, mode: mode);
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);
      final jsonFile = File(p.join(exportDir.path, 'ride_dataset_$timestampStr.json'));
      await jsonFile.writeAsString(jsonString);
      createdFiles.add(jsonFile);
    }

    if (format == ExportFormat.csv || format == ExportFormat.both) {
      final sensorCsv = await buildSensorCsvExport(startUtc: startUtc, endUtc: endUtc, mode: mode);
      final sensorFile = File(p.join(exportDir.path, 'ride_sensor_readings_$timestampStr.csv'));
      await sensorFile.writeAsString(sensorCsv);
      createdFiles.add(sensorFile);

      final cameraCsv = await buildCameraCsvExport(startUtc: startUtc, endUtc: endUtc, mode: mode);
      if (cameraCsv.split('\n').length > 2) {
        // Only create camera CSV if there are detection rows
        final cameraFile = File(p.join(exportDir.path, 'ride_camera_detections_$timestampStr.csv'));
        await cameraFile.writeAsString(cameraCsv);
        createdFiles.add(cameraFile);
      }
    }

    return createdFiles;
  }

  @override
  Future<void> shareFiles(List<File> files) async {
    if (files.isEmpty) return;
    final xFiles = files.map((f) => XFile(f.path)).toList();
    await Share.shareXFiles(
      xFiles,
      text: 'Ride Sensor Capture - ML Training Dataset Export',
      subject: 'Ride Sensor Capture ML Export',
    );
  }

  @override
  Future<List<File>> getSavedExports() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory(p.join(docsDir.path, 'exports'));
      if (!await exportDir.exists()) return [];

      final files = exportDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json') || f.path.endsWith('.csv'))
          .toList();

      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return files;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> deleteExportFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
