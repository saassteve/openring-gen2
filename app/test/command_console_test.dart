import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ring_protocol/ring_protocol.dart';
import 'package:ringconn_companion/ble/command_console.dart';
import 'package:ringconn_companion/ble/ring_controller.dart';
import 'package:ringconn_companion/data/ring_database.dart';

List<int> _frame(List<int> payload) => [
  ...payload,
  payload.reduce((a, b) => a ^ b),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('validates raw command hex and limits scan input to 120 bytes', () {
    expect(parseCommandHex('03 00\n00'), [3, 0, 0]);
    expect(() => parseCommandHex('f'), throwsFormatException);
    expect(() => parseCommandHex('zz'), throwsFormatException);
    expect(parseScanOpcodes('03, 0x86 fF'), [3, 0x86, 0xff]);
    expect(parseScanOpcodes(List.filled(120, '03').join(' ')), hasLength(120));
    expect(
      () => parseScanOpcodes(List.filled(121, '03').join(' ')),
      throwsFormatException,
    );
    expect(() => parseScanOpcodes('100'), throwsFormatException);
  });

  test('summarizes coalesced, fragmented, opaque and unknown frames', () {
    final summaries = <String>[];
    void observe(List<int> bytes, RingFrame? frame) =>
        summaries.add(commandFrameSummary(bytes, frame));
    final parser = FrameReassembler();
    final descriptor = List<int>.filled(19, 0)..[1] = 86;
    final epoch = _frame([0x4c, 0, 2, ...List.filled(23, 0)]);
    final thermal = _frame([0x47, 0, 1, ...List.filled(47, 0)]);
    parser.add([
      ..._frame([0x86, 0]),
      ..._frame([0x87, ...descriptor.skip(1)]),
      ..._frame([0x15, 0, 60, 0, 0]),
      ..._frame([0x10, ...descriptor.skip(1)]),
      ..._frame([0x82, 0, 0]),
      0x50,
      ...List.filled(26, 0),
      ..._frame([0x83, 0]),
      ...epoch.take(11),
    ], observe: observe);
    parser.add(epoch.skip(11).toList(), observe: observe);
    parser.flush(observe: observe);
    parser.add(thermal, observe: observe);
    parser.flush(observe: observe);
    expect(summaries, [
      contains('0x86 • Mode ACK'),
      contains('0x87 • Descriptor • battery 86%'),
      contains('0x15 • Heart rate • 60 bpm'),
      contains('0x10 • Descriptor • battery 86%'),
      contains('0x82 • Sync ACK'),
      contains('0x50 • Opaque status notice • 27 bytes'),
      contains('0x83 • Unknown opcode • 3 bytes'),
      contains('0x4c • epochs history • 1 record'),
      contains('0x47 • thermal history • 1 record'),
    ]);
  });

  test('retains opaque replies that share a known frame opcode', () {
    final parser = FrameReassembler();
    final summaries = <String>[];
    void observe(List<int> bytes, RingFrame? frame) =>
        summaries.add(commandFrameSummary(bytes, frame));

    parser.add([0x87, 0, 0x87], observe: observe);
    expect(summaries, isEmpty);
    parser.flush(observe: observe);
    parser.add(_frame([0x86, 0]), observe: observe);

    expect(summaries, [
      '0x87 • Unknown opcode • 3 bytes',
      '0x86 • Mode ACK • 3 bytes',
    ]);
  });

  testWidgets(
    'each scan window awaits one second and uses XOR acknowledgement',
    (tester) async {
      final scan = CommandScan()..expect(0x03);
      final ack = scan.waitForAck();
      scan.observe(0x03);
      scan.observe(0x83);
      await tester.pump(const Duration(milliseconds: 999));
      scan.observe(0x82);
      await tester.pump(const Duration(milliseconds: 1));
      expect(await ack, isTrue);

      scan.expect(0x07);
      final noAck = scan.waitForAck();
      scan.observe(0x83);
      await tester.pump(const Duration(seconds: 1));
      expect(await noAck, isFalse);

      scan.expect(0x06);
      final stopped = scan.waitForAck();
      scan.stop();
      expect(await stopped, isNull);
    },
  );

  test(
    'console writes use the existing authenticated BLE connection',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const methods = MethodChannel('ringconn/ble');
      const events = MethodChannel('ringconn/ble/events');
      const paths = MethodChannel('plugins.flutter.io/path_provider');
      final directory = await Directory.systemTemp.createTemp(
        'ringconn-ble-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(methods, (call) async {
        calls.add(call);
        return null;
      });
      messenger.setMockMethodCallHandler(events, (_) async => null);
      messenger.setMockMethodCallHandler(paths, (_) async => directory.path);
      addTearDown(() {
        for (final channel in [methods, events, paths]) {
          messenger.setMockMethodCallHandler(channel, null);
        }
      });
      final ring = RingController(RingDatabase(NativeDatabase.memory()));
      addTearDown(ring.dispose);
      ring.openCommandConsole();
      await ring.sendCommand(parseCommandHex('030000'));
      expect(calls, isEmpty);

      await ring.connect((
        id: 'simulated',
        name: 'RingConn Gen2-03AD',
        rssi: -50,
      ));
      Future<void> emit(Map<String, Object> event) async {
        await messenger.handlePlatformMessage(
          events.name,
          const StandardMethodCodec().encodeSuccessEnvelope(event),
          null,
        );
        await ring.stopScan();
      }

      final identity = parseCommandHex('f87999f703ad');
      await emit({
        'type': 'ready',
        'id': 'simulated',
        'systemId': identity,
        'writeLimit': 244,
      });
      expect(ring.state, LinkState.authenticating);
      await emit({
        'type': 'notification',
        'bytes': Uint8List.fromList(_frame([0x81, 0, 0xb0])),
      });
      await emit({
        'type': 'notification',
        'bytes': Uint8List.fromList(_frame([0x81, 1, ...List.filled(35, 0)])),
      });
      expect(ring.connected, isTrue);

      await ring.sendCommand(parseCommandHex('030000'));
      final writes = calls
          .where((call) => call.method == 'write')
          .map((call) => (call.arguments as Map)['bytes']);
      expect(writes, [
        RingCommands.status(),
        RingCommands.authenticate(identity, 0xb0),
        RingCommands.telemetry(),
        [3, 0, 0],
      ]);
      expect(ring.connected, isTrue);
      ring.closeCommandConsole();
      await ring.commandLog.shareFile();
    },
  );

  test('persists the UTC console log and reloads it across sessions', () async {
    final dir = await Directory.systemTemp.createTemp('ringconn-console-test-');
    addTearDown(() => dir.delete(recursive: true));
    final first = CommandLog(documentsDirectory: () async => dir);
    final time = DateTime.utc(2026, 11, 24);
    await first.load();
    expect(await first.shareFile(), isNull);
    first.add(time, 'TX 030000');
    first.add(time, 'RX 0x83 • Unknown opcode • 3 bytes • 830083');
    final file = (await first.shareFile())!;
    expect(file.path, endsWith('/ringconn-command-console.txt'));
    final lines = await file.readAsLines();
    expect(lines.first, '2026-11-24T00:00:00.000Z TX 030000');
    final second = CommandLog(documentsDirectory: () async => dir);
    await second.load();
    expect(second.recent, lines);
  });

  test('summarizes SetParamReply frames in the command console', () {
    final parser = FrameReassembler();
    final summaries = <String>[];
    parser.add(
      [..._frame([0x85, 0x23, 0x00]), ..._frame([0x85, 0x24, 0x01])],
      observe: (bytes, frame) =>
          summaries.add(commandFrameSummary(bytes, frame)),
    );
    expect(summaries, [
      contains('0x85 • Auto-sports monitor • ACK'),
      contains('0x85 • Sleep Pro compressed PPG • rejected (1)'),
    ]);
  });
}
