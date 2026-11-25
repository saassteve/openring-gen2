import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ring_protocol/ring_protocol.dart';
import 'package:ringconn_companion/data/ring_database.dart';

void main() {
  test('upgrades a version 1 database with existing ring data', () async {
    final directory = await Directory.systemTemp.createTemp('ringconn-v1-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/ring.sqlite');
    final database = RingDatabase(NativeDatabase(file));
    await database.rememberDevice(
      DevicesCompanion.insert(
        id: 'existing-ring',
        platformId: 'phone-id',
        name: 'RingConn Gen2',
        systemId: Uint8List(6),
        lastSeenAt: DateTime.utc(2026, 11, 24),
      ),
    );
    // Simulate a version 1 database before export & preference tables existed.
    await database.customStatement('DROP TABLE app_preferences');
    await database.customStatement('DROP TABLE health_export_writes');
    await database.customStatement('DROP TABLE health_export_checkpoints');
    await database.customStatement('PRAGMA user_version = 1');
    await database.close();

    final reopened = RingDatabase(NativeDatabase(file));
    addTearDown(reopened.close);
    expect((await reopened.latestDevice())!.id, 'existing-ring');
    expect(await reopened.latestHealthExport(), isNull);
    expect(
      await reopened.select(reopened.healthExportCheckpoints).get(),
      isEmpty,
    );
    expect(await reopened.getAutoHealthExport(), isTrue);
    await reopened.setAutoHealthExport(false);
    expect(await reopened.getAutoHealthExport(), isFalse);
    await reopened.setAutoHealthExport(true);
    expect(await reopened.getAutoHealthExport(), isTrue);
  });

  test(
    'saves raw history before ACK and deduplicates replayed records',
    () async {
      final database = RingDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final time = DateTime.utc(2026, 11, 24);
      const deviceId = 'recorded-ring';
      await database.rememberDevice(
        DevicesCompanion.insert(
          id: deviceId,
          platformId: 'phone-id',
          name: 'RingConn Gen2',
          systemId: Uint8List(6),
          lastSeenAt: time,
        ),
      );
      final bytes = [
        0x4c,
        0,
        0,
        0x0c,
        0xf9,
        0xac,
        0x81,
        59,
        54,
        8,
        125,
        18,
        12,
        16,
        15,
        45,
        42,
        40,
        0x19,
        0x24,
        0x95,
        0xbb,
        0x02,
        0xc2,
        0x8c,
        0,
      ];
      bytes.add(bytes.reduce((a, b) => a ^ b));
      final page = RingFrame.decode(bytes) as HistoryPage;
      final drain = HistoryDrain(cursor: cursorFromTime(time))..start();
      final session = await database.openDrain(deviceId, drain, time);
      drain.pageReceived(page);
      final pageId = await database.savePage(session, deviceId, page, time);
      expect(
        (await database.select(database.rawHistoryPages).getSingle()).raw,
        bytes,
      );
      expect(
        (await database.select(database.rawHistoryPages).getSingle())
            .acknowledged,
        isFalse,
      );
      expect(await database.select(database.syncCursors).get(), isEmpty);
      drain.pagePersisted();
      drain.acknowledged();
      await database.confirmPage(
        pageId: pageId,
        sessionId: session,
        deviceId: deviceId,
        page: page,
        drain: drain,
        time: time,
      );
      await database.savePage(session, deviceId, page, time);

      final epoch = await database.select(database.epochs).getSingle();
      expect(epoch.bpm, 59);
      expect(epoch.raw, page.records.single.raw);
      final pages = await database.select(database.rawHistoryPages).get();
      expect(pages.map((row) => row.acknowledged), [true, false]);
      final cursor = await database.select(database.syncCursors).getSingle();
      expect(cursor.lastAcknowledgedCursor, page.records.single.cursor);
    },
  );
}
