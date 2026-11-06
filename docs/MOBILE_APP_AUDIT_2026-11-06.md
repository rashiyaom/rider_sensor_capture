# Mobile app audit — 6 November 2026

> Repair update: the first repair batch addresses AUD-01–08. All six original reproduction tests now pass, and the full app suite passes 273 tests. See [repair progress and remaining limits](audit/REPAIR_PROGRESS.md). The findings and results below remain the original audit snapshot.

## Result

The requested ride conversation and review flow is now present, but the app is **not yet validated for dependable riding or trustworthy training data**. The most urgent remaining problems are timestamp precision, buffered-write integrity, warning delivery accounting, and background operation. A successful screen demonstration would not establish that these work correctly.

This report separates executable reproductions, source-confirmed gaps, and risks that require physical-device testing. The remaining findings are a repair backlog; they have not all been fixed. This is a bounded engineering audit, not a claim that every possible bug has been found.

## Scope and evidence

- Working tree based on Git commit `add02444acf9f834f638552b9288c3d3295ed633`, plus the integration changes and audit artifacts in this workspace.
- [Source inventory](audit/source_inventory.csv): 121 files, including 114 handwritten Dart files, native entry points, manifests, and build configuration. Generated database code was analyzed but excluded from the handwritten inventory. Hashes identify the inspected snapshot.
- Whole-project Flutter static analysis, the complete existing test suite, and focused source tracing through BLE → inference → detection → speech → confirmation → persistence → review → saved-location alerts → export.
- Manual inspection covered persistence/migrations, parsers, device/permission state, trip lifecycle, maps, event management, feedback/LLM integration, camera ingestion, export/features, and mobile configuration. Static analysis of a file is not the same as exercising every branch or visually testing its screen.
- No physical phone, watch, Polar band, helmet headset, road run, or iOS build was exercised. Native speech and recognition tests use platform mocks. Sensor accuracy, wind noise, screen-lock behavior, battery consumption, and real GPS latency remain unmeasured.

### Verification results

| Check | Result |
|---|---|
| `flutter test --no-pub --reporter expanded` | **258 passed, 2 failed**. Both failures are existing export-contract inconsistencies; see AUD-07. |
| Same two export test files in an isolated unchanged baseline snapshot | **2 passed, 2 failed**, with the same missing `reading_id` and remapped `forearm` assertions. |
| `flutter analyze --no-pub` | No errors; **17 findings: 9 warnings and 8 informational lints**. The command still exits nonzero. |
| Explicit audit acceptance tests | **6 reproduced failures**, intentionally kept outside the default `test/` suite. See AUD-01–06. |
| Android debug APK build | Failed in the local build environment: `xcrun` requested x86_64 `libxcrun`, but the installed Command Line Tools library contains arm64/arm64e. An APK from the audited source was not validated. |
| iOS/device/road acceptance | Not run. |

Evidence: [validation transcript](audit/validation.txt), [analyzer output](audit/analyze.txt), [diagnostic output](audit/reproductions.txt), [Android build output](audit/android_build.txt). The two default-suite failures must be resolved before describing the suite as green.

To reproduce the six open acceptance failures:

```sh
flutter test --no-pub --reporter expanded docs/audit/reproductions_test.dart
```

The tests use an in-memory database and synthetic samples; they do not alter the rider's stored data.

## Requested behavior now implemented

