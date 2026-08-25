import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:ride_sensor_capture/data/local_db/database.dart';
import 'package:ride_sensor_capture/data/repositories/sensor_repository_impl.dart';
import 'package:ride_sensor_capture/ble/models/raw_sensor_data.dart';
import 'package:ride_sensor_capture/ble/models/ble_device_model.dart';

void main() {
  late AppDatabase db;
  late SensorRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SensorRepositoryImpl(db);
  });

  tearDown(() async {
    repo.dispose();
    await db.close();
  });

  test('Writes raw sensor readings with monotonic sequence numbers per device', () async {
    final reading1 = RawSensorData(
      deviceId: 'device-polar-01',
      deviceName: 'Polar Verity',
      deviceType: DeviceType.verityBand,
      timestamp: DateTime.now(),
      heartRate: 72,
      ppiMs: 833,
      rawBytes: [0x10, 0x48, 0x50, 0x03],
    );

    final reading2 = RawSensorData(
      deviceId: 'device-esp32-01',
      deviceName: 'ESP32 Watch',
      deviceType: DeviceType.watch,
      timestamp: DateTime.now(),
      heartRate: 74,
      accelX: 0.12,
      accelY: -0.45,
      accelZ: 9.81,
      rawBytes: [74, 0, 0, 0],
    );

    final reading3 = RawSensorData(
      deviceId: 'device-polar-01',
      deviceName: 'Polar Verity',
      deviceType: DeviceType.verityBand,
      timestamp: DateTime.now(),
      heartRate: 75,
      rawBytes: [0x00, 0x4B],
    );

    await repo.insertReadingsBatch([reading1, reading2, reading3]);

    final total = await repo.getTotalCount();
    expect(total, 3);

    final counts = await repo.getCountPerDevice();
    expect(counts['device-polar-01'], 2);
    expect(counts['device-esp32-01'], 1);

    final polarRows = await repo.watchReadingsForDevice('device-polar-01').first;
    expect(polarRows.length, 2);
    // Rows ordered desc by sequenceNo
    expect(polarRows.first.sequenceNo, 2);
    expect(polarRows.last.sequenceNo, 1);
    expect(polarRows.last.heartRate, 72);
    expect(polarRows.last.ppiMs, 833);
  });
}
