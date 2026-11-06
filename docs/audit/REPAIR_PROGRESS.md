# Sequential repair progress

This file records changes after the original audit. The audit remains the original evidence snapshot.

## AUD-01 — timestamp precision

Implementation: schema 16 stores all Drift DateTime columns as ISO-8601 text, preserving fractional seconds consistently for sensor, GPS, event and camera timestamps. Upgrade rebuilds date-bearing tables and converts legacy Unix seconds to UTC text, retaining IDs, associations and nulls. Old lost precision cannot be recovered. This uses Drift's supported date representation rather than custom integer columns, retaining the existing typed query API.

Validation: 18 targeted tests passed, including disk reopen/microsecond round trip, actual legacy integer migration, subsecond export filtering, GPS joining, live reviews and pre-alert exports. Full suite: 260 passed; only the two known AUD-07 export failures remain. No new failures.

Regression: `test/timestamp_precision_test.dart`.

## AUD-02 — buffered event/trip ownership — repaired

Every buffered sample captures an immutable event/trip association at arrival, including direct batches before asynchronous work. Seven ownership/repository/lifecycle tests passed before moving to the next repair. `test/buffer_integrity_test.dart` covers transitions between events, trips and unassociated samples.

## AUD-03 — write failure and flush barriers — repaired for a running process

Writes are serialized and transactional. Failed batches remain queued with their original associations; sequence numbers and persisted row/device counters advance only after commit. Retry does not duplicate successful rows. Flush drains arrivals during the write as well as the initial batch. Timer failures are handled and published through write statistics; session health shows a critical storage alert. Trip completion no longer swallows a failed flush: recording pauses and End journey can retry it.

Validation: rollback on the second row of a batch; counters remain zero after failure; recovery writes all samples exactly once; 100 concurrent direct inserts/flush calls; paused recording retries stop. Five focused tests pass, plus the repository/lifecycle regressions. Pending samples are in memory: process death or exhausting memory during a prolonged outage is still outside this repair (AUD-09). No claim of a durable disk journal is made.

## AUD-04 — on-device feature windows — repaired; Python feature parity remains open

Dart extraction now sorts and windows by physical time, separates left/right device streams, measures regular cadence, computes jerk using elapsed time and suppresses fixed-rate FFT on irregular streams. Cross-correlation is only computed for aligned, equally sampled streams. Additional IMUs are explicitly counted rather than silently blended into the selected two. Fifteen timing/feature/export checks passed before moving on.

Limits: automatic windows assume the configured nominal interval for the final sample's coverage. Irregular spectral output is zero with a zero sample-rate field, not a resampled spectrum. The bundled Python trainer still has its older row-based feature extraction; its **split** was repaired under AUD-06, but it must not yet be treated as equivalent to the repaired Dart feature CSV. Multi-trip/rider evaluation and learned-model validation remain open.

## AUD-05 — nullable manual-event state — repaired

Explicit null now clears trip, event, GPS, timestamps, trigger and parameter state; omitted arguments preserve fields. Starting an event clears prior end GPS/computed parameters/pre-alert context. State regression and phone/watch lifecycle tests both pass.

## AUD-06 — overlapping evaluation splits — repaired for sample leakage

The Dart exporter partitions raw time into disjoint train/validation/test regions before building overlapping windows. Short recordings that cannot support three complete windows stay in one partition. The split strategy is exported. The Python generator uses a chronological split with purged overlap rather than random splitting of adjacent windows.

Validation: a test expands source row ranges and proves no intersection between all three partitions. Another test parses the actual generated Python and executes its splitting logic against several overlapping-window fixtures, proving train/test source-sample disjointness. These checks do not establish independence across riders/routes or validate classification quality. Twelve feature/pipeline tests and four final split checks passed.

## AUD-07 — export identity contract — repaired

Time-series and trip CSV now share the same **28-column, schema_version=2** header. The original 22 columns keep their order; six appended columns are `schema_version`, `reading_id`, `device_id`, `mount_location`, `trip_id`, `event_id`. Original mount values are preserved alongside the existing wrist display aliases. Sentinel rows carry the same number of columns and event/trip IDs, with no invented reading/device ID.

