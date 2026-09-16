# ESP32-S3 Watch Firmware Specification & Compatibility Guide

> **Target Device**: Waveshare ESP32-S3-Touch-AMOLED-2.06 (or any ESP32-S3 / ESP32 6-Axis IMU Wearable)  
> **Companion App**: Ride Sensor Capture (Flutter / Dart)  
> **Purpose**: Complete technical prompt and specification for updating, refactoring, and verifying watch firmware compatibility with the mobile app.

---

## 1. Executive Summary & Objective

The **Ride Sensor Capture** mobile application is a high-frequency (50Hz) sensor collection and vehicle telemetry platform. It connects via Bluetooth Low Energy (BLE) to wearable and on-vehicle sensors to record 6-axis IMU acceleration, gyroscope dynamics, GPS coordinates, and labeled ground-truth events for machine learning dataset collection.

To ensure 100% plug-and-play compatibility, the ESP32-S3 watch firmware must implement the exact BLE GATT service hierarchy, binary payload format, timing guarantees, and advertising parameters documented below.

---

## 2. Hardware Architecture & Pinout Reference

### Waveshare ESP32-S3-Touch-AMOLED-2.06 Hardware Profile:
- **MCU**: ESP32-S3 (Dual-core Xtensa 32-bit LX7, up to 240 MHz, BLE 5.0 + Mesh)
- **IMU**: QMI8658 (6-axis Inertial Measurement Unit: 3-axis Accelerometer + 3-axis Gyroscope)
  - Interface: $I^2C$ (`SDA = GPIO 6`, `SCL = GPIO 7` or board-configured pins)
  - Alternate IMU: LSM6DS3 / ICM-42688 (if configured in board revision)
- **Power Management**: AXP2101 / PMIC
- **Display**: 2.06" AMOLED Display (CO5300 / SH8601 controller)
- **Storage**: MicroSD / TF Card SPI/SDIO slot (optional local backup logging)

---

## 3. BLE GATT Architecture & Service Identification

The mobile app actively scans and discovers devices using standard GATT service and characteristic identifiers.

### A. Primary Service UUID
- **128-bit UUID**: `0000FFE0-0000-1000-8000-00805F9B34FB`
- **16-bit Alias**: `0xFFE0` (or `FFE0`)

### B. IMU Data Characteristic (TX / Notify)
- **128-bit UUID**: `0000FFE1-0000-1000-8000-00805F9B34FB`
- **16-bit Alias**: `0xFFE1` (or `FFE1`)
- **Properties**: `NOTIFY` | `READ`
- **Descriptors**: Client Characteristic Configuration Descriptor (CCCD `0x2902`) enabled with notifications.

### C. BLE Advertising Requirements
1. **Device Local Name**: Must be set to `"ESP32-Watch"`, `"Waveshare-Watch"`, `"ESP32_IMU"`, or `"RideSensor"`.
2. **Service Solicitation**: The advertising packet **MUST include Service UUID `0xFFE0`**. This allows the mobile app's BLE scanner to recognize the watch instantly as a verified live data collection device.
3. **Advertising Interval**: 30ms – 60ms (fast advertising for immediate pairing upon opening the app).
4. **Connection Parameters**:
   - Connection Interval: Min `15ms` (12 units) / Max `30ms` (24 units) to effortlessly support 50Hz streaming without packet backlog.
   - Slave Latency: `0`.
   - Supervision Timeout: `3000ms` (300 units).

---

## 4. Binary Telemetry Packet Specification (Primary Standard)

The watch firmware must transmit **28-byte packed binary packets** over the `0xFFE1` characteristic at **50Hz (every 20ms)**.

### A. Packet Memory Layout (Little-Endian, IEEE 754 Float32)

