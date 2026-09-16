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
          ..write('rawPayload: $rawPayload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
    rawPayload,
  );
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
          ..write('gpsHeadingChangeDeg: $gpsHeadingChangeDeg')
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
          other.gpsHeadingChangeDeg == this.gpsHeadingChangeDeg);
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
          ..write('gpsHeadingChangeDeg: $gpsHeadingChangeDeg')
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
  ];
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
}
