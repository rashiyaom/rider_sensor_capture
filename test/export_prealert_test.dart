import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/export_repository_impl.dart';
import 'package:ride_sensor_capture/features/export/models/export_options.dart';

AppDatabase _makeTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

/// Counts CSV fields, honouring quoted values that contain commas.
int _countCsvFields(String line) {
  var count = 1;
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        i++; // escaped quote
        continue;
      }
      inQuotes = !inQuotes;
    } else if (ch == ',' && !inQuotes) {
      count++;
    }
  }
  return count;
}

void main() {
  late AppDatabase db;
  late ExportRepositoryImpl repo;

  setUp(() {
    db = _makeTestDb();
    repo = ExportRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedEvent() async {
    return db.into(db.eventRecords).insert(
          EventRecordsCompanion.insert(
            eventType: 'bump',
            startTimestamp: DateTime.utc(2026, 10, 20, 10, 0, 0),
            endTimestamp: drift.Value(DateTime.utc(2026, 10, 20, 10, 0, 4)),
            status: 'completed',
            triggerPhrase: drift.Value('start bump'),
            tripId: const drift.Value(1),
            computedParameters: drift.Value('{"bump":{"peakGForce":2.1}}'),
          ),
        );
  }

  Future<int> seedPreAlert({int? eventId}) {
    return db.into(db.preAlerts).insert(
          PreAlertsCompanion.insert(
            roadEventId: const drift.Value(1),
            tripId: const drift.Value(1),
            eventId: drift.Value(eventId),
            eventType: 'bump',
            latitude: 12.9716,
            longitude: 77.5946,
            distanceMeters: 400,
            speedKmh: 90,
            timeToEventSeconds: 16,
            recommendedSpeedKmh: 40,
            urgency: 'warning',
            spokenText: 'Speed bump ahead, 400 metres, 16 seconds. Reduce to 40.',
            alertedAtUtc: DateTime.utc(2026, 10, 20, 10, 0, 0),
          ),
        );
  }

  Future<int> seedFeedback({required int eventId, required int preAlertId}) {
    return db.into(db.eventFeedbacks).insert(
          EventFeedbacksCompanion.insert(
            eventId: drift.Value(eventId),
            tripId: const drift.Value(1),
            preAlertId: drift.Value(preAlertId),
            eventType: 'bump',
            prompt: 'How smooth was the bump?',
            responseText: 'Perfect timing, I had enough time to slow down.',
            responseSource: 'voice',
            alertEffectiveness: const drift.Value(0.88),
            alertTimingAdequacy: const drift.Value('adequate'),
            difficultyLevel: const drift.Value('mild'),
            riderSummary: const drift.Value('Rider slowed down comfortably.'),
            improvementSuggestion:
                const drift.Value('Keep the current warning window.'),
            analysisConfidence: const drift.Value(0.91),
            analyzedByLlm: const drift.Value(true),
            createdAtUtc: DateTime.utc(2026, 10, 20, 10, 0, 5),
            analyzedAtUtc: drift.Value(DateTime.utc(2026, 10, 20, 10, 0, 6)),
          ),
        );
  }

  group('buildPreAlertsCsvExport', () {
    test('writes a header and one row per spoken warning', () async {
      await seedPreAlert();

      final csv = await repo.buildPreAlertsCsvExport();
      final lines = csv.trim().split('\n');

      expect(lines, hasLength(2));
      expect(
        lines.first,
        startsWith('pre_alert_id,road_event_id,trip_id,event_id,event_type,'),
      );
      expect(lines.first, contains('distance_meters'));
      expect(lines.first, contains('time_to_event_seconds'));
      expect(lines.last, contains('bump'));
      expect(lines.last, contains('400.0'));
      expect(lines.last, contains('16.00'));
    });

    test('produces a header-only file when there are no warnings', () async {
      final csv = await repo.buildPreAlertsCsvExport();
      expect(csv.trim().split('\n'), hasLength(1));
    });

    test('every row has the same number of columns as the header', () async {
      await seedPreAlert();
      await seedPreAlert();

      final lines = (await repo.buildPreAlertsCsvExport()).trim().split('\n');
      final headerCount = _countCsvFields(lines.first);
      for (final line in lines.skip(1)) {
        expect(_countCsvFields(line), headerCount);
      }
    });

    test('quotes the spoken text so the row stays parseable', () async {
      await seedPreAlert();
      final lines = (await repo.buildPreAlertsCsvExport()).trim().split('\n');
      expect(lines.last, contains('"Speed bump ahead, 400 metres, 16 seconds. Reduce to 40."'));
    });
  });

  group('buildAlertEffectivenessCsvExport', () {
    test('joins the warning with the scored rider feedback', () async {
      final eventId = await seedEvent();
      final preAlertId = await seedPreAlert(eventId: eventId);
      await seedFeedback(eventId: eventId, preAlertId: preAlertId);

      final csv = await repo.buildAlertEffectivenessCsvExport();
      final lines = csv.trim().split('\n');

      expect(lines, hasLength(2));
      expect(lines.first, contains('alert_effectiveness'));
      expect(lines.first, contains('alert_timing_adequacy'));
      expect(lines.first, contains('improvement_suggestion'));
      expect(lines.last, contains('0.880'));
      expect(lines.last, contains('adequate'));
      expect(lines.last, contains('Perfect timing'));
    });

    test('emits a header-only file when nothing was recorded', () async {
      final csv = await repo.buildAlertEffectivenessCsvExport();
      expect(csv.trim().split('\n'), hasLength(1));
    });
  });

  group('buildAlertEffectivenessReport', () {
    test('returns the compiled report', () async {
      final eventId = await seedEvent();
      final preAlertId = await seedPreAlert(eventId: eventId);
      await seedFeedback(eventId: eventId, preAlertId: preAlertId);

      final report = await repo.buildAlertEffectivenessReport();
      expect(report.totalAlerts, 1);
      expect(report.averageEffectiveness, closeTo(0.88, 0.001));
      expect(report.entries.single.riderSummary,
          'Rider slowed down comfortably.');
    });
  });

  group('buildJsonExport — learning loop integration', () {
    test('embeds the pre-alert and the rider feedback in each event', () async {
      final eventId = await seedEvent();
      final preAlertId = await seedPreAlert(eventId: eventId);
      await seedFeedback(eventId: eventId, preAlertId: preAlertId);

      final json = await repo.buildJsonExport(mode: ExportMode.eventsOnly);
      final events = json['events'] as List;
      expect(events, hasLength(1));

      final event = events.first as Map<String, dynamic>;
      final preAlert = event['pre_alert'] as Map<String, dynamic>;
      expect(preAlert['distance_meters'], 400);
      expect(preAlert['time_to_event_seconds'], 16);
      expect(preAlert['spoken_text'], contains('Speed bump ahead'));

      final feedback = event['feedback'] as List;
      expect(feedback, hasLength(1));
      final fb = feedback.first as Map<String, dynamic>;
      expect(fb['alert_effectiveness'], 0.88);
      expect(fb['alert_timing_adequacy'], 'adequate');
      expect(fb['analyzed_by_llm'], true);
      expect(fb['response_source'], 'voice');
    });

    test('includes the top-level pre_alert_effectiveness report', () async {
      final eventId = await seedEvent();
      final preAlertId = await seedPreAlert(eventId: eventId);
      await seedFeedback(eventId: eventId, preAlertId: preAlertId);

      final json = await repo.buildJsonExport(mode: ExportMode.eventsOnly);
      final report = json['pre_alert_effectiveness'] as Map<String, dynamic>;
      expect(report['total_alerts'], 1);
      expect(report['alerts_with_feedback'], 1);
      expect(report['insights'], isA<List>());
    });

    test('bumped the export version to 2.1', () async {
      final json = await repo.buildJsonExport(mode: ExportMode.eventsOnly);
      expect(json['export_version'], '2.1');
    });
  });
}