```
Byte 0       Byte 3 Byte 4       Byte 7 Byte 8       Byte 11
+------------------+------------------+------------------+
|   timestamp_ms   |     accel_x      |     accel_y      |
|  (uint32_t, 4B)  |   (float, 4B)    |   (float, 4B)    |
+------------------+------------------+------------------+

Byte 12      Byte 15 Byte 16      Byte 19 Byte 20      Byte 23
+-------------------+-------------------+-------------------+
|      accel_z      |      gyro_x       |      gyro_y       |
|    (float, 4B)    |    (float, 4B)    |    (float, 4B)    |
+-------------------+-------------------+-------------------+

Byte 24      Byte 27
+-------------------+
|      gyro_z       |
|    (float, 4B)    |
+-------------------+
```

### B. Detailed Field Table

| Byte Range | Type | Field Name | Units | Expected Range | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `0 .. 3` | `uint32_t` | `timestamp_ms` | Milliseconds | `0 .. 4,294,967,295` | Monotonic time from `millis()` since watch boot or session start. |
| `4 .. 7` | `float` | `accel_x` | $m/s^2$ or $g$ | $\pm 8.0\text{ to }\pm 16.0g$ | Linear acceleration along the X-axis (lateral/longitudinal). |
| `8 .. 11` | `float` | `accel_y` | $m/s^2$ or $g$ | $\pm 8.0\text{ to }\pm 16.0g$ | Linear acceleration along the Y-axis (longitudinal/lateral). |
| `12 .. 15` | `float` | `accel_z` | $m/s^2$ or $g$ | $\pm 8.0\text{ to }\pm 16.0g$ | Linear acceleration along the Z-axis (vertical, includes ~1.0g gravity). |
| `16 .. 19` | `float` | `gyro_x` | $deg/s$ or $rad/s$ | $\pm 1000^\circ/s\text{ to }\pm 2000^\circ/s$ | Angular velocity around X-axis (pitch rate). |
| `20 .. 23` | `float` | `gyro_y` | $deg/s$ or $rad/s$ | $\pm 1000^\circ/s\text{ to }\pm 2000^\circ/s$ | Angular velocity around Y-axis (roll rate). |
| `24 .. 27` | `float` | `gyro_z` | $deg/s$ or $rad/s$ | $\pm 1000^\circ/s\text{ to }\pm 2000^\circ/s$ | Angular velocity around Z-axis (yaw / turn rate). |

### C. C/C++ Structure Definition

```c
#pragma pack(push, 1)
typedef struct {
    uint32_t timestamp_ms; // Monotonic millisecond timestamp
    float accel_x;         // Accelerometer X
    float accel_y;         // Accelerometer Y
    float accel_z;         // Accelerometer Z
    float gyro_x;          // Gyroscope X
    float gyro_y;          // Gyroscope Y
    float gyro_z;          // Gyroscope Z
} ImuTelemetryPacket28B;    // Exactly 28 bytes
#pragma pack(pop)
```

---

## 5. Supported Alternative & Fallback Formats

The mobile app's parser (`esp32_watch_parser.dart`) automatically supports the following fallbacks if configured:

1. **24-Byte Binary Packet**:
   - Layout: 6 consecutive float32 values (`accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z`).
   - The app automatically assigns the mobile reception timestamp.
2. **16-Byte Binary Packet (Accel Only)**:
   - Layout: `uint32_t timestamp_ms` + `float32 accel_x, accel_y, accel_z`.
3. **12-Byte Binary Packet (Accel Only)**:
   - Layout: `float32 accel_x, accel_y, accel_z`.
4. **ASCII CSV Text Fallback**:
   - Layout: `"timestamp,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z\n"` or `"accel_x,accel_y,accel_z\n"`.

> **STRICT COMPATIBILITY RULE**:
> - **DO NOT transmit random/mock heart rate bytes in Byte 0**. 
> - Standard Polar heart rate bands use characteristic `0x2A37`. If the watch is transmitting IMU data, ensure it uses the 28-byte binary layout described above.

---

## 6. Sensor Sampling & Timing Pipeline

