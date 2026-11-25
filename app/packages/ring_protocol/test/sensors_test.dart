import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:ring_protocol/ring_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('startAccelerometer command and AccStreamReply frame encode/decode', () {
    expect(RingCommands.startAccelerometer(), [0x23, 0x03, 0x00]);
    final frame = RingFrame.decode([0xa3, 0x00, 0xa3]);
    expect(frame, isA<AccStreamReply>());
    expect((frame as AccStreamReply).accepted, isTrue);
  });

  test('PpgBiofeedbackAnalyzer extracts ~60 bpm, RMSSD, and PI% on synthetic 25 Hz wave', () {
    final analyzer = PpgBiofeedbackAnalyzer();
    // 10 seconds at 25 Hz = 250 samples, 1 Hz cardiac wave (60 bpm) on 400k DC
    for (var i = 0; i < 250; i++) {
      final t = i / 25.0;
      final pulse = 6000.0 * math.sin(2 * math.pi * 1.0 * t);
      analyzer.addSample(400000.0 + pulse);
    }
    expect(analyzer.beatCount, greaterThanOrEqualTo(6));
    expect(analyzer.liveBpm, closeTo(60.0, 4.0));
    expect(analyzer.perfusionIndexPercent, closeTo(3.0, 0.4));
    expect(analyzer.liveRmssdMs, isNotNull);
    expect(analyzer.waveform, isNotEmpty);
  });

  test('GestureDetector3D separates wind-up taps, hard double-taps, and 3D rotation flicks', () {
    final detector = GestureDetector3D();
    final events = <GestureEvent>[];
    void feed(AccSample sample) {
      final ev = detector.addSample(sample);
      if (ev != null) events.add(ev);
    }

    // 1 second of resting 1g
    for (var i = 0; i < 25; i++) {
      feed((x: 0, y: 0, z: -1024));
    }
    expect(events, isEmpty);

    // Real single tap WITH wind-up finger lift (0.55g) + hard 2.4g impact ->
    // MUST register as a single tap (NEVER double-tap and NEVER wrist flick!).
    feed((x: 0, y: 0, z: -560));
    feed((x: 120, y: 0, z: -2400));
    for (var i = 0; i < 24; i++) {
      feed((x: 0, y: 0, z: -1024));
    }
    expect(events.map((e) => e.gesture), [RingGesture.tap]);
    expect(detector.tapCount, 1);
    expect(detector.doubleTapCount, 0);
    expect(detector.flickCount, 0);

    // Hard double tap (320 ms = 8 samples apart, with wind-up lift before tap 2)
    // -> MUST register ONLY doubleTap (never flick, never extra tap).
    feed((x: 50, y: 0, z: -1650));
    for (var i = 0; i < 6; i++) {
      feed((x: 0, y: 0, z: -1024));
    }
    feed((x: 0, y: 0, z: -600)); // wind-up lift
    feed((x: 60, y: 0, z: -1750));
    for (var i = 0; i < 20; i++) {
      feed((x: 0, y: 0, z: -1024));
    }
    expect(events.map((e) => e.gesture), [
      RingGesture.tap,
      RingGesture.doubleTap,
    ]);
    expect(detector.doubleTapCount, 1);

    // Genuine 3D wrist flick (60 deg gravity rotation held for 160 ms)
    for (var i = 0; i < 5; i++) {
      feed((x: 880, y: 0, z: -512));
    }
    for (var i = 0; i < 15; i++) {
      feed((x: 0, y: 0, z: -1024));
    }
    expect(events.last.gesture, RingGesture.flick);
    expect(detector.flickCount, 1);

    expect(
      GestureSensitivity.high.tapThresholdG,
      lessThan(GestureSensitivity.medium.tapThresholdG),
    );
    expect(
      GestureSensitivity.medium.tapThresholdG,
      lessThan(GestureSensitivity.low.tapThresholdG),
    );
  });

  test('ThermalGradient and CircadianInsights decode real FR02.023 history fixture', () {
    final warm = ThermalGradient(ntc1: 32.4, ntc2: 33.1);
    expect(warm.delta, closeTo(0.7, 0.001));
    expect(warm.stateLabel, 'Warm / vasodilated');

    final reassembler = FrameReassembler();
    final epochs = <EpochRecord>[];
    final thermals = <ThermalBlock>[];
    final lines = File('test/fixtures/rc_hist_drain4.jsonl').readAsLinesSync();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final row = jsonDecode(line) as Map<String, dynamic>;
      if (row['dir'] != 'rx') continue;
      final raw = _hex(row['hex'] as String);
      for (final frame in [...reassembler.add(raw), ...reassembler.flush()]) {
        if (frame is HistoryPage) {
          for (final rec in frame.records) {
            if (rec is EpochRecord) epochs.add(rec);
            if (rec is ThermalBlock) thermals.add(rec);
          }
        }
      }
    }
    final insights = CircadianInsights.fromRecords(
      epochs: epochs,
      thermalBlocks: thermals,
    );
    expect(insights.epochCount, greaterThan(0));
    expect(insights.thermalBlockCount, greaterThan(0));
    expect(insights.totalLightMinutes, closeTo(insights.epochCount * 2.5, 0.01));
    expect(insights.hrvMedianMs, isNotNull);
    expect(insights.meanThermalDeltaC, isNotNull);
  });
  test('StatusNotice decodes hardware wear/battery events, optical cover-tap, and rep counter', () {
    // 0x11 wear-off (04) and low-battery (09)
    final offBytes = [0x11, 0x00, 0x00, 0x04, 0x11 ^ 0x04];
    final off = RingFrame.decode(offBytes) as StatusNotice;
    expect(off.event, RingStatusEvent.wearOff);

    final lowBytes = [0x11, 0x00, 0x00, 0x09, 0x11 ^ 0x09];
    final low = RingFrame.decode(lowBytes) as StatusNotice;
    expect(low.event, RingStatusEvent.lowBattery);

    // Fast 400 ms optical cover-tap on ambient photodiode
    final ppg = PpgBiofeedbackAnalyzer();
    for (var i = 0; i < 10; i++) {
      ppg.addSample(400000);
      expect(ppg.checkOpticalAmbient(500), isFalse);
    }
    ppg.addSample(400000);
    expect(ppg.checkOpticalAmbient(3200), isTrue);
    expect(ppg.opticalTapCount, 1);

    // Periodic 1 Hz workout reps (3 smooth cycles)
    final motion = GestureDetector3D();
    for (var i = 0; i < 90; i++) {
      final cycle = (500 * math.sin(2 * math.pi * (i / 25.0))).round();
      motion.addSample((x: 0, y: 0, z: 1024 + cycle));
    }
    expect(motion.repCount, greaterThanOrEqualTo(2));
  });
}


List<int> _hex(String input) => [
  for (var i = 0; i < input.length; i += 2)
    int.parse(input.substring(i, i + 2), radix: 16),
];