| Requirement | Current implementation and boundaries |
|---|---|
| Speech should finish | TTS waits for native completion and serializes messages; the hands-free coordinator pauses recognition during playback. Explicit stop cancels queued work. Hardware interruptions and missing callbacks still need testing. |
| Detect live sensor events | Inference receives raw BLE samples directly, ignores HR-only/invalid IMU packets, separates primary and secondary buffers, uses elapsed sample time for jerk, and handles rotated wrist impacts. The watcher records new episodes only during an active trip. Detection remains heuristic, not a validated learned model. |
| Ask yes/no, then feedback | A detected event can ask a type-specific question. Recognized yes asks “How was it?” and stores text. Recognized no marks it rejected and does not create a future hazard. An ambiguous answer gets one retry. |
| Preserve coordinates and replies | Review rows are created at detection with the then-available GPS coordinate, reply, feedback, and status. GPS missing/stale/poor at detection leaves the coordinate absent; it is not replaced by the later answer position. |
| End-trip review | The end-trip screen and trip detail show detections, coordinates, replies, and feedback. Explicit Save location enables future alerts; Discard leaves the review history but does not enable a new alert. Rejected rows cannot be saved through this action. |
| Speed-dependent warning | Default warning lead is approximately 10 seconds, extended when the braking-distance calculation requires more. At 80 km/h, 10 seconds is approximately 222 m; at 40 km/h it is approximately 111 m. Message distance is rounded and refreshed after queue delay. Target speed varies by event type and severity. These are configured advisory values, not validated road-safe speeds. |
| All-events page | Events → All events combines saved hazards, live reviews, and standalone records; supports search, filters, coordinate markers, type/coordinate/note editing, deletion, and pending-location saving. Remaining editing gaps are listed in AUD-23. |
| Consistent deletion/counts | Event deletion clears associated event links while retaining trip telemetry/photos. Linked saved hazards are removed through the combined library path. Counts use completed events. Pending/rejected records are excluded from the main event export selections. Whole-trip deletion still has gaps: AUD-20. |

Operational boundaries that matter:

- While one conversation is active, further detections are stored for end-trip review rather than queued as late questions. Upcoming-location warnings can cancel a pending answer. Therefore **every detection is not guaranteed a spoken question during a busy sequence**.
- “Total detected events” includes rejected and unanswered detections. Trip confirmed/completed-event totals are a different count. Discarding a future-alert location does not erase a previously confirmed occurrence.
- The map's current-position marker uses the existing location service. It does not independently acquire a fresh position when tracking is stopped.
- Automatic acceleration events are not stationary road hazards and cannot be saved as future location warnings without changing their classification.
- English confirmation keywords are supported. Speech recognition availability/offline operation and non-English replies are not yet validated.

## Priority definitions

- **P0:** can silently destroy data or invalidate fundamental measurement timing; fix before collecting research data.
- **P1:** can miss/misstate a ride warning, mislabel events, or materially distort results; fix before relying on the app during rides.
- **P2:** functionality, consistency, deployment, or scale gap; schedule explicitly and test before the relevant use.

## Open findings

### AUD-01 — P0 — Stored sample timestamps lose subsecond precision

**Evidence: reproduced.** [Sensor timestamp column](../lib/data/local_db/tables/sensor_readings_table.dart), [database](../lib/data/local_db/database.dart), and the native database round trip in the diagnostic test. Two readings 20 ms apart return with a **0 ms** difference. Current Drift DateTime persistence stores the timestamps at second precision in this configuration.

**Impact:** a nominal 50 Hz recording can contain many identical timestamps. Time derivatives, event boundaries, GPS joins, exported sample times, and cross-device alignment can be wrong. In-memory live inference is a different path and retaining a device monotonic field does not automatically repair exported UTC timestamps.

**Repair:** introduce explicit integer epoch microseconds/milliseconds for high-frequency timestamps, migrate existing records with a documented precision limitation, and update all joins/exports. Historical lost precision cannot simply be reconstructed. **Acceptance:** 20 ms and irregular intervals survive a disk round trip and migration; event-boundary and GPS-join tests use subsecond cases.

### AUD-02 — P1 — Buffered readings take the event/trip at flush time

**Evidence: reproduced.** [SensorRepositoryImpl](../lib/data/repositories/sensor_repository_impl.dart), `insertReading`, `insertReadingsBatch`, `_flushBuffer`. The buffer holds only raw readings. Event/trip IDs are read later when building database companions. A sample received during event 10 is stored as event **11** if the event changes before flushing.

**Impact:** event starts/stops and journey boundaries move labels onto the wrong samples. Manual stop clears the active event before the tail of the buffer is safely associated with it.

**Repair:** buffer an immutable sample envelope with event ID, trip ID, and arrival context. **Acceptance:** back-to-back events, end-trip/start-trip, and timed/size-triggered flushes preserve each sample's original association.

### AUD-03 — P0 — A failed flush permanently loses its batch