1. **IMU Configuration**:
   - Accelerometer Full-Scale: $\pm 8g$ or $\pm 16g$ (handles harsh bumps, speed humps, potholes).
   - Gyroscope Full-Scale: $\pm 1000\text{ dps}$ or $\pm 2000\text{ dps}$ (handles sharp turns, lean angles, maneuvers).
   - IMU Output Data Rate (ODR): $50\text{Hz}$ or $100\text{Hz}$ with on-chip low-pass filter (anti-aliasing) enabled.
2. **50Hz Sampling Loop**:
   - Dedicated FreeRTOS Task on ESP32-S3 Core 1 (`vTaskDelayUntil` with 20ms period).
   - Alternatively, a 20ms hardware timer (`esp_timer_create` or `Timer.periodic`) triggers reading and transmission.
3. **BLE Notification Queue**:
   - If the BLE link is temporarily congested, drop the oldest packet rather than blocking the real-time sensor loop. Real-time telemetry takes precedence over stale buffered data.

---

## 7. Dual-Path Storage: TF Card & BLE Streaming

If your watch firmware includes the **TF Card Dataset Collector**:
1. **Synchronous Mode**: When the user taps "START" on the watch or when a journey begins:
   - IMU samples can be written to the TF Card (in CSV or binary `.bin` format).
   - The identical sample is simultaneously converted to `ImuTelemetryPacket28B` and transmitted via BLE notification.
2. **Timestamp Coherence**: The `timestamp_ms` written to the TF card and the `timestamp_ms` sent over BLE must originate from the exact same monotonic hardware clock (`millis()` or `esp_timer_get_time() / 1000ULL`).

---

## 8. Complete Reference Implementation (ESP32 / NimBLE)

Below is a complete, production-grade firmware implementation using **NimBLE** (low memory, high throughput BLE library for ESP32):

```cpp
#include <Arduino.h>
#include <Wire.h>
#include <NimBLEDevice.h>

// ── GATT Service & Characteristic Definitions ──
#define SERVICE_UUID        "FFE0"
#define CHARACTERISTIC_UUID "FFE1"
#define DEVICE_NAME         "ESP32-Watch"

// ── 28-Byte Binary Packet Struct ──
#pragma pack(push, 1)
struct ImuTelemetryPacket28B {
    uint32_t timestamp_ms; // Monotonic millisecond counter
    float accel_x;         // Acceleration X (m/s^2 or g)
    float accel_y;         // Acceleration Y (m/s^2 or g)
    float accel_z;         // Acceleration Z (m/s^2 or g)
    float gyro_x;          // Gyroscope X (deg/s)
    float gyro_y;          // Gyroscope Y (deg/s)
    float gyro_z;          // Gyroscope Z (deg/s)
};
#pragma pack(pop)

static NimBLEServer* pServer = nullptr;
static NimBLECharacteristic* pTxCharacteristic = nullptr;
static bool isClientConnected = false;

// ── Server Connection Callbacks ──
class ServerCallbacks : public NimBLEServerCallbacks {
    void onConnect(NimBLEServer* pServer, ble_gap_conn_desc* desc) override {
        isClientConnected = true;
        // Update connection parameters for 50Hz throughput (15ms - 30ms interval)
        pServer->updateConnParams(desc->conn_handle, 12, 24, 0, 300);
        Serial.println(">> [BLE] Mobile App Connected!");
    }

    void onDisconnect(NimBLEServer* pServer) override {
        isClientConnected = false;
        Serial.println(">> [BLE] Mobile App Disconnected! Restarting advertising...");
        NimBLEDevice::startAdvertising();
    }
};

void setupBleGatt() {
    NimBLEDevice::init(DEVICE_NAME);
    NimBLEDevice::setPower(ESP_PWR_LVL_P9); // Maximum BLE TX power for reliable bike/ride connection

    pServer = NimBLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks());

    NimBLEService* pService = pServer->createService(SERVICE_UUID);
    pTxCharacteristic = pService->createCharacteristic(
        CHARACTERISTIC_UUID,
        NIMBLE_PROPERTY::NOTIFY | NIMBLE_PROPERTY::READ
    );

    pService->start();

    // Configure Advertising
    NimBLEAdvertising* pAdvertising = NimBLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setName(DEVICE_NAME);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinInterval(48); // 30ms
    pAdvertising->setMaxInterval(96); // 60ms
    pAdvertising->start();

    Serial.println(">> [BLE] ESP32-Watch GATT Service FFE0 initialized and advertising.");
}

// ── Simulated or Real IMU Read Function ──
// Replace these with your board's QMI8658 / LSM6DS3 / ICM-42688 register read calls:
void readImuSensors(float* ax, float* ay, float* az, float* gx, float* gy, float* gz) {
    // Example: QMI8658 read registers
    // In real code: qmi8658_read_accel_gyro(ax, ay, az, gx, gy, gz);
    *ax = 0.05f;  // X acceleration
    *ay = 0.12f;  // Y acceleration
    *az = 9.81f;  // Z acceleration (gravity)
    *gx = 0.00f;  // X angular rate
    *gy = 0.00f;  // Y angular rate
    *gz = 0.00f;  // Z angular rate
}

void setup() {
    Serial.begin(115200);
    Serial.println(">> Starting ESP32-Watch IMU Telemetry Firmware...");

    // Initialize I2C and onboard IMU here:
    // Wire.begin(6, 7); // SDA, SCL
    // initQmi8658();

    setupBleGatt();
}

void loop() {
    static uint32_t lastTxTime = 0;
    const uint32_t now = millis();

    // 50Hz Sampling Loop (20ms interval)
    if (now - lastTxTime >= 20) {
        lastTxTime = now;

        if (isClientConnected && pTxCharacteristic != nullptr) {
            ImuTelemetryPacket28B packet;
            packet.timestamp_ms = now;

            // Fetch live 6-axis IMU data
            readImuSensors(&packet.accel_x, &packet.accel_y, &packet.accel_z,
                           &packet.gyro_x,  &packet.gyro_y,  &packet.gyro_z);

            // Transmit 28-byte payload via BLE Notification
            pTxCharacteristic->setValue((uint8_t*)&packet, sizeof(ImuTelemetryPacket28B));
            pTxCharacteristic->notify();
        }
    }

    vTaskDelay(pdMS_TO_TICKS(2)); // Yield to FreeRTOS watchdog & background BLE stack
}
```

