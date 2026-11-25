import 'dart:convert';
import 'dart:io';

import 'package:ring_protocol/ring_protocol.dart';
import 'package:test/test.dart';

List<int> hex(String value) => [
  for (var offset = 0; offset < value.length; offset += 2)
    int.parse(value.substring(offset, offset + 2), radix: 16),
];

Iterable<List<int>> notifications(String name) sync* {
  final lines = File('test/fixtures/$name.jsonl').readAsLinesSync();
  for (final line in lines) {
    final row = jsonDecode(line) as Map<String, dynamic>;
    final bytes = hex(row['hex'] as String);
    expect(bytes.length, row['len']);
    if (row['dir'] == 'rx') yield bytes;
  }
}

Iterable<RingFrame> replay(String name) sync* {
  final parser = FrameReassembler();
  // The probe logged both notifications and recognized frames. Each line is
  // replayed as captured, including duplicate and coalesced packets.
  for (final bytes in notifications(name)) {
    yield* parser.add(bytes);
    yield* parser.flush();
  }
}

void main() {
  test('SM3 matches the standard example and the verified auth pair', () {
    expect(
      sm3(utf8.encode('abc')),
      hex('66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0'),
    );
    expect(
      sm3(utf8.encode('abcd' * 16)),
      hex('debe9ff92275b8a138604889c18e5a4d6fdb70e5387e5765293dcba39c0c5732'),
    );
    final identity = hex('f87999f703ad');
    expect(
      identityFromSystemId(hex('f87999fffef703ad'), 'RingConn Gen2-03AD'),
      identity,
    );
    expect(
      identityFromSystemId(identity.reversed.toList(), 'RingConn Gen2-03AD'),
      identity,
    );
    expect(identityFromSystemId(identity, 'RingConn Gen2-FFFF'), isNull);
    expect(RingCommands.authenticate(identity, 0xb0), hex('010131826700'));
  });

  test(
    'FR02.023 live capture decodes auth, telemetry, mode and warm-up HR',
    () {
      final frames = replay('rc_hr2').toList();
      expect(frames.whereType<AuthChallenge>().single.challenge, 0xbc);
      expect(frames.whereType<AuthStatus>().single.accepted, isTrue);
      expect(frames.whereType<ModeReply>().single.accepted, isTrue);
      final descriptor = frames.whereType<TelemetryFrame>().first;
      expect(descriptor.raw.length, 20);
      expect(descriptor.batteryPercent, 86);
      expect(descriptor.batteryMillivolts, 4204);
      expect(descriptor.temperature1, 25.8);
      expect(descriptor.temperature2, 26.9);
      expect(descriptor.wear, WearState.worn);
      final hr = frames.whereType<LiveHeartRateFrame>().toList();
      expect(hr.first.rawBpm, 8);
      expect(hr.first.bpm, isNull);
      expect(hr.map((frame) => frame.bpm).nonNulls, [58, 61, 62]);
    },
  );

  test(
    'coalesced capture and fragmented history both produce typed frames',
    () {
      final chunk = notifications(
        'rc_hist_drain',
      ).singleWhere((bytes) => bytes.length == 303);
      final parser = FrameReassembler();
      expect(parser.add(chunk.sublist(0, 12)).single, isA<HistoryOpened>());
      expect(parser.add(chunk.sublist(12, 140)).single, isA<TelemetryFrame>());
      expect(parser.flush(), isEmpty);
      expect(parser.add(chunk.sublist(140)), isEmpty);
      final recovered = parser.flush();
      final page = recovered.first as HistoryPage;
      expect(page.stream, HistoryStream.thermal);
      expect(page.remaining, 30);
      expect(page.records.length, 5);
      expect(page.records.first.cursor, 217689293);
      expect(recovered.skip(1), everyElement(isA<TelemetryFrame>()));
      expect(recovered.length, 3);
      expect(parser.hasPendingBytes, isFalse);
    },
  );

  test('an aligned XOR match does not absorb trailing fixed responses', () {
    final page = replay('rc_hist_drain4').whereType<HistoryPage>().firstWhere(
      (frame) => frame.stream == HistoryStream.epochs,
    );
    final live = replay('rc_hr2').toList();
    final descriptor = live.whereType<TelemetryFrame>().first;
    final modeReply = live.whereType<ModeReply>().single;
    final chunk = [...page.raw, ...descriptor.raw, ...modeReply.raw];
    expect(chunk.length - page.raw.length, HistoryStream.epochs.recordSize);
    expect(validXor(chunk), isTrue);
    final parser = FrameReassembler()..add(chunk);
    final frames = parser.flush();
    expect(frames.map((frame) => frame.raw), [
      page.raw,
      descriptor.raw,
      modeReply.raw,
    ]);
  });

  test('FR02.023 history matches CSV values and a two-stream drain', () {
    final pages = replay('rc_hist_drain4').whereType<HistoryPage>().toList();
    final drain = HistoryDrain(cursor: 217735813);
    expect(drain.start(), hex('02000cfa6285000100'));
    final epochs = <int, EpochRecord>{};
    final thermal = <int, ThermalBlock>{};

    for (final page in pages) {
      final duplicateAfterCompletion = drain.finished;
      for (final record in page.records) {
        switch (record) {
          case EpochRecord():
            epochs[record.cursor] = record;
          case ThermalBlock():
            thermal[record.cursor] = record;
        }
      }
      if (duplicateAfterCompletion) continue;
      drain.pageReceived(page);
      expect(drain.phase, DrainPhase.persisting);
      expect(
        drain.pagePersisted(),
        hex(page.stream == HistoryStream.epochs ? 'cc0000' : 'c70000'),
      );
      drain.acknowledged();
      if (page.stream == HistoryStream.thermal && page.remaining == 0) {
        expect(drain.phase, DrainPhase.waiting);
      }
    }

    expect(drain.phase, DrainPhase.complete);
    expect(drain.recordsAcknowledged, 223);
    expect(epochs.length, 212);
    expect(thermal.length, 11);
    final epoch = epochs[217689217]!;
    expect(epoch.endedAt.toIso8601String(), '2026-11-24T01:13:37.000Z');
    expect(epoch.bpm, 59);
    expect(epoch.hrvMs, 54);
    expect(epoch.respiratoryRate, 12.5);
    expect(epoch.oxygenState, OxygenState.notScheduled);
    expect(epoch.motion, [25, 585, 1467, 44, 652]);
    expect(epochs[217689517]!.oxygenPercent, 98);
    final still = epochs.values.firstWhere(
      (record) =>
          record.flags == 4 &&
          record.raw.sublist(15, 22).every((byte) => byte == 0) &&
          record.raw[22] == 4,
    );
    expect(still.motion, [0, 0, 0, 0, 0]);
    final block = thermal[217711793]!;
    expect(block.batteryPercent, 87);
    expect(block.outerTemperatures.take(3), [32.4, 32.55, 32.6]);
    expect(block.innerTemperatures.take(3), [32.7, 32.75, 32.85]);
    expect(thermal[217735194]!.steps, 40);
  });

  test('verified PPG captures decode sample channels and counters', () {
    final frames = replay('rc_modes_ppg').toList();
    final raw = frames.whereType<RawPpgFrame>().single;
    expect(raw.sequence, 21);
    expect(raw.counter, 525);
    expect(raw.samples, hasLength(25));
    expect(raw.samples.first, (green: 739, red: -567, infrared: -451));
    final dense = frames.whereType<DensePpgFrame>().single;
    expect(dense.sequence, 57);
    expect(dense.counter, 130);
    expect(dense.samples, hasLength(10));
    expect(dense.samples.first, (
      channel0: 390273,
      channel1: 433181,
      channel2: 12584,
      ambient: -5,
    ));
  });

  test('bad XOR is rejected and the following valid frame still decodes', () {
    final good = replay('rc_hr2').whereType<TelemetryFrame>().first.raw;
    final corrupt = [...good]..[19] ^= 1;
    expect(validXor(corrupt), isFalse);
    expect(() => RingFrame.decode(corrupt), throwsFormatException);
    final parser = FrameReassembler();
    expect(parser.add(corrupt), isEmpty);
    expect(parser.add(good).single.raw, good);
  });

  test('stalls use a bounded reopen and report unconfirmed completion', () {
    final drain = HistoryDrain(cursor: 100, maxRetries: 1);
    final open = drain.start();
    final thermal = replay('rc_hist_drain4')
        .whereType<HistoryPage>()
        .firstWhere(
          (page) => page.stream == HistoryStream.thermal && page.remaining == 0,
        );
    drain.pageReceived(thermal);
    expect(() => drain.acknowledged(), throwsStateError);
    drain.pagePersisted();
    drain.acknowledged();
    expect(drain.stalled(), open);
    expect(drain.stalled(), isNull);
    expect(drain.phase, DrainPhase.partial);
  });

  test('auth status table decodes telemetry and feature flags from live capture', () {
    final status = replay('rc_hist_drain4').whereType<AuthStatus>().first;
    expect(status.accepted, isTrue);
    expect(status.batteryPercent, 86);
    expect(status.wear, WearState.offFinger);
    expect(status.temperature1, 32.1);
    expect(status.temperature2, 32.8);
    expect(status.ecoMode, 1);
    expect(status.monitorStatus, 0);
    expect(status.monitorPlanStatus, 0);
    expect(status.batteryMillivolts, 4196);
    expect(status.mtu, 244);
    expect(status.sportsMonitor, isTrue);
  });

  test('setParam and temperature commands encode and decode replies', () {
    expect(RingCommands.setParam(RingParam.autoSports, 0), hex('05230000'));
    expect(RingCommands.setParam(RingParam.osaPlan, 1), hex('05220100'));
    expect(RingCommands.readTemperature(), hex('290000'));

    final temp =
        RingFrame.decode(hex('a90148014e00000000af')) as TemperatureReply;
    expect(temp.temperature1, 32.8);
    expect(temp.temperature2, 33.4);

    final parser = FrameReassembler();
    final ok = parser.add(hex('852300a6')).single as SetParamReply;
    expect(ok.param, RingParam.autoSports);
    expect(ok.accepted, isTrue);

    final rejected = parser.add(hex('852401a0')).single as SetParamReply;
    expect(rejected.param, RingParam.sleepProPpg);
    expect(rejected.accepted, isFalse);

    final zero = parser.add(hex('850085')).single as SetParamReply;
    expect(zero.param, isNull);
    expect(zero.accepted, isTrue);
  });

  test('0x13 frames also expose signed 3-axis accelerometer samples', () {
    final raw = replay('rc_modes_ppg').whereType<RawPpgFrame>().single;
    expect(raw.accSamples, hasLength(25));
    expect(raw.accSamples.first, (x: 739, y: -567, z: -451));
    expect(raw.sampleCounter24, 525);
  });
}
