import 'dart:typed_data';

import 'auth.dart';

const ringEpochSeconds = 1577793600;

int cursorFromTime(DateTime time) =>
    time.millisecondsSinceEpoch ~/ 1000 - ringEpochSeconds;

DateTime timeFromCursor(int cursor) => DateTime.fromMillisecondsSinceEpoch(
  (ringEpochSeconds + cursor) * 1000,
  isUtc: true,
);

enum RingMode {
  idle(0x00),
  heartRate(0x01),
  oxygen(0x02),
  densePpg(0x05);

  const RingMode(this.code);
  final int code;
}

enum RingParam {
  osaPlan(0x22, 'Sleep apnoea (OSA) plan'),
  autoSports(0x23, 'Auto-sports monitor'),
  sleepProPpg(0x24, 'Sleep Pro compressed PPG'),
  autoBloodPressure(0x25, 'Auto blood pressure');

  const RingParam(this.code, this.label);
  final int code;
  final String label;

  static RingParam? forCode(int code) => switch (code) {
    0x22 => osaPlan,
    0x23 => autoSports,
    0x24 => sleepProPpg,
    0x25 => autoBloodPressure,
    _ => null,
  };
}

enum HistoryStream {
  epochs(0x4c, 23),
  thermal(0x47, 47);

  const HistoryStream(this.opcode, this.recordSize);
  final int opcode;
  final int recordSize;

  static HistoryStream? forOpcode(int opcode) => switch (opcode) {
    0x4c => epochs,
    0x47 => thermal,
    _ => null,
  };
}

abstract final class RingCommands {
  static Uint8List _command(
    int opcode, [
    int sub = 0,
    List<int> payload = const [],
  ]) => Uint8List.fromList([opcode, sub, ...payload, 0]);

  static Uint8List status() => _command(0x01);
  static Uint8List authenticate(List<int> identity, int challenge) =>
      _command(0x01, 0x01, authResponse(identity, challenge));
  static Uint8List sessionInit() => _command(0xd0);
  static Uint8List telemetry() => _command(0x07);
  static Uint8List mode(RingMode mode) => _command(0x06, mode.code);
  static Uint8List pollHeartRate() => _command(0x95);
  static Uint8List acknowledgeStatus() => _command(0x91);
  static Uint8List acknowledgePage(HistoryStream stream) =>
      _command(stream.opcode ^ 0x80);
  static Uint8List setParam(RingParam param, int value) {
    RangeError.checkValueInInterval(value, 0, 255, 'value');
    return _command(0x05, param.code, [value]);
  }
  static Uint8List readTemperature() => _command(0x29);

  static Uint8List openHistory(int cursor, {int channel = 0}) {
    RangeError.checkValueInInterval(cursor, 0, 0xffffffff, 'cursor');
    RangeError.checkValueInInterval(channel, 0, 255, 'channel');
    return _command(0x02, 0, [
      (cursor >> 24) & 0xff,
      (cursor >> 16) & 0xff,
      (cursor >> 8) & 0xff,
      cursor & 0xff,
      channel,
      1,
    ]);
  }
}