**Evidence: reproduced.** Same repository: `_buffer.clear()` runs before the database insert succeeds. Sequence/count fields are also advanced before commit. A temporary SQLite trigger that rejects an insert, followed by removing the trigger and retrying, leaves **zero** rows instead of one.

**Impact:** storage failures lose samples, counters can imply successful recording, and timer-triggered asynchronous failures have no durable retry path. Concurrent flushes are also not serialized; flushing the current buffer does not necessarily await an earlier in-flight batch.

**Repair:** serialize drains, retain failed batches, update committed counters after success, surface storage failure to session health, and await all outstanding writes at trip end. **Acceptance:** failure/retry, concurrent threshold/timer flush, shutdown mid-write, and disk-full tests show neither duplicates nor lost rows.

### AUD-04 — P1 — Feature window length changes with device count

**Evidence: reproduced.** [WindowedFeatureExtractorService](../lib/data/services/windowed_feature_extractor_service.dart), `extractWindows`, slices 75 rows for a 1.5 s / 50 Hz window before separating devices. With two 50 Hz devices interleaved, the first window spans **0.74 s**. HR rows can further change the effective duration.

**Impact:** training features depend on how many devices are connected. Fixed-rate FFT/jerk assumptions also fail with decimated or irregular samples.

**Repair:** define windows by time, partition/synchronize streams by device, and resample or explicitly handle actual sample cadence. **Acceptance:** equivalent motion with one/two IMUs and additional HR packets produces the same physical window boundaries.

### AUD-05 — P1 — Nullable manual-event state cannot be cleared

**Evidence: reproduced.** [EventRecordingSessionState.copyWith](../lib/features/events/event_recording_controller.dart) uses `newValue ?? oldValue` for nullable GPS, trip, and event fields. Clearing a prior `tripId: 7` with `tripId: null` returns **7**.

**Impact:** starting the next manual event without a trip/GPS can retain prior UI/session context. This is distinct from the new live-detection coordinate snapshot, which stores the supplied fix directly.

**Repair:** use an explicit omitted-value sentinel or create a fresh recording state at event boundaries. **Acceptance:** successful GPS followed by GPS failure clears old coordinates; starting outside a trip does not inherit a previous trip.

### AUD-06 — P1 — Train/validation/test splits overlap raw samples

**Evidence: reproduced.** [WindowedFeatureExtractorService](../lib/data/services/windowed_feature_extractor_service.dart) assigns split labels after generating overlapping windows. In the diagnostic fixture, the last training window ends at row **275**, and validation begins at row **226**: 50 shared rows.

**Impact:** held-out results can be optimistic because test/validation windows contain data already present in training. Adjacent windows from the same ride also have strong dependence.

**Repair:** split by held-out trip/rider/session before window extraction; use an appropriate temporal exclusion gap if splitting a single stream. **Acceptance:** no raw sample identity crosses splits; evaluation includes unseen rides/riders as appropriate.

### AUD-07 — P1 — Export schema and existing consumers/tests disagree

**Evidence: reproduced in the default suite and unchanged baseline.** [E2E test](../test/e2e_trip_lifecycle_pipeline_test.dart) expects `reading_id` in the time-series CSV; it is absent. [Smartwatch/Verity test](../test/smartwatch_verity_full_cycle_test.dart) expects `forearm`; the exporter emits `heart_rate_band`. [Exporter](../lib/data/repositories/export_repository_impl.dart) also maps vehicle mounts into wrist aliases in flattened CSV paths.

**Impact:** downstream consumers cannot safely assume stable identifiers or original mounting metadata. The failure establishes a contract mismatch; it does not by itself establish that every export format is unusable.

**Repair:** agree and version one canonical schema, retain device/sample identifiers and original mount separately from aliases, and update consumers/tests together. **Acceptance:** the two tests pass because the agreed data is preserved, not merely because assertions are removed; multi-device joins round-trip correctly.

### AUD-08 — P1 — Bump peak fallback can convert g to g again

**Evidence: source-confirmed.** [Manual event controller](../lib/features/events/event_recording_controller.dart) stores a bump's `peakGForce` in `peakMetric`; live bump capture now also stores g. [Exporter](../lib/data/repositories/export_repository_impl.dart), event-table `peakG` fallback, calls `AngularUnits.accelToG(e.peakMetric!)` when computed bump parameters are absent.