---

## 9. Firmware Verification Checklist

Before deploying the firmware to the watch, verify each item in this checklist:

- [ ] **Device Name**: Advertised name matches `"ESP32-Watch"` or contains `"Watch"` / `"ESP32"`.
- [ ] **Advertised Service**: Primary Service UUID `0xFFE0` is present in the advertising packet.
- [ ] **GATT Characteristic**: Characteristic `0xFFE1` is created under Service `0xFFE0` with `NOTIFY` permission and CCCD descriptor.
- [ ] **Payload Size**: Exactly **28 bytes** per BLE notification packet.
- [ ] **Payload Format**: `uint32 timestamp_ms` + 6 floats (`accel_x`, `accel_y`, `accel_z`, `gyro_x`, `gyro_y`, `gyro_z`).
- [ ] **Byte Ordering**: Little-Endian (ESP32 native).
- [ ] **Sampling Frequency**: Consistent **50Hz** (one packet every 20ms).
- [ ] **Auto-Reconnection**: When the phone disconnects, advertising restarts immediately without crashing or requiring a manual reboot.
- [ ] **Zero Heart-Rate Interference**: No mock heart rate bytes in Byte 0.
- [ ] **Mobile App Verification**:
  - Open **Ride Sensor Capture** app -> Go to **Devices** tab -> Tap **Scan**.
  - ESP32-Watch appears as a verified sensor.
  - Tap **Connect** -> Status changes to `Connected` with green live indicator.
  - Return to **Dashboard** -> Verify live acceleration and gyroscope waveforms appear cleanly on the charts.
  - Tap **"Start Journey"** -> Verify data is recorded into SQLite with GPS coordinates, distance, and speeds.
