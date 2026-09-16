# Implementation Prompt: Upgrade `ride_sensor_capture` for Driver-Safety-Score ML Pipeline

Use this as a direct implementation brief (for yourself, a dev, or an AI coding assistant like Claude Code). It assumes the existing Flutter/Riverpod/Drift architecture described in `MOBILE_APP_SPECIFICATION.md` and specifies every change needed to make the app produce a correct, ML-ready dataset for a two-wheeler driver safety score model.

---

## 0. Context (paste this if handing to a coding assistant cold)

The app (`ride_sensor_capture`) currently ingests:
- Two ESP32-S3 wearables, each streaming 6-axis IMU (accel + gyro) at 50Hz over BLE (28-byte / 13-byte frames)
- A Polar Verity Sense streaming HR + PPI (GATT `0x2A37`) and 52Hz 3-axis accel (Polar PMD `fb005c82`)
- Edge camera detections via an embedded Shelf HTTP server on port 8080

**Physical sensor placement (new — must be reflected in schema/config):**
- ESP32 Watch #1 → strapped to the **front fork tube**, just below the handlebar clamp (`mountLocation: fork`)
- ESP32 Watch #2 → strapped to the **footboard/footpeg mount rod** (`mountLocation: footboard`)
- Polar Verity Sense → **forearm strap** as shipped (`mountLocation: forearm`)
- No unit is on the handlebar grip or rider's wrist — both watches are on rigid-ish vehicle parts, not the rider's body, so IMU data is vehicle dynamics, not human motion.

**Goal:** produce a clean, correctly-fused, GPS-integrated, per-trip + per-event dataset suitable for training a driver safety score ML model. The current app is missing GPS entirely, uses an incorrect lean-angle formula, has no cross-sensor event confirmation, and has no per-trip aggregate table.

---

## 1. Add GPS/Location Ingestion (new subsystem)

Create `lib/location/` with:
- `location_service.dart` — wraps `geolocator` (or equivalent) package. Stream GPS fixes at **1Hz minimum**, ideally configurable up to 5Hz if the device supports it.
- Fields to capture per fix: `latitude`, `longitude`, `altitude`, `gpsSpeedMps`, `gpsHeadingDeg`, `gpsAccuracyM`, `timestampUtc`.
- Add a new Drift table `location_readings`:

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | INTEGER | PK, autoincrement | |
| `tripId` | INTEGER | NOT NULL, indexed, FK → trips.id | |
| `timestampUtc` | DATETIME | NOT NULL | |
| `latitude` | REAL | NOT NULL | |
| `longitude` | REAL | NOT NULL | |
| `altitude` | REAL | Nullable | meters |
| `gpsSpeedMps` | REAL | Nullable | |
| `gpsHeadingDeg` | REAL | Nullable | 0–360, course over ground |
| `gpsAccuracyM` | REAL | Nullable | used to discard low-quality fixes |

- Add a `GpsDerivedFeatures` computation step that runs on a rolling window and outputs: `gpsAccelMps2` (derivative of `gpsSpeedMps`), `speedVarianceWindow`, `overspeedFlag` (needs a configurable/route-based `speedLimitKmh`, can default null/manual entry for now — do not attempt automatic map-matching in this pass, stub the field).

---

## 2. Add `trips` Table (per-trip container + aggregate row)

New Drift table `trips`:

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | |
| `startTimestampUtc` | DATETIME | |
| `endTimestampUtc` | DATETIME nullable | null while trip active |
| `totalDistanceKm` | REAL nullable | computed from GPS at trip close |
| `totalDurationMin` | REAL nullable | |
| `avgSpeedKmh` | REAL nullable | |
| `maxSpeedKmh` | REAL nullable | |
| `harshBrakeCount` | INTEGER default 0 | |
| `harshAccelCount` | INTEGER default 0 | |
| `harshTurnCount` | INTEGER default 0 | |
| `bumpCount` | INTEGER default 0 | |
| `confirmedEventCount` | INTEGER default 0 | events that passed HR + duration + correlation gating (see §5) |
| `eventsPerKm` | REAL nullable | computed at close |
| `avgHr` | REAL nullable | |
| `maxHr` | INTEGER nullable | |
| `hrSpikeConfirmedRatio` | REAL nullable | confirmedEvents / totalIMUFlaggedEvents |
| `nightDrivingPct` | REAL nullable | % of trip duration between configurable night hours (default 19:00–06:00) |
| `driverScore` | REAL nullable | label column — manually entered or rule-based computed, populated post-hoc |