**Impact:** the fallback underreports a g-valued bump peak by approximately 9.81, including live events without full parameter objects.

**Repair:** make units explicit in storage/schema and remove ambiguous fallback conversion. **Acceptance:** the same known bump has the same peak in the UI, JSON, and every CSV with/without computed parameters.

### AUD-09 — P1 — Background ride continuity and recovery are not implemented end to end

**Evidence: source-confirmed configuration gap; device impact unmeasured.** [Android manifest](../android/app/src/main/AndroidManifest.xml) declares service/wake-lock permissions, but the app-owned code contains no recording foreground service or wake-lock lifecycle. [iOS plist](../ios/Runner/Info.plist) has usage descriptions but no background modes. Trip controller state is in memory; startup does not reconcile an interrupted active trip.

**Impact:** declaring permissions is not proof that BLE, GPS, inference, or audio will continue after screen lock, suspension, or process death. Interrupted trips can remain open without a recovery workflow.

**Repair:** implement platform-supported recording lifetime, visible recording status, checkpoints, and interrupted-trip recovery. **Acceptance:** physical-device lock/background/battery-saver tests and process-kill/relaunch tests account for all retained and lost samples honestly.

### AUD-10 — P1 — GPS validity and availability are inconsistent across subsystems

**Evidence: source-confirmed.** [Trip controller](../lib/features/trips/trip_controller.dart), `_startGpsTracking`, adds distances between successive fixes and tracks peak speed without a comprehensive accuracy/outlier gate. [PreAlertService.start](../lib/prealert/pre_alert_service.dart) marks running and launches tracking without handling its false result. [LocationService](../lib/location/location_service.dart) swallows stream errors, and its `intervalMs` argument is unused. Trip telemetry and pre-alerts own separate location subscriptions. Pre-alert evaluation does not reject fixes solely for age.

**Impact:** GPS jumps inflate distance/speed/score; warnings may appear enabled with no usable GPS; map, trip, and warning state can disagree. Removing the old stream-wide 10 s timeout helps recovery but does not solve these gaps.

**Repair:** one shared location pipeline with freshness, accuracy, finite-value and plausible-motion checks, explicit service/error state, and recovery. **Acceptance:** permission denial, stale fixes, tunnels, jumps, stationary drift, and recovery produce consistent visible status and metrics.

### AUD-11 — P1 — Warning logs/cooldown do not mean audio was delivered

**Evidence: source-confirmed.** [PreAlertService](../lib/prealert/pre_alert_service.dart), `_onFix`/`issueAlert`, suppresses a hazard and persists `spokenText` before an unawaited speech action has reported success. A queued warning may be cancelled or skipped after passing its coordinate, but its log/counter remains. Rapid warnings can invalidate earlier queued hands-free actions. [VoiceAlertService](../lib/voice/voice_alert_service.dart) has stop/error handling, but no watchdog if the native engine supplies neither completion nor error.

**Impact:** reports can claim a warning was spoken when it was not; the same hazard can remain suppressed for the cooldown. A hung native utterance can hold the queue.

**Repair:** distinguish scheduled/started/completed/cancelled/failed delivery states; acknowledge playback; schedule urgent hazards with expiry and bounded playback waits. **Acceptance:** failed TTS, competing hazards, phone-call interruption, expired queued warnings, and missing callbacks yield accurate logs and recoverable audio.

### AUD-12 — P1 — Near a coordinate is not necessarily on the hazard's road

**Evidence: source-confirmed algorithm limitation.** [PreAlertEngine](../lib/prealert/pre_alert_engine.dart) uses distance and a heading cone, not road matching. Missing heading assumes travel toward the hazard. Speed advice uses event-type/severity defaults and fixed braking assumptions.

**Impact:** parallel/opposite roads and stacked roads can trigger irrelevant warnings; curved approaches can be missed. A nominal 10 s lead is affected by GPS cadence, acceleration, and speech queue time.

**Repair:** add approach-direction/road metadata or route matching and validate advice against intended vehicle/use conditions. **Acceptance:** replay straight, curved, opposite-direction, parallel-road, repeated-pass, stop-and-go, and missing-heading approaches; measure actual spoken lead time.

