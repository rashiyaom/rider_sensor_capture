# 📱 Flutter Mobile App Specification & Technical Architecture Guide

> **Application Name**: `ride_sensor_capture`  
> **Framework**: Flutter (Dart >= 3.5.0)  
> **Target Platforms**: Android 14+ (API 34), iOS 16+, macOS, Web  
> **State Management**: Flutter Riverpod 2.x  
> **Persistence Engine**: Drift (SQLite in WAL Mode)  
> **Purpose**: Complete technical architecture reference and implementation specification for the mobile telemetry companion app.

---

## 📑 Table of Contents
1. [Executive Summary & Core Mission](#1-executive-summary--core-mission)
2. [Technology Stack & Key Dependencies](#2-technology-stack--key-dependencies)
3. [Complete Directory & Component Architecture](#3-complete-directory--component-architecture)
4. [BLE Ingestion Subsystem & Parsers](#4-ble-ingestion-subsystem--parsers)
5. [Database & Persistence Subsystem (Drift WAL)](#5-database--persistence-subsystem-drift-wal)
6. [Embedded AI Camera Ingestion Webhook (Shelf)](#6-embedded-ai-camera-ingestion-webhook-shelf)
7. [Voice-Triggered Event Tagging Subsystem](#7-voice-triggered-event-tagging-subsystem)
8. [Physics Parameter Computation Engine](#8-physics-parameter-computation-engine)
9. [Presentation & Telemetry Layer (60 FPS HUD)](#9-presentation--telemetry-layer-60-fps-hud)
10. [Machine Learning Dataset Export Pipeline](#10-machine-learning-dataset-export-pipeline)
11. [Reliability, Battery & Fault Tolerance Hardening](#11-reliability-battery--fault-tolerance-hardening)
12. [Automated Test Suite & Verification](#12-automated-test-suite--verification)

---

## 1. Executive Summary & Core Mission

The **`ride_sensor_capture`** mobile app is a real-time, multi-modal vehicle telemetry and biometric data capture platform. It is engineered for researchers training machine learning models on two-wheeler vehicle dynamics, road surface anomalies (potholes, speed bumps), and rider physiology.

### Key Functional Responsibilities:
1. **Multi-Source Ingestion**: Concurrently ingests 50Hz 6-axis IMU from ESP32 wearables, 52Hz 3-axis accelerometer + optical PPG Heart Rate from Polar Verity Sense, and local Wi-Fi vision detections from edge cameras.
2. **Deterministic Time Synchronization**: Aligns all sensor streams against a global UTC millisecond timeline.
3. **Hands-Free Ground Truth Labeling**: Enables riders to label road events via continuous speech keyword recognition or tactile watch buttons.
4. **Crash-Safe Persistence**: Streams 100+ packets/second into SQLite without UI frame drops using batch buffers.
5. **Direct ML Dataset Deliverable**: Exports multi-modal datasets into PyTorch/TensorFlow-ready JSON and CSV formats.

---

## 2. Technology Stack & Key Dependencies

```yaml
environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: '>=3.24.0'

dependencies:
  # State Management & Reactive Streams
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Bluetooth Low Energy
  flutter_blue_plus: ^1.34.5

  # Local SQLite Persistence & Code Generation
  drift: ^2.20.1
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0

  # High-Performance Visualizations & Waveforms
  fl_chart: ^0.68.0

  # Embedded REST Server for Edge Camera Ingestion
  shelf: ^1.4.1
  shelf_router: ^1.1.4

  # Voice Recognition Engine
  speech_to_text: ^7.0.0
  permission_handler: ^11.3.1

  # Battery & Hardware Diagnostics
  battery_plus: ^6.1.0
  device_info_plus: ^10.1.0
  share_plus: ^10.0.0
  intl: ^0.19.0
```

---

## 3. Complete Directory & Component Architecture

```text
lib/
├── app.dart                        # Root MaterialApp, navigation shell, and dark theme
├── main.dart                       # Entrypoint (WidgetsFlutterBinding, Riverpod ProviderScope)
│
├── ble/                            # Bluetooth Low Energy Communication Subsystem
│   ├── models/
│   │   ├── ble_device_model.dart   # BleDeviceModel, DeviceType, ConnectionHealth, BleConnectionState
│   │   └── raw_sensor_data.dart    # Immutable RawSensorData model (HR, Accel, PPI, Gyro)
│   ├── parsers/
│   │   ├── polar_verity_parser.dart # GATT 0x2A37 (HR/PPI) & Polar PMD Accel unpacker
│   │   └── esp32_watch_parser.dart  # 28-byte & 13-byte float32/binary buffer unpacker
│   └── services/
│       ├── ble_scanner.dart         # Advertisement scanner with RSSI and service filtering
│       ├── ble_connection_manager.dart # Connection lifecycle, MTU, auto-reconnect & packet stream
│       └── ble_permission_service.dart # Platform-specific BLE permission request handlers
│
├── camera/                         # Embedded AI Edge Camera Ingestion
│   ├── camera_detection_model.dart # Detection payload model (bounding box, confidence, latency)
│   ├── camera_detection_repository.dart # Drift persistence interface for camera detections
│   └── camera_ingest_server.dart   # Shelf HTTP REST server on port 8080 (/camera-event)
│
├── voice/                          # Speech Recognition & Voice Commands
│   ├── voice_command_config.dart   # Keyword mapping ("start bump", "start turn", "stop event")
│   └── voice_command_listener.dart # Continuous speech listener wrapping speech_to_text
│
├── data/                           # Data Persistence Layer
│   ├── local_db/
│   │   ├── connection/             # Multiplatform SQLite factory (Native + Web Wasm)
│   │   ├── tables/
│   │   │   ├── sensor_readings_table.dart  # High-frequency time-series table
│   │   │   ├── event_records_table.dart    # Labeled event windows
│   │   │   └── camera_detections_table.dart# Vision inference results
│   │   ├── database.dart           # Drift @DriftDatabase schema, DAOs and queries
│   │   └── database.g.dart         # Drift generated code
│   ├── models/
│   │   └── event_parameters.dart   # Physics models for Bump, Turn, and Speed test features
│   └── repositories/
│       ├── sensor_repository.dart  # Sensor repository interface
│       ├── sensor_repository_impl.dart # 250ms batch buffer SQLite repository
│       ├── export_repository.dart  # Export repository interface
│       └── export_repository_impl.dart # Joined JSON & CSV dataset generation engine
│
├── features/                       # UI Feature Modules (Presentation Layer)
│   ├── dashboard/                  # Live 50Hz waveform telemetry & G-Force dashboard
│   ├── devices/                    # BLE scanner, connection cards & live ingest terminal
│   ├── events/                     # Voice-triggered ride labeling & event history detail
│   └── export/                     # ML dataset export options, filters & share sheet
│
├── providers/                      # Riverpod Dependency Injection & Reactive Providers
│   ├── ble_providers.dart          # Scanner, connection manager, and raw sensor streams
│   ├── db_providers.dart           # Database instance, repository & BLE-to-DB bridge
│   ├── dashboard_providers.dart    # 8 FPS throttled rolling telemetry notifier
│   ├── camera_providers.dart       # Camera server state and live detection streams
│   ├── battery_providers.dart      # Device battery level and power saving mode
│   └── export_providers.dart       # Dataset generation controller and filter state
│
└── core/                           # Shared Theme, System Utilities, and Watchdogs
    ├── services/
    │   ├── app_permissions_service.dart # Cold-start hardware permissions checker
    │   ├── battery_service.dart    # Battery drainage and power-saving advisor
    │   └── session_health_service.dart  # Hardware alerts and packet gap monitor
    └── theme/
        └── app_theme.dart          # Dark glassmorphic cybertech styling tokens
```

---

## 4. BLE Ingestion Subsystem & Parsers

### Multi-Device Management (`BleConnectionManager`)
- **MTU Negotiation**: Automatically requests **512-byte MTU** upon connection to ensure unfragmented packets.
- **Connection Health Tracking**: Monitored every 1500ms:
  - `ConnectionHealth.good`: Packet rate $\ge 25\text{ Hz}$
  - `ConnectionHealth.degraded`: Packet rate $5\text{--}24\text{ Hz}$
  - `ConnectionHealth.poor`: Packet rate $< 5\text{ Hz}$
- **Exponential Backoff Auto-Reconnect**: Retries at intervals of `2s`, `4s`, `8s`, `16s`, `20s` (maximum 6 retries).

### Supported Sensor Formats:
1. **Polar Verity Sense (`PolarVerityParser`)**:
   - `0x180D / 0x2A37`: Standard Heart Rate (BPM) + RR intervals ($\text{PPI} = \frac{\text{RR}}{1024} \times 1000\,\text{ms}$).
   - `fb005c82`: Polar PMD 52Hz 16-bit 3-axis accelerometer stream.
2. **ESP32-S3 Watch (`Esp32WatchParser`)**:
   - **28-byte binary frame** (`0xFFE1`):
     `[uint32 timestamp_ms, float32 ax, ay, az, gx, gy, gz]`
   - **13-byte compact frame** (`0xFFE1` legacy):
     `[uint8 hr, float32 ax, ay, az]`

---

## 5. Database & Persistence Subsystem (Drift WAL)

### SQLite Write-Ahead Logging (WAL) Architecture:
High-frequency (100+ Hz total) writes are protected by an in-memory batch buffer in `SensorRepositoryImpl`:
- **Flush Cadence**: Flushed every **250 milliseconds** or whenever the buffer reaches **25 items**.
- **Crash Safety**: In-flight items are committed in atomic transactions.

### Database Tables:

#### 1. `sensor_readings` Table
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | `INTEGER` | Primary Key, Auto-Increment | Unique row ID |
| `deviceId` | `TEXT` | NOT NULL | Device MAC or UUID |
| `deviceType` | `TEXT` | NOT NULL | `watch`, `verityBand`, `camera` |
| `sequenceNo` | `INTEGER` | NOT NULL | Monotonic packet counter |
| `timestampUtc` | `DATETIME` | NOT NULL | Packet arrival timestamp |
| `sensorType` | `TEXT` | NOT NULL | `imu`, `hr`, `combined`, `ppi` |
| `eventId` | `INTEGER` | Nullable, Indexed | Foreign Key $\to$ `event_records.id` |
| `heartRate` | `INTEGER` | Nullable | BPM |
| `accelX`, `accelY`, `accelZ` | `REAL` | Nullable | Acceleration ($m/s^2$) |
| `gyroX`, `gyroY`, `gyroZ` | `REAL` | Nullable | Angular rate ($rad/s$) |
| `ppiMs` | `INTEGER` | Nullable | Peak-to-peak interval |
| `rawPayload` | `TEXT` | Nullable | Byte buffer debug backup |

#### 2. `event_records` Table
Stores ground-truth labeled windows:
- `id`: Primary key
- `eventType`: `bump`, `turn`, `speed_test`, `custom`
- `startTimestampUtc` & `endTimestampUtc`: Window bounds
- `triggerPhrase`: Trigger source (`"voice: start bump"`, `"watch: tactile"`)
- `computedParametersJson`: JSON string containing extracted physics parameters

#### 3. `camera_detections` Table
- `id`: Primary key
- `deviceId`: Edge camera ID
- `timestampUtc`: Detection timestamp
- `eventClass`: Detected class (`pothole`, `obstacle`, `vehicle`)
- `confidence`: Detection score (0.0 to 1.0)
- `boundingBoxJson`: `[x, y, width, height]`
- `linkedEventId`: Foreign key to `event_records.id`

---

## 6. Embedded AI Camera Ingestion Webhook (Shelf)

The mobile app hosts an internal HTTP REST server (`camera_ingest_server.dart`) listening on `http://0.0.0.0:8080`:

### Ingest Endpoint: `POST /camera-event`
```json
{
  "device_id": "esp32_cam_front",
  "timestamp_utc": "2026-08-25T10:55:00.000Z",
  "event_class": "pothole",
  "confidence": 0.94,
  "bounding_box": [120, 80, 240, 180],
  "latency_ms": 42
}
```

### Auto-Linking Logic:
When a camera detection arrives:
1. It is validated and saved to `camera_detections`.
2. If an event is currently active (e.g. `Bump`), the detection is automatically linked via `linkedEventId`.
3. An active detection badge appears in the mobile HUD.

---

## 7. Voice-Triggered Event Tagging Subsystem

Located in `lib/voice/`, wrapping `speech_to_text`:

### Configured Voice Commands:
* `"start bump"` / `"bump"` $\to$ Starts `bump` event window
* `"start turn"` / `"turn"` $\to$ Starts `turn` event window
* `"start speed"` / `"speed test"` $\to$ Starts `speed_test` event window
* `"stop event"` / `"end"` / `"stop"` $\to$ Finalizes active window and triggers physics computation

### Lifecycle State Machine:
```
[IDLE] ──(Voice / Watch Trigger)──> [EVENT ACTIVE] (Tagging all incoming 50Hz sensor rows)
                                            │
                                  (Stop Command / Timeout)
                                            │
                                            ▼
                               [COMPUTE PARAMETERS]
                                            │
                                            ▼
                                [PERSIST & ASSOCIATE]
```

---

## 8. Physics Parameter Computation Engine

When an event window closes, the app analyzes all sensor readings inside that window:

### 1. Bump Event Parameters (`BumpParameters`)
- **Peak G-Force**: $\max(\sqrt{a_x^2 + a_y^2 + a_z^2}) / 9.80665$
- **Impact Duration**: Duration where $|a| > 1.2g$
- **Estimated Severity**: Categorized as `mild`, `moderate`, or `severe`

### 2. Turn Event Parameters (`TurnParameters`)
- **Peak Yaw Rate**: $\max(|\omega_z|)$
- **Maximum Lean Angle**: Computed from lateral-to-vertical acceleration ratio: $\theta = \arctan(a_y / a_z)$
- **Turn Direction**: `left` vs `right`

### 3. Speed Test Parameters (`SpeedTestParameters`)
- **Deceleration / Acceleration Rate**: $\Delta v / \Delta t$
- **Speed Drop**: $v_{\text{initial}} - v_{\text{final}}$

---

## 9. Presentation & Telemetry Layer (60 FPS HUD)

### Dashboard Screen (`DashboardScreen`):
- **Waveform Charts**: 3-axis Accelerometer & Gyroscope waveforms rendered using `FlChart`.
- **Render Optimizations**:
  - `RepaintBoundary` isolation to prevent entire screen repainting.
  - Data points throttled to 8 FPS for chart drawing, while the database continues ingesting at full 50Hz.
  - Animations disabled (`Duration.zero`) to eliminate UI thread overhead.
- **HUD Gauges**: Live G-Force Vector, Heart Rate pulse indicator, GPS speed readout, and dual battery pill indicators.

---

## 10. Machine Learning Dataset Export Pipeline

### JSON Export Format (`ExportRepository`):
```json
{
  "export_version": "1.0",
  "generated_at_utc": "2026-08-25T11:00:00.000Z",
  "mode": "all_data",
  "events": [
    {
      "id": 1,
      "event_type": "bump",
      "start_timestamp_utc": "2026-08-25T10:55:10.000Z",
      "end_timestamp_utc": "2026-08-25T10:55:14.200Z",
      "trigger_phrase": "voice: start bump",
      "computed_parameters": {
        "bump": { "peak_g_force": 2.84, "duration_ms": 4200 }
      },
      "sensor_readings": [
        {
          "seq": 1042,
          "device_id": "ESP32-Watch",
          "timestamp_utc": "2026-08-25T10:55:10.020Z",
          "accel_x": 0.42,
          "accel_y": -1.18,
          "accel_z": 12.45,
          "gyro_x": 0.05,
          "gyro_y": -0.12,
          "gyro_z": 0.01
        }
      ],
      "camera_detections": [
        {
          "class": "pothole",
          "confidence": 0.94,
          "box": [120, 80, 240, 180]
        }
      ]
    }
  ]
}
```

### Time-Series CSV Export Format:
```csv
id,device_id,device_type,sequence_no,timestamp_utc,sensor_type,event_id,heart_rate,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,ppi_ms
1,ESP32-Watch,watch,1042,2026-08-25T10:55:10.020Z,imu,1,,0.42,-1.18,12.45,0.05,-0.12,0.01,
```

---

## 11. Reliability, Battery & Fault Tolerance Hardening

1. **Battery Optimization Service (`battery_service.dart`)**:
   - Monitors phone battery state and triggers power-saving mode when battery falls below 20%.
   - Reduces UI redraw frequency while maintaining full-speed background SQLite logging.
2. **Session Health Watchdog (`session_health_service.dart`)**:
   - Detects sensor data packet gaps (>3 seconds without data).
   - Surfaces non-blocking warnings on the dashboard.
3. **Monotonic Sequence Continuity**:
   - Queries `getLastSequenceNoForDevice(deviceId)` on reconnect to resume packet counters smoothly across reboots.

---

## 12. Automated Test Suite & Verification

The repository contains **34 unit and integration tests** executing with 100% pass rate:
```bash
flutter test
```

### Verified Test Areas:
1. `ble_parser_test.dart`: Verifies Polar Verity Sense and ESP32 binary unpackers.
2. `camera_detection_repository_test.dart`: Validates camera detection models and bounds checking.
3. `export_repository_test.dart`: Verifies JSON and CSV dataset schema generation.
4. `reliability_hardening_test.dart`: Tests exponential backoff, sequence preservation, and health state transitions.