Every `sensor_readings`, `location_readings`, and `event_records` row must carry a `tripId` foreign key. Add a `TripController`/provider that starts a trip on first sensor connection (or explicit "Start Trip" UI action) and closes it on explicit stop, computing all aggregate columns at close time.

---

## 3. Modify `sensor_readings` Table — Add Mount Location

Add column:

| Column | Type | Constraints | Description |
|---|---|---|---|
| `mountLocation` | TEXT | NOT NULL | Enum: `fork`, `footboard`, `forearm` |

Populate this at ingestion time in `BleConnectionManager` based on a device-ID-to-mount-location mapping configured once during device pairing (add a simple pairing/config screen or config file mapping `deviceId → mountLocation`, don't infer it from packet content).

Also add:
| Column | Type | Description |
|---|---|---|
| `tripId` | INTEGER, FK → trips.id, indexed | |

---

## 4. Fix Physics Computation Engine (`lib/data/models/event_parameters.dart`)

### 4a. Replace the lean angle formula
**Current (incorrect):** `θ = arctan(a_y / a_z)` — only valid under quasi-static conditions; invalid during actual cornering because lateral acceleration corrupts the gravity-vector assumption.

**Replace with a complementary filter** fusing gyro-integrated roll with accelerometer-derived roll, using the **fork-mounted IMU** as the authoritative source (rigid to steering, closer to true vehicle roll than footboard):

```
roll_gyro[i] = roll[i-1] + gyroX * dt
roll_accel = atan2(accelY, sqrt(accelX^2 + accelZ^2))
roll[i] = alpha * roll_gyro[i] + (1 - alpha) * roll_accel   // alpha ≈ 0.98
```
Use GPS heading-rate (`Δheading/Δt` from consecutive `gpsHeadingDeg` fixes) as a periodic drift-correction reference for yaw, since no magnetometer is used (documented decision — GPS course-over-ground substitutes for magnetometer-based heading correction).

### 4b. Add jerk as a first-class computed feature
For every event window and for continuous rolling windows (not just tagged events), compute:
```
jerk_x[i] = (accelX[i] - accelX[i-1]) / dt
jerk_y[i] = (accelY[i] - accelY[i-1]) / dt
jerk_z[i] = (accelZ[i] - accelZ[i-1]) / dt
jerk_magnitude[i] = sqrt(jerk_x^2 + jerk_y^2 + jerk_z^2)
```
Use `jerk_magnitude` (not raw peak G-force alone) as the primary feature for bump/harsh-event severity classification. Keep peak G-force as a secondary feature, not the sole one.

### 4c. Add fork↔footboard cross-correlation confirmation
New computation step `EventCrossValidator`:
1. When an IMU spike is detected on either `fork` or `footboard` mounted device, look for a corresponding spike on the *other* device within a configurable window (default 300ms for bumps, 1000ms for turns/braking since those are whole-vehicle events and should be near-simultaneous, while bumps show front-then-rear lag).
2. Compute `forkFootLagMs` = time delta between the two peak detections.
3. Flag `crossConfirmed: true` only if both devices show a correlated spike above threshold within the window. Discard/deprioritize (but still store, flagged `crossConfirmed: false`) single-device spikes — these are the most likely to be false positives (e.g. one strap slipping, one unit bumped).

### 4d. Add HR-based event confirmation gating
New computation step `HrEventGate`:
1. Maintain a rolling `hrBaseline` (e.g. trailing 60s median HR) per trip.
2. On any IMU-flagged event, check if `heartRate` rose by more than a configurable delta (default 8 bpm) above `hrBaseline` within 5 seconds of the event's start timestamp.
3. Store `hrSpikeConfirmed: bool` and `hrDeltaAtEvent: real` on the event record.
4. An event is only marked `eventConfirmed: true` in the final dataset if it passes **both** `crossConfirmed` (§4c) AND meets duration/threshold criteria — `hrSpikeConfirmed` should be stored as a supporting feature/signal, not a hard gate (HR response lag varies by person and event severity; use it as an ML input feature, not a binary filter that silently drops data).

### 4e. Update `event_records` schema — add columns:
| Column | Type | Description |
|---|---|---|
| `crossConfirmed` | BOOLEAN | From §4c |
| `forkFootLagMs` | REAL nullable | From §4c |
| `hrSpikeConfirmed` | BOOLEAN | From §4d |
| `hrDeltaAtEvent` | REAL nullable | From §4d |
| `jerkPeakMagnitude` | REAL | From §4b |
| `gpsSpeedAtEventKmh` | REAL nullable | Joined from nearest `location_readings` row |
| `gpsHeadingChangeDeg` | REAL nullable | For turn events — confirms real turn vs jitter via GPS heading delta correlated with yaw spike |

### 4f. Signal Filtering & Vibration Noise Rejection Subsystem (`lib/data/services/signal_filter_service.dart`)

**Core Principles:**
1. **Never destroy raw data**: `sensor_readings` (raw table) is never modified or overwritten by filtering. Filtering produces new derived columns/tables.
2. **Zero-Phase Filtering (`filtfilt`)**: All filters used for feature extraction must be zero-phase forward-backward filtering to prevent time delays/phase shifts that misalign GPS/HR timestamps.
3. **Per-device, per-trip calibration**: Calibrate per-trip and per-device (`fork` vs. `footboard`).

**Pipeline Stages:**
- **Stage 1 (Idle Calibration Window)**: First 3–5s stationary window at trip start (GPS speed < 1.2 km/h, low accel variance). Radix-2 FFT (128/256 samples at 50Hz) to detect dominant engine idle noise frequency (10–24.5 Hz). Stored in `trip_calibration` table (`tripId`, `mountLocation`, `engineNoiseFreqHz`, `engineNoiseAmplitude`, `calibratedAtUtc`, `calibrationValid`). If no stationary window found in first 30s, fall back to `calibrationValid: false` with NO notch applied.
- **Stage 2 (Adaptive Narrow Notch Filter)**: 2nd-order IIR notch ($Q \ge 10$) at detected engine frequency, zero-phase. Applied to derived feature channels, **never to bump detection**. No-op if `calibrationValid == false`.
- **Stage 3 (Maneuver Low-Pass)**: 2nd-order zero-phase Butterworth low-pass at 3.0 Hz for roll/lean angle and turn detection.
- **Stage 4 (Bump High-Pass + Envelope)**: Gentle 2nd-order zero-phase high-pass at 0.4 Hz to remove gravity/DC offset without attenuating broadband bump impulses (5–25 Hz). Short-window RMS envelope (20–40ms) and jerk computation.
- **Stage 5 (Adaptive Noise Floor Thresholds)**: `threshold = baselineNoiseFloor + fixedMargin`, where `baselineNoiseFloor` is derived from idle calibration.
- **Stage 6 (Live Dashboard Filtering)**: Causal EMA for display only; isolated from database and ML export pipeline.

---

## 5. Unit Consistency Audit

Explicitly document and enforce (add unit tests):
- `gyroX/Y/Z` stored in **rad/s** (per current schema) — every consumer function (lean angle, yaw rate, turn detection) must convert to/from degrees consistently. Add a single `AngularUnits` utility module; ban ad-hoc conversions scattered across files.
- `accelX/Y/Z` in **m/s²** — G-force conversions must divide by `9.80665`, centralize this constant, don't hardcode `9.8` anywhere.
- Add a unit test (`unit_consistency_test.dart`) asserting no raw literal `9.8`/`57.3`/etc. conversion constants exist outside the shared utility module (simple grep-based test is fine).

---

## 6. Update ML Dataset Export Pipeline (`export_repository_impl.dart`)

### 6a. Produce two separate export outputs (not one flat file):

**File 1 — `sensor_timeseries_export.csv`** (high-frequency, per-reading)
```
timestamp_utc,trip_id,device_id,mount_location,sensor_type,event_id,
heart_rate,hr_baseline,hr_delta,
accel_x,accel_y,accel_z,accel_magnitude,
gyro_x,gyro_y,gyro_z,
jerk_x,jerk_y,jerk_z,jerk_magnitude,
roll_angle_deg,yaw_rate_deg_s,
latitude,longitude,gps_speed_kmh,gps_heading_deg,gps_accuracy_m,
ppi_ms
```
(GPS columns forward-filled from nearest `location_readings` timestamp since GPS is 1Hz and IMU is 50Hz — document the join strategy: nearest-timestamp, max tolerance 1.5s, else null.)

**File 2 — `event_records_export.csv`** (one row per labeled/detected event)
```
event_id,trip_id,event_type,trigger_phrase,
start_timestamp_utc,end_timestamp_utc,duration_ms,
mount_location_primary,
peak_g_force,jerk_peak_magnitude,
peak_yaw_rate_deg_s,max_lean_angle_deg,turn_direction,
cross_confirmed,fork_foot_lag_ms,
hr_spike_confirmed,hr_delta_at_event,
gps_speed_at_event_kmh,gps_heading_change_deg,
camera_linked,camera_event_class,camera_confidence,
event_severity,event_confirmed
```

**File 3 — `trip_summary_export.csv`** (one row per trip — this is your model's primary training table for the overall score)
```
trip_id,start_timestamp_utc,end_timestamp_utc,total_distance_km,total_duration_min,
avg_speed_kmh,max_speed_kmh,
harsh_brake_count,harsh_accel_count,harsh_turn_count,bump_count,
confirmed_event_count,events_per_km,
avg_hr,max_hr,hr_spike_confirmed_ratio,
night_driving_pct,
driver_score
```

### 6b. Keep the existing nested JSON export format, but add the new fields (mount_location, cross_confirmed, hr fields, GPS block) into `computed_parameters` and add a top-level `"trip_summary": {...}` object mirroring File 3's columns.

### 6c. Add an export filter option: "Only export cross-confirmed events" (boolean toggle in `features/export/`) so noisy/unconfirmed data can be excluded from a training run without deleting it from the DB.

---

## 7. Testing Additions

Add to the existing 34-test suite:
- `lean_angle_fusion_test.dart` — verify complementary filter output against known synthetic roll sequences (static tilt cases + simulated cornering with lateral accel, confirming the new formula doesn't corrupt under lateral g).
- `jerk_computation_test.dart` — verify jerk calculation against synthetic step-function acceleration input.
- `cross_correlation_test.dart` — verify `EventCrossValidator` correctly matches/rejects synthetic fork/footboard event pairs at various lag times, including the negative case (no match found → `crossConfirmed: false`).
- `hr_gate_test.dart` — verify HR baseline rolling calculation and delta detection against synthetic HR sequences.
- `gps_join_test.dart` — verify nearest-timestamp GPS join logic, including the "no GPS fix within tolerance → null" case.
- `trip_aggregate_test.dart` — verify `trips` table aggregate columns compute correctly at trip close from synthetic event/sensor data.

---

## 8. Explicit Non-Goals for This Pass (so scope doesn't creep)

- Do **not** implement automatic map-matching / speed-limit lookup via OSM — stub `speedLimitKmh` as a nullable manual-entry field only.
- Do **not** add a magnetometer — GPS heading is the documented drift-correction substitute (see §4a).
- Do **not** change BLE frame formats (28-byte/13-byte parsers stay as-is).
- Do **not** implement weather API integration in this pass — leave `weather` as a future column, not built now.

---

## Summary of Files to Create/Modify

**New files:**
- `lib/location/location_service.dart`
- `lib/data/local_db/tables/location_readings_table.dart`
- `lib/data/local_db/tables/trips_table.dart`
- `lib/data/services/event_cross_validator.dart`
- `lib/data/services/hr_event_gate.dart`
- `lib/core/utils/angular_units.dart`
- `test/lean_angle_fusion_test.dart`, `test/jerk_computation_test.dart`, `test/cross_correlation_test.dart`, `test/hr_gate_test.dart`, `test/gps_join_test.dart`, `test/trip_aggregate_test.dart`

**Modified files:**
- `lib/data/local_db/tables/sensor_readings_table.dart` (add `mountLocation`, `tripId`)
- `lib/data/local_db/tables/event_records_table.dart` (add fields from §4e)
- `lib/data/models/event_parameters.dart` (fix lean angle §4a, add jerk §4b)
- `lib/data/repositories/export_repository_impl.dart` (three-file export, §6)
- `lib/providers/ble_providers.dart` (mount-location device mapping)
- `lib/features/export/` (confirmed-events-only filter toggle)