### AUD-13 — P1 — Detection scores are uncalibrated rules, with mounting limitations

**Evidence: source-confirmed.** [LiveMlInferenceService](../lib/data/services/live_ml_inference_service.dart) uses thresholds and hand-assigned confidence expressions despite “ensemble”/ML comments. No runtime caller wires [idle calibration](../lib/data/services/idle_calibration_service.dart) into this classification path. Wrist braking/acceleration are deliberately disabled to avoid posture-based false detections; turns and shocks still need measured thresholds. Secondary correlation is descriptive, not a required corroboration gate; more than two devices share the secondary buffer.

**Impact:** a confidence of 0.9 is not evidence of 90% real-world accuracy. Arm motion, road vibration, sensor placement and vehicle differences can change false positives/negatives. A large shock is not enough to distinguish pothole from bump. The 600 ms normal rearm plus 3 s dedupe can merge closely spaced hazards.

**Repair:** establish supported mounts/protocols and collect independently labeled replay data; measure confusion matrices and detection latency by mount/event. **Acceptance:** blinded replay across ordinary gestures, braking, turns, bumps and closely spaced events. Do not present rule scores as calibrated probability.

### AUD-14 — P1 — Legacy IMU units and derived attitude can distort signals

**Evidence: source-confirmed.** [ESP32 parser](../lib/ble/parsers/esp32_watch_parser.dart) guesses legacy acceleration units using squared magnitude between 0.1 and 16. A legacy g-valued shock outside that range is treated differently from lower-amplitude readings. Quaternion and gravity-free acceleration are derived from the instantaneous accelerometer vector, not an independent fused attitude estimate. Receive UTC time is used alongside device uptime; cross-device clock alignment is not thereby established.

**Impact:** amplitude can change units within a stream; dynamic acceleration affects the gravity estimate; timing and cross-device comparison can be misleading.

**Repair:** version the wire protocol with explicit units and clock semantics, distinguish measured from estimated channels, and use validated orientation/clock alignment. **Acceptance:** known physical vectors across the unit threshold, dynamic motion, packet jitter and device restart maintain consistent units and time.

### AUD-15 — P1 — Polar raw-frame handling is incomplete

**Evidence: source-confirmed; real-device payload validation pending.** [PolarVerityParser.parsePmdAccel](../lib/ble/parsers/polar_verity_parser.dart) reads one XYZ tuple from fixed offsets and returns one sample; it does not iterate an array of samples, decode a timestamp, or branch on frame subtype. Heart-rate parsing handles the HR-width and RR-present bits but does not advance past any other optional fields.

**Impact:** supported payload variants may drop samples or decode the wrong offset. Current synthetic dual-device tests do not validate a complete captured PMD notification stream.

**Repair:** validate against the actual enabled device protocol and captured fixtures; reject unsupported formats explicitly and emit all samples with proper timestamps. **Acceptance:** multi-sample notifications, optional HR fields, malformed packets, frame variants and measured sample rates.

### AUD-16 — P1 — BLE-to-database bridge lifecycle threatens rate control

**Evidence: source-level risk requiring a provider integration reproduction.** [bleToDbBridgeProvider](../lib/providers/db_providers.dart) watches a changing packet provider and registers an `onDispose` callback clearing its shared decimation map. Recomputations can reset the state intended to span packets; changes to recording/mount settings also reprocess the latest async packet. Inserts are not awaited and UI counters increment immediately.

**Impact:** the selected sample interval may not match stored data, a last packet can be processed again during settings changes, and visible counts need not represent committed rows.

**Repair:** use an owned stream subscription with per-device state and explicit commit/error accounting. **Acceptance:** deliver a timed burst while changing settings/recording state; compare input identities, committed row IDs and counts. This path needs a direct provider test before quantifying loss or duplication.

### AUD-17 — P1 — Health indicators can miss stalled capture

**Evidence: source-confirmed.** [BLE manager](../lib/ble/services/ble_connection_manager.dart) checks a data gap only once `lastPacketTime` exists; a connected device that never sends a packet can remain good. “Poor” is set after 15 s, while [SessionHealthService](../lib/core/services/session_health_service.dart) tells the user “>6s”. Dismissed alert IDs remain suppressed until explicitly reset. GPS health checks manual-event start GPS, not continuous trip fix freshness; database and recognition failures are not covered.

