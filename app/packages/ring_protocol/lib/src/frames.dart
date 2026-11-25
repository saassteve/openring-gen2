import 'dart:typed_data';

import 'bytes.dart';
import 'commands.dart';

export 'bytes.dart' show validXor;

enum WearState {
  measuring,
  offFinger,
  worn,
  unknown;

  static WearState fromCode(int code) => switch (code) {
    1 => measuring,
    2 => offFinger,
    3 => worn,
    _ => unknown,
  };
}

sealed class RingFrame {
  RingFrame._(List<int> raw) : raw = freeze(raw);
  final Uint8List raw;
  int get opcode => raw[0];

  /// Verified fixed lengths, including the XOR trailer.
  static int? fixedLength(int opcode, int? sub) => switch (opcode) {
    0x81 when sub == 0 => 4,
    0x81 when sub == 1 => 38,
    0x82 => 4,
    0x85 when sub != null && sub >= 0x22 => 4,
    0x85 => 3,
    0x86 => 3,
    0xa3 => 3,
    0xa9 => 10,
    0x10 || 0x87 => 20,
    0x11 => 5,
    0x15 when sub == 0 => 6,
    0x12 => 135,
    0x13 => 160,
    _ => null,
  };

  static RingFrame decode(List<int> bytes) {
    if (!validXor(bytes)) throw const FormatException('Invalid frame XOR');
    final opcode = bytes[0];
    final stream = HistoryStream.forOpcode(opcode);
    if (stream != null) {
      final payloadSize = bytes.length - 4;
      if (bytes[1] != 0 ||
          payloadSize <= 0 ||
          payloadSize % stream.recordSize != 0) {
        throw const FormatException('Invalid history page');
      }
      return HistoryPage._(bytes, stream);
    }
    if (bytes.length != fixedLength(opcode, bytes[1])) {
      throw const FormatException(
        'Unsupported response or incorrect frame length',
      );
    }
    return switch (opcode) {
      0x81 when bytes[1] == 0 => AuthChallenge._(bytes),
      0x81 => AuthStatus._(bytes),
      0x82 => HistoryOpened._(bytes),
      0x85 => SetParamReply._(bytes),
      0x86 => ModeReply._(bytes),
      0xa3 => AccStreamReply._(bytes),
      0xa9 => TemperatureReply._(bytes),
      0x10 || 0x87 => TelemetryFrame._(bytes),
      0x11 => StatusNotice._(bytes),
      0x15 => LiveHeartRateFrame._(bytes),
      0x12 => DensePpgFrame._(bytes),
      0x13 => RawPpgFrame._(bytes),
      _ => throw const FormatException('Unsupported response'),
    };
  }
}

final class AuthChallenge extends RingFrame {
  AuthChallenge._(super.raw) : super._();
  int get challenge => raw[2];
}

final class AuthStatus extends RingFrame {
  AuthStatus._(super.raw) : super._();
  bool get accepted => raw[2] == 0;
  int get batteryPercent => raw[3];
  int get wearCode => raw[4];
  WearState get wear => WearState.fromCode(wearCode);
  double get temperature1 => signed16(uint16(raw, 8)) / 10;
  double get temperature2 => signed16(uint16(raw, 10)) / 10;
  int get ecoMode => raw[16];
  int get monitorStatus => raw[17];
  int get monitorPlanStatus => raw[18];
  int get batteryMillivolts => uint16(raw, 19);
  int get mtu => raw[31];
  bool get sportsMonitor => raw[36] != 0;
}

final class SetParamReply extends RingFrame {
  SetParamReply._(super.raw) : super._();
  int? get paramCode => raw.length >= 4 ? raw[1] : null;
  RingParam? get param =>
      paramCode == null ? null : RingParam.forCode(paramCode!);
  int get status => raw.length >= 4 ? raw[2] : raw[1];
  bool get accepted => status == 0;
}

final class HistoryOpened extends RingFrame {
  HistoryOpened._(super.raw) : super._();
  bool get accepted => raw[1] == 0 && raw[2] == 0;
}


final class AccStreamReply extends RingFrame {
  AccStreamReply._(super.raw) : super._();
  bool get accepted => raw[1] == 0;
}

final class TemperatureReply extends RingFrame {
  TemperatureReply._(super.raw) : super._();
  double get temperature1 => signed16(uint16(raw, 1)) / 10;
  double get temperature2 => signed16(uint16(raw, 3)) / 10;
}

final class ModeReply extends RingFrame {
  ModeReply._(super.raw) : super._();
  bool get accepted => raw[1] == 0;
}

enum RingStatusEvent {
  wearOn(0x03, 'Ring put on finger'),
  wearOff(0x04, 'Ring taken off finger'),
  hrHigh(0x05, 'High heart rate alert'),
  hrLow(0x06, 'Low heart rate alert'),
  lowBattery(0x09, 'Low battery'),
  memoryFull(0x0a, 'Ring memory full'),
  weakSignal(0x0b, 'Weak optical signal'),
  unknown(-1, 'Ring status notice');

  const RingStatusEvent(this.code, this.label);
  final int code;
  final String label;

  static RingStatusEvent fromCode(int code) {
    for (final value in values) {
      if (value.code == code) return value;
    }
    return unknown;
  }
}

final class StatusNotice extends RingFrame {
  StatusNotice._(super.raw) : super._();

  int get errorCode => raw[1];
  int get statusCode => raw[2];
  int get eventCode => raw[3];
  RingStatusEvent get event => RingStatusEvent.fromCode(eventCode);
}

