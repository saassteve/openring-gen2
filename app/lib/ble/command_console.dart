import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:ring_protocol/ring_protocol.dart';

const maxScanCommands = 120;

String commandHex(Iterable<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

Uint8List parseCommandHex(String input) {
  final hex = input.replaceAll(RegExp(r'\s+'), '');
  if (hex.isEmpty ||
      hex.length.isOdd ||
      !RegExp(r'^[\da-fA-F]+$').hasMatch(hex)) {
    throw const FormatException(
      'Enter complete hex bytes, for example 030000.',
    );
  }
  return Uint8List.fromList([
    for (var index = 0; index < hex.length; index += 2)
      int.parse(hex.substring(index, index + 2), radix: 16),
  ]);
}

List<int> parseScanOpcodes(String input) {
  final trimmed = input.trim();
  final tokens = trimmed.isEmpty
      ? <String>[]
      : trimmed.split(RegExp(r'[\s,]+'));
  if (tokens.isEmpty || tokens.length > maxScanCommands) {
    throw const FormatException('Enter 1 to 120 hex opcodes.');
  }
  final pattern = RegExp(r'^(?:0x)?[\da-f]{1,2}$', caseSensitive: false);
  if (tokens.any((token) => !pattern.hasMatch(token))) {
    throw const FormatException('Separate hex opcodes with spaces or commas.');
  }
  return [
    for (final token in tokens)
      int.parse(token.toLowerCase().replaceFirst('0x', ''), radix: 16),
  ];
}

String commandFrameSummary(List<int> bytes, RingFrame? frame) {
  final opcode = '0x${commandHex([bytes.first])}';
  final length = '${bytes.length} bytes';
  final summary = switch (frame) {
    ModeReply() => frame.accepted ? 'Mode ACK' : 'Mode rejected',
    AccStreamReply() => frame.accepted ? 'Accelerometer stream ACK' : 'Accelerometer stream rejected',
    TemperatureReply() =>
      'Temperature • ${frame.temperature1} / ${frame.temperature2} °C',
    TelemetryFrame() =>
      'Descriptor • battery ${frame.batteryPercent}% • wear ${frame.wear.name}'
          ' • ${frame.temperature1} / ${frame.temperature2} °C',
    LiveHeartRateFrame() =>
      'Heart rate • ${frame.bpm ?? frame.rawBpm} bpm'
          '${frame.bpm == null ? ' (warm-up)' : ''}',
    HistoryOpened() => frame.accepted ? 'Sync ACK' : 'Sync rejected',
    HistoryPage() =>
      '${frame.stream.name} history • ${frame.records.length} '
          '${frame.records.length == 1 ? 'record' : 'records'} • ${frame.remaining} remaining',
    AuthChallenge() => 'Authentication challenge',
    AuthStatus() => frame.accepted
        ? 'Authentication ACK • eco ${frame.ecoMode} • auto-sports ${frame.sportsMonitor ? "on" : "off"} • MTU ${frame.mtu}'
        : 'Authentication rejected',
    SetParamReply() =>
      '${frame.param?.label ?? (frame.paramCode != null ? "Parameter 0x${commandHex([frame.paramCode!])}" : "Parameter")}'
          ' • ${frame.accepted ? "ACK" : "rejected (${frame.status})"}',
    StatusNotice() => 'Status notice',
    PpgFrame() => 'PPG • sequence ${frame.sequence}',
    null when bytes.first == 0x50 && bytes.length == 27 =>
      'Opaque status notice',
    null => 'Unknown opcode',
  };
  return '$opcode • $summary • $length';
}

final class CommandLog {
  CommandLog({Future<Directory> Function()? documentsDirectory, this.onChanged})
    : _documentsDirectory =
          documentsDirectory ?? getApplicationDocumentsDirectory;

  static const _maxVisibleLines = 200;
  static const _maxReadBytes = 128 * 1024;
  final Future<Directory> Function() _documentsDirectory;
  final void Function()? onChanged;
  final ListQueue<String> _recent = ListQueue();
  Future<void> _pending = Future.value();
  File? _file;
  bool _loaded = false;
  String? error;

  List<String> get recent => _recent.toList(growable: false);

  Future<File> _logFile() async => _file ??= File(
    '${(await _documentsDirectory()).path}/ringconn-command-console.txt',
  );

  Future<void> load() => _queue(() async {
    if (_loaded) return;
    final file = await _logFile();
    if (await file.exists()) {
      final handle = await file.open();
      try {
        final length = await handle.length();
        final start = length > _maxReadBytes ? length - _maxReadBytes : 0;
        await handle.setPosition(start);
        final tail = utf8.decode(
          await handle.read(length - start),
          allowMalformed: true,
        );
        for (final line
            in const LineSplitter().convert(tail).skip(start == 0 ? 0 : 1)) {
          _remember(line);
        }
      } finally {
        await handle.close();
      }
    }
    _loaded = true;
  });

  void add(DateTime time, String text) {
    final line = '${time.toUtc().toIso8601String()} $text';
    // Queue behind the initial reload so lines on disk stay in the same order
    // as the live log even when the first command arrives immediately.
    unawaited(
      _queue(() async {
        _remember(line);
        await (await _logFile()).writeAsString(
          '$line\n',
          mode: FileMode.append,
          flush: true,
        );
      }),
    );
  }

  Future<File?> shareFile() async {
    await _pending;
    final file = await _logFile();
    return await file.exists() ? file : null;
  }

  void _remember(String line) {
    _recent.addLast(line);
    if (_recent.length > _maxVisibleLines) _recent.removeFirst();
  }

  Future<void> _queue(Future<void> Function() operation) =>
      _pending = _pending.then((_) async {
        try {
          await operation();
        } catch (failure) {
          error = 'Could not persist the command log. $failure';
        } finally {
          onChanged?.call();
        }
      });
}

final class CommandScan {
  int? _expected;
  bool _ack = false;
  bool _stopped = false;
  bool get stopped => _stopped;
  Completer<void>? _window;

  void expect(int command) {
    _expected = command ^ 0x80;
    _ack = false;
  }

  void observe(int opcode) {
    if (opcode == _expected) _ack = true;
  }

  Future<bool?> waitForAck() async {
    if (stopped) return null;
    final window = _window = Completer<void>();
    final timer = Timer(const Duration(seconds: 1), window.complete);
    try {
      await window.future;
    } finally {
      timer.cancel();
      _window = null;
      _expected = null;
    }
    return stopped ? null : _ack;
  }

  void stop() {
    _stopped = true;
    final window = _window;
    if (window != null && !window.isCompleted) window.complete();
  }
}
