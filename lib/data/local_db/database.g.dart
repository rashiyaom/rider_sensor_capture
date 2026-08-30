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
    eventId,
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
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
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
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
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
  final int? eventId;
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
    this.eventId,
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
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<int>(eventId);
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
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
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
      eventId: serializer.fromJson<int?>(json['eventId']),
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
      'eventId': serializer.toJson<int?>(eventId),
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
    Value<int?> eventId = const Value.absent(),
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
    eventId: eventId.present ? eventId.value : this.eventId,
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
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
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
          ..write('eventId: $eventId, ')
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
    eventId,
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
          other.eventId == this.eventId &&
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
  final Value<int?> eventId;
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
    this.eventId = const Value.absent(),
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
    this.eventId = const Value.absent(),
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
    Expression<int>? eventId,
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
      if (eventId != null) 'event_id': eventId,
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
    Value<int?>? eventId,
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
      eventId: eventId ?? this.eventId,
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
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
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
          ..write('eventId: $eventId, ')
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
          ..write('classification: $classification')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
  );
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
          other.classification == this.classification);
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
          ..write('classification: $classification')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SensorReadingsTable sensorReadings = $SensorReadingsTable(this);
  late final $EventRecordsTable eventRecords = $EventRecordsTable(this);
  late final $CameraDetectionsTable cameraDetections = $CameraDetectionsTable(
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
      Value<int?> eventId,
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
      Value<int?> eventId,
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

  ColumnFilters<int> get eventId => $composableBuilder(
    column: $table.eventId,
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

  ColumnOrderings<int> get eventId => $composableBuilder(
    column: $table.eventId,
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

  GeneratedColumn<int> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

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
                Value<int?> eventId = const Value.absent(),
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
                eventId: eventId,
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
                Value<int?> eventId = const Value.absent(),
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
                eventId: eventId,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SensorReadingsTableTableManager get sensorReadings =>
      $$SensorReadingsTableTableManager(_db, _db.sensorReadings);
  $$EventRecordsTableTableManager get eventRecords =>
      $$EventRecordsTableTableManager(_db, _db.eventRecords);
  $$CameraDetectionsTableTableManager get cameraDetections =>
      $$CameraDetectionsTableTableManager(_db, _db.cameraDetections);
}