**Impact:** the interface can appear healthy while a sensor never started, or after a previously dismissed condition recurs.

**Repair:** track connected-at/last-packet times, recover/rearm alert episodes, and include storage/GPS/audio readiness. **Acceptance:** never-first-packet, recurring disconnect, stale GPS, denied mic and storage failure are visible with accurate timing.

### AUD-18 — P1 — Speech readiness and old voice-command UI are incomplete

**Evidence: source-confirmed plus hardware testing gap.** [HandsfreeSessionService](../lib/voice/handsfree_session_service.dart) exposes `isAvailable` from TTS even if STT initialization failed. [VoiceCommandListener](../lib/voice/voice_command_listener.dart) and its command stream have no runtime instantiation/consumer in `lib`; continuous hands-free recognition does not dispatch those legacy tagging commands. [FeedbackTranscriber](../lib/feedback/feedback_transcriber.dart) separately owns speech recognition, so manually opening feedback during a ride still needs coordination. Confirmation matching is lexical English, with any recognized negative keyword winning.

**Impact:** the app may speak but never hear yes/no; legacy “voice tagging ready” language overstates functionality. Negated/corrected phrases can be misread. Mocked speech success does not validate Bluetooth audio routing or offline recognition.

**Repair:** expose TTS/mic/STT readiness separately, unify microphone ownership, and either wire or remove legacy command affordances. **Acceptance:** denied/revoked permissions, STT unavailable, headset connect/disconnect, no network, noise, corrected replies, and concurrent feedback entry.

### AUD-19 — P1 — Event-to-warning matching can attach unrelated feedback

**Evidence: source-confirmed.** [PreAlertService.findMostRecentPreAlert/linkEventToPreAlert](../lib/prealert/pre_alert_service.dart) can choose the latest warning within 10 minutes without requiring matching event type/location or an unused link. A later event can overwrite that warning's event association. When no active/effective trip ID is available, the lookup is not trip-scoped.

**Impact:** effectiveness reports can evaluate the wrong warning, and LLM feedback can use unrelated approach metrics.

**Repair:** match by trip, expected hazard identity, position, time and type; preserve immutable associations or explicit one-to-many semantics. **Acceptance:** nearby hazards and successive events cannot steal one another's warnings.

### AUD-20 — P1 — Whole-trip deletion leaves dependent data behind

**Evidence: source-confirmed.** [SensorRepositoryImpl.deleteTrip](../lib/data/repositories/sensor_repository_impl.dart) deletes selected tables sequentially, including live reviews, but not all feedback/pre-alert/camera/unknown-event associations or owned files. [Native database setup](../lib/data/local_db/connection/native.dart) does not enable foreign-key enforcement. There is no encompassing delete transaction in this method.

**Impact:** orphaned rows/files, stale references, partial deletion on failure, and saved hazards still pointing at a deleted trip. Individual event deletion has better cleanup but does not fix this path.

**Repair:** define whether independently saved hazards survive, detach those deliberately, delete owned rows/files with recoverable transaction semantics, and enforce references after cleaning legacy data. **Acceptance:** full populated-trip deletion, interruption/failure, active-trip protection and post-delete export leave no invalid references.

### AUD-21 — P2 — Downloaded offline tiles are not connected to map rendering

**Evidence: source-confirmed.** [MapOfflineCacheService](../lib/core/services/map_offline_cache_service.dart) writes `z_x_y.png` files and caps downloading at 120 tiles. [Live map](../lib/features/dashboard/presentation/live_map_widget.dart) and [event map](../lib/features/live_events/event_library_screen.dart) use network tile layers without a provider reading those files.

**Impact:** a successful cache download does not prove the displayed map will work offline, and progress may represent only the capped subset of the requested region.

**Repair:** wire a compatible tile provider and show actual region/zoom coverage. **Acceptance:** download a region, cold-start without network, pan/zoom throughout it, and distinguish cached from missing areas.

### AUD-22 — P1 — Hazard imports can introduce invalid or synthetic live hazards

