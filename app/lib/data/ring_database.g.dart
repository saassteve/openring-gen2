// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ring_database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformIdMeta = const VerificationMeta(
    'platformId',
  );
  @override
  late final GeneratedColumn<String> platformId = GeneratedColumn<String>(
    'platform_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firmwareMeta = const VerificationMeta(
    'firmware',
  );
  @override
  late final GeneratedColumn<String> firmware = GeneratedColumn<String>(
    'firmware',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<String> serial = GeneratedColumn<String>(
    'serial',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systemIdMeta = const VerificationMeta(
    'systemId',
  );
  @override
  late final GeneratedColumn<Uint8List> systemId = GeneratedColumn<Uint8List>(
    'system_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    platformId,
    name,
    firmware,
    serial,
    systemId,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('platform_id')) {
      context.handle(
        _platformIdMeta,
        platformId.isAcceptableOrUnknown(data['platform_id']!, _platformIdMeta),
      );
    } else if (isInserting) {
      context.missing(_platformIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('firmware')) {
      context.handle(
        _firmwareMeta,
        firmware.isAcceptableOrUnknown(data['firmware']!, _firmwareMeta),
      );
    }
    if (data.containsKey('serial')) {
      context.handle(
        _serialMeta,
        serial.isAcceptableOrUnknown(data['serial']!, _serialMeta),
      );
    }
    if (data.containsKey('system_id')) {
      context.handle(
        _systemIdMeta,
        systemId.isAcceptableOrUnknown(data['system_id']!, _systemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_systemIdMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      platformId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      firmware: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firmware'],
      ),
      serial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial'],
      ),
      systemId: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}system_id'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String platformId;
  final String name;
  final String? firmware;
  final String? serial;
  final Uint8List systemId;
  final DateTime lastSeenAt;
  const Device({
    required this.id,
    required this.platformId,
    required this.name,
    this.firmware,
    this.serial,
    required this.systemId,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['platform_id'] = Variable<String>(platformId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || firmware != null) {
      map['firmware'] = Variable<String>(firmware);
    }
    if (!nullToAbsent || serial != null) {
      map['serial'] = Variable<String>(serial);
    }
    map['system_id'] = Variable<Uint8List>(systemId);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      platformId: Value(platformId),
      name: Value(name),
      firmware: firmware == null && nullToAbsent
          ? const Value.absent()
          : Value(firmware),
      serial: serial == null && nullToAbsent
          ? const Value.absent()
          : Value(serial),
      systemId: Value(systemId),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      platformId: serializer.fromJson<String>(json['platformId']),
      name: serializer.fromJson<String>(json['name']),
      firmware: serializer.fromJson<String?>(json['firmware']),
      serial: serializer.fromJson<String?>(json['serial']),
      systemId: serializer.fromJson<Uint8List>(json['systemId']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'platformId': serializer.toJson<String>(platformId),
      'name': serializer.toJson<String>(name),
      'firmware': serializer.toJson<String?>(firmware),
      'serial': serializer.toJson<String?>(serial),
      'systemId': serializer.toJson<Uint8List>(systemId),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
    };
  }

  Device copyWith({
    String? id,
    String? platformId,
    String? name,
    Value<String?> firmware = const Value.absent(),
    Value<String?> serial = const Value.absent(),
    Uint8List? systemId,
    DateTime? lastSeenAt,
  }) => Device(
    id: id ?? this.id,
    platformId: platformId ?? this.platformId,
    name: name ?? this.name,
    firmware: firmware.present ? firmware.value : this.firmware,
    serial: serial.present ? serial.value : this.serial,
    systemId: systemId ?? this.systemId,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      platformId: data.platformId.present
          ? data.platformId.value
          : this.platformId,
      name: data.name.present ? data.name.value : this.name,
      firmware: data.firmware.present ? data.firmware.value : this.firmware,
      serial: data.serial.present ? data.serial.value : this.serial,
      systemId: data.systemId.present ? data.systemId.value : this.systemId,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('platformId: $platformId, ')
          ..write('name: $name, ')
          ..write('firmware: $firmware, ')
          ..write('serial: $serial, ')
          ..write('systemId: $systemId, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    platformId,
    name,
    firmware,
    serial,
    $driftBlobEquality.hash(systemId),
    lastSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.platformId == this.platformId &&
          other.name == this.name &&
          other.firmware == this.firmware &&
          other.serial == this.serial &&
          $driftBlobEquality.equals(other.systemId, this.systemId) &&
          other.lastSeenAt == this.lastSeenAt);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> platformId;
  final Value<String> name;
  final Value<String?> firmware;
  final Value<String?> serial;
  final Value<Uint8List> systemId;
  final Value<DateTime> lastSeenAt;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.platformId = const Value.absent(),
    this.name = const Value.absent(),
    this.firmware = const Value.absent(),
    this.serial = const Value.absent(),
    this.systemId = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String platformId,
    required String name,
    this.firmware = const Value.absent(),
    this.serial = const Value.absent(),
    required Uint8List systemId,
    required DateTime lastSeenAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       platformId = Value(platformId),
       name = Value(name),
       systemId = Value(systemId),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? platformId,
    Expression<String>? name,
    Expression<String>? firmware,
    Expression<String>? serial,
    Expression<Uint8List>? systemId,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (platformId != null) 'platform_id': platformId,
      if (name != null) 'name': name,
      if (firmware != null) 'firmware': firmware,
      if (serial != null) 'serial': serial,
      if (systemId != null) 'system_id': systemId,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? platformId,
    Value<String>? name,
    Value<String?>? firmware,
    Value<String?>? serial,
    Value<Uint8List>? systemId,
    Value<DateTime>? lastSeenAt,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      platformId: platformId ?? this.platformId,
      name: name ?? this.name,
      firmware: firmware ?? this.firmware,
      serial: serial ?? this.serial,
      systemId: systemId ?? this.systemId,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (platformId.present) {
      map['platform_id'] = Variable<String>(platformId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (firmware.present) {
      map['firmware'] = Variable<String>(firmware.value);
    }
    if (serial.present) {
      map['serial'] = Variable<String>(serial.value);
    }
    if (systemId.present) {
      map['system_id'] = Variable<Uint8List>(systemId.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('platformId: $platformId, ')
          ..write('name: $name, ')
          ..write('firmware: $firmware, ')
          ..write('serial: $serial, ')
          ..write('systemId: $systemId, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TelemetrySnapshotsTable extends TelemetrySnapshots
    with TableInfo<$TelemetrySnapshotsTable, TelemetrySnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelemetrySnapshotsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batteryPercentMeta = const VerificationMeta(
    'batteryPercent',
  );
  @override
  late final GeneratedColumn<int> batteryPercent = GeneratedColumn<int>(
    'battery_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batteryMillivoltsMeta = const VerificationMeta(
    'batteryMillivolts',
  );
  @override
  late final GeneratedColumn<int> batteryMillivolts = GeneratedColumn<int>(
    'battery_millivolts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperature1Meta = const VerificationMeta(
    'temperature1',
  );
  @override
  late final GeneratedColumn<double> temperature1 = GeneratedColumn<double>(
    'temperature1',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperature2Meta = const VerificationMeta(
    'temperature2',
  );
  @override
  late final GeneratedColumn<double> temperature2 = GeneratedColumn<double>(
    'temperature2',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wearCodeMeta = const VerificationMeta(
    'wearCode',
  );
  @override
  late final GeneratedColumn<int> wearCode = GeneratedColumn<int>(
    'wear_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeFlagsMeta = const VerificationMeta(
    'modeFlags',
  );
  @override
  late final GeneratedColumn<int> modeFlags = GeneratedColumn<int>(
    'mode_flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<Uint8List> raw = GeneratedColumn<Uint8List>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    capturedAt,
    batteryPercent,
    batteryMillivolts,
    temperature1,
    temperature2,
    wearCode,
    modeFlags,
    raw,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telemetry_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<TelemetrySnapshot> instance, {
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
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('battery_percent')) {
      context.handle(
        _batteryPercentMeta,
        batteryPercent.isAcceptableOrUnknown(
          data['battery_percent']!,
          _batteryPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batteryPercentMeta);
    }
    if (data.containsKey('battery_millivolts')) {
      context.handle(
        _batteryMillivoltsMeta,
        batteryMillivolts.isAcceptableOrUnknown(
          data['battery_millivolts']!,
          _batteryMillivoltsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batteryMillivoltsMeta);
    }
    if (data.containsKey('temperature1')) {
      context.handle(
        _temperature1Meta,
        temperature1.isAcceptableOrUnknown(
          data['temperature1']!,
          _temperature1Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperature1Meta);
    }
    if (data.containsKey('temperature2')) {
      context.handle(
        _temperature2Meta,
        temperature2.isAcceptableOrUnknown(
          data['temperature2']!,
          _temperature2Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperature2Meta);
    }
    if (data.containsKey('wear_code')) {
      context.handle(
        _wearCodeMeta,
        wearCode.isAcceptableOrUnknown(data['wear_code']!, _wearCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_wearCodeMeta);
    }
    if (data.containsKey('mode_flags')) {
      context.handle(
        _modeFlagsMeta,
        modeFlags.isAcceptableOrUnknown(data['mode_flags']!, _modeFlagsMeta),
      );
    } else if (isInserting) {
      context.missing(_modeFlagsMeta);
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TelemetrySnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelemetrySnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      batteryPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_percent'],
      )!,
      batteryMillivolts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_millivolts'],
      )!,
      temperature1: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature1'],
      )!,
      temperature2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature2'],
      )!,
      wearCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wear_code'],
      )!,
      modeFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mode_flags'],
      )!,
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}raw'],
      )!,
    );
  }

  @override
  $TelemetrySnapshotsTable createAlias(String alias) {
    return $TelemetrySnapshotsTable(attachedDatabase, alias);
  }
}

class TelemetrySnapshot extends DataClass
    implements Insertable<TelemetrySnapshot> {
  final int id;
  final String deviceId;
  final DateTime capturedAt;
  final int batteryPercent;
  final int batteryMillivolts;
  final double temperature1;
  final double temperature2;
  final int wearCode;
  final int modeFlags;
  final Uint8List raw;
  const TelemetrySnapshot({
    required this.id,
    required this.deviceId,
    required this.capturedAt,
    required this.batteryPercent,
    required this.batteryMillivolts,
    required this.temperature1,
    required this.temperature2,
    required this.wearCode,
    required this.modeFlags,
    required this.raw,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['battery_percent'] = Variable<int>(batteryPercent);
    map['battery_millivolts'] = Variable<int>(batteryMillivolts);
    map['temperature1'] = Variable<double>(temperature1);
    map['temperature2'] = Variable<double>(temperature2);
    map['wear_code'] = Variable<int>(wearCode);
    map['mode_flags'] = Variable<int>(modeFlags);
    map['raw'] = Variable<Uint8List>(raw);
    return map;
  }

  TelemetrySnapshotsCompanion toCompanion(bool nullToAbsent) {
    return TelemetrySnapshotsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      capturedAt: Value(capturedAt),
      batteryPercent: Value(batteryPercent),
      batteryMillivolts: Value(batteryMillivolts),
      temperature1: Value(temperature1),
      temperature2: Value(temperature2),
      wearCode: Value(wearCode),
      modeFlags: Value(modeFlags),
      raw: Value(raw),
    );
  }

  factory TelemetrySnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelemetrySnapshot(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      batteryPercent: serializer.fromJson<int>(json['batteryPercent']),
      batteryMillivolts: serializer.fromJson<int>(json['batteryMillivolts']),
      temperature1: serializer.fromJson<double>(json['temperature1']),
      temperature2: serializer.fromJson<double>(json['temperature2']),
      wearCode: serializer.fromJson<int>(json['wearCode']),
      modeFlags: serializer.fromJson<int>(json['modeFlags']),
      raw: serializer.fromJson<Uint8List>(json['raw']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'batteryPercent': serializer.toJson<int>(batteryPercent),
      'batteryMillivolts': serializer.toJson<int>(batteryMillivolts),
      'temperature1': serializer.toJson<double>(temperature1),
      'temperature2': serializer.toJson<double>(temperature2),
      'wearCode': serializer.toJson<int>(wearCode),
      'modeFlags': serializer.toJson<int>(modeFlags),
      'raw': serializer.toJson<Uint8List>(raw),
    };
  }

  TelemetrySnapshot copyWith({
    int? id,
    String? deviceId,
    DateTime? capturedAt,
    int? batteryPercent,
    int? batteryMillivolts,
    double? temperature1,
    double? temperature2,
    int? wearCode,
    int? modeFlags,
    Uint8List? raw,
  }) => TelemetrySnapshot(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    capturedAt: capturedAt ?? this.capturedAt,
    batteryPercent: batteryPercent ?? this.batteryPercent,
    batteryMillivolts: batteryMillivolts ?? this.batteryMillivolts,
    temperature1: temperature1 ?? this.temperature1,
    temperature2: temperature2 ?? this.temperature2,
    wearCode: wearCode ?? this.wearCode,
    modeFlags: modeFlags ?? this.modeFlags,
    raw: raw ?? this.raw,
  );
  TelemetrySnapshot copyWithCompanion(TelemetrySnapshotsCompanion data) {
    return TelemetrySnapshot(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      batteryPercent: data.batteryPercent.present
          ? data.batteryPercent.value
          : this.batteryPercent,
      batteryMillivolts: data.batteryMillivolts.present
          ? data.batteryMillivolts.value
          : this.batteryMillivolts,
      temperature1: data.temperature1.present
          ? data.temperature1.value
          : this.temperature1,
      temperature2: data.temperature2.present
          ? data.temperature2.value
          : this.temperature2,
      wearCode: data.wearCode.present ? data.wearCode.value : this.wearCode,
      modeFlags: data.modeFlags.present ? data.modeFlags.value : this.modeFlags,
      raw: data.raw.present ? data.raw.value : this.raw,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelemetrySnapshot(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('batteryPercent: $batteryPercent, ')
          ..write('batteryMillivolts: $batteryMillivolts, ')
          ..write('temperature1: $temperature1, ')
          ..write('temperature2: $temperature2, ')
          ..write('wearCode: $wearCode, ')
          ..write('modeFlags: $modeFlags, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    capturedAt,
    batteryPercent,
    batteryMillivolts,
    temperature1,
    temperature2,
    wearCode,
    modeFlags,
    $driftBlobEquality.hash(raw),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelemetrySnapshot &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.capturedAt == this.capturedAt &&
          other.batteryPercent == this.batteryPercent &&
          other.batteryMillivolts == this.batteryMillivolts &&
          other.temperature1 == this.temperature1 &&
          other.temperature2 == this.temperature2 &&
          other.wearCode == this.wearCode &&
          other.modeFlags == this.modeFlags &&
          $driftBlobEquality.equals(other.raw, this.raw));
}

class TelemetrySnapshotsCompanion extends UpdateCompanion<TelemetrySnapshot> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> capturedAt;
  final Value<int> batteryPercent;
  final Value<int> batteryMillivolts;
  final Value<double> temperature1;
  final Value<double> temperature2;
  final Value<int> wearCode;
  final Value<int> modeFlags;
  final Value<Uint8List> raw;
  const TelemetrySnapshotsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.batteryPercent = const Value.absent(),
    this.batteryMillivolts = const Value.absent(),
    this.temperature1 = const Value.absent(),
    this.temperature2 = const Value.absent(),
    this.wearCode = const Value.absent(),
    this.modeFlags = const Value.absent(),
    this.raw = const Value.absent(),
  });
  TelemetrySnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime capturedAt,
    required int batteryPercent,
    required int batteryMillivolts,
    required double temperature1,
    required double temperature2,
    required int wearCode,
    required int modeFlags,
    required Uint8List raw,
  }) : deviceId = Value(deviceId),
       capturedAt = Value(capturedAt),
       batteryPercent = Value(batteryPercent),
       batteryMillivolts = Value(batteryMillivolts),
       temperature1 = Value(temperature1),
       temperature2 = Value(temperature2),
       wearCode = Value(wearCode),
       modeFlags = Value(modeFlags),
       raw = Value(raw);
  static Insertable<TelemetrySnapshot> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? capturedAt,
    Expression<int>? batteryPercent,
    Expression<int>? batteryMillivolts,
    Expression<double>? temperature1,
    Expression<double>? temperature2,
    Expression<int>? wearCode,
    Expression<int>? modeFlags,
    Expression<Uint8List>? raw,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (batteryPercent != null) 'battery_percent': batteryPercent,
      if (batteryMillivolts != null) 'battery_millivolts': batteryMillivolts,
      if (temperature1 != null) 'temperature1': temperature1,
      if (temperature2 != null) 'temperature2': temperature2,
      if (wearCode != null) 'wear_code': wearCode,
      if (modeFlags != null) 'mode_flags': modeFlags,
      if (raw != null) 'raw': raw,
    });
  }

  TelemetrySnapshotsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? capturedAt,
    Value<int>? batteryPercent,
    Value<int>? batteryMillivolts,
    Value<double>? temperature1,
    Value<double>? temperature2,
    Value<int>? wearCode,
    Value<int>? modeFlags,
    Value<Uint8List>? raw,
  }) {
    return TelemetrySnapshotsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      capturedAt: capturedAt ?? this.capturedAt,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      batteryMillivolts: batteryMillivolts ?? this.batteryMillivolts,
      temperature1: temperature1 ?? this.temperature1,
      temperature2: temperature2 ?? this.temperature2,
      wearCode: wearCode ?? this.wearCode,
      modeFlags: modeFlags ?? this.modeFlags,
      raw: raw ?? this.raw,
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
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (batteryPercent.present) {
      map['battery_percent'] = Variable<int>(batteryPercent.value);
    }
    if (batteryMillivolts.present) {
      map['battery_millivolts'] = Variable<int>(batteryMillivolts.value);
    }
    if (temperature1.present) {
      map['temperature1'] = Variable<double>(temperature1.value);
    }
    if (temperature2.present) {
      map['temperature2'] = Variable<double>(temperature2.value);
    }
    if (wearCode.present) {
      map['wear_code'] = Variable<int>(wearCode.value);
    }
    if (modeFlags.present) {
      map['mode_flags'] = Variable<int>(modeFlags.value);
    }
    if (raw.present) {
      map['raw'] = Variable<Uint8List>(raw.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelemetrySnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('batteryPercent: $batteryPercent, ')
          ..write('batteryMillivolts: $batteryMillivolts, ')
          ..write('temperature1: $temperature1, ')
          ..write('temperature2: $temperature2, ')
          ..write('wearCode: $wearCode, ')
          ..write('modeFlags: $modeFlags, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }
}

class $LiveHrSamplesTable extends LiveHrSamples
    with TableInfo<$LiveHrSamplesTable, LiveHrSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiveHrSamplesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bpmMeta = const VerificationMeta('bpm');
  @override
  late final GeneratedColumn<int> bpm = GeneratedColumn<int>(
    'bpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<Uint8List> raw = GeneratedColumn<Uint8List>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, deviceId, capturedAt, bpm, raw];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'live_hr_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<LiveHrSample> instance, {
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
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('bpm')) {
      context.handle(
        _bpmMeta,
        bpm.isAcceptableOrUnknown(data['bpm']!, _bpmMeta),
      );
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LiveHrSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiveHrSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      bpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bpm'],
      ),
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}raw'],
      )!,
    );
  }

  @override
  $LiveHrSamplesTable createAlias(String alias) {
    return $LiveHrSamplesTable(attachedDatabase, alias);
  }
}

class LiveHrSample extends DataClass implements Insertable<LiveHrSample> {
  final int id;
  final String deviceId;
  final DateTime capturedAt;
  final int? bpm;
  final Uint8List raw;
  const LiveHrSample({
    required this.id,
    required this.deviceId,
    required this.capturedAt,
    this.bpm,
    required this.raw,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || bpm != null) {
      map['bpm'] = Variable<int>(bpm);
    }
    map['raw'] = Variable<Uint8List>(raw);
    return map;
  }

  LiveHrSamplesCompanion toCompanion(bool nullToAbsent) {
    return LiveHrSamplesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      capturedAt: Value(capturedAt),
      bpm: bpm == null && nullToAbsent ? const Value.absent() : Value(bpm),
      raw: Value(raw),
    );
  }

  factory LiveHrSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiveHrSample(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      bpm: serializer.fromJson<int?>(json['bpm']),
      raw: serializer.fromJson<Uint8List>(json['raw']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'bpm': serializer.toJson<int?>(bpm),
      'raw': serializer.toJson<Uint8List>(raw),
    };
  }

  LiveHrSample copyWith({
    int? id,
    String? deviceId,
    DateTime? capturedAt,
    Value<int?> bpm = const Value.absent(),
    Uint8List? raw,
  }) => LiveHrSample(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    capturedAt: capturedAt ?? this.capturedAt,
    bpm: bpm.present ? bpm.value : this.bpm,
    raw: raw ?? this.raw,
  );
  LiveHrSample copyWithCompanion(LiveHrSamplesCompanion data) {
    return LiveHrSample(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      bpm: data.bpm.present ? data.bpm.value : this.bpm,
      raw: data.raw.present ? data.raw.value : this.raw,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiveHrSample(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('bpm: $bpm, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, capturedAt, bpm, $driftBlobEquality.hash(raw));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiveHrSample &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.capturedAt == this.capturedAt &&
          other.bpm == this.bpm &&
          $driftBlobEquality.equals(other.raw, this.raw));
}

class LiveHrSamplesCompanion extends UpdateCompanion<LiveHrSample> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> capturedAt;
  final Value<int?> bpm;
  final Value<Uint8List> raw;
  const LiveHrSamplesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.bpm = const Value.absent(),
    this.raw = const Value.absent(),
  });
  LiveHrSamplesCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime capturedAt,
    this.bpm = const Value.absent(),
    required Uint8List raw,
  }) : deviceId = Value(deviceId),
       capturedAt = Value(capturedAt),
       raw = Value(raw);
  static Insertable<LiveHrSample> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? capturedAt,
    Expression<int>? bpm,
    Expression<Uint8List>? raw,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (bpm != null) 'bpm': bpm,
      if (raw != null) 'raw': raw,
    });
  }

  LiveHrSamplesCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? capturedAt,
    Value<int?>? bpm,
    Value<Uint8List>? raw,
  }) {
    return LiveHrSamplesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      capturedAt: capturedAt ?? this.capturedAt,
      bpm: bpm ?? this.bpm,
      raw: raw ?? this.raw,
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
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (bpm.present) {
      map['bpm'] = Variable<int>(bpm.value);
    }
    if (raw.present) {
      map['raw'] = Variable<Uint8List>(raw.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiveHrSamplesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('bpm: $bpm, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }
}

class $EpochsTable extends Epochs with TableInfo<$EpochsTable, Epoch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpochsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bpmMeta = const VerificationMeta('bpm');
  @override
  late final GeneratedColumn<int> bpm = GeneratedColumn<int>(
    'bpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hrvMsMeta = const VerificationMeta('hrvMs');
  @override
  late final GeneratedColumn<int> hrvMs = GeneratedColumn<int>(
    'hrv_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ppgQualityMeta = const VerificationMeta(
    'ppgQuality',
  );
  @override
  late final GeneratedColumn<int> ppgQuality = GeneratedColumn<int>(
    'ppg_quality',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respiratoryRateMeta = const VerificationMeta(
    'respiratoryRate',
  );
  @override
  late final GeneratedColumn<double> respiratoryRate = GeneratedColumn<double>(
    'respiratory_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oxygenPercentMeta = const VerificationMeta(
    'oxygenPercent',
  );
  @override
  late final GeneratedColumn<int> oxygenPercent = GeneratedColumn<int>(
    'oxygen_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oxygenStateMeta = const VerificationMeta(
    'oxygenState',
  );
  @override
  late final GeneratedColumn<String> oxygenState = GeneratedColumn<String>(
    'oxygen_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityMetMeta = const VerificationMeta(
    'activityMet',
  );
  @override
  late final GeneratedColumn<double> activityMet = GeneratedColumn<double>(
    'activity_met',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flagsMeta = const VerificationMeta('flags');
  @override
  late final GeneratedColumn<int> flags = GeneratedColumn<int>(
    'flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<Uint8List> raw = GeneratedColumn<Uint8List>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    cursor,
    endedAt,
    bpm,
    hrvMs,
    ppgQuality,
    respiratoryRate,
    oxygenPercent,
    oxygenState,
    activityMet,
    flags,
    raw,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'epochs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Epoch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('bpm')) {
      context.handle(
        _bpmMeta,
        bpm.isAcceptableOrUnknown(data['bpm']!, _bpmMeta),
      );
    }
    if (data.containsKey('hrv_ms')) {
      context.handle(
        _hrvMsMeta,
        hrvMs.isAcceptableOrUnknown(data['hrv_ms']!, _hrvMsMeta),
      );
    }
    if (data.containsKey('ppg_quality')) {
      context.handle(
        _ppgQualityMeta,
        ppgQuality.isAcceptableOrUnknown(data['ppg_quality']!, _ppgQualityMeta),
      );
    } else if (isInserting) {
      context.missing(_ppgQualityMeta);
    }
    if (data.containsKey('respiratory_rate')) {
      context.handle(
        _respiratoryRateMeta,
        respiratoryRate.isAcceptableOrUnknown(
          data['respiratory_rate']!,
          _respiratoryRateMeta,
        ),
      );
    }
    if (data.containsKey('oxygen_percent')) {
      context.handle(
        _oxygenPercentMeta,
        oxygenPercent.isAcceptableOrUnknown(
          data['oxygen_percent']!,
          _oxygenPercentMeta,
        ),
      );
    }
    if (data.containsKey('oxygen_state')) {
      context.handle(
        _oxygenStateMeta,
        oxygenState.isAcceptableOrUnknown(
          data['oxygen_state']!,
          _oxygenStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oxygenStateMeta);
    }
    if (data.containsKey('activity_met')) {
      context.handle(
        _activityMetMeta,
        activityMet.isAcceptableOrUnknown(
          data['activity_met']!,
          _activityMetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityMetMeta);
    }
    if (data.containsKey('flags')) {
      context.handle(
        _flagsMeta,
        flags.isAcceptableOrUnknown(data['flags']!, _flagsMeta),
      );
    } else if (isInserting) {
      context.missing(_flagsMeta);
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId, cursor};
  @override
  Epoch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Epoch(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      bpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bpm'],
      ),
      hrvMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hrv_ms'],
      ),
      ppgQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ppg_quality'],
      )!,
      respiratoryRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}respiratory_rate'],
      ),
      oxygenPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oxygen_percent'],
      ),
      oxygenState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oxygen_state'],
      )!,
      activityMet: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}activity_met'],
      )!,
      flags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flags'],
      )!,
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}raw'],
      )!,
    );
  }

  @override
  $EpochsTable createAlias(String alias) {
    return $EpochsTable(attachedDatabase, alias);
  }
}