Both previously failing end-to-end export tests pass. Column-count tests were updated to the explicit version-2 contract; all 12 export/ride tests pass. Consumers hardcoded to 22 columns must adopt the versioned schema or parse by header. Original data was restored rather than weakening the failing identity assertions.

## AUD-08 — peak acceleration units — repaired

Bump/pothole `peakMetric` fallback is already g and is exported unchanged. Other event types no longer have unrelated peak metrics exported as g. The regression checks a stored 2.5 g bump exports as 2.50 and a turn does not populate `peak_g_force`. Nine export tests pass.

## Combined validation

- Initial complete default suite before GPS and delivery-state work: **273 passed, zero failed**.
- Six original audit reproductions plus five buffer tests: **11 passed**, including the final flush-drain adjustment.
- Static analysis: no errors; existing warnings/informational findings remain. Drift's version-pinned experimental migration API use is documented and covered by disk migration tests.
- `git diff --check`: passed.
- No physical-device ride, Android APK build, iOS build or native audio/background acceptance is claimed by these tests.

Evidence is saved in `repairs_full_tests.txt`, `repairs_reproductions.txt` and `repairs_analyze.txt` alongside this file.

## AUD-10 — GPS validity and readiness — repaired in the shared decision paths

Added a common GPS quality gate for finite/in-range coordinates, fix age, accuracy, plausible speed, monotonic timestamps and impossible short-interval jumps. The location service now exposes active/error/fresh-fix state, retries through its stream, honors Android update intervals, and does not treat a temporary tunnel as stream completion. Trip distance rejects invalid fixes and does not bridge GPS outages longer than ten seconds. Pre-alert startup no longer claims success before location tracking starts; session health reports missing GPS.

Validation: GPS, trip, watcher and migration regressions pass in the focused runs; the complete current suite passes **281 tests**. Limits: trip recording and pre-alert location still use separate native location streams, stationary drift and map matching are not solved, and background/permission-revocation behavior needs phone validation.

## AUD-11 — warning delivery accounting — repaired for app-observable speech completion

Schema 17 records queued/delivered/failed/expired/cancelled state, completion time and failure reason. Warning speech waits for playback completion, rechecks hazard relevance and refreshes distance at dequeue, times out boundedly, and only delivered warnings affect cooldown, counts, reports and feedback linkage. Health surfaces delivery failures, and exports include delivery state. Migration handles direct v16 and chained v15 upgrades without duplicate columns.

Validation: focused GPS/speech/export suite **58 passed**; timestamp and review migration suite **7 passed**; complete current suite **281 passed**; `git diff --check` passed. Static analysis reports no errors and 34 existing warning/info findings (nonzero exit). Physical phone, headset, call interruption and native TTS callback behavior remain unverified.

## AUD-09 — interrupted-trip recovery — partial repair

On controller startup, open trip rows are recovered transactionally and closed at the newest persisted sensor/GPS timestamp (or the start time when no samples exist). The repair records duration and row/event counts, adds a note that activity after the last saved sample may be missing, and surfaces a dashboard health warning. Starting a new ride waits for this reconciliation. Recovery is idempotent and does not change already closed rides. Android now starts a foreground service with a persistent notification and partial wake lock for an active ride, and reports service-start failure as a critical health alert. iOS declares the location and Bluetooth-central background modes.

Validation: two recovery-specific cases plus trip aggregate regression pass; the complete current suite after platform wiring passes **283 tests**. Static analysis has no errors (34 warning/info findings remain); the iOS plist passes `plutil -lint`, and `git diff --check` passes. Android Kotlin compilation and manifest merge both pass when Flutter asset generation is excluded. A full APK build still fails before Flutter source compilation: Gradle invokes `xcrun` from an x86_64 Temurin 17 runtime, while the installed Command Line Tools are arm64-only; the arm64 JDK 21 Homebrew link is dangling. Platform code is therefore only partly build-validated, and continuous BLE/GPS/Dart capture during lock/suspension is not device-validated. Continue AUD-09 until a full Android build and lock/battery-saver/process-kill tests pass; iOS needs a device background test too.

## Next unresolved work

Continue AUD-09 with platform background lifetime and physical-device checks, then the remaining audit backlog. AUD-04's Python feature-extraction parity also remains open. Do not mark the whole mobile system repaired or road-validated based on this software-only batch.