**Evidence: source-confirmed.** [BulkImportHazardsSheet](../lib/features/prealert/presentation/bulk_import_hazards_sheet.dart) parses numeric CSV coordinates without finite/range validation; [RoadEventRegistry.register](../lib/prealert/road_event_registry.dart) also does not enforce it. The benchmark preset silently falls back to fixed Mumbai coordinates on GPS failure and reports hazards “near your GPS position”. These synthetic points use the same seeded source consumed by real warnings. Inserts are individual, so failure can leave a partial import.

**Impact:** invalid points, partial imports, or fictional benchmark hazards can enter the real warning library. Unknown type strings silently become unknown hazards.

**Repair:** validate centrally; preview imports with row errors and duplicate detection; keep benchmark fixtures in a separate simulation dataset; never claim GPS success after fallback. **Acceptance:** invalid ranges/NaN, missing GPS, partial failure, duplicate import, and leaving simulation cannot contaminate real alerts.

### AUD-23 — P2 — Event editing is not yet fully flexible or consistent

**Evidence: source-confirmed in the current implementation.** [EventLibraryRepository](../lib/features/live_events/event_library_repository.dart), `ManagedEvent.combine`/`edit`, displays a standalone record's trigger phrase as its feedback. Editing feedback updates existing `eventFeedbacks` rows but does not create one if none exists, and the combined list does not load those rows for standalone events. All feedback rows for an event are updated together. Type changes do not invalidate previously computed parameters/classification. [Library UI](../lib/features/live_events/event_library_screen.dart) has no severity editor, drag-to-move marker, or confirmation correction control.

**Impact:** older standalone-event note edits can appear saved but be lost; changing a bump into a turn can leave bump-derived metrics. New live-review notes and seeded-road notes have direct storage, so this is not a failure of every edit path. “Full flexibility” remains partly unmet.

**Repair:** one canonical editable event view with explicit note storage/upsert, versioned feedback history, metadata invalidation on type change, and supported severity/confirmation/location controls. **Acceptance:** seeded, standalone and live events all retain edits after reload and export, including first feedback and type changes. Define whether rejected events may be manually reconsidered.

### AUD-24 — P2 — Feedback is stored/analyzed, but does not tune warning policy

**Evidence: source-confirmed integration limitation.** [FeedbackAnalyzer](../lib/llm/feedback_analyzer.dart) and feedback reports do not update the live pre-alert engine's policy. The new live-review path stores the rider's text without running the older LLM scoring flow. [GroqConfig](../lib/llm/groq_client.dart) takes a compile-time API key that would be distributed in the client when configured.

**Impact:** “learning” should not imply adaptive speed/lead-time advice. A distributed client credential is recoverable from the app; free-text feedback sent for analysis also requires clear data-handling behavior.

**Repair:** distinguish capture, evaluation and any validated policy change; keep service credentials server-side for distributed builds and make network analysis explicit. **Acceptance:** no bundled service credential, clear offline behavior, and traceable/versioned changes if adaptation is introduced. No external API was called during this audit.

### AUD-25 — P1 when enabled — Camera ingestion trusts any reachable sender

**Evidence: source-confirmed.** [CameraIngestServer](../lib/camera/camera_ingest_server.dart) binds all IPv4 interfaces, accepts unauthed POSTs, and reads the entire body before validation without an app-level size/rate limit. [CameraDetectionRepository](../lib/camera/camera_detection_repository.dart) immediately links to the active event regardless of payload timestamp; fallback matching is time-based without trip identity.

**Impact:** another reachable network participant can inject records or consume storage; delayed/wrong-clock camera messages can contaminate event labels.

**Repair:** pair/authenticate senders, bound bodies/rates, validate timestamps/device identity, and match camera/event clocks within the correct trip. **Acceptance:** unauthorized, replayed, oversized, delayed and wrong-trip payloads are rejected or quarantined. This audit did not send traffic to a real device.

### AUD-26 — P2 — Long-ride/history performance needs a measured budget

**Evidence: source-level scale risk, not a measured performance failure.** [Event library](../lib/features/live_events/event_library_screen.dart) loads full histories and constructs all list cards/markers. Several [export paths](../lib/data/repositories/export_repository_impl.dart) materialize complete reading collections and build large strings/features in process. The navigation shell retains multiple screens.

