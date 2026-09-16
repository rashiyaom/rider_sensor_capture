import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../core/utils/angular_units.dart';
import '../local_db/database.dart';
import '../models/event_parameters.dart';
import '../services/hr_event_gate.dart';
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
    bool onlyCrossConfirmed = false,
  }) async {
    final events = await _fetchEventsInRange(startUtc, endUtc, onlyCrossConfirmed: onlyCrossConfirmed);
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

    final estSize = (events.length * 700) + (readingCount * 250) + (detectionCount * 180);

    return ExportSummary(
      eventCount: events.length,
      sensorReadingCount: readingCount,
      cameraDetectionCount: detectionCount,
      estimatedSizeBytes: estSize,
    );
  }

  Future<List<EventRecord>> _fetchEventsInRange(
    DateTime? startUtc,
    DateTime? endUtc, {
    bool onlyCrossConfirmed = false,
  }) async {
    var query = _db.select(_db.eventRecords);
    if (startUtc != null) {
      query = query..where((t) => t.startTimestamp.isBiggerOrEqualValue(startUtc));
    }
    if (endUtc != null) {
      query = query..where((t) => t.startTimestamp.isSmallerOrEqualValue(endUtc));
    }
    if (onlyCrossConfirmed) {
      query = query..where((t) => t.crossConfirmed.equals(true));
    }
    return query.get();
  }

  @override
  Future<Map<String, dynamic>> buildJsonExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
    bool onlyCrossConfirmed = false,
  }) async {
    final now = DateTime.now().toUtc();
    final events = await _fetchEventsInRange(startUtc, endUtc, onlyCrossConfirmed: onlyCrossConfirmed);
    final eventMap = <int, EventRecord>{for (var e in events) e.id: e};
    final eventIds = eventMap.keys.toSet();

    // Fetch Trips within range
    var tripsQuery = _db.select(_db.trips);
    if (startUtc != null) {
      tripsQuery = tripsQuery..where((t) => t.startTimestampUtc.isBiggerOrEqualValue(startUtc));
    }
    if (endUtc != null) {
      tripsQuery = tripsQuery..where((t) => t.startTimestampUtc.isSmallerOrEqualValue(endUtc));
    }
    final tripsList = await tripsQuery.get();

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
        'trip_id': e.tripId,
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
        'cross_confirmed': e.crossConfirmed,
        'fork_foot_lag_ms': e.forkFootLagMs,
        'hr_spike_confirmed': e.hrSpikeConfirmed,
        'hr_delta_at_event': e.hrDeltaAtEvent,
        'jerk_peak_magnitude': e.jerkPeakMagnitude,
        'gps_speed_at_event_kmh': e.gpsSpeedAtEventKmh,
        'gps_heading_change_deg': e.gpsHeadingChangeDeg,
        'parameters': parsedParams,
        'sensor_readings': readingsByEvent[e.id] ?? [],
        'camera_detections': detectionsByEvent[e.id] ?? [],
      };
    }).toList();

    // Top-level trip summaries mirroring File 3
    final tripIds = tripsList.map((t) => t.id).toSet();
    final calibrations = tripIds.isNotEmpty
        ? await (_db.select(_db.tripCalibrations)..where((c) => c.tripId.isIn(tripIds))).get()
        : <TripCalibration>[];
    final calMap = <int, TripCalibration>{for (final c in calibrations) c.tripId: c};

    final tripSummaries = tripsList.map((t) {
      final cal = calMap[t.id];
      return {
        'trip_id': t.id,
        'start_timestamp_utc': (t.startTimestampUtc ?? t.startTimeUtc).toIso8601String(),
        'end_timestamp_utc': (t.endTimestampUtc ?? t.endTimeUtc)?.toIso8601String(),
        'total_distance_km': t.totalDistanceKm,
        'total_duration_min': t.totalDurationMin,
        'avg_speed_kmh': t.avgSpeedKmh,
        'max_speed_kmh': t.maxSpeedKmh,
        'harsh_brake_count': t.harshBrakeCount,
        'harsh_accel_count': t.harshAccelCount,
        'harsh_turn_count': t.harshTurnCount,
        'bump_count': t.bumpCount,
        'confirmed_event_count': t.confirmedEventCount,
        'events_per_km': t.eventsPerKm,
        'avg_hr': t.avgHr,
        'max_hr': t.maxHr,
        'hr_spike_confirmed_ratio': t.hrSpikeConfirmedRatio,
        'night_driving_pct': t.nightDrivingPct,
        'driver_score': t.driverScore,
        'calibration_valid': cal?.calibrationValid ?? false,
        'engine_noise_freq_hz': cal?.engineNoiseFreqHz,
      };
    }).toList();

    final exportJson = <String, dynamic>{
      'export_version': '2.0',
      'export_generated_at_utc': now.toIso8601String(),
      'time_range': {
        'start_utc': startUtc?.toIso8601String(),
        'end_utc': endUtc?.toIso8601String(),
      },
      'export_mode': mode == ExportMode.eventsOnly ? 'events_only' : 'full_raw_session',
      'only_cross_confirmed': onlyCrossConfirmed,
      'trip_summary': tripSummaries.isNotEmpty ? tripSummaries.first : null,
      'trips': tripSummaries,
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
      'trip_id': r.tripId,
      'device_id': r.deviceId,
      'device_type': r.deviceType,
      'mount_location': r.mountLocation,
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

  // ──────────────────────────────────────────────────────────────────────────
  // FILE 1: sensor_timeseries_export.csv
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<String> buildSensorTimeseriesCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
    bool onlyCrossConfirmed = false,
  }) async {
    final events = await _fetchEventsInRange(startUtc, endUtc, onlyCrossConfirmed: onlyCrossConfirmed);
    final eventIds = events.map((e) => e.id).toSet();

    var query = _db.select(_db.sensorReadings);
    if (mode == ExportMode.eventsOnly) {
      if (eventIds.isEmpty) return _buildTimeseriesCsvHeader();
      query = query..where((t) => t.eventId.isIn(eventIds));
    }
    if (startUtc != null) {
      query = query..where((t) => t.timestampUtc.isBiggerOrEqualValue(startUtc));
    }
    if (endUtc != null) {
      query = query..where((t) => t.timestampUtc.isSmallerOrEqualValue(endUtc));
    }

    final readings = await (query
          ..orderBy([
            (t) => OrderingTerm(expression: t.timestampUtc, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc),
          ]))
        .get();

    // Fetch GPS fixes to forward-fill
    var locQuery = _db.select(_db.locationReadings);
    if (startUtc != null) {
      locQuery = locQuery..where((t) => t.timestampUtc.isBiggerOrEqualValue(startUtc.subtract(const Duration(seconds: 5))));
    }
    if (endUtc != null) {
      locQuery = locQuery..where((t) => t.timestampUtc.isSmallerOrEqualValue(endUtc.add(const Duration(seconds: 5))));
    }
    final gpsFixes = await (locQuery..orderBy([(t) => OrderingTerm(expression: t.timestampUtc)])).get();

    final buffer = StringBuffer();
    buffer.writeln(
      'timestamp_utc,trip_id,device_id,mount_location,sensor_type,event_id,'
      'heart_rate,hr_baseline,hr_delta,'
      'accel_x,accel_y,accel_z,accel_magnitude,'
      'gyro_x,gyro_y,gyro_z,'
      'jerk_x,jerk_y,jerk_z,jerk_magnitude,'
      'roll_angle_deg,yaw_rate_deg_s,'
      'latitude,longitude,gps_speed_kmh,gps_heading_deg,gps_accuracy_m,'
      'ppi_ms',
    );

    final recentHrs = <int>[];
    SensorReading? prevReading;
    int gpsSearchIdx = 0;

    for (final r in readings) {
      // HR baseline calculation
      if (r.heartRate != null && r.heartRate! > 30 && r.heartRate! < 220) {
        recentHrs.add(r.heartRate!);
        if (recentHrs.length > 60) recentHrs.removeAt(0);
      }
      final hrBaseline = recentHrs.isNotEmpty ? HrEventGate.computeBaseline(recentHrs) : null;
      final hrDelta = (r.heartRate != null && hrBaseline != null) ? (r.heartRate! - hrBaseline) : null;

      // Accel magnitude
      double? accelMag;
      if (r.accelX != null && r.accelY != null && r.accelZ != null) {
        accelMag = math.sqrt(r.accelX! * r.accelX! + r.accelY! * r.accelY! + r.accelZ! * r.accelZ!);
      }

      // Jerk
      double? jx, jy, jz, jMag;
      if (prevReading != null && prevReading.deviceId == r.deviceId) {
        final dt = r.timestampUtc.difference(prevReading.timestampUtc).inMilliseconds / 1000.0;
        if (dt > 0.005 && dt < 0.2) {
          if (r.accelX != null && prevReading.accelX != null) jx = (r.accelX! - prevReading.accelX!) / dt;
          if (r.accelY != null && prevReading.accelY != null) jy = (r.accelY! - prevReading.accelY!) / dt;
          if (r.accelZ != null && prevReading.accelZ != null) jz = (r.accelZ! - prevReading.accelZ!) / dt;
          if (jx != null && jy != null && jz != null) {
            jMag = math.sqrt(jx * jx + jy * jy + jz * jz);
          }
        }
      }

      // Roll & Yaw rate
      double? rollDeg;
      if (r.accelX != null && r.accelY != null && r.accelZ != null) {
        final rollRad = math.atan2(r.accelY!, math.sqrt(r.accelX! * r.accelX! + r.accelZ! * r.accelZ!));
        rollDeg = AngularUnits.radToDeg(rollRad);
      }
      final yawRateDegS = r.gyroZ != null ? AngularUnits.radToDeg(r.gyroZ!.abs()) : null;

      // Nearest GPS within 1.5s (1500ms) tolerance
      LocationReading? nearestGps;
      if (gpsFixes.isNotEmpty) {
        while (gpsSearchIdx < gpsFixes.length - 1 &&
            gpsFixes[gpsSearchIdx + 1].timestampUtc.isBefore(r.timestampUtc)) {
          gpsSearchIdx++;
        }
        final candidate1 = gpsFixes[gpsSearchIdx];
        final candidate2 = (gpsSearchIdx + 1 < gpsFixes.length) ? gpsFixes[gpsSearchIdx + 1] : candidate1;
        final diff1 = candidate1.timestampUtc.difference(r.timestampUtc).inMilliseconds.abs();
        final diff2 = candidate2.timestampUtc.difference(r.timestampUtc).inMilliseconds.abs();
        final best = diff1 <= diff2 ? candidate1 : candidate2;
        final bestDiff = diff1 <= diff2 ? diff1 : diff2;
        if (bestDiff <= 1500) {
          nearestGps = best;
        }
      }

      final row = [
        r.timestampUtc.toIso8601String(),
        r.tripId ?? '',
        _csvEscape(r.deviceId),
        _csvEscape(r.mountLocation),
        _csvEscape(r.sensorType),
        r.eventId ?? '',
        r.heartRate ?? '',
        hrBaseline?.toStringAsFixed(1) ?? '',
        hrDelta?.toStringAsFixed(1) ?? '',
        r.accelX?.toStringAsFixed(4) ?? '',
        r.accelY?.toStringAsFixed(4) ?? '',
        r.accelZ?.toStringAsFixed(4) ?? '',
        accelMag?.toStringAsFixed(4) ?? '',
        r.gyroX?.toStringAsFixed(4) ?? '',
        r.gyroY?.toStringAsFixed(4) ?? '',
        r.gyroZ?.toStringAsFixed(4) ?? '',
        jx?.toStringAsFixed(2) ?? '',
        jy?.toStringAsFixed(2) ?? '',
        jz?.toStringAsFixed(2) ?? '',
        jMag?.toStringAsFixed(2) ?? '',
        rollDeg?.toStringAsFixed(2) ?? '',
        yawRateDegS?.toStringAsFixed(2) ?? '',
        nearestGps?.latitude.toStringAsFixed(6) ?? '',
        nearestGps?.longitude.toStringAsFixed(6) ?? '',
        nearestGps?.gpsSpeedMps != null ? (nearestGps!.gpsSpeedMps! * 3.6).toStringAsFixed(1) : '',
        nearestGps?.gpsHeadingDeg?.toStringAsFixed(1) ?? '',
        nearestGps?.gpsAccuracyM?.toStringAsFixed(1) ?? '',
        r.ppiMs ?? '',
      ];

      buffer.writeln(row.join(','));
      prevReading = r;
    }

    return buffer.toString();
  }

  String _buildTimeseriesCsvHeader() {
    return 'timestamp_utc,trip_id,device_id,mount_location,sensor_type,event_id,'
        'heart_rate,hr_baseline,hr_delta,'
        'accel_x,accel_y,accel_z,accel_magnitude,'
        'gyro_x,gyro_y,gyro_z,'
        'jerk_x,jerk_y,jerk_z,jerk_magnitude,'
        'roll_angle_deg,yaw_rate_deg_s,'
        'latitude,longitude,gps_speed_kmh,gps_heading_deg,gps_accuracy_m,'
        'ppi_ms\n';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FILE 2: event_records_export.csv
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<String> buildEventRecordsCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    bool onlyCrossConfirmed = false,
  }) async {
    final events = await _fetchEventsInRange(startUtc, endUtc, onlyCrossConfirmed: onlyCrossConfirmed);

    final buffer = StringBuffer();
    buffer.writeln(
      'event_id,trip_id,event_type,trigger_phrase,'
      'start_timestamp_utc,end_timestamp_utc,duration_ms,'
      'mount_location_primary,'
      'peak_g_force,jerk_peak_magnitude,'
      'peak_yaw_rate_deg_s,max_lean_angle_deg,turn_direction,'
      'cross_confirmed,fork_foot_lag_ms,'
      'hr_spike_confirmed,hr_delta_at_event,'
      'gps_speed_at_event_kmh,gps_heading_change_deg,'
      'camera_linked,camera_event_class,camera_confidence,'
      'event_severity,event_confirmed',
    );

    for (final e in events) {
      final durationMs = e.endTimestamp != null
          ? e.endTimestamp!.difference(e.startTimestamp).inMilliseconds
          : 0;

      // Find camera detections linked to this event
      final detections = await (_db.select(_db.cameraDetections)..where((t) => t.linkedEventId.equals(e.id))).get();
      final hasCam = detections.isNotEmpty;
      final camClass = hasCam ? detections.first.eventClass : '';
      final camConf = hasCam ? detections.first.confidence.toStringAsFixed(3) : '';

      final isConfirmed = e.crossConfirmed && durationMs >= 80;

      EventParameters? params;
      if (e.computedParameters != null) {
        params = EventParameters.fromJsonString(e.computedParameters);
      }

      final peakG = params?.bump?.peakGForce ?? (e.peakMetric != null ? AngularUnits.accelToG(e.peakMetric!) : null);
      final jerk = e.jerkPeakMagnitude ?? params?.bump?.jerkPeakMagnitude ?? params?.speed?.jerkPeakMagnitude;
      final yawRate = params?.turn?.peakGyroDegPerSec;
      final lean = params?.turn?.maxLeanAngleDeg;
      final turnDir = params?.turn?.turnDirection ?? '';
      final severity = params?.bump?.severity ?? e.classification ?? 'normal';

      final row = [
        e.id,
        e.tripId ?? '',
        _csvEscape(e.eventType),
        _csvEscape(e.triggerPhrase ?? ''),
        e.startTimestamp.toIso8601String(),
        e.endTimestamp?.toIso8601String() ?? '',
        durationMs,
        'fork',
        peakG?.toStringAsFixed(2) ?? '',
        jerk?.toStringAsFixed(2) ?? '',
        yawRate?.toStringAsFixed(1) ?? '',
        lean?.toStringAsFixed(1) ?? '',
        _csvEscape(turnDir),
        e.crossConfirmed,
        e.forkFootLagMs?.toStringAsFixed(1) ?? '',
        e.hrSpikeConfirmed,
        e.hrDeltaAtEvent?.toStringAsFixed(1) ?? '',
        e.gpsSpeedAtEventKmh?.toStringAsFixed(1) ?? '',
        e.gpsHeadingChangeDeg?.toStringAsFixed(1) ?? '',
        hasCam,
        _csvEscape(camClass),
        camConf,
        _csvEscape(severity),
        isConfirmed,
      ];

      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FILE 3: trip_summary_export.csv
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<String> buildTripSummaryCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
  }) async {
    var query = _db.select(_db.trips);
    if (startUtc != null) {
      query = query..where((t) => t.startTimestampUtc.isBiggerOrEqualValue(startUtc));
    }
    if (endUtc != null) {
      query = query..where((t) => t.startTimestampUtc.isSmallerOrEqualValue(endUtc));
    }
    final tripsList = await (query..orderBy([(t) => OrderingTerm(expression: t.startTimestampUtc)])).get();

    final tripIds = tripsList.map((t) => t.id).toSet();
    final calibrations = tripIds.isNotEmpty
        ? await (_db.select(_db.tripCalibrations)..where((c) => c.tripId.isIn(tripIds))).get()
        : <TripCalibration>[];
    final calMap = <int, TripCalibration>{for (final c in calibrations) c.tripId: c};

    final buffer = StringBuffer();
    buffer.writeln(
      'trip_id,start_timestamp_utc,end_timestamp_utc,total_distance_km,total_duration_min,'
      'avg_speed_kmh,max_speed_kmh,'
      'harsh_brake_count,harsh_accel_count,harsh_turn_count,bump_count,'
      'confirmed_event_count,events_per_km,'
      'avg_hr,max_hr,hr_spike_confirmed_ratio,'
      'night_driving_pct,'
      'driver_score,'
      'calibration_valid,engine_noise_freq_hz',
    );

    for (final t in tripsList) {
      final cal = calMap[t.id];
      final row = [
        t.id,
        (t.startTimestampUtc ?? t.startTimeUtc).toIso8601String(),
        (t.endTimestampUtc ?? t.endTimeUtc)?.toIso8601String() ?? '',
        t.totalDistanceKm?.toStringAsFixed(3) ?? '',
        t.totalDurationMin?.toStringAsFixed(2) ?? '',
        t.avgSpeedKmh?.toStringAsFixed(1) ?? '',
        t.maxSpeedKmh?.toStringAsFixed(1) ?? '',
        t.harshBrakeCount,
        t.harshAccelCount,
        t.harshTurnCount,
        t.bumpCount,
        t.confirmedEventCount,
        t.eventsPerKm?.toStringAsFixed(2) ?? '',
        t.avgHr?.toStringAsFixed(1) ?? '',
        t.maxHr ?? '',
        t.hrSpikeConfirmedRatio?.toStringAsFixed(3) ?? '',
        t.nightDrivingPct?.toStringAsFixed(1) ?? '',
        t.driverScore?.toStringAsFixed(1) ?? '',
        cal?.calibrationValid ?? false,
        cal?.engineNoiseFreqHz != null ? cal!.engineNoiseFreqHz.toStringAsFixed(2) : '',
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Legacy & Per-Sensor CSV Exports
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<String> buildSensorCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
    String? deviceId,
    bool onlyCrossConfirmed = false,
  }) async {
    final events = await _fetchEventsInRange(startUtc, endUtc, onlyCrossConfirmed: onlyCrossConfirmed);
    final eventMap = <int, EventRecord>{for (var e in events) e.id: e};
    final eventIds = eventMap.keys.toSet();

    var query = _db.select(_db.sensorReadings);
    if (mode == ExportMode.eventsOnly) {
      if (eventIds.isEmpty) return _generateLegacyCsvFromReadings([], eventMap);
      query = query..where((t) => t.eventId.isIn(eventIds));
    }
    if (startUtc != null) {
      query = query..where((t) => t.timestampUtc.isBiggerOrEqualValue(startUtc));
    }
    if (endUtc != null) {
      query = query..where((t) => t.timestampUtc.isSmallerOrEqualValue(endUtc));
    }
    if (deviceId != null) {
      query = query..where((t) => t.deviceId.equals(deviceId));
    }

    final readings = await (query
          ..orderBy([
            (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.timestampUtc, mode: OrderingMode.asc),
          ]))
        .get();

    return _generateLegacyCsvFromReadings(readings, eventMap);
  }

  @override
  Future<Map<String, String>> buildPerSensorCsvExports({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
    bool onlyCrossConfirmed = false,
  }) async {
    final events = await _fetchEventsInRange(startUtc, endUtc, onlyCrossConfirmed: onlyCrossConfirmed);
    final eventMap = <int, EventRecord>{for (var e in events) e.id: e};
    final eventIds = eventMap.keys.toSet();

    var query = _db.select(_db.sensorReadings);
    if (mode == ExportMode.eventsOnly) {
      if (eventIds.isEmpty) return {};
      query = query..where((t) => t.eventId.isIn(eventIds));
    }
    if (startUtc != null) {
      query = query..where((t) => t.timestampUtc.isBiggerOrEqualValue(startUtc));
    }
    if (endUtc != null) {
      query = query..where((t) => t.timestampUtc.isSmallerOrEqualValue(endUtc));
    }

    final allReadings = await (query
          ..orderBy([
            (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.timestampUtc, mode: OrderingMode.asc),
          ]))
        .get();

    final readingsByDevice = <String, List<SensorReading>>{};
    for (final r in allReadings) {
      readingsByDevice.putIfAbsent(r.deviceId, () => []).add(r);
    }

    final result = <String, String>{};
    for (final entry in readingsByDevice.entries) {
      result[entry.key] = _generateLegacyCsvFromReadings(entry.value, eventMap);
    }

    return result;
  }

  String _generateLegacyCsvFromReadings(List<SensorReading> readings, Map<int, EventRecord> eventMap) {
    final buffer = StringBuffer();
    final localDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

    buffer.writeln(
      'reading_id,timestamp_iso8601,timestamp_local,timestamp_epoch_ms,sequence_no,device_id,device_type,mount_location,sensor_type,'
      'heart_rate_bpm,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,ppi_ms,'
      'trip_id,event_id,event_type,event_classification,event_peak_metric,cross_confirmed,param_summary',
    );

    for (final r in readings) {
      final evt = r.eventId != null ? eventMap[r.eventId] : null;
      final params = evt?.computedParameters != null
          ? EventParameters.fromJsonString(evt!.computedParameters)?.summary
          : '';

      final localFormatted = localDateFormat.format(r.timestampUtc.toLocal());
      final epochMs = r.timestampUtc.millisecondsSinceEpoch;

      final row = [
        r.id,
        r.timestampUtc.toIso8601String(),
        _csvEscape(localFormatted),
        epochMs,
        r.sequenceNo,
        _csvEscape(r.deviceId),
        _csvEscape(r.deviceType),
        _csvEscape(r.mountLocation),
        _csvEscape(r.sensorType),
        r.heartRate ?? '',
        r.accelX?.toStringAsFixed(4) ?? '',
        r.accelY?.toStringAsFixed(4) ?? '',
        r.accelZ?.toStringAsFixed(4) ?? '',
        r.gyroX?.toStringAsFixed(4) ?? '',
        r.gyroY?.toStringAsFixed(4) ?? '',
        r.gyroZ?.toStringAsFixed(4) ?? '',
        r.ppiMs ?? '',
        r.tripId ?? '',
        r.eventId ?? '',
        _csvEscape(evt?.eventType ?? ''),
        _csvEscape(evt?.classification ?? ''),
        evt?.peakMetric?.toStringAsFixed(2) ?? '',
        evt?.crossConfirmed ?? false,
        _csvEscape(params ?? ''),
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  @override
  Future<String> exportTripCsv(int tripId) async {
    final events = await (_db.select(_db.eventRecords)..where((t) => t.tripId.equals(tripId))).get();
    final eventMap = <int, EventRecord>{for (var e in events) e.id: e};

    final readings = await (_db.select(_db.sensorReadings)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.timestampUtc, mode: OrderingMode.asc),
          ]))
        .get();

    return _generateLegacyCsvWithBoundingBoxes(readings, eventMap, events);
  }

  /// Generates CSV with EVENT_START / EVENT_END marker rows injected at event boundaries.
  /// This gives ML preprocessing a clear bounding box for each labeled event.
  String _generateLegacyCsvWithBoundingBoxes(
    List<SensorReading> readings,
    Map<int, EventRecord> eventMap,
    List<EventRecord> events,
  ) {
    final buffer = StringBuffer();
    final localDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

    // Header — extra sentinel column `bbox_marker` at the end for easy filtering
    buffer.writeln(
      'reading_id,timestamp_iso8601,timestamp_local,timestamp_epoch_ms,sequence_no,device_id,device_type,mount_location,sensor_type,'
      'heart_rate_bpm,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,ppi_ms,'
      'trip_id,event_id,event_type,event_classification,event_peak_metric,cross_confirmed,param_summary,bbox_marker',
    );

    // Build a sorted list of event boundary timestamps for efficient insertion
    // We'll do a merge: walk readings in order and inject markers when we cross an event boundary
    final sortedEvents = List<EventRecord>.from(events)
      ..sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));

    // Track which events have had their START marker written
    final startWritten = <int>{};

    // Helper to write a sentinel marker row
    void writeMarker(String markerType, EventRecord evt) {
      final ts = markerType == 'EVENT_START' ? evt.startTimestamp : (evt.endTimestamp ?? evt.startTimestamp);
      final localFmt = localDateFormat.format(ts.toLocal());
      // Marker rows have all data columns empty except bbox_marker
      final cols = [
        '',                           // reading_id
        ts.toIso8601String(),         // timestamp_iso8601
        _csvEscape(localFmt),         // timestamp_local
        ts.millisecondsSinceEpoch,    // timestamp_epoch_ms
        '',                           // sequence_no
        '',                           // device_id
        '',                           // device_type
        '',                           // mount_location
        '',                           // sensor_type
        '', '', '', '', '', '', '', '', // sensor data columns
        evt.tripId ?? '',             // trip_id
        evt.id,                       // event_id
        _csvEscape(evt.eventType),    // event_type
        _csvEscape(evt.classification ?? ''), // event_classification
        evt.peakMetric?.toStringAsFixed(2) ?? '', // event_peak_metric
        evt.crossConfirmed ?? false,  // cross_confirmed
        '',                           // param_summary
        _csvEscape(markerType),       // bbox_marker
      ];
      buffer.writeln(cols.join(','));
    }

    // Walk through readings; inject event markers at boundaries
    for (final r in readings) {
      final rTime = r.timestampUtc;

      // Write EVENT_START for any event whose window begins at or before this reading
      for (final evt in sortedEvents) {
        if (!startWritten.contains(evt.id) && !rTime.isBefore(evt.startTimestamp)) {
          writeMarker('EVENT_START', evt);
          startWritten.add(evt.id);
        }
      }

      // Write the sensor reading row
      final evt = r.eventId != null ? eventMap[r.eventId] : null;
      final params = evt?.computedParameters != null
          ? EventParameters.fromJsonString(evt!.computedParameters)?.summary
          : '';
      final localFormatted = localDateFormat.format(r.timestampUtc.toLocal());
      final epochMs = r.timestampUtc.millisecondsSinceEpoch;

      final row = [
        r.id,
        r.timestampUtc.toIso8601String(),
        _csvEscape(localFormatted),
        epochMs,
        r.sequenceNo,
        _csvEscape(r.deviceId),
        _csvEscape(r.deviceType),
        _csvEscape(r.mountLocation),
        _csvEscape(r.sensorType),
        r.heartRate ?? '',
        r.accelX?.toStringAsFixed(4) ?? '',
        r.accelY?.toStringAsFixed(4) ?? '',
        r.accelZ?.toStringAsFixed(4) ?? '',
        r.gyroX?.toStringAsFixed(4) ?? '',
        r.gyroY?.toStringAsFixed(4) ?? '',
        r.gyroZ?.toStringAsFixed(4) ?? '',
        r.ppiMs ?? '',
        r.tripId ?? '',
        r.eventId ?? '',
        _csvEscape(evt?.eventType ?? ''),
        _csvEscape(evt?.classification ?? ''),
        evt?.peakMetric?.toStringAsFixed(2) ?? '',
        evt?.crossConfirmed ?? false,
        _csvEscape(params ?? ''),
        '',  // bbox_marker — empty for normal data rows
      ];
      buffer.writeln(row.join(','));

      // Write EVENT_END for events whose window closes at this reading's timestamp
      for (final e in sortedEvents) {
        if (startWritten.contains(e.id) && e.endTimestamp != null) {
          if (!rTime.isBefore(e.endTimestamp!)) {
            writeMarker('EVENT_END', e);
            sortedEvents.remove(e);
            break;  // Restart outer loop to avoid ConcurrentModificationError
          }
        }
      }
    }

    // Flush any remaining EVENT_END markers for events that outlasted all readings
    for (final evt in sortedEvents) {
      if (startWritten.contains(evt.id) && evt.endTimestamp != null) {
        writeMarker('EVENT_END', evt);
      }
    }

    return buffer.toString();
  }


  @override
  Future<Map<String, dynamic>> exportTripJson(int tripId) async {
    final trip = await (_db.select(_db.trips)..where((t) => t.id.equals(tripId))).getSingleOrNull();
    if (trip == null) return {'error': 'Trip not found', 'trip_id': tripId};

    final events = await (_db.select(_db.eventRecords)..where((t) => t.tripId.equals(tripId))).get();

    final readings = await (_db.select(_db.sensorReadings)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sequenceNo, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.timestampUtc, mode: OrderingMode.asc),
          ]))
        .get();

    final eventsJson = events.map((e) {
      Map<String, dynamic>? parsedParams;
      if (e.computedParameters != null) {
        try {
          parsedParams = jsonDecode(e.computedParameters!) as Map<String, dynamic>;
        } catch (_) {}
      }
      return {
        'event_id': e.id,
        'event_type': e.eventType,
        'status': e.status,
        'trigger_phrase': e.triggerPhrase,
        'start_timestamp_utc': e.startTimestamp.toIso8601String(),
        'end_timestamp_utc': e.endTimestamp?.toIso8601String(),
        'classification': e.classification,
        'peak_metric': e.peakMetric,
        'cross_confirmed': e.crossConfirmed,
        'fork_foot_lag_ms': e.forkFootLagMs,
        'hr_spike_confirmed': e.hrSpikeConfirmed,
        'hr_delta_at_event': e.hrDeltaAtEvent,
        'jerk_peak_magnitude': e.jerkPeakMagnitude,
        'gps_speed_at_event_kmh': e.gpsSpeedAtEventKmh,
        'gps_heading_change_deg': e.gpsHeadingChangeDeg,
        'parameters': parsedParams,
      };
    }).toList();

    List<dynamic> routePoints = [];
    if (trip.routeCoordinatesJson != null) {
      try {
        routePoints = jsonDecode(trip.routeCoordinatesJson!) as List<dynamic>;
      } catch (_) {}
    }

    final distanceMeters = trip.distanceMeters > 0
        ? trip.distanceMeters
        : (trip.totalDistanceKm != null ? trip.totalDistanceKm! * 1000 : trip.distanceMeters);
    final totalDistKm = trip.totalDistanceKm ?? (trip.distanceMeters / 1000.0);
    final totalDurMin = trip.totalDurationMin ?? (trip.durationSeconds / 60.0);

    final cal = await (_db.select(_db.tripCalibrations)
          ..where((c) => c.tripId.equals(tripId))
          ..limit(1))
        .getSingleOrNull();

    return {
      'trip_id': trip.id,
      'rider_name': trip.riderName,
      'start_timestamp_utc': (trip.startTimestampUtc ?? trip.startTimeUtc).toIso8601String(),
      'end_timestamp_utc': (trip.endTimestampUtc ?? trip.endTimeUtc)?.toIso8601String(),
      'duration_seconds': trip.durationSeconds,
      'distance_meters': distanceMeters,
      'total_distance_km': totalDistKm,
      'total_duration_min': totalDurMin,
      'avg_speed_kmh': trip.avgSpeedKmh,
      'peak_speed_kmh': trip.peakSpeedKmh ?? trip.maxSpeedKmh,
      'max_speed_kmh': trip.maxSpeedKmh ?? trip.peakSpeedKmh,
      'start_lat': trip.startLat,
      'start_lng': trip.startLng,
      'end_lat': trip.endLat,
      'end_lng': trip.endLng,
      'gps_route_breadcrumbs': routePoints,
      'harsh_brake_count': trip.harshBrakeCount,
      'harsh_accel_count': trip.harshAccelCount,
      'harsh_turn_count': trip.harshTurnCount,
      'bump_count': trip.bumpCount,
      'confirmed_event_count': trip.confirmedEventCount,
      'events_per_km': trip.eventsPerKm,
      'avg_hr': trip.avgHr,
      'max_hr': trip.maxHr,
      'hr_spike_confirmed_ratio': trip.hrSpikeConfirmedRatio,
      'night_driving_pct': trip.nightDrivingPct,
      'driver_score': trip.driverScore,
      'calibration_valid': cal?.calibrationValid ?? false,
      'engine_noise_freq_hz': cal?.engineNoiseFreqHz,
      'events': eventsJson,
      'sensor_readings': readings.map(_formatReading).toList(),
    };
  }

  @override
  Future<List<File>> generateTripExportFiles(int tripId, {required ExportFormat format}) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(docsDir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final createdFiles = <File>[];

    if (format == ExportFormat.json || format == ExportFormat.both) {
      final jsonMap = await exportTripJson(tripId);
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);
      final jsonFile = File(p.join(exportDir.path, 'trip_${tripId}_dataset_$timestampStr.json'));
      await jsonFile.writeAsString(jsonString);
      createdFiles.add(jsonFile);
    }

    if (format == ExportFormat.csv || format == ExportFormat.both) {
      final tripCsv = await exportTripCsv(tripId);
      final csvFile = File(p.join(exportDir.path, 'trip_${tripId}_sensor_telemetry_$timestampStr.csv'));
      await csvFile.writeAsString(tripCsv);
      createdFiles.add(csvFile);
    }

    return createdFiles;
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
    bool includePerSensorFiles = true,
    bool onlyCrossConfirmed = false,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(docsDir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final createdFiles = <File>[];

    // 1. JSON Export (with trip_summary and multi-sensor validation)
    if (format == ExportFormat.json || format == ExportFormat.both) {
      final jsonMap = await buildJsonExport(
        startUtc: startUtc,
        endUtc: endUtc,
        mode: mode,
        onlyCrossConfirmed: onlyCrossConfirmed,
      );
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);
      final jsonFile = File(p.join(exportDir.path, 'ride_dataset_ml_$timestampStr.json'));
      await jsonFile.writeAsString(jsonString);
      createdFiles.add(jsonFile);
    }

    // 2. The 3 Primary ML Dataset CSV Files
    if (format == ExportFormat.csv || format == ExportFormat.both) {
      // File 1: sensor_timeseries_export.csv
      final timeseriesCsv = await buildSensorTimeseriesCsvExport(
        startUtc: startUtc,
        endUtc: endUtc,
        mode: mode,
        onlyCrossConfirmed: onlyCrossConfirmed,
      );
      final timeseriesFile = File(p.join(exportDir.path, 'sensor_timeseries_export_$timestampStr.csv'));
      await timeseriesFile.writeAsString(timeseriesCsv);
      createdFiles.add(timeseriesFile);

      // File 2: event_records_export.csv
      final eventRecordsCsv = await buildEventRecordsCsvExport(
        startUtc: startUtc,
        endUtc: endUtc,
        onlyCrossConfirmed: onlyCrossConfirmed,
      );
      final eventRecordsFile = File(p.join(exportDir.path, 'event_records_export_$timestampStr.csv'));
      await eventRecordsFile.writeAsString(eventRecordsCsv);
      createdFiles.add(eventRecordsFile);

      // File 3: trip_summary_export.csv
      final tripSummaryCsv = await buildTripSummaryCsvExport(
        startUtc: startUtc,
        endUtc: endUtc,
      );
      final tripSummaryFile = File(p.join(exportDir.path, 'trip_summary_export_$timestampStr.csv'));
      await tripSummaryFile.writeAsString(tripSummaryCsv);
      createdFiles.add(tripSummaryFile);

      // Optional camera detections export
      final cameraCsv = await buildCameraCsvExport(startUtc: startUtc, endUtc: endUtc, mode: mode);
      if (cameraCsv.split('\n').length > 2) {
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
      text: 'Ride Sensor Capture - Driver Safety Score ML Dataset Export',
      subject: 'Driver Safety Score ML Export',
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
