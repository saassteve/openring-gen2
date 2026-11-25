import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:ring_protocol/ring_protocol.dart';

import 'health_metric.dart';

part 'ring_database.g.dart';

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get platformId => text()();
  TextColumn get name => text()();
  TextColumn get firmware => text().nullable()();
  TextColumn get serial => text().nullable()();
  BlobColumn get systemId => blob()();
  DateTimeColumn get lastSeenAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'telemetry_device_time', columns: {#deviceId, #capturedAt})
class TelemetrySnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().references(Devices, #id)();
  DateTimeColumn get capturedAt => dateTime()();
  IntColumn get batteryPercent => integer()();
  IntColumn get batteryMillivolts => integer()();
  RealColumn get temperature1 => real()();
  RealColumn get temperature2 => real()();
  IntColumn get wearCode => integer()();
  IntColumn get modeFlags => integer()();
  BlobColumn get raw => blob()();
}

@DataClassName('LiveHrSample')
class LiveHrSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().references(Devices, #id)();
  DateTimeColumn get capturedAt => dateTime()();
  IntColumn get bpm => integer().nullable()();
  BlobColumn get raw => blob()();
}

class Epochs extends Table {
  TextColumn get deviceId => text().references(Devices, #id)();
  IntColumn get cursor => integer()();
  DateTimeColumn get endedAt => dateTime()();
  IntColumn get bpm => integer().nullable()();
  IntColumn get hrvMs => integer().nullable()();
  IntColumn get ppgQuality => integer()();
  RealColumn get respiratoryRate => real().nullable()();
  IntColumn get oxygenPercent => integer().nullable()();
  TextColumn get oxygenState => text()();
  RealColumn get activityMet => real()();
  IntColumn get flags => integer()();
  BlobColumn get raw => blob()();

  @override
  Set<Column> get primaryKey => {deviceId, cursor};
}

@DataClassName('StoredThermalBlock')
class ThermalBlocks extends Table {
  TextColumn get deviceId => text().references(Devices, #id)();
  IntColumn get cursor => integer()();
  DateTimeColumn get endedAt => dateTime()();
  IntColumn get subtype => integer()();
  IntColumn get batteryPercent => integer()();
  BoolColumn get activity => boolean()();
  IntColumn get steps => integer()();
  IntColumn get activeTimeRaw => integer()();
  RealColumn get meanOuterTemperature => real()();
  RealColumn get meanInnerTemperature => real()();
  BlobColumn get raw => blob()();

  @override
  Set<Column> get primaryKey => {deviceId, cursor};
}

class DrainSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().references(Devices, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get requestedCursor => integer()();
  IntColumn get channel => integer()();
  TextColumn get state => text()();
  IntColumn get pagesAcknowledged => integer().withDefault(const Constant(0))();
  IntColumn get recordsAcknowledged =>
      integer().withDefault(const Constant(0))();
  TextColumn get detail => text().nullable()();
}

class SyncCursors extends Table {
  TextColumn get deviceId => text().references(Devices, #id)();
  IntColumn get opcode => integer()();
  IntColumn get lastAcknowledgedCursor => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {deviceId, opcode};
}

class RawHistoryPages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(DrainSessions, #id)();
  IntColumn get opcode => integer()();
  IntColumn get remaining => integer()();
  DateTimeColumn get receivedAt => dateTime()();
  BoolColumn get acknowledged => boolean().withDefault(const Constant(false))();
  BlobColumn get raw => blob()();
}

@TableIndex(name: 'trace_connection', columns: {#connection})
class RawPackets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().references(Devices, #id)();
  IntColumn get connection => integer()();
  IntColumn get elapsedMs => integer()();
  TextColumn get direction => text()();
  BlobColumn get raw => blob()();
}

class HealthExportCheckpoints extends Table {
  TextColumn get deviceId => text().references(Devices, #id)();
  TextColumn get metric => text()();
  IntColumn get maxCursor => integer()();

  @override
  Set<Column> get primaryKey => {deviceId, metric};
}

@TableIndex(name: 'health_export_run', columns: {#exportedAtMicros})
class HealthExportWrites extends Table {
  TextColumn get deviceId => text().references(Devices, #id)();
  TextColumn get metric => text()();
  IntColumn get cursor => integer()();
  IntColumn get exportedAtMicros => integer()();

  @override
  Set<Column> get primaryKey => {deviceId, metric, cursor};
}

class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Devices,
    TelemetrySnapshots,
    LiveHrSamples,
    Epochs,
    ThermalBlocks,
    DrainSessions,
    SyncCursors,
    RawHistoryPages,
    RawPackets,
    HealthExportCheckpoints,
    HealthExportWrites,
    AppPreferences,
  ],
)
class RingDatabase extends _$RingDatabase {
  RingDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'ringconn_companion'));

  static const autoHealthExportKey = 'auto_health_export';

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await transaction(() async {
          await migrator.createTable(healthExportCheckpoints);
          await migrator.createTable(healthExportWrites);
          await migrator.createIndex(healthExportRun);
        });
      }
      if (from < 3) {
        await migrator.createTable(appPreferences);
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await (update(
        drainSessions,
      )..where((row) => row.finishedAt.isNull())).write(
        DrainSessionsCompanion(
          state: const Value('interrupted'),
          detail: const Value('The app closed before sync finished.'),
          finishedAt: Value(DateTime.now()),
        ),
      );
    },
  );

  Future<void> rememberDevice(DevicesCompanion device) =>
      into(devices).insertOnConflictUpdate(device);

  Future<void> saveTelemetry(
    String deviceId,
    DateTime time,
    TelemetryFrame frame,
  ) => into(telemetrySnapshots).insert(
    TelemetrySnapshotsCompanion.insert(
      deviceId: deviceId,
      capturedAt: time,
      batteryPercent: frame.batteryPercent,
      batteryMillivolts: frame.batteryMillivolts,
      temperature1: frame.temperature1,
      temperature2: frame.temperature2,
      wearCode: frame.wearCode,
      modeFlags: frame.modeFlags,
      raw: frame.raw,
    ),
  );

  Future<void> saveHeartRate(
    String deviceId,
    DateTime time,
    LiveHeartRateFrame frame,
  ) => into(liveHrSamples).insert(
    LiveHrSamplesCompanion.insert(
      deviceId: deviceId,
      capturedAt: time,
      bpm: Value(frame.bpm),
      raw: frame.raw,
    ),
  );

  Future<int> openDrain(String deviceId, HistoryDrain drain, DateTime time) =>
      into(drainSessions).insert(
        DrainSessionsCompanion.insert(
          deviceId: deviceId,
          startedAt: time,
          requestedCursor: drain.cursor,
          channel: drain.channel,
          state: DrainPhase.waiting.name,
        ),
      );

  Future<int> savePage(
    int sessionId,
    String deviceId,
    HistoryPage page,
    DateTime time,
  ) => transaction(() async {
    final pageId = await into(rawHistoryPages).insert(
      RawHistoryPagesCompanion.insert(
        sessionId: sessionId,
        opcode: page.opcode,
        remaining: page.remaining,
        receivedAt: time,
        raw: page.raw,
      ),
    );
    await batch((batch) {
      for (final record in page.records) {
        switch (record) {
          case EpochRecord():
            batch.insert(
              epochs,
              EpochsCompanion.insert(
                deviceId: deviceId,
                cursor: record.cursor,
                endedAt: record.endedAt,
                bpm: Value(record.bpm),
                hrvMs: Value(record.hrvMs),
                ppgQuality: record.ppgQuality,
                respiratoryRate: Value(record.respiratoryRate),
                oxygenPercent: Value(record.oxygenPercent),
                oxygenState: record.oxygenState.name,
                activityMet: record.activityMet,
                flags: record.flags,
                raw: record.raw,
              ),
              mode: InsertMode.insertOrIgnore,
            );
          case ThermalBlock():
            batch.insert(
              thermalBlocks,
              ThermalBlocksCompanion.insert(
                deviceId: deviceId,
                cursor: record.cursor,
                endedAt: record.endedAt,
                subtype: record.subtype,
                batteryPercent: record.batteryPercent,
                activity: record.activity,
                steps: record.steps,
                activeTimeRaw: record.activeTimeRaw,
                meanOuterTemperature: _mean(record.outerTemperatures),
                meanInnerTemperature: _mean(record.innerTemperatures),
                raw: record.raw,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        }
      }
    });
    return pageId;
  });

  Future<void> confirmPage({
    required int pageId,
    required int sessionId,
    required String deviceId,
    required HistoryPage page,
    required HistoryDrain drain,
    required DateTime time,
  }) => transaction(() async {
    await (update(rawHistoryPages)..where((row) => row.id.equals(pageId)))
        .write(const RawHistoryPagesCompanion(acknowledged: Value(true)));
    final newest = page.records
        .map((record) => record.cursor)
        .reduce((a, b) => a > b ? a : b);
    final current =
        await (select(syncCursors)..where(
              (row) =>
                  row.deviceId.equals(deviceId) &
                  row.opcode.equals(page.opcode),
            ))
            .getSingleOrNull();
    if (current == null || newest > current.lastAcknowledgedCursor) {
      await into(syncCursors).insertOnConflictUpdate(
        SyncCursorsCompanion.insert(
          deviceId: deviceId,
          opcode: page.opcode,
          lastAcknowledgedCursor: newest,
          updatedAt: time,
        ),
      );
    }
    await (update(
      drainSessions,
    )..where((row) => row.id.equals(sessionId))).write(
      DrainSessionsCompanion(
        pagesAcknowledged: Value(drain.pagesAcknowledged),
        recordsAcknowledged: Value(drain.recordsAcknowledged),
      ),
    );
  });

  Future<void> closeDrain(int sessionId, HistoryDrain drain, String? detail) =>
      (update(drainSessions)..where((row) => row.id.equals(sessionId))).write(
        DrainSessionsCompanion(
          state: Value(drain.phase.name),
          finishedAt: Value(DateTime.now()),
          detail: Value(detail),
        ),
      );

  Future<Device?> latestDevice() =>
      (select(devices)
            ..orderBy([(row) => OrderingTerm.desc(row.lastSeenAt)])
            ..limit(1))
          .getSingleOrNull();

  Stream<List<TelemetrySnapshot>> watchBattery(String deviceId) =>
      (select(telemetrySnapshots)
            ..where((row) => row.deviceId.equals(deviceId))
            ..orderBy([(row) => OrderingTerm.desc(row.id)])
            ..limit(1440))
          .watch()
          .map((rows) => rows.reversed.toList(growable: false));

  Stream<DrainSession?> watchLastDrain(String deviceId) =>
      (select(drainSessions)
            ..where((row) => row.deviceId.equals(deviceId))
            ..orderBy([(row) => OrderingTerm.desc(row.id)])
            ..limit(1))
          .watchSingleOrNull();

  Future<void> savePacket({
    required String deviceId,
    required int connection,
    required int elapsedMs,
    required String direction,
    required Uint8List bytes,
  }) => into(rawPackets).insert(
    RawPacketsCompanion.insert(
      deviceId: deviceId,
      connection: connection,
      elapsedMs: elapsedMs,
      direction: direction,
      raw: bytes,
    ),
  );

  Future<int?> latestTraceConnection() async {
    final row =
        await (select(rawPackets)
              ..orderBy([(row) => OrderingTerm.desc(row.id)])
              ..limit(1))
            .getSingleOrNull();
    return row?.connection;
  }

  Stream<RawPacket> tracePackets(int connection) async* {
    final last =
        await (select(rawPackets)
              ..where((row) => row.connection.equals(connection))
              ..orderBy([(row) => OrderingTerm.desc(row.id)])
              ..limit(1))
            .getSingleOrNull();
    if (last == null) return;
    var offsetId = 0;
    while (true) {
      final rows =
          await (select(rawPackets)
                ..where(
                  (row) =>
                      row.connection.equals(connection) &
                      row.id.isBiggerThanValue(offsetId) &
                      row.id.isSmallerOrEqualValue(last.id),
                )
                ..orderBy([(row) => OrderingTerm.asc(row.id)])
                ..limit(500))
              .get();
      if (rows.isEmpty) return;
      for (final row in rows) {
        yield row;
      }
      offsetId = rows.last.id;
    }
  }

  Future<List<HealthSample>> pendingHealthSamples(
    HealthMetric metric, {
    required int through,
    required int limit,
  }) async {
    Expression<bool> pending(TextColumn device, IntColumn cursor) {
      final checkpoint = selectOnly(healthExportCheckpoints)
        ..addColumns([healthExportCheckpoints.maxCursor])
        ..where(
          healthExportCheckpoints.metric.equals(metric.name) &
              healthExportCheckpoints.deviceId.equalsExp(device) &
              healthExportCheckpoints.maxCursor.isBiggerOrEqual(cursor),
        );
      final exported = selectOnly(healthExportWrites)
        ..addColumns([healthExportWrites.cursor])
        ..where(
          healthExportWrites.metric.equals(metric.name) &
              healthExportWrites.deviceId.equalsExp(device) &
              healthExportWrites.cursor.equalsExp(cursor),
        );
      // Older pages can arrive after a newer cursor has already been exported.
      // Check their individual receipts so the high-water mark cannot skip them.
      return cursor.isSmallerOrEqualValue(through) &
          (notExistsQuery(checkpoint) | notExistsQuery(exported));
    }

    if (metric == HealthMetric.steps) {
      final blocks =
          await (select(thermalBlocks)
                ..where(
                  (row) =>
                      row.steps.isBiggerThanValue(0) &
                      pending(row.deviceId, row.cursor),
                )
                ..orderBy([
                  (row) => OrderingTerm.asc(row.deviceId),
                  (row) => OrderingTerm.asc(row.cursor),
                ])
                ..limit(limit))
              .get();
      return [
        for (final row in blocks)
          (
            deviceId: row.deviceId,
            cursor: row.cursor,
            values: [row.steps.toDouble()],
          ),
      ];
    }

    if (metric == HealthMetric.outerTemperature ||
        metric == HealthMetric.innerTemperature) {
      final blocks =
          await (select(thermalBlocks)
                ..where((row) => pending(row.deviceId, row.cursor))
                ..orderBy([
                  (row) => OrderingTerm.asc(row.deviceId),
                  (row) => OrderingTerm.asc(row.cursor),
                ])
                ..limit(limit))
              .get();
      return [
        for (final row in blocks)
          (
            deviceId: row.deviceId,
            cursor: row.cursor,
            values: switch (metric) {
              HealthMetric.outerTemperature => ThermalBlock.decode(
                row.raw,
              ).outerTemperatures,
              _ => ThermalBlock.decode(row.raw).innerTemperatures,
            },
          ),
      ];
    }

    final rows =
        await (select(epochs)
              ..where((row) {
                final valid = switch (metric) {
                  HealthMetric.heartRate => row.bpm.isBetweenValues(30, 255),
                  HealthMetric.hrv => row.hrvMs.isBetweenValues(1, 200),
                  HealthMetric.oxygen =>
                    row.oxygenState.equals(OxygenState.measured.name) &
                        row.oxygenPercent.isBetweenValues(1, 100),
                  HealthMetric.respiratoryRate =>
                    row.respiratoryRate.isBiggerThanValue(0),
                  _ => throw ArgumentError.value(metric),
                };
                return valid & pending(row.deviceId, row.cursor);
              })
              ..orderBy([
                (row) => OrderingTerm.asc(row.deviceId),
                (row) => OrderingTerm.asc(row.cursor),
              ])
              ..limit(limit))
            .get();
    return [
      for (final row in rows)
        (
          deviceId: row.deviceId,
          cursor: row.cursor,
          values: [
            switch (metric) {
              HealthMetric.heartRate => row.bpm!.toDouble(),
              HealthMetric.hrv => row.hrvMs!.toDouble(),
              HealthMetric.oxygen => row.oxygenPercent!.toDouble(),
              HealthMetric.respiratoryRate => row.respiratoryRate!,
              _ => throw ArgumentError.value(metric),
            },
          ],
        ),
    ];
  }

  Future<void> confirmHealthWrites(
    HealthMetric metric,
    List<HealthSample> samples,
    DateTime exportedAt,
  ) => transaction(() async {
    final maxima = <String, int>{};
    await batch((batch) {
      for (final sample in samples) {
        batch.insert(
          healthExportWrites,
          HealthExportWritesCompanion.insert(
            deviceId: sample.deviceId,
            metric: metric.name,
            cursor: sample.cursor,
            exportedAtMicros: exportedAt.microsecondsSinceEpoch,
          ),
          mode: InsertMode.insertOrIgnore,
        );
        final previous = maxima[sample.deviceId];
        if (previous == null || sample.cursor > previous) {
          maxima[sample.deviceId] = sample.cursor;
        }
      }
    });
    for (final entry in maxima.entries) {
      await customStatement(
        'INSERT INTO health_export_checkpoints (device_id, metric, max_cursor) '
        'VALUES (?, ?, ?) ON CONFLICT (device_id, metric) DO UPDATE SET '
        'max_cursor = MAX(max_cursor, excluded.max_cursor)',
        [entry.key, metric.name, entry.value],
      );
    }
  });

  Future<HealthExportReport?> latestHealthExport() => transaction(() async {
    final latest = healthExportWrites.exportedAtMicros.max();
    final recent = await (selectOnly(
      healthExportWrites,
    )..addColumns([latest])).getSingle();
    final micros = recent.read(latest);
    if (micros == null) return null;
    final metric = healthExportWrites.metric;
    final count = healthExportWrites.cursor.count();
    final rows =
        await (selectOnly(healthExportWrites)
              ..addColumns([metric, count])
              ..where(healthExportWrites.exportedAtMicros.equals(micros))
              ..groupBy([metric]))
            .get();
    return (
      at: DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true),
      counts: {
        for (final row in rows)
          HealthMetric.values.byName(row.read(metric)!): row.read(count)!,
      },
    );
  });

  Future<bool> getAutoHealthExport() async {
    final row = await (select(appPreferences)
          ..where((pref) => pref.key.equals(autoHealthExportKey)))
        .getSingleOrNull();
    return row == null ? true : row.value != 'false';
  }

  Future<void> setAutoHealthExport(bool enabled) => into(appPreferences)
      .insertOnConflictUpdate(
        AppPreferencesCompanion.insert(
          key: autoHealthExportKey,
          value: enabled ? 'true' : 'false',
        ),
      );

  Future<String?> getPreference(String key) async {
    final row = await (select(appPreferences)
          ..where((pref) => pref.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setPreference(String key, String value) => into(appPreferences)
      .insertOnConflictUpdate(
        AppPreferencesCompanion.insert(key: key, value: value),
      );

  Stream<bool> watchAutoHealthExport() => (select(appPreferences)
        ..where((pref) => pref.key.equals(autoHealthExportKey)))
      .watchSingleOrNull()
      .map((row) => row == null ? true : row.value != 'false');

  Future<CircadianInsights> loadCircadianInsights({String? deviceId}) async {
    final epochQuery = select(epochs)
      ..orderBy([(row) => OrderingTerm.asc(row.cursor)]);
    if (deviceId != null) {
      epochQuery.where((row) => row.deviceId.equals(deviceId));
    }
    final thermalQuery = select(thermalBlocks)
      ..orderBy([(row) => OrderingTerm.asc(row.cursor)]);
    if (deviceId != null) {
      thermalQuery.where((row) => row.deviceId.equals(deviceId));
    }
    final storedEpochs = await epochQuery.get();
    final storedThermals = await thermalQuery.get();
    final decodedEpochs = <EpochRecord>[];
    for (final row in storedEpochs) {
      final page = RingFrame.decode([
        0x4c,
        0,
        0,
        ...row.raw,
        [0x4c, 0, 0, ...row.raw].reduce((a, b) => a ^ b),
      ]) as HistoryPage;
      decodedEpochs.add(page.records.single as EpochRecord);
    }
    final decodedThermals = <ThermalBlock>[];
    for (final row in storedThermals) {
      final page = RingFrame.decode([
        0x47,
        0,
        0,
        ...row.raw,
        [0x47, 0, 0, ...row.raw].reduce((a, b) => a ^ b),
      ]) as HistoryPage;
      decodedThermals.add(page.records.single as ThermalBlock);
    }
    return CircadianInsights.fromRecords(
      epochs: decodedEpochs,
      thermalBlocks: decodedThermals,
    );
  }

  static double _mean(List<double> samples) =>
      samples.reduce((a, b) => a + b) / samples.length;
}