**Impact:** long rides or large histories may cause memory pressure, slow exports, UI stalls and battery drain. Small unit fixtures do not measure these effects.

**Repair:** profile representative low-end phones; paginate lists, bound map points, stream exports and move heavy feature work off UI execution where needed. **Acceptance:** 1–3 hour multi-sensor captures and large histories meet measured memory, latency and battery targets without sample loss.

### AUD-27 — P2 — Distribution/build readiness is incomplete

**Evidence: source-confirmed plus failed local build.** [Android build configuration](../android/app/build.gradle.kts) signs release with debug keys and retains `com.example.ride_sensor_capture`. The current Mac toolchain mismatch prevents completing the Android build verification; SDK/plugin compatibility warnings also appear in its log. iOS deployment was not tested.

**Repair:** repair the local toolchain architecture consistently, establish reproducible Android/iOS builds, then configure owned app identity and release signing. **Acceptance:** install the actual release candidate on supported devices and repeat the ride acceptance matrix. No toolchain installation or signing changes were made in this audit.

## Recommended repair order

1. **AUD-01–03:** preserve sample timing, correct event/trip ownership and make writes reliable. These determine whether future data is usable. Promote each diagnostic into the normal suite when fixed.
2. **AUD-09–11, 17–18:** continuous recording, GPS readiness and truthful warning/microphone health. Verify on physical phones before road reliance.
3. **AUD-05, 19–20, 22–23:** consistent event lifecycle, editable history and clean hazard data.
4. **AUD-04, 06–08, 13–16:** trustworthy feature/export pipeline, protocol fixtures and measured detector quality.
5. **AUD-12, 21, 24–27:** route relevance, offline UX, feedback architecture, camera hardening, scale and release readiness.

For each repair: agree the expected behavior, reproduce the defect, fix the smallest coherent path, run its regression and relevant integration tests, update this report, then move to the next issue. Avoid broad threshold tuning before fixing timing and label integrity.

## Physical-device acceptance matrix

Run controlled replay/bench checks first. Have a passenger/test operator observe any moving-vehicle tests; the rider should not operate the interface.

| Scenario | Required observation |
|---|---|
| Start with valid sensors/GPS/mic | All required services show actual readiness; first packet/fix/playback times are recorded. |
| Bump → yes → “okayish and bumpy” | One detection at the original coordinate; full question; mic opens after speech; reply/feedback persist. |
| Bump → no | Rejected history retained; no future road alert created. |
| Silence/ambiguous reply/no STT | No false yes/no; review available later; visible recognition state. |
| Closely spaced events and an upcoming saved hazard | Warning priority, stored unasked detections and cancellation status are explicit; no clipped competing speech. |
| End trip during speech/recognition/write | No late writes into another trip; all in-flight work settles; review loads persisted rows. |
| Save/discard/restart | Only explicitly saved locations alert on a later trip; replies/feedback survive restart. |
| Edit/delete seeded, live and standalone records | Map, review, counts, warning registry and exports agree after reload. |
| 40/80 km/h synthetic GPS approaches | Trigger distance scales with speed; spoken distance and actual playback lead are logged. Use replay rather than requiring these road speeds. |
| Parallel/opposite road, curve, stopped GPS | Relevant warning behavior with no fabricated direction or stale-position claims. |
| Screen locked/backgrounded/call/headset change | Measure BLE/GPS/audio continuity and recovery, including native completion failures. |
| Disconnect/reconnect watch; no first packet | Health status changes and rearms; no timing/unit jump or silent loss. |
| GPS off/tunnel/permission revoked | Clear degraded state; capture retains missing-location status; tracking recovers. |
| Offline cold start | Explicit map coverage and speech availability; pending feedback is not silently lost. |
| Database rejection/disk full/process kill | Recoverable recording state and honest committed counts; no silent success. |
| Long capture with two IMUs, HR and camera | Measured actual rates, timestamp precision, event ownership, memory and battery; compare transmitted versus committed identities. |

The current code and passing tests establish progress on the requested workflow. They do not establish that the entire mobile system is reliable under these conditions.