sealed class PpgFrame extends RingFrame {
  PpgFrame._(super.raw) : super._();

  int get sequence;
  int get counter;
}

typedef RawPpgSample = ({int green, int red, int infrared});
typedef AccSample = ({int x, int y, int z});
typedef DensePpgSample = ({
  int channel0,
  int channel1,
  int channel2,
  int ambient,
});

final class RawPpgFrame extends PpgFrame {
  RawPpgFrame._(super.raw) : super._();

  @override
  int get sequence => raw[2];
  @override
  int get counter => uint16(raw, 157);

  late final List<RawPpgSample> samples = List.unmodifiable([
    for (var offset = 6; offset < 156; offset += 6)
      (
        green: uint16(raw, offset),
        red: signed16(uint16(raw, offset + 2)),
        infrared: signed16(uint16(raw, offset + 4)),
      ),
  ]);

  /// Decodes the 25 samples as signed 16-bit BE 3-axis accelerometer readings
  /// (25 Hz, 40 ms per sample).
  int get sampleCounter24 => uint24(raw, 156);

  late final List<AccSample> accSamples = List.unmodifiable([
    for (var offset = 6; offset < 156; offset += 6)
      (
        x: signed16(uint16(raw, offset)),
        y: signed16(uint16(raw, offset + 2)),
        z: signed16(uint16(raw, offset + 4)),
      ),
  ]);
}

final class DensePpgFrame extends PpgFrame {
  DensePpgFrame._(super.raw) : super._();

  @override
  int get sequence => uint16(raw, 1);
  @override
  int get counter => uint24(raw, 130);

  late final List<DensePpgSample> samples = List.unmodifiable([
    for (var offset = 6; offset < 126; offset += 12)
      (
        channel0: uint24(raw, offset),
        channel1: uint24(raw, offset + 3),
        channel2: uint24(raw, offset + 6),
        ambient: signed20(uint24(raw, offset + 9)),
      ),
  ]);
}

final class TelemetryFrame extends RingFrame {
  TelemetryFrame._(super.raw) : super._();
  int get batteryPercent => raw[1];
  int get wearCode => raw[2];
  WearState get wear => WearState.fromCode(wearCode);
  double get temperature1 => signed16(uint16(raw, 6)) / 10;
  double get temperature2 => signed16(uint16(raw, 8)) / 10;
  int get batteryMillivolts => uint16(raw, 14);
  int get modeFlags => raw[16];
}

final class LiveHeartRateFrame extends RingFrame {
  LiveHeartRateFrame._(super.raw) : super._();
  int get rawBpm => raw[2];
  int? get bpm => rawBpm >= 30 ? rawBpm : null;
}

final class HistoryPage extends RingFrame {
  HistoryPage._(super.raw, this.stream) : super._();
  final HistoryStream stream;
  int get remaining => raw[2];

  late final List<HistoryRecord> records = List.unmodifiable([
    for (var index = 3; index < raw.length - 1; index += stream.recordSize)
      switch (stream) {
        HistoryStream.epochs => EpochRecord._(
          raw.sublist(index, index + stream.recordSize),
        ),
        HistoryStream.thermal => ThermalBlock._(
          raw.sublist(index, index + stream.recordSize),
        ),
      },
  ]);
}

sealed class HistoryRecord {
  HistoryRecord._(List<int> raw) : raw = freeze(raw);
  final Uint8List raw;
  int get cursor => uint32(raw, 0);
  DateTime get endedAt => timeFromCursor(cursor);
}

enum OxygenState { measured, failed, notScheduled }

final class EpochRecord extends HistoryRecord {
  EpochRecord._(super.raw) : super._();
  int? get bpm => raw[4] >= 30 ? raw[4] : null;
  int? get hrvMs => raw[5] == 0 ? null : raw[5];
  int get ppgQuality => raw[6];
  double? get respiratoryRate => raw[7] == 0 ? null : raw[7] / 10;
  int? get oxygenPercent => oxygenState == OxygenState.measured ? raw[8] : null;
  OxygenState get oxygenState => switch (raw[8]) {
    17 => OxygenState.failed,
    18 => OxygenState.notScheduled,
    _ => OxygenState.measured,
  };
  double get activityMet => raw[9] / 10;
  List<int> get ambient => raw.sublist(10, 15);
  List<int> get motion =>
      List.generate(5, (i) => packedBits(raw, 120 + i * 12, 12));
  int get flags => raw[22] & 0x0f;
}

final class ThermalBlock extends HistoryRecord {
  ThermalBlock._(super.raw) : super._();

  /// Decodes a raw thermal record previously extracted from a history page.
  factory ThermalBlock.decode(List<int> bytes) {
    if (bytes.length != HistoryStream.thermal.recordSize) {
      throw const FormatException('Invalid thermal record length');
    }
    return ThermalBlock._(bytes);
  }

  int get subtype => raw[4];
  int get batteryPercent => raw[5] >> 1;
  bool get activity => (raw[5] & 1) != 0;
  int get steps => uint16(raw, 6);
  int get activeTimeRaw => raw[8];
  // Capture-derived: sample bits start at byte 9 and end in a pad nibble.
  List<double> get outerTemperatures => _temperatures(72);
  List<double> get innerTemperatures => _temperatures(82);
  List<double> _temperatures(int offset) =>
      List.generate(15, (i) => packedBits(raw, offset + i * 20, 10) / 20);
}
