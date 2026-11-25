import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ring_protocol/ring_protocol.dart';
import 'package:ringconn_companion/data/health_exporter.dart';
import 'package:ringconn_companion/data/health_metric.dart';
import 'package:ringconn_companion/data/ring_database.dart';

const _device = 'test-ring';

Future<void> _savePage(RingDatabase database, List<int> body) async {
  final page =
      RingFrame.decode([...body, body.reduce((a, b) => a ^ b)]) as HistoryPage;
  final now = DateTime.utc(2026, 11, 24);
  final drain = HistoryDrain(cursor: cursorFromTime(now))..start();
  final session = await database.openDrain(_device, drain, now);
  await database.savePage(session, _device, page, now);
}

List<int> _epoch(int cursor, {int hrv = 54, int oxygen = 98}) {
  final raw = Uint8List(23);
  ByteData.sublistView(raw).setUint32(0, cursor);
  raw.setRange(4, 10, [59, hrv, 8, 125, oxygen, 10]);
  return raw;
}

List<int> _thermal(int cursor, {int steps = 0}) {
  final raw = Uint8List(47)..[4] = 2;
  ByteData.sublistView(raw)
    ..setUint32(0, cursor)
    ..setUint16(6, steps);
  for (var sample = 0; sample < 15; sample++) {
    final outer = 600 + sample;
    final inner = 620 + sample;
    final word = (outer << 10) | inner;
    for (var bit = 0; bit < 20; bit++) {
      final offset = 72 + sample * 20 + bit;
      raw[offset ~/ 8] |= (word >> (19 - bit) & 1) << (7 - offset % 8);
    }
  }
  return raw;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('exports each granted metric, resumes after failure and catches late history', () async {
    final database = RingDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.rememberDevice(
      DevicesCompanion.insert(
        id: _device,
        platformId: 'phone-id',
        name: 'RingConn Gen2',
        systemId: Uint8List(6),
        lastSeenAt: DateTime.utc(2026, 11, 24),
      ),
    );
    await _savePage(database, [0x4c, 0, 0, ..._epoch(900)]);
    await _savePage(database, [0x47, 0, 0, ..._thermal(900, steps: 240)]);

    final calls = <String, List<Map<Object?, Object?>>>{};
    final types = HealthMetric.values.map((metric) => metric.name).toList();
    var failOxygen = true;
    var grantHrv = false;
    const channel = MethodChannel('ringconn/health_connect');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'authorize') {
        return {
          'available': types,
          'granted': types.where((type) => grantHrv || type != 'hrv').toList(),
        };
      }
      expect(call.method, 'insert');
      final arguments = call.arguments as Map<Object?, Object?>;
      final metric = arguments['metric'] as String;
      if (metric == 'oxygen' && failOxygen) {
        throw PlatformException(code: 'test_failure');
      }
      calls
          .putIfAbsent(metric, () => [])
          .addAll((arguments['records'] as List).cast<Map<Object?, Object?>>());
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final exporter = HealthExporter(database);
    final running = exporter.export();
    expect(exporter.export(), same(running));
    final partial = await running;
    expect(partial.failures.keys, [HealthMetric.oxygen]);
    expect((await exporter.latestReport())!.counts, {
      HealthMetric.heartRate: 1,
      HealthMetric.respiratoryRate: 1,
      HealthMetric.steps: 1,
      HealthMetric.outerTemperature: 1,
      HealthMetric.innerTemperature: 1,
    });
    expect(calls, isNot(contains('oxygen')));

    failOxygen = false;
    final retry = await exporter.export();
    expect(retry.denied, [HealthMetric.hrv]);
    expect(retry.counts, {HealthMetric.oxygen: 1});
    expect(calls['heartRate']!.single, {
      'id': 'ringconn:test-ring:heartRate:900',
      'timeMs': (1577793600 + 900) * 1000,
      'values': [59.0],
    });
    expect(calls['oxygen']!.single['values'], [98.0]);
    expect(calls['respiratoryRate']!.single['values'], [12.5]);
    expect(calls['steps']!.single['values'], [240.0]);
    expect(
      calls['outerTemperature']!.single['values'],
      List.generate(15, (i) => (600 + i) / 20),
    );
    expect(
      calls['innerTemperature']!.single['values'],
      List.generate(15, (i) => (620 + i) / 20),
    );
    expect(
      calls['outerTemperature']!.single['id'],
      isNot(calls['innerTemperature']!.single['id']),
    );
    expect((await exporter.export()).counts, isEmpty);

    grantHrv = true;
    await _savePage(database, [
      0x4c,
      0,
      0,
      ..._epoch(750, hrv: 250, oxygen: 17),
    ]);
    final backfill = await exporter.export();
    expect(backfill.counts, {
      HealthMetric.heartRate: 1,
      HealthMetric.hrv: 1,
      HealthMetric.respiratoryRate: 1,
    });
    expect(calls['hrv']!.single['values'], [54.0]);
    final checkpoints = await database
        .select(database.healthExportCheckpoints)
        .get();
    expect(checkpoints, hasLength(7));
    expect(checkpoints.map((checkpoint) => checkpoint.maxCursor).toSet(), {
      900,
    });
    expect((await exporter.latestReport())!.counts, backfill.counts);
    expect((await HealthExporter(database).export()).counts, isEmpty);
  });

  test('non-interactive auto-export uses silent checkPermissions and never prompts', () async {
    final database = RingDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.rememberDevice(
      DevicesCompanion.insert(
        id: _device,
        platformId: 'phone-id',
        name: 'RingConn Gen2',
        systemId: Uint8List(6),
        lastSeenAt: DateTime.utc(2026, 11, 24),
      ),
    );
    await _savePage(database, [0x4c, 0, 0, ..._epoch(1200)]);

    final methodsCalled = <String>[];
    final inserted = <String, int>{};
    var granted = <String>[];
    final allTypes = HealthMetric.values.map((m) => m.name).toList();
    const channel = MethodChannel('ringconn/health_connect');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      methodsCalled.add(call.method);
      if (call.method == 'checkPermissions') {
        return {'available': allTypes, 'granted': granted};
      }
      if (call.method == 'insert') {
        final args = call.arguments as Map<Object?, Object?>;
        final metric = args['metric'] as String;
        inserted[metric] =
            (inserted[metric] ?? 0) + (args['records'] as List).length;
        return null;
      }
      fail('Unexpected method call during silent auto-export: ${call.method}');
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final exporter = HealthExporter(database);
    // 1. Before permissions are granted: silent check reports denied, no authorize prompt.
    final ungranted = await exporter.export(interactive: false);
    expect(methodsCalled, ['checkPermissions']);
    expect(ungranted.granted, isEmpty);
    expect(ungranted.denied, HealthMetric.values);
    expect(ungranted.counts, isEmpty);

    // 2. Once permissions are granted: silent auto-export writes all pending metrics.
    granted = allTypes;
    final exported = await exporter.export(interactive: false);
    expect(methodsCalled, isNot(contains('authorize')));
    expect(exported.counts, {
      HealthMetric.heartRate: 1,
      HealthMetric.hrv: 1,
      HealthMetric.oxygen: 1,
      HealthMetric.respiratoryRate: 1,
    });
    expect(inserted['hrv'], 1);
  });
}