class Epoch extends DataClass implements Insertable<Epoch> {
  final String deviceId;
  final int cursor;
  final DateTime endedAt;
  final int? bpm;
  final int? hrvMs;
  final int ppgQuality;
  final double? respiratoryRate;
  final int? oxygenPercent;
  final String oxygenState;
  final double activityMet;
  final int flags;
  final Uint8List raw;
  const Epoch({
    required this.deviceId,
    required this.cursor,
    required this.endedAt,
    this.bpm,
    this.hrvMs,
    required this.ppgQuality,
    this.respiratoryRate,
    this.oxygenPercent,
    required this.oxygenState,
    required this.activityMet,
    required this.flags,
    required this.raw,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['cursor'] = Variable<int>(cursor);
    map['ended_at'] = Variable<DateTime>(endedAt);
    if (!nullToAbsent || bpm != null) {
      map['bpm'] = Variable<int>(bpm);
    }
    if (!nullToAbsent || hrvMs != null) {
      map['hrv_ms'] = Variable<int>(hrvMs);
    }
    map['ppg_quality'] = Variable<int>(ppgQuality);
    if (!nullToAbsent || respiratoryRate != null) {
      map['respiratory_rate'] = Variable<double>(respiratoryRate);
    }
    if (!nullToAbsent || oxygenPercent != null) {
      map['oxygen_percent'] = Variable<int>(oxygenPercent);
    }
    map['oxygen_state'] = Variable<String>(oxygenState);
    map['activity_met'] = Variable<double>(activityMet);
    map['flags'] = Variable<int>(flags);
    map['raw'] = Variable<Uint8List>(raw);
    return map;
  }

  EpochsCompanion toCompanion(bool nullToAbsent) {
    return EpochsCompanion(
      deviceId: Value(deviceId),
      cursor: Value(cursor),
      endedAt: Value(endedAt),
      bpm: bpm == null && nullToAbsent ? const Value.absent() : Value(bpm),
      hrvMs: hrvMs == null && nullToAbsent
          ? const Value.absent()
          : Value(hrvMs),
      ppgQuality: Value(ppgQuality),
      respiratoryRate: respiratoryRate == null && nullToAbsent
          ? const Value.absent()
          : Value(respiratoryRate),
      oxygenPercent: oxygenPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(oxygenPercent),
      oxygenState: Value(oxygenState),
      activityMet: Value(activityMet),
      flags: Value(flags),
      raw: Value(raw),
    );
  }

  factory Epoch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Epoch(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      cursor: serializer.fromJson<int>(json['cursor']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      bpm: serializer.fromJson<int?>(json['bpm']),
      hrvMs: serializer.fromJson<int?>(json['hrvMs']),
      ppgQuality: serializer.fromJson<int>(json['ppgQuality']),
      respiratoryRate: serializer.fromJson<double?>(json['respiratoryRate']),
      oxygenPercent: serializer.fromJson<int?>(json['oxygenPercent']),
      oxygenState: serializer.fromJson<String>(json['oxygenState']),
      activityMet: serializer.fromJson<double>(json['activityMet']),
      flags: serializer.fromJson<int>(json['flags']),
      raw: serializer.fromJson<Uint8List>(json['raw']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'cursor': serializer.toJson<int>(cursor),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'bpm': serializer.toJson<int?>(bpm),
      'hrvMs': serializer.toJson<int?>(hrvMs),
      'ppgQuality': serializer.toJson<int>(ppgQuality),
      'respiratoryRate': serializer.toJson<double?>(respiratoryRate),
      'oxygenPercent': serializer.toJson<int?>(oxygenPercent),
      'oxygenState': serializer.toJson<String>(oxygenState),
      'activityMet': serializer.toJson<double>(activityMet),
      'flags': serializer.toJson<int>(flags),
      'raw': serializer.toJson<Uint8List>(raw),
    };
  }

  Epoch copyWith({
    String? deviceId,
    int? cursor,
    DateTime? endedAt,
    Value<int?> bpm = const Value.absent(),
    Value<int?> hrvMs = const Value.absent(),
    int? ppgQuality,
    Value<double?> respiratoryRate = const Value.absent(),
    Value<int?> oxygenPercent = const Value.absent(),
    String? oxygenState,
    double? activityMet,
    int? flags,
    Uint8List? raw,
  }) => Epoch(
    deviceId: deviceId ?? this.deviceId,
    cursor: cursor ?? this.cursor,
    endedAt: endedAt ?? this.endedAt,
    bpm: bpm.present ? bpm.value : this.bpm,
    hrvMs: hrvMs.present ? hrvMs.value : this.hrvMs,
    ppgQuality: ppgQuality ?? this.ppgQuality,
    respiratoryRate: respiratoryRate.present
        ? respiratoryRate.value
        : this.respiratoryRate,
    oxygenPercent: oxygenPercent.present
        ? oxygenPercent.value
        : this.oxygenPercent,
    oxygenState: oxygenState ?? this.oxygenState,
    activityMet: activityMet ?? this.activityMet,
    flags: flags ?? this.flags,
    raw: raw ?? this.raw,
  );
  Epoch copyWithCompanion(EpochsCompanion data) {
    return Epoch(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      bpm: data.bpm.present ? data.bpm.value : this.bpm,
      hrvMs: data.hrvMs.present ? data.hrvMs.value : this.hrvMs,
      ppgQuality: data.ppgQuality.present
          ? data.ppgQuality.value
          : this.ppgQuality,
      respiratoryRate: data.respiratoryRate.present
          ? data.respiratoryRate.value
          : this.respiratoryRate,
      oxygenPercent: data.oxygenPercent.present
          ? data.oxygenPercent.value
          : this.oxygenPercent,
      oxygenState: data.oxygenState.present
          ? data.oxygenState.value
          : this.oxygenState,
      activityMet: data.activityMet.present
          ? data.activityMet.value
          : this.activityMet,
      flags: data.flags.present ? data.flags.value : this.flags,
      raw: data.raw.present ? data.raw.value : this.raw,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Epoch(')
          ..write('deviceId: $deviceId, ')
          ..write('cursor: $cursor, ')
          ..write('endedAt: $endedAt, ')
          ..write('bpm: $bpm, ')
          ..write('hrvMs: $hrvMs, ')
          ..write('ppgQuality: $ppgQuality, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('oxygenPercent: $oxygenPercent, ')
          ..write('oxygenState: $oxygenState, ')
          ..write('activityMet: $activityMet, ')
          ..write('flags: $flags, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deviceId,
    cursor,
    endedAt,
    bpm,
    hrvMs,
    ppgQuality,
    respiratoryRate,
    oxygenPercent,
    oxygenState,
    activityMet,
    flags,
    $driftBlobEquality.hash(raw),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Epoch &&
          other.deviceId == this.deviceId &&
          other.cursor == this.cursor &&
          other.endedAt == this.endedAt &&
          other.bpm == this.bpm &&
          other.hrvMs == this.hrvMs &&
          other.ppgQuality == this.ppgQuality &&
          other.respiratoryRate == this.respiratoryRate &&
          other.oxygenPercent == this.oxygenPercent &&
          other.oxygenState == this.oxygenState &&
          other.activityMet == this.activityMet &&
          other.flags == this.flags &&
          $driftBlobEquality.equals(other.raw, this.raw));
}

class EpochsCompanion extends UpdateCompanion<Epoch> {
  final Value<String> deviceId;
  final Value<int> cursor;
  final Value<DateTime> endedAt;
  final Value<int?> bpm;
  final Value<int?> hrvMs;
  final Value<int> ppgQuality;
  final Value<double?> respiratoryRate;
  final Value<int?> oxygenPercent;
  final Value<String> oxygenState;
  final Value<double> activityMet;
  final Value<int> flags;
  final Value<Uint8List> raw;
  final Value<int> rowid;
  const EpochsCompanion({
    this.deviceId = const Value.absent(),
    this.cursor = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.bpm = const Value.absent(),
    this.hrvMs = const Value.absent(),
    this.ppgQuality = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.oxygenPercent = const Value.absent(),
    this.oxygenState = const Value.absent(),
    this.activityMet = const Value.absent(),
    this.flags = const Value.absent(),
    this.raw = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpochsCompanion.insert({
    required String deviceId,
    required int cursor,
    required DateTime endedAt,
    this.bpm = const Value.absent(),
    this.hrvMs = const Value.absent(),
    required int ppgQuality,
    this.respiratoryRate = const Value.absent(),
    this.oxygenPercent = const Value.absent(),
    required String oxygenState,
    required double activityMet,
    required int flags,
    required Uint8List raw,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       cursor = Value(cursor),
       endedAt = Value(endedAt),
       ppgQuality = Value(ppgQuality),
       oxygenState = Value(oxygenState),
       activityMet = Value(activityMet),
       flags = Value(flags),
       raw = Value(raw);
  static Insertable<Epoch> custom({
    Expression<String>? deviceId,
    Expression<int>? cursor,
    Expression<DateTime>? endedAt,
    Expression<int>? bpm,
    Expression<int>? hrvMs,
    Expression<int>? ppgQuality,
    Expression<double>? respiratoryRate,
    Expression<int>? oxygenPercent,
    Expression<String>? oxygenState,
    Expression<double>? activityMet,
    Expression<int>? flags,
    Expression<Uint8List>? raw,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (cursor != null) 'cursor': cursor,
      if (endedAt != null) 'ended_at': endedAt,
      if (bpm != null) 'bpm': bpm,
      if (hrvMs != null) 'hrv_ms': hrvMs,
      if (ppgQuality != null) 'ppg_quality': ppgQuality,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (oxygenPercent != null) 'oxygen_percent': oxygenPercent,
      if (oxygenState != null) 'oxygen_state': oxygenState,
      if (activityMet != null) 'activity_met': activityMet,
      if (flags != null) 'flags': flags,
      if (raw != null) 'raw': raw,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpochsCompanion copyWith({
    Value<String>? deviceId,
    Value<int>? cursor,
    Value<DateTime>? endedAt,
    Value<int?>? bpm,
    Value<int?>? hrvMs,
    Value<int>? ppgQuality,
    Value<double?>? respiratoryRate,
    Value<int?>? oxygenPercent,
    Value<String>? oxygenState,
    Value<double>? activityMet,
    Value<int>? flags,
    Value<Uint8List>? raw,
    Value<int>? rowid,
  }) {
    return EpochsCompanion(
      deviceId: deviceId ?? this.deviceId,
      cursor: cursor ?? this.cursor,
      endedAt: endedAt ?? this.endedAt,
      bpm: bpm ?? this.bpm,
      hrvMs: hrvMs ?? this.hrvMs,
      ppgQuality: ppgQuality ?? this.ppgQuality,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      oxygenPercent: oxygenPercent ?? this.oxygenPercent,
      oxygenState: oxygenState ?? this.oxygenState,
      activityMet: activityMet ?? this.activityMet,
      flags: flags ?? this.flags,
      raw: raw ?? this.raw,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (bpm.present) {
      map['bpm'] = Variable<int>(bpm.value);
    }
    if (hrvMs.present) {
      map['hrv_ms'] = Variable<int>(hrvMs.value);
    }
    if (ppgQuality.present) {
      map['ppg_quality'] = Variable<int>(ppgQuality.value);
    }
    if (respiratoryRate.present) {
      map['respiratory_rate'] = Variable<double>(respiratoryRate.value);
    }
    if (oxygenPercent.present) {
      map['oxygen_percent'] = Variable<int>(oxygenPercent.value);
    }
    if (oxygenState.present) {
      map['oxygen_state'] = Variable<String>(oxygenState.value);
    }
    if (activityMet.present) {
      map['activity_met'] = Variable<double>(activityMet.value);
    }
    if (flags.present) {
      map['flags'] = Variable<int>(flags.value);
    }
    if (raw.present) {
      map['raw'] = Variable<Uint8List>(raw.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpochsCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('cursor: $cursor, ')
          ..write('endedAt: $endedAt, ')
          ..write('bpm: $bpm, ')
          ..write('hrvMs: $hrvMs, ')
          ..write('ppgQuality: $ppgQuality, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('oxygenPercent: $oxygenPercent, ')
          ..write('oxygenState: $oxygenState, ')
          ..write('activityMet: $activityMet, ')
          ..write('flags: $flags, ')
          ..write('raw: $raw, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThermalBlocksTable extends ThermalBlocks
    with TableInfo<$ThermalBlocksTable, StoredThermalBlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThermalBlocksTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtypeMeta = const VerificationMeta(
    'subtype',
  );
  @override
  late final GeneratedColumn<int> subtype = GeneratedColumn<int>(
    'subtype',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batteryPercentMeta = const VerificationMeta(
    'batteryPercent',
  );
  @override
  late final GeneratedColumn<int> batteryPercent = GeneratedColumn<int>(
    'battery_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityMeta = const VerificationMeta(
    'activity',
  );
  @override
  late final GeneratedColumn<bool> activity = GeneratedColumn<bool>(
    'activity',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activity" IN (0, 1))',
    ),
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeTimeRawMeta = const VerificationMeta(
    'activeTimeRaw',
  );
  @override
  late final GeneratedColumn<int> activeTimeRaw = GeneratedColumn<int>(
    'active_time_raw',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meanOuterTemperatureMeta =
      const VerificationMeta('meanOuterTemperature');
  @override
  late final GeneratedColumn<double> meanOuterTemperature =
      GeneratedColumn<double>(
        'mean_outer_temperature',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _meanInnerTemperatureMeta =
      const VerificationMeta('meanInnerTemperature');
  @override
  late final GeneratedColumn<double> meanInnerTemperature =
      GeneratedColumn<double>(
        'mean_inner_temperature',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<Uint8List> raw = GeneratedColumn<Uint8List>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    cursor,
    endedAt,
    subtype,
    batteryPercent,
    activity,
    steps,
    activeTimeRaw,
    meanOuterTemperature,
    meanInnerTemperature,
    raw,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thermal_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredThermalBlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('subtype')) {
      context.handle(
        _subtypeMeta,
        subtype.isAcceptableOrUnknown(data['subtype']!, _subtypeMeta),
      );
    } else if (isInserting) {
      context.missing(_subtypeMeta);
    }
    if (data.containsKey('battery_percent')) {
      context.handle(
        _batteryPercentMeta,
        batteryPercent.isAcceptableOrUnknown(
          data['battery_percent']!,
          _batteryPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batteryPercentMeta);
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    } else if (isInserting) {
      context.missing(_activityMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('active_time_raw')) {
      context.handle(
        _activeTimeRawMeta,
        activeTimeRaw.isAcceptableOrUnknown(
          data['active_time_raw']!,
          _activeTimeRawMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeTimeRawMeta);
    }
    if (data.containsKey('mean_outer_temperature')) {
      context.handle(
        _meanOuterTemperatureMeta,
        meanOuterTemperature.isAcceptableOrUnknown(
          data['mean_outer_temperature']!,
          _meanOuterTemperatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meanOuterTemperatureMeta);
    }
    if (data.containsKey('mean_inner_temperature')) {
      context.handle(
        _meanInnerTemperatureMeta,
        meanInnerTemperature.isAcceptableOrUnknown(
          data['mean_inner_temperature']!,
          _meanInnerTemperatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meanInnerTemperatureMeta);
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId, cursor};
  @override
  StoredThermalBlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredThermalBlock(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      subtype: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtype'],
      )!,
      batteryPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_percent'],
      )!,
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activity'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      )!,
      activeTimeRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_time_raw'],
      )!,
      meanOuterTemperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mean_outer_temperature'],
      )!,
      meanInnerTemperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mean_inner_temperature'],
      )!,
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}raw'],
      )!,
    );
  }

  @override
  $ThermalBlocksTable createAlias(String alias) {
    return $ThermalBlocksTable(attachedDatabase, alias);
  }
}

class StoredThermalBlock extends DataClass
    implements Insertable<StoredThermalBlock> {
  final String deviceId;
  final int cursor;
  final DateTime endedAt;
  final int subtype;
  final int batteryPercent;
  final bool activity;
  final int steps;
  final int activeTimeRaw;
  final double meanOuterTemperature;
  final double meanInnerTemperature;
  final Uint8List raw;
  const StoredThermalBlock({
    required this.deviceId,
    required this.cursor,
    required this.endedAt,
    required this.subtype,
    required this.batteryPercent,
    required this.activity,
    required this.steps,
    required this.activeTimeRaw,
    required this.meanOuterTemperature,
    required this.meanInnerTemperature,
    required this.raw,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['cursor'] = Variable<int>(cursor);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['subtype'] = Variable<int>(subtype);
    map['battery_percent'] = Variable<int>(batteryPercent);
    map['activity'] = Variable<bool>(activity);
    map['steps'] = Variable<int>(steps);
    map['active_time_raw'] = Variable<int>(activeTimeRaw);
    map['mean_outer_temperature'] = Variable<double>(meanOuterTemperature);
    map['mean_inner_temperature'] = Variable<double>(meanInnerTemperature);
    map['raw'] = Variable<Uint8List>(raw);
    return map;
  }

  ThermalBlocksCompanion toCompanion(bool nullToAbsent) {
    return ThermalBlocksCompanion(
      deviceId: Value(deviceId),
      cursor: Value(cursor),
      endedAt: Value(endedAt),
      subtype: Value(subtype),
      batteryPercent: Value(batteryPercent),
      activity: Value(activity),
      steps: Value(steps),
      activeTimeRaw: Value(activeTimeRaw),
      meanOuterTemperature: Value(meanOuterTemperature),
      meanInnerTemperature: Value(meanInnerTemperature),
      raw: Value(raw),
    );
  }

  factory StoredThermalBlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredThermalBlock(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      cursor: serializer.fromJson<int>(json['cursor']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      subtype: serializer.fromJson<int>(json['subtype']),
      batteryPercent: serializer.fromJson<int>(json['batteryPercent']),
      activity: serializer.fromJson<bool>(json['activity']),
      steps: serializer.fromJson<int>(json['steps']),
      activeTimeRaw: serializer.fromJson<int>(json['activeTimeRaw']),
      meanOuterTemperature: serializer.fromJson<double>(
        json['meanOuterTemperature'],
      ),
      meanInnerTemperature: serializer.fromJson<double>(
        json['meanInnerTemperature'],
      ),
      raw: serializer.fromJson<Uint8List>(json['raw']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'cursor': serializer.toJson<int>(cursor),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'subtype': serializer.toJson<int>(subtype),
      'batteryPercent': serializer.toJson<int>(batteryPercent),
      'activity': serializer.toJson<bool>(activity),
      'steps': serializer.toJson<int>(steps),
      'activeTimeRaw': serializer.toJson<int>(activeTimeRaw),
      'meanOuterTemperature': serializer.toJson<double>(meanOuterTemperature),
      'meanInnerTemperature': serializer.toJson<double>(meanInnerTemperature),
      'raw': serializer.toJson<Uint8List>(raw),
    };
  }

  StoredThermalBlock copyWith({
    String? deviceId,
    int? cursor,
    DateTime? endedAt,
    int? subtype,
    int? batteryPercent,
    bool? activity,
    int? steps,
    int? activeTimeRaw,
    double? meanOuterTemperature,
    double? meanInnerTemperature,
    Uint8List? raw,
  }) => StoredThermalBlock(
    deviceId: deviceId ?? this.deviceId,
    cursor: cursor ?? this.cursor,
    endedAt: endedAt ?? this.endedAt,
    subtype: subtype ?? this.subtype,
    batteryPercent: batteryPercent ?? this.batteryPercent,
    activity: activity ?? this.activity,
    steps: steps ?? this.steps,
    activeTimeRaw: activeTimeRaw ?? this.activeTimeRaw,
    meanOuterTemperature: meanOuterTemperature ?? this.meanOuterTemperature,
    meanInnerTemperature: meanInnerTemperature ?? this.meanInnerTemperature,
    raw: raw ?? this.raw,
  );
  StoredThermalBlock copyWithCompanion(ThermalBlocksCompanion data) {
    return StoredThermalBlock(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      subtype: data.subtype.present ? data.subtype.value : this.subtype,
      batteryPercent: data.batteryPercent.present
          ? data.batteryPercent.value
          : this.batteryPercent,
      activity: data.activity.present ? data.activity.value : this.activity,
      steps: data.steps.present ? data.steps.value : this.steps,
      activeTimeRaw: data.activeTimeRaw.present
          ? data.activeTimeRaw.value
          : this.activeTimeRaw,
      meanOuterTemperature: data.meanOuterTemperature.present
          ? data.meanOuterTemperature.value
          : this.meanOuterTemperature,
      meanInnerTemperature: data.meanInnerTemperature.present
          ? data.meanInnerTemperature.value
          : this.meanInnerTemperature,
      raw: data.raw.present ? data.raw.value : this.raw,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredThermalBlock(')
          ..write('deviceId: $deviceId, ')
          ..write('cursor: $cursor, ')
          ..write('endedAt: $endedAt, ')
          ..write('subtype: $subtype, ')
          ..write('batteryPercent: $batteryPercent, ')
          ..write('activity: $activity, ')
          ..write('steps: $steps, ')
          ..write('activeTimeRaw: $activeTimeRaw, ')
          ..write('meanOuterTemperature: $meanOuterTemperature, ')
          ..write('meanInnerTemperature: $meanInnerTemperature, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deviceId,
    cursor,
    endedAt,
    subtype,
    batteryPercent,
    activity,
    steps,
    activeTimeRaw,
    meanOuterTemperature,
    meanInnerTemperature,
    $driftBlobEquality.hash(raw),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredThermalBlock &&
          other.deviceId == this.deviceId &&
          other.cursor == this.cursor &&
          other.endedAt == this.endedAt &&
          other.subtype == this.subtype &&
          other.batteryPercent == this.batteryPercent &&
          other.activity == this.activity &&
          other.steps == this.steps &&
          other.activeTimeRaw == this.activeTimeRaw &&
          other.meanOuterTemperature == this.meanOuterTemperature &&
          other.meanInnerTemperature == this.meanInnerTemperature &&
          $driftBlobEquality.equals(other.raw, this.raw));
}

class ThermalBlocksCompanion extends UpdateCompanion<StoredThermalBlock> {
  final Value<String> deviceId;
  final Value<int> cursor;
  final Value<DateTime> endedAt;
  final Value<int> subtype;
  final Value<int> batteryPercent;
  final Value<bool> activity;
  final Value<int> steps;
  final Value<int> activeTimeRaw;
  final Value<double> meanOuterTemperature;
  final Value<double> meanInnerTemperature;
  final Value<Uint8List> raw;
  final Value<int> rowid;
  const ThermalBlocksCompanion({
    this.deviceId = const Value.absent(),
    this.cursor = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.subtype = const Value.absent(),
    this.batteryPercent = const Value.absent(),
    this.activity = const Value.absent(),
    this.steps = const Value.absent(),
    this.activeTimeRaw = const Value.absent(),
    this.meanOuterTemperature = const Value.absent(),
    this.meanInnerTemperature = const Value.absent(),
    this.raw = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThermalBlocksCompanion.insert({
    required String deviceId,
    required int cursor,
    required DateTime endedAt,
    required int subtype,
    required int batteryPercent,
    required bool activity,
    required int steps,
    required int activeTimeRaw,
    required double meanOuterTemperature,
    required double meanInnerTemperature,
    required Uint8List raw,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       cursor = Value(cursor),
       endedAt = Value(endedAt),
       subtype = Value(subtype),
       batteryPercent = Value(batteryPercent),
       activity = Value(activity),
       steps = Value(steps),
       activeTimeRaw = Value(activeTimeRaw),
       meanOuterTemperature = Value(meanOuterTemperature),
       meanInnerTemperature = Value(meanInnerTemperature),
       raw = Value(raw);
  static Insertable<StoredThermalBlock> custom({
    Expression<String>? deviceId,
    Expression<int>? cursor,
    Expression<DateTime>? endedAt,
    Expression<int>? subtype,
    Expression<int>? batteryPercent,
    Expression<bool>? activity,
    Expression<int>? steps,
    Expression<int>? activeTimeRaw,
    Expression<double>? meanOuterTemperature,
    Expression<double>? meanInnerTemperature,
    Expression<Uint8List>? raw,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (cursor != null) 'cursor': cursor,
      if (endedAt != null) 'ended_at': endedAt,
      if (subtype != null) 'subtype': subtype,
      if (batteryPercent != null) 'battery_percent': batteryPercent,
      if (activity != null) 'activity': activity,
      if (steps != null) 'steps': steps,
      if (activeTimeRaw != null) 'active_time_raw': activeTimeRaw,
      if (meanOuterTemperature != null)
        'mean_outer_temperature': meanOuterTemperature,
      if (meanInnerTemperature != null)
        'mean_inner_temperature': meanInnerTemperature,
      if (raw != null) 'raw': raw,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThermalBlocksCompanion copyWith({
    Value<String>? deviceId,
    Value<int>? cursor,
    Value<DateTime>? endedAt,
    Value<int>? subtype,
    Value<int>? batteryPercent,
    Value<bool>? activity,
    Value<int>? steps,
    Value<int>? activeTimeRaw,
    Value<double>? meanOuterTemperature,
    Value<double>? meanInnerTemperature,
    Value<Uint8List>? raw,
    Value<int>? rowid,
  }) {
    return ThermalBlocksCompanion(
      deviceId: deviceId ?? this.deviceId,
      cursor: cursor ?? this.cursor,
      endedAt: endedAt ?? this.endedAt,
      subtype: subtype ?? this.subtype,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      activity: activity ?? this.activity,
      steps: steps ?? this.steps,
      activeTimeRaw: activeTimeRaw ?? this.activeTimeRaw,
      meanOuterTemperature: meanOuterTemperature ?? this.meanOuterTemperature,
      meanInnerTemperature: meanInnerTemperature ?? this.meanInnerTemperature,
      raw: raw ?? this.raw,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (subtype.present) {
      map['subtype'] = Variable<int>(subtype.value);
    }
    if (batteryPercent.present) {
      map['battery_percent'] = Variable<int>(batteryPercent.value);
    }
    if (activity.present) {
      map['activity'] = Variable<bool>(activity.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (activeTimeRaw.present) {
      map['active_time_raw'] = Variable<int>(activeTimeRaw.value);
    }
    if (meanOuterTemperature.present) {
      map['mean_outer_temperature'] = Variable<double>(
        meanOuterTemperature.value,
      );
    }
    if (meanInnerTemperature.present) {
      map['mean_inner_temperature'] = Variable<double>(
        meanInnerTemperature.value,
      );
    }
    if (raw.present) {
      map['raw'] = Variable<Uint8List>(raw.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThermalBlocksCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('cursor: $cursor, ')
          ..write('endedAt: $endedAt, ')
          ..write('subtype: $subtype, ')
          ..write('batteryPercent: $batteryPercent, ')
          ..write('activity: $activity, ')
          ..write('steps: $steps, ')
          ..write('activeTimeRaw: $activeTimeRaw, ')
          ..write('meanOuterTemperature: $meanOuterTemperature, ')
          ..write('meanInnerTemperature: $meanInnerTemperature, ')
          ..write('raw: $raw, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DrainSessionsTable extends DrainSessions
    with TableInfo<$DrainSessionsTable, DrainSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrainSessionsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedCursorMeta = const VerificationMeta(
    'requestedCursor',
  );
  @override
  late final GeneratedColumn<int> requestedCursor = GeneratedColumn<int>(
    'requested_cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<int> channel = GeneratedColumn<int>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagesAcknowledgedMeta = const VerificationMeta(
    'pagesAcknowledged',
  );
  @override
  late final GeneratedColumn<int> pagesAcknowledged = GeneratedColumn<int>(
    'pages_acknowledged',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recordsAcknowledgedMeta =
      const VerificationMeta('recordsAcknowledged');
  @override
  late final GeneratedColumn<int> recordsAcknowledged = GeneratedColumn<int>(
    'records_acknowledged',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    startedAt,
    finishedAt,
    requestedCursor,
    channel,
    state,
    pagesAcknowledged,
    recordsAcknowledged,
    detail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drain_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DrainSession> instance, {
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
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('requested_cursor')) {
      context.handle(
        _requestedCursorMeta,
        requestedCursor.isAcceptableOrUnknown(
          data['requested_cursor']!,
          _requestedCursorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedCursorMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    } else if (isInserting) {
      context.missing(_channelMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('pages_acknowledged')) {
      context.handle(
        _pagesAcknowledgedMeta,
        pagesAcknowledged.isAcceptableOrUnknown(
          data['pages_acknowledged']!,
          _pagesAcknowledgedMeta,
        ),
      );
    }
    if (data.containsKey('records_acknowledged')) {
      context.handle(
        _recordsAcknowledgedMeta,
        recordsAcknowledged.isAcceptableOrUnknown(
          data['records_acknowledged']!,
          _recordsAcknowledgedMeta,
        ),
      );
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DrainSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrainSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      requestedCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_cursor'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}channel'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      pagesAcknowledged: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_acknowledged'],
      )!,
      recordsAcknowledged: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}records_acknowledged'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
    );
  }

  @override
  $DrainSessionsTable createAlias(String alias) {
    return $DrainSessionsTable(attachedDatabase, alias);
  }
}

class DrainSession extends DataClass implements Insertable<DrainSession> {
  final int id;
  final String deviceId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int requestedCursor;
  final int channel;
  final String state;
  final int pagesAcknowledged;
  final int recordsAcknowledged;
  final String? detail;
  const DrainSession({
    required this.id,
    required this.deviceId,
    required this.startedAt,
    this.finishedAt,
    required this.requestedCursor,
    required this.channel,
    required this.state,
    required this.pagesAcknowledged,
    required this.recordsAcknowledged,
    this.detail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['requested_cursor'] = Variable<int>(requestedCursor);
    map['channel'] = Variable<int>(channel);
    map['state'] = Variable<String>(state);
    map['pages_acknowledged'] = Variable<int>(pagesAcknowledged);
    map['records_acknowledged'] = Variable<int>(recordsAcknowledged);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  DrainSessionsCompanion toCompanion(bool nullToAbsent) {
    return DrainSessionsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      requestedCursor: Value(requestedCursor),
      channel: Value(channel),
      state: Value(state),
      pagesAcknowledged: Value(pagesAcknowledged),
      recordsAcknowledged: Value(recordsAcknowledged),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
    );
  }

  factory DrainSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrainSession(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      requestedCursor: serializer.fromJson<int>(json['requestedCursor']),
      channel: serializer.fromJson<int>(json['channel']),
      state: serializer.fromJson<String>(json['state']),
      pagesAcknowledged: serializer.fromJson<int>(json['pagesAcknowledged']),
      recordsAcknowledged: serializer.fromJson<int>(
        json['recordsAcknowledged'],
      ),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'requestedCursor': serializer.toJson<int>(requestedCursor),
      'channel': serializer.toJson<int>(channel),
      'state': serializer.toJson<String>(state),
      'pagesAcknowledged': serializer.toJson<int>(pagesAcknowledged),
      'recordsAcknowledged': serializer.toJson<int>(recordsAcknowledged),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  DrainSession copyWith({
    int? id,
    String? deviceId,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    int? requestedCursor,
    int? channel,
    String? state,
    int? pagesAcknowledged,
    int? recordsAcknowledged,
    Value<String?> detail = const Value.absent(),
  }) => DrainSession(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    requestedCursor: requestedCursor ?? this.requestedCursor,
    channel: channel ?? this.channel,
    state: state ?? this.state,
    pagesAcknowledged: pagesAcknowledged ?? this.pagesAcknowledged,
    recordsAcknowledged: recordsAcknowledged ?? this.recordsAcknowledged,
    detail: detail.present ? detail.value : this.detail,
  );
  DrainSession copyWithCompanion(DrainSessionsCompanion data) {
    return DrainSession(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      requestedCursor: data.requestedCursor.present
          ? data.requestedCursor.value
          : this.requestedCursor,
      channel: data.channel.present ? data.channel.value : this.channel,
      state: data.state.present ? data.state.value : this.state,
      pagesAcknowledged: data.pagesAcknowledged.present
          ? data.pagesAcknowledged.value
          : this.pagesAcknowledged,
      recordsAcknowledged: data.recordsAcknowledged.present
          ? data.recordsAcknowledged.value
          : this.recordsAcknowledged,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrainSession(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('requestedCursor: $requestedCursor, ')
          ..write('channel: $channel, ')
          ..write('state: $state, ')
          ..write('pagesAcknowledged: $pagesAcknowledged, ')
          ..write('recordsAcknowledged: $recordsAcknowledged, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    startedAt,
    finishedAt,
    requestedCursor,
    channel,
    state,
    pagesAcknowledged,
    recordsAcknowledged,
    detail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrainSession &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.requestedCursor == this.requestedCursor &&
          other.channel == this.channel &&
          other.state == this.state &&
          other.pagesAcknowledged == this.pagesAcknowledged &&
          other.recordsAcknowledged == this.recordsAcknowledged &&
          other.detail == this.detail);
}

class DrainSessionsCompanion extends UpdateCompanion<DrainSession> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> requestedCursor;
  final Value<int> channel;
  final Value<String> state;
  final Value<int> pagesAcknowledged;
  final Value<int> recordsAcknowledged;
  final Value<String?> detail;
  const DrainSessionsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.requestedCursor = const Value.absent(),
    this.channel = const Value.absent(),
    this.state = const Value.absent(),
    this.pagesAcknowledged = const Value.absent(),
    this.recordsAcknowledged = const Value.absent(),
    this.detail = const Value.absent(),
  });
  DrainSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    required int requestedCursor,
    required int channel,
    required String state,
    this.pagesAcknowledged = const Value.absent(),
    this.recordsAcknowledged = const Value.absent(),
    this.detail = const Value.absent(),
  }) : deviceId = Value(deviceId),
       startedAt = Value(startedAt),
       requestedCursor = Value(requestedCursor),
       channel = Value(channel),
       state = Value(state);
  static Insertable<DrainSession> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? requestedCursor,
    Expression<int>? channel,
    Expression<String>? state,
    Expression<int>? pagesAcknowledged,
    Expression<int>? recordsAcknowledged,
    Expression<String>? detail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (requestedCursor != null) 'requested_cursor': requestedCursor,
      if (channel != null) 'channel': channel,
      if (state != null) 'state': state,
      if (pagesAcknowledged != null) 'pages_acknowledged': pagesAcknowledged,
      if (recordsAcknowledged != null)
        'records_acknowledged': recordsAcknowledged,
      if (detail != null) 'detail': detail,
    });
  }

  DrainSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? requestedCursor,
    Value<int>? channel,
    Value<String>? state,
    Value<int>? pagesAcknowledged,
    Value<int>? recordsAcknowledged,
    Value<String?>? detail,
  }) {
    return DrainSessionsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      requestedCursor: requestedCursor ?? this.requestedCursor,
      channel: channel ?? this.channel,
      state: state ?? this.state,
      pagesAcknowledged: pagesAcknowledged ?? this.pagesAcknowledged,
      recordsAcknowledged: recordsAcknowledged ?? this.recordsAcknowledged,
      detail: detail ?? this.detail,
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
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (requestedCursor.present) {
      map['requested_cursor'] = Variable<int>(requestedCursor.value);
    }
    if (channel.present) {
      map['channel'] = Variable<int>(channel.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (pagesAcknowledged.present) {
      map['pages_acknowledged'] = Variable<int>(pagesAcknowledged.value);
    }
    if (recordsAcknowledged.present) {
      map['records_acknowledged'] = Variable<int>(recordsAcknowledged.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrainSessionsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('requestedCursor: $requestedCursor, ')
          ..write('channel: $channel, ')
          ..write('state: $state, ')
          ..write('pagesAcknowledged: $pagesAcknowledged, ')
          ..write('recordsAcknowledged: $recordsAcknowledged, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _opcodeMeta = const VerificationMeta('opcode');
  @override
  late final GeneratedColumn<int> opcode = GeneratedColumn<int>(
    'opcode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAcknowledgedCursorMeta =
      const VerificationMeta('lastAcknowledgedCursor');
  @override
  late final GeneratedColumn<int> lastAcknowledgedCursor = GeneratedColumn<int>(
    'last_acknowledged_cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    opcode,
    lastAcknowledgedCursor,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('opcode')) {
      context.handle(
        _opcodeMeta,
        opcode.isAcceptableOrUnknown(data['opcode']!, _opcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_opcodeMeta);
    }
    if (data.containsKey('last_acknowledged_cursor')) {
      context.handle(
        _lastAcknowledgedCursorMeta,
        lastAcknowledgedCursor.isAcceptableOrUnknown(
          data['last_acknowledged_cursor']!,
          _lastAcknowledgedCursorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAcknowledgedCursorMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId, opcode};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      opcode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opcode'],
      )!,
      lastAcknowledgedCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_acknowledged_cursor'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String deviceId;
  final int opcode;
  final int lastAcknowledgedCursor;
  final DateTime updatedAt;
  const SyncCursor({
    required this.deviceId,
    required this.opcode,
    required this.lastAcknowledgedCursor,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['opcode'] = Variable<int>(opcode);
    map['last_acknowledged_cursor'] = Variable<int>(lastAcknowledgedCursor);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      deviceId: Value(deviceId),
      opcode: Value(opcode),
      lastAcknowledgedCursor: Value(lastAcknowledgedCursor),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      opcode: serializer.fromJson<int>(json['opcode']),
      lastAcknowledgedCursor: serializer.fromJson<int>(
        json['lastAcknowledgedCursor'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'opcode': serializer.toJson<int>(opcode),
      'lastAcknowledgedCursor': serializer.toJson<int>(lastAcknowledgedCursor),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncCursor copyWith({
    String? deviceId,
    int? opcode,
    int? lastAcknowledgedCursor,
    DateTime? updatedAt,
  }) => SyncCursor(
    deviceId: deviceId ?? this.deviceId,
    opcode: opcode ?? this.opcode,
    lastAcknowledgedCursor:
        lastAcknowledgedCursor ?? this.lastAcknowledgedCursor,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      opcode: data.opcode.present ? data.opcode.value : this.opcode,
      lastAcknowledgedCursor: data.lastAcknowledgedCursor.present
          ? data.lastAcknowledgedCursor.value
          : this.lastAcknowledgedCursor,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('deviceId: $deviceId, ')
          ..write('opcode: $opcode, ')
          ..write('lastAcknowledgedCursor: $lastAcknowledgedCursor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(deviceId, opcode, lastAcknowledgedCursor, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.deviceId == this.deviceId &&
          other.opcode == this.opcode &&
          other.lastAcknowledgedCursor == this.lastAcknowledgedCursor &&
          other.updatedAt == this.updatedAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> deviceId;
  final Value<int> opcode;
  final Value<int> lastAcknowledgedCursor;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.deviceId = const Value.absent(),
    this.opcode = const Value.absent(),
    this.lastAcknowledgedCursor = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String deviceId,
    required int opcode,
    required int lastAcknowledgedCursor,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       opcode = Value(opcode),
       lastAcknowledgedCursor = Value(lastAcknowledgedCursor),
       updatedAt = Value(updatedAt);
  static Insertable<SyncCursor> custom({
    Expression<String>? deviceId,
    Expression<int>? opcode,
    Expression<int>? lastAcknowledgedCursor,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (opcode != null) 'opcode': opcode,
      if (lastAcknowledgedCursor != null)
        'last_acknowledged_cursor': lastAcknowledgedCursor,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? deviceId,
    Value<int>? opcode,
    Value<int>? lastAcknowledgedCursor,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      deviceId: deviceId ?? this.deviceId,
      opcode: opcode ?? this.opcode,
      lastAcknowledgedCursor:
          lastAcknowledgedCursor ?? this.lastAcknowledgedCursor,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (opcode.present) {
      map['opcode'] = Variable<int>(opcode.value);
    }
    if (lastAcknowledgedCursor.present) {
      map['last_acknowledged_cursor'] = Variable<int>(
        lastAcknowledgedCursor.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('opcode: $opcode, ')
          ..write('lastAcknowledgedCursor: $lastAcknowledgedCursor, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RawHistoryPagesTable extends RawHistoryPages
    with TableInfo<$RawHistoryPagesTable, RawHistoryPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RawHistoryPagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drain_sessions (id)',
    ),
  );
  static const VerificationMeta _opcodeMeta = const VerificationMeta('opcode');
  @override
  late final GeneratedColumn<int> opcode = GeneratedColumn<int>(
    'opcode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingMeta = const VerificationMeta(
    'remaining',
  );
  @override
  late final GeneratedColumn<int> remaining = GeneratedColumn<int>(
    'remaining',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<Uint8List> raw = GeneratedColumn<Uint8List>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    opcode,
    remaining,
    receivedAt,
    acknowledged,
    raw,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'raw_history_pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawHistoryPage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('opcode')) {
      context.handle(
        _opcodeMeta,
        opcode.isAcceptableOrUnknown(data['opcode']!, _opcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_opcodeMeta);
    }
    if (data.containsKey('remaining')) {
      context.handle(
        _remainingMeta,
        remaining.isAcceptableOrUnknown(data['remaining']!, _remainingMeta),
      );
    } else if (isInserting) {
      context.missing(_remainingMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
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
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawHistoryPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawHistoryPage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      opcode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opcode'],
      )!,
      remaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      acknowledged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}acknowledged'],
      )!,
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}raw'],
      )!,
    );
  }

  @override
  $RawHistoryPagesTable createAlias(String alias) {
    return $RawHistoryPagesTable(attachedDatabase, alias);
  }
}

class RawHistoryPage extends DataClass implements Insertable<RawHistoryPage> {
  final int id;
  final int sessionId;
  final int opcode;
  final int remaining;
  final DateTime receivedAt;
  final bool acknowledged;
  final Uint8List raw;
  const RawHistoryPage({
    required this.id,
    required this.sessionId,
    required this.opcode,
    required this.remaining,
    required this.receivedAt,
    required this.acknowledged,
    required this.raw,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['opcode'] = Variable<int>(opcode);
    map['remaining'] = Variable<int>(remaining);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['acknowledged'] = Variable<bool>(acknowledged);
    map['raw'] = Variable<Uint8List>(raw);
    return map;
  }

  RawHistoryPagesCompanion toCompanion(bool nullToAbsent) {
    return RawHistoryPagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      opcode: Value(opcode),
      remaining: Value(remaining),
      receivedAt: Value(receivedAt),
      acknowledged: Value(acknowledged),
      raw: Value(raw),
    );
  }

  factory RawHistoryPage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawHistoryPage(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      opcode: serializer.fromJson<int>(json['opcode']),
      remaining: serializer.fromJson<int>(json['remaining']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      acknowledged: serializer.fromJson<bool>(json['acknowledged']),
      raw: serializer.fromJson<Uint8List>(json['raw']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'opcode': serializer.toJson<int>(opcode),
      'remaining': serializer.toJson<int>(remaining),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'acknowledged': serializer.toJson<bool>(acknowledged),
      'raw': serializer.toJson<Uint8List>(raw),
    };
  }

  RawHistoryPage copyWith({
    int? id,
    int? sessionId,
    int? opcode,
    int? remaining,
    DateTime? receivedAt,
    bool? acknowledged,
    Uint8List? raw,
  }) => RawHistoryPage(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    opcode: opcode ?? this.opcode,
    remaining: remaining ?? this.remaining,
    receivedAt: receivedAt ?? this.receivedAt,
    acknowledged: acknowledged ?? this.acknowledged,
    raw: raw ?? this.raw,
  );
  RawHistoryPage copyWithCompanion(RawHistoryPagesCompanion data) {
    return RawHistoryPage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      opcode: data.opcode.present ? data.opcode.value : this.opcode,
      remaining: data.remaining.present ? data.remaining.value : this.remaining,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      acknowledged: data.acknowledged.present
          ? data.acknowledged.value
          : this.acknowledged,
      raw: data.raw.present ? data.raw.value : this.raw,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawHistoryPage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('opcode: $opcode, ')
          ..write('remaining: $remaining, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('acknowledged: $acknowledged, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    opcode,
    remaining,
    receivedAt,
    acknowledged,
    $driftBlobEquality.hash(raw),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawHistoryPage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.opcode == this.opcode &&
          other.remaining == this.remaining &&
          other.receivedAt == this.receivedAt &&
          other.acknowledged == this.acknowledged &&
          $driftBlobEquality.equals(other.raw, this.raw));
}

class RawHistoryPagesCompanion extends UpdateCompanion<RawHistoryPage> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> opcode;
  final Value<int> remaining;
  final Value<DateTime> receivedAt;
  final Value<bool> acknowledged;
  final Value<Uint8List> raw;
  const RawHistoryPagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.opcode = const Value.absent(),
    this.remaining = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.acknowledged = const Value.absent(),
    this.raw = const Value.absent(),
  });
  RawHistoryPagesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int opcode,
    required int remaining,
    required DateTime receivedAt,
    this.acknowledged = const Value.absent(),
    required Uint8List raw,
  }) : sessionId = Value(sessionId),
       opcode = Value(opcode),
       remaining = Value(remaining),
       receivedAt = Value(receivedAt),
       raw = Value(raw);
  static Insertable<RawHistoryPage> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? opcode,
    Expression<int>? remaining,
    Expression<DateTime>? receivedAt,
    Expression<bool>? acknowledged,
    Expression<Uint8List>? raw,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (opcode != null) 'opcode': opcode,
      if (remaining != null) 'remaining': remaining,
      if (receivedAt != null) 'received_at': receivedAt,
      if (acknowledged != null) 'acknowledged': acknowledged,
      if (raw != null) 'raw': raw,
    });
  }

  RawHistoryPagesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? opcode,
    Value<int>? remaining,
    Value<DateTime>? receivedAt,
    Value<bool>? acknowledged,
    Value<Uint8List>? raw,
  }) {
    return RawHistoryPagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      opcode: opcode ?? this.opcode,
      remaining: remaining ?? this.remaining,
      receivedAt: receivedAt ?? this.receivedAt,
      acknowledged: acknowledged ?? this.acknowledged,
      raw: raw ?? this.raw,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (opcode.present) {
      map['opcode'] = Variable<int>(opcode.value);
    }
    if (remaining.present) {
      map['remaining'] = Variable<int>(remaining.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (acknowledged.present) {
      map['acknowledged'] = Variable<bool>(acknowledged.value);
    }
    if (raw.present) {
      map['raw'] = Variable<Uint8List>(raw.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RawHistoryPagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('opcode: $opcode, ')
          ..write('remaining: $remaining, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('acknowledged: $acknowledged, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }
}

class $RawPacketsTable extends RawPackets
    with TableInfo<$RawPacketsTable, RawPacket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RawPacketsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _connectionMeta = const VerificationMeta(
    'connection',
  );
  @override
  late final GeneratedColumn<int> connection = GeneratedColumn<int>(
    'connection',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<Uint8List> raw = GeneratedColumn<Uint8List>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    connection,
    elapsedMs,
    direction,
    raw,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'raw_packets';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawPacket> instance, {
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
    if (data.containsKey('connection')) {
      context.handle(
        _connectionMeta,
        connection.isAcceptableOrUnknown(data['connection']!, _connectionMeta),
      );
    } else if (isInserting) {
      context.missing(_connectionMeta);
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawPacket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawPacket(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      connection: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}connection'],
      )!,
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}raw'],
      )!,
    );
  }

  @override
  $RawPacketsTable createAlias(String alias) {
    return $RawPacketsTable(attachedDatabase, alias);
  }
}

class RawPacket extends DataClass implements Insertable<RawPacket> {
  final int id;
  final String deviceId;
  final int connection;
  final int elapsedMs;
  final String direction;
  final Uint8List raw;
  const RawPacket({
    required this.id,
    required this.deviceId,
    required this.connection,
    required this.elapsedMs,
    required this.direction,
    required this.raw,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['connection'] = Variable<int>(connection);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['direction'] = Variable<String>(direction);
    map['raw'] = Variable<Uint8List>(raw);
    return map;
  }

  RawPacketsCompanion toCompanion(bool nullToAbsent) {
    return RawPacketsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      connection: Value(connection),
      elapsedMs: Value(elapsedMs),
      direction: Value(direction),
      raw: Value(raw),
    );
  }

  factory RawPacket.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawPacket(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      connection: serializer.fromJson<int>(json['connection']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      direction: serializer.fromJson<String>(json['direction']),
      raw: serializer.fromJson<Uint8List>(json['raw']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'connection': serializer.toJson<int>(connection),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'direction': serializer.toJson<String>(direction),
      'raw': serializer.toJson<Uint8List>(raw),
    };
  }

  RawPacket copyWith({
    int? id,
    String? deviceId,
    int? connection,
    int? elapsedMs,
    String? direction,
    Uint8List? raw,
  }) => RawPacket(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    connection: connection ?? this.connection,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    direction: direction ?? this.direction,
    raw: raw ?? this.raw,
  );
  RawPacket copyWithCompanion(RawPacketsCompanion data) {
    return RawPacket(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      connection: data.connection.present
          ? data.connection.value
          : this.connection,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      direction: data.direction.present ? data.direction.value : this.direction,
      raw: data.raw.present ? data.raw.value : this.raw,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawPacket(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('connection: $connection, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('direction: $direction, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    connection,
    elapsedMs,
    direction,
    $driftBlobEquality.hash(raw),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawPacket &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.connection == this.connection &&
          other.elapsedMs == this.elapsedMs &&
          other.direction == this.direction &&
          $driftBlobEquality.equals(other.raw, this.raw));
}

class RawPacketsCompanion extends UpdateCompanion<RawPacket> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<int> connection;
  final Value<int> elapsedMs;
  final Value<String> direction;
  final Value<Uint8List> raw;
  const RawPacketsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.connection = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.direction = const Value.absent(),
    this.raw = const Value.absent(),
  });
  RawPacketsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required int connection,
    required int elapsedMs,
    required String direction,
    required Uint8List raw,
  }) : deviceId = Value(deviceId),
       connection = Value(connection),
       elapsedMs = Value(elapsedMs),
       direction = Value(direction),
       raw = Value(raw);
  static Insertable<RawPacket> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<int>? connection,
    Expression<int>? elapsedMs,
    Expression<String>? direction,
    Expression<Uint8List>? raw,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (connection != null) 'connection': connection,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (direction != null) 'direction': direction,
      if (raw != null) 'raw': raw,
    });
  }

  RawPacketsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<int>? connection,
    Value<int>? elapsedMs,
    Value<String>? direction,
    Value<Uint8List>? raw,
  }) {
    return RawPacketsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      connection: connection ?? this.connection,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      direction: direction ?? this.direction,
      raw: raw ?? this.raw,
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
    if (connection.present) {
      map['connection'] = Variable<int>(connection.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (raw.present) {
      map['raw'] = Variable<Uint8List>(raw.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RawPacketsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('connection: $connection, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('direction: $direction, ')
          ..write('raw: $raw')
          ..write(')'))
        .toString();
  }
}

class $HealthExportCheckpointsTable extends HealthExportCheckpoints
    with TableInfo<$HealthExportCheckpointsTable, HealthExportCheckpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthExportCheckpointsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _metricMeta = const VerificationMeta('metric');
  @override
  late final GeneratedColumn<String> metric = GeneratedColumn<String>(
    'metric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxCursorMeta = const VerificationMeta(
    'maxCursor',
  );
  @override
  late final GeneratedColumn<int> maxCursor = GeneratedColumn<int>(
    'max_cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [deviceId, metric, maxCursor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_export_checkpoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthExportCheckpoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('metric')) {
      context.handle(
        _metricMeta,
        metric.isAcceptableOrUnknown(data['metric']!, _metricMeta),
      );
    } else if (isInserting) {
      context.missing(_metricMeta);
    }
    if (data.containsKey('max_cursor')) {
      context.handle(
        _maxCursorMeta,
        maxCursor.isAcceptableOrUnknown(data['max_cursor']!, _maxCursorMeta),
      );
    } else if (isInserting) {
      context.missing(_maxCursorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId, metric};
  @override
  HealthExportCheckpoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthExportCheckpoint(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      metric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric'],
      )!,
      maxCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_cursor'],
      )!,
    );
  }

  @override
  $HealthExportCheckpointsTable createAlias(String alias) {
    return $HealthExportCheckpointsTable(attachedDatabase, alias);
  }
}

class HealthExportCheckpoint extends DataClass
    implements Insertable<HealthExportCheckpoint> {
  final String deviceId;
  final String metric;
  final int maxCursor;
  const HealthExportCheckpoint({
    required this.deviceId,
    required this.metric,
    required this.maxCursor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['metric'] = Variable<String>(metric);
    map['max_cursor'] = Variable<int>(maxCursor);
    return map;
  }

  HealthExportCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return HealthExportCheckpointsCompanion(
      deviceId: Value(deviceId),
      metric: Value(metric),
      maxCursor: Value(maxCursor),
    );
  }

  factory HealthExportCheckpoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthExportCheckpoint(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      metric: serializer.fromJson<String>(json['metric']),
      maxCursor: serializer.fromJson<int>(json['maxCursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'metric': serializer.toJson<String>(metric),
      'maxCursor': serializer.toJson<int>(maxCursor),
    };
  }

  HealthExportCheckpoint copyWith({
    String? deviceId,
    String? metric,
    int? maxCursor,
  }) => HealthExportCheckpoint(
    deviceId: deviceId ?? this.deviceId,
    metric: metric ?? this.metric,
    maxCursor: maxCursor ?? this.maxCursor,
  );
  HealthExportCheckpoint copyWithCompanion(
    HealthExportCheckpointsCompanion data,
  ) {
    return HealthExportCheckpoint(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      metric: data.metric.present ? data.metric.value : this.metric,
      maxCursor: data.maxCursor.present ? data.maxCursor.value : this.maxCursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthExportCheckpoint(')
          ..write('deviceId: $deviceId, ')
          ..write('metric: $metric, ')
          ..write('maxCursor: $maxCursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, metric, maxCursor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthExportCheckpoint &&
          other.deviceId == this.deviceId &&
          other.metric == this.metric &&
          other.maxCursor == this.maxCursor);
}

class HealthExportCheckpointsCompanion
    extends UpdateCompanion<HealthExportCheckpoint> {
  final Value<String> deviceId;
  final Value<String> metric;
  final Value<int> maxCursor;
  final Value<int> rowid;
  const HealthExportCheckpointsCompanion({
    this.deviceId = const Value.absent(),
    this.metric = const Value.absent(),
    this.maxCursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthExportCheckpointsCompanion.insert({
    required String deviceId,
    required String metric,
    required int maxCursor,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       metric = Value(metric),
       maxCursor = Value(maxCursor);
  static Insertable<HealthExportCheckpoint> custom({
    Expression<String>? deviceId,
    Expression<String>? metric,
    Expression<int>? maxCursor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (metric != null) 'metric': metric,
      if (maxCursor != null) 'max_cursor': maxCursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthExportCheckpointsCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? metric,
    Value<int>? maxCursor,
    Value<int>? rowid,
  }) {
    return HealthExportCheckpointsCompanion(
      deviceId: deviceId ?? this.deviceId,
      metric: metric ?? this.metric,
      maxCursor: maxCursor ?? this.maxCursor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (metric.present) {
      map['metric'] = Variable<String>(metric.value);
    }
    if (maxCursor.present) {
      map['max_cursor'] = Variable<int>(maxCursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthExportCheckpointsCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('metric: $metric, ')
          ..write('maxCursor: $maxCursor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthExportWritesTable extends HealthExportWrites
    with TableInfo<$HealthExportWritesTable, HealthExportWrite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthExportWritesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _metricMeta = const VerificationMeta('metric');
  @override
  late final GeneratedColumn<String> metric = GeneratedColumn<String>(
    'metric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exportedAtMicrosMeta = const VerificationMeta(
    'exportedAtMicros',
  );
  @override
  late final GeneratedColumn<int> exportedAtMicros = GeneratedColumn<int>(
    'exported_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    metric,
    cursor,
    exportedAtMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_export_writes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthExportWrite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('metric')) {
      context.handle(
        _metricMeta,
        metric.isAcceptableOrUnknown(data['metric']!, _metricMeta),
      );
    } else if (isInserting) {
      context.missing(_metricMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('exported_at_micros')) {
      context.handle(
        _exportedAtMicrosMeta,
        exportedAtMicros.isAcceptableOrUnknown(
          data['exported_at_micros']!,
          _exportedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exportedAtMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId, metric, cursor};
  @override
  HealthExportWrite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthExportWrite(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      metric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor'],
      )!,
      exportedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exported_at_micros'],
      )!,
    );
  }

  @override
  $HealthExportWritesTable createAlias(String alias) {
    return $HealthExportWritesTable(attachedDatabase, alias);
  }
}

class HealthExportWrite extends DataClass
    implements Insertable<HealthExportWrite> {
  final String deviceId;
  final String metric;
  final int cursor;
  final int exportedAtMicros;
  const HealthExportWrite({
    required this.deviceId,
    required this.metric,
    required this.cursor,
    required this.exportedAtMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['metric'] = Variable<String>(metric);
    map['cursor'] = Variable<int>(cursor);
    map['exported_at_micros'] = Variable<int>(exportedAtMicros);
    return map;
  }

  HealthExportWritesCompanion toCompanion(bool nullToAbsent) {
    return HealthExportWritesCompanion(
      deviceId: Value(deviceId),
      metric: Value(metric),
      cursor: Value(cursor),
      exportedAtMicros: Value(exportedAtMicros),
    );
  }

  factory HealthExportWrite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthExportWrite(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      metric: serializer.fromJson<String>(json['metric']),
      cursor: serializer.fromJson<int>(json['cursor']),
      exportedAtMicros: serializer.fromJson<int>(json['exportedAtMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'metric': serializer.toJson<String>(metric),
      'cursor': serializer.toJson<int>(cursor),
      'exportedAtMicros': serializer.toJson<int>(exportedAtMicros),
    };
  }

  HealthExportWrite copyWith({
    String? deviceId,
    String? metric,
    int? cursor,
    int? exportedAtMicros,
  }) => HealthExportWrite(
    deviceId: deviceId ?? this.deviceId,
    metric: metric ?? this.metric,
    cursor: cursor ?? this.cursor,
    exportedAtMicros: exportedAtMicros ?? this.exportedAtMicros,
  );
  HealthExportWrite copyWithCompanion(HealthExportWritesCompanion data) {
    return HealthExportWrite(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      metric: data.metric.present ? data.metric.value : this.metric,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      exportedAtMicros: data.exportedAtMicros.present
          ? data.exportedAtMicros.value
          : this.exportedAtMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthExportWrite(')
          ..write('deviceId: $deviceId, ')
          ..write('metric: $metric, ')
          ..write('cursor: $cursor, ')
          ..write('exportedAtMicros: $exportedAtMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, metric, cursor, exportedAtMicros);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthExportWrite &&
          other.deviceId == this.deviceId &&
          other.metric == this.metric &&
          other.cursor == this.cursor &&
          other.exportedAtMicros == this.exportedAtMicros);
}

class HealthExportWritesCompanion extends UpdateCompanion<HealthExportWrite> {
  final Value<String> deviceId;
  final Value<String> metric;
  final Value<int> cursor;
  final Value<int> exportedAtMicros;
  final Value<int> rowid;
  const HealthExportWritesCompanion({
    this.deviceId = const Value.absent(),
    this.metric = const Value.absent(),
    this.cursor = const Value.absent(),
    this.exportedAtMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthExportWritesCompanion.insert({
    required String deviceId,
    required String metric,
    required int cursor,
    required int exportedAtMicros,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       metric = Value(metric),
       cursor = Value(cursor),
       exportedAtMicros = Value(exportedAtMicros);
  static Insertable<HealthExportWrite> custom({
    Expression<String>? deviceId,
    Expression<String>? metric,
    Expression<int>? cursor,
    Expression<int>? exportedAtMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (metric != null) 'metric': metric,
      if (cursor != null) 'cursor': cursor,
      if (exportedAtMicros != null) 'exported_at_micros': exportedAtMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthExportWritesCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? metric,
    Value<int>? cursor,
    Value<int>? exportedAtMicros,
    Value<int>? rowid,
  }) {
    return HealthExportWritesCompanion(
      deviceId: deviceId ?? this.deviceId,
      metric: metric ?? this.metric,
      cursor: cursor ?? this.cursor,
      exportedAtMicros: exportedAtMicros ?? this.exportedAtMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (metric.present) {
      map['metric'] = Variable<String>(metric.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (exportedAtMicros.present) {
      map['exported_at_micros'] = Variable<int>(exportedAtMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthExportWritesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('metric: $metric, ')
          ..write('cursor: $cursor, ')
          ..write('exportedAtMicros: $exportedAtMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreference extends DataClass implements Insertable<AppPreference> {
  final String key;
  final String value;
  const AppPreference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory AppPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppPreference copyWith({String? key, String? value}) =>
      AppPreference(key: key ?? this.key, value: value ?? this.value);
  AppPreference copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreference &&
          other.key == this.key &&
          other.value == this.value);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$RingDatabase extends GeneratedDatabase {
  _$RingDatabase(QueryExecutor e) : super(e);
  $RingDatabaseManager get managers => $RingDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $TelemetrySnapshotsTable telemetrySnapshots =
      $TelemetrySnapshotsTable(this);
  late final $LiveHrSamplesTable liveHrSamples = $LiveHrSamplesTable(this);
  late final $EpochsTable epochs = $EpochsTable(this);
  late final $ThermalBlocksTable thermalBlocks = $ThermalBlocksTable(this);
  late final $DrainSessionsTable drainSessions = $DrainSessionsTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $RawHistoryPagesTable rawHistoryPages = $RawHistoryPagesTable(
    this,
  );
  late final $RawPacketsTable rawPackets = $RawPacketsTable(this);
  late final $HealthExportCheckpointsTable healthExportCheckpoints =
      $HealthExportCheckpointsTable(this);
  late final $HealthExportWritesTable healthExportWrites =
      $HealthExportWritesTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final Index telemetryDeviceTime = Index(
    'telemetry_device_time',
    'CREATE INDEX telemetry_device_time ON telemetry_snapshots (device_id, captured_at)',
  );
  late final Index traceConnection = Index(
    'trace_connection',
    'CREATE INDEX trace_connection ON raw_packets (connection)',
  );
  late final Index healthExportRun = Index(
    'health_export_run',
    'CREATE INDEX health_export_run ON health_export_writes (exported_at_micros)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devices,
    telemetrySnapshots,
    liveHrSamples,
    epochs,
    thermalBlocks,
    drainSessions,
    syncCursors,
    rawHistoryPages,
    rawPackets,
    healthExportCheckpoints,
    healthExportWrites,
    appPreferences,
    telemetryDeviceTime,
    traceConnection,
    healthExportRun,
  ];
}

typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String platformId,
  required String name,
  Value<String?> firmware,
  Value<String?> serial,
  required Uint8List systemId,
  required DateTime lastSeenAt,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> platformId,
  Value<String> name,
  Value<String?> firmware,
  Value<String?> serial,
  Value<Uint8List> systemId,
  Value<DateTime> lastSeenAt,
  Value<int> rowid,
});

final class $$DevicesTableReferences
    extends BaseReferences<_$RingDatabase, $DevicesTable, Device> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TelemetrySnapshotsTable, List<TelemetrySnapshot>>
  _telemetrySnapshotsRefsTable(_$RingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.telemetrySnapshots,
        aliasName: 'devices__id__telemetry_snapshots__device_id',
      );

  $$TelemetrySnapshotsTableProcessedTableManager get telemetrySnapshotsRefs {
    final manager = $$TelemetrySnapshotsTableTableManager(
      $_db,
      $_db.telemetrySnapshots,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _telemetrySnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LiveHrSamplesTable, List<LiveHrSample>>
  _liveHrSamplesRefsTable(_$RingDatabase db) => MultiTypedResultKey.fromTable(
    db.liveHrSamples,
    aliasName: 'devices__id__live_hr_samples__device_id',
  );

  $$LiveHrSamplesTableProcessedTableManager get liveHrSamplesRefs {
    final manager = $$LiveHrSamplesTableTableManager(
      $_db,
      $_db.liveHrSamples,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_liveHrSamplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EpochsTable, List<Epoch>> _epochsRefsTable(
    _$RingDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.epochs,
    aliasName: 'devices__id__epochs__device_id',
  );

  $$EpochsTableProcessedTableManager get epochsRefs {
    final manager = $$EpochsTableTableManager(
      $_db,
      $_db.epochs,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_epochsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ThermalBlocksTable, List<StoredThermalBlock>>
  _thermalBlocksRefsTable(_$RingDatabase db) => MultiTypedResultKey.fromTable(
    db.thermalBlocks,
    aliasName: 'devices__id__thermal_blocks__device_id',
  );

  $$ThermalBlocksTableProcessedTableManager get thermalBlocksRefs {
    final manager = $$ThermalBlocksTableTableManager(
      $_db,
      $_db.thermalBlocks,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_thermalBlocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DrainSessionsTable, List<DrainSession>>
  _drainSessionsRefsTable(_$RingDatabase db) => MultiTypedResultKey.fromTable(
    db.drainSessions,
    aliasName: 'devices__id__drain_sessions__device_id',
  );

  $$DrainSessionsTableProcessedTableManager get drainSessionsRefs {
    final manager = $$DrainSessionsTableTableManager(
      $_db,
      $_db.drainSessions,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_drainSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncCursorsTable, List<SyncCursor>>
  _syncCursorsRefsTable(_$RingDatabase db) => MultiTypedResultKey.fromTable(
    db.syncCursors,
    aliasName: 'devices__id__sync_cursors__device_id',
  );

  $$SyncCursorsTableProcessedTableManager get syncCursorsRefs {
    final manager = $$SyncCursorsTableTableManager(
      $_db,
      $_db.syncCursors,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncCursorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RawPacketsTable, List<RawPacket>>
  _rawPacketsRefsTable(_$RingDatabase db) => MultiTypedResultKey.fromTable(
    db.rawPackets,
    aliasName: 'devices__id__raw_packets__device_id',
  );

  $$RawPacketsTableProcessedTableManager get rawPacketsRefs {
    final manager = $$RawPacketsTableTableManager(
      $_db,
      $_db.rawPackets,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_rawPacketsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $HealthExportCheckpointsTable,
    List<HealthExportCheckpoint>
  >
  _healthExportCheckpointsRefsTable(_$RingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.healthExportCheckpoints,
        aliasName: 'devices__id__health_export_checkpoints__device_id',
      );

  $$HealthExportCheckpointsTableProcessedTableManager
  get healthExportCheckpointsRefs {
    final manager = $$HealthExportCheckpointsTableTableManager(
      $_db,
      $_db.healthExportCheckpoints,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _healthExportCheckpointsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HealthExportWritesTable, List<HealthExportWrite>>
  _healthExportWritesRefsTable(_$RingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.healthExportWrites,
        aliasName: 'devices__id__health_export_writes__device_id',
      );

  $$HealthExportWritesTableProcessedTableManager get healthExportWritesRefs {
    final manager = $$HealthExportWritesTableTableManager(
      $_db,
      $_db.healthExportWrites,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _healthExportWritesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DevicesTableFilterComposer
    extends Composer<_$RingDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platformId => $composableBuilder(
    column: $table.platformId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firmware => $composableBuilder(
    column: $table.firmware,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get systemId => $composableBuilder(
    column: $table.systemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> telemetrySnapshotsRefs(
    Expression<bool> Function($$TelemetrySnapshotsTableFilterComposer f) f,
  ) {
    final $$TelemetrySnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.telemetrySnapshots,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TelemetrySnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.telemetrySnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> liveHrSamplesRefs(
    Expression<bool> Function($$LiveHrSamplesTableFilterComposer f) f,
  ) {
    final $$LiveHrSamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.liveHrSamples,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiveHrSamplesTableFilterComposer(
            $db: $db,
            $table: $db.liveHrSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> epochsRefs(
    Expression<bool> Function($$EpochsTableFilterComposer f) f,
  ) {
    final $$EpochsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.epochs,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpochsTableFilterComposer(
            $db: $db,
            $table: $db.epochs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> thermalBlocksRefs(
    Expression<bool> Function($$ThermalBlocksTableFilterComposer f) f,
  ) {
    final $$ThermalBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.thermalBlocks,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThermalBlocksTableFilterComposer(
            $db: $db,
            $table: $db.thermalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> drainSessionsRefs(
    Expression<bool> Function($$DrainSessionsTableFilterComposer f) f,
  ) {
    final $$DrainSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drainSessions,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrainSessionsTableFilterComposer(
            $db: $db,
            $table: $db.drainSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncCursorsRefs(
    Expression<bool> Function($$SyncCursorsTableFilterComposer f) f,
  ) {
    final $$SyncCursorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncCursors,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncCursorsTableFilterComposer(
            $db: $db,
            $table: $db.syncCursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rawPacketsRefs(
    Expression<bool> Function($$RawPacketsTableFilterComposer f) f,
  ) {
    final $$RawPacketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rawPackets,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RawPacketsTableFilterComposer(
            $db: $db,
            $table: $db.rawPackets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> healthExportCheckpointsRefs(
    Expression<bool> Function($$HealthExportCheckpointsTableFilterComposer f) f,
  ) {
    final $$HealthExportCheckpointsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.healthExportCheckpoints,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HealthExportCheckpointsTableFilterComposer(
                $db: $db,
                $table: $db.healthExportCheckpoints,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> healthExportWritesRefs(
    Expression<bool> Function($$HealthExportWritesTableFilterComposer f) f,
  ) {
    final $$HealthExportWritesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.healthExportWrites,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HealthExportWritesTableFilterComposer(
            $db: $db,
            $table: $db.healthExportWrites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$RingDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platformId => $composableBuilder(
    column: $table.platformId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firmware => $composableBuilder(
    column: $table.firmware,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get systemId => $composableBuilder(
    column: $table.systemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$RingDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get platformId => $composableBuilder(
    column: $table.platformId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get firmware =>
      $composableBuilder(column: $table.firmware, builder: (column) => column);

  GeneratedColumn<String> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<Uint8List> get systemId =>
      $composableBuilder(column: $table.systemId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  Expression<T> telemetrySnapshotsRefs<T extends Object>(
    Expression<T> Function($$TelemetrySnapshotsTableAnnotationComposer a) f,
  ) {
    final $$TelemetrySnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.telemetrySnapshots,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TelemetrySnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.telemetrySnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> liveHrSamplesRefs<T extends Object>(
    Expression<T> Function($$LiveHrSamplesTableAnnotationComposer a) f,
  ) {
    final $$LiveHrSamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.liveHrSamples,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiveHrSamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.liveHrSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> epochsRefs<T extends Object>(
    Expression<T> Function($$EpochsTableAnnotationComposer a) f,
  ) {
    final $$EpochsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.epochs,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpochsTableAnnotationComposer(
            $db: $db,
            $table: $db.epochs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> thermalBlocksRefs<T extends Object>(
    Expression<T> Function($$ThermalBlocksTableAnnotationComposer a) f,
  ) {
    final $$ThermalBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.thermalBlocks,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThermalBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.thermalBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> drainSessionsRefs<T extends Object>(
    Expression<T> Function($$DrainSessionsTableAnnotationComposer a) f,
  ) {
    final $$DrainSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drainSessions,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrainSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.drainSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncCursorsRefs<T extends Object>(
    Expression<T> Function($$SyncCursorsTableAnnotationComposer a) f,
  ) {
    final $$SyncCursorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncCursors,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncCursorsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncCursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rawPacketsRefs<T extends Object>(
    Expression<T> Function($$RawPacketsTableAnnotationComposer a) f,
  ) {
    final $$RawPacketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rawPackets,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RawPacketsTableAnnotationComposer(
            $db: $db,
            $table: $db.rawPackets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> healthExportCheckpointsRefs<T extends Object>(
    Expression<T> Function($$HealthExportCheckpointsTableAnnotationComposer a)
    f,
  ) {
    final $$HealthExportCheckpointsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.healthExportCheckpoints,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HealthExportCheckpointsTableAnnotationComposer(
                $db: $db,
                $table: $db.healthExportCheckpoints,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> healthExportWritesRefs<T extends Object>(
    Expression<T> Function($$HealthExportWritesTableAnnotationComposer a) f,
  ) {
    final $$HealthExportWritesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.healthExportWrites,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HealthExportWritesTableAnnotationComposer(
                $db: $db,
                $table: $db.healthExportWrites,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, $$DevicesTableReferences),
          Device,
          PrefetchHooks Function({
            bool telemetrySnapshotsRefs,
            bool liveHrSamplesRefs,
            bool epochsRefs,
            bool thermalBlocksRefs,
            bool drainSessionsRefs,
            bool syncCursorsRefs,
            bool rawPacketsRefs,
            bool healthExportCheckpointsRefs,
            bool healthExportWritesRefs,
          })
        > {
  $$DevicesTableTableManager(_$RingDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> platformId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> firmware = const Value.absent(),
                Value<String?> serial = const Value.absent(),
                Value<Uint8List> systemId = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                platformId: platformId,
                name: name,
                firmware: firmware,
                serial: serial,
                systemId: systemId,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String platformId,
                required String name,
                Value<String?> firmware = const Value.absent(),
                Value<String?> serial = const Value.absent(),
                required Uint8List systemId,
                required DateTime lastSeenAt,
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                platformId: platformId,
                name: name,
                firmware: firmware,
                serial: serial,
                systemId: systemId,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevicesTable, Device>(table),
                  $$DevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                telemetrySnapshotsRefs = false,
                liveHrSamplesRefs = false,
                epochsRefs = false,
                thermalBlocksRefs = false,
                drainSessionsRefs = false,
                syncCursorsRefs = false,
                rawPacketsRefs = false,
                healthExportCheckpointsRefs = false,
                healthExportWritesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (telemetrySnapshotsRefs) db.telemetrySnapshots,
                    if (liveHrSamplesRefs) db.liveHrSamples,
                    if (epochsRefs) db.epochs,
                    if (thermalBlocksRefs) db.thermalBlocks,
                    if (drainSessionsRefs) db.drainSessions,
                    if (syncCursorsRefs) db.syncCursors,
                    if (rawPacketsRefs) db.rawPackets,
                    if (healthExportCheckpointsRefs) db.healthExportCheckpoints,
                    if (healthExportWritesRefs) db.healthExportWrites,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (telemetrySnapshotsRefs)
                        await $_getPrefetchedDataByColumns<
                          Device,
                          $DevicesTable,
                          TelemetrySnapshot,
                          $TelemetrySnapshotsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._telemetrySnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).telemetrySnapshotsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (liveHrSamplesRefs)
                        await $_getPrefetchedDataByColumns<
                          Device,
                          $DevicesTable,
                          LiveHrSample,
                          $LiveHrSamplesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._liveHrSamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).liveHrSamplesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (epochsRefs)
                        await $_getPrefetchedDataByColumns<
                          Device,
                          $DevicesTable,
                          Epoch,
                          $EpochsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._epochsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).epochsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (thermalBlocksRefs)
                        await $_getPrefetchedDataByColumns<
                          Device,
                          $DevicesTable,
                          StoredThermalBlock,
                          $ThermalBlocksTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._thermalBlocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).thermalBlocksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (drainSessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Device,
                          $DevicesTable,
                          DrainSession,
                          $DrainSessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._drainSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).drainSessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (syncCursorsRefs)
                        await $_getPrefetchedDataByColumns<
                          Device,
                          $DevicesTable,
                          SyncCursor,
                          $SyncCursorsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._syncCursorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).syncCursorsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (rawPacketsRefs)
                        await $_getPrefetchedDataByColumns<
                          Device,
                          $DevicesTable,
                          RawPacket,
                          $RawPacketsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._rawPacketsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).rawPacketsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (healthExportCheckpointsRefs)
                        await $_getPrefetchedDataByColumns<
                          Device,
                          $DevicesTable,
                          HealthExportCheckpoint,
                          $HealthExportCheckpointsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._healthExportCheckpointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).healthExportCheckpointsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (healthExportWritesRefs)
                        await $_getPrefetchedDataByColumns<
                          Device,
                          $DevicesTable,
                          HealthExportWrite,
                          $HealthExportWritesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._healthExportWritesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).healthExportWritesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, $$DevicesTableReferences),
      Device,
      PrefetchHooks Function({
        bool telemetrySnapshotsRefs,
        bool liveHrSamplesRefs,
        bool epochsRefs,
        bool thermalBlocksRefs,
        bool drainSessionsRefs,
        bool syncCursorsRefs,
        bool rawPacketsRefs,
        bool healthExportCheckpointsRefs,
        bool healthExportWritesRefs,
      })
    >;
typedef $$TelemetrySnapshotsTableCreateCompanionBuilder =
    TelemetrySnapshotsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime capturedAt,
      required int batteryPercent,
      required int batteryMillivolts,
      required double temperature1,
      required double temperature2,
      required int wearCode,
      required int modeFlags,
      required Uint8List raw,
    });
typedef $$TelemetrySnapshotsTableUpdateCompanionBuilder =
    TelemetrySnapshotsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> capturedAt,
      Value<int> batteryPercent,
      Value<int> batteryMillivolts,
      Value<double> temperature1,
      Value<double> temperature2,
      Value<int> wearCode,
      Value<int> modeFlags,
      Value<Uint8List> raw,
    });

final class $$TelemetrySnapshotsTableReferences
    extends
        BaseReferences<
          _$RingDatabase,
          $TelemetrySnapshotsTable,
          TelemetrySnapshot
        > {
  $$TelemetrySnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$RingDatabase db) =>
      db.devices.createAlias('telemetry_snapshots__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TelemetrySnapshotsTableFilterComposer
    extends Composer<_$RingDatabase, $TelemetrySnapshotsTable> {
  $$TelemetrySnapshotsTableFilterComposer({
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

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryPercent => $composableBuilder(
    column: $table.batteryPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryMillivolts => $composableBuilder(
    column: $table.batteryMillivolts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature1 => $composableBuilder(
    column: $table.temperature1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature2 => $composableBuilder(
    column: $table.temperature2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wearCode => $composableBuilder(
    column: $table.wearCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modeFlags => $composableBuilder(
    column: $table.modeFlags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TelemetrySnapshotsTableOrderingComposer
    extends Composer<_$RingDatabase, $TelemetrySnapshotsTable> {
  $$TelemetrySnapshotsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryPercent => $composableBuilder(
    column: $table.batteryPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryMillivolts => $composableBuilder(
    column: $table.batteryMillivolts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature1 => $composableBuilder(
    column: $table.temperature1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature2 => $composableBuilder(
    column: $table.temperature2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wearCode => $composableBuilder(
    column: $table.wearCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modeFlags => $composableBuilder(
    column: $table.modeFlags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TelemetrySnapshotsTableAnnotationComposer
    extends Composer<_$RingDatabase, $TelemetrySnapshotsTable> {
  $$TelemetrySnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batteryPercent => $composableBuilder(
    column: $table.batteryPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batteryMillivolts => $composableBuilder(
    column: $table.batteryMillivolts,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature1 => $composableBuilder(
    column: $table.temperature1,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature2 => $composableBuilder(
    column: $table.temperature2,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wearCode =>
      $composableBuilder(column: $table.wearCode, builder: (column) => column);

  GeneratedColumn<int> get modeFlags =>
      $composableBuilder(column: $table.modeFlags, builder: (column) => column);

  GeneratedColumn<Uint8List> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TelemetrySnapshotsTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $TelemetrySnapshotsTable,
          TelemetrySnapshot,
          $$TelemetrySnapshotsTableFilterComposer,
          $$TelemetrySnapshotsTableOrderingComposer,
          $$TelemetrySnapshotsTableAnnotationComposer,
          $$TelemetrySnapshotsTableCreateCompanionBuilder,
          $$TelemetrySnapshotsTableUpdateCompanionBuilder,
          (TelemetrySnapshot, $$TelemetrySnapshotsTableReferences),
          TelemetrySnapshot,
          PrefetchHooks Function({bool deviceId})
        > {
  $$TelemetrySnapshotsTableTableManager(
    _$RingDatabase db,
    $TelemetrySnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TelemetrySnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TelemetrySnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TelemetrySnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> batteryPercent = const Value.absent(),
                Value<int> batteryMillivolts = const Value.absent(),
                Value<double> temperature1 = const Value.absent(),
                Value<double> temperature2 = const Value.absent(),
                Value<int> wearCode = const Value.absent(),
                Value<int> modeFlags = const Value.absent(),
                Value<Uint8List> raw = const Value.absent(),
              }) => TelemetrySnapshotsCompanion(
                id: id,
                deviceId: deviceId,
                capturedAt: capturedAt,
                batteryPercent: batteryPercent,
                batteryMillivolts: batteryMillivolts,
                temperature1: temperature1,
                temperature2: temperature2,
                wearCode: wearCode,
                modeFlags: modeFlags,
                raw: raw,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime capturedAt,
                required int batteryPercent,
                required int batteryMillivolts,
                required double temperature1,
                required double temperature2,
                required int wearCode,
                required int modeFlags,
                required Uint8List raw,
              }) => TelemetrySnapshotsCompanion.insert(
                id: id,
                deviceId: deviceId,
                capturedAt: capturedAt,
                batteryPercent: batteryPercent,
                batteryMillivolts: batteryMillivolts,
                temperature1: temperature1,
                temperature2: temperature2,
                wearCode: wearCode,
                modeFlags: modeFlags,
                raw: raw,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TelemetrySnapshotsTable, TelemetrySnapshot>(
                    table,
                  ),
                  $$TelemetrySnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$TelemetrySnapshotsTableReferences
                            ._deviceIdTable(db),
                        referencedColumn: $$TelemetrySnapshotsTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TelemetrySnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $TelemetrySnapshotsTable,
      TelemetrySnapshot,
      $$TelemetrySnapshotsTableFilterComposer,
      $$TelemetrySnapshotsTableOrderingComposer,
      $$TelemetrySnapshotsTableAnnotationComposer,
      $$TelemetrySnapshotsTableCreateCompanionBuilder,
      $$TelemetrySnapshotsTableUpdateCompanionBuilder,
      (TelemetrySnapshot, $$TelemetrySnapshotsTableReferences),
      TelemetrySnapshot,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$LiveHrSamplesTableCreateCompanionBuilder =
    LiveHrSamplesCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime capturedAt,
      Value<int?> bpm,
      required Uint8List raw,
    });
typedef $$LiveHrSamplesTableUpdateCompanionBuilder =
    LiveHrSamplesCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> capturedAt,
      Value<int?> bpm,
      Value<Uint8List> raw,
    });

final class $$LiveHrSamplesTableReferences
    extends BaseReferences<_$RingDatabase, $LiveHrSamplesTable, LiveHrSample> {
  $$LiveHrSamplesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$RingDatabase db) =>
      db.devices.createAlias('live_hr_samples__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LiveHrSamplesTableFilterComposer
    extends Composer<_$RingDatabase, $LiveHrSamplesTable> {
  $$LiveHrSamplesTableFilterComposer({
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

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LiveHrSamplesTableOrderingComposer
    extends Composer<_$RingDatabase, $LiveHrSamplesTable> {
  $$LiveHrSamplesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LiveHrSamplesTableAnnotationComposer
    extends Composer<_$RingDatabase, $LiveHrSamplesTable> {
  $$LiveHrSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bpm =>
      $composableBuilder(column: $table.bpm, builder: (column) => column);

  GeneratedColumn<Uint8List> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LiveHrSamplesTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $LiveHrSamplesTable,
          LiveHrSample,
          $$LiveHrSamplesTableFilterComposer,
          $$LiveHrSamplesTableOrderingComposer,
          $$LiveHrSamplesTableAnnotationComposer,
          $$LiveHrSamplesTableCreateCompanionBuilder,
          $$LiveHrSamplesTableUpdateCompanionBuilder,
          (LiveHrSample, $$LiveHrSamplesTableReferences),
          LiveHrSample,
          PrefetchHooks Function({bool deviceId})
        > {
  $$LiveHrSamplesTableTableManager(_$RingDatabase db, $LiveHrSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiveHrSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiveHrSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiveHrSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int?> bpm = const Value.absent(),
                Value<Uint8List> raw = const Value.absent(),
              }) => LiveHrSamplesCompanion(
                id: id,
                deviceId: deviceId,
                capturedAt: capturedAt,
                bpm: bpm,
                raw: raw,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime capturedAt,
                Value<int?> bpm = const Value.absent(),
                required Uint8List raw,
              }) => LiveHrSamplesCompanion.insert(
                id: id,
                deviceId: deviceId,
                capturedAt: capturedAt,
                bpm: bpm,
                raw: raw,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LiveHrSamplesTable, LiveHrSample>(table),
                  $$LiveHrSamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$LiveHrSamplesTableReferences
                            ._deviceIdTable(db),
                        referencedColumn: $$LiveHrSamplesTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LiveHrSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $LiveHrSamplesTable,
      LiveHrSample,
      $$LiveHrSamplesTableFilterComposer,
      $$LiveHrSamplesTableOrderingComposer,
      $$LiveHrSamplesTableAnnotationComposer,
      $$LiveHrSamplesTableCreateCompanionBuilder,
      $$LiveHrSamplesTableUpdateCompanionBuilder,
      (LiveHrSample, $$LiveHrSamplesTableReferences),
      LiveHrSample,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$EpochsTableCreateCompanionBuilder = EpochsCompanion Function({
  required String deviceId,
  required int cursor,
  required DateTime endedAt,
  Value<int?> bpm,
  Value<int?> hrvMs,
  required int ppgQuality,
  Value<double?> respiratoryRate,
  Value<int?> oxygenPercent,
  required String oxygenState,
  required double activityMet,
  required int flags,
  required Uint8List raw,
  Value<int> rowid,
});
typedef $$EpochsTableUpdateCompanionBuilder = EpochsCompanion Function({
  Value<String> deviceId,
  Value<int> cursor,
  Value<DateTime> endedAt,
  Value<int?> bpm,
  Value<int?> hrvMs,
  Value<int> ppgQuality,
  Value<double?> respiratoryRate,
  Value<int?> oxygenPercent,
  Value<String> oxygenState,
  Value<double> activityMet,
  Value<int> flags,
  Value<Uint8List> raw,
  Value<int> rowid,
});

final class $$EpochsTableReferences
    extends BaseReferences<_$RingDatabase, $EpochsTable, Epoch> {
  $$EpochsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$RingDatabase db) =>
      db.devices.createAlias('epochs__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpochsTableFilterComposer
    extends Composer<_$RingDatabase, $EpochsTable> {
  $$EpochsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hrvMs => $composableBuilder(
    column: $table.hrvMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ppgQuality => $composableBuilder(
    column: $table.ppgQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oxygenPercent => $composableBuilder(
    column: $table.oxygenPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oxygenState => $composableBuilder(
    column: $table.oxygenState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get activityMet => $composableBuilder(
    column: $table.activityMet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpochsTableOrderingComposer
    extends Composer<_$RingDatabase, $EpochsTable> {
  $$EpochsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hrvMs => $composableBuilder(
    column: $table.hrvMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ppgQuality => $composableBuilder(
    column: $table.ppgQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oxygenPercent => $composableBuilder(
    column: $table.oxygenPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oxygenState => $composableBuilder(
    column: $table.oxygenState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get activityMet => $composableBuilder(
    column: $table.activityMet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpochsTableAnnotationComposer
    extends Composer<_$RingDatabase, $EpochsTable> {
  $$EpochsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get bpm =>
      $composableBuilder(column: $table.bpm, builder: (column) => column);

  GeneratedColumn<int> get hrvMs =>
      $composableBuilder(column: $table.hrvMs, builder: (column) => column);

  GeneratedColumn<int> get ppgQuality => $composableBuilder(
    column: $table.ppgQuality,
    builder: (column) => column,
  );

  GeneratedColumn<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get oxygenPercent => $composableBuilder(
    column: $table.oxygenPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oxygenState => $composableBuilder(
    column: $table.oxygenState,
    builder: (column) => column,
  );

  GeneratedColumn<double> get activityMet => $composableBuilder(
    column: $table.activityMet,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flags =>
      $composableBuilder(column: $table.flags, builder: (column) => column);

  GeneratedColumn<Uint8List> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpochsTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $EpochsTable,
          Epoch,
          $$EpochsTableFilterComposer,
          $$EpochsTableOrderingComposer,
          $$EpochsTableAnnotationComposer,
          $$EpochsTableCreateCompanionBuilder,
          $$EpochsTableUpdateCompanionBuilder,
          (Epoch, $$EpochsTableReferences),
          Epoch,
          PrefetchHooks Function({bool deviceId})
        > {
  $$EpochsTableTableManager(_$RingDatabase db, $EpochsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpochsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpochsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpochsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<int?> bpm = const Value.absent(),
                Value<int?> hrvMs = const Value.absent(),
                Value<int> ppgQuality = const Value.absent(),
                Value<double?> respiratoryRate = const Value.absent(),
                Value<int?> oxygenPercent = const Value.absent(),
                Value<String> oxygenState = const Value.absent(),
                Value<double> activityMet = const Value.absent(),
                Value<int> flags = const Value.absent(),
                Value<Uint8List> raw = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpochsCompanion(
                deviceId: deviceId,
                cursor: cursor,
                endedAt: endedAt,
                bpm: bpm,
                hrvMs: hrvMs,
                ppgQuality: ppgQuality,
                respiratoryRate: respiratoryRate,
                oxygenPercent: oxygenPercent,
                oxygenState: oxygenState,
                activityMet: activityMet,
                flags: flags,
                raw: raw,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required int cursor,
                required DateTime endedAt,
                Value<int?> bpm = const Value.absent(),
                Value<int?> hrvMs = const Value.absent(),
                required int ppgQuality,
                Value<double?> respiratoryRate = const Value.absent(),
                Value<int?> oxygenPercent = const Value.absent(),
                required String oxygenState,
                required double activityMet,
                required int flags,
                required Uint8List raw,
                Value<int> rowid = const Value.absent(),
              }) => EpochsCompanion.insert(
                deviceId: deviceId,
                cursor: cursor,
                endedAt: endedAt,
                bpm: bpm,
                hrvMs: hrvMs,
                ppgQuality: ppgQuality,
                respiratoryRate: respiratoryRate,
                oxygenPercent: oxygenPercent,
                oxygenState: oxygenState,
                activityMet: activityMet,
                flags: flags,
                raw: raw,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpochsTable, Epoch>(table),
                  $$EpochsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$EpochsTableReferences._deviceIdTable(
                          db,
                        ),
                        referencedColumn: $$EpochsTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpochsTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $EpochsTable,
      Epoch,
      $$EpochsTableFilterComposer,
      $$EpochsTableOrderingComposer,
      $$EpochsTableAnnotationComposer,
      $$EpochsTableCreateCompanionBuilder,
      $$EpochsTableUpdateCompanionBuilder,
      (Epoch, $$EpochsTableReferences),
      Epoch,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$ThermalBlocksTableCreateCompanionBuilder =
    ThermalBlocksCompanion Function({
      required String deviceId,
      required int cursor,
      required DateTime endedAt,
      required int subtype,
      required int batteryPercent,
      required bool activity,
      required int steps,
      required int activeTimeRaw,
      required double meanOuterTemperature,
      required double meanInnerTemperature,
      required Uint8List raw,
      Value<int> rowid,
    });
typedef $$ThermalBlocksTableUpdateCompanionBuilder =
    ThermalBlocksCompanion Function({
      Value<String> deviceId,
      Value<int> cursor,
      Value<DateTime> endedAt,
      Value<int> subtype,
      Value<int> batteryPercent,
      Value<bool> activity,
      Value<int> steps,
      Value<int> activeTimeRaw,
      Value<double> meanOuterTemperature,
      Value<double> meanInnerTemperature,
      Value<Uint8List> raw,
      Value<int> rowid,
    });

final class $$ThermalBlocksTableReferences
    extends
        BaseReferences<
          _$RingDatabase,
          $ThermalBlocksTable,
          StoredThermalBlock
        > {
  $$ThermalBlocksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$RingDatabase db) =>
      db.devices.createAlias('thermal_blocks__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ThermalBlocksTableFilterComposer
    extends Composer<_$RingDatabase, $ThermalBlocksTable> {
  $$ThermalBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryPercent => $composableBuilder(
    column: $table.batteryPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeTimeRaw => $composableBuilder(
    column: $table.activeTimeRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanOuterTemperature => $composableBuilder(
    column: $table.meanOuterTemperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanInnerTemperature => $composableBuilder(
    column: $table.meanInnerTemperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThermalBlocksTableOrderingComposer
    extends Composer<_$RingDatabase, $ThermalBlocksTable> {
  $$ThermalBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryPercent => $composableBuilder(
    column: $table.batteryPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeTimeRaw => $composableBuilder(
    column: $table.activeTimeRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanOuterTemperature => $composableBuilder(
    column: $table.meanOuterTemperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanInnerTemperature => $composableBuilder(
    column: $table.meanInnerTemperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThermalBlocksTableAnnotationComposer
    extends Composer<_$RingDatabase, $ThermalBlocksTable> {
  $$ThermalBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get subtype =>
      $composableBuilder(column: $table.subtype, builder: (column) => column);

  GeneratedColumn<int> get batteryPercent => $composableBuilder(
    column: $table.batteryPercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get activeTimeRaw => $composableBuilder(
    column: $table.activeTimeRaw,
    builder: (column) => column,
  );

  GeneratedColumn<double> get meanOuterTemperature => $composableBuilder(
    column: $table.meanOuterTemperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get meanInnerTemperature => $composableBuilder(
    column: $table.meanInnerTemperature,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThermalBlocksTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $ThermalBlocksTable,
          StoredThermalBlock,
          $$ThermalBlocksTableFilterComposer,
          $$ThermalBlocksTableOrderingComposer,
          $$ThermalBlocksTableAnnotationComposer,
          $$ThermalBlocksTableCreateCompanionBuilder,
          $$ThermalBlocksTableUpdateCompanionBuilder,
          (StoredThermalBlock, $$ThermalBlocksTableReferences),
          StoredThermalBlock,
          PrefetchHooks Function({bool deviceId})
        > {
  $$ThermalBlocksTableTableManager(_$RingDatabase db, $ThermalBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThermalBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThermalBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThermalBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<int> subtype = const Value.absent(),
                Value<int> batteryPercent = const Value.absent(),
                Value<bool> activity = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<int> activeTimeRaw = const Value.absent(),
                Value<double> meanOuterTemperature = const Value.absent(),
                Value<double> meanInnerTemperature = const Value.absent(),
                Value<Uint8List> raw = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThermalBlocksCompanion(
                deviceId: deviceId,
                cursor: cursor,
                endedAt: endedAt,
                subtype: subtype,
                batteryPercent: batteryPercent,
                activity: activity,
                steps: steps,
                activeTimeRaw: activeTimeRaw,
                meanOuterTemperature: meanOuterTemperature,
                meanInnerTemperature: meanInnerTemperature,
                raw: raw,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required int cursor,
                required DateTime endedAt,
                required int subtype,
                required int batteryPercent,
                required bool activity,
                required int steps,
                required int activeTimeRaw,
                required double meanOuterTemperature,
                required double meanInnerTemperature,
                required Uint8List raw,
                Value<int> rowid = const Value.absent(),
              }) => ThermalBlocksCompanion.insert(
                deviceId: deviceId,
                cursor: cursor,
                endedAt: endedAt,
                subtype: subtype,
                batteryPercent: batteryPercent,
                activity: activity,
                steps: steps,
                activeTimeRaw: activeTimeRaw,
                meanOuterTemperature: meanOuterTemperature,
                meanInnerTemperature: meanInnerTemperature,
                raw: raw,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ThermalBlocksTable, StoredThermalBlock>(table),
                  $$ThermalBlocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$ThermalBlocksTableReferences
                            ._deviceIdTable(db),
                        referencedColumn: $$ThermalBlocksTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ThermalBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $ThermalBlocksTable,
      StoredThermalBlock,
      $$ThermalBlocksTableFilterComposer,
      $$ThermalBlocksTableOrderingComposer,
      $$ThermalBlocksTableAnnotationComposer,
      $$ThermalBlocksTableCreateCompanionBuilder,
      $$ThermalBlocksTableUpdateCompanionBuilder,
      (StoredThermalBlock, $$ThermalBlocksTableReferences),
      StoredThermalBlock,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$DrainSessionsTableCreateCompanionBuilder =
    DrainSessionsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      required int requestedCursor,
      required int channel,
      required String state,
      Value<int> pagesAcknowledged,
      Value<int> recordsAcknowledged,
      Value<String?> detail,
    });
typedef $$DrainSessionsTableUpdateCompanionBuilder =
    DrainSessionsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int> requestedCursor,
      Value<int> channel,
      Value<String> state,
      Value<int> pagesAcknowledged,
      Value<int> recordsAcknowledged,
      Value<String?> detail,
    });

final class $$DrainSessionsTableReferences
    extends BaseReferences<_$RingDatabase, $DrainSessionsTable, DrainSession> {
  $$DrainSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$RingDatabase db) =>
      db.devices.createAlias('drain_sessions__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RawHistoryPagesTable, List<RawHistoryPage>>
  _rawHistoryPagesRefsTable(_$RingDatabase db) => MultiTypedResultKey.fromTable(
    db.rawHistoryPages,
    aliasName: 'drain_sessions__id__raw_history_pages__session_id',
  );

  $$RawHistoryPagesTableProcessedTableManager get rawHistoryPagesRefs {
    final manager = $$RawHistoryPagesTableTableManager(
      $_db,
      $_db.rawHistoryPages,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rawHistoryPagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DrainSessionsTableFilterComposer
    extends Composer<_$RingDatabase, $DrainSessionsTable> {
  $$DrainSessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedCursor => $composableBuilder(
    column: $table.requestedCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagesAcknowledged => $composableBuilder(
    column: $table.pagesAcknowledged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordsAcknowledged => $composableBuilder(
    column: $table.recordsAcknowledged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> rawHistoryPagesRefs(
    Expression<bool> Function($$RawHistoryPagesTableFilterComposer f) f,
  ) {
    final $$RawHistoryPagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rawHistoryPages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RawHistoryPagesTableFilterComposer(
            $db: $db,
            $table: $db.rawHistoryPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DrainSessionsTableOrderingComposer
    extends Composer<_$RingDatabase, $DrainSessionsTable> {
  $$DrainSessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedCursor => $composableBuilder(
    column: $table.requestedCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesAcknowledged => $composableBuilder(
    column: $table.pagesAcknowledged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordsAcknowledged => $composableBuilder(
    column: $table.recordsAcknowledged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrainSessionsTableAnnotationComposer
    extends Composer<_$RingDatabase, $DrainSessionsTable> {
  $$DrainSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedCursor => $composableBuilder(
    column: $table.requestedCursor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get pagesAcknowledged => $composableBuilder(
    column: $table.pagesAcknowledged,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordsAcknowledged => $composableBuilder(
    column: $table.recordsAcknowledged,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> rawHistoryPagesRefs<T extends Object>(
    Expression<T> Function($$RawHistoryPagesTableAnnotationComposer a) f,
  ) {
    final $$RawHistoryPagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rawHistoryPages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RawHistoryPagesTableAnnotationComposer(
            $db: $db,
            $table: $db.rawHistoryPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DrainSessionsTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $DrainSessionsTable,
          DrainSession,
          $$DrainSessionsTableFilterComposer,
          $$DrainSessionsTableOrderingComposer,
          $$DrainSessionsTableAnnotationComposer,
          $$DrainSessionsTableCreateCompanionBuilder,
          $$DrainSessionsTableUpdateCompanionBuilder,
          (DrainSession, $$DrainSessionsTableReferences),
          DrainSession,
          PrefetchHooks Function({bool deviceId, bool rawHistoryPagesRefs})
        > {
  $$DrainSessionsTableTableManager(_$RingDatabase db, $DrainSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrainSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrainSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrainSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> requestedCursor = const Value.absent(),
                Value<int> channel = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> pagesAcknowledged = const Value.absent(),
                Value<int> recordsAcknowledged = const Value.absent(),
                Value<String?> detail = const Value.absent(),
              }) => DrainSessionsCompanion(
                id: id,
                deviceId: deviceId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                requestedCursor: requestedCursor,
                channel: channel,
                state: state,
                pagesAcknowledged: pagesAcknowledged,
                recordsAcknowledged: recordsAcknowledged,
                detail: detail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                required int requestedCursor,
                required int channel,
                required String state,
                Value<int> pagesAcknowledged = const Value.absent(),
                Value<int> recordsAcknowledged = const Value.absent(),
                Value<String?> detail = const Value.absent(),
              }) => DrainSessionsCompanion.insert(
                id: id,
                deviceId: deviceId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                requestedCursor: requestedCursor,
                channel: channel,
                state: state,
                pagesAcknowledged: pagesAcknowledged,
                recordsAcknowledged: recordsAcknowledged,
                detail: detail,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DrainSessionsTable, DrainSession>(table),
                  $$DrainSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({deviceId = false, rawHistoryPagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rawHistoryPagesRefs) db.rawHistoryPages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (deviceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.deviceId,
                            referencedTable: $$DrainSessionsTableReferences
                                ._deviceIdTable(db),
                            referencedColumn: $$DrainSessionsTableReferences
                                ._deviceIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rawHistoryPagesRefs)
                        await $_getPrefetchedDataByColumns<
                          DrainSession,
                          $DrainSessionsTable,
                          RawHistoryPage,
                          $RawHistoryPagesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DrainSessionsTableReferences
                              ._rawHistoryPagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DrainSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).rawHistoryPagesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DrainSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $DrainSessionsTable,
      DrainSession,
      $$DrainSessionsTableFilterComposer,
      $$DrainSessionsTableOrderingComposer,
      $$DrainSessionsTableAnnotationComposer,
      $$DrainSessionsTableCreateCompanionBuilder,
      $$DrainSessionsTableUpdateCompanionBuilder,
      (DrainSession, $$DrainSessionsTableReferences),
      DrainSession,
      PrefetchHooks Function({bool deviceId, bool rawHistoryPagesRefs})
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String deviceId,
      required int opcode,
      required int lastAcknowledgedCursor,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> deviceId,
      Value<int> opcode,
      Value<int> lastAcknowledgedCursor,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SyncCursorsTableReferences
    extends BaseReferences<_$RingDatabase, $SyncCursorsTable, SyncCursor> {
  $$SyncCursorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$RingDatabase db) =>
      db.devices.createAlias('sync_cursors__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncCursorsTableFilterComposer
    extends Composer<_$RingDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get opcode => $composableBuilder(
    column: $table.opcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAcknowledgedCursor => $composableBuilder(
    column: $table.lastAcknowledgedCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$RingDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get opcode => $composableBuilder(
    column: $table.opcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAcknowledgedCursor => $composableBuilder(
    column: $table.lastAcknowledgedCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$RingDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get opcode =>
      $composableBuilder(column: $table.opcode, builder: (column) => column);

  GeneratedColumn<int> get lastAcknowledgedCursor => $composableBuilder(
    column: $table.lastAcknowledgedCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (SyncCursor, $$SyncCursorsTableReferences),
          SyncCursor,
          PrefetchHooks Function({bool deviceId})
        > {
  $$SyncCursorsTableTableManager(_$RingDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<int> opcode = const Value.absent(),
                Value<int> lastAcknowledgedCursor = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                deviceId: deviceId,
                opcode: opcode,
                lastAcknowledgedCursor: lastAcknowledgedCursor,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required int opcode,
                required int lastAcknowledgedCursor,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                deviceId: deviceId,
                opcode: opcode,
                lastAcknowledgedCursor: lastAcknowledgedCursor,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursor>(table),
                  $$SyncCursorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$SyncCursorsTableReferences
                            ._deviceIdTable(db),
                        referencedColumn: $$SyncCursorsTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (SyncCursor, $$SyncCursorsTableReferences),
      SyncCursor,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$RawHistoryPagesTableCreateCompanionBuilder =
    RawHistoryPagesCompanion Function({
      Value<int> id,
      required int sessionId,
      required int opcode,
      required int remaining,
      required DateTime receivedAt,
      Value<bool> acknowledged,
      required Uint8List raw,
    });
typedef $$RawHistoryPagesTableUpdateCompanionBuilder =
    RawHistoryPagesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> opcode,
      Value<int> remaining,
      Value<DateTime> receivedAt,
      Value<bool> acknowledged,
      Value<Uint8List> raw,
    });

final class $$RawHistoryPagesTableReferences
    extends
        BaseReferences<_$RingDatabase, $RawHistoryPagesTable, RawHistoryPage> {
  $$RawHistoryPagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DrainSessionsTable _sessionIdTable(_$RingDatabase db) => db
      .drainSessions
      .createAlias('raw_history_pages__session_id__drain_sessions__id');

  $$DrainSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$DrainSessionsTableTableManager(
      $_db,
      $_db.drainSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RawHistoryPagesTableFilterComposer
    extends Composer<_$RingDatabase, $RawHistoryPagesTable> {
  $$RawHistoryPagesTableFilterComposer({
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

  ColumnFilters<int> get opcode => $composableBuilder(
    column: $table.opcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  $$DrainSessionsTableFilterComposer get sessionId {
    final $$DrainSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.drainSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrainSessionsTableFilterComposer(
            $db: $db,
            $table: $db.drainSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RawHistoryPagesTableOrderingComposer
    extends Composer<_$RingDatabase, $RawHistoryPagesTable> {
  $$RawHistoryPagesTableOrderingComposer({
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

  ColumnOrderings<int> get opcode => $composableBuilder(
    column: $table.opcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  $$DrainSessionsTableOrderingComposer get sessionId {
    final $$DrainSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.drainSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrainSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.drainSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RawHistoryPagesTableAnnotationComposer
    extends Composer<_$RingDatabase, $RawHistoryPagesTable> {
  $$RawHistoryPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get opcode =>
      $composableBuilder(column: $table.opcode, builder: (column) => column);

  GeneratedColumn<int> get remaining =>
      $composableBuilder(column: $table.remaining, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  $$DrainSessionsTableAnnotationComposer get sessionId {
    final $$DrainSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.drainSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrainSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.drainSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RawHistoryPagesTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $RawHistoryPagesTable,
          RawHistoryPage,
          $$RawHistoryPagesTableFilterComposer,
          $$RawHistoryPagesTableOrderingComposer,
          $$RawHistoryPagesTableAnnotationComposer,
          $$RawHistoryPagesTableCreateCompanionBuilder,
          $$RawHistoryPagesTableUpdateCompanionBuilder,
          (RawHistoryPage, $$RawHistoryPagesTableReferences),
          RawHistoryPage,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RawHistoryPagesTableTableManager(
    _$RingDatabase db,
    $RawHistoryPagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RawHistoryPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RawHistoryPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RawHistoryPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> opcode = const Value.absent(),
                Value<int> remaining = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<bool> acknowledged = const Value.absent(),
                Value<Uint8List> raw = const Value.absent(),
              }) => RawHistoryPagesCompanion(
                id: id,
                sessionId: sessionId,
                opcode: opcode,
                remaining: remaining,
                receivedAt: receivedAt,
                acknowledged: acknowledged,
                raw: raw,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int opcode,
                required int remaining,
                required DateTime receivedAt,
                Value<bool> acknowledged = const Value.absent(),
                required Uint8List raw,
              }) => RawHistoryPagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                opcode: opcode,
                remaining: remaining,
                receivedAt: receivedAt,
                acknowledged: acknowledged,
                raw: raw,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RawHistoryPagesTable, RawHistoryPage>(table),
                  $$RawHistoryPagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$RawHistoryPagesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$RawHistoryPagesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RawHistoryPagesTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $RawHistoryPagesTable,
      RawHistoryPage,
      $$RawHistoryPagesTableFilterComposer,
      $$RawHistoryPagesTableOrderingComposer,
      $$RawHistoryPagesTableAnnotationComposer,
      $$RawHistoryPagesTableCreateCompanionBuilder,
      $$RawHistoryPagesTableUpdateCompanionBuilder,
      (RawHistoryPage, $$RawHistoryPagesTableReferences),
      RawHistoryPage,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$RawPacketsTableCreateCompanionBuilder = RawPacketsCompanion Function({
  Value<int> id,
  required String deviceId,
  required int connection,
  required int elapsedMs,
  required String direction,
  required Uint8List raw,
});
typedef $$RawPacketsTableUpdateCompanionBuilder = RawPacketsCompanion Function({
  Value<int> id,
  Value<String> deviceId,
  Value<int> connection,
  Value<int> elapsedMs,
  Value<String> direction,
  Value<Uint8List> raw,
});

final class $$RawPacketsTableReferences
    extends BaseReferences<_$RingDatabase, $RawPacketsTable, RawPacket> {
  $$RawPacketsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$RingDatabase db) =>
      db.devices.createAlias('raw_packets__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RawPacketsTableFilterComposer
    extends Composer<_$RingDatabase, $RawPacketsTable> {
  $$RawPacketsTableFilterComposer({
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

  ColumnFilters<int> get connection => $composableBuilder(
    column: $table.connection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RawPacketsTableOrderingComposer
    extends Composer<_$RingDatabase, $RawPacketsTable> {
  $$RawPacketsTableOrderingComposer({
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

  ColumnOrderings<int> get connection => $composableBuilder(
    column: $table.connection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RawPacketsTableAnnotationComposer
    extends Composer<_$RingDatabase, $RawPacketsTable> {
  $$RawPacketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get connection => $composableBuilder(
    column: $table.connection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<Uint8List> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RawPacketsTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $RawPacketsTable,
          RawPacket,
          $$RawPacketsTableFilterComposer,
          $$RawPacketsTableOrderingComposer,
          $$RawPacketsTableAnnotationComposer,
          $$RawPacketsTableCreateCompanionBuilder,
          $$RawPacketsTableUpdateCompanionBuilder,
          (RawPacket, $$RawPacketsTableReferences),
          RawPacket,
          PrefetchHooks Function({bool deviceId})
        > {
  $$RawPacketsTableTableManager(_$RingDatabase db, $RawPacketsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RawPacketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RawPacketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RawPacketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> connection = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<Uint8List> raw = const Value.absent(),
              }) => RawPacketsCompanion(
                id: id,
                deviceId: deviceId,
                connection: connection,
                elapsedMs: elapsedMs,
                direction: direction,
                raw: raw,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required int connection,
                required int elapsedMs,
                required String direction,
                required Uint8List raw,
              }) => RawPacketsCompanion.insert(
                id: id,
                deviceId: deviceId,
                connection: connection,
                elapsedMs: elapsedMs,
                direction: direction,
                raw: raw,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RawPacketsTable, RawPacket>(table),
                  $$RawPacketsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$RawPacketsTableReferences
                            ._deviceIdTable(db),
                        referencedColumn: $$RawPacketsTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RawPacketsTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $RawPacketsTable,
      RawPacket,
      $$RawPacketsTableFilterComposer,
      $$RawPacketsTableOrderingComposer,
      $$RawPacketsTableAnnotationComposer,
      $$RawPacketsTableCreateCompanionBuilder,
      $$RawPacketsTableUpdateCompanionBuilder,
      (RawPacket, $$RawPacketsTableReferences),
      RawPacket,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$HealthExportCheckpointsTableCreateCompanionBuilder =
    HealthExportCheckpointsCompanion Function({
      required String deviceId,
      required String metric,
      required int maxCursor,
      Value<int> rowid,
    });
typedef $$HealthExportCheckpointsTableUpdateCompanionBuilder =
    HealthExportCheckpointsCompanion Function({
      Value<String> deviceId,
      Value<String> metric,
      Value<int> maxCursor,
      Value<int> rowid,
    });

final class $$HealthExportCheckpointsTableReferences
    extends
        BaseReferences<
          _$RingDatabase,
          $HealthExportCheckpointsTable,
          HealthExportCheckpoint
        > {
  $$HealthExportCheckpointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$RingDatabase db) => db.devices
      .createAlias('health_export_checkpoints__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HealthExportCheckpointsTableFilterComposer
    extends Composer<_$RingDatabase, $HealthExportCheckpointsTable> {
  $$HealthExportCheckpointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxCursor => $composableBuilder(
    column: $table.maxCursor,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthExportCheckpointsTableOrderingComposer
    extends Composer<_$RingDatabase, $HealthExportCheckpointsTable> {
  $$HealthExportCheckpointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxCursor => $composableBuilder(
    column: $table.maxCursor,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthExportCheckpointsTableAnnotationComposer
    extends Composer<_$RingDatabase, $HealthExportCheckpointsTable> {
  $$HealthExportCheckpointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get metric =>
      $composableBuilder(column: $table.metric, builder: (column) => column);

  GeneratedColumn<int> get maxCursor =>
      $composableBuilder(column: $table.maxCursor, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthExportCheckpointsTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $HealthExportCheckpointsTable,
          HealthExportCheckpoint,
          $$HealthExportCheckpointsTableFilterComposer,
          $$HealthExportCheckpointsTableOrderingComposer,
          $$HealthExportCheckpointsTableAnnotationComposer,
          $$HealthExportCheckpointsTableCreateCompanionBuilder,
          $$HealthExportCheckpointsTableUpdateCompanionBuilder,
          (HealthExportCheckpoint, $$HealthExportCheckpointsTableReferences),
          HealthExportCheckpoint,
          PrefetchHooks Function({bool deviceId})
        > {
  $$HealthExportCheckpointsTableTableManager(
    _$RingDatabase db,
    $HealthExportCheckpointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthExportCheckpointsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HealthExportCheckpointsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HealthExportCheckpointsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> metric = const Value.absent(),
                Value<int> maxCursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthExportCheckpointsCompanion(
                deviceId: deviceId,
                metric: metric,
                maxCursor: maxCursor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String metric,
                required int maxCursor,
                Value<int> rowid = const Value.absent(),
              }) => HealthExportCheckpointsCompanion.insert(
                deviceId: deviceId,
                metric: metric,
                maxCursor: maxCursor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $HealthExportCheckpointsTable,
                    HealthExportCheckpoint
                  >(table),
                  $$HealthExportCheckpointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable:
                            $$HealthExportCheckpointsTableReferences
                                ._deviceIdTable(db),
                        referencedColumn:
                            $$HealthExportCheckpointsTableReferences
                                ._deviceIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HealthExportCheckpointsTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $HealthExportCheckpointsTable,
      HealthExportCheckpoint,
      $$HealthExportCheckpointsTableFilterComposer,
      $$HealthExportCheckpointsTableOrderingComposer,
      $$HealthExportCheckpointsTableAnnotationComposer,
      $$HealthExportCheckpointsTableCreateCompanionBuilder,
      $$HealthExportCheckpointsTableUpdateCompanionBuilder,
      (HealthExportCheckpoint, $$HealthExportCheckpointsTableReferences),
      HealthExportCheckpoint,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$HealthExportWritesTableCreateCompanionBuilder =
    HealthExportWritesCompanion Function({
      required String deviceId,
      required String metric,
      required int cursor,
      required int exportedAtMicros,
      Value<int> rowid,
    });
typedef $$HealthExportWritesTableUpdateCompanionBuilder =
    HealthExportWritesCompanion Function({
      Value<String> deviceId,
      Value<String> metric,
      Value<int> cursor,
      Value<int> exportedAtMicros,
      Value<int> rowid,
    });

final class $$HealthExportWritesTableReferences
    extends
        BaseReferences<
          _$RingDatabase,
          $HealthExportWritesTable,
          HealthExportWrite
        > {
  $$HealthExportWritesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$RingDatabase db) =>
      db.devices.createAlias('health_export_writes__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HealthExportWritesTableFilterComposer
    extends Composer<_$RingDatabase, $HealthExportWritesTable> {
  $$HealthExportWritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exportedAtMicros => $composableBuilder(
    column: $table.exportedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthExportWritesTableOrderingComposer
    extends Composer<_$RingDatabase, $HealthExportWritesTable> {
  $$HealthExportWritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exportedAtMicros => $composableBuilder(
    column: $table.exportedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthExportWritesTableAnnotationComposer
    extends Composer<_$RingDatabase, $HealthExportWritesTable> {
  $$HealthExportWritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get metric =>
      $composableBuilder(column: $table.metric, builder: (column) => column);

  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<int> get exportedAtMicros => $composableBuilder(
    column: $table.exportedAtMicros,
    builder: (column) => column,
  );

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthExportWritesTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $HealthExportWritesTable,
          HealthExportWrite,
          $$HealthExportWritesTableFilterComposer,
          $$HealthExportWritesTableOrderingComposer,
          $$HealthExportWritesTableAnnotationComposer,
          $$HealthExportWritesTableCreateCompanionBuilder,
          $$HealthExportWritesTableUpdateCompanionBuilder,
          (HealthExportWrite, $$HealthExportWritesTableReferences),
          HealthExportWrite,
          PrefetchHooks Function({bool deviceId})
        > {
  $$HealthExportWritesTableTableManager(
    _$RingDatabase db,
    $HealthExportWritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthExportWritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthExportWritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthExportWritesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> metric = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                Value<int> exportedAtMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthExportWritesCompanion(
                deviceId: deviceId,
                metric: metric,
                cursor: cursor,
                exportedAtMicros: exportedAtMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String metric,
                required int cursor,
                required int exportedAtMicros,
                Value<int> rowid = const Value.absent(),
              }) => HealthExportWritesCompanion.insert(
                deviceId: deviceId,
                metric: metric,
                cursor: cursor,
                exportedAtMicros: exportedAtMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HealthExportWritesTable, HealthExportWrite>(
                    table,
                  ),
                  $$HealthExportWritesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$HealthExportWritesTableReferences
                            ._deviceIdTable(db),
                        referencedColumn: $$HealthExportWritesTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HealthExportWritesTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $HealthExportWritesTable,
      HealthExportWrite,
      $$HealthExportWritesTableFilterComposer,
      $$HealthExportWritesTableOrderingComposer,
      $$HealthExportWritesTableAnnotationComposer,
      $$HealthExportWritesTableCreateCompanionBuilder,
      $$HealthExportWritesTableUpdateCompanionBuilder,
      (HealthExportWrite, $$HealthExportWritesTableReferences),
      HealthExportWrite,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$RingDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$RingDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$RingDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$RingDatabase,
          $AppPreferencesTable,
          AppPreference,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreference,
            BaseReferences<_$RingDatabase, $AppPreferencesTable, AppPreference>,
          ),
          AppPreference,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$RingDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppPreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppPreferencesTable, AppPreference>(table),
                  BaseReferences<
                    _$RingDatabase,
                    $AppPreferencesTable,
                    AppPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$RingDatabase,
      $AppPreferencesTable,
      AppPreference,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreference,
        BaseReferences<_$RingDatabase, $AppPreferencesTable, AppPreference>,
      ),
      AppPreference,
      PrefetchHooks Function()
    >;

class $RingDatabaseManager {
  final _$RingDatabase _db;
  $RingDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$TelemetrySnapshotsTableTableManager get telemetrySnapshots =>
      $$TelemetrySnapshotsTableTableManager(_db, _db.telemetrySnapshots);
  $$LiveHrSamplesTableTableManager get liveHrSamples =>
      $$LiveHrSamplesTableTableManager(_db, _db.liveHrSamples);
  $$EpochsTableTableManager get epochs =>
      $$EpochsTableTableManager(_db, _db.epochs);
  $$ThermalBlocksTableTableManager get thermalBlocks =>
      $$ThermalBlocksTableTableManager(_db, _db.thermalBlocks);
  $$DrainSessionsTableTableManager get drainSessions =>
      $$DrainSessionsTableTableManager(_db, _db.drainSessions);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$RawHistoryPagesTableTableManager get rawHistoryPages =>
      $$RawHistoryPagesTableTableManager(_db, _db.rawHistoryPages);
  $$RawPacketsTableTableManager get rawPackets =>
      $$RawPacketsTableTableManager(_db, _db.rawPackets);
  $$HealthExportCheckpointsTableTableManager get healthExportCheckpoints =>
      $$HealthExportCheckpointsTableTableManager(
        _db,
        _db.healthExportCheckpoints,
      );
  $$HealthExportWritesTableTableManager get healthExportWrites =>
      $$HealthExportWritesTableTableManager(_db, _db.healthExportWrites);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
}
