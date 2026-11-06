// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SensorReadingsTable extends SensorReadings
    with TableInfo<$SensorReadingsTable, SensorReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceTypeMeta = const VerificationMeta(
    'deviceType',
  );
  @override
  late final GeneratedColumn<String> deviceType = GeneratedColumn<String>(
    'device_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceNoMeta = const VerificationMeta(
    'sequenceNo',
  );
  @override
  late final GeneratedColumn<int> sequenceNo = GeneratedColumn<int>(
    'sequence_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampUtcMeta = const VerificationMeta(
    'timestampUtc',
  );
  @override
  late final GeneratedColumn<DateTime> timestampUtc = GeneratedColumn<DateTime>(
    'timestamp_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensorTypeMeta = const VerificationMeta(
    'sensorType',
  );
  @override
  late final GeneratedColumn<String> sensorType = GeneratedColumn<String>(
    'sensor_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mountLocationMeta = const VerificationMeta(
    'mountLocation',
  );
  @override
  late final GeneratedColumn<String> mountLocation = GeneratedColumn<String>(
    'mount_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fork'),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heartRateMeta = const VerificationMeta(
    'heartRate',
  );
  @override
  late final GeneratedColumn<int> heartRate = GeneratedColumn<int>(
    'heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelXMeta = const VerificationMeta('accelX');
  @override
  late final GeneratedColumn<double> accelX = GeneratedColumn<double>(
    'accel_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelYMeta = const VerificationMeta('accelY');
  @override
  late final GeneratedColumn<double> accelY = GeneratedColumn<double>(
    'accel_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelZMeta = const VerificationMeta('accelZ');
  @override
  late final GeneratedColumn<double> accelZ = GeneratedColumn<double>(
    'accel_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroXMeta = const VerificationMeta('gyroX');
  @override
  late final GeneratedColumn<double> gyroX = GeneratedColumn<double>(
    'gyro_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroYMeta = const VerificationMeta('gyroY');
  @override
  late final GeneratedColumn<double> gyroY = GeneratedColumn<double>(
    'gyro_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroZMeta = const VerificationMeta('gyroZ');
  @override
  late final GeneratedColumn<double> gyroZ = GeneratedColumn<double>(
    'gyro_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ppiMsMeta = const VerificationMeta('ppiMs');
  @override
  late final GeneratedColumn<int> ppiMs = GeneratedColumn<int>(
    'ppi_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsSpeedKmhMeta = const VerificationMeta(
    'gpsSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> gpsSpeedKmh = GeneratedColumn<double>(
    'gps_speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linearAccelXMeta = const VerificationMeta(
    'linearAccelX',
  );
  @override
  late final GeneratedColumn<double> linearAccelX = GeneratedColumn<double>(
    'linear_accel_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linearAccelYMeta = const VerificationMeta(
    'linearAccelY',
  );
  @override
  late final GeneratedColumn<double> linearAccelY = GeneratedColumn<double>(
    'linear_accel_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linearAccelZMeta = const VerificationMeta(
    'linearAccelZ',
  );
  @override
  late final GeneratedColumn<double> linearAccelZ = GeneratedColumn<double>(
    'linear_accel_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quatWMeta = const VerificationMeta('quatW');
  @override
  late final GeneratedColumn<double> quatW = GeneratedColumn<double>(
    'quat_w',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quatXMeta = const VerificationMeta('quatX');
  @override
  late final GeneratedColumn<double> quatX = GeneratedColumn<double>(
    'quat_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quatYMeta = const VerificationMeta('quatY');
  @override
  late final GeneratedColumn<double> quatY = GeneratedColumn<double>(
    'quat_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quatZMeta = const VerificationMeta('quatZ');
  @override
  late final GeneratedColumn<double> quatZ = GeneratedColumn<double>(
    'quat_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMonotonicMicrosMeta =
      const VerificationMeta('timestampMonotonicMicros');
  @override
  late final GeneratedColumn<int> timestampMonotonicMicros =
      GeneratedColumn<int>(
        'timestamp_monotonic_micros',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _barometerAltitudeMMeta =
      const VerificationMeta('barometerAltitudeM');
  @override
  late final GeneratedColumn<double> barometerAltitudeM =
      GeneratedColumn<double>(
        'barometer_altitude_m',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rawPayloadMeta = const VerificationMeta(
    'rawPayload',
  );
  @override
  late final GeneratedColumn<String> rawPayload = GeneratedColumn<String>(
    'raw_payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    deviceType,
    sequenceNo,
    timestampUtc,
    sensorType,
    mountLocation,
    eventId,
    tripId,
    heartRate,
    accelX,
    accelY,
    accelZ,
    gyroX,
    gyroY,
    gyroZ,
    ppiMs,
    gpsSpeedKmh,
    linearAccelX,
    linearAccelY,
    linearAccelZ,
    quatW,
    quatX,
    quatY,
    quatZ,
    timestampMonotonicMicros,
    barometerAltitudeM,
    rawPayload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SensorReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_type')) {
      context.handle(
        _deviceTypeMeta,
        deviceType.isAcceptableOrUnknown(data['device_type']!, _deviceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceTypeMeta);
    }
    if (data.containsKey('sequence_no')) {
      context.handle(
        _sequenceNoMeta,
        sequenceNo.isAcceptableOrUnknown(data['sequence_no']!, _sequenceNoMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceNoMeta);
    }
    if (data.containsKey('timestamp_utc')) {
      context.handle(
        _timestampUtcMeta,
        timestampUtc.isAcceptableOrUnknown(
          data['timestamp_utc']!,
          _timestampUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampUtcMeta);
    }
    if (data.containsKey('sensor_type')) {
      context.handle(
        _sensorTypeMeta,
        sensorType.isAcceptableOrUnknown(data['sensor_type']!, _sensorTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sensorTypeMeta);
    }
    if (data.containsKey('mount_location')) {
      context.handle(
        _mountLocationMeta,
        mountLocation.isAcceptableOrUnknown(
          data['mount_location']!,
          _mountLocationMeta,
        ),
      );
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    if (data.containsKey('heart_rate')) {
      context.handle(
        _heartRateMeta,
        heartRate.isAcceptableOrUnknown(data['heart_rate']!, _heartRateMeta),
      );
    }
    if (data.containsKey('accel_x')) {
      context.handle(
        _accelXMeta,
        accelX.isAcceptableOrUnknown(data['accel_x']!, _accelXMeta),
      );
    }
    if (data.containsKey('accel_y')) {
      context.handle(
        _accelYMeta,
        accelY.isAcceptableOrUnknown(data['accel_y']!, _accelYMeta),
      );
    }
    if (data.containsKey('accel_z')) {
      context.handle(
        _accelZMeta,
        accelZ.isAcceptableOrUnknown(data['accel_z']!, _accelZMeta),
      );
    }
    if (data.containsKey('gyro_x')) {
      context.handle(
        _gyroXMeta,
        gyroX.isAcceptableOrUnknown(data['gyro_x']!, _gyroXMeta),
      );
    }
    if (data.containsKey('gyro_y')) {
      context.handle(
        _gyroYMeta,
        gyroY.isAcceptableOrUnknown(data['gyro_y']!, _gyroYMeta),
      );
    }
    if (data.containsKey('gyro_z')) {
      context.handle(
        _gyroZMeta,
        gyroZ.isAcceptableOrUnknown(data['gyro_z']!, _gyroZMeta),
      );
    }
    if (data.containsKey('ppi_ms')) {
      context.handle(
        _ppiMsMeta,
        ppiMs.isAcceptableOrUnknown(data['ppi_ms']!, _ppiMsMeta),
      );
    }
    if (data.containsKey('gps_speed_kmh')) {
      context.handle(
        _gpsSpeedKmhMeta,
        gpsSpeedKmh.isAcceptableOrUnknown(
          data['gps_speed_kmh']!,
          _gpsSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('linear_accel_x')) {
      context.handle(
        _linearAccelXMeta,
        linearAccelX.isAcceptableOrUnknown(
          data['linear_accel_x']!,
          _linearAccelXMeta,
        ),
      );
    }
    if (data.containsKey('linear_accel_y')) {
      context.handle(
        _linearAccelYMeta,
        linearAccelY.isAcceptableOrUnknown(
          data['linear_accel_y']!,
          _linearAccelYMeta,
        ),
      );
    }
    if (data.containsKey('linear_accel_z')) {
      context.handle(
        _linearAccelZMeta,
        linearAccelZ.isAcceptableOrUnknown(
          data['linear_accel_z']!,
          _linearAccelZMeta,
        ),
      );
    }
    if (data.containsKey('quat_w')) {
      context.handle(
        _quatWMeta,
        quatW.isAcceptableOrUnknown(data['quat_w']!, _quatWMeta),
      );
    }
    if (data.containsKey('quat_x')) {
      context.handle(
        _quatXMeta,
        quatX.isAcceptableOrUnknown(data['quat_x']!, _quatXMeta),
      );
    }
    if (data.containsKey('quat_y')) {
      context.handle(
        _quatYMeta,
        quatY.isAcceptableOrUnknown(data['quat_y']!, _quatYMeta),
      );
    }
    if (data.containsKey('quat_z')) {
      context.handle(
        _quatZMeta,
        quatZ.isAcceptableOrUnknown(data['quat_z']!, _quatZMeta),
      );
    }
    if (data.containsKey('timestamp_monotonic_micros')) {
      context.handle(
        _timestampMonotonicMicrosMeta,
        timestampMonotonicMicros.isAcceptableOrUnknown(
          data['timestamp_monotonic_micros']!,
          _timestampMonotonicMicrosMeta,
        ),
      );
    }
    if (data.containsKey('barometer_altitude_m')) {
      context.handle(
        _barometerAltitudeMMeta,
        barometerAltitudeM.isAcceptableOrUnknown(
          data['barometer_altitude_m']!,
          _barometerAltitudeMMeta,
        ),
      );
    }
    if (data.containsKey('raw_payload')) {
      context.handle(
        _rawPayloadMeta,
        rawPayload.isAcceptableOrUnknown(data['raw_payload']!, _rawPayloadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_type'],
      )!,
      sequenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_no'],
      )!,
      timestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp_utc'],
      )!,
      sensorType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sensor_type'],
      )!,
      mountLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mount_location'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      ),
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      ),
      heartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate'],
      ),
      accelX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accel_x'],
      ),
      accelY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accel_y'],
      ),
      accelZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accel_z'],
      ),
      gyroX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyro_x'],
      ),
      gyroY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyro_y'],
      ),
      gyroZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyro_z'],
      ),
      ppiMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ppi_ms'],
      ),
      gpsSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_speed_kmh'],
      ),
      linearAccelX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}linear_accel_x'],
      ),
      linearAccelY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}linear_accel_y'],
      ),
      linearAccelZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}linear_accel_z'],
      ),
      quatW: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quat_w'],
      ),
      quatX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quat_x'],
      ),
      quatY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quat_y'],
      ),
      quatZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quat_z'],
      ),
      timestampMonotonicMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_monotonic_micros'],
      ),
      barometerAltitudeM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}barometer_altitude_m'],
      ),
      rawPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_payload'],
      ),
    );
  }

  @override
  $SensorReadingsTable createAlias(String alias) {
    return $SensorReadingsTable(attachedDatabase, alias);
  }
}

class SensorReading extends DataClass implements Insertable<SensorReading> {
  final int id;
  final String deviceId;
  final String deviceType;
  final int sequenceNo;
  final DateTime timestampUtc;
  final String sensorType;
  final String mountLocation;
  final int? eventId;
  final int? tripId;
  final int? heartRate;
  final double? accelX;
  final double? accelY;
  final double? accelZ;
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;
  final int? ppiMs;
  final double? gpsSpeedKmh;
  final double? linearAccelX;
  final double? linearAccelY;
  final double? linearAccelZ;
  final double? quatW;
  final double? quatX;
  final double? quatY;
  final double? quatZ;
  final int? timestampMonotonicMicros;
  final double? barometerAltitudeM;
  final String? rawPayload;
  const SensorReading({
    required this.id,
    required this.deviceId,
    required this.deviceType,
    required this.sequenceNo,
    required this.timestampUtc,
    required this.sensorType,
    required this.mountLocation,
    this.eventId,
    this.tripId,
    this.heartRate,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.ppiMs,
    this.gpsSpeedKmh,
    this.linearAccelX,
    this.linearAccelY,
    this.linearAccelZ,
    this.quatW,
    this.quatX,
    this.quatY,
    this.quatZ,
    this.timestampMonotonicMicros,
    this.barometerAltitudeM,
    this.rawPayload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['device_type'] = Variable<String>(deviceType);
    map['sequence_no'] = Variable<int>(sequenceNo);
    map['timestamp_utc'] = Variable<DateTime>(timestampUtc);
    map['sensor_type'] = Variable<String>(sensorType);
    map['mount_location'] = Variable<String>(mountLocation);
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<int>(eventId);
    }
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    if (!nullToAbsent || heartRate != null) {
      map['heart_rate'] = Variable<int>(heartRate);
    }
    if (!nullToAbsent || accelX != null) {
      map['accel_x'] = Variable<double>(accelX);
    }
    if (!nullToAbsent || accelY != null) {
      map['accel_y'] = Variable<double>(accelY);
    }
    if (!nullToAbsent || accelZ != null) {
      map['accel_z'] = Variable<double>(accelZ);
    }
    if (!nullToAbsent || gyroX != null) {
      map['gyro_x'] = Variable<double>(gyroX);
    }
    if (!nullToAbsent || gyroY != null) {
      map['gyro_y'] = Variable<double>(gyroY);
    }
    if (!nullToAbsent || gyroZ != null) {
      map['gyro_z'] = Variable<double>(gyroZ);
    }
    if (!nullToAbsent || ppiMs != null) {
      map['ppi_ms'] = Variable<int>(ppiMs);
    }
    if (!nullToAbsent || gpsSpeedKmh != null) {
      map['gps_speed_kmh'] = Variable<double>(gpsSpeedKmh);
    }
    if (!nullToAbsent || linearAccelX != null) {
      map['linear_accel_x'] = Variable<double>(linearAccelX);
    }
    if (!nullToAbsent || linearAccelY != null) {
      map['linear_accel_y'] = Variable<double>(linearAccelY);
    }
    if (!nullToAbsent || linearAccelZ != null) {
      map['linear_accel_z'] = Variable<double>(linearAccelZ);
    }
    if (!nullToAbsent || quatW != null) {
      map['quat_w'] = Variable<double>(quatW);
    }
    if (!nullToAbsent || quatX != null) {
      map['quat_x'] = Variable<double>(quatX);
    }
    if (!nullToAbsent || quatY != null) {
      map['quat_y'] = Variable<double>(quatY);
    }
    if (!nullToAbsent || quatZ != null) {
      map['quat_z'] = Variable<double>(quatZ);
    }
    if (!nullToAbsent || timestampMonotonicMicros != null) {
      map['timestamp_monotonic_micros'] = Variable<int>(
        timestampMonotonicMicros,
      );
    }
    if (!nullToAbsent || barometerAltitudeM != null) {
      map['barometer_altitude_m'] = Variable<double>(barometerAltitudeM);
    }
    if (!nullToAbsent || rawPayload != null) {
      map['raw_payload'] = Variable<String>(rawPayload);
    }
    return map;
  }

  SensorReadingsCompanion toCompanion(bool nullToAbsent) {
    return SensorReadingsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      deviceType: Value(deviceType),
      sequenceNo: Value(sequenceNo),
      timestampUtc: Value(timestampUtc),
      sensorType: Value(sensorType),
      mountLocation: Value(mountLocation),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
      heartRate: heartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRate),
      accelX: accelX == null && nullToAbsent
          ? const Value.absent()
          : Value(accelX),
      accelY: accelY == null && nullToAbsent
          ? const Value.absent()
          : Value(accelY),
      accelZ: accelZ == null && nullToAbsent
          ? const Value.absent()
          : Value(accelZ),
      gyroX: gyroX == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroX),
      gyroY: gyroY == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroY),
      gyroZ: gyroZ == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroZ),
      ppiMs: ppiMs == null && nullToAbsent
          ? const Value.absent()
          : Value(ppiMs),
      gpsSpeedKmh: gpsSpeedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsSpeedKmh),
      linearAccelX: linearAccelX == null && nullToAbsent
          ? const Value.absent()
          : Value(linearAccelX),
      linearAccelY: linearAccelY == null && nullToAbsent
          ? const Value.absent()
          : Value(linearAccelY),
      linearAccelZ: linearAccelZ == null && nullToAbsent
          ? const Value.absent()
          : Value(linearAccelZ),
      quatW: quatW == null && nullToAbsent
          ? const Value.absent()
          : Value(quatW),
      quatX: quatX == null && nullToAbsent
          ? const Value.absent()
          : Value(quatX),
      quatY: quatY == null && nullToAbsent
          ? const Value.absent()
          : Value(quatY),
      quatZ: quatZ == null && nullToAbsent
          ? const Value.absent()
          : Value(quatZ),
      timestampMonotonicMicros: timestampMonotonicMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(timestampMonotonicMicros),
      barometerAltitudeM: barometerAltitudeM == null && nullToAbsent
          ? const Value.absent()
          : Value(barometerAltitudeM),
      rawPayload: rawPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(rawPayload),
    );
  }

  factory SensorReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorReading(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceType: serializer.fromJson<String>(json['deviceType']),
      sequenceNo: serializer.fromJson<int>(json['sequenceNo']),
      timestampUtc: serializer.fromJson<DateTime>(json['timestampUtc']),
      sensorType: serializer.fromJson<String>(json['sensorType']),
      mountLocation: serializer.fromJson<String>(json['mountLocation']),
      eventId: serializer.fromJson<int?>(json['eventId']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      heartRate: serializer.fromJson<int?>(json['heartRate']),
      accelX: serializer.fromJson<double?>(json['accelX']),
      accelY: serializer.fromJson<double?>(json['accelY']),
      accelZ: serializer.fromJson<double?>(json['accelZ']),
      gyroX: serializer.fromJson<double?>(json['gyroX']),
      gyroY: serializer.fromJson<double?>(json['gyroY']),
      gyroZ: serializer.fromJson<double?>(json['gyroZ']),
      ppiMs: serializer.fromJson<int?>(json['ppiMs']),
      gpsSpeedKmh: serializer.fromJson<double?>(json['gpsSpeedKmh']),
      linearAccelX: serializer.fromJson<double?>(json['linearAccelX']),
      linearAccelY: serializer.fromJson<double?>(json['linearAccelY']),
      linearAccelZ: serializer.fromJson<double?>(json['linearAccelZ']),
      quatW: serializer.fromJson<double?>(json['quatW']),
      quatX: serializer.fromJson<double?>(json['quatX']),
      quatY: serializer.fromJson<double?>(json['quatY']),
      quatZ: serializer.fromJson<double?>(json['quatZ']),
      timestampMonotonicMicros: serializer.fromJson<int?>(
        json['timestampMonotonicMicros'],
      ),
      barometerAltitudeM: serializer.fromJson<double?>(
        json['barometerAltitudeM'],
      ),
      rawPayload: serializer.fromJson<String?>(json['rawPayload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceType': serializer.toJson<String>(deviceType),
      'sequenceNo': serializer.toJson<int>(sequenceNo),
      'timestampUtc': serializer.toJson<DateTime>(timestampUtc),
      'sensorType': serializer.toJson<String>(sensorType),
      'mountLocation': serializer.toJson<String>(mountLocation),
      'eventId': serializer.toJson<int?>(eventId),
      'tripId': serializer.toJson<int?>(tripId),
      'heartRate': serializer.toJson<int?>(heartRate),
      'accelX': serializer.toJson<double?>(accelX),
      'accelY': serializer.toJson<double?>(accelY),
      'accelZ': serializer.toJson<double?>(accelZ),
      'gyroX': serializer.toJson<double?>(gyroX),
      'gyroY': serializer.toJson<double?>(gyroY),
      'gyroZ': serializer.toJson<double?>(gyroZ),
      'ppiMs': serializer.toJson<int?>(ppiMs),
      'gpsSpeedKmh': serializer.toJson<double?>(gpsSpeedKmh),
      'linearAccelX': serializer.toJson<double?>(linearAccelX),
      'linearAccelY': serializer.toJson<double?>(linearAccelY),
      'linearAccelZ': serializer.toJson<double?>(linearAccelZ),
      'quatW': serializer.toJson<double?>(quatW),
      'quatX': serializer.toJson<double?>(quatX),
      'quatY': serializer.toJson<double?>(quatY),
      'quatZ': serializer.toJson<double?>(quatZ),
      'timestampMonotonicMicros': serializer.toJson<int?>(
        timestampMonotonicMicros,
      ),
      'barometerAltitudeM': serializer.toJson<double?>(barometerAltitudeM),
      'rawPayload': serializer.toJson<String?>(rawPayload),
    };
  }

  SensorReading copyWith({
    int? id,
    String? deviceId,
    String? deviceType,
    int? sequenceNo,
    DateTime? timestampUtc,
    String? sensorType,
    String? mountLocation,
    Value<int?> eventId = const Value.absent(),
    Value<int?> tripId = const Value.absent(),
    Value<int?> heartRate = const Value.absent(),
    Value<double?> accelX = const Value.absent(),
    Value<double?> accelY = const Value.absent(),
    Value<double?> accelZ = const Value.absent(),
    Value<double?> gyroX = const Value.absent(),
    Value<double?> gyroY = const Value.absent(),
    Value<double?> gyroZ = const Value.absent(),
    Value<int?> ppiMs = const Value.absent(),
    Value<double?> gpsSpeedKmh = const Value.absent(),
    Value<double?> linearAccelX = const Value.absent(),
    Value<double?> linearAccelY = const Value.absent(),
    Value<double?> linearAccelZ = const Value.absent(),
    Value<double?> quatW = const Value.absent(),
    Value<double?> quatX = const Value.absent(),
    Value<double?> quatY = const Value.absent(),
    Value<double?> quatZ = const Value.absent(),
    Value<int?> timestampMonotonicMicros = const Value.absent(),
    Value<double?> barometerAltitudeM = const Value.absent(),
    Value<String?> rawPayload = const Value.absent(),
  }) => SensorReading(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    deviceType: deviceType ?? this.deviceType,
    sequenceNo: sequenceNo ?? this.sequenceNo,
    timestampUtc: timestampUtc ?? this.timestampUtc,
    sensorType: sensorType ?? this.sensorType,
    mountLocation: mountLocation ?? this.mountLocation,
    eventId: eventId.present ? eventId.value : this.eventId,
    tripId: tripId.present ? tripId.value : this.tripId,
    heartRate: heartRate.present ? heartRate.value : this.heartRate,
    accelX: accelX.present ? accelX.value : this.accelX,
    accelY: accelY.present ? accelY.value : this.accelY,
    accelZ: accelZ.present ? accelZ.value : this.accelZ,
    gyroX: gyroX.present ? gyroX.value : this.gyroX,
    gyroY: gyroY.present ? gyroY.value : this.gyroY,
    gyroZ: gyroZ.present ? gyroZ.value : this.gyroZ,
    ppiMs: ppiMs.present ? ppiMs.value : this.ppiMs,
    gpsSpeedKmh: gpsSpeedKmh.present ? gpsSpeedKmh.value : this.gpsSpeedKmh,
    linearAccelX: linearAccelX.present ? linearAccelX.value : this.linearAccelX,
    linearAccelY: linearAccelY.present ? linearAccelY.value : this.linearAccelY,
    linearAccelZ: linearAccelZ.present ? linearAccelZ.value : this.linearAccelZ,
    quatW: quatW.present ? quatW.value : this.quatW,
    quatX: quatX.present ? quatX.value : this.quatX,
    quatY: quatY.present ? quatY.value : this.quatY,
    quatZ: quatZ.present ? quatZ.value : this.quatZ,
    timestampMonotonicMicros: timestampMonotonicMicros.present
        ? timestampMonotonicMicros.value
        : this.timestampMonotonicMicros,
    barometerAltitudeM: barometerAltitudeM.present
        ? barometerAltitudeM.value
        : this.barometerAltitudeM,
    rawPayload: rawPayload.present ? rawPayload.value : this.rawPayload,
  );
  SensorReading copyWithCompanion(SensorReadingsCompanion data) {
    return SensorReading(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceType: data.deviceType.present
          ? data.deviceType.value
          : this.deviceType,
      sequenceNo: data.sequenceNo.present
          ? data.sequenceNo.value
          : this.sequenceNo,
      timestampUtc: data.timestampUtc.present
          ? data.timestampUtc.value
          : this.timestampUtc,
      sensorType: data.sensorType.present
          ? data.sensorType.value
          : this.sensorType,
      mountLocation: data.mountLocation.present
          ? data.mountLocation.value
          : this.mountLocation,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      heartRate: data.heartRate.present ? data.heartRate.value : this.heartRate,
      accelX: data.accelX.present ? data.accelX.value : this.accelX,
      accelY: data.accelY.present ? data.accelY.value : this.accelY,
      accelZ: data.accelZ.present ? data.accelZ.value : this.accelZ,
      gyroX: data.gyroX.present ? data.gyroX.value : this.gyroX,
      gyroY: data.gyroY.present ? data.gyroY.value : this.gyroY,
      gyroZ: data.gyroZ.present ? data.gyroZ.value : this.gyroZ,
      ppiMs: data.ppiMs.present ? data.ppiMs.value : this.ppiMs,
      gpsSpeedKmh: data.gpsSpeedKmh.present
          ? data.gpsSpeedKmh.value
          : this.gpsSpeedKmh,
      linearAccelX: data.linearAccelX.present
          ? data.linearAccelX.value
          : this.linearAccelX,
      linearAccelY: data.linearAccelY.present
          ? data.linearAccelY.value
          : this.linearAccelY,
      linearAccelZ: data.linearAccelZ.present
          ? data.linearAccelZ.value
          : this.linearAccelZ,
      quatW: data.quatW.present ? data.quatW.value : this.quatW,
      quatX: data.quatX.present ? data.quatX.value : this.quatX,
      quatY: data.quatY.present ? data.quatY.value : this.quatY,
      quatZ: data.quatZ.present ? data.quatZ.value : this.quatZ,
      timestampMonotonicMicros: data.timestampMonotonicMicros.present
          ? data.timestampMonotonicMicros.value
          : this.timestampMonotonicMicros,
      barometerAltitudeM: data.barometerAltitudeM.present
          ? data.barometerAltitudeM.value
          : this.barometerAltitudeM,
      rawPayload: data.rawPayload.present
          ? data.rawPayload.value
          : this.rawPayload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorReading(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceType: $deviceType, ')
          ..write('sequenceNo: $sequenceNo, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('sensorType: $sensorType, ')
          ..write('mountLocation: $mountLocation, ')
          ..write('eventId: $eventId, ')
          ..write('tripId: $tripId, ')
          ..write('heartRate: $heartRate, ')
          ..write('accelX: $accelX, ')
          ..write('accelY: $accelY, ')
          ..write('accelZ: $accelZ, ')
          ..write('gyroX: $gyroX, ')
          ..write('gyroY: $gyroY, ')
          ..write('gyroZ: $gyroZ, ')
          ..write('ppiMs: $ppiMs, ')
          ..write('gpsSpeedKmh: $gpsSpeedKmh, ')
          ..write('linearAccelX: $linearAccelX, ')
          ..write('linearAccelY: $linearAccelY, ')
          ..write('linearAccelZ: $linearAccelZ, ')
          ..write('quatW: $quatW, ')
          ..write('quatX: $quatX, ')
          ..write('quatY: $quatY, ')
          ..write('quatZ: $quatZ, ')
          ..write('timestampMonotonicMicros: $timestampMonotonicMicros, ')
          ..write('barometerAltitudeM: $barometerAltitudeM, ')
          ..write('rawPayload: $rawPayload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    deviceId,
    deviceType,
    sequenceNo,
    timestampUtc,
    sensorType,
    mountLocation,
    eventId,
    tripId,
    heartRate,
    accelX,
    accelY,
    accelZ,
    gyroX,
    gyroY,
    gyroZ,
    ppiMs,
    gpsSpeedKmh,
    linearAccelX,
    linearAccelY,
    linearAccelZ,
    quatW,
    quatX,
    quatY,
    quatZ,
    timestampMonotonicMicros,
    barometerAltitudeM,
    rawPayload,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorReading &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.deviceType == this.deviceType &&
          other.sequenceNo == this.sequenceNo &&
          other.timestampUtc == this.timestampUtc &&
          other.sensorType == this.sensorType &&
          other.mountLocation == this.mountLocation &&
          other.eventId == this.eventId &&
          other.tripId == this.tripId &&
          other.heartRate == this.heartRate &&
          other.accelX == this.accelX &&
          other.accelY == this.accelY &&
          other.accelZ == this.accelZ &&
          other.gyroX == this.gyroX &&
          other.gyroY == this.gyroY &&
          other.gyroZ == this.gyroZ &&
          other.ppiMs == this.ppiMs &&
          other.gpsSpeedKmh == this.gpsSpeedKmh &&
          other.linearAccelX == this.linearAccelX &&
          other.linearAccelY == this.linearAccelY &&
          other.linearAccelZ == this.linearAccelZ &&
          other.quatW == this.quatW &&
          other.quatX == this.quatX &&
          other.quatY == this.quatY &&
          other.quatZ == this.quatZ &&
          other.timestampMonotonicMicros == this.timestampMonotonicMicros &&
          other.barometerAltitudeM == this.barometerAltitudeM &&
          other.rawPayload == this.rawPayload);
}

class SensorReadingsCompanion extends UpdateCompanion<SensorReading> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String> deviceType;
  final Value<int> sequenceNo;
  final Value<DateTime> timestampUtc;
  final Value<String> sensorType;
  final Value<String> mountLocation;
  final Value<int?> eventId;
  final Value<int?> tripId;
  final Value<int?> heartRate;
  final Value<double?> accelX;
  final Value<double?> accelY;
  final Value<double?> accelZ;
  final Value<double?> gyroX;
  final Value<double?> gyroY;
  final Value<double?> gyroZ;
  final Value<int?> ppiMs;
  final Value<double?> gpsSpeedKmh;
  final Value<double?> linearAccelX;
  final Value<double?> linearAccelY;
  final Value<double?> linearAccelZ;
  final Value<double?> quatW;
  final Value<double?> quatX;
  final Value<double?> quatY;
  final Value<double?> quatZ;
  final Value<int?> timestampMonotonicMicros;
  final Value<double?> barometerAltitudeM;
  final Value<String?> rawPayload;
  const SensorReadingsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceType = const Value.absent(),
    this.sequenceNo = const Value.absent(),
    this.timestampUtc = const Value.absent(),
    this.sensorType = const Value.absent(),
    this.mountLocation = const Value.absent(),
    this.eventId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.accelX = const Value.absent(),
    this.accelY = const Value.absent(),
    this.accelZ = const Value.absent(),
    this.gyroX = const Value.absent(),
    this.gyroY = const Value.absent(),
    this.gyroZ = const Value.absent(),
    this.ppiMs = const Value.absent(),
    this.gpsSpeedKmh = const Value.absent(),
    this.linearAccelX = const Value.absent(),
    this.linearAccelY = const Value.absent(),
    this.linearAccelZ = const Value.absent(),
    this.quatW = const Value.absent(),
    this.quatX = const Value.absent(),
    this.quatY = const Value.absent(),
    this.quatZ = const Value.absent(),
    this.timestampMonotonicMicros = const Value.absent(),
    this.barometerAltitudeM = const Value.absent(),
    this.rawPayload = const Value.absent(),
  });
  SensorReadingsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required String deviceType,
    required int sequenceNo,
    required DateTime timestampUtc,
    required String sensorType,
    this.mountLocation = const Value.absent(),
    this.eventId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.accelX = const Value.absent(),
    this.accelY = const Value.absent(),
    this.accelZ = const Value.absent(),
    this.gyroX = const Value.absent(),
    this.gyroY = const Value.absent(),
    this.gyroZ = const Value.absent(),
    this.ppiMs = const Value.absent(),
    this.gpsSpeedKmh = const Value.absent(),
    this.linearAccelX = const Value.absent(),
    this.linearAccelY = const Value.absent(),
    this.linearAccelZ = const Value.absent(),
    this.quatW = const Value.absent(),
    this.quatX = const Value.absent(),
    this.quatY = const Value.absent(),
    this.quatZ = const Value.absent(),
    this.timestampMonotonicMicros = const Value.absent(),
    this.barometerAltitudeM = const Value.absent(),
    this.rawPayload = const Value.absent(),
  }) : deviceId = Value(deviceId),
       deviceType = Value(deviceType),
       sequenceNo = Value(sequenceNo),
       timestampUtc = Value(timestampUtc),
       sensorType = Value(sensorType);
  static Insertable<SensorReading> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? deviceType,
    Expression<int>? sequenceNo,
    Expression<DateTime>? timestampUtc,
    Expression<String>? sensorType,
    Expression<String>? mountLocation,
    Expression<int>? eventId,
    Expression<int>? tripId,
    Expression<int>? heartRate,
    Expression<double>? accelX,
    Expression<double>? accelY,
    Expression<double>? accelZ,
    Expression<double>? gyroX,
    Expression<double>? gyroY,
    Expression<double>? gyroZ,
    Expression<int>? ppiMs,
    Expression<double>? gpsSpeedKmh,
    Expression<double>? linearAccelX,
    Expression<double>? linearAccelY,
    Expression<double>? linearAccelZ,
    Expression<double>? quatW,
    Expression<double>? quatX,
    Expression<double>? quatY,
    Expression<double>? quatZ,
    Expression<int>? timestampMonotonicMicros,
    Expression<double>? barometerAltitudeM,
    Expression<String>? rawPayload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceType != null) 'device_type': deviceType,
      if (sequenceNo != null) 'sequence_no': sequenceNo,
      if (timestampUtc != null) 'timestamp_utc': timestampUtc,
      if (sensorType != null) 'sensor_type': sensorType,
      if (mountLocation != null) 'mount_location': mountLocation,
      if (eventId != null) 'event_id': eventId,
      if (tripId != null) 'trip_id': tripId,
      if (heartRate != null) 'heart_rate': heartRate,
      if (accelX != null) 'accel_x': accelX,
      if (accelY != null) 'accel_y': accelY,
      if (accelZ != null) 'accel_z': accelZ,
      if (gyroX != null) 'gyro_x': gyroX,
      if (gyroY != null) 'gyro_y': gyroY,
      if (gyroZ != null) 'gyro_z': gyroZ,
      if (ppiMs != null) 'ppi_ms': ppiMs,
      if (gpsSpeedKmh != null) 'gps_speed_kmh': gpsSpeedKmh,
      if (linearAccelX != null) 'linear_accel_x': linearAccelX,
      if (linearAccelY != null) 'linear_accel_y': linearAccelY,
      if (linearAccelZ != null) 'linear_accel_z': linearAccelZ,
      if (quatW != null) 'quat_w': quatW,
      if (quatX != null) 'quat_x': quatX,
      if (quatY != null) 'quat_y': quatY,
      if (quatZ != null) 'quat_z': quatZ,
      if (timestampMonotonicMicros != null)
        'timestamp_monotonic_micros': timestampMonotonicMicros,
      if (barometerAltitudeM != null)
        'barometer_altitude_m': barometerAltitudeM,
      if (rawPayload != null) 'raw_payload': rawPayload,
    });
  }

  SensorReadingsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<String>? deviceType,
    Value<int>? sequenceNo,
    Value<DateTime>? timestampUtc,
    Value<String>? sensorType,
    Value<String>? mountLocation,
    Value<int?>? eventId,
    Value<int?>? tripId,
    Value<int?>? heartRate,
    Value<double?>? accelX,
    Value<double?>? accelY,
    Value<double?>? accelZ,
    Value<double?>? gyroX,
    Value<double?>? gyroY,
    Value<double?>? gyroZ,
    Value<int?>? ppiMs,
    Value<double?>? gpsSpeedKmh,
    Value<double?>? linearAccelX,
    Value<double?>? linearAccelY,
    Value<double?>? linearAccelZ,
    Value<double?>? quatW,
    Value<double?>? quatX,
    Value<double?>? quatY,
    Value<double?>? quatZ,
    Value<int?>? timestampMonotonicMicros,
    Value<double?>? barometerAltitudeM,
    Value<String?>? rawPayload,
  }) {
    return SensorReadingsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceType: deviceType ?? this.deviceType,
      sequenceNo: sequenceNo ?? this.sequenceNo,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      sensorType: sensorType ?? this.sensorType,
      mountLocation: mountLocation ?? this.mountLocation,
      eventId: eventId ?? this.eventId,
      tripId: tripId ?? this.tripId,
      heartRate: heartRate ?? this.heartRate,
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      ppiMs: ppiMs ?? this.ppiMs,
      gpsSpeedKmh: gpsSpeedKmh ?? this.gpsSpeedKmh,
      linearAccelX: linearAccelX ?? this.linearAccelX,
      linearAccelY: linearAccelY ?? this.linearAccelY,
      linearAccelZ: linearAccelZ ?? this.linearAccelZ,
      quatW: quatW ?? this.quatW,
      quatX: quatX ?? this.quatX,
      quatY: quatY ?? this.quatY,
      quatZ: quatZ ?? this.quatZ,
      timestampMonotonicMicros:
          timestampMonotonicMicros ?? this.timestampMonotonicMicros,
      barometerAltitudeM: barometerAltitudeM ?? this.barometerAltitudeM,
      rawPayload: rawPayload ?? this.rawPayload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceType.present) {
      map['device_type'] = Variable<String>(deviceType.value);
    }
    if (sequenceNo.present) {
      map['sequence_no'] = Variable<int>(sequenceNo.value);
    }
    if (timestampUtc.present) {
      map['timestamp_utc'] = Variable<DateTime>(timestampUtc.value);
    }
    if (sensorType.present) {
      map['sensor_type'] = Variable<String>(sensorType.value);
    }
    if (mountLocation.present) {
      map['mount_location'] = Variable<String>(mountLocation.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (heartRate.present) {
      map['heart_rate'] = Variable<int>(heartRate.value);
    }
    if (accelX.present) {
      map['accel_x'] = Variable<double>(accelX.value);
    }
    if (accelY.present) {
      map['accel_y'] = Variable<double>(accelY.value);
    }
    if (accelZ.present) {
      map['accel_z'] = Variable<double>(accelZ.value);
    }
    if (gyroX.present) {
      map['gyro_x'] = Variable<double>(gyroX.value);
    }
    if (gyroY.present) {
      map['gyro_y'] = Variable<double>(gyroY.value);
    }
    if (gyroZ.present) {
      map['gyro_z'] = Variable<double>(gyroZ.value);
    }
    if (ppiMs.present) {
      map['ppi_ms'] = Variable<int>(ppiMs.value);
    }
    if (gpsSpeedKmh.present) {
      map['gps_speed_kmh'] = Variable<double>(gpsSpeedKmh.value);
    }
    if (linearAccelX.present) {
      map['linear_accel_x'] = Variable<double>(linearAccelX.value);
    }
    if (linearAccelY.present) {
      map['linear_accel_y'] = Variable<double>(linearAccelY.value);
    }
    if (linearAccelZ.present) {
      map['linear_accel_z'] = Variable<double>(linearAccelZ.value);
    }
    if (quatW.present) {
      map['quat_w'] = Variable<double>(quatW.value);
    }
    if (quatX.present) {
      map['quat_x'] = Variable<double>(quatX.value);
    }
    if (quatY.present) {
      map['quat_y'] = Variable<double>(quatY.value);
    }
    if (quatZ.present) {
      map['quat_z'] = Variable<double>(quatZ.value);
    }
    if (timestampMonotonicMicros.present) {
      map['timestamp_monotonic_micros'] = Variable<int>(
        timestampMonotonicMicros.value,
      );
    }
    if (barometerAltitudeM.present) {
      map['barometer_altitude_m'] = Variable<double>(barometerAltitudeM.value);
    }
    if (rawPayload.present) {
      map['raw_payload'] = Variable<String>(rawPayload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorReadingsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceType: $deviceType, ')
          ..write('sequenceNo: $sequenceNo, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('sensorType: $sensorType, ')
          ..write('mountLocation: $mountLocation, ')
          ..write('eventId: $eventId, ')
          ..write('tripId: $tripId, ')
          ..write('heartRate: $heartRate, ')
          ..write('accelX: $accelX, ')
          ..write('accelY: $accelY, ')
          ..write('accelZ: $accelZ, ')
          ..write('gyroX: $gyroX, ')
          ..write('gyroY: $gyroY, ')
          ..write('gyroZ: $gyroZ, ')
          ..write('ppiMs: $ppiMs, ')
          ..write('gpsSpeedKmh: $gpsSpeedKmh, ')
          ..write('linearAccelX: $linearAccelX, ')
          ..write('linearAccelY: $linearAccelY, ')
          ..write('linearAccelZ: $linearAccelZ, ')
          ..write('quatW: $quatW, ')
          ..write('quatX: $quatX, ')
          ..write('quatY: $quatY, ')
          ..write('quatZ: $quatZ, ')
          ..write('timestampMonotonicMicros: $timestampMonotonicMicros, ')
          ..write('barometerAltitudeM: $barometerAltitudeM, ')
          ..write('rawPayload: $rawPayload')
          ..write(')'))
        .toString();
  }
}

class $EventRecordsTable extends EventRecords
    with TableInfo<$EventRecordsTable, EventRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimestampMeta = const VerificationMeta(
    'startTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> startTimestamp =
      GeneratedColumn<DateTime>(
        'start_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _endTimestampMeta = const VerificationMeta(
    'endTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> endTimestamp = GeneratedColumn<DateTime>(
    'end_timestamp',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startGpsLatMeta = const VerificationMeta(
    'startGpsLat',
  );
  @override
  late final GeneratedColumn<double> startGpsLat = GeneratedColumn<double>(
    'start_gps_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startGpsLngMeta = const VerificationMeta(
    'startGpsLng',
  );
  @override
  late final GeneratedColumn<double> startGpsLng = GeneratedColumn<double>(
    'start_gps_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endGpsLatMeta = const VerificationMeta(
    'endGpsLat',
  );
  @override
  late final GeneratedColumn<double> endGpsLat = GeneratedColumn<double>(
    'end_gps_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endGpsLngMeta = const VerificationMeta(
    'endGpsLng',
  );
  @override
  late final GeneratedColumn<double> endGpsLng = GeneratedColumn<double>(
    'end_gps_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerPhraseMeta = const VerificationMeta(
    'triggerPhrase',
  );
  @override
  late final GeneratedColumn<String> triggerPhrase = GeneratedColumn<String>(
    'trigger_phrase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _computedParametersMeta =
      const VerificationMeta('computedParameters');
  @override
  late final GeneratedColumn<String> computedParameters =
      GeneratedColumn<String>(
        'computed_parameters',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _peakMetricMeta = const VerificationMeta(
    'peakMetric',
  );
  @override
  late final GeneratedColumn<double> peakMetric = GeneratedColumn<double>(
    'peak_metric',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classificationMeta = const VerificationMeta(
    'classification',
  );
  @override
  late final GeneratedColumn<String> classification = GeneratedColumn<String>(
    'classification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _crossConfirmedMeta = const VerificationMeta(
    'crossConfirmed',
  );
  @override
  late final GeneratedColumn<bool> crossConfirmed = GeneratedColumn<bool>(
    'cross_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cross_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _forkFootLagMsMeta = const VerificationMeta(
    'forkFootLagMs',
  );
  @override
  late final GeneratedColumn<double> forkFootLagMs = GeneratedColumn<double>(
    'fork_foot_lag_ms',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hrSpikeConfirmedMeta = const VerificationMeta(
    'hrSpikeConfirmed',
  );
  @override
  late final GeneratedColumn<bool> hrSpikeConfirmed = GeneratedColumn<bool>(
    'hr_spike_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hr_spike_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hrDeltaAtEventMeta = const VerificationMeta(
    'hrDeltaAtEvent',
  );
  @override
  late final GeneratedColumn<double> hrDeltaAtEvent = GeneratedColumn<double>(
    'hr_delta_at_event',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jerkPeakMagnitudeMeta = const VerificationMeta(
    'jerkPeakMagnitude',
  );
  @override
  late final GeneratedColumn<double> jerkPeakMagnitude =
      GeneratedColumn<double>(
        'jerk_peak_magnitude',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _gpsSpeedAtEventKmhMeta =
      const VerificationMeta('gpsSpeedAtEventKmh');
  @override
  late final GeneratedColumn<double> gpsSpeedAtEventKmh =
      GeneratedColumn<double>(
        'gps_speed_at_event_kmh',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _gpsHeadingChangeDegMeta =
      const VerificationMeta('gpsHeadingChangeDeg');
  @override
  late final GeneratedColumn<double> gpsHeadingChangeDeg =
      GeneratedColumn<double>(
        'gps_heading_change_deg',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _audioFilePathMeta = const VerificationMeta(
    'audioFilePath',
  );
  @override
  late final GeneratedColumn<String> audioFilePath = GeneratedColumn<String>(
    'audio_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventType,
    startTimestamp,
    endTimestamp,
    startGpsLat,
    startGpsLng,
    endGpsLat,
    endGpsLng,
    status,
    triggerPhrase,
    computedParameters,
    peakMetric,
    classification,
    tripId,
    crossConfirmed,
    forkFootLagMs,
    hrSpikeConfirmed,
    hrDeltaAtEvent,
    jerkPeakMagnitude,
    gpsSpeedAtEventKmh,
    gpsHeadingChangeDeg,
    audioFilePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('start_timestamp')) {
      context.handle(
        _startTimestampMeta,
        startTimestamp.isAcceptableOrUnknown(
          data['start_timestamp']!,
          _startTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimestampMeta);
    }
    if (data.containsKey('end_timestamp')) {
      context.handle(
        _endTimestampMeta,
        endTimestamp.isAcceptableOrUnknown(
          data['end_timestamp']!,
          _endTimestampMeta,
        ),
      );
    }
    if (data.containsKey('start_gps_lat')) {
      context.handle(
        _startGpsLatMeta,
        startGpsLat.isAcceptableOrUnknown(
          data['start_gps_lat']!,
          _startGpsLatMeta,
        ),
      );
    }
    if (data.containsKey('start_gps_lng')) {
      context.handle(
        _startGpsLngMeta,
        startGpsLng.isAcceptableOrUnknown(
          data['start_gps_lng']!,
          _startGpsLngMeta,
        ),
      );
    }
    if (data.containsKey('end_gps_lat')) {
      context.handle(
        _endGpsLatMeta,
        endGpsLat.isAcceptableOrUnknown(data['end_gps_lat']!, _endGpsLatMeta),
      );
    }
    if (data.containsKey('end_gps_lng')) {
      context.handle(
        _endGpsLngMeta,
        endGpsLng.isAcceptableOrUnknown(data['end_gps_lng']!, _endGpsLngMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('trigger_phrase')) {
      context.handle(
        _triggerPhraseMeta,
        triggerPhrase.isAcceptableOrUnknown(
          data['trigger_phrase']!,
          _triggerPhraseMeta,
        ),
      );
    }
    if (data.containsKey('computed_parameters')) {
      context.handle(
        _computedParametersMeta,
        computedParameters.isAcceptableOrUnknown(
          data['computed_parameters']!,
          _computedParametersMeta,
        ),
      );
    }
    if (data.containsKey('peak_metric')) {
      context.handle(
        _peakMetricMeta,
        peakMetric.isAcceptableOrUnknown(data['peak_metric']!, _peakMetricMeta),
      );
    }
    if (data.containsKey('classification')) {
      context.handle(
        _classificationMeta,
        classification.isAcceptableOrUnknown(
          data['classification']!,
          _classificationMeta,
        ),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    if (data.containsKey('cross_confirmed')) {
      context.handle(
        _crossConfirmedMeta,
        crossConfirmed.isAcceptableOrUnknown(
          data['cross_confirmed']!,
          _crossConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('fork_foot_lag_ms')) {
      context.handle(
        _forkFootLagMsMeta,
        forkFootLagMs.isAcceptableOrUnknown(
          data['fork_foot_lag_ms']!,
          _forkFootLagMsMeta,
        ),
      );
    }
    if (data.containsKey('hr_spike_confirmed')) {
      context.handle(
        _hrSpikeConfirmedMeta,
        hrSpikeConfirmed.isAcceptableOrUnknown(
          data['hr_spike_confirmed']!,
          _hrSpikeConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('hr_delta_at_event')) {
      context.handle(
        _hrDeltaAtEventMeta,
        hrDeltaAtEvent.isAcceptableOrUnknown(
          data['hr_delta_at_event']!,
          _hrDeltaAtEventMeta,
        ),
      );
    }
    if (data.containsKey('jerk_peak_magnitude')) {
      context.handle(
        _jerkPeakMagnitudeMeta,
        jerkPeakMagnitude.isAcceptableOrUnknown(
          data['jerk_peak_magnitude']!,
          _jerkPeakMagnitudeMeta,
        ),
      );
    }
    if (data.containsKey('gps_speed_at_event_kmh')) {
      context.handle(
        _gpsSpeedAtEventKmhMeta,
        gpsSpeedAtEventKmh.isAcceptableOrUnknown(
          data['gps_speed_at_event_kmh']!,
          _gpsSpeedAtEventKmhMeta,
        ),
      );
    }
    if (data.containsKey('gps_heading_change_deg')) {
      context.handle(
        _gpsHeadingChangeDegMeta,
        gpsHeadingChangeDeg.isAcceptableOrUnknown(
          data['gps_heading_change_deg']!,
          _gpsHeadingChangeDegMeta,
        ),
      );
    }
    if (data.containsKey('audio_file_path')) {
      context.handle(
        _audioFilePathMeta,
        audioFilePath.isAcceptableOrUnknown(
          data['audio_file_path']!,
          _audioFilePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      startTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_timestamp'],
      )!,
      endTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_timestamp'],
      ),
      startGpsLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_gps_lat'],
      ),
      startGpsLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_gps_lng'],
      ),
      endGpsLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_gps_lat'],
      ),
      endGpsLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_gps_lng'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      triggerPhrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_phrase'],
      ),
      computedParameters: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}computed_parameters'],
      ),
      peakMetric: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_metric'],
      ),
      classification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification'],
      ),
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      ),
      crossConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cross_confirmed'],
      )!,
      forkFootLagMs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fork_foot_lag_ms'],
      ),
      hrSpikeConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hr_spike_confirmed'],
      )!,
      hrDeltaAtEvent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hr_delta_at_event'],
      ),
      jerkPeakMagnitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}jerk_peak_magnitude'],
      ),
      gpsSpeedAtEventKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_speed_at_event_kmh'],
      ),
      gpsHeadingChangeDeg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_heading_change_deg'],
      ),
      audioFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_file_path'],
      ),
    );
  }

  @override
  $EventRecordsTable createAlias(String alias) {
    return $EventRecordsTable(attachedDatabase, alias);
  }
}

class EventRecord extends DataClass implements Insertable<EventRecord> {
  final int id;
  final String eventType;
  final DateTime startTimestamp;
  final DateTime? endTimestamp;
  final double? startGpsLat;
  final double? startGpsLng;
  final double? endGpsLat;
  final double? endGpsLng;
  final String status;
  final String? triggerPhrase;
  final String? computedParameters;
  final double? peakMetric;
  final String? classification;
  final int? tripId;
  final bool crossConfirmed;
  final double? forkFootLagMs;
  final bool hrSpikeConfirmed;
  final double? hrDeltaAtEvent;
  final double? jerkPeakMagnitude;
  final double? gpsSpeedAtEventKmh;
  final double? gpsHeadingChangeDeg;
  final String? audioFilePath;
  const EventRecord({
    required this.id,
    required this.eventType,
    required this.startTimestamp,
    this.endTimestamp,
    this.startGpsLat,
    this.startGpsLng,
    this.endGpsLat,
    this.endGpsLng,
    required this.status,
    this.triggerPhrase,
    this.computedParameters,
    this.peakMetric,
    this.classification,
    this.tripId,
    required this.crossConfirmed,
    this.forkFootLagMs,
    required this.hrSpikeConfirmed,
    this.hrDeltaAtEvent,
    this.jerkPeakMagnitude,
    this.gpsSpeedAtEventKmh,
    this.gpsHeadingChangeDeg,
    this.audioFilePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_type'] = Variable<String>(eventType);
    map['start_timestamp'] = Variable<DateTime>(startTimestamp);
    if (!nullToAbsent || endTimestamp != null) {
      map['end_timestamp'] = Variable<DateTime>(endTimestamp);
    }
    if (!nullToAbsent || startGpsLat != null) {
      map['start_gps_lat'] = Variable<double>(startGpsLat);
    }
    if (!nullToAbsent || startGpsLng != null) {
      map['start_gps_lng'] = Variable<double>(startGpsLng);
    }
    if (!nullToAbsent || endGpsLat != null) {
      map['end_gps_lat'] = Variable<double>(endGpsLat);
    }
    if (!nullToAbsent || endGpsLng != null) {
      map['end_gps_lng'] = Variable<double>(endGpsLng);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || triggerPhrase != null) {
      map['trigger_phrase'] = Variable<String>(triggerPhrase);
    }
    if (!nullToAbsent || computedParameters != null) {
      map['computed_parameters'] = Variable<String>(computedParameters);
    }
    if (!nullToAbsent || peakMetric != null) {
      map['peak_metric'] = Variable<double>(peakMetric);
    }
    if (!nullToAbsent || classification != null) {
      map['classification'] = Variable<String>(classification);
    }
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    map['cross_confirmed'] = Variable<bool>(crossConfirmed);
    if (!nullToAbsent || forkFootLagMs != null) {
      map['fork_foot_lag_ms'] = Variable<double>(forkFootLagMs);
    }
    map['hr_spike_confirmed'] = Variable<bool>(hrSpikeConfirmed);
    if (!nullToAbsent || hrDeltaAtEvent != null) {
      map['hr_delta_at_event'] = Variable<double>(hrDeltaAtEvent);
    }
    if (!nullToAbsent || jerkPeakMagnitude != null) {
      map['jerk_peak_magnitude'] = Variable<double>(jerkPeakMagnitude);
    }
    if (!nullToAbsent || gpsSpeedAtEventKmh != null) {
      map['gps_speed_at_event_kmh'] = Variable<double>(gpsSpeedAtEventKmh);
    }
    if (!nullToAbsent || gpsHeadingChangeDeg != null) {
      map['gps_heading_change_deg'] = Variable<double>(gpsHeadingChangeDeg);
    }
    if (!nullToAbsent || audioFilePath != null) {
      map['audio_file_path'] = Variable<String>(audioFilePath);
    }
    return map;
  }

  EventRecordsCompanion toCompanion(bool nullToAbsent) {
    return EventRecordsCompanion(
      id: Value(id),
      eventType: Value(eventType),
      startTimestamp: Value(startTimestamp),
      endTimestamp: endTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(endTimestamp),
      startGpsLat: startGpsLat == null && nullToAbsent
          ? const Value.absent()
          : Value(startGpsLat),
      startGpsLng: startGpsLng == null && nullToAbsent
          ? const Value.absent()
          : Value(startGpsLng),
      endGpsLat: endGpsLat == null && nullToAbsent
          ? const Value.absent()
          : Value(endGpsLat),
      endGpsLng: endGpsLng == null && nullToAbsent
          ? const Value.absent()
          : Value(endGpsLng),
      status: Value(status),
      triggerPhrase: triggerPhrase == null && nullToAbsent
          ? const Value.absent()
          : Value(triggerPhrase),
      computedParameters: computedParameters == null && nullToAbsent
          ? const Value.absent()
          : Value(computedParameters),
      peakMetric: peakMetric == null && nullToAbsent
          ? const Value.absent()
          : Value(peakMetric),
      classification: classification == null && nullToAbsent
          ? const Value.absent()
          : Value(classification),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
      crossConfirmed: Value(crossConfirmed),
      forkFootLagMs: forkFootLagMs == null && nullToAbsent
          ? const Value.absent()
          : Value(forkFootLagMs),
      hrSpikeConfirmed: Value(hrSpikeConfirmed),
      hrDeltaAtEvent: hrDeltaAtEvent == null && nullToAbsent
          ? const Value.absent()
          : Value(hrDeltaAtEvent),
      jerkPeakMagnitude: jerkPeakMagnitude == null && nullToAbsent
          ? const Value.absent()
          : Value(jerkPeakMagnitude),
      gpsSpeedAtEventKmh: gpsSpeedAtEventKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsSpeedAtEventKmh),
      gpsHeadingChangeDeg: gpsHeadingChangeDeg == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsHeadingChangeDeg),
      audioFilePath: audioFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFilePath),
    );
  }

  factory EventRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRecord(
      id: serializer.fromJson<int>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      startTimestamp: serializer.fromJson<DateTime>(json['startTimestamp']),
      endTimestamp: serializer.fromJson<DateTime?>(json['endTimestamp']),
      startGpsLat: serializer.fromJson<double?>(json['startGpsLat']),
      startGpsLng: serializer.fromJson<double?>(json['startGpsLng']),
      endGpsLat: serializer.fromJson<double?>(json['endGpsLat']),
      endGpsLng: serializer.fromJson<double?>(json['endGpsLng']),
      status: serializer.fromJson<String>(json['status']),
      triggerPhrase: serializer.fromJson<String?>(json['triggerPhrase']),
      computedParameters: serializer.fromJson<String?>(
        json['computedParameters'],
      ),
      peakMetric: serializer.fromJson<double?>(json['peakMetric']),
      classification: serializer.fromJson<String?>(json['classification']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      crossConfirmed: serializer.fromJson<bool>(json['crossConfirmed']),
      forkFootLagMs: serializer.fromJson<double?>(json['forkFootLagMs']),
      hrSpikeConfirmed: serializer.fromJson<bool>(json['hrSpikeConfirmed']),
      hrDeltaAtEvent: serializer.fromJson<double?>(json['hrDeltaAtEvent']),
      jerkPeakMagnitude: serializer.fromJson<double?>(
        json['jerkPeakMagnitude'],
      ),
      gpsSpeedAtEventKmh: serializer.fromJson<double?>(
        json['gpsSpeedAtEventKmh'],
      ),
      gpsHeadingChangeDeg: serializer.fromJson<double?>(
        json['gpsHeadingChangeDeg'],
      ),
      audioFilePath: serializer.fromJson<String?>(json['audioFilePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventType': serializer.toJson<String>(eventType),
      'startTimestamp': serializer.toJson<DateTime>(startTimestamp),
      'endTimestamp': serializer.toJson<DateTime?>(endTimestamp),
      'startGpsLat': serializer.toJson<double?>(startGpsLat),
      'startGpsLng': serializer.toJson<double?>(startGpsLng),
      'endGpsLat': serializer.toJson<double?>(endGpsLat),
      'endGpsLng': serializer.toJson<double?>(endGpsLng),
      'status': serializer.toJson<String>(status),
      'triggerPhrase': serializer.toJson<String?>(triggerPhrase),
      'computedParameters': serializer.toJson<String?>(computedParameters),
      'peakMetric': serializer.toJson<double?>(peakMetric),
      'classification': serializer.toJson<String?>(classification),
      'tripId': serializer.toJson<int?>(tripId),
      'crossConfirmed': serializer.toJson<bool>(crossConfirmed),
      'forkFootLagMs': serializer.toJson<double?>(forkFootLagMs),
      'hrSpikeConfirmed': serializer.toJson<bool>(hrSpikeConfirmed),
      'hrDeltaAtEvent': serializer.toJson<double?>(hrDeltaAtEvent),
      'jerkPeakMagnitude': serializer.toJson<double?>(jerkPeakMagnitude),
      'gpsSpeedAtEventKmh': serializer.toJson<double?>(gpsSpeedAtEventKmh),
      'gpsHeadingChangeDeg': serializer.toJson<double?>(gpsHeadingChangeDeg),
      'audioFilePath': serializer.toJson<String?>(audioFilePath),
    };
  }

  EventRecord copyWith({
    int? id,
    String? eventType,
    DateTime? startTimestamp,
    Value<DateTime?> endTimestamp = const Value.absent(),
    Value<double?> startGpsLat = const Value.absent(),
    Value<double?> startGpsLng = const Value.absent(),
    Value<double?> endGpsLat = const Value.absent(),
    Value<double?> endGpsLng = const Value.absent(),
    String? status,
    Value<String?> triggerPhrase = const Value.absent(),
    Value<String?> computedParameters = const Value.absent(),
    Value<double?> peakMetric = const Value.absent(),
    Value<String?> classification = const Value.absent(),
    Value<int?> tripId = const Value.absent(),
    bool? crossConfirmed,
    Value<double?> forkFootLagMs = const Value.absent(),
    bool? hrSpikeConfirmed,
    Value<double?> hrDeltaAtEvent = const Value.absent(),
    Value<double?> jerkPeakMagnitude = const Value.absent(),
    Value<double?> gpsSpeedAtEventKmh = const Value.absent(),
    Value<double?> gpsHeadingChangeDeg = const Value.absent(),
    Value<String?> audioFilePath = const Value.absent(),
  }) => EventRecord(
    id: id ?? this.id,
    eventType: eventType ?? this.eventType,
    startTimestamp: startTimestamp ?? this.startTimestamp,
    endTimestamp: endTimestamp.present ? endTimestamp.value : this.endTimestamp,
    startGpsLat: startGpsLat.present ? startGpsLat.value : this.startGpsLat,
    startGpsLng: startGpsLng.present ? startGpsLng.value : this.startGpsLng,
    endGpsLat: endGpsLat.present ? endGpsLat.value : this.endGpsLat,
    endGpsLng: endGpsLng.present ? endGpsLng.value : this.endGpsLng,
    status: status ?? this.status,
    triggerPhrase: triggerPhrase.present
        ? triggerPhrase.value
        : this.triggerPhrase,
    computedParameters: computedParameters.present
        ? computedParameters.value
        : this.computedParameters,
    peakMetric: peakMetric.present ? peakMetric.value : this.peakMetric,
    classification: classification.present
        ? classification.value
        : this.classification,
    tripId: tripId.present ? tripId.value : this.tripId,
    crossConfirmed: crossConfirmed ?? this.crossConfirmed,
    forkFootLagMs: forkFootLagMs.present
        ? forkFootLagMs.value
        : this.forkFootLagMs,
    hrSpikeConfirmed: hrSpikeConfirmed ?? this.hrSpikeConfirmed,
    hrDeltaAtEvent: hrDeltaAtEvent.present
        ? hrDeltaAtEvent.value
        : this.hrDeltaAtEvent,
    jerkPeakMagnitude: jerkPeakMagnitude.present
        ? jerkPeakMagnitude.value
        : this.jerkPeakMagnitude,
    gpsSpeedAtEventKmh: gpsSpeedAtEventKmh.present
        ? gpsSpeedAtEventKmh.value
        : this.gpsSpeedAtEventKmh,
    gpsHeadingChangeDeg: gpsHeadingChangeDeg.present
        ? gpsHeadingChangeDeg.value
        : this.gpsHeadingChangeDeg,
    audioFilePath: audioFilePath.present
        ? audioFilePath.value
        : this.audioFilePath,
  );
  EventRecord copyWithCompanion(EventRecordsCompanion data) {
    return EventRecord(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      startTimestamp: data.startTimestamp.present
          ? data.startTimestamp.value
          : this.startTimestamp,
      endTimestamp: data.endTimestamp.present
          ? data.endTimestamp.value
          : this.endTimestamp,
      startGpsLat: data.startGpsLat.present
          ? data.startGpsLat.value
          : this.startGpsLat,
      startGpsLng: data.startGpsLng.present
          ? data.startGpsLng.value
          : this.startGpsLng,
      endGpsLat: data.endGpsLat.present ? data.endGpsLat.value : this.endGpsLat,
      endGpsLng: data.endGpsLng.present ? data.endGpsLng.value : this.endGpsLng,
      status: data.status.present ? data.status.value : this.status,
      triggerPhrase: data.triggerPhrase.present
          ? data.triggerPhrase.value
          : this.triggerPhrase,
      computedParameters: data.computedParameters.present
          ? data.computedParameters.value
          : this.computedParameters,
      peakMetric: data.peakMetric.present
          ? data.peakMetric.value
          : this.peakMetric,
      classification: data.classification.present
          ? data.classification.value
          : this.classification,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      crossConfirmed: data.crossConfirmed.present
          ? data.crossConfirmed.value
          : this.crossConfirmed,
      forkFootLagMs: data.forkFootLagMs.present
          ? data.forkFootLagMs.value
          : this.forkFootLagMs,
      hrSpikeConfirmed: data.hrSpikeConfirmed.present
          ? data.hrSpikeConfirmed.value
          : this.hrSpikeConfirmed,
      hrDeltaAtEvent: data.hrDeltaAtEvent.present
          ? data.hrDeltaAtEvent.value
          : this.hrDeltaAtEvent,
      jerkPeakMagnitude: data.jerkPeakMagnitude.present
          ? data.jerkPeakMagnitude.value
          : this.jerkPeakMagnitude,
      gpsSpeedAtEventKmh: data.gpsSpeedAtEventKmh.present
          ? data.gpsSpeedAtEventKmh.value
          : this.gpsSpeedAtEventKmh,
      gpsHeadingChangeDeg: data.gpsHeadingChangeDeg.present
          ? data.gpsHeadingChangeDeg.value
          : this.gpsHeadingChangeDeg,
      audioFilePath: data.audioFilePath.present
          ? data.audioFilePath.value
          : this.audioFilePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRecord(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('startTimestamp: $startTimestamp, ')
          ..write('endTimestamp: $endTimestamp, ')
          ..write('startGpsLat: $startGpsLat, ')
          ..write('startGpsLng: $startGpsLng, ')
          ..write('endGpsLat: $endGpsLat, ')
          ..write('endGpsLng: $endGpsLng, ')
          ..write('status: $status, ')
          ..write('triggerPhrase: $triggerPhrase, ')
          ..write('computedParameters: $computedParameters, ')
          ..write('peakMetric: $peakMetric, ')
          ..write('classification: $classification, ')
          ..write('tripId: $tripId, ')
          ..write('crossConfirmed: $crossConfirmed, ')
          ..write('forkFootLagMs: $forkFootLagMs, ')
          ..write('hrSpikeConfirmed: $hrSpikeConfirmed, ')
          ..write('hrDeltaAtEvent: $hrDeltaAtEvent, ')
          ..write('jerkPeakMagnitude: $jerkPeakMagnitude, ')
          ..write('gpsSpeedAtEventKmh: $gpsSpeedAtEventKmh, ')
          ..write('gpsHeadingChangeDeg: $gpsHeadingChangeDeg, ')
          ..write('audioFilePath: $audioFilePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    eventType,
    startTimestamp,
    endTimestamp,
    startGpsLat,
    startGpsLng,
    endGpsLat,
    endGpsLng,
    status,
    triggerPhrase,
    computedParameters,
    peakMetric,
    classification,
    tripId,
    crossConfirmed,
    forkFootLagMs,
    hrSpikeConfirmed,
    hrDeltaAtEvent,
    jerkPeakMagnitude,
    gpsSpeedAtEventKmh,
    gpsHeadingChangeDeg,
    audioFilePath,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRecord &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.startTimestamp == this.startTimestamp &&
          other.endTimestamp == this.endTimestamp &&
          other.startGpsLat == this.startGpsLat &&
          other.startGpsLng == this.startGpsLng &&
          other.endGpsLat == this.endGpsLat &&
          other.endGpsLng == this.endGpsLng &&
          other.status == this.status &&
          other.triggerPhrase == this.triggerPhrase &&
          other.computedParameters == this.computedParameters &&
          other.peakMetric == this.peakMetric &&
          other.classification == this.classification &&
          other.tripId == this.tripId &&
          other.crossConfirmed == this.crossConfirmed &&
          other.forkFootLagMs == this.forkFootLagMs &&
          other.hrSpikeConfirmed == this.hrSpikeConfirmed &&
          other.hrDeltaAtEvent == this.hrDeltaAtEvent &&
          other.jerkPeakMagnitude == this.jerkPeakMagnitude &&
          other.gpsSpeedAtEventKmh == this.gpsSpeedAtEventKmh &&
          other.gpsHeadingChangeDeg == this.gpsHeadingChangeDeg &&
          other.audioFilePath == this.audioFilePath);
}

class EventRecordsCompanion extends UpdateCompanion<EventRecord> {
  final Value<int> id;
  final Value<String> eventType;
  final Value<DateTime> startTimestamp;
  final Value<DateTime?> endTimestamp;
  final Value<double?> startGpsLat;
  final Value<double?> startGpsLng;
  final Value<double?> endGpsLat;
  final Value<double?> endGpsLng;
  final Value<String> status;
  final Value<String?> triggerPhrase;
  final Value<String?> computedParameters;
  final Value<double?> peakMetric;
  final Value<String?> classification;
  final Value<int?> tripId;
  final Value<bool> crossConfirmed;
  final Value<double?> forkFootLagMs;
  final Value<bool> hrSpikeConfirmed;
  final Value<double?> hrDeltaAtEvent;
  final Value<double?> jerkPeakMagnitude;
  final Value<double?> gpsSpeedAtEventKmh;
  final Value<double?> gpsHeadingChangeDeg;
  final Value<String?> audioFilePath;
  const EventRecordsCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.startTimestamp = const Value.absent(),
    this.endTimestamp = const Value.absent(),
    this.startGpsLat = const Value.absent(),
    this.startGpsLng = const Value.absent(),
    this.endGpsLat = const Value.absent(),
    this.endGpsLng = const Value.absent(),
    this.status = const Value.absent(),
    this.triggerPhrase = const Value.absent(),
    this.computedParameters = const Value.absent(),
    this.peakMetric = const Value.absent(),
    this.classification = const Value.absent(),
    this.tripId = const Value.absent(),
    this.crossConfirmed = const Value.absent(),
    this.forkFootLagMs = const Value.absent(),
    this.hrSpikeConfirmed = const Value.absent(),
    this.hrDeltaAtEvent = const Value.absent(),
    this.jerkPeakMagnitude = const Value.absent(),
    this.gpsSpeedAtEventKmh = const Value.absent(),
    this.gpsHeadingChangeDeg = const Value.absent(),
    this.audioFilePath = const Value.absent(),
  });
  EventRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String eventType,
    required DateTime startTimestamp,
    this.endTimestamp = const Value.absent(),
    this.startGpsLat = const Value.absent(),
    this.startGpsLng = const Value.absent(),
    this.endGpsLat = const Value.absent(),
    this.endGpsLng = const Value.absent(),
    required String status,
    this.triggerPhrase = const Value.absent(),
    this.computedParameters = const Value.absent(),
    this.peakMetric = const Value.absent(),
    this.classification = const Value.absent(),
    this.tripId = const Value.absent(),
    this.crossConfirmed = const Value.absent(),
    this.forkFootLagMs = const Value.absent(),
    this.hrSpikeConfirmed = const Value.absent(),
    this.hrDeltaAtEvent = const Value.absent(),
    this.jerkPeakMagnitude = const Value.absent(),
    this.gpsSpeedAtEventKmh = const Value.absent(),
    this.gpsHeadingChangeDeg = const Value.absent(),
    this.audioFilePath = const Value.absent(),
  }) : eventType = Value(eventType),
       startTimestamp = Value(startTimestamp),
       status = Value(status);
  static Insertable<EventRecord> custom({
    Expression<int>? id,
    Expression<String>? eventType,
    Expression<DateTime>? startTimestamp,
    Expression<DateTime>? endTimestamp,
    Expression<double>? startGpsLat,
    Expression<double>? startGpsLng,
    Expression<double>? endGpsLat,
    Expression<double>? endGpsLng,
    Expression<String>? status,
    Expression<String>? triggerPhrase,
    Expression<String>? computedParameters,
    Expression<double>? peakMetric,
    Expression<String>? classification,
    Expression<int>? tripId,
    Expression<bool>? crossConfirmed,
    Expression<double>? forkFootLagMs,
    Expression<bool>? hrSpikeConfirmed,
    Expression<double>? hrDeltaAtEvent,
    Expression<double>? jerkPeakMagnitude,
    Expression<double>? gpsSpeedAtEventKmh,
    Expression<double>? gpsHeadingChangeDeg,
    Expression<String>? audioFilePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (startTimestamp != null) 'start_timestamp': startTimestamp,
      if (endTimestamp != null) 'end_timestamp': endTimestamp,
      if (startGpsLat != null) 'start_gps_lat': startGpsLat,
      if (startGpsLng != null) 'start_gps_lng': startGpsLng,
      if (endGpsLat != null) 'end_gps_lat': endGpsLat,
      if (endGpsLng != null) 'end_gps_lng': endGpsLng,
      if (status != null) 'status': status,
      if (triggerPhrase != null) 'trigger_phrase': triggerPhrase,
      if (computedParameters != null) 'computed_parameters': computedParameters,
      if (peakMetric != null) 'peak_metric': peakMetric,
      if (classification != null) 'classification': classification,
      if (tripId != null) 'trip_id': tripId,
      if (crossConfirmed != null) 'cross_confirmed': crossConfirmed,
      if (forkFootLagMs != null) 'fork_foot_lag_ms': forkFootLagMs,
      if (hrSpikeConfirmed != null) 'hr_spike_confirmed': hrSpikeConfirmed,
      if (hrDeltaAtEvent != null) 'hr_delta_at_event': hrDeltaAtEvent,
      if (jerkPeakMagnitude != null) 'jerk_peak_magnitude': jerkPeakMagnitude,
      if (gpsSpeedAtEventKmh != null)
        'gps_speed_at_event_kmh': gpsSpeedAtEventKmh,
      if (gpsHeadingChangeDeg != null)
        'gps_heading_change_deg': gpsHeadingChangeDeg,
      if (audioFilePath != null) 'audio_file_path': audioFilePath,
    });
  }

  EventRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? eventType,
    Value<DateTime>? startTimestamp,
    Value<DateTime?>? endTimestamp,
    Value<double?>? startGpsLat,
    Value<double?>? startGpsLng,
    Value<double?>? endGpsLat,
    Value<double?>? endGpsLng,
    Value<String>? status,
    Value<String?>? triggerPhrase,
    Value<String?>? computedParameters,
    Value<double?>? peakMetric,
    Value<String?>? classification,
    Value<int?>? tripId,
    Value<bool>? crossConfirmed,
    Value<double?>? forkFootLagMs,
    Value<bool>? hrSpikeConfirmed,
    Value<double?>? hrDeltaAtEvent,
    Value<double?>? jerkPeakMagnitude,
    Value<double?>? gpsSpeedAtEventKmh,
    Value<double?>? gpsHeadingChangeDeg,
    Value<String?>? audioFilePath,
  }) {
    return EventRecordsCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      endTimestamp: endTimestamp ?? this.endTimestamp,
      startGpsLat: startGpsLat ?? this.startGpsLat,
      startGpsLng: startGpsLng ?? this.startGpsLng,
      endGpsLat: endGpsLat ?? this.endGpsLat,
      endGpsLng: endGpsLng ?? this.endGpsLng,
      status: status ?? this.status,
      triggerPhrase: triggerPhrase ?? this.triggerPhrase,
      computedParameters: computedParameters ?? this.computedParameters,
      peakMetric: peakMetric ?? this.peakMetric,
      classification: classification ?? this.classification,
      tripId: tripId ?? this.tripId,
      crossConfirmed: crossConfirmed ?? this.crossConfirmed,
      forkFootLagMs: forkFootLagMs ?? this.forkFootLagMs,
      hrSpikeConfirmed: hrSpikeConfirmed ?? this.hrSpikeConfirmed,
      hrDeltaAtEvent: hrDeltaAtEvent ?? this.hrDeltaAtEvent,
      jerkPeakMagnitude: jerkPeakMagnitude ?? this.jerkPeakMagnitude,
      gpsSpeedAtEventKmh: gpsSpeedAtEventKmh ?? this.gpsSpeedAtEventKmh,
      gpsHeadingChangeDeg: gpsHeadingChangeDeg ?? this.gpsHeadingChangeDeg,
      audioFilePath: audioFilePath ?? this.audioFilePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (startTimestamp.present) {
      map['start_timestamp'] = Variable<DateTime>(startTimestamp.value);
    }
    if (endTimestamp.present) {
      map['end_timestamp'] = Variable<DateTime>(endTimestamp.value);
    }
    if (startGpsLat.present) {
      map['start_gps_lat'] = Variable<double>(startGpsLat.value);
    }
    if (startGpsLng.present) {
      map['start_gps_lng'] = Variable<double>(startGpsLng.value);
    }
    if (endGpsLat.present) {
      map['end_gps_lat'] = Variable<double>(endGpsLat.value);
    }
    if (endGpsLng.present) {
      map['end_gps_lng'] = Variable<double>(endGpsLng.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (triggerPhrase.present) {
      map['trigger_phrase'] = Variable<String>(triggerPhrase.value);
    }
    if (computedParameters.present) {
      map['computed_parameters'] = Variable<String>(computedParameters.value);
    }
    if (peakMetric.present) {
      map['peak_metric'] = Variable<double>(peakMetric.value);
    }
    if (classification.present) {
      map['classification'] = Variable<String>(classification.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (crossConfirmed.present) {
      map['cross_confirmed'] = Variable<bool>(crossConfirmed.value);
    }
    if (forkFootLagMs.present) {
      map['fork_foot_lag_ms'] = Variable<double>(forkFootLagMs.value);
    }
    if (hrSpikeConfirmed.present) {
      map['hr_spike_confirmed'] = Variable<bool>(hrSpikeConfirmed.value);
    }
    if (hrDeltaAtEvent.present) {
      map['hr_delta_at_event'] = Variable<double>(hrDeltaAtEvent.value);
    }
    if (jerkPeakMagnitude.present) {
      map['jerk_peak_magnitude'] = Variable<double>(jerkPeakMagnitude.value);
    }
    if (gpsSpeedAtEventKmh.present) {
      map['gps_speed_at_event_kmh'] = Variable<double>(
        gpsSpeedAtEventKmh.value,
      );
    }
    if (gpsHeadingChangeDeg.present) {
      map['gps_heading_change_deg'] = Variable<double>(
        gpsHeadingChangeDeg.value,
      );
    }
    if (audioFilePath.present) {
      map['audio_file_path'] = Variable<String>(audioFilePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventRecordsCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('startTimestamp: $startTimestamp, ')
          ..write('endTimestamp: $endTimestamp, ')
          ..write('startGpsLat: $startGpsLat, ')
          ..write('startGpsLng: $startGpsLng, ')
          ..write('endGpsLat: $endGpsLat, ')
          ..write('endGpsLng: $endGpsLng, ')
          ..write('status: $status, ')
          ..write('triggerPhrase: $triggerPhrase, ')
          ..write('computedParameters: $computedParameters, ')
          ..write('peakMetric: $peakMetric, ')
          ..write('classification: $classification, ')
          ..write('tripId: $tripId, ')
          ..write('crossConfirmed: $crossConfirmed, ')
          ..write('forkFootLagMs: $forkFootLagMs, ')
          ..write('hrSpikeConfirmed: $hrSpikeConfirmed, ')
          ..write('hrDeltaAtEvent: $hrDeltaAtEvent, ')
          ..write('jerkPeakMagnitude: $jerkPeakMagnitude, ')
          ..write('gpsSpeedAtEventKmh: $gpsSpeedAtEventKmh, ')
          ..write('gpsHeadingChangeDeg: $gpsHeadingChangeDeg, ')
          ..write('audioFilePath: $audioFilePath')
          ..write(')'))
        .toString();
  }
}

class $CameraDetectionsTable extends CameraDetections
    with TableInfo<$CameraDetectionsTable, CameraDetection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CameraDetectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventClassMeta = const VerificationMeta(
    'eventClass',
  );
  @override
  late final GeneratedColumn<String> eventClass = GeneratedColumn<String>(
    'event_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cameraTimestampUtcMeta =
      const VerificationMeta('cameraTimestampUtc');
  @override
  late final GeneratedColumn<DateTime> cameraTimestampUtc =
      GeneratedColumn<DateTime>(
        'camera_timestamp_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receivedAtUtcMeta = const VerificationMeta(
    'receivedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAtUtc =
      GeneratedColumn<DateTime>(
        'received_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _linkedEventIdMeta = const VerificationMeta(
    'linkedEventId',
  );
  @override
  late final GeneratedColumn<int> linkedEventId = GeneratedColumn<int>(
    'linked_event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    eventClass,
    confidence,
    cameraTimestampUtc,
    receivedAtUtc,
    linkedEventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'camera_detections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CameraDetection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('event_class')) {
      context.handle(
        _eventClassMeta,
        eventClass.isAcceptableOrUnknown(data['event_class']!, _eventClassMeta),
      );
    } else if (isInserting) {
      context.missing(_eventClassMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('camera_timestamp_utc')) {
      context.handle(
        _cameraTimestampUtcMeta,
        cameraTimestampUtc.isAcceptableOrUnknown(
          data['camera_timestamp_utc']!,
          _cameraTimestampUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cameraTimestampUtcMeta);
    }
    if (data.containsKey('received_at_utc')) {
      context.handle(
        _receivedAtUtcMeta,
        receivedAtUtc.isAcceptableOrUnknown(
          data['received_at_utc']!,
          _receivedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedAtUtcMeta);
    }
    if (data.containsKey('linked_event_id')) {
      context.handle(
        _linkedEventIdMeta,
        linkedEventId.isAcceptableOrUnknown(
          data['linked_event_id']!,
          _linkedEventIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CameraDetection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CameraDetection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      eventClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_class'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      cameraTimestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}camera_timestamp_utc'],
      )!,
      receivedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at_utc'],
      )!,
      linkedEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_event_id'],
      ),
    );
  }

  @override
  $CameraDetectionsTable createAlias(String alias) {
    return $CameraDetectionsTable(attachedDatabase, alias);
  }
}

class CameraDetection extends DataClass implements Insertable<CameraDetection> {
  final int id;
  final String deviceId;
  final String eventClass;
  final double confidence;
  final DateTime cameraTimestampUtc;
  final DateTime receivedAtUtc;
  final int? linkedEventId;
  const CameraDetection({
    required this.id,
    required this.deviceId,
    required this.eventClass,
    required this.confidence,
    required this.cameraTimestampUtc,
    required this.receivedAtUtc,
    this.linkedEventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['event_class'] = Variable<String>(eventClass);
    map['confidence'] = Variable<double>(confidence);
    map['camera_timestamp_utc'] = Variable<DateTime>(cameraTimestampUtc);
    map['received_at_utc'] = Variable<DateTime>(receivedAtUtc);
    if (!nullToAbsent || linkedEventId != null) {
      map['linked_event_id'] = Variable<int>(linkedEventId);
    }
    return map;
  }

  CameraDetectionsCompanion toCompanion(bool nullToAbsent) {
    return CameraDetectionsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      eventClass: Value(eventClass),
      confidence: Value(confidence),
      cameraTimestampUtc: Value(cameraTimestampUtc),
      receivedAtUtc: Value(receivedAtUtc),
      linkedEventId: linkedEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedEventId),
    );
  }

  factory CameraDetection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CameraDetection(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      eventClass: serializer.fromJson<String>(json['eventClass']),
      confidence: serializer.fromJson<double>(json['confidence']),
      cameraTimestampUtc: serializer.fromJson<DateTime>(
        json['cameraTimestampUtc'],
      ),
      receivedAtUtc: serializer.fromJson<DateTime>(json['receivedAtUtc']),
      linkedEventId: serializer.fromJson<int?>(json['linkedEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'eventClass': serializer.toJson<String>(eventClass),
      'confidence': serializer.toJson<double>(confidence),
      'cameraTimestampUtc': serializer.toJson<DateTime>(cameraTimestampUtc),
      'receivedAtUtc': serializer.toJson<DateTime>(receivedAtUtc),
      'linkedEventId': serializer.toJson<int?>(linkedEventId),
    };
  }

  CameraDetection copyWith({
    int? id,
    String? deviceId,
    String? eventClass,
    double? confidence,
    DateTime? cameraTimestampUtc,
    DateTime? receivedAtUtc,
    Value<int?> linkedEventId = const Value.absent(),
  }) => CameraDetection(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    eventClass: eventClass ?? this.eventClass,
    confidence: confidence ?? this.confidence,
    cameraTimestampUtc: cameraTimestampUtc ?? this.cameraTimestampUtc,
    receivedAtUtc: receivedAtUtc ?? this.receivedAtUtc,
    linkedEventId: linkedEventId.present
        ? linkedEventId.value
        : this.linkedEventId,
  );
  CameraDetection copyWithCompanion(CameraDetectionsCompanion data) {
    return CameraDetection(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      eventClass: data.eventClass.present
          ? data.eventClass.value
          : this.eventClass,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      cameraTimestampUtc: data.cameraTimestampUtc.present
          ? data.cameraTimestampUtc.value
          : this.cameraTimestampUtc,
      receivedAtUtc: data.receivedAtUtc.present
          ? data.receivedAtUtc.value
          : this.receivedAtUtc,
      linkedEventId: data.linkedEventId.present
          ? data.linkedEventId.value
          : this.linkedEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CameraDetection(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('eventClass: $eventClass, ')
          ..write('confidence: $confidence, ')
          ..write('cameraTimestampUtc: $cameraTimestampUtc, ')
          ..write('receivedAtUtc: $receivedAtUtc, ')
          ..write('linkedEventId: $linkedEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    eventClass,
    confidence,
    cameraTimestampUtc,
    receivedAtUtc,
    linkedEventId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CameraDetection &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.eventClass == this.eventClass &&
          other.confidence == this.confidence &&
          other.cameraTimestampUtc == this.cameraTimestampUtc &&
          other.receivedAtUtc == this.receivedAtUtc &&
          other.linkedEventId == this.linkedEventId);
}

class CameraDetectionsCompanion extends UpdateCompanion<CameraDetection> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String> eventClass;
  final Value<double> confidence;
  final Value<DateTime> cameraTimestampUtc;
  final Value<DateTime> receivedAtUtc;
  final Value<int?> linkedEventId;
  const CameraDetectionsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.eventClass = const Value.absent(),
    this.confidence = const Value.absent(),
    this.cameraTimestampUtc = const Value.absent(),
    this.receivedAtUtc = const Value.absent(),
    this.linkedEventId = const Value.absent(),
  });
  CameraDetectionsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required String eventClass,
    required double confidence,
    required DateTime cameraTimestampUtc,
    required DateTime receivedAtUtc,
    this.linkedEventId = const Value.absent(),
  }) : deviceId = Value(deviceId),
       eventClass = Value(eventClass),
       confidence = Value(confidence),
       cameraTimestampUtc = Value(cameraTimestampUtc),
       receivedAtUtc = Value(receivedAtUtc);
  static Insertable<CameraDetection> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? eventClass,
    Expression<double>? confidence,
    Expression<DateTime>? cameraTimestampUtc,
    Expression<DateTime>? receivedAtUtc,
    Expression<int>? linkedEventId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (eventClass != null) 'event_class': eventClass,
      if (confidence != null) 'confidence': confidence,
      if (cameraTimestampUtc != null)
        'camera_timestamp_utc': cameraTimestampUtc,
      if (receivedAtUtc != null) 'received_at_utc': receivedAtUtc,
      if (linkedEventId != null) 'linked_event_id': linkedEventId,
    });
  }

  CameraDetectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<String>? eventClass,
    Value<double>? confidence,
    Value<DateTime>? cameraTimestampUtc,
    Value<DateTime>? receivedAtUtc,
    Value<int?>? linkedEventId,
  }) {
    return CameraDetectionsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      eventClass: eventClass ?? this.eventClass,
      confidence: confidence ?? this.confidence,
      cameraTimestampUtc: cameraTimestampUtc ?? this.cameraTimestampUtc,
      receivedAtUtc: receivedAtUtc ?? this.receivedAtUtc,
      linkedEventId: linkedEventId ?? this.linkedEventId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (eventClass.present) {
      map['event_class'] = Variable<String>(eventClass.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (cameraTimestampUtc.present) {
      map['camera_timestamp_utc'] = Variable<DateTime>(
        cameraTimestampUtc.value,
      );
    }
    if (receivedAtUtc.present) {
      map['received_at_utc'] = Variable<DateTime>(receivedAtUtc.value);
    }
    if (linkedEventId.present) {
      map['linked_event_id'] = Variable<int>(linkedEventId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CameraDetectionsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('eventClass: $eventClass, ')
          ..write('confidence: $confidence, ')
          ..write('cameraTimestampUtc: $cameraTimestampUtc, ')
          ..write('receivedAtUtc: $receivedAtUtc, ')
          ..write('linkedEventId: $linkedEventId')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _riderNameMeta = const VerificationMeta(
    'riderName',
  );
  @override
  late final GeneratedColumn<String> riderName = GeneratedColumn<String>(
    'rider_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Rider'),
  );
  static const VerificationMeta _wristSideMeta = const VerificationMeta(
    'wristSide',
  );
  @override
  late final GeneratedColumn<String> wristSide = GeneratedColumn<String>(
    'wrist_side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Left'),
  );
  static const VerificationMeta _startTimeUtcMeta = const VerificationMeta(
    'startTimeUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startTimeUtc = GeneratedColumn<DateTime>(
    'start_time_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeUtcMeta = const VerificationMeta(
    'endTimeUtc',
  );
  @override
  late final GeneratedColumn<DateTime> endTimeUtc = GeneratedColumn<DateTime>(
    'end_time_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimestampUtcMeta = const VerificationMeta(
    'startTimestampUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startTimestampUtc =
      GeneratedColumn<DateTime>(
        'start_timestamp_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endTimestampUtcMeta = const VerificationMeta(
    'endTimestampUtc',
  );
  @override
  late final GeneratedColumn<DateTime> endTimestampUtc =
      GeneratedColumn<DateTime>(
        'end_timestamp_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalDistanceKmMeta = const VerificationMeta(
    'totalDistanceKm',
  );
  @override
  late final GeneratedColumn<double> totalDistanceKm = GeneratedColumn<double>(
    'total_distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDurationMinMeta = const VerificationMeta(
    'totalDurationMin',
  );
  @override
  late final GeneratedColumn<double> totalDurationMin = GeneratedColumn<double>(
    'total_duration_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgSpeedKmhMeta = const VerificationMeta(
    'avgSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> avgSpeedKmh = GeneratedColumn<double>(
    'avg_speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxSpeedKmhMeta = const VerificationMeta(
    'maxSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> maxSpeedKmh = GeneratedColumn<double>(
    'max_speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _harshBrakeCountMeta = const VerificationMeta(
    'harshBrakeCount',
  );
  @override
  late final GeneratedColumn<int> harshBrakeCount = GeneratedColumn<int>(
    'harsh_brake_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _harshAccelCountMeta = const VerificationMeta(
    'harshAccelCount',
  );
  @override
  late final GeneratedColumn<int> harshAccelCount = GeneratedColumn<int>(
    'harsh_accel_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _harshTurnCountMeta = const VerificationMeta(
    'harshTurnCount',
  );
  @override
  late final GeneratedColumn<int> harshTurnCount = GeneratedColumn<int>(
    'harsh_turn_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bumpCountMeta = const VerificationMeta(
    'bumpCount',
  );
  @override
  late final GeneratedColumn<int> bumpCount = GeneratedColumn<int>(
    'bump_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _confirmedEventCountMeta =
      const VerificationMeta('confirmedEventCount');
  @override
  late final GeneratedColumn<int> confirmedEventCount = GeneratedColumn<int>(
    'confirmed_event_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _eventsPerKmMeta = const VerificationMeta(
    'eventsPerKm',
  );
  @override
  late final GeneratedColumn<double> eventsPerKm = GeneratedColumn<double>(
    'events_per_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgHrMeta = const VerificationMeta('avgHr');
  @override
  late final GeneratedColumn<double> avgHr = GeneratedColumn<double>(
    'avg_hr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHrMeta = const VerificationMeta('maxHr');
  @override
  late final GeneratedColumn<int> maxHr = GeneratedColumn<int>(
    'max_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hrSpikeConfirmedRatioMeta =
      const VerificationMeta('hrSpikeConfirmedRatio');
  @override
  late final GeneratedColumn<double> hrSpikeConfirmedRatio =
      GeneratedColumn<double>(
        'hr_spike_confirmed_ratio',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nightDrivingPctMeta = const VerificationMeta(
    'nightDrivingPct',
  );
  @override
  late final GeneratedColumn<double> nightDrivingPct = GeneratedColumn<double>(
    'night_driving_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverScoreMeta = const VerificationMeta(
    'driverScore',
  );
  @override
  late final GeneratedColumn<double> driverScore = GeneratedColumn<double>(
    'driver_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startLatMeta = const VerificationMeta(
    'startLat',
  );
  @override
  late final GeneratedColumn<double> startLat = GeneratedColumn<double>(
    'start_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startLngMeta = const VerificationMeta(
    'startLng',
  );
  @override
  late final GeneratedColumn<double> startLng = GeneratedColumn<double>(
    'start_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endLatMeta = const VerificationMeta('endLat');
  @override
  late final GeneratedColumn<double> endLat = GeneratedColumn<double>(
    'end_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endLngMeta = const VerificationMeta('endLng');
  @override
  late final GeneratedColumn<double> endLng = GeneratedColumn<double>(
    'end_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _peakSpeedKmhMeta = const VerificationMeta(
    'peakSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> peakSpeedKmh = GeneratedColumn<double>(
    'peak_speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalSensorRowsMeta = const VerificationMeta(
    'totalSensorRows',
  );
  @override
  late final GeneratedColumn<int> totalSensorRows = GeneratedColumn<int>(
    'total_sensor_rows',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalEventsCountMeta = const VerificationMeta(
    'totalEventsCount',
  );
  @override
  late final GeneratedColumn<int> totalEventsCount = GeneratedColumn<int>(
    'total_events_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _routeCoordinatesJsonMeta =
      const VerificationMeta('routeCoordinatesJson');
  @override
  late final GeneratedColumn<String> routeCoordinatesJson =
      GeneratedColumn<String>(
        'route_coordinates_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    riderName,
    wristSide,
    startTimeUtc,
    endTimeUtc,
    startTimestampUtc,
    endTimestampUtc,
    totalDistanceKm,
    totalDurationMin,
    avgSpeedKmh,
    maxSpeedKmh,
    harshBrakeCount,
    harshAccelCount,
    harshTurnCount,
    bumpCount,
    confirmedEventCount,
    eventsPerKm,
    avgHr,
    maxHr,
    hrSpikeConfirmedRatio,
    nightDrivingPct,
    driverScore,
    durationSeconds,
    startLat,
    startLng,
    endLat,
    endLng,
    distanceMeters,
    peakSpeedKmh,
    totalSensorRows,
    totalEventsCount,
    routeCoordinatesJson,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rider_name')) {
      context.handle(
        _riderNameMeta,
        riderName.isAcceptableOrUnknown(data['rider_name']!, _riderNameMeta),
      );
    }
    if (data.containsKey('wrist_side')) {
      context.handle(
        _wristSideMeta,
        wristSide.isAcceptableOrUnknown(data['wrist_side']!, _wristSideMeta),
      );
    }
    if (data.containsKey('start_time_utc')) {
      context.handle(
        _startTimeUtcMeta,
        startTimeUtc.isAcceptableOrUnknown(
          data['start_time_utc']!,
          _startTimeUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimeUtcMeta);
    }
    if (data.containsKey('end_time_utc')) {
      context.handle(
        _endTimeUtcMeta,
        endTimeUtc.isAcceptableOrUnknown(
          data['end_time_utc']!,
          _endTimeUtcMeta,
        ),
      );
    }
    if (data.containsKey('start_timestamp_utc')) {
      context.handle(
        _startTimestampUtcMeta,
        startTimestampUtc.isAcceptableOrUnknown(
          data['start_timestamp_utc']!,
          _startTimestampUtcMeta,
        ),
      );
    }
    if (data.containsKey('end_timestamp_utc')) {
      context.handle(
        _endTimestampUtcMeta,
        endTimestampUtc.isAcceptableOrUnknown(
          data['end_timestamp_utc']!,
          _endTimestampUtcMeta,
        ),
      );
    }
    if (data.containsKey('total_distance_km')) {
      context.handle(
        _totalDistanceKmMeta,
        totalDistanceKm.isAcceptableOrUnknown(
          data['total_distance_km']!,
          _totalDistanceKmMeta,
        ),
      );
    }
    if (data.containsKey('total_duration_min')) {
      context.handle(
        _totalDurationMinMeta,
        totalDurationMin.isAcceptableOrUnknown(
          data['total_duration_min']!,
          _totalDurationMinMeta,
        ),
      );
    }
    if (data.containsKey('avg_speed_kmh')) {
      context.handle(
        _avgSpeedKmhMeta,
        avgSpeedKmh.isAcceptableOrUnknown(
          data['avg_speed_kmh']!,
          _avgSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('max_speed_kmh')) {
      context.handle(
        _maxSpeedKmhMeta,
        maxSpeedKmh.isAcceptableOrUnknown(
          data['max_speed_kmh']!,
          _maxSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('harsh_brake_count')) {
      context.handle(
        _harshBrakeCountMeta,
        harshBrakeCount.isAcceptableOrUnknown(
          data['harsh_brake_count']!,
          _harshBrakeCountMeta,
        ),
      );
    }
    if (data.containsKey('harsh_accel_count')) {
      context.handle(
        _harshAccelCountMeta,
        harshAccelCount.isAcceptableOrUnknown(
          data['harsh_accel_count']!,
          _harshAccelCountMeta,
        ),
      );
    }
    if (data.containsKey('harsh_turn_count')) {
      context.handle(
        _harshTurnCountMeta,
        harshTurnCount.isAcceptableOrUnknown(
          data['harsh_turn_count']!,
          _harshTurnCountMeta,
        ),
      );
    }
    if (data.containsKey('bump_count')) {
      context.handle(
        _bumpCountMeta,
        bumpCount.isAcceptableOrUnknown(data['bump_count']!, _bumpCountMeta),
      );
    }
    if (data.containsKey('confirmed_event_count')) {
      context.handle(
        _confirmedEventCountMeta,
        confirmedEventCount.isAcceptableOrUnknown(
          data['confirmed_event_count']!,
          _confirmedEventCountMeta,
        ),
      );
    }
    if (data.containsKey('events_per_km')) {
      context.handle(
        _eventsPerKmMeta,
        eventsPerKm.isAcceptableOrUnknown(
          data['events_per_km']!,
          _eventsPerKmMeta,
        ),
      );
    }
    if (data.containsKey('avg_hr')) {
      context.handle(
        _avgHrMeta,
        avgHr.isAcceptableOrUnknown(data['avg_hr']!, _avgHrMeta),
      );
    }
    if (data.containsKey('max_hr')) {
      context.handle(
        _maxHrMeta,
        maxHr.isAcceptableOrUnknown(data['max_hr']!, _maxHrMeta),
      );
    }
    if (data.containsKey('hr_spike_confirmed_ratio')) {
      context.handle(
        _hrSpikeConfirmedRatioMeta,
        hrSpikeConfirmedRatio.isAcceptableOrUnknown(
          data['hr_spike_confirmed_ratio']!,
          _hrSpikeConfirmedRatioMeta,
        ),
      );
    }
    if (data.containsKey('night_driving_pct')) {
      context.handle(
        _nightDrivingPctMeta,
        nightDrivingPct.isAcceptableOrUnknown(
          data['night_driving_pct']!,
          _nightDrivingPctMeta,
        ),
      );
    }
    if (data.containsKey('driver_score')) {
      context.handle(
        _driverScoreMeta,
        driverScore.isAcceptableOrUnknown(
          data['driver_score']!,
          _driverScoreMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('start_lat')) {
      context.handle(
        _startLatMeta,
        startLat.isAcceptableOrUnknown(data['start_lat']!, _startLatMeta),
      );
    }
    if (data.containsKey('start_lng')) {
      context.handle(
        _startLngMeta,
        startLng.isAcceptableOrUnknown(data['start_lng']!, _startLngMeta),
      );
    }
    if (data.containsKey('end_lat')) {
      context.handle(
        _endLatMeta,
        endLat.isAcceptableOrUnknown(data['end_lat']!, _endLatMeta),
      );
    }
    if (data.containsKey('end_lng')) {
      context.handle(
        _endLngMeta,
        endLng.isAcceptableOrUnknown(data['end_lng']!, _endLngMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('peak_speed_kmh')) {
      context.handle(
        _peakSpeedKmhMeta,
        peakSpeedKmh.isAcceptableOrUnknown(
          data['peak_speed_kmh']!,
          _peakSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('total_sensor_rows')) {
      context.handle(
        _totalSensorRowsMeta,
        totalSensorRows.isAcceptableOrUnknown(
          data['total_sensor_rows']!,
          _totalSensorRowsMeta,
        ),
      );
    }
    if (data.containsKey('total_events_count')) {
      context.handle(
        _totalEventsCountMeta,
        totalEventsCount.isAcceptableOrUnknown(
          data['total_events_count']!,
          _totalEventsCountMeta,
        ),
      );
    }
    if (data.containsKey('route_coordinates_json')) {
      context.handle(
        _routeCoordinatesJsonMeta,
        routeCoordinatesJson.isAcceptableOrUnknown(
          data['route_coordinates_json']!,
          _routeCoordinatesJsonMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      riderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rider_name'],
      )!,
      wristSide: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wrist_side'],
      )!,
      startTimeUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time_utc'],
      )!,
      endTimeUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time_utc'],
      ),
      startTimestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_timestamp_utc'],
      ),
      endTimestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_timestamp_utc'],
      ),
      totalDistanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_distance_km'],
      ),
      totalDurationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_duration_min'],
      ),
      avgSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_speed_kmh'],
      ),
      maxSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_speed_kmh'],
      ),
      harshBrakeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}harsh_brake_count'],
      )!,
      harshAccelCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}harsh_accel_count'],
      )!,
      harshTurnCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}harsh_turn_count'],
      )!,
      bumpCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bump_count'],
      )!,
      confirmedEventCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirmed_event_count'],
      )!,
      eventsPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}events_per_km'],
      ),
      avgHr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_hr'],
      ),
      maxHr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_hr'],
      ),
      hrSpikeConfirmedRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hr_spike_confirmed_ratio'],
      ),
      nightDrivingPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}night_driving_pct'],
      ),
      driverScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}driver_score'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      startLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_lat'],
      ),
      startLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_lng'],
      ),
      endLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_lat'],
      ),
      endLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_lng'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      peakSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_speed_kmh'],
      ),
      totalSensorRows: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_sensor_rows'],
      )!,
      totalEventsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_events_count'],
      )!,
      routeCoordinatesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_coordinates_json'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final int id;
  final String riderName;
  final String wristSide;
  final DateTime startTimeUtc;
  final DateTime? endTimeUtc;
  final DateTime? startTimestampUtc;
  final DateTime? endTimestampUtc;
  final double? totalDistanceKm;
  final double? totalDurationMin;
  final double? avgSpeedKmh;
  final double? maxSpeedKmh;
  final int harshBrakeCount;
  final int harshAccelCount;
  final int harshTurnCount;
  final int bumpCount;
  final int confirmedEventCount;
  final double? eventsPerKm;
  final double? avgHr;
  final int? maxHr;
  final double? hrSpikeConfirmedRatio;
  final double? nightDrivingPct;
  final double? driverScore;
  final int durationSeconds;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final double distanceMeters;
  final double? peakSpeedKmh;
  final int totalSensorRows;
  final int totalEventsCount;
  final String? routeCoordinatesJson;
  final String? notes;
  const Trip({
    required this.id,
    required this.riderName,
    required this.wristSide,
    required this.startTimeUtc,
    this.endTimeUtc,
    this.startTimestampUtc,
    this.endTimestampUtc,
    this.totalDistanceKm,
    this.totalDurationMin,
    this.avgSpeedKmh,
    this.maxSpeedKmh,
    required this.harshBrakeCount,
    required this.harshAccelCount,
    required this.harshTurnCount,
    required this.bumpCount,
    required this.confirmedEventCount,
    this.eventsPerKm,
    this.avgHr,
    this.maxHr,
    this.hrSpikeConfirmedRatio,
    this.nightDrivingPct,
    this.driverScore,
    required this.durationSeconds,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    required this.distanceMeters,
    this.peakSpeedKmh,
    required this.totalSensorRows,
    required this.totalEventsCount,
    this.routeCoordinatesJson,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rider_name'] = Variable<String>(riderName);
    map['wrist_side'] = Variable<String>(wristSide);
    map['start_time_utc'] = Variable<DateTime>(startTimeUtc);
    if (!nullToAbsent || endTimeUtc != null) {
      map['end_time_utc'] = Variable<DateTime>(endTimeUtc);
    }
    if (!nullToAbsent || startTimestampUtc != null) {
      map['start_timestamp_utc'] = Variable<DateTime>(startTimestampUtc);
    }
    if (!nullToAbsent || endTimestampUtc != null) {
      map['end_timestamp_utc'] = Variable<DateTime>(endTimestampUtc);
    }
    if (!nullToAbsent || totalDistanceKm != null) {
      map['total_distance_km'] = Variable<double>(totalDistanceKm);
    }
    if (!nullToAbsent || totalDurationMin != null) {
      map['total_duration_min'] = Variable<double>(totalDurationMin);
    }
    if (!nullToAbsent || avgSpeedKmh != null) {
      map['avg_speed_kmh'] = Variable<double>(avgSpeedKmh);
    }
    if (!nullToAbsent || maxSpeedKmh != null) {
      map['max_speed_kmh'] = Variable<double>(maxSpeedKmh);
    }
    map['harsh_brake_count'] = Variable<int>(harshBrakeCount);
    map['harsh_accel_count'] = Variable<int>(harshAccelCount);
    map['harsh_turn_count'] = Variable<int>(harshTurnCount);
    map['bump_count'] = Variable<int>(bumpCount);
    map['confirmed_event_count'] = Variable<int>(confirmedEventCount);
    if (!nullToAbsent || eventsPerKm != null) {
      map['events_per_km'] = Variable<double>(eventsPerKm);
    }
    if (!nullToAbsent || avgHr != null) {
      map['avg_hr'] = Variable<double>(avgHr);
    }
    if (!nullToAbsent || maxHr != null) {
      map['max_hr'] = Variable<int>(maxHr);
    }
    if (!nullToAbsent || hrSpikeConfirmedRatio != null) {
      map['hr_spike_confirmed_ratio'] = Variable<double>(hrSpikeConfirmedRatio);
    }
    if (!nullToAbsent || nightDrivingPct != null) {
      map['night_driving_pct'] = Variable<double>(nightDrivingPct);
    }
    if (!nullToAbsent || driverScore != null) {
      map['driver_score'] = Variable<double>(driverScore);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || startLat != null) {
      map['start_lat'] = Variable<double>(startLat);
    }
    if (!nullToAbsent || startLng != null) {
      map['start_lng'] = Variable<double>(startLng);
    }
    if (!nullToAbsent || endLat != null) {
      map['end_lat'] = Variable<double>(endLat);
    }
    if (!nullToAbsent || endLng != null) {
      map['end_lng'] = Variable<double>(endLng);
    }
    map['distance_meters'] = Variable<double>(distanceMeters);
    if (!nullToAbsent || peakSpeedKmh != null) {
      map['peak_speed_kmh'] = Variable<double>(peakSpeedKmh);
    }
    map['total_sensor_rows'] = Variable<int>(totalSensorRows);
    map['total_events_count'] = Variable<int>(totalEventsCount);
    if (!nullToAbsent || routeCoordinatesJson != null) {
      map['route_coordinates_json'] = Variable<String>(routeCoordinatesJson);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      riderName: Value(riderName),
      wristSide: Value(wristSide),
      startTimeUtc: Value(startTimeUtc),
      endTimeUtc: endTimeUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(endTimeUtc),
      startTimestampUtc: startTimestampUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(startTimestampUtc),
      endTimestampUtc: endTimestampUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(endTimestampUtc),
      totalDistanceKm: totalDistanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDistanceKm),
      totalDurationMin: totalDurationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDurationMin),
      avgSpeedKmh: avgSpeedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(avgSpeedKmh),
      maxSpeedKmh: maxSpeedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(maxSpeedKmh),
      harshBrakeCount: Value(harshBrakeCount),
      harshAccelCount: Value(harshAccelCount),
      harshTurnCount: Value(harshTurnCount),
      bumpCount: Value(bumpCount),
      confirmedEventCount: Value(confirmedEventCount),
      eventsPerKm: eventsPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(eventsPerKm),
      avgHr: avgHr == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHr),
      maxHr: maxHr == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHr),
      hrSpikeConfirmedRatio: hrSpikeConfirmedRatio == null && nullToAbsent
          ? const Value.absent()
          : Value(hrSpikeConfirmedRatio),
      nightDrivingPct: nightDrivingPct == null && nullToAbsent
          ? const Value.absent()
          : Value(nightDrivingPct),
      driverScore: driverScore == null && nullToAbsent
          ? const Value.absent()
          : Value(driverScore),
      durationSeconds: Value(durationSeconds),
      startLat: startLat == null && nullToAbsent
          ? const Value.absent()
          : Value(startLat),
      startLng: startLng == null && nullToAbsent
          ? const Value.absent()
          : Value(startLng),
      endLat: endLat == null && nullToAbsent
          ? const Value.absent()
          : Value(endLat),
      endLng: endLng == null && nullToAbsent
          ? const Value.absent()
          : Value(endLng),
      distanceMeters: Value(distanceMeters),
      peakSpeedKmh: peakSpeedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(peakSpeedKmh),
      totalSensorRows: Value(totalSensorRows),
      totalEventsCount: Value(totalEventsCount),
      routeCoordinatesJson: routeCoordinatesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(routeCoordinatesJson),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Trip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<int>(json['id']),
      riderName: serializer.fromJson<String>(json['riderName']),
      wristSide: serializer.fromJson<String>(json['wristSide']),
      startTimeUtc: serializer.fromJson<DateTime>(json['startTimeUtc']),
      endTimeUtc: serializer.fromJson<DateTime?>(json['endTimeUtc']),
      startTimestampUtc: serializer.fromJson<DateTime?>(
        json['startTimestampUtc'],
      ),
      endTimestampUtc: serializer.fromJson<DateTime?>(json['endTimestampUtc']),
      totalDistanceKm: serializer.fromJson<double?>(json['totalDistanceKm']),
      totalDurationMin: serializer.fromJson<double?>(json['totalDurationMin']),
      avgSpeedKmh: serializer.fromJson<double?>(json['avgSpeedKmh']),
      maxSpeedKmh: serializer.fromJson<double?>(json['maxSpeedKmh']),
      harshBrakeCount: serializer.fromJson<int>(json['harshBrakeCount']),
      harshAccelCount: serializer.fromJson<int>(json['harshAccelCount']),
      harshTurnCount: serializer.fromJson<int>(json['harshTurnCount']),
      bumpCount: serializer.fromJson<int>(json['bumpCount']),
      confirmedEventCount: serializer.fromJson<int>(
        json['confirmedEventCount'],
      ),
      eventsPerKm: serializer.fromJson<double?>(json['eventsPerKm']),
      avgHr: serializer.fromJson<double?>(json['avgHr']),
      maxHr: serializer.fromJson<int?>(json['maxHr']),
      hrSpikeConfirmedRatio: serializer.fromJson<double?>(
        json['hrSpikeConfirmedRatio'],
      ),
      nightDrivingPct: serializer.fromJson<double?>(json['nightDrivingPct']),
      driverScore: serializer.fromJson<double?>(json['driverScore']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      startLat: serializer.fromJson<double?>(json['startLat']),
      startLng: serializer.fromJson<double?>(json['startLng']),
      endLat: serializer.fromJson<double?>(json['endLat']),
      endLng: serializer.fromJson<double?>(json['endLng']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      peakSpeedKmh: serializer.fromJson<double?>(json['peakSpeedKmh']),
      totalSensorRows: serializer.fromJson<int>(json['totalSensorRows']),
      totalEventsCount: serializer.fromJson<int>(json['totalEventsCount']),
      routeCoordinatesJson: serializer.fromJson<String?>(
        json['routeCoordinatesJson'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'riderName': serializer.toJson<String>(riderName),
      'wristSide': serializer.toJson<String>(wristSide),
      'startTimeUtc': serializer.toJson<DateTime>(startTimeUtc),
      'endTimeUtc': serializer.toJson<DateTime?>(endTimeUtc),
      'startTimestampUtc': serializer.toJson<DateTime?>(startTimestampUtc),
      'endTimestampUtc': serializer.toJson<DateTime?>(endTimestampUtc),
      'totalDistanceKm': serializer.toJson<double?>(totalDistanceKm),
      'totalDurationMin': serializer.toJson<double?>(totalDurationMin),
      'avgSpeedKmh': serializer.toJson<double?>(avgSpeedKmh),
      'maxSpeedKmh': serializer.toJson<double?>(maxSpeedKmh),
      'harshBrakeCount': serializer.toJson<int>(harshBrakeCount),
      'harshAccelCount': serializer.toJson<int>(harshAccelCount),
      'harshTurnCount': serializer.toJson<int>(harshTurnCount),
      'bumpCount': serializer.toJson<int>(bumpCount),
      'confirmedEventCount': serializer.toJson<int>(confirmedEventCount),
      'eventsPerKm': serializer.toJson<double?>(eventsPerKm),
      'avgHr': serializer.toJson<double?>(avgHr),
      'maxHr': serializer.toJson<int?>(maxHr),
      'hrSpikeConfirmedRatio': serializer.toJson<double?>(
        hrSpikeConfirmedRatio,
      ),
      'nightDrivingPct': serializer.toJson<double?>(nightDrivingPct),
      'driverScore': serializer.toJson<double?>(driverScore),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'startLat': serializer.toJson<double?>(startLat),
      'startLng': serializer.toJson<double?>(startLng),
      'endLat': serializer.toJson<double?>(endLat),
      'endLng': serializer.toJson<double?>(endLng),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'peakSpeedKmh': serializer.toJson<double?>(peakSpeedKmh),
      'totalSensorRows': serializer.toJson<int>(totalSensorRows),
      'totalEventsCount': serializer.toJson<int>(totalEventsCount),
      'routeCoordinatesJson': serializer.toJson<String?>(routeCoordinatesJson),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Trip copyWith({
    int? id,
    String? riderName,
    String? wristSide,
    DateTime? startTimeUtc,
    Value<DateTime?> endTimeUtc = const Value.absent(),
    Value<DateTime?> startTimestampUtc = const Value.absent(),
    Value<DateTime?> endTimestampUtc = const Value.absent(),
    Value<double?> totalDistanceKm = const Value.absent(),
    Value<double?> totalDurationMin = const Value.absent(),
    Value<double?> avgSpeedKmh = const Value.absent(),
    Value<double?> maxSpeedKmh = const Value.absent(),
    int? harshBrakeCount,
    int? harshAccelCount,
    int? harshTurnCount,
    int? bumpCount,
    int? confirmedEventCount,
    Value<double?> eventsPerKm = const Value.absent(),
    Value<double?> avgHr = const Value.absent(),
    Value<int?> maxHr = const Value.absent(),
    Value<double?> hrSpikeConfirmedRatio = const Value.absent(),
    Value<double?> nightDrivingPct = const Value.absent(),
    Value<double?> driverScore = const Value.absent(),
    int? durationSeconds,
    Value<double?> startLat = const Value.absent(),
    Value<double?> startLng = const Value.absent(),
    Value<double?> endLat = const Value.absent(),
    Value<double?> endLng = const Value.absent(),
    double? distanceMeters,
    Value<double?> peakSpeedKmh = const Value.absent(),
    int? totalSensorRows,
    int? totalEventsCount,
    Value<String?> routeCoordinatesJson = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Trip(
    id: id ?? this.id,
    riderName: riderName ?? this.riderName,
    wristSide: wristSide ?? this.wristSide,
    startTimeUtc: startTimeUtc ?? this.startTimeUtc,
    endTimeUtc: endTimeUtc.present ? endTimeUtc.value : this.endTimeUtc,
    startTimestampUtc: startTimestampUtc.present
        ? startTimestampUtc.value
        : this.startTimestampUtc,
    endTimestampUtc: endTimestampUtc.present
        ? endTimestampUtc.value
        : this.endTimestampUtc,
    totalDistanceKm: totalDistanceKm.present
        ? totalDistanceKm.value
        : this.totalDistanceKm,
    totalDurationMin: totalDurationMin.present
        ? totalDurationMin.value
        : this.totalDurationMin,
    avgSpeedKmh: avgSpeedKmh.present ? avgSpeedKmh.value : this.avgSpeedKmh,
    maxSpeedKmh: maxSpeedKmh.present ? maxSpeedKmh.value : this.maxSpeedKmh,
    harshBrakeCount: harshBrakeCount ?? this.harshBrakeCount,
    harshAccelCount: harshAccelCount ?? this.harshAccelCount,
    harshTurnCount: harshTurnCount ?? this.harshTurnCount,
    bumpCount: bumpCount ?? this.bumpCount,
    confirmedEventCount: confirmedEventCount ?? this.confirmedEventCount,
    eventsPerKm: eventsPerKm.present ? eventsPerKm.value : this.eventsPerKm,
    avgHr: avgHr.present ? avgHr.value : this.avgHr,
    maxHr: maxHr.present ? maxHr.value : this.maxHr,
    hrSpikeConfirmedRatio: hrSpikeConfirmedRatio.present
        ? hrSpikeConfirmedRatio.value
        : this.hrSpikeConfirmedRatio,
    nightDrivingPct: nightDrivingPct.present
        ? nightDrivingPct.value
        : this.nightDrivingPct,
    driverScore: driverScore.present ? driverScore.value : this.driverScore,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    startLat: startLat.present ? startLat.value : this.startLat,
    startLng: startLng.present ? startLng.value : this.startLng,
    endLat: endLat.present ? endLat.value : this.endLat,
    endLng: endLng.present ? endLng.value : this.endLng,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    peakSpeedKmh: peakSpeedKmh.present ? peakSpeedKmh.value : this.peakSpeedKmh,
    totalSensorRows: totalSensorRows ?? this.totalSensorRows,
    totalEventsCount: totalEventsCount ?? this.totalEventsCount,
    routeCoordinatesJson: routeCoordinatesJson.present
        ? routeCoordinatesJson.value
        : this.routeCoordinatesJson,
    notes: notes.present ? notes.value : this.notes,
  );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      riderName: data.riderName.present ? data.riderName.value : this.riderName,
      wristSide: data.wristSide.present ? data.wristSide.value : this.wristSide,
      startTimeUtc: data.startTimeUtc.present
          ? data.startTimeUtc.value
          : this.startTimeUtc,
      endTimeUtc: data.endTimeUtc.present
          ? data.endTimeUtc.value
          : this.endTimeUtc,
      startTimestampUtc: data.startTimestampUtc.present
          ? data.startTimestampUtc.value
          : this.startTimestampUtc,
      endTimestampUtc: data.endTimestampUtc.present
          ? data.endTimestampUtc.value
          : this.endTimestampUtc,
      totalDistanceKm: data.totalDistanceKm.present
          ? data.totalDistanceKm.value
          : this.totalDistanceKm,
      totalDurationMin: data.totalDurationMin.present
          ? data.totalDurationMin.value
          : this.totalDurationMin,
      avgSpeedKmh: data.avgSpeedKmh.present
          ? data.avgSpeedKmh.value
          : this.avgSpeedKmh,
      maxSpeedKmh: data.maxSpeedKmh.present
          ? data.maxSpeedKmh.value
          : this.maxSpeedKmh,
      harshBrakeCount: data.harshBrakeCount.present
          ? data.harshBrakeCount.value
          : this.harshBrakeCount,
      harshAccelCount: data.harshAccelCount.present
          ? data.harshAccelCount.value
          : this.harshAccelCount,
      harshTurnCount: data.harshTurnCount.present
          ? data.harshTurnCount.value
          : this.harshTurnCount,
      bumpCount: data.bumpCount.present ? data.bumpCount.value : this.bumpCount,
      confirmedEventCount: data.confirmedEventCount.present
          ? data.confirmedEventCount.value
          : this.confirmedEventCount,
      eventsPerKm: data.eventsPerKm.present
          ? data.eventsPerKm.value
          : this.eventsPerKm,
      avgHr: data.avgHr.present ? data.avgHr.value : this.avgHr,
      maxHr: data.maxHr.present ? data.maxHr.value : this.maxHr,
      hrSpikeConfirmedRatio: data.hrSpikeConfirmedRatio.present
          ? data.hrSpikeConfirmedRatio.value
          : this.hrSpikeConfirmedRatio,
      nightDrivingPct: data.nightDrivingPct.present
          ? data.nightDrivingPct.value
          : this.nightDrivingPct,
      driverScore: data.driverScore.present
          ? data.driverScore.value
          : this.driverScore,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      startLat: data.startLat.present ? data.startLat.value : this.startLat,
      startLng: data.startLng.present ? data.startLng.value : this.startLng,
      endLat: data.endLat.present ? data.endLat.value : this.endLat,
      endLng: data.endLng.present ? data.endLng.value : this.endLng,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      peakSpeedKmh: data.peakSpeedKmh.present
          ? data.peakSpeedKmh.value
          : this.peakSpeedKmh,
      totalSensorRows: data.totalSensorRows.present
          ? data.totalSensorRows.value
          : this.totalSensorRows,
      totalEventsCount: data.totalEventsCount.present
          ? data.totalEventsCount.value
          : this.totalEventsCount,
      routeCoordinatesJson: data.routeCoordinatesJson.present
          ? data.routeCoordinatesJson.value
          : this.routeCoordinatesJson,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('riderName: $riderName, ')
          ..write('wristSide: $wristSide, ')
          ..write('startTimeUtc: $startTimeUtc, ')
          ..write('endTimeUtc: $endTimeUtc, ')
          ..write('startTimestampUtc: $startTimestampUtc, ')
          ..write('endTimestampUtc: $endTimestampUtc, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('totalDurationMin: $totalDurationMin, ')
          ..write('avgSpeedKmh: $avgSpeedKmh, ')
          ..write('maxSpeedKmh: $maxSpeedKmh, ')
          ..write('harshBrakeCount: $harshBrakeCount, ')
          ..write('harshAccelCount: $harshAccelCount, ')
          ..write('harshTurnCount: $harshTurnCount, ')
          ..write('bumpCount: $bumpCount, ')
          ..write('confirmedEventCount: $confirmedEventCount, ')
          ..write('eventsPerKm: $eventsPerKm, ')
          ..write('avgHr: $avgHr, ')
          ..write('maxHr: $maxHr, ')
          ..write('hrSpikeConfirmedRatio: $hrSpikeConfirmedRatio, ')
          ..write('nightDrivingPct: $nightDrivingPct, ')
          ..write('driverScore: $driverScore, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startLat: $startLat, ')
          ..write('startLng: $startLng, ')
          ..write('endLat: $endLat, ')
          ..write('endLng: $endLng, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('peakSpeedKmh: $peakSpeedKmh, ')
          ..write('totalSensorRows: $totalSensorRows, ')
          ..write('totalEventsCount: $totalEventsCount, ')
          ..write('routeCoordinatesJson: $routeCoordinatesJson, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    riderName,
    wristSide,
    startTimeUtc,
    endTimeUtc,
    startTimestampUtc,
    endTimestampUtc,
    totalDistanceKm,
    totalDurationMin,
    avgSpeedKmh,
    maxSpeedKmh,
    harshBrakeCount,
    harshAccelCount,
    harshTurnCount,
    bumpCount,
    confirmedEventCount,
    eventsPerKm,
    avgHr,
    maxHr,
    hrSpikeConfirmedRatio,
    nightDrivingPct,
    driverScore,
    durationSeconds,
    startLat,
    startLng,
    endLat,
    endLng,
    distanceMeters,
    peakSpeedKmh,
    totalSensorRows,
    totalEventsCount,
    routeCoordinatesJson,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.riderName == this.riderName &&
          other.wristSide == this.wristSide &&
          other.startTimeUtc == this.startTimeUtc &&
          other.endTimeUtc == this.endTimeUtc &&
          other.startTimestampUtc == this.startTimestampUtc &&
          other.endTimestampUtc == this.endTimestampUtc &&
          other.totalDistanceKm == this.totalDistanceKm &&
          other.totalDurationMin == this.totalDurationMin &&
          other.avgSpeedKmh == this.avgSpeedKmh &&
          other.maxSpeedKmh == this.maxSpeedKmh &&
          other.harshBrakeCount == this.harshBrakeCount &&
          other.harshAccelCount == this.harshAccelCount &&
          other.harshTurnCount == this.harshTurnCount &&
          other.bumpCount == this.bumpCount &&
          other.confirmedEventCount == this.confirmedEventCount &&
          other.eventsPerKm == this.eventsPerKm &&
          other.avgHr == this.avgHr &&
          other.maxHr == this.maxHr &&
          other.hrSpikeConfirmedRatio == this.hrSpikeConfirmedRatio &&
          other.nightDrivingPct == this.nightDrivingPct &&
          other.driverScore == this.driverScore &&
          other.durationSeconds == this.durationSeconds &&
          other.startLat == this.startLat &&
          other.startLng == this.startLng &&
          other.endLat == this.endLat &&
          other.endLng == this.endLng &&
          other.distanceMeters == this.distanceMeters &&
          other.peakSpeedKmh == this.peakSpeedKmh &&
          other.totalSensorRows == this.totalSensorRows &&
          other.totalEventsCount == this.totalEventsCount &&
          other.routeCoordinatesJson == this.routeCoordinatesJson &&
          other.notes == this.notes);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<int> id;
  final Value<String> riderName;
  final Value<String> wristSide;
  final Value<DateTime> startTimeUtc;
  final Value<DateTime?> endTimeUtc;
  final Value<DateTime?> startTimestampUtc;
  final Value<DateTime?> endTimestampUtc;
  final Value<double?> totalDistanceKm;
  final Value<double?> totalDurationMin;
  final Value<double?> avgSpeedKmh;
  final Value<double?> maxSpeedKmh;
  final Value<int> harshBrakeCount;
  final Value<int> harshAccelCount;
  final Value<int> harshTurnCount;
  final Value<int> bumpCount;
  final Value<int> confirmedEventCount;
  final Value<double?> eventsPerKm;
  final Value<double?> avgHr;
  final Value<int?> maxHr;
  final Value<double?> hrSpikeConfirmedRatio;
  final Value<double?> nightDrivingPct;
  final Value<double?> driverScore;
  final Value<int> durationSeconds;
  final Value<double?> startLat;
  final Value<double?> startLng;
  final Value<double?> endLat;
  final Value<double?> endLng;
  final Value<double> distanceMeters;
  final Value<double?> peakSpeedKmh;
  final Value<int> totalSensorRows;
  final Value<int> totalEventsCount;
  final Value<String?> routeCoordinatesJson;
  final Value<String?> notes;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.riderName = const Value.absent(),
    this.wristSide = const Value.absent(),
    this.startTimeUtc = const Value.absent(),
    this.endTimeUtc = const Value.absent(),
    this.startTimestampUtc = const Value.absent(),
    this.endTimestampUtc = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.totalDurationMin = const Value.absent(),
    this.avgSpeedKmh = const Value.absent(),
    this.maxSpeedKmh = const Value.absent(),
    this.harshBrakeCount = const Value.absent(),
    this.harshAccelCount = const Value.absent(),
    this.harshTurnCount = const Value.absent(),
    this.bumpCount = const Value.absent(),
    this.confirmedEventCount = const Value.absent(),
    this.eventsPerKm = const Value.absent(),
    this.avgHr = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.hrSpikeConfirmedRatio = const Value.absent(),
    this.nightDrivingPct = const Value.absent(),
    this.driverScore = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.startLat = const Value.absent(),
    this.startLng = const Value.absent(),
    this.endLat = const Value.absent(),
    this.endLng = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.peakSpeedKmh = const Value.absent(),
    this.totalSensorRows = const Value.absent(),
    this.totalEventsCount = const Value.absent(),
    this.routeCoordinatesJson = const Value.absent(),
    this.notes = const Value.absent(),
  });
  TripsCompanion.insert({
    this.id = const Value.absent(),
    this.riderName = const Value.absent(),
    this.wristSide = const Value.absent(),
    required DateTime startTimeUtc,
    this.endTimeUtc = const Value.absent(),
    this.startTimestampUtc = const Value.absent(),
    this.endTimestampUtc = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.totalDurationMin = const Value.absent(),
    this.avgSpeedKmh = const Value.absent(),
    this.maxSpeedKmh = const Value.absent(),
    this.harshBrakeCount = const Value.absent(),
    this.harshAccelCount = const Value.absent(),
    this.harshTurnCount = const Value.absent(),
    this.bumpCount = const Value.absent(),
    this.confirmedEventCount = const Value.absent(),
    this.eventsPerKm = const Value.absent(),
    this.avgHr = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.hrSpikeConfirmedRatio = const Value.absent(),
    this.nightDrivingPct = const Value.absent(),
    this.driverScore = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.startLat = const Value.absent(),
    this.startLng = const Value.absent(),
    this.endLat = const Value.absent(),
    this.endLng = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.peakSpeedKmh = const Value.absent(),
    this.totalSensorRows = const Value.absent(),
    this.totalEventsCount = const Value.absent(),
    this.routeCoordinatesJson = const Value.absent(),
    this.notes = const Value.absent(),
  }) : startTimeUtc = Value(startTimeUtc);
  static Insertable<Trip> custom({
    Expression<int>? id,
    Expression<String>? riderName,
    Expression<String>? wristSide,
    Expression<DateTime>? startTimeUtc,
    Expression<DateTime>? endTimeUtc,
    Expression<DateTime>? startTimestampUtc,
    Expression<DateTime>? endTimestampUtc,
    Expression<double>? totalDistanceKm,
    Expression<double>? totalDurationMin,
    Expression<double>? avgSpeedKmh,
    Expression<double>? maxSpeedKmh,
    Expression<int>? harshBrakeCount,
    Expression<int>? harshAccelCount,
    Expression<int>? harshTurnCount,
    Expression<int>? bumpCount,
    Expression<int>? confirmedEventCount,
    Expression<double>? eventsPerKm,
    Expression<double>? avgHr,
    Expression<int>? maxHr,
    Expression<double>? hrSpikeConfirmedRatio,
    Expression<double>? nightDrivingPct,
    Expression<double>? driverScore,
    Expression<int>? durationSeconds,
    Expression<double>? startLat,
    Expression<double>? startLng,
    Expression<double>? endLat,
    Expression<double>? endLng,
    Expression<double>? distanceMeters,
    Expression<double>? peakSpeedKmh,
    Expression<int>? totalSensorRows,
    Expression<int>? totalEventsCount,
    Expression<String>? routeCoordinatesJson,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (riderName != null) 'rider_name': riderName,
      if (wristSide != null) 'wrist_side': wristSide,
      if (startTimeUtc != null) 'start_time_utc': startTimeUtc,
      if (endTimeUtc != null) 'end_time_utc': endTimeUtc,
      if (startTimestampUtc != null) 'start_timestamp_utc': startTimestampUtc,
      if (endTimestampUtc != null) 'end_timestamp_utc': endTimestampUtc,
      if (totalDistanceKm != null) 'total_distance_km': totalDistanceKm,
      if (totalDurationMin != null) 'total_duration_min': totalDurationMin,
      if (avgSpeedKmh != null) 'avg_speed_kmh': avgSpeedKmh,
      if (maxSpeedKmh != null) 'max_speed_kmh': maxSpeedKmh,
      if (harshBrakeCount != null) 'harsh_brake_count': harshBrakeCount,
      if (harshAccelCount != null) 'harsh_accel_count': harshAccelCount,
      if (harshTurnCount != null) 'harsh_turn_count': harshTurnCount,
      if (bumpCount != null) 'bump_count': bumpCount,
      if (confirmedEventCount != null)
        'confirmed_event_count': confirmedEventCount,
      if (eventsPerKm != null) 'events_per_km': eventsPerKm,
      if (avgHr != null) 'avg_hr': avgHr,
      if (maxHr != null) 'max_hr': maxHr,
      if (hrSpikeConfirmedRatio != null)
        'hr_spike_confirmed_ratio': hrSpikeConfirmedRatio,
      if (nightDrivingPct != null) 'night_driving_pct': nightDrivingPct,
      if (driverScore != null) 'driver_score': driverScore,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (startLat != null) 'start_lat': startLat,
      if (startLng != null) 'start_lng': startLng,
      if (endLat != null) 'end_lat': endLat,
      if (endLng != null) 'end_lng': endLng,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (peakSpeedKmh != null) 'peak_speed_kmh': peakSpeedKmh,
      if (totalSensorRows != null) 'total_sensor_rows': totalSensorRows,
      if (totalEventsCount != null) 'total_events_count': totalEventsCount,
      if (routeCoordinatesJson != null)
        'route_coordinates_json': routeCoordinatesJson,
      if (notes != null) 'notes': notes,
    });
  }

  TripsCompanion copyWith({
    Value<int>? id,
    Value<String>? riderName,
    Value<String>? wristSide,
    Value<DateTime>? startTimeUtc,
    Value<DateTime?>? endTimeUtc,
    Value<DateTime?>? startTimestampUtc,
    Value<DateTime?>? endTimestampUtc,
    Value<double?>? totalDistanceKm,
    Value<double?>? totalDurationMin,
    Value<double?>? avgSpeedKmh,
    Value<double?>? maxSpeedKmh,
    Value<int>? harshBrakeCount,
    Value<int>? harshAccelCount,
    Value<int>? harshTurnCount,
    Value<int>? bumpCount,
    Value<int>? confirmedEventCount,
    Value<double?>? eventsPerKm,
    Value<double?>? avgHr,
    Value<int?>? maxHr,
    Value<double?>? hrSpikeConfirmedRatio,
    Value<double?>? nightDrivingPct,
    Value<double?>? driverScore,
    Value<int>? durationSeconds,
    Value<double?>? startLat,
    Value<double?>? startLng,
    Value<double?>? endLat,
    Value<double?>? endLng,
    Value<double>? distanceMeters,
    Value<double?>? peakSpeedKmh,
    Value<int>? totalSensorRows,
    Value<int>? totalEventsCount,
    Value<String?>? routeCoordinatesJson,
    Value<String?>? notes,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      riderName: riderName ?? this.riderName,
      wristSide: wristSide ?? this.wristSide,
      startTimeUtc: startTimeUtc ?? this.startTimeUtc,
      endTimeUtc: endTimeUtc ?? this.endTimeUtc,
      startTimestampUtc: startTimestampUtc ?? this.startTimestampUtc,
      endTimestampUtc: endTimestampUtc ?? this.endTimestampUtc,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalDurationMin: totalDurationMin ?? this.totalDurationMin,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      harshBrakeCount: harshBrakeCount ?? this.harshBrakeCount,
      harshAccelCount: harshAccelCount ?? this.harshAccelCount,
      harshTurnCount: harshTurnCount ?? this.harshTurnCount,
      bumpCount: bumpCount ?? this.bumpCount,
      confirmedEventCount: confirmedEventCount ?? this.confirmedEventCount,
      eventsPerKm: eventsPerKm ?? this.eventsPerKm,
      avgHr: avgHr ?? this.avgHr,
      maxHr: maxHr ?? this.maxHr,
      hrSpikeConfirmedRatio:
          hrSpikeConfirmedRatio ?? this.hrSpikeConfirmedRatio,
      nightDrivingPct: nightDrivingPct ?? this.nightDrivingPct,
      driverScore: driverScore ?? this.driverScore,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      peakSpeedKmh: peakSpeedKmh ?? this.peakSpeedKmh,
      totalSensorRows: totalSensorRows ?? this.totalSensorRows,
      totalEventsCount: totalEventsCount ?? this.totalEventsCount,
      routeCoordinatesJson: routeCoordinatesJson ?? this.routeCoordinatesJson,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (riderName.present) {
      map['rider_name'] = Variable<String>(riderName.value);
    }
    if (wristSide.present) {
      map['wrist_side'] = Variable<String>(wristSide.value);
    }
    if (startTimeUtc.present) {
      map['start_time_utc'] = Variable<DateTime>(startTimeUtc.value);
    }
    if (endTimeUtc.present) {
      map['end_time_utc'] = Variable<DateTime>(endTimeUtc.value);
    }
    if (startTimestampUtc.present) {
      map['start_timestamp_utc'] = Variable<DateTime>(startTimestampUtc.value);
    }
    if (endTimestampUtc.present) {
      map['end_timestamp_utc'] = Variable<DateTime>(endTimestampUtc.value);
    }
    if (totalDistanceKm.present) {
      map['total_distance_km'] = Variable<double>(totalDistanceKm.value);
    }
    if (totalDurationMin.present) {
      map['total_duration_min'] = Variable<double>(totalDurationMin.value);
    }
    if (avgSpeedKmh.present) {
      map['avg_speed_kmh'] = Variable<double>(avgSpeedKmh.value);
    }
    if (maxSpeedKmh.present) {
      map['max_speed_kmh'] = Variable<double>(maxSpeedKmh.value);
    }
    if (harshBrakeCount.present) {
      map['harsh_brake_count'] = Variable<int>(harshBrakeCount.value);
    }
    if (harshAccelCount.present) {
      map['harsh_accel_count'] = Variable<int>(harshAccelCount.value);
    }
    if (harshTurnCount.present) {
      map['harsh_turn_count'] = Variable<int>(harshTurnCount.value);
    }
    if (bumpCount.present) {
      map['bump_count'] = Variable<int>(bumpCount.value);
    }
    if (confirmedEventCount.present) {
      map['confirmed_event_count'] = Variable<int>(confirmedEventCount.value);
    }
    if (eventsPerKm.present) {
      map['events_per_km'] = Variable<double>(eventsPerKm.value);
    }
    if (avgHr.present) {
      map['avg_hr'] = Variable<double>(avgHr.value);
    }
    if (maxHr.present) {
      map['max_hr'] = Variable<int>(maxHr.value);
    }
    if (hrSpikeConfirmedRatio.present) {
      map['hr_spike_confirmed_ratio'] = Variable<double>(
        hrSpikeConfirmedRatio.value,
      );
    }
    if (nightDrivingPct.present) {
      map['night_driving_pct'] = Variable<double>(nightDrivingPct.value);
    }
    if (driverScore.present) {
      map['driver_score'] = Variable<double>(driverScore.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (startLat.present) {
      map['start_lat'] = Variable<double>(startLat.value);
    }
    if (startLng.present) {
      map['start_lng'] = Variable<double>(startLng.value);
    }
    if (endLat.present) {
      map['end_lat'] = Variable<double>(endLat.value);
    }
    if (endLng.present) {
      map['end_lng'] = Variable<double>(endLng.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (peakSpeedKmh.present) {
      map['peak_speed_kmh'] = Variable<double>(peakSpeedKmh.value);
    }
    if (totalSensorRows.present) {
      map['total_sensor_rows'] = Variable<int>(totalSensorRows.value);
    }
    if (totalEventsCount.present) {
      map['total_events_count'] = Variable<int>(totalEventsCount.value);
    }
    if (routeCoordinatesJson.present) {
      map['route_coordinates_json'] = Variable<String>(
        routeCoordinatesJson.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('riderName: $riderName, ')
          ..write('wristSide: $wristSide, ')
          ..write('startTimeUtc: $startTimeUtc, ')
          ..write('endTimeUtc: $endTimeUtc, ')
          ..write('startTimestampUtc: $startTimestampUtc, ')
          ..write('endTimestampUtc: $endTimestampUtc, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('totalDurationMin: $totalDurationMin, ')
          ..write('avgSpeedKmh: $avgSpeedKmh, ')
          ..write('maxSpeedKmh: $maxSpeedKmh, ')
          ..write('harshBrakeCount: $harshBrakeCount, ')
          ..write('harshAccelCount: $harshAccelCount, ')
          ..write('harshTurnCount: $harshTurnCount, ')
          ..write('bumpCount: $bumpCount, ')
          ..write('confirmedEventCount: $confirmedEventCount, ')
          ..write('eventsPerKm: $eventsPerKm, ')
          ..write('avgHr: $avgHr, ')
          ..write('maxHr: $maxHr, ')
          ..write('hrSpikeConfirmedRatio: $hrSpikeConfirmedRatio, ')
          ..write('nightDrivingPct: $nightDrivingPct, ')
          ..write('driverScore: $driverScore, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startLat: $startLat, ')
          ..write('startLng: $startLng, ')
          ..write('endLat: $endLat, ')
          ..write('endLng: $endLng, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('peakSpeedKmh: $peakSpeedKmh, ')
          ..write('totalSensorRows: $totalSensorRows, ')
          ..write('totalEventsCount: $totalEventsCount, ')
          ..write('routeCoordinatesJson: $routeCoordinatesJson, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $LocationReadingsTable extends LocationReadings
    with TableInfo<$LocationReadingsTable, LocationReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampUtcMeta = const VerificationMeta(
    'timestampUtc',
  );
  @override
  late final GeneratedColumn<DateTime> timestampUtc = GeneratedColumn<DateTime>(
    'timestamp_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsSpeedMpsMeta = const VerificationMeta(
    'gpsSpeedMps',
  );
  @override
  late final GeneratedColumn<double> gpsSpeedMps = GeneratedColumn<double>(
    'gps_speed_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsHeadingDegMeta = const VerificationMeta(
    'gpsHeadingDeg',
  );
  @override
  late final GeneratedColumn<double> gpsHeadingDeg = GeneratedColumn<double>(
    'gps_heading_deg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsAccuracyMMeta = const VerificationMeta(
    'gpsAccuracyM',
  );
  @override
  late final GeneratedColumn<double> gpsAccuracyM = GeneratedColumn<double>(
    'gps_accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    timestampUtc,
    latitude,
    longitude,
    altitude,
    gpsSpeedMps,
    gpsHeadingDeg,
    gpsAccuracyM,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('timestamp_utc')) {
      context.handle(
        _timestampUtcMeta,
        timestampUtc.isAcceptableOrUnknown(
          data['timestamp_utc']!,
          _timestampUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampUtcMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('gps_speed_mps')) {
      context.handle(
        _gpsSpeedMpsMeta,
        gpsSpeedMps.isAcceptableOrUnknown(
          data['gps_speed_mps']!,
          _gpsSpeedMpsMeta,
        ),
      );
    }
    if (data.containsKey('gps_heading_deg')) {
      context.handle(
        _gpsHeadingDegMeta,
        gpsHeadingDeg.isAcceptableOrUnknown(
          data['gps_heading_deg']!,
          _gpsHeadingDegMeta,
        ),
      );
    }
    if (data.containsKey('gps_accuracy_m')) {
      context.handle(
        _gpsAccuracyMMeta,
        gpsAccuracyM.isAcceptableOrUnknown(
          data['gps_accuracy_m']!,
          _gpsAccuracyMMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      )!,
      timestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp_utc'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      gpsSpeedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_speed_mps'],
      ),
      gpsHeadingDeg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_heading_deg'],
      ),
      gpsAccuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_accuracy_m'],
      ),
    );
  }

  @override
  $LocationReadingsTable createAlias(String alias) {
    return $LocationReadingsTable(attachedDatabase, alias);
  }
}

class LocationReading extends DataClass implements Insertable<LocationReading> {
  final int id;
  final int tripId;
  final DateTime timestampUtc;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? gpsSpeedMps;
  final double? gpsHeadingDeg;
  final double? gpsAccuracyM;
  const LocationReading({
    required this.id,
    required this.tripId,
    required this.timestampUtc,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.gpsSpeedMps,
    this.gpsHeadingDeg,
    this.gpsAccuracyM,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trip_id'] = Variable<int>(tripId);
    map['timestamp_utc'] = Variable<DateTime>(timestampUtc);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    if (!nullToAbsent || gpsSpeedMps != null) {
      map['gps_speed_mps'] = Variable<double>(gpsSpeedMps);
    }
    if (!nullToAbsent || gpsHeadingDeg != null) {
      map['gps_heading_deg'] = Variable<double>(gpsHeadingDeg);
    }
    if (!nullToAbsent || gpsAccuracyM != null) {
      map['gps_accuracy_m'] = Variable<double>(gpsAccuracyM);
    }
    return map;
  }

  LocationReadingsCompanion toCompanion(bool nullToAbsent) {
    return LocationReadingsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      timestampUtc: Value(timestampUtc),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      gpsSpeedMps: gpsSpeedMps == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsSpeedMps),
      gpsHeadingDeg: gpsHeadingDeg == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsHeadingDeg),
      gpsAccuracyM: gpsAccuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracyM),
    );
  }

  factory LocationReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationReading(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<int>(json['tripId']),
      timestampUtc: serializer.fromJson<DateTime>(json['timestampUtc']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      gpsSpeedMps: serializer.fromJson<double?>(json['gpsSpeedMps']),
      gpsHeadingDeg: serializer.fromJson<double?>(json['gpsHeadingDeg']),
      gpsAccuracyM: serializer.fromJson<double?>(json['gpsAccuracyM']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<int>(tripId),
      'timestampUtc': serializer.toJson<DateTime>(timestampUtc),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double?>(altitude),
      'gpsSpeedMps': serializer.toJson<double?>(gpsSpeedMps),
      'gpsHeadingDeg': serializer.toJson<double?>(gpsHeadingDeg),
      'gpsAccuracyM': serializer.toJson<double?>(gpsAccuracyM),
    };
  }

  LocationReading copyWith({
    int? id,
    int? tripId,
    DateTime? timestampUtc,
    double? latitude,
    double? longitude,
    Value<double?> altitude = const Value.absent(),
    Value<double?> gpsSpeedMps = const Value.absent(),
    Value<double?> gpsHeadingDeg = const Value.absent(),
    Value<double?> gpsAccuracyM = const Value.absent(),
  }) => LocationReading(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    timestampUtc: timestampUtc ?? this.timestampUtc,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
    gpsSpeedMps: gpsSpeedMps.present ? gpsSpeedMps.value : this.gpsSpeedMps,
    gpsHeadingDeg: gpsHeadingDeg.present
        ? gpsHeadingDeg.value
        : this.gpsHeadingDeg,
    gpsAccuracyM: gpsAccuracyM.present ? gpsAccuracyM.value : this.gpsAccuracyM,
  );
  LocationReading copyWithCompanion(LocationReadingsCompanion data) {
    return LocationReading(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      timestampUtc: data.timestampUtc.present
          ? data.timestampUtc.value
          : this.timestampUtc,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      gpsSpeedMps: data.gpsSpeedMps.present
          ? data.gpsSpeedMps.value
          : this.gpsSpeedMps,
      gpsHeadingDeg: data.gpsHeadingDeg.present
          ? data.gpsHeadingDeg.value
          : this.gpsHeadingDeg,
      gpsAccuracyM: data.gpsAccuracyM.present
          ? data.gpsAccuracyM.value
          : this.gpsAccuracyM,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationReading(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('gpsSpeedMps: $gpsSpeedMps, ')
          ..write('gpsHeadingDeg: $gpsHeadingDeg, ')
          ..write('gpsAccuracyM: $gpsAccuracyM')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    timestampUtc,
    latitude,
    longitude,
    altitude,
    gpsSpeedMps,
    gpsHeadingDeg,
    gpsAccuracyM,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationReading &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.timestampUtc == this.timestampUtc &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.gpsSpeedMps == this.gpsSpeedMps &&
          other.gpsHeadingDeg == this.gpsHeadingDeg &&
          other.gpsAccuracyM == this.gpsAccuracyM);
}

class LocationReadingsCompanion extends UpdateCompanion<LocationReading> {
  final Value<int> id;
  final Value<int> tripId;
  final Value<DateTime> timestampUtc;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitude;
  final Value<double?> gpsSpeedMps;
  final Value<double?> gpsHeadingDeg;
  final Value<double?> gpsAccuracyM;
  const LocationReadingsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.timestampUtc = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.gpsSpeedMps = const Value.absent(),
    this.gpsHeadingDeg = const Value.absent(),
    this.gpsAccuracyM = const Value.absent(),
  });
  LocationReadingsCompanion.insert({
    this.id = const Value.absent(),
    required int tripId,
    required DateTime timestampUtc,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    this.gpsSpeedMps = const Value.absent(),
    this.gpsHeadingDeg = const Value.absent(),
    this.gpsAccuracyM = const Value.absent(),
  }) : tripId = Value(tripId),
       timestampUtc = Value(timestampUtc),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<LocationReading> custom({
    Expression<int>? id,
    Expression<int>? tripId,
    Expression<DateTime>? timestampUtc,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? gpsSpeedMps,
    Expression<double>? gpsHeadingDeg,
    Expression<double>? gpsAccuracyM,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (timestampUtc != null) 'timestamp_utc': timestampUtc,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (gpsSpeedMps != null) 'gps_speed_mps': gpsSpeedMps,
      if (gpsHeadingDeg != null) 'gps_heading_deg': gpsHeadingDeg,
      if (gpsAccuracyM != null) 'gps_accuracy_m': gpsAccuracyM,
    });
  }

  LocationReadingsCompanion copyWith({
    Value<int>? id,
    Value<int>? tripId,
    Value<DateTime>? timestampUtc,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitude,
    Value<double?>? gpsSpeedMps,
    Value<double?>? gpsHeadingDeg,
    Value<double?>? gpsAccuracyM,
  }) {
    return LocationReadingsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      gpsSpeedMps: gpsSpeedMps ?? this.gpsSpeedMps,
      gpsHeadingDeg: gpsHeadingDeg ?? this.gpsHeadingDeg,
      gpsAccuracyM: gpsAccuracyM ?? this.gpsAccuracyM,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (timestampUtc.present) {
      map['timestamp_utc'] = Variable<DateTime>(timestampUtc.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (gpsSpeedMps.present) {
      map['gps_speed_mps'] = Variable<double>(gpsSpeedMps.value);
    }
    if (gpsHeadingDeg.present) {
      map['gps_heading_deg'] = Variable<double>(gpsHeadingDeg.value);
    }
    if (gpsAccuracyM.present) {
      map['gps_accuracy_m'] = Variable<double>(gpsAccuracyM.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationReadingsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('gpsSpeedMps: $gpsSpeedMps, ')
          ..write('gpsHeadingDeg: $gpsHeadingDeg, ')
          ..write('gpsAccuracyM: $gpsAccuracyM')
          ..write(')'))
        .toString();
  }
}

class $TripCalibrationsTable extends TripCalibrations
    with TableInfo<$TripCalibrationsTable, TripCalibration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripCalibrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mountLocationMeta = const VerificationMeta(
    'mountLocation',
  );
  @override
  late final GeneratedColumn<String> mountLocation = GeneratedColumn<String>(
    'mount_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineNoiseFreqHzMeta = const VerificationMeta(
    'engineNoiseFreqHz',
  );
  @override
  late final GeneratedColumn<double> engineNoiseFreqHz =
      GeneratedColumn<double>(
        'engine_noise_freq_hz',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _engineNoiseAmplitudeMeta =
      const VerificationMeta('engineNoiseAmplitude');
  @override
  late final GeneratedColumn<double> engineNoiseAmplitude =
      GeneratedColumn<double>(
        'engine_noise_amplitude',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _calibratedAtUtcMeta = const VerificationMeta(
    'calibratedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> calibratedAtUtc =
      GeneratedColumn<DateTime>(
        'calibrated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _calibrationValidMeta = const VerificationMeta(
    'calibrationValid',
  );
  @override
  late final GeneratedColumn<bool> calibrationValid = GeneratedColumn<bool>(
    'calibration_valid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("calibration_valid" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    mountLocation,
    engineNoiseFreqHz,
    engineNoiseAmplitude,
    calibratedAtUtc,
    calibrationValid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_calibrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripCalibration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('mount_location')) {
      context.handle(
        _mountLocationMeta,
        mountLocation.isAcceptableOrUnknown(
          data['mount_location']!,
          _mountLocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mountLocationMeta);
    }
    if (data.containsKey('engine_noise_freq_hz')) {
      context.handle(
        _engineNoiseFreqHzMeta,
        engineNoiseFreqHz.isAcceptableOrUnknown(
          data['engine_noise_freq_hz']!,
          _engineNoiseFreqHzMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineNoiseFreqHzMeta);
    }
    if (data.containsKey('engine_noise_amplitude')) {
      context.handle(
        _engineNoiseAmplitudeMeta,
        engineNoiseAmplitude.isAcceptableOrUnknown(
          data['engine_noise_amplitude']!,
          _engineNoiseAmplitudeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineNoiseAmplitudeMeta);
    }
    if (data.containsKey('calibrated_at_utc')) {
      context.handle(
        _calibratedAtUtcMeta,
        calibratedAtUtc.isAcceptableOrUnknown(
          data['calibrated_at_utc']!,
          _calibratedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calibratedAtUtcMeta);
    }
    if (data.containsKey('calibration_valid')) {
      context.handle(
        _calibrationValidMeta,
        calibrationValid.isAcceptableOrUnknown(
          data['calibration_valid']!,
          _calibrationValidMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripCalibration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripCalibration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      )!,
      mountLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mount_location'],
      )!,
      engineNoiseFreqHz: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}engine_noise_freq_hz'],
      )!,
      engineNoiseAmplitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}engine_noise_amplitude'],
      )!,
      calibratedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calibrated_at_utc'],
      )!,
      calibrationValid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}calibration_valid'],
      )!,
    );
  }

  @override
  $TripCalibrationsTable createAlias(String alias) {
    return $TripCalibrationsTable(attachedDatabase, alias);
  }
}

class TripCalibration extends DataClass implements Insertable<TripCalibration> {
  final int id;
  final int tripId;
  final String mountLocation;
  final double engineNoiseFreqHz;
  final double engineNoiseAmplitude;
  final DateTime calibratedAtUtc;
  final bool calibrationValid;
  const TripCalibration({
    required this.id,
    required this.tripId,
    required this.mountLocation,
    required this.engineNoiseFreqHz,
    required this.engineNoiseAmplitude,
    required this.calibratedAtUtc,
    required this.calibrationValid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trip_id'] = Variable<int>(tripId);
    map['mount_location'] = Variable<String>(mountLocation);
    map['engine_noise_freq_hz'] = Variable<double>(engineNoiseFreqHz);
    map['engine_noise_amplitude'] = Variable<double>(engineNoiseAmplitude);
    map['calibrated_at_utc'] = Variable<DateTime>(calibratedAtUtc);
    map['calibration_valid'] = Variable<bool>(calibrationValid);
    return map;
  }

  TripCalibrationsCompanion toCompanion(bool nullToAbsent) {
    return TripCalibrationsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      mountLocation: Value(mountLocation),
      engineNoiseFreqHz: Value(engineNoiseFreqHz),
      engineNoiseAmplitude: Value(engineNoiseAmplitude),
      calibratedAtUtc: Value(calibratedAtUtc),
      calibrationValid: Value(calibrationValid),
    );
  }

  factory TripCalibration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripCalibration(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<int>(json['tripId']),
      mountLocation: serializer.fromJson<String>(json['mountLocation']),
      engineNoiseFreqHz: serializer.fromJson<double>(json['engineNoiseFreqHz']),
      engineNoiseAmplitude: serializer.fromJson<double>(
        json['engineNoiseAmplitude'],
      ),
      calibratedAtUtc: serializer.fromJson<DateTime>(json['calibratedAtUtc']),
      calibrationValid: serializer.fromJson<bool>(json['calibrationValid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<int>(tripId),
      'mountLocation': serializer.toJson<String>(mountLocation),
      'engineNoiseFreqHz': serializer.toJson<double>(engineNoiseFreqHz),
      'engineNoiseAmplitude': serializer.toJson<double>(engineNoiseAmplitude),
      'calibratedAtUtc': serializer.toJson<DateTime>(calibratedAtUtc),
      'calibrationValid': serializer.toJson<bool>(calibrationValid),
    };
  }

  TripCalibration copyWith({
    int? id,
    int? tripId,
    String? mountLocation,
    double? engineNoiseFreqHz,
    double? engineNoiseAmplitude,
    DateTime? calibratedAtUtc,
    bool? calibrationValid,
  }) => TripCalibration(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    mountLocation: mountLocation ?? this.mountLocation,
    engineNoiseFreqHz: engineNoiseFreqHz ?? this.engineNoiseFreqHz,
    engineNoiseAmplitude: engineNoiseAmplitude ?? this.engineNoiseAmplitude,
    calibratedAtUtc: calibratedAtUtc ?? this.calibratedAtUtc,
    calibrationValid: calibrationValid ?? this.calibrationValid,
  );
  TripCalibration copyWithCompanion(TripCalibrationsCompanion data) {
    return TripCalibration(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      mountLocation: data.mountLocation.present
          ? data.mountLocation.value
          : this.mountLocation,
      engineNoiseFreqHz: data.engineNoiseFreqHz.present
          ? data.engineNoiseFreqHz.value
          : this.engineNoiseFreqHz,
      engineNoiseAmplitude: data.engineNoiseAmplitude.present
          ? data.engineNoiseAmplitude.value
          : this.engineNoiseAmplitude,
      calibratedAtUtc: data.calibratedAtUtc.present
          ? data.calibratedAtUtc.value
          : this.calibratedAtUtc,
      calibrationValid: data.calibrationValid.present
          ? data.calibrationValid.value
          : this.calibrationValid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripCalibration(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('mountLocation: $mountLocation, ')
          ..write('engineNoiseFreqHz: $engineNoiseFreqHz, ')
          ..write('engineNoiseAmplitude: $engineNoiseAmplitude, ')
          ..write('calibratedAtUtc: $calibratedAtUtc, ')
          ..write('calibrationValid: $calibrationValid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    mountLocation,
    engineNoiseFreqHz,
    engineNoiseAmplitude,
    calibratedAtUtc,
    calibrationValid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripCalibration &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.mountLocation == this.mountLocation &&
          other.engineNoiseFreqHz == this.engineNoiseFreqHz &&
          other.engineNoiseAmplitude == this.engineNoiseAmplitude &&
          other.calibratedAtUtc == this.calibratedAtUtc &&
          other.calibrationValid == this.calibrationValid);
}

class TripCalibrationsCompanion extends UpdateCompanion<TripCalibration> {
  final Value<int> id;
  final Value<int> tripId;
  final Value<String> mountLocation;
  final Value<double> engineNoiseFreqHz;
  final Value<double> engineNoiseAmplitude;
  final Value<DateTime> calibratedAtUtc;
  final Value<bool> calibrationValid;
  const TripCalibrationsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.mountLocation = const Value.absent(),
    this.engineNoiseFreqHz = const Value.absent(),
    this.engineNoiseAmplitude = const Value.absent(),
    this.calibratedAtUtc = const Value.absent(),
    this.calibrationValid = const Value.absent(),
  });
  TripCalibrationsCompanion.insert({
    this.id = const Value.absent(),
    required int tripId,
    required String mountLocation,
    required double engineNoiseFreqHz,
    required double engineNoiseAmplitude,
    required DateTime calibratedAtUtc,
    this.calibrationValid = const Value.absent(),
  }) : tripId = Value(tripId),
       mountLocation = Value(mountLocation),
       engineNoiseFreqHz = Value(engineNoiseFreqHz),
       engineNoiseAmplitude = Value(engineNoiseAmplitude),
       calibratedAtUtc = Value(calibratedAtUtc);
  static Insertable<TripCalibration> custom({
    Expression<int>? id,
    Expression<int>? tripId,
    Expression<String>? mountLocation,
    Expression<double>? engineNoiseFreqHz,
    Expression<double>? engineNoiseAmplitude,
    Expression<DateTime>? calibratedAtUtc,
    Expression<bool>? calibrationValid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (mountLocation != null) 'mount_location': mountLocation,
      if (engineNoiseFreqHz != null) 'engine_noise_freq_hz': engineNoiseFreqHz,
      if (engineNoiseAmplitude != null)
        'engine_noise_amplitude': engineNoiseAmplitude,
      if (calibratedAtUtc != null) 'calibrated_at_utc': calibratedAtUtc,
      if (calibrationValid != null) 'calibration_valid': calibrationValid,
    });
  }

  TripCalibrationsCompanion copyWith({
    Value<int>? id,
    Value<int>? tripId,
    Value<String>? mountLocation,
    Value<double>? engineNoiseFreqHz,
    Value<double>? engineNoiseAmplitude,
    Value<DateTime>? calibratedAtUtc,
    Value<bool>? calibrationValid,
  }) {
    return TripCalibrationsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      mountLocation: mountLocation ?? this.mountLocation,
      engineNoiseFreqHz: engineNoiseFreqHz ?? this.engineNoiseFreqHz,
      engineNoiseAmplitude: engineNoiseAmplitude ?? this.engineNoiseAmplitude,
      calibratedAtUtc: calibratedAtUtc ?? this.calibratedAtUtc,
      calibrationValid: calibrationValid ?? this.calibrationValid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (mountLocation.present) {
      map['mount_location'] = Variable<String>(mountLocation.value);
    }
    if (engineNoiseFreqHz.present) {
      map['engine_noise_freq_hz'] = Variable<double>(engineNoiseFreqHz.value);
    }
    if (engineNoiseAmplitude.present) {
      map['engine_noise_amplitude'] = Variable<double>(
        engineNoiseAmplitude.value,
      );
    }
    if (calibratedAtUtc.present) {
      map['calibrated_at_utc'] = Variable<DateTime>(calibratedAtUtc.value);
    }
    if (calibrationValid.present) {
      map['calibration_valid'] = Variable<bool>(calibrationValid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripCalibrationsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('mountLocation: $mountLocation, ')
          ..write('engineNoiseFreqHz: $engineNoiseFreqHz, ')
          ..write('engineNoiseAmplitude: $engineNoiseAmplitude, ')
          ..write('calibratedAtUtc: $calibratedAtUtc, ')
          ..write('calibrationValid: $calibrationValid')
          ..write(')'))
        .toString();
  }
}

class $RoadEventsTable extends RoadEvents
    with TableInfo<$RoadEventsTable, RoadEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoadEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<double> severity = GeneratedColumn<double>(
    'severity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ml'),
  );
  static const VerificationMeta _detectedAtUtcMeta = const VerificationMeta(
    'detectedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAtUtc =
      GeneratedColumn<DateTime>(
        'detected_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _speedKmhAtDetectionMeta =
      const VerificationMeta('speedKmhAtDetection');
  @override
  late final GeneratedColumn<double> speedKmhAtDetection =
      GeneratedColumn<double>(
        'speed_kmh_at_detection',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _alertCountMeta = const VerificationMeta(
    'alertCount',
  );
  @override
  late final GeneratedColumn<int> alertCount = GeneratedColumn<int>(
    'alert_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _feedbackCountMeta = const VerificationMeta(
    'feedbackCount',
  );
  @override
  late final GeneratedColumn<int> feedbackCount = GeneratedColumn<int>(
    'feedback_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAlertedAtUtcMeta = const VerificationMeta(
    'lastAlertedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> lastAlertedAtUtc =
      GeneratedColumn<DateTime>(
        'last_alerted_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    eventType,
    latitude,
    longitude,
    severity,
    confidence,
    source,
    detectedAtUtc,
    speedKmhAtDetection,
    alertCount,
    feedbackCount,
    lastAlertedAtUtc,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'road_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoadEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('detected_at_utc')) {
      context.handle(
        _detectedAtUtcMeta,
        detectedAtUtc.isAcceptableOrUnknown(
          data['detected_at_utc']!,
          _detectedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectedAtUtcMeta);
    }
    if (data.containsKey('speed_kmh_at_detection')) {
      context.handle(
        _speedKmhAtDetectionMeta,
        speedKmhAtDetection.isAcceptableOrUnknown(
          data['speed_kmh_at_detection']!,
          _speedKmhAtDetectionMeta,
        ),
      );
    }
    if (data.containsKey('alert_count')) {
      context.handle(
        _alertCountMeta,
        alertCount.isAcceptableOrUnknown(data['alert_count']!, _alertCountMeta),
      );
    }
    if (data.containsKey('feedback_count')) {
      context.handle(
        _feedbackCountMeta,
        feedbackCount.isAcceptableOrUnknown(
          data['feedback_count']!,
          _feedbackCountMeta,
        ),
      );
    }
    if (data.containsKey('last_alerted_at_utc')) {
      context.handle(
        _lastAlertedAtUtcMeta,
        lastAlertedAtUtc.isAcceptableOrUnknown(
          data['last_alerted_at_utc']!,
          _lastAlertedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoadEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoadEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}severity'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      detectedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at_utc'],
      )!,
      speedKmhAtDetection: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_kmh_at_detection'],
      ),
      alertCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alert_count'],
      )!,
      feedbackCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feedback_count'],
      )!,
      lastAlertedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_alerted_at_utc'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $RoadEventsTable createAlias(String alias) {
    return $RoadEventsTable(attachedDatabase, alias);
  }
}

class RoadEvent extends DataClass implements Insertable<RoadEvent> {
  final int id;

  /// Trip that first reported this road event (nullable for seeded hazards).
  final int? tripId;

  /// bump | pothole | turn | braking | hazard | unknown
  final String eventType;
  final double latitude;
  final double longitude;

  /// Normalized 0..1 severity derived from the ML confidence / g-force.
  final double? severity;

  /// Model confidence for the detection (0..1).
  final double? confidence;

  /// ml | camera | voice | manual
  final String source;
  final DateTime detectedAtUtc;

  /// Ground speed at the moment the hazard was detected.
  final double? speedKmhAtDetection;

  /// How many pre-alerts have been spoken for this hazard.
  final int alertCount;

  /// How many rider feedback records are linked to this hazard.
  final int feedbackCount;
  final DateTime? lastAlertedAtUtc;
  final String? note;
  const RoadEvent({
    required this.id,
    this.tripId,
    required this.eventType,
    required this.latitude,
    required this.longitude,
    this.severity,
    this.confidence,
    required this.source,
    required this.detectedAtUtc,
    this.speedKmhAtDetection,
    required this.alertCount,
    required this.feedbackCount,
    this.lastAlertedAtUtc,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || severity != null) {
      map['severity'] = Variable<double>(severity);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['source'] = Variable<String>(source);
    map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc);
    if (!nullToAbsent || speedKmhAtDetection != null) {
      map['speed_kmh_at_detection'] = Variable<double>(speedKmhAtDetection);
    }
    map['alert_count'] = Variable<int>(alertCount);
    map['feedback_count'] = Variable<int>(feedbackCount);
    if (!nullToAbsent || lastAlertedAtUtc != null) {
      map['last_alerted_at_utc'] = Variable<DateTime>(lastAlertedAtUtc);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  RoadEventsCompanion toCompanion(bool nullToAbsent) {
    return RoadEventsCompanion(
      id: Value(id),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
      eventType: Value(eventType),
      latitude: Value(latitude),
      longitude: Value(longitude),
      severity: severity == null && nullToAbsent
          ? const Value.absent()
          : Value(severity),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      source: Value(source),
      detectedAtUtc: Value(detectedAtUtc),
      speedKmhAtDetection: speedKmhAtDetection == null && nullToAbsent
          ? const Value.absent()
          : Value(speedKmhAtDetection),
      alertCount: Value(alertCount),
      feedbackCount: Value(feedbackCount),
      lastAlertedAtUtc: lastAlertedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAlertedAtUtc),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory RoadEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoadEvent(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      severity: serializer.fromJson<double?>(json['severity']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      source: serializer.fromJson<String>(json['source']),
      detectedAtUtc: serializer.fromJson<DateTime>(json['detectedAtUtc']),
      speedKmhAtDetection: serializer.fromJson<double?>(
        json['speedKmhAtDetection'],
      ),
      alertCount: serializer.fromJson<int>(json['alertCount']),
      feedbackCount: serializer.fromJson<int>(json['feedbackCount']),
      lastAlertedAtUtc: serializer.fromJson<DateTime?>(
        json['lastAlertedAtUtc'],
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<int?>(tripId),
      'eventType': serializer.toJson<String>(eventType),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'severity': serializer.toJson<double?>(severity),
      'confidence': serializer.toJson<double?>(confidence),
      'source': serializer.toJson<String>(source),
      'detectedAtUtc': serializer.toJson<DateTime>(detectedAtUtc),
      'speedKmhAtDetection': serializer.toJson<double?>(speedKmhAtDetection),
      'alertCount': serializer.toJson<int>(alertCount),
      'feedbackCount': serializer.toJson<int>(feedbackCount),
      'lastAlertedAtUtc': serializer.toJson<DateTime?>(lastAlertedAtUtc),
      'note': serializer.toJson<String?>(note),
    };
  }

  RoadEvent copyWith({
    int? id,
    Value<int?> tripId = const Value.absent(),
    String? eventType,
    double? latitude,
    double? longitude,
    Value<double?> severity = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    String? source,
    DateTime? detectedAtUtc,
    Value<double?> speedKmhAtDetection = const Value.absent(),
    int? alertCount,
    int? feedbackCount,
    Value<DateTime?> lastAlertedAtUtc = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => RoadEvent(
    id: id ?? this.id,
    tripId: tripId.present ? tripId.value : this.tripId,
    eventType: eventType ?? this.eventType,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    severity: severity.present ? severity.value : this.severity,
    confidence: confidence.present ? confidence.value : this.confidence,
    source: source ?? this.source,
    detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
    speedKmhAtDetection: speedKmhAtDetection.present
        ? speedKmhAtDetection.value
        : this.speedKmhAtDetection,
    alertCount: alertCount ?? this.alertCount,
    feedbackCount: feedbackCount ?? this.feedbackCount,
    lastAlertedAtUtc: lastAlertedAtUtc.present
        ? lastAlertedAtUtc.value
        : this.lastAlertedAtUtc,
    note: note.present ? note.value : this.note,
  );
  RoadEvent copyWithCompanion(RoadEventsCompanion data) {
    return RoadEvent(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      severity: data.severity.present ? data.severity.value : this.severity,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      source: data.source.present ? data.source.value : this.source,
      detectedAtUtc: data.detectedAtUtc.present
          ? data.detectedAtUtc.value
          : this.detectedAtUtc,
      speedKmhAtDetection: data.speedKmhAtDetection.present
          ? data.speedKmhAtDetection.value
          : this.speedKmhAtDetection,
      alertCount: data.alertCount.present
          ? data.alertCount.value
          : this.alertCount,
      feedbackCount: data.feedbackCount.present
          ? data.feedbackCount.value
          : this.feedbackCount,
      lastAlertedAtUtc: data.lastAlertedAtUtc.present
          ? data.lastAlertedAtUtc.value
          : this.lastAlertedAtUtc,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoadEvent(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('eventType: $eventType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('severity: $severity, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('speedKmhAtDetection: $speedKmhAtDetection, ')
          ..write('alertCount: $alertCount, ')
          ..write('feedbackCount: $feedbackCount, ')
          ..write('lastAlertedAtUtc: $lastAlertedAtUtc, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    eventType,
    latitude,
    longitude,
    severity,
    confidence,
    source,
    detectedAtUtc,
    speedKmhAtDetection,
    alertCount,
    feedbackCount,
    lastAlertedAtUtc,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoadEvent &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.eventType == this.eventType &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.severity == this.severity &&
          other.confidence == this.confidence &&
          other.source == this.source &&
          other.detectedAtUtc == this.detectedAtUtc &&
          other.speedKmhAtDetection == this.speedKmhAtDetection &&
          other.alertCount == this.alertCount &&
          other.feedbackCount == this.feedbackCount &&
          other.lastAlertedAtUtc == this.lastAlertedAtUtc &&
          other.note == this.note);
}

class RoadEventsCompanion extends UpdateCompanion<RoadEvent> {
  final Value<int> id;
  final Value<int?> tripId;
  final Value<String> eventType;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> severity;
  final Value<double?> confidence;
  final Value<String> source;
  final Value<DateTime> detectedAtUtc;
  final Value<double?> speedKmhAtDetection;
  final Value<int> alertCount;
  final Value<int> feedbackCount;
  final Value<DateTime?> lastAlertedAtUtc;
  final Value<String?> note;
  const RoadEventsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.severity = const Value.absent(),
    this.confidence = const Value.absent(),
    this.source = const Value.absent(),
    this.detectedAtUtc = const Value.absent(),
    this.speedKmhAtDetection = const Value.absent(),
    this.alertCount = const Value.absent(),
    this.feedbackCount = const Value.absent(),
    this.lastAlertedAtUtc = const Value.absent(),
    this.note = const Value.absent(),
  });
  RoadEventsCompanion.insert({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    required String eventType,
    required double latitude,
    required double longitude,
    this.severity = const Value.absent(),
    this.confidence = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime detectedAtUtc,
    this.speedKmhAtDetection = const Value.absent(),
    this.alertCount = const Value.absent(),
    this.feedbackCount = const Value.absent(),
    this.lastAlertedAtUtc = const Value.absent(),
    this.note = const Value.absent(),
  }) : eventType = Value(eventType),
       latitude = Value(latitude),
       longitude = Value(longitude),
       detectedAtUtc = Value(detectedAtUtc);
  static Insertable<RoadEvent> custom({
    Expression<int>? id,
    Expression<int>? tripId,
    Expression<String>? eventType,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? severity,
    Expression<double>? confidence,
    Expression<String>? source,
    Expression<DateTime>? detectedAtUtc,
    Expression<double>? speedKmhAtDetection,
    Expression<int>? alertCount,
    Expression<int>? feedbackCount,
    Expression<DateTime>? lastAlertedAtUtc,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (eventType != null) 'event_type': eventType,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (severity != null) 'severity': severity,
      if (confidence != null) 'confidence': confidence,
      if (source != null) 'source': source,
      if (detectedAtUtc != null) 'detected_at_utc': detectedAtUtc,
      if (speedKmhAtDetection != null)
        'speed_kmh_at_detection': speedKmhAtDetection,
      if (alertCount != null) 'alert_count': alertCount,
      if (feedbackCount != null) 'feedback_count': feedbackCount,
      if (lastAlertedAtUtc != null) 'last_alerted_at_utc': lastAlertedAtUtc,
      if (note != null) 'note': note,
    });
  }

  RoadEventsCompanion copyWith({
    Value<int>? id,
    Value<int?>? tripId,
    Value<String>? eventType,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? severity,
    Value<double?>? confidence,
    Value<String>? source,
    Value<DateTime>? detectedAtUtc,
    Value<double?>? speedKmhAtDetection,
    Value<int>? alertCount,
    Value<int>? feedbackCount,
    Value<DateTime?>? lastAlertedAtUtc,
    Value<String?>? note,
  }) {
    return RoadEventsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      eventType: eventType ?? this.eventType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
      speedKmhAtDetection: speedKmhAtDetection ?? this.speedKmhAtDetection,
      alertCount: alertCount ?? this.alertCount,
      feedbackCount: feedbackCount ?? this.feedbackCount,
      lastAlertedAtUtc: lastAlertedAtUtc ?? this.lastAlertedAtUtc,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (severity.present) {
      map['severity'] = Variable<double>(severity.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (detectedAtUtc.present) {
      map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc.value);
    }
    if (speedKmhAtDetection.present) {
      map['speed_kmh_at_detection'] = Variable<double>(
        speedKmhAtDetection.value,
      );
    }
    if (alertCount.present) {
      map['alert_count'] = Variable<int>(alertCount.value);
    }
    if (feedbackCount.present) {
      map['feedback_count'] = Variable<int>(feedbackCount.value);
    }
    if (lastAlertedAtUtc.present) {
      map['last_alerted_at_utc'] = Variable<DateTime>(lastAlertedAtUtc.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoadEventsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('eventType: $eventType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('severity: $severity, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('speedKmhAtDetection: $speedKmhAtDetection, ')
          ..write('alertCount: $alertCount, ')
          ..write('feedbackCount: $feedbackCount, ')
          ..write('lastAlertedAtUtc: $lastAlertedAtUtc, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PreAlertsTable extends PreAlerts
    with TableInfo<$PreAlertsTable, PreAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _roadEventIdMeta = const VerificationMeta(
    'roadEventId',
  );
  @override
  late final GeneratedColumn<int> roadEventId = GeneratedColumn<int>(
    'road_event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedKmhMeta = const VerificationMeta(
    'speedKmh',
  );
  @override
  late final GeneratedColumn<double> speedKmh = GeneratedColumn<double>(
    'speed_kmh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeToEventSecondsMeta =
      const VerificationMeta('timeToEventSeconds');
  @override
  late final GeneratedColumn<double> timeToEventSeconds =
      GeneratedColumn<double>(
        'time_to_event_seconds',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recommendedSpeedKmhMeta =
      const VerificationMeta('recommendedSpeedKmh');
  @override
  late final GeneratedColumn<double> recommendedSpeedKmh =
      GeneratedColumn<double>(
        'recommended_speed_kmh',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _urgencyMeta = const VerificationMeta(
    'urgency',
  );
  @override
  late final GeneratedColumn<String> urgency = GeneratedColumn<String>(
    'urgency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spokenTextMeta = const VerificationMeta(
    'spokenText',
  );
  @override
  late final GeneratedColumn<String> spokenText = GeneratedColumn<String>(
    'spoken_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertedAtUtcMeta = const VerificationMeta(
    'alertedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> alertedAtUtc = GeneratedColumn<DateTime>(
    'alerted_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryStatusMeta = const VerificationMeta(
    'deliveryStatus',
  );
  @override
  late final GeneratedColumn<String> deliveryStatus = GeneratedColumn<String>(
    'delivery_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _deliveredAtUtcMeta = const VerificationMeta(
    'deliveredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> deliveredAtUtc =
      GeneratedColumn<DateTime>(
        'delivered_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deliveryFailureMeta = const VerificationMeta(
    'deliveryFailure',
  );
  @override
  late final GeneratedColumn<String> deliveryFailure = GeneratedColumn<String>(
    'delivery_failure',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acknowledgedMeta = const VerificationMeta(
    'acknowledged',
  );
  @override
  late final GeneratedColumn<bool> acknowledged = GeneratedColumn<bool>(
    'acknowledged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("acknowledged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roadEventId,
    tripId,
    eventId,
    eventType,
    latitude,
    longitude,
    distanceMeters,
    speedKmh,
    timeToEventSeconds,
    recommendedSpeedKmh,
    urgency,
    spokenText,
    alertedAtUtc,
    deliveryStatus,
    deliveredAtUtc,
    deliveryFailure,
    acknowledged,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pre_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreAlert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('road_event_id')) {
      context.handle(
        _roadEventIdMeta,
        roadEventId.isAcceptableOrUnknown(
          data['road_event_id']!,
          _roadEventIdMeta,
        ),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('speed_kmh')) {
      context.handle(
        _speedKmhMeta,
        speedKmh.isAcceptableOrUnknown(data['speed_kmh']!, _speedKmhMeta),
      );
    } else if (isInserting) {
      context.missing(_speedKmhMeta);
    }
    if (data.containsKey('time_to_event_seconds')) {
      context.handle(
        _timeToEventSecondsMeta,
        timeToEventSeconds.isAcceptableOrUnknown(
          data['time_to_event_seconds']!,
          _timeToEventSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeToEventSecondsMeta);
    }
    if (data.containsKey('recommended_speed_kmh')) {
      context.handle(
        _recommendedSpeedKmhMeta,
        recommendedSpeedKmh.isAcceptableOrUnknown(
          data['recommended_speed_kmh']!,
          _recommendedSpeedKmhMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedSpeedKmhMeta);
    }
    if (data.containsKey('urgency')) {
      context.handle(
        _urgencyMeta,
        urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta),
      );
    } else if (isInserting) {
      context.missing(_urgencyMeta);
    }
    if (data.containsKey('spoken_text')) {
      context.handle(
        _spokenTextMeta,
        spokenText.isAcceptableOrUnknown(data['spoken_text']!, _spokenTextMeta),
      );
    } else if (isInserting) {
      context.missing(_spokenTextMeta);
    }
    if (data.containsKey('alerted_at_utc')) {
      context.handle(
        _alertedAtUtcMeta,
        alertedAtUtc.isAcceptableOrUnknown(
          data['alerted_at_utc']!,
          _alertedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_alertedAtUtcMeta);
    }
    if (data.containsKey('delivery_status')) {
      context.handle(
        _deliveryStatusMeta,
        deliveryStatus.isAcceptableOrUnknown(
          data['delivery_status']!,
          _deliveryStatusMeta,
        ),
      );
    }
    if (data.containsKey('delivered_at_utc')) {
      context.handle(
        _deliveredAtUtcMeta,
        deliveredAtUtc.isAcceptableOrUnknown(
          data['delivered_at_utc']!,
          _deliveredAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('delivery_failure')) {
      context.handle(
        _deliveryFailureMeta,
        deliveryFailure.isAcceptableOrUnknown(
          data['delivery_failure']!,
          _deliveryFailureMeta,
        ),
      );
    }
    if (data.containsKey('acknowledged')) {
      context.handle(
        _acknowledgedMeta,
        acknowledged.isAcceptableOrUnknown(
          data['acknowledged']!,
          _acknowledgedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreAlert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      roadEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}road_event_id'],
      ),
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      ),
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      speedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_kmh'],
      )!,
      timeToEventSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}time_to_event_seconds'],
      )!,
      recommendedSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recommended_speed_kmh'],
      )!,
      urgency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urgency'],
      )!,
      spokenText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spoken_text'],
      )!,
      alertedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}alerted_at_utc'],
      )!,
      deliveryStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_status'],
      )!,
      deliveredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivered_at_utc'],
      ),
      deliveryFailure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_failure'],
      ),
      acknowledged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}acknowledged'],
      )!,
    );
  }

  @override
  $PreAlertsTable createAlias(String alias) {
    return $PreAlertsTable(attachedDatabase, alias);
  }
}

class PreAlert extends DataClass implements Insertable<PreAlert> {
  final int id;

  /// The geo-tagged hazard that triggered the warning.
  final int? roadEventId;
  final int? tripId;

  /// The labeled event that this pre-alert was associated with, once known.
  final int? eventId;
  final String eventType;
  final double latitude;
  final double longitude;

  /// Straight-line distance from the rider to the hazard at alert time.
  final double distanceMeters;

  /// Ground speed at alert time.
  final double speedKmh;

  /// distance / speed — the number of seconds the rider had to react.
  final double timeToEventSeconds;

  /// Speed the rider should be at (km/h) to clear the hazard safely.
  final double recommendedSpeedKmh;

  /// imminent | warning | advisory
  final String urgency;

  /// The exact text that was spoken by the TTS engine.
  final String spokenText;
  final DateTime alertedAtUtc;

  /// Delivery state is distinct from a queued/scheduled warning.
  final String deliveryStatus;
  final DateTime? deliveredAtUtc;
  final String? deliveryFailure;

  /// Set once the rider passed the hazard (used for timing evaluation).
  final bool acknowledged;
  const PreAlert({
    required this.id,
    this.roadEventId,
    this.tripId,
    this.eventId,
    required this.eventType,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.speedKmh,
    required this.timeToEventSeconds,
    required this.recommendedSpeedKmh,
    required this.urgency,
    required this.spokenText,
    required this.alertedAtUtc,
    required this.deliveryStatus,
    this.deliveredAtUtc,
    this.deliveryFailure,
    required this.acknowledged,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || roadEventId != null) {
      map['road_event_id'] = Variable<int>(roadEventId);
    }
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<int>(eventId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['speed_kmh'] = Variable<double>(speedKmh);
    map['time_to_event_seconds'] = Variable<double>(timeToEventSeconds);
    map['recommended_speed_kmh'] = Variable<double>(recommendedSpeedKmh);
    map['urgency'] = Variable<String>(urgency);
    map['spoken_text'] = Variable<String>(spokenText);
    map['alerted_at_utc'] = Variable<DateTime>(alertedAtUtc);
    map['delivery_status'] = Variable<String>(deliveryStatus);
    if (!nullToAbsent || deliveredAtUtc != null) {
      map['delivered_at_utc'] = Variable<DateTime>(deliveredAtUtc);
    }
    if (!nullToAbsent || deliveryFailure != null) {
      map['delivery_failure'] = Variable<String>(deliveryFailure);
    }
    map['acknowledged'] = Variable<bool>(acknowledged);
    return map;
  }

  PreAlertsCompanion toCompanion(bool nullToAbsent) {
    return PreAlertsCompanion(
      id: Value(id),
      roadEventId: roadEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(roadEventId),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      eventType: Value(eventType),
      latitude: Value(latitude),
      longitude: Value(longitude),
      distanceMeters: Value(distanceMeters),
      speedKmh: Value(speedKmh),
      timeToEventSeconds: Value(timeToEventSeconds),
      recommendedSpeedKmh: Value(recommendedSpeedKmh),
      urgency: Value(urgency),
      spokenText: Value(spokenText),
      alertedAtUtc: Value(alertedAtUtc),
      deliveryStatus: Value(deliveryStatus),
      deliveredAtUtc: deliveredAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAtUtc),
      deliveryFailure: deliveryFailure == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryFailure),
      acknowledged: Value(acknowledged),
    );
  }

  factory PreAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreAlert(
      id: serializer.fromJson<int>(json['id']),
      roadEventId: serializer.fromJson<int?>(json['roadEventId']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      eventId: serializer.fromJson<int?>(json['eventId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      speedKmh: serializer.fromJson<double>(json['speedKmh']),
      timeToEventSeconds: serializer.fromJson<double>(
        json['timeToEventSeconds'],
      ),
      recommendedSpeedKmh: serializer.fromJson<double>(
        json['recommendedSpeedKmh'],
      ),
      urgency: serializer.fromJson<String>(json['urgency']),
      spokenText: serializer.fromJson<String>(json['spokenText']),
      alertedAtUtc: serializer.fromJson<DateTime>(json['alertedAtUtc']),
      deliveryStatus: serializer.fromJson<String>(json['deliveryStatus']),
      deliveredAtUtc: serializer.fromJson<DateTime?>(json['deliveredAtUtc']),
      deliveryFailure: serializer.fromJson<String?>(json['deliveryFailure']),
      acknowledged: serializer.fromJson<bool>(json['acknowledged']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roadEventId': serializer.toJson<int?>(roadEventId),
      'tripId': serializer.toJson<int?>(tripId),
      'eventId': serializer.toJson<int?>(eventId),
      'eventType': serializer.toJson<String>(eventType),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'speedKmh': serializer.toJson<double>(speedKmh),
      'timeToEventSeconds': serializer.toJson<double>(timeToEventSeconds),
      'recommendedSpeedKmh': serializer.toJson<double>(recommendedSpeedKmh),
      'urgency': serializer.toJson<String>(urgency),
      'spokenText': serializer.toJson<String>(spokenText),
      'alertedAtUtc': serializer.toJson<DateTime>(alertedAtUtc),
      'deliveryStatus': serializer.toJson<String>(deliveryStatus),
      'deliveredAtUtc': serializer.toJson<DateTime?>(deliveredAtUtc),
      'deliveryFailure': serializer.toJson<String?>(deliveryFailure),
      'acknowledged': serializer.toJson<bool>(acknowledged),
    };
  }

  PreAlert copyWith({
    int? id,
    Value<int?> roadEventId = const Value.absent(),
    Value<int?> tripId = const Value.absent(),
    Value<int?> eventId = const Value.absent(),
    String? eventType,
    double? latitude,
    double? longitude,
    double? distanceMeters,
    double? speedKmh,
    double? timeToEventSeconds,
    double? recommendedSpeedKmh,
    String? urgency,
    String? spokenText,
    DateTime? alertedAtUtc,
    String? deliveryStatus,
    Value<DateTime?> deliveredAtUtc = const Value.absent(),
    Value<String?> deliveryFailure = const Value.absent(),
    bool? acknowledged,
  }) => PreAlert(
    id: id ?? this.id,
    roadEventId: roadEventId.present ? roadEventId.value : this.roadEventId,
    tripId: tripId.present ? tripId.value : this.tripId,
    eventId: eventId.present ? eventId.value : this.eventId,
    eventType: eventType ?? this.eventType,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    speedKmh: speedKmh ?? this.speedKmh,
    timeToEventSeconds: timeToEventSeconds ?? this.timeToEventSeconds,
    recommendedSpeedKmh: recommendedSpeedKmh ?? this.recommendedSpeedKmh,
    urgency: urgency ?? this.urgency,
    spokenText: spokenText ?? this.spokenText,
    alertedAtUtc: alertedAtUtc ?? this.alertedAtUtc,
    deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    deliveredAtUtc: deliveredAtUtc.present
        ? deliveredAtUtc.value
        : this.deliveredAtUtc,
    deliveryFailure: deliveryFailure.present
        ? deliveryFailure.value
        : this.deliveryFailure,
    acknowledged: acknowledged ?? this.acknowledged,
  );
  PreAlert copyWithCompanion(PreAlertsCompanion data) {
    return PreAlert(
      id: data.id.present ? data.id.value : this.id,
      roadEventId: data.roadEventId.present
          ? data.roadEventId.value
          : this.roadEventId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      speedKmh: data.speedKmh.present ? data.speedKmh.value : this.speedKmh,
      timeToEventSeconds: data.timeToEventSeconds.present
          ? data.timeToEventSeconds.value
          : this.timeToEventSeconds,
      recommendedSpeedKmh: data.recommendedSpeedKmh.present
          ? data.recommendedSpeedKmh.value
          : this.recommendedSpeedKmh,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      spokenText: data.spokenText.present
          ? data.spokenText.value
          : this.spokenText,
      alertedAtUtc: data.alertedAtUtc.present
          ? data.alertedAtUtc.value
          : this.alertedAtUtc,
      deliveryStatus: data.deliveryStatus.present
          ? data.deliveryStatus.value
          : this.deliveryStatus,
      deliveredAtUtc: data.deliveredAtUtc.present
          ? data.deliveredAtUtc.value
          : this.deliveredAtUtc,
      deliveryFailure: data.deliveryFailure.present
          ? data.deliveryFailure.value
          : this.deliveryFailure,
      acknowledged: data.acknowledged.present
          ? data.acknowledged.value
          : this.acknowledged,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreAlert(')
          ..write('id: $id, ')
          ..write('roadEventId: $roadEventId, ')
          ..write('tripId: $tripId, ')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('timeToEventSeconds: $timeToEventSeconds, ')
          ..write('recommendedSpeedKmh: $recommendedSpeedKmh, ')
          ..write('urgency: $urgency, ')
          ..write('spokenText: $spokenText, ')
          ..write('alertedAtUtc: $alertedAtUtc, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('deliveredAtUtc: $deliveredAtUtc, ')
          ..write('deliveryFailure: $deliveryFailure, ')
          ..write('acknowledged: $acknowledged')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roadEventId,
    tripId,
    eventId,
    eventType,
    latitude,
    longitude,
    distanceMeters,
    speedKmh,
    timeToEventSeconds,
    recommendedSpeedKmh,
    urgency,
    spokenText,
    alertedAtUtc,
    deliveryStatus,
    deliveredAtUtc,
    deliveryFailure,
    acknowledged,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreAlert &&
          other.id == this.id &&
          other.roadEventId == this.roadEventId &&
          other.tripId == this.tripId &&
          other.eventId == this.eventId &&
          other.eventType == this.eventType &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.distanceMeters == this.distanceMeters &&
          other.speedKmh == this.speedKmh &&
          other.timeToEventSeconds == this.timeToEventSeconds &&
          other.recommendedSpeedKmh == this.recommendedSpeedKmh &&
          other.urgency == this.urgency &&
          other.spokenText == this.spokenText &&
          other.alertedAtUtc == this.alertedAtUtc &&
          other.deliveryStatus == this.deliveryStatus &&
          other.deliveredAtUtc == this.deliveredAtUtc &&
          other.deliveryFailure == this.deliveryFailure &&
          other.acknowledged == this.acknowledged);
}

class PreAlertsCompanion extends UpdateCompanion<PreAlert> {
  final Value<int> id;
  final Value<int?> roadEventId;
  final Value<int?> tripId;
  final Value<int?> eventId;
  final Value<String> eventType;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> distanceMeters;
  final Value<double> speedKmh;
  final Value<double> timeToEventSeconds;
  final Value<double> recommendedSpeedKmh;
  final Value<String> urgency;
  final Value<String> spokenText;
  final Value<DateTime> alertedAtUtc;
  final Value<String> deliveryStatus;
  final Value<DateTime?> deliveredAtUtc;
  final Value<String?> deliveryFailure;
  final Value<bool> acknowledged;
  const PreAlertsCompanion({
    this.id = const Value.absent(),
    this.roadEventId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.timeToEventSeconds = const Value.absent(),
    this.recommendedSpeedKmh = const Value.absent(),
    this.urgency = const Value.absent(),
    this.spokenText = const Value.absent(),
    this.alertedAtUtc = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    this.deliveredAtUtc = const Value.absent(),
    this.deliveryFailure = const Value.absent(),
    this.acknowledged = const Value.absent(),
  });
  PreAlertsCompanion.insert({
    this.id = const Value.absent(),
    this.roadEventId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.eventId = const Value.absent(),
    required String eventType,
    required double latitude,
    required double longitude,
    required double distanceMeters,
    required double speedKmh,
    required double timeToEventSeconds,
    required double recommendedSpeedKmh,
    required String urgency,
    required String spokenText,
    required DateTime alertedAtUtc,
    this.deliveryStatus = const Value.absent(),
    this.deliveredAtUtc = const Value.absent(),
    this.deliveryFailure = const Value.absent(),
    this.acknowledged = const Value.absent(),
  }) : eventType = Value(eventType),
       latitude = Value(latitude),
       longitude = Value(longitude),
       distanceMeters = Value(distanceMeters),
       speedKmh = Value(speedKmh),
       timeToEventSeconds = Value(timeToEventSeconds),
       recommendedSpeedKmh = Value(recommendedSpeedKmh),
       urgency = Value(urgency),
       spokenText = Value(spokenText),
       alertedAtUtc = Value(alertedAtUtc);
  static Insertable<PreAlert> custom({
    Expression<int>? id,
    Expression<int>? roadEventId,
    Expression<int>? tripId,
    Expression<int>? eventId,
    Expression<String>? eventType,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? distanceMeters,
    Expression<double>? speedKmh,
    Expression<double>? timeToEventSeconds,
    Expression<double>? recommendedSpeedKmh,
    Expression<String>? urgency,
    Expression<String>? spokenText,
    Expression<DateTime>? alertedAtUtc,
    Expression<String>? deliveryStatus,
    Expression<DateTime>? deliveredAtUtc,
    Expression<String>? deliveryFailure,
    Expression<bool>? acknowledged,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roadEventId != null) 'road_event_id': roadEventId,
      if (tripId != null) 'trip_id': tripId,
      if (eventId != null) 'event_id': eventId,
      if (eventType != null) 'event_type': eventType,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (speedKmh != null) 'speed_kmh': speedKmh,
      if (timeToEventSeconds != null)
        'time_to_event_seconds': timeToEventSeconds,
      if (recommendedSpeedKmh != null)
        'recommended_speed_kmh': recommendedSpeedKmh,
      if (urgency != null) 'urgency': urgency,
      if (spokenText != null) 'spoken_text': spokenText,
      if (alertedAtUtc != null) 'alerted_at_utc': alertedAtUtc,
      if (deliveryStatus != null) 'delivery_status': deliveryStatus,
      if (deliveredAtUtc != null) 'delivered_at_utc': deliveredAtUtc,
      if (deliveryFailure != null) 'delivery_failure': deliveryFailure,
      if (acknowledged != null) 'acknowledged': acknowledged,
    });
  }

  PreAlertsCompanion copyWith({
    Value<int>? id,
    Value<int?>? roadEventId,
    Value<int?>? tripId,
    Value<int?>? eventId,
    Value<String>? eventType,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? distanceMeters,
    Value<double>? speedKmh,
    Value<double>? timeToEventSeconds,
    Value<double>? recommendedSpeedKmh,
    Value<String>? urgency,
    Value<String>? spokenText,
    Value<DateTime>? alertedAtUtc,
    Value<String>? deliveryStatus,
    Value<DateTime?>? deliveredAtUtc,
    Value<String?>? deliveryFailure,
    Value<bool>? acknowledged,
  }) {
    return PreAlertsCompanion(
      id: id ?? this.id,
      roadEventId: roadEventId ?? this.roadEventId,
      tripId: tripId ?? this.tripId,
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      speedKmh: speedKmh ?? this.speedKmh,
      timeToEventSeconds: timeToEventSeconds ?? this.timeToEventSeconds,
      recommendedSpeedKmh: recommendedSpeedKmh ?? this.recommendedSpeedKmh,
      urgency: urgency ?? this.urgency,
      spokenText: spokenText ?? this.spokenText,
      alertedAtUtc: alertedAtUtc ?? this.alertedAtUtc,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveredAtUtc: deliveredAtUtc ?? this.deliveredAtUtc,
      deliveryFailure: deliveryFailure ?? this.deliveryFailure,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roadEventId.present) {
      map['road_event_id'] = Variable<int>(roadEventId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (speedKmh.present) {
      map['speed_kmh'] = Variable<double>(speedKmh.value);
    }
    if (timeToEventSeconds.present) {
      map['time_to_event_seconds'] = Variable<double>(timeToEventSeconds.value);
    }
    if (recommendedSpeedKmh.present) {
      map['recommended_speed_kmh'] = Variable<double>(
        recommendedSpeedKmh.value,
      );
    }
    if (urgency.present) {
      map['urgency'] = Variable<String>(urgency.value);
    }
    if (spokenText.present) {
      map['spoken_text'] = Variable<String>(spokenText.value);
    }
    if (alertedAtUtc.present) {
      map['alerted_at_utc'] = Variable<DateTime>(alertedAtUtc.value);
    }
    if (deliveryStatus.present) {
      map['delivery_status'] = Variable<String>(deliveryStatus.value);
    }
    if (deliveredAtUtc.present) {
      map['delivered_at_utc'] = Variable<DateTime>(deliveredAtUtc.value);
    }
    if (deliveryFailure.present) {
      map['delivery_failure'] = Variable<String>(deliveryFailure.value);
    }
    if (acknowledged.present) {
      map['acknowledged'] = Variable<bool>(acknowledged.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreAlertsCompanion(')
          ..write('id: $id, ')
          ..write('roadEventId: $roadEventId, ')
          ..write('tripId: $tripId, ')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('timeToEventSeconds: $timeToEventSeconds, ')
          ..write('recommendedSpeedKmh: $recommendedSpeedKmh, ')
          ..write('urgency: $urgency, ')
          ..write('spokenText: $spokenText, ')
          ..write('alertedAtUtc: $alertedAtUtc, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('deliveredAtUtc: $deliveredAtUtc, ')
          ..write('deliveryFailure: $deliveryFailure, ')
          ..write('acknowledged: $acknowledged')
          ..write(')'))
        .toString();
  }
}

class $EventFeedbacksTable extends EventFeedbacks
    with TableInfo<$EventFeedbacksTable, EventFeedback> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventFeedbacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roadEventIdMeta = const VerificationMeta(
    'roadEventId',
  );
  @override
  late final GeneratedColumn<int> roadEventId = GeneratedColumn<int>(
    'road_event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preAlertIdMeta = const VerificationMeta(
    'preAlertId',
  );
  @override
  late final GeneratedColumn<int> preAlertId = GeneratedColumn<int>(
    'pre_alert_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseTextMeta = const VerificationMeta(
    'responseText',
  );
  @override
  late final GeneratedColumn<String> responseText = GeneratedColumn<String>(
    'response_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseSourceMeta = const VerificationMeta(
    'responseSource',
  );
  @override
  late final GeneratedColumn<String> responseSource = GeneratedColumn<String>(
    'response_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptConfidenceMeta =
      const VerificationMeta('transcriptConfidence');
  @override
  late final GeneratedColumn<double> transcriptConfidence =
      GeneratedColumn<double>(
        'transcript_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _llmAnalysisMeta = const VerificationMeta(
    'llmAnalysis',
  );
  @override
  late final GeneratedColumn<String> llmAnalysis = GeneratedColumn<String>(
    'llm_analysis',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alertEffectivenessMeta =
      const VerificationMeta('alertEffectiveness');
  @override
  late final GeneratedColumn<double> alertEffectiveness =
      GeneratedColumn<double>(
        'alert_effectiveness',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _alertTimingAdequacyMeta =
      const VerificationMeta('alertTimingAdequacy');
  @override
  late final GeneratedColumn<String> alertTimingAdequacy =
      GeneratedColumn<String>(
        'alert_timing_adequacy',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _difficultyLevelMeta = const VerificationMeta(
    'difficultyLevel',
  );
  @override
  late final GeneratedColumn<String> difficultyLevel = GeneratedColumn<String>(
    'difficulty_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _riderSummaryMeta = const VerificationMeta(
    'riderSummary',
  );
  @override
  late final GeneratedColumn<String> riderSummary = GeneratedColumn<String>(
    'rider_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _improvementSuggestionMeta =
      const VerificationMeta('improvementSuggestion');
  @override
  late final GeneratedColumn<String> improvementSuggestion =
      GeneratedColumn<String>(
        'improvement_suggestion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _audioFilePathMeta = const VerificationMeta(
    'audioFilePath',
  );
  @override
  late final GeneratedColumn<String> audioFilePath = GeneratedColumn<String>(
    'audio_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _analysisConfidenceMeta =
      const VerificationMeta('analysisConfidence');
  @override
  late final GeneratedColumn<double> analysisConfidence =
      GeneratedColumn<double>(
        'analysis_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _analyzedByLlmMeta = const VerificationMeta(
    'analyzedByLlm',
  );
  @override
  late final GeneratedColumn<bool> analyzedByLlm = GeneratedColumn<bool>(
    'analyzed_by_llm',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("analyzed_by_llm" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analyzedAtUtcMeta = const VerificationMeta(
    'analyzedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> analyzedAtUtc =
      GeneratedColumn<DateTime>(
        'analyzed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    tripId,
    roadEventId,
    preAlertId,
    eventType,
    prompt,
    responseText,
    responseSource,
    transcriptConfidence,
    llmAnalysis,
    alertEffectiveness,
    alertTimingAdequacy,
    difficultyLevel,
    riderSummary,
    improvementSuggestion,
    audioFilePath,
    analysisConfidence,
    analyzedByLlm,
    createdAtUtc,
    analyzedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_feedbacks';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventFeedback> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    if (data.containsKey('road_event_id')) {
      context.handle(
        _roadEventIdMeta,
        roadEventId.isAcceptableOrUnknown(
          data['road_event_id']!,
          _roadEventIdMeta,
        ),
      );
    }
    if (data.containsKey('pre_alert_id')) {
      context.handle(
        _preAlertIdMeta,
        preAlertId.isAcceptableOrUnknown(
          data['pre_alert_id']!,
          _preAlertIdMeta,
        ),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('response_text')) {
      context.handle(
        _responseTextMeta,
        responseText.isAcceptableOrUnknown(
          data['response_text']!,
          _responseTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseTextMeta);
    }
    if (data.containsKey('response_source')) {
      context.handle(
        _responseSourceMeta,
        responseSource.isAcceptableOrUnknown(
          data['response_source']!,
          _responseSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseSourceMeta);
    }
    if (data.containsKey('transcript_confidence')) {
      context.handle(
        _transcriptConfidenceMeta,
        transcriptConfidence.isAcceptableOrUnknown(
          data['transcript_confidence']!,
          _transcriptConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('llm_analysis')) {
      context.handle(
        _llmAnalysisMeta,
        llmAnalysis.isAcceptableOrUnknown(
          data['llm_analysis']!,
          _llmAnalysisMeta,
        ),
      );
    }
    if (data.containsKey('alert_effectiveness')) {
      context.handle(
        _alertEffectivenessMeta,
        alertEffectiveness.isAcceptableOrUnknown(
          data['alert_effectiveness']!,
          _alertEffectivenessMeta,
        ),
      );
    }
    if (data.containsKey('alert_timing_adequacy')) {
      context.handle(
        _alertTimingAdequacyMeta,
        alertTimingAdequacy.isAcceptableOrUnknown(
          data['alert_timing_adequacy']!,
          _alertTimingAdequacyMeta,
        ),
      );
    }
    if (data.containsKey('difficulty_level')) {
      context.handle(
        _difficultyLevelMeta,
        difficultyLevel.isAcceptableOrUnknown(
          data['difficulty_level']!,
          _difficultyLevelMeta,
        ),
      );
    }
    if (data.containsKey('rider_summary')) {
      context.handle(
        _riderSummaryMeta,
        riderSummary.isAcceptableOrUnknown(
          data['rider_summary']!,
          _riderSummaryMeta,
        ),
      );
    }
    if (data.containsKey('improvement_suggestion')) {
      context.handle(
        _improvementSuggestionMeta,
        improvementSuggestion.isAcceptableOrUnknown(
          data['improvement_suggestion']!,
          _improvementSuggestionMeta,
        ),
      );
    }
    if (data.containsKey('audio_file_path')) {
      context.handle(
        _audioFilePathMeta,
        audioFilePath.isAcceptableOrUnknown(
          data['audio_file_path']!,
          _audioFilePathMeta,
        ),
      );
    }
    if (data.containsKey('analysis_confidence')) {
      context.handle(
        _analysisConfidenceMeta,
        analysisConfidence.isAcceptableOrUnknown(
          data['analysis_confidence']!,
          _analysisConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('analyzed_by_llm')) {
      context.handle(
        _analyzedByLlmMeta,
        analyzedByLlm.isAcceptableOrUnknown(
          data['analyzed_by_llm']!,
          _analyzedByLlmMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('analyzed_at_utc')) {
      context.handle(
        _analyzedAtUtcMeta,
        analyzedAtUtc.isAcceptableOrUnknown(
          data['analyzed_at_utc']!,
          _analyzedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventFeedback map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventFeedback(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      ),
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      ),
      roadEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}road_event_id'],
      ),
      preAlertId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pre_alert_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      responseText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_text'],
      )!,
      responseSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_source'],
      )!,
      transcriptConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}transcript_confidence'],
      ),
      llmAnalysis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}llm_analysis'],
      ),
      alertEffectiveness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alert_effectiveness'],
      ),
      alertTimingAdequacy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_timing_adequacy'],
      ),
      difficultyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty_level'],
      ),
      riderSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rider_summary'],
      ),
      improvementSuggestion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}improvement_suggestion'],
      ),
      audioFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_file_path'],
      ),
      analysisConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}analysis_confidence'],
      ),
      analyzedByLlm: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}analyzed_by_llm'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      analyzedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}analyzed_at_utc'],
      ),
    );
  }

  @override
  $EventFeedbacksTable createAlias(String alias) {
    return $EventFeedbacksTable(attachedDatabase, alias);
  }
}

class EventFeedback extends DataClass implements Insertable<EventFeedback> {
  final int id;

  /// The labeled event this feedback belongs to.
  final int? eventId;
  final int? tripId;

  /// The geo-tagged hazard the rider was reacting to.
  final int? roadEventId;

  /// The pre-alert that was spoken before the event, if any.
  final int? preAlertId;
  final String eventType;

  /// The question that was asked of the rider.
  final String prompt;

  /// The rider's answer (transcribed speech or typed text).
  final String responseText;

  /// voice | text | skipped
  final String responseSource;

  /// Speech-to-text confidence (0..1) when the answer was spoken.
  final double? transcriptConfidence;

  /// Full JSON payload of the LLM analysis.
  final String? llmAnalysis;

  /// LLM-scored effectiveness of the pre-alert (0..1).
  final double? alertEffectiveness;

  /// too_early | adequate | too_late | unknown
  final String? alertTimingAdequacy;

  /// none | mild | moderate | severe | unknown
  final String? difficultyLevel;

  /// One-line natural-language summary of the rider's experience.
  final String? riderSummary;

  /// Actionable recommendation for improving alert timing / accuracy.
  final String? improvementSuggestion;

  /// Local filesystem path to the recorded 5-second audio clip (.mp4/.m4a).
  final String? audioFilePath;
  final double? analysisConfidence;

  /// False when the heuristic (offline) analyzer was used instead of the LLM.
  final bool analyzedByLlm;
  final DateTime createdAtUtc;
  final DateTime? analyzedAtUtc;
  const EventFeedback({
    required this.id,
    this.eventId,
    this.tripId,
    this.roadEventId,
    this.preAlertId,
    required this.eventType,
    required this.prompt,
    required this.responseText,
    required this.responseSource,
    this.transcriptConfidence,
    this.llmAnalysis,
    this.alertEffectiveness,
    this.alertTimingAdequacy,
    this.difficultyLevel,
    this.riderSummary,
    this.improvementSuggestion,
    this.audioFilePath,
    this.analysisConfidence,
    required this.analyzedByLlm,
    required this.createdAtUtc,
    this.analyzedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<int>(eventId);
    }
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    if (!nullToAbsent || roadEventId != null) {
      map['road_event_id'] = Variable<int>(roadEventId);
    }
    if (!nullToAbsent || preAlertId != null) {
      map['pre_alert_id'] = Variable<int>(preAlertId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['prompt'] = Variable<String>(prompt);
    map['response_text'] = Variable<String>(responseText);
    map['response_source'] = Variable<String>(responseSource);
    if (!nullToAbsent || transcriptConfidence != null) {
      map['transcript_confidence'] = Variable<double>(transcriptConfidence);
    }
    if (!nullToAbsent || llmAnalysis != null) {
      map['llm_analysis'] = Variable<String>(llmAnalysis);
    }
    if (!nullToAbsent || alertEffectiveness != null) {
      map['alert_effectiveness'] = Variable<double>(alertEffectiveness);
    }
    if (!nullToAbsent || alertTimingAdequacy != null) {
      map['alert_timing_adequacy'] = Variable<String>(alertTimingAdequacy);
    }
    if (!nullToAbsent || difficultyLevel != null) {
      map['difficulty_level'] = Variable<String>(difficultyLevel);
    }
    if (!nullToAbsent || riderSummary != null) {
      map['rider_summary'] = Variable<String>(riderSummary);
    }
    if (!nullToAbsent || improvementSuggestion != null) {
      map['improvement_suggestion'] = Variable<String>(improvementSuggestion);
    }
    if (!nullToAbsent || audioFilePath != null) {
      map['audio_file_path'] = Variable<String>(audioFilePath);
    }
    if (!nullToAbsent || analysisConfidence != null) {
      map['analysis_confidence'] = Variable<double>(analysisConfidence);
    }
    map['analyzed_by_llm'] = Variable<bool>(analyzedByLlm);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    if (!nullToAbsent || analyzedAtUtc != null) {
      map['analyzed_at_utc'] = Variable<DateTime>(analyzedAtUtc);
    }
    return map;
  }

  EventFeedbacksCompanion toCompanion(bool nullToAbsent) {
    return EventFeedbacksCompanion(
      id: Value(id),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
      roadEventId: roadEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(roadEventId),
      preAlertId: preAlertId == null && nullToAbsent
          ? const Value.absent()
          : Value(preAlertId),
      eventType: Value(eventType),
      prompt: Value(prompt),
      responseText: Value(responseText),
      responseSource: Value(responseSource),
      transcriptConfidence: transcriptConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(transcriptConfidence),
      llmAnalysis: llmAnalysis == null && nullToAbsent
          ? const Value.absent()
          : Value(llmAnalysis),
      alertEffectiveness: alertEffectiveness == null && nullToAbsent
          ? const Value.absent()
          : Value(alertEffectiveness),
      alertTimingAdequacy: alertTimingAdequacy == null && nullToAbsent
          ? const Value.absent()
          : Value(alertTimingAdequacy),
      difficultyLevel: difficultyLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(difficultyLevel),
      riderSummary: riderSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(riderSummary),
      improvementSuggestion: improvementSuggestion == null && nullToAbsent
          ? const Value.absent()
          : Value(improvementSuggestion),
      audioFilePath: audioFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFilePath),
      analysisConfidence: analysisConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisConfidence),
      analyzedByLlm: Value(analyzedByLlm),
      createdAtUtc: Value(createdAtUtc),
      analyzedAtUtc: analyzedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(analyzedAtUtc),
    );
  }

  factory EventFeedback.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventFeedback(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<int?>(json['eventId']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      roadEventId: serializer.fromJson<int?>(json['roadEventId']),
      preAlertId: serializer.fromJson<int?>(json['preAlertId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      prompt: serializer.fromJson<String>(json['prompt']),
      responseText: serializer.fromJson<String>(json['responseText']),
      responseSource: serializer.fromJson<String>(json['responseSource']),
      transcriptConfidence: serializer.fromJson<double?>(
        json['transcriptConfidence'],
      ),
      llmAnalysis: serializer.fromJson<String?>(json['llmAnalysis']),
      alertEffectiveness: serializer.fromJson<double?>(
        json['alertEffectiveness'],
      ),
      alertTimingAdequacy: serializer.fromJson<String?>(
        json['alertTimingAdequacy'],
      ),
      difficultyLevel: serializer.fromJson<String?>(json['difficultyLevel']),
      riderSummary: serializer.fromJson<String?>(json['riderSummary']),
      improvementSuggestion: serializer.fromJson<String?>(
        json['improvementSuggestion'],
      ),
      audioFilePath: serializer.fromJson<String?>(json['audioFilePath']),
      analysisConfidence: serializer.fromJson<double?>(
        json['analysisConfidence'],
      ),
      analyzedByLlm: serializer.fromJson<bool>(json['analyzedByLlm']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      analyzedAtUtc: serializer.fromJson<DateTime?>(json['analyzedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<int?>(eventId),
      'tripId': serializer.toJson<int?>(tripId),
      'roadEventId': serializer.toJson<int?>(roadEventId),
      'preAlertId': serializer.toJson<int?>(preAlertId),
      'eventType': serializer.toJson<String>(eventType),
      'prompt': serializer.toJson<String>(prompt),
      'responseText': serializer.toJson<String>(responseText),
      'responseSource': serializer.toJson<String>(responseSource),
      'transcriptConfidence': serializer.toJson<double?>(transcriptConfidence),
      'llmAnalysis': serializer.toJson<String?>(llmAnalysis),
      'alertEffectiveness': serializer.toJson<double?>(alertEffectiveness),
      'alertTimingAdequacy': serializer.toJson<String?>(alertTimingAdequacy),
      'difficultyLevel': serializer.toJson<String?>(difficultyLevel),
      'riderSummary': serializer.toJson<String?>(riderSummary),
      'improvementSuggestion': serializer.toJson<String?>(
        improvementSuggestion,
      ),
      'audioFilePath': serializer.toJson<String?>(audioFilePath),
      'analysisConfidence': serializer.toJson<double?>(analysisConfidence),
      'analyzedByLlm': serializer.toJson<bool>(analyzedByLlm),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'analyzedAtUtc': serializer.toJson<DateTime?>(analyzedAtUtc),
    };
  }

  EventFeedback copyWith({
    int? id,
    Value<int?> eventId = const Value.absent(),
    Value<int?> tripId = const Value.absent(),
    Value<int?> roadEventId = const Value.absent(),
    Value<int?> preAlertId = const Value.absent(),
    String? eventType,
    String? prompt,
    String? responseText,
    String? responseSource,
    Value<double?> transcriptConfidence = const Value.absent(),
    Value<String?> llmAnalysis = const Value.absent(),
    Value<double?> alertEffectiveness = const Value.absent(),
    Value<String?> alertTimingAdequacy = const Value.absent(),
    Value<String?> difficultyLevel = const Value.absent(),
    Value<String?> riderSummary = const Value.absent(),
    Value<String?> improvementSuggestion = const Value.absent(),
    Value<String?> audioFilePath = const Value.absent(),
    Value<double?> analysisConfidence = const Value.absent(),
    bool? analyzedByLlm,
    DateTime? createdAtUtc,
    Value<DateTime?> analyzedAtUtc = const Value.absent(),
  }) => EventFeedback(
    id: id ?? this.id,
    eventId: eventId.present ? eventId.value : this.eventId,
    tripId: tripId.present ? tripId.value : this.tripId,
    roadEventId: roadEventId.present ? roadEventId.value : this.roadEventId,
    preAlertId: preAlertId.present ? preAlertId.value : this.preAlertId,
    eventType: eventType ?? this.eventType,
    prompt: prompt ?? this.prompt,
    responseText: responseText ?? this.responseText,
    responseSource: responseSource ?? this.responseSource,
    transcriptConfidence: transcriptConfidence.present
        ? transcriptConfidence.value
        : this.transcriptConfidence,
    llmAnalysis: llmAnalysis.present ? llmAnalysis.value : this.llmAnalysis,
    alertEffectiveness: alertEffectiveness.present
        ? alertEffectiveness.value
        : this.alertEffectiveness,
    alertTimingAdequacy: alertTimingAdequacy.present
        ? alertTimingAdequacy.value
        : this.alertTimingAdequacy,
    difficultyLevel: difficultyLevel.present
        ? difficultyLevel.value
        : this.difficultyLevel,
    riderSummary: riderSummary.present ? riderSummary.value : this.riderSummary,
    improvementSuggestion: improvementSuggestion.present
        ? improvementSuggestion.value
        : this.improvementSuggestion,
    audioFilePath: audioFilePath.present
        ? audioFilePath.value
        : this.audioFilePath,
    analysisConfidence: analysisConfidence.present
        ? analysisConfidence.value
        : this.analysisConfidence,
    analyzedByLlm: analyzedByLlm ?? this.analyzedByLlm,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    analyzedAtUtc: analyzedAtUtc.present
        ? analyzedAtUtc.value
        : this.analyzedAtUtc,
  );
  EventFeedback copyWithCompanion(EventFeedbacksCompanion data) {
    return EventFeedback(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      roadEventId: data.roadEventId.present
          ? data.roadEventId.value
          : this.roadEventId,
      preAlertId: data.preAlertId.present
          ? data.preAlertId.value
          : this.preAlertId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      responseText: data.responseText.present
          ? data.responseText.value
          : this.responseText,
      responseSource: data.responseSource.present
          ? data.responseSource.value
          : this.responseSource,
      transcriptConfidence: data.transcriptConfidence.present
          ? data.transcriptConfidence.value
          : this.transcriptConfidence,
      llmAnalysis: data.llmAnalysis.present
          ? data.llmAnalysis.value
          : this.llmAnalysis,
      alertEffectiveness: data.alertEffectiveness.present
          ? data.alertEffectiveness.value
          : this.alertEffectiveness,
      alertTimingAdequacy: data.alertTimingAdequacy.present
          ? data.alertTimingAdequacy.value
          : this.alertTimingAdequacy,
      difficultyLevel: data.difficultyLevel.present
          ? data.difficultyLevel.value
          : this.difficultyLevel,
      riderSummary: data.riderSummary.present
          ? data.riderSummary.value
          : this.riderSummary,
      improvementSuggestion: data.improvementSuggestion.present
          ? data.improvementSuggestion.value
          : this.improvementSuggestion,
      audioFilePath: data.audioFilePath.present
          ? data.audioFilePath.value
          : this.audioFilePath,
      analysisConfidence: data.analysisConfidence.present
          ? data.analysisConfidence.value
          : this.analysisConfidence,
      analyzedByLlm: data.analyzedByLlm.present
          ? data.analyzedByLlm.value
          : this.analyzedByLlm,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      analyzedAtUtc: data.analyzedAtUtc.present
          ? data.analyzedAtUtc.value
          : this.analyzedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventFeedback(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('tripId: $tripId, ')
          ..write('roadEventId: $roadEventId, ')
          ..write('preAlertId: $preAlertId, ')
          ..write('eventType: $eventType, ')
          ..write('prompt: $prompt, ')
          ..write('responseText: $responseText, ')
          ..write('responseSource: $responseSource, ')
          ..write('transcriptConfidence: $transcriptConfidence, ')
          ..write('llmAnalysis: $llmAnalysis, ')
          ..write('alertEffectiveness: $alertEffectiveness, ')
          ..write('alertTimingAdequacy: $alertTimingAdequacy, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('riderSummary: $riderSummary, ')
          ..write('improvementSuggestion: $improvementSuggestion, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('analysisConfidence: $analysisConfidence, ')
          ..write('analyzedByLlm: $analyzedByLlm, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('analyzedAtUtc: $analyzedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    eventId,
    tripId,
    roadEventId,
    preAlertId,
    eventType,
    prompt,
    responseText,
    responseSource,
    transcriptConfidence,
    llmAnalysis,
    alertEffectiveness,
    alertTimingAdequacy,
    difficultyLevel,
    riderSummary,
    improvementSuggestion,
    audioFilePath,
    analysisConfidence,
    analyzedByLlm,
    createdAtUtc,
    analyzedAtUtc,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventFeedback &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.tripId == this.tripId &&
          other.roadEventId == this.roadEventId &&
          other.preAlertId == this.preAlertId &&
          other.eventType == this.eventType &&
          other.prompt == this.prompt &&
          other.responseText == this.responseText &&
          other.responseSource == this.responseSource &&
          other.transcriptConfidence == this.transcriptConfidence &&
          other.llmAnalysis == this.llmAnalysis &&
          other.alertEffectiveness == this.alertEffectiveness &&
          other.alertTimingAdequacy == this.alertTimingAdequacy &&
          other.difficultyLevel == this.difficultyLevel &&
          other.riderSummary == this.riderSummary &&
          other.improvementSuggestion == this.improvementSuggestion &&
          other.audioFilePath == this.audioFilePath &&
          other.analysisConfidence == this.analysisConfidence &&
          other.analyzedByLlm == this.analyzedByLlm &&
          other.createdAtUtc == this.createdAtUtc &&
          other.analyzedAtUtc == this.analyzedAtUtc);
}

class EventFeedbacksCompanion extends UpdateCompanion<EventFeedback> {
  final Value<int> id;
  final Value<int?> eventId;
  final Value<int?> tripId;
  final Value<int?> roadEventId;
  final Value<int?> preAlertId;
  final Value<String> eventType;
  final Value<String> prompt;
  final Value<String> responseText;
  final Value<String> responseSource;
  final Value<double?> transcriptConfidence;
  final Value<String?> llmAnalysis;
  final Value<double?> alertEffectiveness;
  final Value<String?> alertTimingAdequacy;
  final Value<String?> difficultyLevel;
  final Value<String?> riderSummary;
  final Value<String?> improvementSuggestion;
  final Value<String?> audioFilePath;
  final Value<double?> analysisConfidence;
  final Value<bool> analyzedByLlm;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime?> analyzedAtUtc;
  const EventFeedbacksCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.roadEventId = const Value.absent(),
    this.preAlertId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.prompt = const Value.absent(),
    this.responseText = const Value.absent(),
    this.responseSource = const Value.absent(),
    this.transcriptConfidence = const Value.absent(),
    this.llmAnalysis = const Value.absent(),
    this.alertEffectiveness = const Value.absent(),
    this.alertTimingAdequacy = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.riderSummary = const Value.absent(),
    this.improvementSuggestion = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    this.analysisConfidence = const Value.absent(),
    this.analyzedByLlm = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.analyzedAtUtc = const Value.absent(),
  });
  EventFeedbacksCompanion.insert({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.roadEventId = const Value.absent(),
    this.preAlertId = const Value.absent(),
    required String eventType,
    required String prompt,
    required String responseText,
    required String responseSource,
    this.transcriptConfidence = const Value.absent(),
    this.llmAnalysis = const Value.absent(),
    this.alertEffectiveness = const Value.absent(),
    this.alertTimingAdequacy = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.riderSummary = const Value.absent(),
    this.improvementSuggestion = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    this.analysisConfidence = const Value.absent(),
    this.analyzedByLlm = const Value.absent(),
    required DateTime createdAtUtc,
    this.analyzedAtUtc = const Value.absent(),
  }) : eventType = Value(eventType),
       prompt = Value(prompt),
       responseText = Value(responseText),
       responseSource = Value(responseSource),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<EventFeedback> custom({
    Expression<int>? id,
    Expression<int>? eventId,
    Expression<int>? tripId,
    Expression<int>? roadEventId,
    Expression<int>? preAlertId,
    Expression<String>? eventType,
    Expression<String>? prompt,
    Expression<String>? responseText,
    Expression<String>? responseSource,
    Expression<double>? transcriptConfidence,
    Expression<String>? llmAnalysis,
    Expression<double>? alertEffectiveness,
    Expression<String>? alertTimingAdequacy,
    Expression<String>? difficultyLevel,
    Expression<String>? riderSummary,
    Expression<String>? improvementSuggestion,
    Expression<String>? audioFilePath,
    Expression<double>? analysisConfidence,
    Expression<bool>? analyzedByLlm,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? analyzedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (tripId != null) 'trip_id': tripId,
      if (roadEventId != null) 'road_event_id': roadEventId,
      if (preAlertId != null) 'pre_alert_id': preAlertId,
      if (eventType != null) 'event_type': eventType,
      if (prompt != null) 'prompt': prompt,
      if (responseText != null) 'response_text': responseText,
      if (responseSource != null) 'response_source': responseSource,
      if (transcriptConfidence != null)
        'transcript_confidence': transcriptConfidence,
      if (llmAnalysis != null) 'llm_analysis': llmAnalysis,
      if (alertEffectiveness != null) 'alert_effectiveness': alertEffectiveness,
      if (alertTimingAdequacy != null)
        'alert_timing_adequacy': alertTimingAdequacy,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      if (riderSummary != null) 'rider_summary': riderSummary,
      if (improvementSuggestion != null)
        'improvement_suggestion': improvementSuggestion,
      if (audioFilePath != null) 'audio_file_path': audioFilePath,
      if (analysisConfidence != null) 'analysis_confidence': analysisConfidence,
      if (analyzedByLlm != null) 'analyzed_by_llm': analyzedByLlm,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (analyzedAtUtc != null) 'analyzed_at_utc': analyzedAtUtc,
    });
  }

  EventFeedbacksCompanion copyWith({
    Value<int>? id,
    Value<int?>? eventId,
    Value<int?>? tripId,
    Value<int?>? roadEventId,
    Value<int?>? preAlertId,
    Value<String>? eventType,
    Value<String>? prompt,
    Value<String>? responseText,
    Value<String>? responseSource,
    Value<double?>? transcriptConfidence,
    Value<String?>? llmAnalysis,
    Value<double?>? alertEffectiveness,
    Value<String?>? alertTimingAdequacy,
    Value<String?>? difficultyLevel,
    Value<String?>? riderSummary,
    Value<String?>? improvementSuggestion,
    Value<String?>? audioFilePath,
    Value<double?>? analysisConfidence,
    Value<bool>? analyzedByLlm,
    Value<DateTime>? createdAtUtc,
    Value<DateTime?>? analyzedAtUtc,
  }) {
    return EventFeedbacksCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      tripId: tripId ?? this.tripId,
      roadEventId: roadEventId ?? this.roadEventId,
      preAlertId: preAlertId ?? this.preAlertId,
      eventType: eventType ?? this.eventType,
      prompt: prompt ?? this.prompt,
      responseText: responseText ?? this.responseText,
      responseSource: responseSource ?? this.responseSource,
      transcriptConfidence: transcriptConfidence ?? this.transcriptConfidence,
      llmAnalysis: llmAnalysis ?? this.llmAnalysis,
      alertEffectiveness: alertEffectiveness ?? this.alertEffectiveness,
      alertTimingAdequacy: alertTimingAdequacy ?? this.alertTimingAdequacy,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      riderSummary: riderSummary ?? this.riderSummary,
      improvementSuggestion:
          improvementSuggestion ?? this.improvementSuggestion,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      analysisConfidence: analysisConfidence ?? this.analysisConfidence,
      analyzedByLlm: analyzedByLlm ?? this.analyzedByLlm,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      analyzedAtUtc: analyzedAtUtc ?? this.analyzedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (roadEventId.present) {
      map['road_event_id'] = Variable<int>(roadEventId.value);
    }
    if (preAlertId.present) {
      map['pre_alert_id'] = Variable<int>(preAlertId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (responseText.present) {
      map['response_text'] = Variable<String>(responseText.value);
    }
    if (responseSource.present) {
      map['response_source'] = Variable<String>(responseSource.value);
    }
    if (transcriptConfidence.present) {
      map['transcript_confidence'] = Variable<double>(
        transcriptConfidence.value,
      );
    }
    if (llmAnalysis.present) {
      map['llm_analysis'] = Variable<String>(llmAnalysis.value);
    }
    if (alertEffectiveness.present) {
      map['alert_effectiveness'] = Variable<double>(alertEffectiveness.value);
    }
    if (alertTimingAdequacy.present) {
      map['alert_timing_adequacy'] = Variable<String>(
        alertTimingAdequacy.value,
      );
    }
    if (difficultyLevel.present) {
      map['difficulty_level'] = Variable<String>(difficultyLevel.value);
    }
    if (riderSummary.present) {
      map['rider_summary'] = Variable<String>(riderSummary.value);
    }
    if (improvementSuggestion.present) {
      map['improvement_suggestion'] = Variable<String>(
        improvementSuggestion.value,
      );
    }
    if (audioFilePath.present) {
      map['audio_file_path'] = Variable<String>(audioFilePath.value);
    }
    if (analysisConfidence.present) {
      map['analysis_confidence'] = Variable<double>(analysisConfidence.value);
    }
    if (analyzedByLlm.present) {
      map['analyzed_by_llm'] = Variable<bool>(analyzedByLlm.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (analyzedAtUtc.present) {
      map['analyzed_at_utc'] = Variable<DateTime>(analyzedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventFeedbacksCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('tripId: $tripId, ')
          ..write('roadEventId: $roadEventId, ')
          ..write('preAlertId: $preAlertId, ')
          ..write('eventType: $eventType, ')
          ..write('prompt: $prompt, ')
          ..write('responseText: $responseText, ')
          ..write('responseSource: $responseSource, ')
          ..write('transcriptConfidence: $transcriptConfidence, ')
          ..write('llmAnalysis: $llmAnalysis, ')
          ..write('alertEffectiveness: $alertEffectiveness, ')
          ..write('alertTimingAdequacy: $alertTimingAdequacy, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('riderSummary: $riderSummary, ')
          ..write('improvementSuggestion: $improvementSuggestion, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('analysisConfidence: $analysisConfidence, ')
          ..write('analyzedByLlm: $analyzedByLlm, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('analyzedAtUtc: $analyzedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $UnknownEventsTable extends UnknownEvents
    with TableInfo<$UnknownEventsTable, UnknownEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnknownEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imuSnapshotJsonMeta = const VerificationMeta(
    'imuSnapshotJson',
  );
  @override
  late final GeneratedColumn<String> imuSnapshotJson = GeneratedColumn<String>(
    'imu_snapshot_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peakAccelMagnitudeMeta =
      const VerificationMeta('peakAccelMagnitude');
  @override
  late final GeneratedColumn<double> peakAccelMagnitude =
      GeneratedColumn<double>(
        'peak_accel_magnitude',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questionSpokenMeta = const VerificationMeta(
    'questionSpoken',
  );
  @override
  late final GeneratedColumn<String> questionSpoken = GeneratedColumn<String>(
    'question_spoken',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riderAnswerRawMeta = const VerificationMeta(
    'riderAnswerRaw',
  );
  @override
  late final GeneratedColumn<String> riderAnswerRaw = GeneratedColumn<String>(
    'rider_answer_raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptConfidenceMeta =
      const VerificationMeta('transcriptConfidence');
  @override
  late final GeneratedColumn<double> transcriptConfidence =
      GeneratedColumn<double>(
        'transcript_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _resolvedLabelMeta = const VerificationMeta(
    'resolvedLabel',
  );
  @override
  late final GeneratedColumn<String> resolvedLabel = GeneratedColumn<String>(
    'resolved_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promotedMeta = const VerificationMeta(
    'promoted',
  );
  @override
  late final GeneratedColumn<bool> promoted = GeneratedColumn<bool>(
    'promoted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("promoted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _promotedRoadEventIdMeta =
      const VerificationMeta('promotedRoadEventId');
  @override
  late final GeneratedColumn<int> promotedRoadEventId = GeneratedColumn<int>(
    'promoted_road_event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioFilePathMeta = const VerificationMeta(
    'audioFilePath',
  );
  @override
  late final GeneratedColumn<String> audioFilePath = GeneratedColumn<String>(
    'audio_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectedAtUtcMeta = const VerificationMeta(
    'detectedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAtUtc =
      GeneratedColumn<DateTime>(
        'detected_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _answeredAtUtcMeta = const VerificationMeta(
    'answeredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAtUtc =
      GeneratedColumn<DateTime>(
        'answered_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    latitude,
    longitude,
    imuSnapshotJson,
    peakAccelMagnitude,
    durationMs,
    questionSpoken,
    riderAnswerRaw,
    transcriptConfidence,
    resolvedLabel,
    promoted,
    promotedRoadEventId,
    audioFilePath,
    detectedAtUtc,
    answeredAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unknown_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnknownEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('imu_snapshot_json')) {
      context.handle(
        _imuSnapshotJsonMeta,
        imuSnapshotJson.isAcceptableOrUnknown(
          data['imu_snapshot_json']!,
          _imuSnapshotJsonMeta,
        ),
      );
    }
    if (data.containsKey('peak_accel_magnitude')) {
      context.handle(
        _peakAccelMagnitudeMeta,
        peakAccelMagnitude.isAcceptableOrUnknown(
          data['peak_accel_magnitude']!,
          _peakAccelMagnitudeMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('question_spoken')) {
      context.handle(
        _questionSpokenMeta,
        questionSpoken.isAcceptableOrUnknown(
          data['question_spoken']!,
          _questionSpokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionSpokenMeta);
    }
    if (data.containsKey('rider_answer_raw')) {
      context.handle(
        _riderAnswerRawMeta,
        riderAnswerRaw.isAcceptableOrUnknown(
          data['rider_answer_raw']!,
          _riderAnswerRawMeta,
        ),
      );
    }
    if (data.containsKey('transcript_confidence')) {
      context.handle(
        _transcriptConfidenceMeta,
        transcriptConfidence.isAcceptableOrUnknown(
          data['transcript_confidence']!,
          _transcriptConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('resolved_label')) {
      context.handle(
        _resolvedLabelMeta,
        resolvedLabel.isAcceptableOrUnknown(
          data['resolved_label']!,
          _resolvedLabelMeta,
        ),
      );
    }
    if (data.containsKey('promoted')) {
      context.handle(
        _promotedMeta,
        promoted.isAcceptableOrUnknown(data['promoted']!, _promotedMeta),
      );
    }
    if (data.containsKey('promoted_road_event_id')) {
      context.handle(
        _promotedRoadEventIdMeta,
        promotedRoadEventId.isAcceptableOrUnknown(
          data['promoted_road_event_id']!,
          _promotedRoadEventIdMeta,
        ),
      );
    }
    if (data.containsKey('audio_file_path')) {
      context.handle(
        _audioFilePathMeta,
        audioFilePath.isAcceptableOrUnknown(
          data['audio_file_path']!,
          _audioFilePathMeta,
        ),
      );
    }
    if (data.containsKey('detected_at_utc')) {
      context.handle(
        _detectedAtUtcMeta,
        detectedAtUtc.isAcceptableOrUnknown(
          data['detected_at_utc']!,
          _detectedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectedAtUtcMeta);
    }
    if (data.containsKey('answered_at_utc')) {
      context.handle(
        _answeredAtUtcMeta,
        answeredAtUtc.isAcceptableOrUnknown(
          data['answered_at_utc']!,
          _answeredAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnknownEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnknownEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      imuSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imu_snapshot_json'],
      ),
      peakAccelMagnitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_accel_magnitude'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      questionSpoken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_spoken'],
      )!,
      riderAnswerRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rider_answer_raw'],
      ),
      transcriptConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}transcript_confidence'],
      ),
      resolvedLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_label'],
      ),
      promoted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}promoted'],
      )!,
      promotedRoadEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}promoted_road_event_id'],
      ),
      audioFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_file_path'],
      ),
      detectedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at_utc'],
      )!,
      answeredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at_utc'],
      ),
    );
  }

  @override
  $UnknownEventsTable createAlias(String alias) {
    return $UnknownEventsTable(attachedDatabase, alias);
  }
}

class UnknownEvent extends DataClass implements Insertable<UnknownEvent> {
  final int id;

  /// The trip during which the anomaly was detected.
  final int? tripId;

  /// GPS latitude at the moment the anomaly was detected.
  final double? latitude;

  /// GPS longitude at the moment the anomaly was detected.
  final double? longitude;

  /// Raw IMU signal statistics captured around the event window (JSON).
  final String? imuSnapshotJson;

  /// Peak acceleration magnitude (m/s²) during the anomaly window.
  final double? peakAccelMagnitude;

  /// Duration of the anomaly window in milliseconds.
  final int? durationMs;

  /// The exact text spoken to the rider when asking "what was that?".
  final String questionSpoken;

  /// The rider's raw transcribed answer.
  final String? riderAnswerRaw;

  /// STT confidence (0..1) for the rider's answer.
  final double? transcriptConfidence;

  /// Normalised event label derived from the rider's answer (e.g. "speed_bump").
  final String? resolvedLabel;

  /// Whether the resolved label was promoted to road_events.
  final bool promoted;

  /// The road_event row id created when the event was promoted (if any).
  final int? promotedRoadEventId;

  /// Local filesystem path to the recorded 5-second audio clip (.mp4/.m4a).
  final String? audioFilePath;

  /// Timestamp when the anomaly was first detected.
  final DateTime detectedAtUtc;

  /// Timestamp when the rider's answer was recorded.
  final DateTime? answeredAtUtc;
  const UnknownEvent({
    required this.id,
    this.tripId,
    this.latitude,
    this.longitude,
    this.imuSnapshotJson,
    this.peakAccelMagnitude,
    this.durationMs,
    required this.questionSpoken,
    this.riderAnswerRaw,
    this.transcriptConfidence,
    this.resolvedLabel,
    required this.promoted,
    this.promotedRoadEventId,
    this.audioFilePath,
    required this.detectedAtUtc,
    this.answeredAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || imuSnapshotJson != null) {
      map['imu_snapshot_json'] = Variable<String>(imuSnapshotJson);
    }
    if (!nullToAbsent || peakAccelMagnitude != null) {
      map['peak_accel_magnitude'] = Variable<double>(peakAccelMagnitude);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['question_spoken'] = Variable<String>(questionSpoken);
    if (!nullToAbsent || riderAnswerRaw != null) {
      map['rider_answer_raw'] = Variable<String>(riderAnswerRaw);
    }
    if (!nullToAbsent || transcriptConfidence != null) {
      map['transcript_confidence'] = Variable<double>(transcriptConfidence);
    }
    if (!nullToAbsent || resolvedLabel != null) {
      map['resolved_label'] = Variable<String>(resolvedLabel);
    }
    map['promoted'] = Variable<bool>(promoted);
    if (!nullToAbsent || promotedRoadEventId != null) {
      map['promoted_road_event_id'] = Variable<int>(promotedRoadEventId);
    }
    if (!nullToAbsent || audioFilePath != null) {
      map['audio_file_path'] = Variable<String>(audioFilePath);
    }
    map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc);
    if (!nullToAbsent || answeredAtUtc != null) {
      map['answered_at_utc'] = Variable<DateTime>(answeredAtUtc);
    }
    return map;
  }

  UnknownEventsCompanion toCompanion(bool nullToAbsent) {
    return UnknownEventsCompanion(
      id: Value(id),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      imuSnapshotJson: imuSnapshotJson == null && nullToAbsent
          ? const Value.absent()
          : Value(imuSnapshotJson),
      peakAccelMagnitude: peakAccelMagnitude == null && nullToAbsent
          ? const Value.absent()
          : Value(peakAccelMagnitude),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      questionSpoken: Value(questionSpoken),
      riderAnswerRaw: riderAnswerRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(riderAnswerRaw),
      transcriptConfidence: transcriptConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(transcriptConfidence),
      resolvedLabel: resolvedLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedLabel),
      promoted: Value(promoted),
      promotedRoadEventId: promotedRoadEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(promotedRoadEventId),
      audioFilePath: audioFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFilePath),
      detectedAtUtc: Value(detectedAtUtc),
      answeredAtUtc: answeredAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAtUtc),
    );
  }

  factory UnknownEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnknownEvent(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      imuSnapshotJson: serializer.fromJson<String?>(json['imuSnapshotJson']),
      peakAccelMagnitude: serializer.fromJson<double?>(
        json['peakAccelMagnitude'],
      ),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      questionSpoken: serializer.fromJson<String>(json['questionSpoken']),
      riderAnswerRaw: serializer.fromJson<String?>(json['riderAnswerRaw']),
      transcriptConfidence: serializer.fromJson<double?>(
        json['transcriptConfidence'],
      ),
      resolvedLabel: serializer.fromJson<String?>(json['resolvedLabel']),
      promoted: serializer.fromJson<bool>(json['promoted']),
      promotedRoadEventId: serializer.fromJson<int?>(
        json['promotedRoadEventId'],
      ),
      audioFilePath: serializer.fromJson<String?>(json['audioFilePath']),
      detectedAtUtc: serializer.fromJson<DateTime>(json['detectedAtUtc']),
      answeredAtUtc: serializer.fromJson<DateTime?>(json['answeredAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<int?>(tripId),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'imuSnapshotJson': serializer.toJson<String?>(imuSnapshotJson),
      'peakAccelMagnitude': serializer.toJson<double?>(peakAccelMagnitude),
      'durationMs': serializer.toJson<int?>(durationMs),
      'questionSpoken': serializer.toJson<String>(questionSpoken),
      'riderAnswerRaw': serializer.toJson<String?>(riderAnswerRaw),
      'transcriptConfidence': serializer.toJson<double?>(transcriptConfidence),
      'resolvedLabel': serializer.toJson<String?>(resolvedLabel),
      'promoted': serializer.toJson<bool>(promoted),
      'promotedRoadEventId': serializer.toJson<int?>(promotedRoadEventId),
      'audioFilePath': serializer.toJson<String?>(audioFilePath),
      'detectedAtUtc': serializer.toJson<DateTime>(detectedAtUtc),
      'answeredAtUtc': serializer.toJson<DateTime?>(answeredAtUtc),
    };
  }

  UnknownEvent copyWith({
    int? id,
    Value<int?> tripId = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> imuSnapshotJson = const Value.absent(),
    Value<double?> peakAccelMagnitude = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    String? questionSpoken,
    Value<String?> riderAnswerRaw = const Value.absent(),
    Value<double?> transcriptConfidence = const Value.absent(),
    Value<String?> resolvedLabel = const Value.absent(),
    bool? promoted,
    Value<int?> promotedRoadEventId = const Value.absent(),
    Value<String?> audioFilePath = const Value.absent(),
    DateTime? detectedAtUtc,
    Value<DateTime?> answeredAtUtc = const Value.absent(),
  }) => UnknownEvent(
    id: id ?? this.id,
    tripId: tripId.present ? tripId.value : this.tripId,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    imuSnapshotJson: imuSnapshotJson.present
        ? imuSnapshotJson.value
        : this.imuSnapshotJson,
    peakAccelMagnitude: peakAccelMagnitude.present
        ? peakAccelMagnitude.value
        : this.peakAccelMagnitude,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    questionSpoken: questionSpoken ?? this.questionSpoken,
    riderAnswerRaw: riderAnswerRaw.present
        ? riderAnswerRaw.value
        : this.riderAnswerRaw,
    transcriptConfidence: transcriptConfidence.present
        ? transcriptConfidence.value
        : this.transcriptConfidence,
    resolvedLabel: resolvedLabel.present
        ? resolvedLabel.value
        : this.resolvedLabel,
    promoted: promoted ?? this.promoted,
    promotedRoadEventId: promotedRoadEventId.present
        ? promotedRoadEventId.value
        : this.promotedRoadEventId,
    audioFilePath: audioFilePath.present
        ? audioFilePath.value
        : this.audioFilePath,
    detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
    answeredAtUtc: answeredAtUtc.present
        ? answeredAtUtc.value
        : this.answeredAtUtc,
  );
  UnknownEvent copyWithCompanion(UnknownEventsCompanion data) {
    return UnknownEvent(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      imuSnapshotJson: data.imuSnapshotJson.present
          ? data.imuSnapshotJson.value
          : this.imuSnapshotJson,
      peakAccelMagnitude: data.peakAccelMagnitude.present
          ? data.peakAccelMagnitude.value
          : this.peakAccelMagnitude,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      questionSpoken: data.questionSpoken.present
          ? data.questionSpoken.value
          : this.questionSpoken,
      riderAnswerRaw: data.riderAnswerRaw.present
          ? data.riderAnswerRaw.value
          : this.riderAnswerRaw,
      transcriptConfidence: data.transcriptConfidence.present
          ? data.transcriptConfidence.value
          : this.transcriptConfidence,
      resolvedLabel: data.resolvedLabel.present
          ? data.resolvedLabel.value
          : this.resolvedLabel,
      promoted: data.promoted.present ? data.promoted.value : this.promoted,
      promotedRoadEventId: data.promotedRoadEventId.present
          ? data.promotedRoadEventId.value
          : this.promotedRoadEventId,
      audioFilePath: data.audioFilePath.present
          ? data.audioFilePath.value
          : this.audioFilePath,
      detectedAtUtc: data.detectedAtUtc.present
          ? data.detectedAtUtc.value
          : this.detectedAtUtc,
      answeredAtUtc: data.answeredAtUtc.present
          ? data.answeredAtUtc.value
          : this.answeredAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnknownEvent(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('imuSnapshotJson: $imuSnapshotJson, ')
          ..write('peakAccelMagnitude: $peakAccelMagnitude, ')
          ..write('durationMs: $durationMs, ')
          ..write('questionSpoken: $questionSpoken, ')
          ..write('riderAnswerRaw: $riderAnswerRaw, ')
          ..write('transcriptConfidence: $transcriptConfidence, ')
          ..write('resolvedLabel: $resolvedLabel, ')
          ..write('promoted: $promoted, ')
          ..write('promotedRoadEventId: $promotedRoadEventId, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('answeredAtUtc: $answeredAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    latitude,
    longitude,
    imuSnapshotJson,
    peakAccelMagnitude,
    durationMs,
    questionSpoken,
    riderAnswerRaw,
    transcriptConfidence,
    resolvedLabel,
    promoted,
    promotedRoadEventId,
    audioFilePath,
    detectedAtUtc,
    answeredAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnknownEvent &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.imuSnapshotJson == this.imuSnapshotJson &&
          other.peakAccelMagnitude == this.peakAccelMagnitude &&
          other.durationMs == this.durationMs &&
          other.questionSpoken == this.questionSpoken &&
          other.riderAnswerRaw == this.riderAnswerRaw &&
          other.transcriptConfidence == this.transcriptConfidence &&
          other.resolvedLabel == this.resolvedLabel &&
          other.promoted == this.promoted &&
          other.promotedRoadEventId == this.promotedRoadEventId &&
          other.audioFilePath == this.audioFilePath &&
          other.detectedAtUtc == this.detectedAtUtc &&
          other.answeredAtUtc == this.answeredAtUtc);
}

class UnknownEventsCompanion extends UpdateCompanion<UnknownEvent> {
  final Value<int> id;
  final Value<int?> tripId;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> imuSnapshotJson;
  final Value<double?> peakAccelMagnitude;
  final Value<int?> durationMs;
  final Value<String> questionSpoken;
  final Value<String?> riderAnswerRaw;
  final Value<double?> transcriptConfidence;
  final Value<String?> resolvedLabel;
  final Value<bool> promoted;
  final Value<int?> promotedRoadEventId;
  final Value<String?> audioFilePath;
  final Value<DateTime> detectedAtUtc;
  final Value<DateTime?> answeredAtUtc;
  const UnknownEventsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.imuSnapshotJson = const Value.absent(),
    this.peakAccelMagnitude = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.questionSpoken = const Value.absent(),
    this.riderAnswerRaw = const Value.absent(),
    this.transcriptConfidence = const Value.absent(),
    this.resolvedLabel = const Value.absent(),
    this.promoted = const Value.absent(),
    this.promotedRoadEventId = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    this.detectedAtUtc = const Value.absent(),
    this.answeredAtUtc = const Value.absent(),
  });
  UnknownEventsCompanion.insert({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.imuSnapshotJson = const Value.absent(),
    this.peakAccelMagnitude = const Value.absent(),
    this.durationMs = const Value.absent(),
    required String questionSpoken,
    this.riderAnswerRaw = const Value.absent(),
    this.transcriptConfidence = const Value.absent(),
    this.resolvedLabel = const Value.absent(),
    this.promoted = const Value.absent(),
    this.promotedRoadEventId = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    required DateTime detectedAtUtc,
    this.answeredAtUtc = const Value.absent(),
  }) : questionSpoken = Value(questionSpoken),
       detectedAtUtc = Value(detectedAtUtc);
  static Insertable<UnknownEvent> custom({
    Expression<int>? id,
    Expression<int>? tripId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? imuSnapshotJson,
    Expression<double>? peakAccelMagnitude,
    Expression<int>? durationMs,
    Expression<String>? questionSpoken,
    Expression<String>? riderAnswerRaw,
    Expression<double>? transcriptConfidence,
    Expression<String>? resolvedLabel,
    Expression<bool>? promoted,
    Expression<int>? promotedRoadEventId,
    Expression<String>? audioFilePath,
    Expression<DateTime>? detectedAtUtc,
    Expression<DateTime>? answeredAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (imuSnapshotJson != null) 'imu_snapshot_json': imuSnapshotJson,
      if (peakAccelMagnitude != null)
        'peak_accel_magnitude': peakAccelMagnitude,
      if (durationMs != null) 'duration_ms': durationMs,
      if (questionSpoken != null) 'question_spoken': questionSpoken,
      if (riderAnswerRaw != null) 'rider_answer_raw': riderAnswerRaw,
      if (transcriptConfidence != null)
        'transcript_confidence': transcriptConfidence,
      if (resolvedLabel != null) 'resolved_label': resolvedLabel,
      if (promoted != null) 'promoted': promoted,
      if (promotedRoadEventId != null)
        'promoted_road_event_id': promotedRoadEventId,
      if (audioFilePath != null) 'audio_file_path': audioFilePath,
      if (detectedAtUtc != null) 'detected_at_utc': detectedAtUtc,
      if (answeredAtUtc != null) 'answered_at_utc': answeredAtUtc,
    });
  }

  UnknownEventsCompanion copyWith({
    Value<int>? id,
    Value<int?>? tripId,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? imuSnapshotJson,
    Value<double?>? peakAccelMagnitude,
    Value<int?>? durationMs,
    Value<String>? questionSpoken,
    Value<String?>? riderAnswerRaw,
    Value<double?>? transcriptConfidence,
    Value<String?>? resolvedLabel,
    Value<bool>? promoted,
    Value<int?>? promotedRoadEventId,
    Value<String?>? audioFilePath,
    Value<DateTime>? detectedAtUtc,
    Value<DateTime?>? answeredAtUtc,
  }) {
    return UnknownEventsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imuSnapshotJson: imuSnapshotJson ?? this.imuSnapshotJson,
      peakAccelMagnitude: peakAccelMagnitude ?? this.peakAccelMagnitude,
      durationMs: durationMs ?? this.durationMs,
      questionSpoken: questionSpoken ?? this.questionSpoken,
      riderAnswerRaw: riderAnswerRaw ?? this.riderAnswerRaw,
      transcriptConfidence: transcriptConfidence ?? this.transcriptConfidence,
      resolvedLabel: resolvedLabel ?? this.resolvedLabel,
      promoted: promoted ?? this.promoted,
      promotedRoadEventId: promotedRoadEventId ?? this.promotedRoadEventId,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
      answeredAtUtc: answeredAtUtc ?? this.answeredAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (imuSnapshotJson.present) {
      map['imu_snapshot_json'] = Variable<String>(imuSnapshotJson.value);
    }
    if (peakAccelMagnitude.present) {
      map['peak_accel_magnitude'] = Variable<double>(peakAccelMagnitude.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (questionSpoken.present) {
      map['question_spoken'] = Variable<String>(questionSpoken.value);
    }
    if (riderAnswerRaw.present) {
      map['rider_answer_raw'] = Variable<String>(riderAnswerRaw.value);
    }
    if (transcriptConfidence.present) {
      map['transcript_confidence'] = Variable<double>(
        transcriptConfidence.value,
      );
    }
    if (resolvedLabel.present) {
      map['resolved_label'] = Variable<String>(resolvedLabel.value);
    }
    if (promoted.present) {
      map['promoted'] = Variable<bool>(promoted.value);
    }
    if (promotedRoadEventId.present) {
      map['promoted_road_event_id'] = Variable<int>(promotedRoadEventId.value);
    }
    if (audioFilePath.present) {
      map['audio_file_path'] = Variable<String>(audioFilePath.value);
    }
    if (detectedAtUtc.present) {
      map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc.value);
    }
    if (answeredAtUtc.present) {
      map['answered_at_utc'] = Variable<DateTime>(answeredAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnknownEventsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('imuSnapshotJson: $imuSnapshotJson, ')
          ..write('peakAccelMagnitude: $peakAccelMagnitude, ')
          ..write('durationMs: $durationMs, ')
          ..write('questionSpoken: $questionSpoken, ')
          ..write('riderAnswerRaw: $riderAnswerRaw, ')
          ..write('transcriptConfidence: $transcriptConfidence, ')
          ..write('resolvedLabel: $resolvedLabel, ')
          ..write('promoted: $promoted, ')
          ..write('promotedRoadEventId: $promotedRoadEventId, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('answeredAtUtc: $answeredAtUtc')
          ..write(')'))
        .toString();
  }
}

class $CameraCapturesTable extends CameraCaptures
    with TableInfo<$CameraCapturesTable, CameraCapture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CameraCapturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _captureKeyMeta = const VerificationMeta(
    'captureKey',
  );
  @override
  late final GeneratedColumn<String> captureKey = GeneratedColumn<String>(
    'capture_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceNoMeta = const VerificationMeta(
    'sequenceNo',
  );
  @override
  late final GeneratedColumn<int> sequenceNo = GeneratedColumn<int>(
    'sequence_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtUtcMeta = const VerificationMeta(
    'capturedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAtUtc =
      GeneratedColumn<DateTime>(
        'captured_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receivedAtUtcMeta = const VerificationMeta(
    'receivedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAtUtc =
      GeneratedColumn<DateTime>(
        'received_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedEventIdMeta = const VerificationMeta(
    'linkedEventId',
  );
  @override
  late final GeneratedColumn<int> linkedEventId = GeneratedColumn<int>(
    'linked_event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('image/jpeg'),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteLengthMeta = const VerificationMeta(
    'byteLength',
  );
  @override
  late final GeneratedColumn<int> byteLength = GeneratedColumn<int>(
    'byte_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    captureKey,
    deviceId,
    sequenceNo,
    capturedAtUtc,
    receivedAtUtc,
    tripId,
    linkedEventId,
    filePath,
    mimeType,
    width,
    height,
    byteLength,
    sha256,
    trigger,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'camera_captures';
  @override
  VerificationContext validateIntegrity(
    Insertable<CameraCapture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('capture_key')) {
      context.handle(
        _captureKeyMeta,
        captureKey.isAcceptableOrUnknown(data['capture_key']!, _captureKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_captureKeyMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('sequence_no')) {
      context.handle(
        _sequenceNoMeta,
        sequenceNo.isAcceptableOrUnknown(data['sequence_no']!, _sequenceNoMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceNoMeta);
    }
    if (data.containsKey('captured_at_utc')) {
      context.handle(
        _capturedAtUtcMeta,
        capturedAtUtc.isAcceptableOrUnknown(
          data['captured_at_utc']!,
          _capturedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capturedAtUtcMeta);
    }
    if (data.containsKey('received_at_utc')) {
      context.handle(
        _receivedAtUtcMeta,
        receivedAtUtc.isAcceptableOrUnknown(
          data['received_at_utc']!,
          _receivedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedAtUtcMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    if (data.containsKey('linked_event_id')) {
      context.handle(
        _linkedEventIdMeta,
        linkedEventId.isAcceptableOrUnknown(
          data['linked_event_id']!,
          _linkedEventIdMeta,
        ),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('byte_length')) {
      context.handle(
        _byteLengthMeta,
        byteLength.isAcceptableOrUnknown(data['byte_length']!, _byteLengthMeta),
      );
    } else if (isInserting) {
      context.missing(_byteLengthMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId, sequenceNo},
  ];
  @override
  CameraCapture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CameraCapture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      captureKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capture_key'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      sequenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_no'],
      )!,
      capturedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at_utc'],
      )!,
      receivedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at_utc'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      ),
      linkedEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_event_id'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      byteLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_length'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
    );
  }

  @override
  $CameraCapturesTable createAlias(String alias) {
    return $CameraCapturesTable(attachedDatabase, alias);
  }
}

class CameraCapture extends DataClass implements Insertable<CameraCapture> {
  final int id;
  final String captureKey;
  final String deviceId;
  final int sequenceNo;
  final DateTime capturedAtUtc;
  final DateTime receivedAtUtc;
  final int? tripId;
  final int? linkedEventId;
  final String filePath;
  final String mimeType;
  final int width;
  final int height;
  final int byteLength;
  final String sha256;

  /// manual | camera_button | incident | interval
  final String trigger;
  const CameraCapture({
    required this.id,
    required this.captureKey,
    required this.deviceId,
    required this.sequenceNo,
    required this.capturedAtUtc,
    required this.receivedAtUtc,
    this.tripId,
    this.linkedEventId,
    required this.filePath,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.byteLength,
    required this.sha256,
    required this.trigger,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['capture_key'] = Variable<String>(captureKey);
    map['device_id'] = Variable<String>(deviceId);
    map['sequence_no'] = Variable<int>(sequenceNo);
    map['captured_at_utc'] = Variable<DateTime>(capturedAtUtc);
    map['received_at_utc'] = Variable<DateTime>(receivedAtUtc);
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    if (!nullToAbsent || linkedEventId != null) {
      map['linked_event_id'] = Variable<int>(linkedEventId);
    }
    map['file_path'] = Variable<String>(filePath);
    map['mime_type'] = Variable<String>(mimeType);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['byte_length'] = Variable<int>(byteLength);
    map['sha256'] = Variable<String>(sha256);
    map['trigger'] = Variable<String>(trigger);
    return map;
  }

  CameraCapturesCompanion toCompanion(bool nullToAbsent) {
    return CameraCapturesCompanion(
      id: Value(id),
      captureKey: Value(captureKey),
      deviceId: Value(deviceId),
      sequenceNo: Value(sequenceNo),
      capturedAtUtc: Value(capturedAtUtc),
      receivedAtUtc: Value(receivedAtUtc),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
      linkedEventId: linkedEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedEventId),
      filePath: Value(filePath),
      mimeType: Value(mimeType),
      width: Value(width),
      height: Value(height),
      byteLength: Value(byteLength),
      sha256: Value(sha256),
      trigger: Value(trigger),
    );
  }

  factory CameraCapture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CameraCapture(
      id: serializer.fromJson<int>(json['id']),
      captureKey: serializer.fromJson<String>(json['captureKey']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      sequenceNo: serializer.fromJson<int>(json['sequenceNo']),
      capturedAtUtc: serializer.fromJson<DateTime>(json['capturedAtUtc']),
      receivedAtUtc: serializer.fromJson<DateTime>(json['receivedAtUtc']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      linkedEventId: serializer.fromJson<int?>(json['linkedEventId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      byteLength: serializer.fromJson<int>(json['byteLength']),
      sha256: serializer.fromJson<String>(json['sha256']),
      trigger: serializer.fromJson<String>(json['trigger']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'captureKey': serializer.toJson<String>(captureKey),
      'deviceId': serializer.toJson<String>(deviceId),
      'sequenceNo': serializer.toJson<int>(sequenceNo),
      'capturedAtUtc': serializer.toJson<DateTime>(capturedAtUtc),
      'receivedAtUtc': serializer.toJson<DateTime>(receivedAtUtc),
      'tripId': serializer.toJson<int?>(tripId),
      'linkedEventId': serializer.toJson<int?>(linkedEventId),
      'filePath': serializer.toJson<String>(filePath),
      'mimeType': serializer.toJson<String>(mimeType),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'byteLength': serializer.toJson<int>(byteLength),
      'sha256': serializer.toJson<String>(sha256),
      'trigger': serializer.toJson<String>(trigger),
    };
  }

  CameraCapture copyWith({
    int? id,
    String? captureKey,
    String? deviceId,
    int? sequenceNo,
    DateTime? capturedAtUtc,
    DateTime? receivedAtUtc,
    Value<int?> tripId = const Value.absent(),
    Value<int?> linkedEventId = const Value.absent(),
    String? filePath,
    String? mimeType,
    int? width,
    int? height,
    int? byteLength,
    String? sha256,
    String? trigger,
  }) => CameraCapture(
    id: id ?? this.id,
    captureKey: captureKey ?? this.captureKey,
    deviceId: deviceId ?? this.deviceId,
    sequenceNo: sequenceNo ?? this.sequenceNo,
    capturedAtUtc: capturedAtUtc ?? this.capturedAtUtc,
    receivedAtUtc: receivedAtUtc ?? this.receivedAtUtc,
    tripId: tripId.present ? tripId.value : this.tripId,
    linkedEventId: linkedEventId.present
        ? linkedEventId.value
        : this.linkedEventId,
    filePath: filePath ?? this.filePath,
    mimeType: mimeType ?? this.mimeType,
    width: width ?? this.width,
    height: height ?? this.height,
    byteLength: byteLength ?? this.byteLength,
    sha256: sha256 ?? this.sha256,
    trigger: trigger ?? this.trigger,
  );
  CameraCapture copyWithCompanion(CameraCapturesCompanion data) {
    return CameraCapture(
      id: data.id.present ? data.id.value : this.id,
      captureKey: data.captureKey.present
          ? data.captureKey.value
          : this.captureKey,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      sequenceNo: data.sequenceNo.present
          ? data.sequenceNo.value
          : this.sequenceNo,
      capturedAtUtc: data.capturedAtUtc.present
          ? data.capturedAtUtc.value
          : this.capturedAtUtc,
      receivedAtUtc: data.receivedAtUtc.present
          ? data.receivedAtUtc.value
          : this.receivedAtUtc,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      linkedEventId: data.linkedEventId.present
          ? data.linkedEventId.value
          : this.linkedEventId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      byteLength: data.byteLength.present
          ? data.byteLength.value
          : this.byteLength,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CameraCapture(')
          ..write('id: $id, ')
          ..write('captureKey: $captureKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('sequenceNo: $sequenceNo, ')
          ..write('capturedAtUtc: $capturedAtUtc, ')
          ..write('receivedAtUtc: $receivedAtUtc, ')
          ..write('tripId: $tripId, ')
          ..write('linkedEventId: $linkedEventId, ')
          ..write('filePath: $filePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('byteLength: $byteLength, ')
          ..write('sha256: $sha256, ')
          ..write('trigger: $trigger')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    captureKey,
    deviceId,
    sequenceNo,
    capturedAtUtc,
    receivedAtUtc,
    tripId,
    linkedEventId,
    filePath,
    mimeType,
    width,
    height,
    byteLength,
    sha256,
    trigger,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CameraCapture &&
          other.id == this.id &&
          other.captureKey == this.captureKey &&
          other.deviceId == this.deviceId &&
          other.sequenceNo == this.sequenceNo &&
          other.capturedAtUtc == this.capturedAtUtc &&
          other.receivedAtUtc == this.receivedAtUtc &&
          other.tripId == this.tripId &&
          other.linkedEventId == this.linkedEventId &&
          other.filePath == this.filePath &&
          other.mimeType == this.mimeType &&
          other.width == this.width &&
          other.height == this.height &&
          other.byteLength == this.byteLength &&
          other.sha256 == this.sha256 &&
          other.trigger == this.trigger);
}

class CameraCapturesCompanion extends UpdateCompanion<CameraCapture> {
  final Value<int> id;
  final Value<String> captureKey;
  final Value<String> deviceId;
  final Value<int> sequenceNo;
  final Value<DateTime> capturedAtUtc;
  final Value<DateTime> receivedAtUtc;
  final Value<int?> tripId;
  final Value<int?> linkedEventId;
  final Value<String> filePath;
  final Value<String> mimeType;
  final Value<int> width;
  final Value<int> height;
  final Value<int> byteLength;
  final Value<String> sha256;
  final Value<String> trigger;
  const CameraCapturesCompanion({
    this.id = const Value.absent(),
    this.captureKey = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.sequenceNo = const Value.absent(),
    this.capturedAtUtc = const Value.absent(),
    this.receivedAtUtc = const Value.absent(),
    this.tripId = const Value.absent(),
    this.linkedEventId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.trigger = const Value.absent(),
  });
  CameraCapturesCompanion.insert({
    this.id = const Value.absent(),
    required String captureKey,
    required String deviceId,
    required int sequenceNo,
    required DateTime capturedAtUtc,
    required DateTime receivedAtUtc,
    this.tripId = const Value.absent(),
    this.linkedEventId = const Value.absent(),
    required String filePath,
    this.mimeType = const Value.absent(),
    required int width,
    required int height,
    required int byteLength,
    required String sha256,
    this.trigger = const Value.absent(),
  }) : captureKey = Value(captureKey),
       deviceId = Value(deviceId),
       sequenceNo = Value(sequenceNo),
       capturedAtUtc = Value(capturedAtUtc),
       receivedAtUtc = Value(receivedAtUtc),
       filePath = Value(filePath),
       width = Value(width),
       height = Value(height),
       byteLength = Value(byteLength),
       sha256 = Value(sha256);
  static Insertable<CameraCapture> custom({
    Expression<int>? id,
    Expression<String>? captureKey,
    Expression<String>? deviceId,
    Expression<int>? sequenceNo,
    Expression<DateTime>? capturedAtUtc,
    Expression<DateTime>? receivedAtUtc,
    Expression<int>? tripId,
    Expression<int>? linkedEventId,
    Expression<String>? filePath,
    Expression<String>? mimeType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? byteLength,
    Expression<String>? sha256,
    Expression<String>? trigger,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (captureKey != null) 'capture_key': captureKey,
      if (deviceId != null) 'device_id': deviceId,
      if (sequenceNo != null) 'sequence_no': sequenceNo,
      if (capturedAtUtc != null) 'captured_at_utc': capturedAtUtc,
      if (receivedAtUtc != null) 'received_at_utc': receivedAtUtc,
      if (tripId != null) 'trip_id': tripId,
      if (linkedEventId != null) 'linked_event_id': linkedEventId,
      if (filePath != null) 'file_path': filePath,
      if (mimeType != null) 'mime_type': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (byteLength != null) 'byte_length': byteLength,
      if (sha256 != null) 'sha256': sha256,
      if (trigger != null) 'trigger': trigger,
    });
  }

  CameraCapturesCompanion copyWith({
    Value<int>? id,
    Value<String>? captureKey,
    Value<String>? deviceId,
    Value<int>? sequenceNo,
    Value<DateTime>? capturedAtUtc,
    Value<DateTime>? receivedAtUtc,
    Value<int?>? tripId,
    Value<int?>? linkedEventId,
    Value<String>? filePath,
    Value<String>? mimeType,
    Value<int>? width,
    Value<int>? height,
    Value<int>? byteLength,
    Value<String>? sha256,
    Value<String>? trigger,
  }) {
    return CameraCapturesCompanion(
      id: id ?? this.id,
      captureKey: captureKey ?? this.captureKey,
      deviceId: deviceId ?? this.deviceId,
      sequenceNo: sequenceNo ?? this.sequenceNo,
      capturedAtUtc: capturedAtUtc ?? this.capturedAtUtc,
      receivedAtUtc: receivedAtUtc ?? this.receivedAtUtc,
      tripId: tripId ?? this.tripId,
      linkedEventId: linkedEventId ?? this.linkedEventId,
      filePath: filePath ?? this.filePath,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      byteLength: byteLength ?? this.byteLength,
      sha256: sha256 ?? this.sha256,
      trigger: trigger ?? this.trigger,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (captureKey.present) {
      map['capture_key'] = Variable<String>(captureKey.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (sequenceNo.present) {
      map['sequence_no'] = Variable<int>(sequenceNo.value);
    }
    if (capturedAtUtc.present) {
      map['captured_at_utc'] = Variable<DateTime>(capturedAtUtc.value);
    }
    if (receivedAtUtc.present) {
      map['received_at_utc'] = Variable<DateTime>(receivedAtUtc.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (linkedEventId.present) {
      map['linked_event_id'] = Variable<int>(linkedEventId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (byteLength.present) {
      map['byte_length'] = Variable<int>(byteLength.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CameraCapturesCompanion(')
          ..write('id: $id, ')
          ..write('captureKey: $captureKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('sequenceNo: $sequenceNo, ')
          ..write('capturedAtUtc: $capturedAtUtc, ')
          ..write('receivedAtUtc: $receivedAtUtc, ')
          ..write('tripId: $tripId, ')
          ..write('linkedEventId: $linkedEventId, ')
          ..write('filePath: $filePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('byteLength: $byteLength, ')
          ..write('sha256: $sha256, ')
          ..write('trigger: $trigger')
          ..write(')'))
        .toString();
  }
}

class $LiveEventReviewsTable extends LiveEventReviews
    with TableInfo<$LiveEventReviewsTable, LiveEventReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiveEventReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedAtUtcMeta = const VerificationMeta(
    'detectedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAtUtc =
      GeneratedColumn<DateTime>(
        'detected_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensorFeaturesJsonMeta =
      const VerificationMeta('sensorFeaturesJson');
  @override
  late final GeneratedColumn<String> sensorFeaturesJson =
      GeneratedColumn<String>(
        'sensor_features_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _confirmationReplyMeta = const VerificationMeta(
    'confirmationReply',
  );
  @override
  late final GeneratedColumn<String> confirmationReply =
      GeneratedColumn<String>(
        'confirmation_reply',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _confirmedMeta = const VerificationMeta(
    'confirmed',
  );
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
    'confirmed',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _feedbackMeta = const VerificationMeta(
    'feedback',
  );
  @override
  late final GeneratedColumn<String> feedback = GeneratedColumn<String>(
    'feedback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _roadEventIdMeta = const VerificationMeta(
    'roadEventId',
  );
  @override
  late final GeneratedColumn<int> roadEventId = GeneratedColumn<int>(
    'road_event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    eventId,
    eventType,
    detectedAtUtc,
    latitude,
    longitude,
    confidence,
    sensorFeaturesJson,
    confirmationReply,
    confirmed,
    feedback,
    reviewStatus,
    roadEventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'live_event_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<LiveEventReview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('detected_at_utc')) {
      context.handle(
        _detectedAtUtcMeta,
        detectedAtUtc.isAcceptableOrUnknown(
          data['detected_at_utc']!,
          _detectedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectedAtUtcMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('sensor_features_json')) {
      context.handle(
        _sensorFeaturesJsonMeta,
        sensorFeaturesJson.isAcceptableOrUnknown(
          data['sensor_features_json']!,
          _sensorFeaturesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sensorFeaturesJsonMeta);
    }
    if (data.containsKey('confirmation_reply')) {
      context.handle(
        _confirmationReplyMeta,
        confirmationReply.isAcceptableOrUnknown(
          data['confirmation_reply']!,
          _confirmationReplyMeta,
        ),
      );
    }
    if (data.containsKey('confirmed')) {
      context.handle(
        _confirmedMeta,
        confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta),
      );
    }
    if (data.containsKey('feedback')) {
      context.handle(
        _feedbackMeta,
        feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta),
      );
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    }
    if (data.containsKey('road_event_id')) {
      context.handle(
        _roadEventIdMeta,
        roadEventId.isAcceptableOrUnknown(
          data['road_event_id']!,
          _roadEventIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LiveEventReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiveEventReview(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      detectedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at_utc'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      sensorFeaturesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sensor_features_json'],
      )!,
      confirmationReply: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confirmation_reply'],
      ),
      confirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed'],
      ),
      feedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback'],
      ),
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      roadEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}road_event_id'],
      ),
    );
  }

  @override
  $LiveEventReviewsTable createAlias(String alias) {
    return $LiveEventReviewsTable(attachedDatabase, alias);
  }
}

class LiveEventReview extends DataClass implements Insertable<LiveEventReview> {
  final int id;
  final int tripId;
  final int? eventId;
  final String eventType;
  final DateTime detectedAtUtc;
  final double? latitude;
  final double? longitude;
  final double confidence;
  final String sensorFeaturesJson;
  final String? confirmationReply;
  final bool? confirmed;
  final String? feedback;

  /// pending | saved | discarded
  final String reviewStatus;
  final int? roadEventId;
  const LiveEventReview({
    required this.id,
    required this.tripId,
    this.eventId,
    required this.eventType,
    required this.detectedAtUtc,
    this.latitude,
    this.longitude,
    required this.confidence,
    required this.sensorFeaturesJson,
    this.confirmationReply,
    this.confirmed,
    this.feedback,
    required this.reviewStatus,
    this.roadEventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trip_id'] = Variable<int>(tripId);
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<int>(eventId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['confidence'] = Variable<double>(confidence);
    map['sensor_features_json'] = Variable<String>(sensorFeaturesJson);
    if (!nullToAbsent || confirmationReply != null) {
      map['confirmation_reply'] = Variable<String>(confirmationReply);
    }
    if (!nullToAbsent || confirmed != null) {
      map['confirmed'] = Variable<bool>(confirmed);
    }
    if (!nullToAbsent || feedback != null) {
      map['feedback'] = Variable<String>(feedback);
    }
    map['review_status'] = Variable<String>(reviewStatus);
    if (!nullToAbsent || roadEventId != null) {
      map['road_event_id'] = Variable<int>(roadEventId);
    }
    return map;
  }

  LiveEventReviewsCompanion toCompanion(bool nullToAbsent) {
    return LiveEventReviewsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      eventType: Value(eventType),
      detectedAtUtc: Value(detectedAtUtc),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      confidence: Value(confidence),
      sensorFeaturesJson: Value(sensorFeaturesJson),
      confirmationReply: confirmationReply == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmationReply),
      confirmed: confirmed == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmed),
      feedback: feedback == null && nullToAbsent
          ? const Value.absent()
          : Value(feedback),
      reviewStatus: Value(reviewStatus),
      roadEventId: roadEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(roadEventId),
    );
  }

  factory LiveEventReview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiveEventReview(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<int>(json['tripId']),
      eventId: serializer.fromJson<int?>(json['eventId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      detectedAtUtc: serializer.fromJson<DateTime>(json['detectedAtUtc']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      confidence: serializer.fromJson<double>(json['confidence']),
      sensorFeaturesJson: serializer.fromJson<String>(
        json['sensorFeaturesJson'],
      ),
      confirmationReply: serializer.fromJson<String?>(
        json['confirmationReply'],
      ),
      confirmed: serializer.fromJson<bool?>(json['confirmed']),
      feedback: serializer.fromJson<String?>(json['feedback']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      roadEventId: serializer.fromJson<int?>(json['roadEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<int>(tripId),
      'eventId': serializer.toJson<int?>(eventId),
      'eventType': serializer.toJson<String>(eventType),
      'detectedAtUtc': serializer.toJson<DateTime>(detectedAtUtc),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'confidence': serializer.toJson<double>(confidence),
      'sensorFeaturesJson': serializer.toJson<String>(sensorFeaturesJson),
      'confirmationReply': serializer.toJson<String?>(confirmationReply),
      'confirmed': serializer.toJson<bool?>(confirmed),
      'feedback': serializer.toJson<String?>(feedback),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'roadEventId': serializer.toJson<int?>(roadEventId),
    };
  }

  LiveEventReview copyWith({
    int? id,
    int? tripId,
    Value<int?> eventId = const Value.absent(),
    String? eventType,
    DateTime? detectedAtUtc,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    double? confidence,
    String? sensorFeaturesJson,
    Value<String?> confirmationReply = const Value.absent(),
    Value<bool?> confirmed = const Value.absent(),
    Value<String?> feedback = const Value.absent(),
    String? reviewStatus,
    Value<int?> roadEventId = const Value.absent(),
  }) => LiveEventReview(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    eventId: eventId.present ? eventId.value : this.eventId,
    eventType: eventType ?? this.eventType,
    detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    confidence: confidence ?? this.confidence,
    sensorFeaturesJson: sensorFeaturesJson ?? this.sensorFeaturesJson,
    confirmationReply: confirmationReply.present
        ? confirmationReply.value
        : this.confirmationReply,
    confirmed: confirmed.present ? confirmed.value : this.confirmed,
    feedback: feedback.present ? feedback.value : this.feedback,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    roadEventId: roadEventId.present ? roadEventId.value : this.roadEventId,
  );
  LiveEventReview copyWithCompanion(LiveEventReviewsCompanion data) {
    return LiveEventReview(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      detectedAtUtc: data.detectedAtUtc.present
          ? data.detectedAtUtc.value
          : this.detectedAtUtc,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      sensorFeaturesJson: data.sensorFeaturesJson.present
          ? data.sensorFeaturesJson.value
          : this.sensorFeaturesJson,
      confirmationReply: data.confirmationReply.present
          ? data.confirmationReply.value
          : this.confirmationReply,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      roadEventId: data.roadEventId.present
          ? data.roadEventId.value
          : this.roadEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiveEventReview(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('confidence: $confidence, ')
          ..write('sensorFeaturesJson: $sensorFeaturesJson, ')
          ..write('confirmationReply: $confirmationReply, ')
          ..write('confirmed: $confirmed, ')
          ..write('feedback: $feedback, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('roadEventId: $roadEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    eventId,
    eventType,
    detectedAtUtc,
    latitude,
    longitude,
    confidence,
    sensorFeaturesJson,
    confirmationReply,
    confirmed,
    feedback,
    reviewStatus,
    roadEventId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiveEventReview &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.eventId == this.eventId &&
          other.eventType == this.eventType &&
          other.detectedAtUtc == this.detectedAtUtc &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.confidence == this.confidence &&
          other.sensorFeaturesJson == this.sensorFeaturesJson &&
          other.confirmationReply == this.confirmationReply &&
          other.confirmed == this.confirmed &&
          other.feedback == this.feedback &&
          other.reviewStatus == this.reviewStatus &&
          other.roadEventId == this.roadEventId);
}

class LiveEventReviewsCompanion extends UpdateCompanion<LiveEventReview> {
  final Value<int> id;
  final Value<int> tripId;
  final Value<int?> eventId;
  final Value<String> eventType;
  final Value<DateTime> detectedAtUtc;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double> confidence;
  final Value<String> sensorFeaturesJson;
  final Value<String?> confirmationReply;
  final Value<bool?> confirmed;
  final Value<String?> feedback;
  final Value<String> reviewStatus;
  final Value<int?> roadEventId;
  const LiveEventReviewsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.detectedAtUtc = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.confidence = const Value.absent(),
    this.sensorFeaturesJson = const Value.absent(),
    this.confirmationReply = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.feedback = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.roadEventId = const Value.absent(),
  });
  LiveEventReviewsCompanion.insert({
    this.id = const Value.absent(),
    required int tripId,
    this.eventId = const Value.absent(),
    required String eventType,
    required DateTime detectedAtUtc,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required double confidence,
    required String sensorFeaturesJson,
    this.confirmationReply = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.feedback = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.roadEventId = const Value.absent(),
  }) : tripId = Value(tripId),
       eventType = Value(eventType),
       detectedAtUtc = Value(detectedAtUtc),
       confidence = Value(confidence),
       sensorFeaturesJson = Value(sensorFeaturesJson);
  static Insertable<LiveEventReview> custom({
    Expression<int>? id,
    Expression<int>? tripId,
    Expression<int>? eventId,
    Expression<String>? eventType,
    Expression<DateTime>? detectedAtUtc,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? confidence,
    Expression<String>? sensorFeaturesJson,
    Expression<String>? confirmationReply,
    Expression<bool>? confirmed,
    Expression<String>? feedback,
    Expression<String>? reviewStatus,
    Expression<int>? roadEventId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (eventId != null) 'event_id': eventId,
      if (eventType != null) 'event_type': eventType,
      if (detectedAtUtc != null) 'detected_at_utc': detectedAtUtc,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (confidence != null) 'confidence': confidence,
      if (sensorFeaturesJson != null)
        'sensor_features_json': sensorFeaturesJson,
      if (confirmationReply != null) 'confirmation_reply': confirmationReply,
      if (confirmed != null) 'confirmed': confirmed,
      if (feedback != null) 'feedback': feedback,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (roadEventId != null) 'road_event_id': roadEventId,
    });
  }

  LiveEventReviewsCompanion copyWith({
    Value<int>? id,
    Value<int>? tripId,
    Value<int?>? eventId,
    Value<String>? eventType,
    Value<DateTime>? detectedAtUtc,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double>? confidence,
    Value<String>? sensorFeaturesJson,
    Value<String?>? confirmationReply,
    Value<bool?>? confirmed,
    Value<String?>? feedback,
    Value<String>? reviewStatus,
    Value<int?>? roadEventId,
  }) {
    return LiveEventReviewsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      confidence: confidence ?? this.confidence,
      sensorFeaturesJson: sensorFeaturesJson ?? this.sensorFeaturesJson,
      confirmationReply: confirmationReply ?? this.confirmationReply,
      confirmed: confirmed ?? this.confirmed,
      feedback: feedback ?? this.feedback,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      roadEventId: roadEventId ?? this.roadEventId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (detectedAtUtc.present) {
      map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (sensorFeaturesJson.present) {
      map['sensor_features_json'] = Variable<String>(sensorFeaturesJson.value);
    }
    if (confirmationReply.present) {
      map['confirmation_reply'] = Variable<String>(confirmationReply.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(feedback.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (roadEventId.present) {
      map['road_event_id'] = Variable<int>(roadEventId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiveEventReviewsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('confidence: $confidence, ')
          ..write('sensorFeaturesJson: $sensorFeaturesJson, ')
          ..write('confirmationReply: $confirmationReply, ')
          ..write('confirmed: $confirmed, ')
          ..write('feedback: $feedback, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('roadEventId: $roadEventId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SensorReadingsTable sensorReadings = $SensorReadingsTable(this);
  late final $EventRecordsTable eventRecords = $EventRecordsTable(this);
  late final $CameraDetectionsTable cameraDetections = $CameraDetectionsTable(
    this,
  );
  late final $TripsTable trips = $TripsTable(this);
  late final $LocationReadingsTable locationReadings = $LocationReadingsTable(
    this,
  );
  late final $TripCalibrationsTable tripCalibrations = $TripCalibrationsTable(
    this,
  );
  late final $RoadEventsTable roadEvents = $RoadEventsTable(this);
  late final $PreAlertsTable preAlerts = $PreAlertsTable(this);
  late final $EventFeedbacksTable eventFeedbacks = $EventFeedbacksTable(this);
  late final $UnknownEventsTable unknownEvents = $UnknownEventsTable(this);
  late final $CameraCapturesTable cameraCaptures = $CameraCapturesTable(this);
  late final $LiveEventReviewsTable liveEventReviews = $LiveEventReviewsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sensorReadings,
    eventRecords,
    cameraDetections,
    trips,
    locationReadings,
    tripCalibrations,
    roadEvents,
    preAlerts,
    eventFeedbacks,
    unknownEvents,
    cameraCaptures,
    liveEventReviews,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$SensorReadingsTableCreateCompanionBuilder =
    SensorReadingsCompanion Function({
      Value<int> id,
      required String deviceId,
      required String deviceType,
      required int sequenceNo,
      required DateTime timestampUtc,
      required String sensorType,
      Value<String> mountLocation,
      Value<int?> eventId,
      Value<int?> tripId,
      Value<int?> heartRate,
      Value<double?> accelX,
      Value<double?> accelY,
      Value<double?> accelZ,
      Value<double?> gyroX,
      Value<double?> gyroY,
      Value<double?> gyroZ,
      Value<int?> ppiMs,
      Value<double?> gpsSpeedKmh,
      Value<double?> linearAccelX,
      Value<double?> linearAccelY,
      Value<double?> linearAccelZ,
      Value<double?> quatW,
      Value<double?> quatX,
      Value<double?> quatY,
      Value<double?> quatZ,
      Value<int?> timestampMonotonicMicros,
      Value<double?> barometerAltitudeM,
      Value<String?> rawPayload,
    });
typedef $$SensorReadingsTableUpdateCompanionBuilder =
    SensorReadingsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<String> deviceType,
      Value<int> sequenceNo,
      Value<DateTime> timestampUtc,
      Value<String> sensorType,
      Value<String> mountLocation,
      Value<int?> eventId,
      Value<int?> tripId,
      Value<int?> heartRate,
      Value<double?> accelX,
      Value<double?> accelY,
      Value<double?> accelZ,
      Value<double?> gyroX,
      Value<double?> gyroY,
      Value<double?> gyroZ,
      Value<int?> ppiMs,
      Value<double?> gpsSpeedKmh,
      Value<double?> linearAccelX,
      Value<double?> linearAccelY,
      Value<double?> linearAccelZ,
      Value<double?> quatW,
      Value<double?> quatX,
      Value<double?> quatY,
      Value<double?> quatZ,
      Value<int?> timestampMonotonicMicros,
      Value<double?> barometerAltitudeM,
      Value<String?> rawPayload,
    });

class $$SensorReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNo => $composableBuilder(
    column: $table.sequenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sensorType => $composableBuilder(
    column: $table.sensorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mountLocation => $composableBuilder(
    column: $table.mountLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelX => $composableBuilder(
    column: $table.accelX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelY => $composableBuilder(
    column: $table.accelY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelZ => $composableBuilder(
    column: $table.accelZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroX => $composableBuilder(
    column: $table.gyroX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroY => $composableBuilder(
    column: $table.gyroY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroZ => $composableBuilder(
    column: $table.gyroZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ppiMs => $composableBuilder(
    column: $table.ppiMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsSpeedKmh => $composableBuilder(
    column: $table.gpsSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get linearAccelX => $composableBuilder(
    column: $table.linearAccelX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get linearAccelY => $composableBuilder(
    column: $table.linearAccelY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get linearAccelZ => $composableBuilder(
    column: $table.linearAccelZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quatW => $composableBuilder(
    column: $table.quatW,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quatX => $composableBuilder(
    column: $table.quatX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quatY => $composableBuilder(
    column: $table.quatY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quatZ => $composableBuilder(
    column: $table.quatZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMonotonicMicros => $composableBuilder(
    column: $table.timestampMonotonicMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get barometerAltitudeM => $composableBuilder(
    column: $table.barometerAltitudeM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SensorReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNo => $composableBuilder(
    column: $table.sequenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensorType => $composableBuilder(
    column: $table.sensorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mountLocation => $composableBuilder(
    column: $table.mountLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelX => $composableBuilder(
    column: $table.accelX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelY => $composableBuilder(
    column: $table.accelY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelZ => $composableBuilder(
    column: $table.accelZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroX => $composableBuilder(
    column: $table.gyroX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroY => $composableBuilder(
    column: $table.gyroY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroZ => $composableBuilder(
    column: $table.gyroZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ppiMs => $composableBuilder(
    column: $table.ppiMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsSpeedKmh => $composableBuilder(
    column: $table.gpsSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get linearAccelX => $composableBuilder(
    column: $table.linearAccelX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get linearAccelY => $composableBuilder(
    column: $table.linearAccelY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get linearAccelZ => $composableBuilder(
    column: $table.linearAccelZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quatW => $composableBuilder(
    column: $table.quatW,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quatX => $composableBuilder(
    column: $table.quatX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quatY => $composableBuilder(
    column: $table.quatY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quatZ => $composableBuilder(
    column: $table.quatZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMonotonicMicros => $composableBuilder(
    column: $table.timestampMonotonicMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get barometerAltitudeM => $composableBuilder(
    column: $table.barometerAltitudeM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SensorReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequenceNo => $composableBuilder(
    column: $table.sequenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sensorType => $composableBuilder(
    column: $table.sensorType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mountLocation => $composableBuilder(
    column: $table.mountLocation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<int> get heartRate =>
      $composableBuilder(column: $table.heartRate, builder: (column) => column);

  GeneratedColumn<double> get accelX =>
      $composableBuilder(column: $table.accelX, builder: (column) => column);

  GeneratedColumn<double> get accelY =>
      $composableBuilder(column: $table.accelY, builder: (column) => column);

  GeneratedColumn<double> get accelZ =>
      $composableBuilder(column: $table.accelZ, builder: (column) => column);

  GeneratedColumn<double> get gyroX =>
      $composableBuilder(column: $table.gyroX, builder: (column) => column);

  GeneratedColumn<double> get gyroY =>
      $composableBuilder(column: $table.gyroY, builder: (column) => column);

  GeneratedColumn<double> get gyroZ =>
      $composableBuilder(column: $table.gyroZ, builder: (column) => column);

  GeneratedColumn<int> get ppiMs =>
      $composableBuilder(column: $table.ppiMs, builder: (column) => column);

  GeneratedColumn<double> get gpsSpeedKmh => $composableBuilder(
    column: $table.gpsSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get linearAccelX => $composableBuilder(
    column: $table.linearAccelX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get linearAccelY => $composableBuilder(
    column: $table.linearAccelY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get linearAccelZ => $composableBuilder(
    column: $table.linearAccelZ,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quatW =>
      $composableBuilder(column: $table.quatW, builder: (column) => column);

  GeneratedColumn<double> get quatX =>
      $composableBuilder(column: $table.quatX, builder: (column) => column);

  GeneratedColumn<double> get quatY =>
      $composableBuilder(column: $table.quatY, builder: (column) => column);

  GeneratedColumn<double> get quatZ =>
      $composableBuilder(column: $table.quatZ, builder: (column) => column);

  GeneratedColumn<int> get timestampMonotonicMicros => $composableBuilder(
    column: $table.timestampMonotonicMicros,
    builder: (column) => column,
  );

  GeneratedColumn<double> get barometerAltitudeM => $composableBuilder(
    column: $table.barometerAltitudeM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => column,
  );
}

class $$SensorReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorReadingsTable,
          SensorReading,
          $$SensorReadingsTableFilterComposer,
          $$SensorReadingsTableOrderingComposer,
          $$SensorReadingsTableAnnotationComposer,
          $$SensorReadingsTableCreateCompanionBuilder,
          $$SensorReadingsTableUpdateCompanionBuilder,
          (
            SensorReading,
            BaseReferences<_$AppDatabase, $SensorReadingsTable, SensorReading>,
          ),
          SensorReading,
          PrefetchHooks Function()
        > {
  $$SensorReadingsTableTableManager(
    _$AppDatabase db,
    $SensorReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SensorReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SensorReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SensorReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> deviceType = const Value.absent(),
                Value<int> sequenceNo = const Value.absent(),
                Value<DateTime> timestampUtc = const Value.absent(),
                Value<String> sensorType = const Value.absent(),
                Value<String> mountLocation = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<double?> accelX = const Value.absent(),
                Value<double?> accelY = const Value.absent(),
                Value<double?> accelZ = const Value.absent(),
                Value<double?> gyroX = const Value.absent(),
                Value<double?> gyroY = const Value.absent(),
                Value<double?> gyroZ = const Value.absent(),
                Value<int?> ppiMs = const Value.absent(),
                Value<double?> gpsSpeedKmh = const Value.absent(),
                Value<double?> linearAccelX = const Value.absent(),
                Value<double?> linearAccelY = const Value.absent(),
                Value<double?> linearAccelZ = const Value.absent(),
                Value<double?> quatW = const Value.absent(),
                Value<double?> quatX = const Value.absent(),
                Value<double?> quatY = const Value.absent(),
                Value<double?> quatZ = const Value.absent(),
                Value<int?> timestampMonotonicMicros = const Value.absent(),
                Value<double?> barometerAltitudeM = const Value.absent(),
                Value<String?> rawPayload = const Value.absent(),
              }) => SensorReadingsCompanion(
                id: id,
                deviceId: deviceId,
                deviceType: deviceType,
                sequenceNo: sequenceNo,
                timestampUtc: timestampUtc,
                sensorType: sensorType,
                mountLocation: mountLocation,
                eventId: eventId,
                tripId: tripId,
                heartRate: heartRate,
                accelX: accelX,
                accelY: accelY,
                accelZ: accelZ,
                gyroX: gyroX,
                gyroY: gyroY,
                gyroZ: gyroZ,
                ppiMs: ppiMs,
                gpsSpeedKmh: gpsSpeedKmh,
                linearAccelX: linearAccelX,
                linearAccelY: linearAccelY,
                linearAccelZ: linearAccelZ,
                quatW: quatW,
                quatX: quatX,
                quatY: quatY,
                quatZ: quatZ,
                timestampMonotonicMicros: timestampMonotonicMicros,
                barometerAltitudeM: barometerAltitudeM,
                rawPayload: rawPayload,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required String deviceType,
                required int sequenceNo,
                required DateTime timestampUtc,
                required String sensorType,
                Value<String> mountLocation = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<double?> accelX = const Value.absent(),
                Value<double?> accelY = const Value.absent(),
                Value<double?> accelZ = const Value.absent(),
                Value<double?> gyroX = const Value.absent(),
                Value<double?> gyroY = const Value.absent(),
                Value<double?> gyroZ = const Value.absent(),
                Value<int?> ppiMs = const Value.absent(),
                Value<double?> gpsSpeedKmh = const Value.absent(),
                Value<double?> linearAccelX = const Value.absent(),
                Value<double?> linearAccelY = const Value.absent(),
                Value<double?> linearAccelZ = const Value.absent(),
                Value<double?> quatW = const Value.absent(),
                Value<double?> quatX = const Value.absent(),
                Value<double?> quatY = const Value.absent(),
                Value<double?> quatZ = const Value.absent(),
                Value<int?> timestampMonotonicMicros = const Value.absent(),
                Value<double?> barometerAltitudeM = const Value.absent(),
                Value<String?> rawPayload = const Value.absent(),
              }) => SensorReadingsCompanion.insert(
                id: id,
                deviceId: deviceId,
                deviceType: deviceType,
                sequenceNo: sequenceNo,
                timestampUtc: timestampUtc,
                sensorType: sensorType,
                mountLocation: mountLocation,
                eventId: eventId,
                tripId: tripId,
                heartRate: heartRate,
                accelX: accelX,
                accelY: accelY,
                accelZ: accelZ,
                gyroX: gyroX,
                gyroY: gyroY,
                gyroZ: gyroZ,
                ppiMs: ppiMs,
                gpsSpeedKmh: gpsSpeedKmh,
                linearAccelX: linearAccelX,
                linearAccelY: linearAccelY,
                linearAccelZ: linearAccelZ,
                quatW: quatW,
                quatX: quatX,
                quatY: quatY,
                quatZ: quatZ,
                timestampMonotonicMicros: timestampMonotonicMicros,
                barometerAltitudeM: barometerAltitudeM,
                rawPayload: rawPayload,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SensorReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorReadingsTable,
      SensorReading,
      $$SensorReadingsTableFilterComposer,
      $$SensorReadingsTableOrderingComposer,
      $$SensorReadingsTableAnnotationComposer,
      $$SensorReadingsTableCreateCompanionBuilder,
      $$SensorReadingsTableUpdateCompanionBuilder,
      (
        SensorReading,
        BaseReferences<_$AppDatabase, $SensorReadingsTable, SensorReading>,
      ),
      SensorReading,
      PrefetchHooks Function()
    >;
typedef $$EventRecordsTableCreateCompanionBuilder =
    EventRecordsCompanion Function({
      Value<int> id,
      required String eventType,
      required DateTime startTimestamp,
      Value<DateTime?> endTimestamp,
      Value<double?> startGpsLat,
      Value<double?> startGpsLng,
      Value<double?> endGpsLat,
      Value<double?> endGpsLng,
      required String status,
      Value<String?> triggerPhrase,
      Value<String?> computedParameters,
      Value<double?> peakMetric,
      Value<String?> classification,
      Value<int?> tripId,
      Value<bool> crossConfirmed,
      Value<double?> forkFootLagMs,
      Value<bool> hrSpikeConfirmed,
      Value<double?> hrDeltaAtEvent,
      Value<double?> jerkPeakMagnitude,
      Value<double?> gpsSpeedAtEventKmh,
      Value<double?> gpsHeadingChangeDeg,
      Value<String?> audioFilePath,
    });
typedef $$EventRecordsTableUpdateCompanionBuilder =
    EventRecordsCompanion Function({
      Value<int> id,
      Value<String> eventType,
      Value<DateTime> startTimestamp,
      Value<DateTime?> endTimestamp,
      Value<double?> startGpsLat,
      Value<double?> startGpsLng,
      Value<double?> endGpsLat,
      Value<double?> endGpsLng,
      Value<String> status,
      Value<String?> triggerPhrase,
      Value<String?> computedParameters,
      Value<double?> peakMetric,
      Value<String?> classification,
      Value<int?> tripId,
      Value<bool> crossConfirmed,
      Value<double?> forkFootLagMs,
      Value<bool> hrSpikeConfirmed,
      Value<double?> hrDeltaAtEvent,
      Value<double?> jerkPeakMagnitude,
      Value<double?> gpsSpeedAtEventKmh,
      Value<double?> gpsHeadingChangeDeg,
      Value<String?> audioFilePath,
    });

class $$EventRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $EventRecordsTable> {
  $$EventRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTimestamp => $composableBuilder(
    column: $table.startTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTimestamp => $composableBuilder(
    column: $table.endTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startGpsLat => $composableBuilder(
    column: $table.startGpsLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startGpsLng => $composableBuilder(
    column: $table.startGpsLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endGpsLat => $composableBuilder(
    column: $table.endGpsLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endGpsLng => $composableBuilder(
    column: $table.endGpsLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerPhrase => $composableBuilder(
    column: $table.triggerPhrase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get computedParameters => $composableBuilder(
    column: $table.computedParameters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakMetric => $composableBuilder(
    column: $table.peakMetric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get crossConfirmed => $composableBuilder(
    column: $table.crossConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get forkFootLagMs => $composableBuilder(
    column: $table.forkFootLagMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hrSpikeConfirmed => $composableBuilder(
    column: $table.hrSpikeConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrDeltaAtEvent => $composableBuilder(
    column: $table.hrDeltaAtEvent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get jerkPeakMagnitude => $composableBuilder(
    column: $table.jerkPeakMagnitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsSpeedAtEventKmh => $composableBuilder(
    column: $table.gpsSpeedAtEventKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsHeadingChangeDeg => $composableBuilder(
    column: $table.gpsHeadingChangeDeg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventRecordsTable> {
  $$EventRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTimestamp => $composableBuilder(
    column: $table.startTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTimestamp => $composableBuilder(
    column: $table.endTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startGpsLat => $composableBuilder(
    column: $table.startGpsLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startGpsLng => $composableBuilder(
    column: $table.startGpsLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endGpsLat => $composableBuilder(
    column: $table.endGpsLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endGpsLng => $composableBuilder(
    column: $table.endGpsLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerPhrase => $composableBuilder(
    column: $table.triggerPhrase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get computedParameters => $composableBuilder(
    column: $table.computedParameters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakMetric => $composableBuilder(
    column: $table.peakMetric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get crossConfirmed => $composableBuilder(
    column: $table.crossConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get forkFootLagMs => $composableBuilder(
    column: $table.forkFootLagMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hrSpikeConfirmed => $composableBuilder(
    column: $table.hrSpikeConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrDeltaAtEvent => $composableBuilder(
    column: $table.hrDeltaAtEvent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get jerkPeakMagnitude => $composableBuilder(
    column: $table.jerkPeakMagnitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsSpeedAtEventKmh => $composableBuilder(
    column: $table.gpsSpeedAtEventKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsHeadingChangeDeg => $composableBuilder(
    column: $table.gpsHeadingChangeDeg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventRecordsTable> {
  $$EventRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get startTimestamp => $composableBuilder(
    column: $table.startTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endTimestamp => $composableBuilder(
    column: $table.endTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startGpsLat => $composableBuilder(
    column: $table.startGpsLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startGpsLng => $composableBuilder(
    column: $table.startGpsLng,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endGpsLat =>
      $composableBuilder(column: $table.endGpsLat, builder: (column) => column);

  GeneratedColumn<double> get endGpsLng =>
      $composableBuilder(column: $table.endGpsLng, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get triggerPhrase => $composableBuilder(
    column: $table.triggerPhrase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get computedParameters => $composableBuilder(
    column: $table.computedParameters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakMetric => $composableBuilder(
    column: $table.peakMetric,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<bool> get crossConfirmed => $composableBuilder(
    column: $table.crossConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<double> get forkFootLagMs => $composableBuilder(
    column: $table.forkFootLagMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hrSpikeConfirmed => $composableBuilder(
    column: $table.hrSpikeConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrDeltaAtEvent => $composableBuilder(
    column: $table.hrDeltaAtEvent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get jerkPeakMagnitude => $composableBuilder(
    column: $table.jerkPeakMagnitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsSpeedAtEventKmh => $composableBuilder(
    column: $table.gpsSpeedAtEventKmh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsHeadingChangeDeg => $composableBuilder(
    column: $table.gpsHeadingChangeDeg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => column,
  );
}

class $$EventRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventRecordsTable,
          EventRecord,
          $$EventRecordsTableFilterComposer,
          $$EventRecordsTableOrderingComposer,
          $$EventRecordsTableAnnotationComposer,
          $$EventRecordsTableCreateCompanionBuilder,
          $$EventRecordsTableUpdateCompanionBuilder,
          (
            EventRecord,
            BaseReferences<_$AppDatabase, $EventRecordsTable, EventRecord>,
          ),
          EventRecord,
          PrefetchHooks Function()
        > {
  $$EventRecordsTableTableManager(_$AppDatabase db, $EventRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> startTimestamp = const Value.absent(),
                Value<DateTime?> endTimestamp = const Value.absent(),
                Value<double?> startGpsLat = const Value.absent(),
                Value<double?> startGpsLng = const Value.absent(),
                Value<double?> endGpsLat = const Value.absent(),
                Value<double?> endGpsLng = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> triggerPhrase = const Value.absent(),
                Value<String?> computedParameters = const Value.absent(),
                Value<double?> peakMetric = const Value.absent(),
                Value<String?> classification = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<bool> crossConfirmed = const Value.absent(),
                Value<double?> forkFootLagMs = const Value.absent(),
                Value<bool> hrSpikeConfirmed = const Value.absent(),
                Value<double?> hrDeltaAtEvent = const Value.absent(),
                Value<double?> jerkPeakMagnitude = const Value.absent(),
                Value<double?> gpsSpeedAtEventKmh = const Value.absent(),
                Value<double?> gpsHeadingChangeDeg = const Value.absent(),
                Value<String?> audioFilePath = const Value.absent(),
              }) => EventRecordsCompanion(
                id: id,
                eventType: eventType,
                startTimestamp: startTimestamp,
                endTimestamp: endTimestamp,
                startGpsLat: startGpsLat,
                startGpsLng: startGpsLng,
                endGpsLat: endGpsLat,
                endGpsLng: endGpsLng,
                status: status,
                triggerPhrase: triggerPhrase,
                computedParameters: computedParameters,
                peakMetric: peakMetric,
                classification: classification,
                tripId: tripId,
                crossConfirmed: crossConfirmed,
                forkFootLagMs: forkFootLagMs,
                hrSpikeConfirmed: hrSpikeConfirmed,
                hrDeltaAtEvent: hrDeltaAtEvent,
                jerkPeakMagnitude: jerkPeakMagnitude,
                gpsSpeedAtEventKmh: gpsSpeedAtEventKmh,
                gpsHeadingChangeDeg: gpsHeadingChangeDeg,
                audioFilePath: audioFilePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String eventType,
                required DateTime startTimestamp,
                Value<DateTime?> endTimestamp = const Value.absent(),
                Value<double?> startGpsLat = const Value.absent(),
                Value<double?> startGpsLng = const Value.absent(),
                Value<double?> endGpsLat = const Value.absent(),
                Value<double?> endGpsLng = const Value.absent(),
                required String status,
                Value<String?> triggerPhrase = const Value.absent(),
                Value<String?> computedParameters = const Value.absent(),
                Value<double?> peakMetric = const Value.absent(),
                Value<String?> classification = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<bool> crossConfirmed = const Value.absent(),
                Value<double?> forkFootLagMs = const Value.absent(),
                Value<bool> hrSpikeConfirmed = const Value.absent(),
                Value<double?> hrDeltaAtEvent = const Value.absent(),
                Value<double?> jerkPeakMagnitude = const Value.absent(),
                Value<double?> gpsSpeedAtEventKmh = const Value.absent(),
                Value<double?> gpsHeadingChangeDeg = const Value.absent(),
                Value<String?> audioFilePath = const Value.absent(),
              }) => EventRecordsCompanion.insert(
                id: id,
                eventType: eventType,
                startTimestamp: startTimestamp,
                endTimestamp: endTimestamp,
                startGpsLat: startGpsLat,
                startGpsLng: startGpsLng,
                endGpsLat: endGpsLat,
                endGpsLng: endGpsLng,
                status: status,
                triggerPhrase: triggerPhrase,
                computedParameters: computedParameters,
                peakMetric: peakMetric,
                classification: classification,
                tripId: tripId,
                crossConfirmed: crossConfirmed,
                forkFootLagMs: forkFootLagMs,
                hrSpikeConfirmed: hrSpikeConfirmed,
                hrDeltaAtEvent: hrDeltaAtEvent,
                jerkPeakMagnitude: jerkPeakMagnitude,
                gpsSpeedAtEventKmh: gpsSpeedAtEventKmh,
                gpsHeadingChangeDeg: gpsHeadingChangeDeg,
                audioFilePath: audioFilePath,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventRecordsTable,
      EventRecord,
      $$EventRecordsTableFilterComposer,
      $$EventRecordsTableOrderingComposer,
      $$EventRecordsTableAnnotationComposer,
      $$EventRecordsTableCreateCompanionBuilder,
      $$EventRecordsTableUpdateCompanionBuilder,
      (
        EventRecord,
        BaseReferences<_$AppDatabase, $EventRecordsTable, EventRecord>,
      ),
      EventRecord,
      PrefetchHooks Function()
    >;
typedef $$CameraDetectionsTableCreateCompanionBuilder =
    CameraDetectionsCompanion Function({
      Value<int> id,
      required String deviceId,
      required String eventClass,
      required double confidence,
      required DateTime cameraTimestampUtc,
      required DateTime receivedAtUtc,
      Value<int?> linkedEventId,
    });
typedef $$CameraDetectionsTableUpdateCompanionBuilder =
    CameraDetectionsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<String> eventClass,
      Value<double> confidence,
      Value<DateTime> cameraTimestampUtc,
      Value<DateTime> receivedAtUtc,
      Value<int?> linkedEventId,
    });

class $$CameraDetectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CameraDetectionsTable> {
  $$CameraDetectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventClass => $composableBuilder(
    column: $table.eventClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cameraTimestampUtc => $composableBuilder(
    column: $table.cameraTimestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAtUtc => $composableBuilder(
    column: $table.receivedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedEventId => $composableBuilder(
    column: $table.linkedEventId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CameraDetectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CameraDetectionsTable> {
  $$CameraDetectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventClass => $composableBuilder(
    column: $table.eventClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cameraTimestampUtc => $composableBuilder(
    column: $table.cameraTimestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAtUtc => $composableBuilder(
    column: $table.receivedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedEventId => $composableBuilder(
    column: $table.linkedEventId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CameraDetectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CameraDetectionsTable> {
  $$CameraDetectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get eventClass => $composableBuilder(
    column: $table.eventClass,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cameraTimestampUtc => $composableBuilder(
    column: $table.cameraTimestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAtUtc => $composableBuilder(
    column: $table.receivedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkedEventId => $composableBuilder(
    column: $table.linkedEventId,
    builder: (column) => column,
  );
}

class $$CameraDetectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CameraDetectionsTable,
          CameraDetection,
          $$CameraDetectionsTableFilterComposer,
          $$CameraDetectionsTableOrderingComposer,
          $$CameraDetectionsTableAnnotationComposer,
          $$CameraDetectionsTableCreateCompanionBuilder,
          $$CameraDetectionsTableUpdateCompanionBuilder,
          (
            CameraDetection,
            BaseReferences<
              _$AppDatabase,
              $CameraDetectionsTable,
              CameraDetection
            >,
          ),
          CameraDetection,
          PrefetchHooks Function()
        > {
  $$CameraDetectionsTableTableManager(
    _$AppDatabase db,
    $CameraDetectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CameraDetectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CameraDetectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CameraDetectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> eventClass = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime> cameraTimestampUtc = const Value.absent(),
                Value<DateTime> receivedAtUtc = const Value.absent(),
                Value<int?> linkedEventId = const Value.absent(),
              }) => CameraDetectionsCompanion(
                id: id,
                deviceId: deviceId,
                eventClass: eventClass,
                confidence: confidence,
                cameraTimestampUtc: cameraTimestampUtc,
                receivedAtUtc: receivedAtUtc,
                linkedEventId: linkedEventId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required String eventClass,
                required double confidence,
                required DateTime cameraTimestampUtc,
                required DateTime receivedAtUtc,
                Value<int?> linkedEventId = const Value.absent(),
              }) => CameraDetectionsCompanion.insert(
                id: id,
                deviceId: deviceId,
                eventClass: eventClass,
                confidence: confidence,
                cameraTimestampUtc: cameraTimestampUtc,
                receivedAtUtc: receivedAtUtc,
                linkedEventId: linkedEventId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CameraDetectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CameraDetectionsTable,
      CameraDetection,
      $$CameraDetectionsTableFilterComposer,
      $$CameraDetectionsTableOrderingComposer,
      $$CameraDetectionsTableAnnotationComposer,
      $$CameraDetectionsTableCreateCompanionBuilder,
      $$CameraDetectionsTableUpdateCompanionBuilder,
      (
        CameraDetection,
        BaseReferences<_$AppDatabase, $CameraDetectionsTable, CameraDetection>,
      ),
      CameraDetection,
      PrefetchHooks Function()
    >;
typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      Value<int> id,
      Value<String> riderName,
      Value<String> wristSide,
      required DateTime startTimeUtc,
      Value<DateTime?> endTimeUtc,
      Value<DateTime?> startTimestampUtc,
      Value<DateTime?> endTimestampUtc,
      Value<double?> totalDistanceKm,
      Value<double?> totalDurationMin,
      Value<double?> avgSpeedKmh,
      Value<double?> maxSpeedKmh,
      Value<int> harshBrakeCount,
      Value<int> harshAccelCount,
      Value<int> harshTurnCount,
      Value<int> bumpCount,
      Value<int> confirmedEventCount,
      Value<double?> eventsPerKm,
      Value<double?> avgHr,
      Value<int?> maxHr,
      Value<double?> hrSpikeConfirmedRatio,
      Value<double?> nightDrivingPct,
      Value<double?> driverScore,
      Value<int> durationSeconds,
      Value<double?> startLat,
      Value<double?> startLng,
      Value<double?> endLat,
      Value<double?> endLng,
      Value<double> distanceMeters,
      Value<double?> peakSpeedKmh,
      Value<int> totalSensorRows,
      Value<int> totalEventsCount,
      Value<String?> routeCoordinatesJson,
      Value<String?> notes,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<int> id,
      Value<String> riderName,
      Value<String> wristSide,
      Value<DateTime> startTimeUtc,
      Value<DateTime?> endTimeUtc,
      Value<DateTime?> startTimestampUtc,
      Value<DateTime?> endTimestampUtc,
      Value<double?> totalDistanceKm,
      Value<double?> totalDurationMin,
      Value<double?> avgSpeedKmh,
      Value<double?> maxSpeedKmh,
      Value<int> harshBrakeCount,
      Value<int> harshAccelCount,
      Value<int> harshTurnCount,
      Value<int> bumpCount,
      Value<int> confirmedEventCount,
      Value<double?> eventsPerKm,
      Value<double?> avgHr,
      Value<int?> maxHr,
      Value<double?> hrSpikeConfirmedRatio,
      Value<double?> nightDrivingPct,
      Value<double?> driverScore,
      Value<int> durationSeconds,
      Value<double?> startLat,
      Value<double?> startLng,
      Value<double?> endLat,
      Value<double?> endLng,
      Value<double> distanceMeters,
      Value<double?> peakSpeedKmh,
      Value<int> totalSensorRows,
      Value<int> totalEventsCount,
      Value<String?> routeCoordinatesJson,
      Value<String?> notes,
    });

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riderName => $composableBuilder(
    column: $table.riderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wristSide => $composableBuilder(
    column: $table.wristSide,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTimeUtc => $composableBuilder(
    column: $table.startTimeUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTimeUtc => $composableBuilder(
    column: $table.endTimeUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTimestampUtc => $composableBuilder(
    column: $table.startTimestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTimestampUtc => $composableBuilder(
    column: $table.endTimestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDurationMin => $composableBuilder(
    column: $table.totalDurationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpeedKmh => $composableBuilder(
    column: $table.avgSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxSpeedKmh => $composableBuilder(
    column: $table.maxSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get harshBrakeCount => $composableBuilder(
    column: $table.harshBrakeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get harshAccelCount => $composableBuilder(
    column: $table.harshAccelCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get harshTurnCount => $composableBuilder(
    column: $table.harshTurnCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bumpCount => $composableBuilder(
    column: $table.bumpCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmedEventCount => $composableBuilder(
    column: $table.confirmedEventCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get eventsPerKm => $composableBuilder(
    column: $table.eventsPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgHr => $composableBuilder(
    column: $table.avgHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrSpikeConfirmedRatio => $composableBuilder(
    column: $table.hrSpikeConfirmedRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nightDrivingPct => $composableBuilder(
    column: $table.nightDrivingPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get driverScore => $composableBuilder(
    column: $table.driverScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLat => $composableBuilder(
    column: $table.startLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLng => $composableBuilder(
    column: $table.startLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLat => $composableBuilder(
    column: $table.endLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLng => $composableBuilder(
    column: $table.endLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakSpeedKmh => $composableBuilder(
    column: $table.peakSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSensorRows => $composableBuilder(
    column: $table.totalSensorRows,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalEventsCount => $composableBuilder(
    column: $table.totalEventsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeCoordinatesJson => $composableBuilder(
    column: $table.routeCoordinatesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riderName => $composableBuilder(
    column: $table.riderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wristSide => $composableBuilder(
    column: $table.wristSide,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTimeUtc => $composableBuilder(
    column: $table.startTimeUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTimeUtc => $composableBuilder(
    column: $table.endTimeUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTimestampUtc => $composableBuilder(
    column: $table.startTimestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTimestampUtc => $composableBuilder(
    column: $table.endTimestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDurationMin => $composableBuilder(
    column: $table.totalDurationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpeedKmh => $composableBuilder(
    column: $table.avgSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxSpeedKmh => $composableBuilder(
    column: $table.maxSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get harshBrakeCount => $composableBuilder(
    column: $table.harshBrakeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get harshAccelCount => $composableBuilder(
    column: $table.harshAccelCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get harshTurnCount => $composableBuilder(
    column: $table.harshTurnCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bumpCount => $composableBuilder(
    column: $table.bumpCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedEventCount => $composableBuilder(
    column: $table.confirmedEventCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get eventsPerKm => $composableBuilder(
    column: $table.eventsPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgHr => $composableBuilder(
    column: $table.avgHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrSpikeConfirmedRatio => $composableBuilder(
    column: $table.hrSpikeConfirmedRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nightDrivingPct => $composableBuilder(
    column: $table.nightDrivingPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get driverScore => $composableBuilder(
    column: $table.driverScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLat => $composableBuilder(
    column: $table.startLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLng => $composableBuilder(
    column: $table.startLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLat => $composableBuilder(
    column: $table.endLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLng => $composableBuilder(
    column: $table.endLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakSpeedKmh => $composableBuilder(
    column: $table.peakSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSensorRows => $composableBuilder(
    column: $table.totalSensorRows,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalEventsCount => $composableBuilder(
    column: $table.totalEventsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeCoordinatesJson => $composableBuilder(
    column: $table.routeCoordinatesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get riderName =>
      $composableBuilder(column: $table.riderName, builder: (column) => column);

  GeneratedColumn<String> get wristSide =>
      $composableBuilder(column: $table.wristSide, builder: (column) => column);

  GeneratedColumn<DateTime> get startTimeUtc => $composableBuilder(
    column: $table.startTimeUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endTimeUtc => $composableBuilder(
    column: $table.endTimeUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTimestampUtc => $composableBuilder(
    column: $table.startTimestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endTimestampUtc => $composableBuilder(
    column: $table.endTimestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalDurationMin => $composableBuilder(
    column: $table.totalDurationMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgSpeedKmh => $composableBuilder(
    column: $table.avgSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxSpeedKmh => $composableBuilder(
    column: $table.maxSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get harshBrakeCount => $composableBuilder(
    column: $table.harshBrakeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get harshAccelCount => $composableBuilder(
    column: $table.harshAccelCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get harshTurnCount => $composableBuilder(
    column: $table.harshTurnCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bumpCount =>
      $composableBuilder(column: $table.bumpCount, builder: (column) => column);

  GeneratedColumn<int> get confirmedEventCount => $composableBuilder(
    column: $table.confirmedEventCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get eventsPerKm => $composableBuilder(
    column: $table.eventsPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgHr =>
      $composableBuilder(column: $table.avgHr, builder: (column) => column);

  GeneratedColumn<int> get maxHr =>
      $composableBuilder(column: $table.maxHr, builder: (column) => column);

  GeneratedColumn<double> get hrSpikeConfirmedRatio => $composableBuilder(
    column: $table.hrSpikeConfirmedRatio,
    builder: (column) => column,
  );

  GeneratedColumn<double> get nightDrivingPct => $composableBuilder(
    column: $table.nightDrivingPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get driverScore => $composableBuilder(
    column: $table.driverScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startLat =>
      $composableBuilder(column: $table.startLat, builder: (column) => column);

  GeneratedColumn<double> get startLng =>
      $composableBuilder(column: $table.startLng, builder: (column) => column);

  GeneratedColumn<double> get endLat =>
      $composableBuilder(column: $table.endLat, builder: (column) => column);

  GeneratedColumn<double> get endLng =>
      $composableBuilder(column: $table.endLng, builder: (column) => column);

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakSpeedKmh => $composableBuilder(
    column: $table.peakSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalSensorRows => $composableBuilder(
    column: $table.totalSensorRows,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalEventsCount => $composableBuilder(
    column: $table.totalEventsCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routeCoordinatesJson => $composableBuilder(
    column: $table.routeCoordinatesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          Trip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
          Trip,
          PrefetchHooks Function()
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> riderName = const Value.absent(),
                Value<String> wristSide = const Value.absent(),
                Value<DateTime> startTimeUtc = const Value.absent(),
                Value<DateTime?> endTimeUtc = const Value.absent(),
                Value<DateTime?> startTimestampUtc = const Value.absent(),
                Value<DateTime?> endTimestampUtc = const Value.absent(),
                Value<double?> totalDistanceKm = const Value.absent(),
                Value<double?> totalDurationMin = const Value.absent(),
                Value<double?> avgSpeedKmh = const Value.absent(),
                Value<double?> maxSpeedKmh = const Value.absent(),
                Value<int> harshBrakeCount = const Value.absent(),
                Value<int> harshAccelCount = const Value.absent(),
                Value<int> harshTurnCount = const Value.absent(),
                Value<int> bumpCount = const Value.absent(),
                Value<int> confirmedEventCount = const Value.absent(),
                Value<double?> eventsPerKm = const Value.absent(),
                Value<double?> avgHr = const Value.absent(),
                Value<int?> maxHr = const Value.absent(),
                Value<double?> hrSpikeConfirmedRatio = const Value.absent(),
                Value<double?> nightDrivingPct = const Value.absent(),
                Value<double?> driverScore = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double?> startLat = const Value.absent(),
                Value<double?> startLng = const Value.absent(),
                Value<double?> endLat = const Value.absent(),
                Value<double?> endLng = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<double?> peakSpeedKmh = const Value.absent(),
                Value<int> totalSensorRows = const Value.absent(),
                Value<int> totalEventsCount = const Value.absent(),
                Value<String?> routeCoordinatesJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                riderName: riderName,
                wristSide: wristSide,
                startTimeUtc: startTimeUtc,
                endTimeUtc: endTimeUtc,
                startTimestampUtc: startTimestampUtc,
                endTimestampUtc: endTimestampUtc,
                totalDistanceKm: totalDistanceKm,
                totalDurationMin: totalDurationMin,
                avgSpeedKmh: avgSpeedKmh,
                maxSpeedKmh: maxSpeedKmh,
                harshBrakeCount: harshBrakeCount,
                harshAccelCount: harshAccelCount,
                harshTurnCount: harshTurnCount,
                bumpCount: bumpCount,
                confirmedEventCount: confirmedEventCount,
                eventsPerKm: eventsPerKm,
                avgHr: avgHr,
                maxHr: maxHr,
                hrSpikeConfirmedRatio: hrSpikeConfirmedRatio,
                nightDrivingPct: nightDrivingPct,
                driverScore: driverScore,
                durationSeconds: durationSeconds,
                startLat: startLat,
                startLng: startLng,
                endLat: endLat,
                endLng: endLng,
                distanceMeters: distanceMeters,
                peakSpeedKmh: peakSpeedKmh,
                totalSensorRows: totalSensorRows,
                totalEventsCount: totalEventsCount,
                routeCoordinatesJson: routeCoordinatesJson,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> riderName = const Value.absent(),
                Value<String> wristSide = const Value.absent(),
                required DateTime startTimeUtc,
                Value<DateTime?> endTimeUtc = const Value.absent(),
                Value<DateTime?> startTimestampUtc = const Value.absent(),
                Value<DateTime?> endTimestampUtc = const Value.absent(),
                Value<double?> totalDistanceKm = const Value.absent(),
                Value<double?> totalDurationMin = const Value.absent(),
                Value<double?> avgSpeedKmh = const Value.absent(),
                Value<double?> maxSpeedKmh = const Value.absent(),
                Value<int> harshBrakeCount = const Value.absent(),
                Value<int> harshAccelCount = const Value.absent(),
                Value<int> harshTurnCount = const Value.absent(),
                Value<int> bumpCount = const Value.absent(),
                Value<int> confirmedEventCount = const Value.absent(),
                Value<double?> eventsPerKm = const Value.absent(),
                Value<double?> avgHr = const Value.absent(),
                Value<int?> maxHr = const Value.absent(),
                Value<double?> hrSpikeConfirmedRatio = const Value.absent(),
                Value<double?> nightDrivingPct = const Value.absent(),
                Value<double?> driverScore = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double?> startLat = const Value.absent(),
                Value<double?> startLng = const Value.absent(),
                Value<double?> endLat = const Value.absent(),
                Value<double?> endLng = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<double?> peakSpeedKmh = const Value.absent(),
                Value<int> totalSensorRows = const Value.absent(),
                Value<int> totalEventsCount = const Value.absent(),
                Value<String?> routeCoordinatesJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                riderName: riderName,
                wristSide: wristSide,
                startTimeUtc: startTimeUtc,
                endTimeUtc: endTimeUtc,
                startTimestampUtc: startTimestampUtc,
                endTimestampUtc: endTimestampUtc,
                totalDistanceKm: totalDistanceKm,
                totalDurationMin: totalDurationMin,
                avgSpeedKmh: avgSpeedKmh,
                maxSpeedKmh: maxSpeedKmh,
                harshBrakeCount: harshBrakeCount,
                harshAccelCount: harshAccelCount,
                harshTurnCount: harshTurnCount,
                bumpCount: bumpCount,
                confirmedEventCount: confirmedEventCount,
                eventsPerKm: eventsPerKm,
                avgHr: avgHr,
                maxHr: maxHr,
                hrSpikeConfirmedRatio: hrSpikeConfirmedRatio,
                nightDrivingPct: nightDrivingPct,
                driverScore: driverScore,
                durationSeconds: durationSeconds,
                startLat: startLat,
                startLng: startLng,
                endLat: endLat,
                endLng: endLng,
                distanceMeters: distanceMeters,
                peakSpeedKmh: peakSpeedKmh,
                totalSensorRows: totalSensorRows,
                totalEventsCount: totalEventsCount,
                routeCoordinatesJson: routeCoordinatesJson,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      Trip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
      Trip,
      PrefetchHooks Function()
    >;
typedef $$LocationReadingsTableCreateCompanionBuilder =
    LocationReadingsCompanion Function({
      Value<int> id,
      required int tripId,
      required DateTime timestampUtc,
      required double latitude,
      required double longitude,
      Value<double?> altitude,
      Value<double?> gpsSpeedMps,
      Value<double?> gpsHeadingDeg,
      Value<double?> gpsAccuracyM,
    });
typedef $$LocationReadingsTableUpdateCompanionBuilder =
    LocationReadingsCompanion Function({
      Value<int> id,
      Value<int> tripId,
      Value<DateTime> timestampUtc,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitude,
      Value<double?> gpsSpeedMps,
      Value<double?> gpsHeadingDeg,
      Value<double?> gpsAccuracyM,
    });

class $$LocationReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationReadingsTable> {
  $$LocationReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsSpeedMps => $composableBuilder(
    column: $table.gpsSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsHeadingDeg => $composableBuilder(
    column: $table.gpsHeadingDeg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsAccuracyM => $composableBuilder(
    column: $table.gpsAccuracyM,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationReadingsTable> {
  $$LocationReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsSpeedMps => $composableBuilder(
    column: $table.gpsSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsHeadingDeg => $composableBuilder(
    column: $table.gpsHeadingDeg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsAccuracyM => $composableBuilder(
    column: $table.gpsAccuracyM,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationReadingsTable> {
  $$LocationReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get gpsSpeedMps => $composableBuilder(
    column: $table.gpsSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsHeadingDeg => $composableBuilder(
    column: $table.gpsHeadingDeg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsAccuracyM => $composableBuilder(
    column: $table.gpsAccuracyM,
    builder: (column) => column,
  );
}

class $$LocationReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationReadingsTable,
          LocationReading,
          $$LocationReadingsTableFilterComposer,
          $$LocationReadingsTableOrderingComposer,
          $$LocationReadingsTableAnnotationComposer,
          $$LocationReadingsTableCreateCompanionBuilder,
          $$LocationReadingsTableUpdateCompanionBuilder,
          (
            LocationReading,
            BaseReferences<
              _$AppDatabase,
              $LocationReadingsTable,
              LocationReading
            >,
          ),
          LocationReading,
          PrefetchHooks Function()
        > {
  $$LocationReadingsTableTableManager(
    _$AppDatabase db,
    $LocationReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tripId = const Value.absent(),
                Value<DateTime> timestampUtc = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> gpsSpeedMps = const Value.absent(),
                Value<double?> gpsHeadingDeg = const Value.absent(),
                Value<double?> gpsAccuracyM = const Value.absent(),
              }) => LocationReadingsCompanion(
                id: id,
                tripId: tripId,
                timestampUtc: timestampUtc,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                gpsSpeedMps: gpsSpeedMps,
                gpsHeadingDeg: gpsHeadingDeg,
                gpsAccuracyM: gpsAccuracyM,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tripId,
                required DateTime timestampUtc,
                required double latitude,
                required double longitude,
                Value<double?> altitude = const Value.absent(),
                Value<double?> gpsSpeedMps = const Value.absent(),
                Value<double?> gpsHeadingDeg = const Value.absent(),
                Value<double?> gpsAccuracyM = const Value.absent(),
              }) => LocationReadingsCompanion.insert(
                id: id,
                tripId: tripId,
                timestampUtc: timestampUtc,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                gpsSpeedMps: gpsSpeedMps,
                gpsHeadingDeg: gpsHeadingDeg,
                gpsAccuracyM: gpsAccuracyM,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationReadingsTable,
      LocationReading,
      $$LocationReadingsTableFilterComposer,
      $$LocationReadingsTableOrderingComposer,
      $$LocationReadingsTableAnnotationComposer,
      $$LocationReadingsTableCreateCompanionBuilder,
      $$LocationReadingsTableUpdateCompanionBuilder,
      (
        LocationReading,
        BaseReferences<_$AppDatabase, $LocationReadingsTable, LocationReading>,
      ),
      LocationReading,
      PrefetchHooks Function()
    >;
typedef $$TripCalibrationsTableCreateCompanionBuilder =
    TripCalibrationsCompanion Function({
      Value<int> id,
      required int tripId,
      required String mountLocation,
      required double engineNoiseFreqHz,
      required double engineNoiseAmplitude,
      required DateTime calibratedAtUtc,
      Value<bool> calibrationValid,
    });
typedef $$TripCalibrationsTableUpdateCompanionBuilder =
    TripCalibrationsCompanion Function({
      Value<int> id,
      Value<int> tripId,
      Value<String> mountLocation,
      Value<double> engineNoiseFreqHz,
      Value<double> engineNoiseAmplitude,
      Value<DateTime> calibratedAtUtc,
      Value<bool> calibrationValid,
    });

class $$TripCalibrationsTableFilterComposer
    extends Composer<_$AppDatabase, $TripCalibrationsTable> {
  $$TripCalibrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mountLocation => $composableBuilder(
    column: $table.mountLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get engineNoiseFreqHz => $composableBuilder(
    column: $table.engineNoiseFreqHz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get engineNoiseAmplitude => $composableBuilder(
    column: $table.engineNoiseAmplitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get calibratedAtUtc => $composableBuilder(
    column: $table.calibratedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get calibrationValid => $composableBuilder(
    column: $table.calibrationValid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripCalibrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripCalibrationsTable> {
  $$TripCalibrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mountLocation => $composableBuilder(
    column: $table.mountLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get engineNoiseFreqHz => $composableBuilder(
    column: $table.engineNoiseFreqHz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get engineNoiseAmplitude => $composableBuilder(
    column: $table.engineNoiseAmplitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get calibratedAtUtc => $composableBuilder(
    column: $table.calibratedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get calibrationValid => $composableBuilder(
    column: $table.calibrationValid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripCalibrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripCalibrationsTable> {
  $$TripCalibrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get mountLocation => $composableBuilder(
    column: $table.mountLocation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get engineNoiseFreqHz => $composableBuilder(
    column: $table.engineNoiseFreqHz,
    builder: (column) => column,
  );

  GeneratedColumn<double> get engineNoiseAmplitude => $composableBuilder(
    column: $table.engineNoiseAmplitude,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get calibratedAtUtc => $composableBuilder(
    column: $table.calibratedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get calibrationValid => $composableBuilder(
    column: $table.calibrationValid,
    builder: (column) => column,
  );
}

class $$TripCalibrationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripCalibrationsTable,
          TripCalibration,
          $$TripCalibrationsTableFilterComposer,
          $$TripCalibrationsTableOrderingComposer,
          $$TripCalibrationsTableAnnotationComposer,
          $$TripCalibrationsTableCreateCompanionBuilder,
          $$TripCalibrationsTableUpdateCompanionBuilder,
          (
            TripCalibration,
            BaseReferences<
              _$AppDatabase,
              $TripCalibrationsTable,
              TripCalibration
            >,
          ),
          TripCalibration,
          PrefetchHooks Function()
        > {
  $$TripCalibrationsTableTableManager(
    _$AppDatabase db,
    $TripCalibrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripCalibrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripCalibrationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripCalibrationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tripId = const Value.absent(),
                Value<String> mountLocation = const Value.absent(),
                Value<double> engineNoiseFreqHz = const Value.absent(),
                Value<double> engineNoiseAmplitude = const Value.absent(),
                Value<DateTime> calibratedAtUtc = const Value.absent(),
                Value<bool> calibrationValid = const Value.absent(),
              }) => TripCalibrationsCompanion(
                id: id,
                tripId: tripId,
                mountLocation: mountLocation,
                engineNoiseFreqHz: engineNoiseFreqHz,
                engineNoiseAmplitude: engineNoiseAmplitude,
                calibratedAtUtc: calibratedAtUtc,
                calibrationValid: calibrationValid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tripId,
                required String mountLocation,
                required double engineNoiseFreqHz,
                required double engineNoiseAmplitude,
                required DateTime calibratedAtUtc,
                Value<bool> calibrationValid = const Value.absent(),
              }) => TripCalibrationsCompanion.insert(
                id: id,
                tripId: tripId,
                mountLocation: mountLocation,
                engineNoiseFreqHz: engineNoiseFreqHz,
                engineNoiseAmplitude: engineNoiseAmplitude,
                calibratedAtUtc: calibratedAtUtc,
                calibrationValid: calibrationValid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripCalibrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripCalibrationsTable,
      TripCalibration,
      $$TripCalibrationsTableFilterComposer,
      $$TripCalibrationsTableOrderingComposer,
      $$TripCalibrationsTableAnnotationComposer,
      $$TripCalibrationsTableCreateCompanionBuilder,
      $$TripCalibrationsTableUpdateCompanionBuilder,
      (
        TripCalibration,
        BaseReferences<_$AppDatabase, $TripCalibrationsTable, TripCalibration>,
      ),
      TripCalibration,
      PrefetchHooks Function()
    >;
typedef $$RoadEventsTableCreateCompanionBuilder =
    RoadEventsCompanion Function({
      Value<int> id,
      Value<int?> tripId,
      required String eventType,
      required double latitude,
      required double longitude,
      Value<double?> severity,
      Value<double?> confidence,
      Value<String> source,
      required DateTime detectedAtUtc,
      Value<double?> speedKmhAtDetection,
      Value<int> alertCount,
      Value<int> feedbackCount,
      Value<DateTime?> lastAlertedAtUtc,
      Value<String?> note,
    });
typedef $$RoadEventsTableUpdateCompanionBuilder =
    RoadEventsCompanion Function({
      Value<int> id,
      Value<int?> tripId,
      Value<String> eventType,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> severity,
      Value<double?> confidence,
      Value<String> source,
      Value<DateTime> detectedAtUtc,
      Value<double?> speedKmhAtDetection,
      Value<int> alertCount,
      Value<int> feedbackCount,
      Value<DateTime?> lastAlertedAtUtc,
      Value<String?> note,
    });

class $$RoadEventsTableFilterComposer
    extends Composer<_$AppDatabase, $RoadEventsTable> {
  $$RoadEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedKmhAtDetection => $composableBuilder(
    column: $table.speedKmhAtDetection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alertCount => $composableBuilder(
    column: $table.alertCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feedbackCount => $composableBuilder(
    column: $table.feedbackCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAlertedAtUtc => $composableBuilder(
    column: $table.lastAlertedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoadEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoadEventsTable> {
  $$RoadEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedKmhAtDetection => $composableBuilder(
    column: $table.speedKmhAtDetection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alertCount => $composableBuilder(
    column: $table.alertCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feedbackCount => $composableBuilder(
    column: $table.feedbackCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAlertedAtUtc => $composableBuilder(
    column: $table.lastAlertedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoadEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoadEventsTable> {
  $$RoadEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speedKmhAtDetection => $composableBuilder(
    column: $table.speedKmhAtDetection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alertCount => $composableBuilder(
    column: $table.alertCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feedbackCount => $composableBuilder(
    column: $table.feedbackCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAlertedAtUtc => $composableBuilder(
    column: $table.lastAlertedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$RoadEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoadEventsTable,
          RoadEvent,
          $$RoadEventsTableFilterComposer,
          $$RoadEventsTableOrderingComposer,
          $$RoadEventsTableAnnotationComposer,
          $$RoadEventsTableCreateCompanionBuilder,
          $$RoadEventsTableUpdateCompanionBuilder,
          (
            RoadEvent,
            BaseReferences<_$AppDatabase, $RoadEventsTable, RoadEvent>,
          ),
          RoadEvent,
          PrefetchHooks Function()
        > {
  $$RoadEventsTableTableManager(_$AppDatabase db, $RoadEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoadEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoadEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoadEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> severity = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> detectedAtUtc = const Value.absent(),
                Value<double?> speedKmhAtDetection = const Value.absent(),
                Value<int> alertCount = const Value.absent(),
                Value<int> feedbackCount = const Value.absent(),
                Value<DateTime?> lastAlertedAtUtc = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => RoadEventsCompanion(
                id: id,
                tripId: tripId,
                eventType: eventType,
                latitude: latitude,
                longitude: longitude,
                severity: severity,
                confidence: confidence,
                source: source,
                detectedAtUtc: detectedAtUtc,
                speedKmhAtDetection: speedKmhAtDetection,
                alertCount: alertCount,
                feedbackCount: feedbackCount,
                lastAlertedAtUtc: lastAlertedAtUtc,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                required String eventType,
                required double latitude,
                required double longitude,
                Value<double?> severity = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String> source = const Value.absent(),
                required DateTime detectedAtUtc,
                Value<double?> speedKmhAtDetection = const Value.absent(),
                Value<int> alertCount = const Value.absent(),
                Value<int> feedbackCount = const Value.absent(),
                Value<DateTime?> lastAlertedAtUtc = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => RoadEventsCompanion.insert(
                id: id,
                tripId: tripId,
                eventType: eventType,
                latitude: latitude,
                longitude: longitude,
                severity: severity,
                confidence: confidence,
                source: source,
                detectedAtUtc: detectedAtUtc,
                speedKmhAtDetection: speedKmhAtDetection,
                alertCount: alertCount,
                feedbackCount: feedbackCount,
                lastAlertedAtUtc: lastAlertedAtUtc,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoadEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoadEventsTable,
      RoadEvent,
      $$RoadEventsTableFilterComposer,
      $$RoadEventsTableOrderingComposer,
      $$RoadEventsTableAnnotationComposer,
      $$RoadEventsTableCreateCompanionBuilder,
      $$RoadEventsTableUpdateCompanionBuilder,
      (RoadEvent, BaseReferences<_$AppDatabase, $RoadEventsTable, RoadEvent>),
      RoadEvent,
      PrefetchHooks Function()
    >;
typedef $$PreAlertsTableCreateCompanionBuilder =
    PreAlertsCompanion Function({
      Value<int> id,
      Value<int?> roadEventId,
      Value<int?> tripId,
      Value<int?> eventId,
      required String eventType,
      required double latitude,
      required double longitude,
      required double distanceMeters,
      required double speedKmh,
      required double timeToEventSeconds,
      required double recommendedSpeedKmh,
      required String urgency,
      required String spokenText,
      required DateTime alertedAtUtc,
      Value<String> deliveryStatus,
      Value<DateTime?> deliveredAtUtc,
      Value<String?> deliveryFailure,
      Value<bool> acknowledged,
    });
typedef $$PreAlertsTableUpdateCompanionBuilder =
    PreAlertsCompanion Function({
      Value<int> id,
      Value<int?> roadEventId,
      Value<int?> tripId,
      Value<int?> eventId,
      Value<String> eventType,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> distanceMeters,
      Value<double> speedKmh,
      Value<double> timeToEventSeconds,
      Value<double> recommendedSpeedKmh,
      Value<String> urgency,
      Value<String> spokenText,
      Value<DateTime> alertedAtUtc,
      Value<String> deliveryStatus,
      Value<DateTime?> deliveredAtUtc,
      Value<String?> deliveryFailure,
      Value<bool> acknowledged,
    });

class $$PreAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $PreAlertsTable> {
  $$PreAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roadEventId => $composableBuilder(
    column: $table.roadEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get timeToEventSeconds => $composableBuilder(
    column: $table.timeToEventSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recommendedSpeedKmh => $composableBuilder(
    column: $table.recommendedSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spokenText => $composableBuilder(
    column: $table.spokenText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get alertedAtUtc => $composableBuilder(
    column: $table.alertedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveredAtUtc => $composableBuilder(
    column: $table.deliveredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryFailure => $composableBuilder(
    column: $table.deliveryFailure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $PreAlertsTable> {
  $$PreAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roadEventId => $composableBuilder(
    column: $table.roadEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get timeToEventSeconds => $composableBuilder(
    column: $table.timeToEventSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recommendedSpeedKmh => $composableBuilder(
    column: $table.recommendedSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spokenText => $composableBuilder(
    column: $table.spokenText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get alertedAtUtc => $composableBuilder(
    column: $table.alertedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveredAtUtc => $composableBuilder(
    column: $table.deliveredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryFailure => $composableBuilder(
    column: $table.deliveryFailure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreAlertsTable> {
  $$PreAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get roadEventId => $composableBuilder(
    column: $table.roadEventId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<int> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speedKmh =>
      $composableBuilder(column: $table.speedKmh, builder: (column) => column);

  GeneratedColumn<double> get timeToEventSeconds => $composableBuilder(
    column: $table.timeToEventSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recommendedSpeedKmh => $composableBuilder(
    column: $table.recommendedSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<String> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<String> get spokenText => $composableBuilder(
    column: $table.spokenText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get alertedAtUtc => $composableBuilder(
    column: $table.alertedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deliveredAtUtc => $composableBuilder(
    column: $table.deliveredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryFailure => $composableBuilder(
    column: $table.deliveryFailure,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => column,
  );
}

class $$PreAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreAlertsTable,
          PreAlert,
          $$PreAlertsTableFilterComposer,
          $$PreAlertsTableOrderingComposer,
          $$PreAlertsTableAnnotationComposer,
          $$PreAlertsTableCreateCompanionBuilder,
          $$PreAlertsTableUpdateCompanionBuilder,
          (PreAlert, BaseReferences<_$AppDatabase, $PreAlertsTable, PreAlert>),
          PreAlert,
          PrefetchHooks Function()
        > {
  $$PreAlertsTableTableManager(_$AppDatabase db, $PreAlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> roadEventId = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<double> speedKmh = const Value.absent(),
                Value<double> timeToEventSeconds = const Value.absent(),
                Value<double> recommendedSpeedKmh = const Value.absent(),
                Value<String> urgency = const Value.absent(),
                Value<String> spokenText = const Value.absent(),
                Value<DateTime> alertedAtUtc = const Value.absent(),
                Value<String> deliveryStatus = const Value.absent(),
                Value<DateTime?> deliveredAtUtc = const Value.absent(),
                Value<String?> deliveryFailure = const Value.absent(),
                Value<bool> acknowledged = const Value.absent(),
              }) => PreAlertsCompanion(
                id: id,
                roadEventId: roadEventId,
                tripId: tripId,
                eventId: eventId,
                eventType: eventType,
                latitude: latitude,
                longitude: longitude,
                distanceMeters: distanceMeters,
                speedKmh: speedKmh,
                timeToEventSeconds: timeToEventSeconds,
                recommendedSpeedKmh: recommendedSpeedKmh,
                urgency: urgency,
                spokenText: spokenText,
                alertedAtUtc: alertedAtUtc,
                deliveryStatus: deliveryStatus,
                deliveredAtUtc: deliveredAtUtc,
                deliveryFailure: deliveryFailure,
                acknowledged: acknowledged,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> roadEventId = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
                required String eventType,
                required double latitude,
                required double longitude,
                required double distanceMeters,
                required double speedKmh,
                required double timeToEventSeconds,
                required double recommendedSpeedKmh,
                required String urgency,
                required String spokenText,
                required DateTime alertedAtUtc,
                Value<String> deliveryStatus = const Value.absent(),
                Value<DateTime?> deliveredAtUtc = const Value.absent(),
                Value<String?> deliveryFailure = const Value.absent(),
                Value<bool> acknowledged = const Value.absent(),
              }) => PreAlertsCompanion.insert(
                id: id,
                roadEventId: roadEventId,
                tripId: tripId,
                eventId: eventId,
                eventType: eventType,
                latitude: latitude,
                longitude: longitude,
                distanceMeters: distanceMeters,
                speedKmh: speedKmh,
                timeToEventSeconds: timeToEventSeconds,
                recommendedSpeedKmh: recommendedSpeedKmh,
                urgency: urgency,
                spokenText: spokenText,
                alertedAtUtc: alertedAtUtc,
                deliveryStatus: deliveryStatus,
                deliveredAtUtc: deliveredAtUtc,
                deliveryFailure: deliveryFailure,
                acknowledged: acknowledged,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreAlertsTable,
      PreAlert,
      $$PreAlertsTableFilterComposer,
      $$PreAlertsTableOrderingComposer,
      $$PreAlertsTableAnnotationComposer,
      $$PreAlertsTableCreateCompanionBuilder,
      $$PreAlertsTableUpdateCompanionBuilder,
      (PreAlert, BaseReferences<_$AppDatabase, $PreAlertsTable, PreAlert>),
      PreAlert,
      PrefetchHooks Function()
    >;
typedef $$EventFeedbacksTableCreateCompanionBuilder =
    EventFeedbacksCompanion Function({
      Value<int> id,
      Value<int?> eventId,
      Value<int?> tripId,
      Value<int?> roadEventId,
      Value<int?> preAlertId,
      required String eventType,
      required String prompt,
      required String responseText,
      required String responseSource,
      Value<double?> transcriptConfidence,
      Value<String?> llmAnalysis,
      Value<double?> alertEffectiveness,
      Value<String?> alertTimingAdequacy,
      Value<String?> difficultyLevel,
      Value<String?> riderSummary,
      Value<String?> improvementSuggestion,
      Value<String?> audioFilePath,
      Value<double?> analysisConfidence,
      Value<bool> analyzedByLlm,
      required DateTime createdAtUtc,
      Value<DateTime?> analyzedAtUtc,
    });
typedef $$EventFeedbacksTableUpdateCompanionBuilder =
    EventFeedbacksCompanion Function({
      Value<int> id,
      Value<int?> eventId,
      Value<int?> tripId,
      Value<int?> roadEventId,
      Value<int?> preAlertId,
      Value<String> eventType,
      Value<String> prompt,
      Value<String> responseText,
      Value<String> responseSource,
      Value<double?> transcriptConfidence,
      Value<String?> llmAnalysis,
      Value<double?> alertEffectiveness,
      Value<String?> alertTimingAdequacy,
      Value<String?> difficultyLevel,
      Value<String?> riderSummary,
      Value<String?> improvementSuggestion,
      Value<String?> audioFilePath,
      Value<double?> analysisConfidence,
      Value<bool> analyzedByLlm,
      Value<DateTime> createdAtUtc,
      Value<DateTime?> analyzedAtUtc,
    });

class $$EventFeedbacksTableFilterComposer
    extends Composer<_$AppDatabase, $EventFeedbacksTable> {
  $$EventFeedbacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roadEventId => $composableBuilder(
    column: $table.roadEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preAlertId => $composableBuilder(
    column: $table.preAlertId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseText => $composableBuilder(
    column: $table.responseText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseSource => $composableBuilder(
    column: $table.responseSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transcriptConfidence => $composableBuilder(
    column: $table.transcriptConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get llmAnalysis => $composableBuilder(
    column: $table.llmAnalysis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alertEffectiveness => $composableBuilder(
    column: $table.alertEffectiveness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertTimingAdequacy => $composableBuilder(
    column: $table.alertTimingAdequacy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riderSummary => $composableBuilder(
    column: $table.riderSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get improvementSuggestion => $composableBuilder(
    column: $table.improvementSuggestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get analysisConfidence => $composableBuilder(
    column: $table.analysisConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get analyzedByLlm => $composableBuilder(
    column: $table.analyzedByLlm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get analyzedAtUtc => $composableBuilder(
    column: $table.analyzedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventFeedbacksTableOrderingComposer
    extends Composer<_$AppDatabase, $EventFeedbacksTable> {
  $$EventFeedbacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roadEventId => $composableBuilder(
    column: $table.roadEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preAlertId => $composableBuilder(
    column: $table.preAlertId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseText => $composableBuilder(
    column: $table.responseText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseSource => $composableBuilder(
    column: $table.responseSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transcriptConfidence => $composableBuilder(
    column: $table.transcriptConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get llmAnalysis => $composableBuilder(
    column: $table.llmAnalysis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alertEffectiveness => $composableBuilder(
    column: $table.alertEffectiveness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertTimingAdequacy => $composableBuilder(
    column: $table.alertTimingAdequacy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riderSummary => $composableBuilder(
    column: $table.riderSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get improvementSuggestion => $composableBuilder(
    column: $table.improvementSuggestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get analysisConfidence => $composableBuilder(
    column: $table.analysisConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get analyzedByLlm => $composableBuilder(
    column: $table.analyzedByLlm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get analyzedAtUtc => $composableBuilder(
    column: $table.analyzedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventFeedbacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventFeedbacksTable> {
  $$EventFeedbacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<int> get roadEventId => $composableBuilder(
    column: $table.roadEventId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preAlertId => $composableBuilder(
    column: $table.preAlertId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get responseText => $composableBuilder(
    column: $table.responseText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseSource => $composableBuilder(
    column: $table.responseSource,
    builder: (column) => column,
  );

  GeneratedColumn<double> get transcriptConfidence => $composableBuilder(
    column: $table.transcriptConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get llmAnalysis => $composableBuilder(
    column: $table.llmAnalysis,
    builder: (column) => column,
  );

  GeneratedColumn<double> get alertEffectiveness => $composableBuilder(
    column: $table.alertEffectiveness,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alertTimingAdequacy => $composableBuilder(
    column: $table.alertTimingAdequacy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get riderSummary => $composableBuilder(
    column: $table.riderSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get improvementSuggestion => $composableBuilder(
    column: $table.improvementSuggestion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get analysisConfidence => $composableBuilder(
    column: $table.analysisConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get analyzedByLlm => $composableBuilder(
    column: $table.analyzedByLlm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get analyzedAtUtc => $composableBuilder(
    column: $table.analyzedAtUtc,
    builder: (column) => column,
  );
}

class $$EventFeedbacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventFeedbacksTable,
          EventFeedback,
          $$EventFeedbacksTableFilterComposer,
          $$EventFeedbacksTableOrderingComposer,
          $$EventFeedbacksTableAnnotationComposer,
          $$EventFeedbacksTableCreateCompanionBuilder,
          $$EventFeedbacksTableUpdateCompanionBuilder,
          (
            EventFeedback,
            BaseReferences<_$AppDatabase, $EventFeedbacksTable, EventFeedback>,
          ),
          EventFeedback,
          PrefetchHooks Function()
        > {
  $$EventFeedbacksTableTableManager(
    _$AppDatabase db,
    $EventFeedbacksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventFeedbacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventFeedbacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventFeedbacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<int?> roadEventId = const Value.absent(),
                Value<int?> preAlertId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> responseText = const Value.absent(),
                Value<String> responseSource = const Value.absent(),
                Value<double?> transcriptConfidence = const Value.absent(),
                Value<String?> llmAnalysis = const Value.absent(),
                Value<double?> alertEffectiveness = const Value.absent(),
                Value<String?> alertTimingAdequacy = const Value.absent(),
                Value<String?> difficultyLevel = const Value.absent(),
                Value<String?> riderSummary = const Value.absent(),
                Value<String?> improvementSuggestion = const Value.absent(),
                Value<String?> audioFilePath = const Value.absent(),
                Value<double?> analysisConfidence = const Value.absent(),
                Value<bool> analyzedByLlm = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime?> analyzedAtUtc = const Value.absent(),
              }) => EventFeedbacksCompanion(
                id: id,
                eventId: eventId,
                tripId: tripId,
                roadEventId: roadEventId,
                preAlertId: preAlertId,
                eventType: eventType,
                prompt: prompt,
                responseText: responseText,
                responseSource: responseSource,
                transcriptConfidence: transcriptConfidence,
                llmAnalysis: llmAnalysis,
                alertEffectiveness: alertEffectiveness,
                alertTimingAdequacy: alertTimingAdequacy,
                difficultyLevel: difficultyLevel,
                riderSummary: riderSummary,
                improvementSuggestion: improvementSuggestion,
                audioFilePath: audioFilePath,
                analysisConfidence: analysisConfidence,
                analyzedByLlm: analyzedByLlm,
                createdAtUtc: createdAtUtc,
                analyzedAtUtc: analyzedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<int?> roadEventId = const Value.absent(),
                Value<int?> preAlertId = const Value.absent(),
                required String eventType,
                required String prompt,
                required String responseText,
                required String responseSource,
                Value<double?> transcriptConfidence = const Value.absent(),
                Value<String?> llmAnalysis = const Value.absent(),
                Value<double?> alertEffectiveness = const Value.absent(),
                Value<String?> alertTimingAdequacy = const Value.absent(),
                Value<String?> difficultyLevel = const Value.absent(),
                Value<String?> riderSummary = const Value.absent(),
                Value<String?> improvementSuggestion = const Value.absent(),
                Value<String?> audioFilePath = const Value.absent(),
                Value<double?> analysisConfidence = const Value.absent(),
                Value<bool> analyzedByLlm = const Value.absent(),
                required DateTime createdAtUtc,
                Value<DateTime?> analyzedAtUtc = const Value.absent(),
              }) => EventFeedbacksCompanion.insert(
                id: id,
                eventId: eventId,
                tripId: tripId,
                roadEventId: roadEventId,
                preAlertId: preAlertId,
                eventType: eventType,
                prompt: prompt,
                responseText: responseText,
                responseSource: responseSource,
                transcriptConfidence: transcriptConfidence,
                llmAnalysis: llmAnalysis,
                alertEffectiveness: alertEffectiveness,
                alertTimingAdequacy: alertTimingAdequacy,
                difficultyLevel: difficultyLevel,
                riderSummary: riderSummary,
                improvementSuggestion: improvementSuggestion,
                audioFilePath: audioFilePath,
                analysisConfidence: analysisConfidence,
                analyzedByLlm: analyzedByLlm,
                createdAtUtc: createdAtUtc,
                analyzedAtUtc: analyzedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventFeedbacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventFeedbacksTable,
      EventFeedback,
      $$EventFeedbacksTableFilterComposer,
      $$EventFeedbacksTableOrderingComposer,
      $$EventFeedbacksTableAnnotationComposer,
      $$EventFeedbacksTableCreateCompanionBuilder,
      $$EventFeedbacksTableUpdateCompanionBuilder,
      (
        EventFeedback,
        BaseReferences<_$AppDatabase, $EventFeedbacksTable, EventFeedback>,
      ),
      EventFeedback,
      PrefetchHooks Function()
    >;
typedef $$UnknownEventsTableCreateCompanionBuilder =
    UnknownEventsCompanion Function({
      Value<int> id,
      Value<int?> tripId,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> imuSnapshotJson,
      Value<double?> peakAccelMagnitude,
      Value<int?> durationMs,
      required String questionSpoken,
      Value<String?> riderAnswerRaw,
      Value<double?> transcriptConfidence,
      Value<String?> resolvedLabel,
      Value<bool> promoted,
      Value<int?> promotedRoadEventId,
      Value<String?> audioFilePath,
      required DateTime detectedAtUtc,
      Value<DateTime?> answeredAtUtc,
    });
typedef $$UnknownEventsTableUpdateCompanionBuilder =
    UnknownEventsCompanion Function({
      Value<int> id,
      Value<int?> tripId,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> imuSnapshotJson,
      Value<double?> peakAccelMagnitude,
      Value<int?> durationMs,
      Value<String> questionSpoken,
      Value<String?> riderAnswerRaw,
      Value<double?> transcriptConfidence,
      Value<String?> resolvedLabel,
      Value<bool> promoted,
      Value<int?> promotedRoadEventId,
      Value<String?> audioFilePath,
      Value<DateTime> detectedAtUtc,
      Value<DateTime?> answeredAtUtc,
    });

class $$UnknownEventsTableFilterComposer
    extends Composer<_$AppDatabase, $UnknownEventsTable> {
  $$UnknownEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imuSnapshotJson => $composableBuilder(
    column: $table.imuSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakAccelMagnitude => $composableBuilder(
    column: $table.peakAccelMagnitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionSpoken => $composableBuilder(
    column: $table.questionSpoken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riderAnswerRaw => $composableBuilder(
    column: $table.riderAnswerRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transcriptConfidence => $composableBuilder(
    column: $table.transcriptConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedLabel => $composableBuilder(
    column: $table.resolvedLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get promoted => $composableBuilder(
    column: $table.promoted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get promotedRoadEventId => $composableBuilder(
    column: $table.promotedRoadEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAtUtc => $composableBuilder(
    column: $table.answeredAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnknownEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnknownEventsTable> {
  $$UnknownEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imuSnapshotJson => $composableBuilder(
    column: $table.imuSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakAccelMagnitude => $composableBuilder(
    column: $table.peakAccelMagnitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionSpoken => $composableBuilder(
    column: $table.questionSpoken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riderAnswerRaw => $composableBuilder(
    column: $table.riderAnswerRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transcriptConfidence => $composableBuilder(
    column: $table.transcriptConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedLabel => $composableBuilder(
    column: $table.resolvedLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get promoted => $composableBuilder(
    column: $table.promoted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get promotedRoadEventId => $composableBuilder(
    column: $table.promotedRoadEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAtUtc => $composableBuilder(
    column: $table.answeredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnknownEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnknownEventsTable> {
  $$UnknownEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get imuSnapshotJson => $composableBuilder(
    column: $table.imuSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakAccelMagnitude => $composableBuilder(
    column: $table.peakAccelMagnitude,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionSpoken => $composableBuilder(
    column: $table.questionSpoken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get riderAnswerRaw => $composableBuilder(
    column: $table.riderAnswerRaw,
    builder: (column) => column,
  );

  GeneratedColumn<double> get transcriptConfidence => $composableBuilder(
    column: $table.transcriptConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolvedLabel => $composableBuilder(
    column: $table.resolvedLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get promoted =>
      $composableBuilder(column: $table.promoted, builder: (column) => column);

  GeneratedColumn<int> get promotedRoadEventId => $composableBuilder(
    column: $table.promotedRoadEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get answeredAtUtc => $composableBuilder(
    column: $table.answeredAtUtc,
    builder: (column) => column,
  );
}

class $$UnknownEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnknownEventsTable,
          UnknownEvent,
          $$UnknownEventsTableFilterComposer,
          $$UnknownEventsTableOrderingComposer,
          $$UnknownEventsTableAnnotationComposer,
          $$UnknownEventsTableCreateCompanionBuilder,
          $$UnknownEventsTableUpdateCompanionBuilder,
          (
            UnknownEvent,
            BaseReferences<_$AppDatabase, $UnknownEventsTable, UnknownEvent>,
          ),
          UnknownEvent,
          PrefetchHooks Function()
        > {
  $$UnknownEventsTableTableManager(_$AppDatabase db, $UnknownEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnknownEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnknownEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnknownEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> imuSnapshotJson = const Value.absent(),
                Value<double?> peakAccelMagnitude = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String> questionSpoken = const Value.absent(),
                Value<String?> riderAnswerRaw = const Value.absent(),
                Value<double?> transcriptConfidence = const Value.absent(),
                Value<String?> resolvedLabel = const Value.absent(),
                Value<bool> promoted = const Value.absent(),
                Value<int?> promotedRoadEventId = const Value.absent(),
                Value<String?> audioFilePath = const Value.absent(),
                Value<DateTime> detectedAtUtc = const Value.absent(),
                Value<DateTime?> answeredAtUtc = const Value.absent(),
              }) => UnknownEventsCompanion(
                id: id,
                tripId: tripId,
                latitude: latitude,
                longitude: longitude,
                imuSnapshotJson: imuSnapshotJson,
                peakAccelMagnitude: peakAccelMagnitude,
                durationMs: durationMs,
                questionSpoken: questionSpoken,
                riderAnswerRaw: riderAnswerRaw,
                transcriptConfidence: transcriptConfidence,
                resolvedLabel: resolvedLabel,
                promoted: promoted,
                promotedRoadEventId: promotedRoadEventId,
                audioFilePath: audioFilePath,
                detectedAtUtc: detectedAtUtc,
                answeredAtUtc: answeredAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> imuSnapshotJson = const Value.absent(),
                Value<double?> peakAccelMagnitude = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required String questionSpoken,
                Value<String?> riderAnswerRaw = const Value.absent(),
                Value<double?> transcriptConfidence = const Value.absent(),
                Value<String?> resolvedLabel = const Value.absent(),
                Value<bool> promoted = const Value.absent(),
                Value<int?> promotedRoadEventId = const Value.absent(),
                Value<String?> audioFilePath = const Value.absent(),
                required DateTime detectedAtUtc,
                Value<DateTime?> answeredAtUtc = const Value.absent(),
              }) => UnknownEventsCompanion.insert(
                id: id,
                tripId: tripId,
                latitude: latitude,
                longitude: longitude,
                imuSnapshotJson: imuSnapshotJson,
                peakAccelMagnitude: peakAccelMagnitude,
                durationMs: durationMs,
                questionSpoken: questionSpoken,
                riderAnswerRaw: riderAnswerRaw,
                transcriptConfidence: transcriptConfidence,
                resolvedLabel: resolvedLabel,
                promoted: promoted,
                promotedRoadEventId: promotedRoadEventId,
                audioFilePath: audioFilePath,
                detectedAtUtc: detectedAtUtc,
                answeredAtUtc: answeredAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnknownEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnknownEventsTable,
      UnknownEvent,
      $$UnknownEventsTableFilterComposer,
      $$UnknownEventsTableOrderingComposer,
      $$UnknownEventsTableAnnotationComposer,
      $$UnknownEventsTableCreateCompanionBuilder,
      $$UnknownEventsTableUpdateCompanionBuilder,
      (
        UnknownEvent,
        BaseReferences<_$AppDatabase, $UnknownEventsTable, UnknownEvent>,
      ),
      UnknownEvent,
      PrefetchHooks Function()
    >;
typedef $$CameraCapturesTableCreateCompanionBuilder =
    CameraCapturesCompanion Function({
      Value<int> id,
      required String captureKey,
      required String deviceId,
      required int sequenceNo,
      required DateTime capturedAtUtc,
      required DateTime receivedAtUtc,
      Value<int?> tripId,
      Value<int?> linkedEventId,
      required String filePath,
      Value<String> mimeType,
      required int width,
      required int height,
      required int byteLength,
      required String sha256,
      Value<String> trigger,
    });
typedef $$CameraCapturesTableUpdateCompanionBuilder =
    CameraCapturesCompanion Function({
      Value<int> id,
      Value<String> captureKey,
      Value<String> deviceId,
      Value<int> sequenceNo,
      Value<DateTime> capturedAtUtc,
      Value<DateTime> receivedAtUtc,
      Value<int?> tripId,
      Value<int?> linkedEventId,
      Value<String> filePath,
      Value<String> mimeType,
      Value<int> width,
      Value<int> height,
      Value<int> byteLength,
      Value<String> sha256,
      Value<String> trigger,
    });

class $$CameraCapturesTableFilterComposer
    extends Composer<_$AppDatabase, $CameraCapturesTable> {
  $$CameraCapturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get captureKey => $composableBuilder(
    column: $table.captureKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNo => $composableBuilder(
    column: $table.sequenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAtUtc => $composableBuilder(
    column: $table.capturedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAtUtc => $composableBuilder(
    column: $table.receivedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedEventId => $composableBuilder(
    column: $table.linkedEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CameraCapturesTableOrderingComposer
    extends Composer<_$AppDatabase, $CameraCapturesTable> {
  $$CameraCapturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get captureKey => $composableBuilder(
    column: $table.captureKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNo => $composableBuilder(
    column: $table.sequenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAtUtc => $composableBuilder(
    column: $table.capturedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAtUtc => $composableBuilder(
    column: $table.receivedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedEventId => $composableBuilder(
    column: $table.linkedEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CameraCapturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CameraCapturesTable> {
  $$CameraCapturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get captureKey => $composableBuilder(
    column: $table.captureKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get sequenceNo => $composableBuilder(
    column: $table.sequenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAtUtc => $composableBuilder(
    column: $table.capturedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAtUtc => $composableBuilder(
    column: $table.receivedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<int> get linkedEventId => $composableBuilder(
    column: $table.linkedEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);
}

class $$CameraCapturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CameraCapturesTable,
          CameraCapture,
          $$CameraCapturesTableFilterComposer,
          $$CameraCapturesTableOrderingComposer,
          $$CameraCapturesTableAnnotationComposer,
          $$CameraCapturesTableCreateCompanionBuilder,
          $$CameraCapturesTableUpdateCompanionBuilder,
          (
            CameraCapture,
            BaseReferences<_$AppDatabase, $CameraCapturesTable, CameraCapture>,
          ),
          CameraCapture,
          PrefetchHooks Function()
        > {
  $$CameraCapturesTableTableManager(
    _$AppDatabase db,
    $CameraCapturesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CameraCapturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CameraCapturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CameraCapturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> captureKey = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> sequenceNo = const Value.absent(),
                Value<DateTime> capturedAtUtc = const Value.absent(),
                Value<DateTime> receivedAtUtc = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<int?> linkedEventId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<int> byteLength = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> trigger = const Value.absent(),
              }) => CameraCapturesCompanion(
                id: id,
                captureKey: captureKey,
                deviceId: deviceId,
                sequenceNo: sequenceNo,
                capturedAtUtc: capturedAtUtc,
                receivedAtUtc: receivedAtUtc,
                tripId: tripId,
                linkedEventId: linkedEventId,
                filePath: filePath,
                mimeType: mimeType,
                width: width,
                height: height,
                byteLength: byteLength,
                sha256: sha256,
                trigger: trigger,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String captureKey,
                required String deviceId,
                required int sequenceNo,
                required DateTime capturedAtUtc,
                required DateTime receivedAtUtc,
                Value<int?> tripId = const Value.absent(),
                Value<int?> linkedEventId = const Value.absent(),
                required String filePath,
                Value<String> mimeType = const Value.absent(),
                required int width,
                required int height,
                required int byteLength,
                required String sha256,
                Value<String> trigger = const Value.absent(),
              }) => CameraCapturesCompanion.insert(
                id: id,
                captureKey: captureKey,
                deviceId: deviceId,
                sequenceNo: sequenceNo,
                capturedAtUtc: capturedAtUtc,
                receivedAtUtc: receivedAtUtc,
                tripId: tripId,
                linkedEventId: linkedEventId,
                filePath: filePath,
                mimeType: mimeType,
                width: width,
                height: height,
                byteLength: byteLength,
                sha256: sha256,
                trigger: trigger,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CameraCapturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CameraCapturesTable,
      CameraCapture,
      $$CameraCapturesTableFilterComposer,
      $$CameraCapturesTableOrderingComposer,
      $$CameraCapturesTableAnnotationComposer,
      $$CameraCapturesTableCreateCompanionBuilder,
      $$CameraCapturesTableUpdateCompanionBuilder,
      (
        CameraCapture,
        BaseReferences<_$AppDatabase, $CameraCapturesTable, CameraCapture>,
      ),
      CameraCapture,
      PrefetchHooks Function()
    >;
typedef $$LiveEventReviewsTableCreateCompanionBuilder =
    LiveEventReviewsCompanion Function({
      Value<int> id,
      required int tripId,
      Value<int?> eventId,
      required String eventType,
      required DateTime detectedAtUtc,
      Value<double?> latitude,
      Value<double?> longitude,
      required double confidence,
      required String sensorFeaturesJson,
      Value<String?> confirmationReply,
      Value<bool?> confirmed,
      Value<String?> feedback,
      Value<String> reviewStatus,
      Value<int?> roadEventId,
    });
typedef $$LiveEventReviewsTableUpdateCompanionBuilder =
    LiveEventReviewsCompanion Function({
      Value<int> id,
      Value<int> tripId,
      Value<int?> eventId,
      Value<String> eventType,
      Value<DateTime> detectedAtUtc,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double> confidence,
      Value<String> sensorFeaturesJson,
      Value<String?> confirmationReply,
      Value<bool?> confirmed,
      Value<String?> feedback,
      Value<String> reviewStatus,
      Value<int?> roadEventId,
    });

class $$LiveEventReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $LiveEventReviewsTable> {
  $$LiveEventReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sensorFeaturesJson => $composableBuilder(
    column: $table.sensorFeaturesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confirmationReply => $composableBuilder(
    column: $table.confirmationReply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roadEventId => $composableBuilder(
    column: $table.roadEventId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LiveEventReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $LiveEventReviewsTable> {
  $$LiveEventReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensorFeaturesJson => $composableBuilder(
    column: $table.sensorFeaturesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confirmationReply => $composableBuilder(
    column: $table.confirmationReply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roadEventId => $composableBuilder(
    column: $table.roadEventId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LiveEventReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiveEventReviewsTable> {
  $$LiveEventReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<int> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sensorFeaturesJson => $composableBuilder(
    column: $table.sensorFeaturesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confirmationReply => $composableBuilder(
    column: $table.confirmationReply,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  GeneratedColumn<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roadEventId => $composableBuilder(
    column: $table.roadEventId,
    builder: (column) => column,
  );
}

class $$LiveEventReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiveEventReviewsTable,
          LiveEventReview,
          $$LiveEventReviewsTableFilterComposer,
          $$LiveEventReviewsTableOrderingComposer,
          $$LiveEventReviewsTableAnnotationComposer,
          $$LiveEventReviewsTableCreateCompanionBuilder,
          $$LiveEventReviewsTableUpdateCompanionBuilder,
          (
            LiveEventReview,
            BaseReferences<
              _$AppDatabase,
              $LiveEventReviewsTable,
              LiveEventReview
            >,
          ),
          LiveEventReview,
          PrefetchHooks Function()
        > {
  $$LiveEventReviewsTableTableManager(
    _$AppDatabase db,
    $LiveEventReviewsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiveEventReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiveEventReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiveEventReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tripId = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> detectedAtUtc = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> sensorFeaturesJson = const Value.absent(),
                Value<String?> confirmationReply = const Value.absent(),
                Value<bool?> confirmed = const Value.absent(),
                Value<String?> feedback = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<int?> roadEventId = const Value.absent(),
              }) => LiveEventReviewsCompanion(
                id: id,
                tripId: tripId,
                eventId: eventId,
                eventType: eventType,
                detectedAtUtc: detectedAtUtc,
                latitude: latitude,
                longitude: longitude,
                confidence: confidence,
                sensorFeaturesJson: sensorFeaturesJson,
                confirmationReply: confirmationReply,
                confirmed: confirmed,
                feedback: feedback,
                reviewStatus: reviewStatus,
                roadEventId: roadEventId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tripId,
                Value<int?> eventId = const Value.absent(),
                required String eventType,
                required DateTime detectedAtUtc,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                required double confidence,
                required String sensorFeaturesJson,
                Value<String?> confirmationReply = const Value.absent(),
                Value<bool?> confirmed = const Value.absent(),
                Value<String?> feedback = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<int?> roadEventId = const Value.absent(),
              }) => LiveEventReviewsCompanion.insert(
                id: id,
                tripId: tripId,
                eventId: eventId,
                eventType: eventType,
                detectedAtUtc: detectedAtUtc,
                latitude: latitude,
                longitude: longitude,
                confidence: confidence,
                sensorFeaturesJson: sensorFeaturesJson,
                confirmationReply: confirmationReply,
                confirmed: confirmed,
                feedback: feedback,
                reviewStatus: reviewStatus,
                roadEventId: roadEventId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LiveEventReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiveEventReviewsTable,
      LiveEventReview,
      $$LiveEventReviewsTableFilterComposer,
      $$LiveEventReviewsTableOrderingComposer,
      $$LiveEventReviewsTableAnnotationComposer,
      $$LiveEventReviewsTableCreateCompanionBuilder,
      $$LiveEventReviewsTableUpdateCompanionBuilder,
      (
        LiveEventReview,
        BaseReferences<_$AppDatabase, $LiveEventReviewsTable, LiveEventReview>,
      ),
      LiveEventReview,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SensorReadingsTableTableManager get sensorReadings =>
      $$SensorReadingsTableTableManager(_db, _db.sensorReadings);
  $$EventRecordsTableTableManager get eventRecords =>
      $$EventRecordsTableTableManager(_db, _db.eventRecords);
  $$CameraDetectionsTableTableManager get cameraDetections =>
      $$CameraDetectionsTableTableManager(_db, _db.cameraDetections);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$LocationReadingsTableTableManager get locationReadings =>
      $$LocationReadingsTableTableManager(_db, _db.locationReadings);
  $$TripCalibrationsTableTableManager get tripCalibrations =>
      $$TripCalibrationsTableTableManager(_db, _db.tripCalibrations);
  $$RoadEventsTableTableManager get roadEvents =>
      $$RoadEventsTableTableManager(_db, _db.roadEvents);
  $$PreAlertsTableTableManager get preAlerts =>
      $$PreAlertsTableTableManager(_db, _db.preAlerts);
  $$EventFeedbacksTableTableManager get eventFeedbacks =>
      $$EventFeedbacksTableTableManager(_db, _db.eventFeedbacks);
  $$UnknownEventsTableTableManager get unknownEvents =>
      $$UnknownEventsTableTableManager(_db, _db.unknownEvents);
  $$CameraCapturesTableTableManager get cameraCaptures =>
      $$CameraCapturesTableTableManager(_db, _db.cameraCaptures);
  $$LiveEventReviewsTableTableManager get liveEventReviews =>
      $$LiveEventReviewsTableTableManager(_db, _db.liveEventReviews);
}
