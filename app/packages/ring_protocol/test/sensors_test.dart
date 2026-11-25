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

  test('GestureDetector3D distinguishes rest, tap, double-tap, and flick', () {
    final detector = GestureDetector3D();
    // 1 second of resting 1g
    for (var i = 0; i < 25; i++) {
      expect(detector.addSample((x: 0, y: 0, z: 1024)), isNull);
    }
    expect(detector.tapCount, 0);

    // First tap (~1.7g impulse)
    final tap1 = detector.addSample((x: 0, y: 0, z: 1750));
    expect(tap1?.gesture, RingGesture.tap);

    // 7 samples (~280 ms) of rest, then second tap -> double tap
    for (var i = 0; i < 7; i++) {
      detector.addSample((x: 0, y: 0, z: 1024));
    }
    final tap2 = detector.addSample((x: 0, y: 0, z: 1750));
    expect(tap2?.gesture, RingGesture.doubleTap);
    expect(detector.doubleTapCount, 1);

    // 10 samples of rest, then high-energy wrist flick (~2.6g)
    for (var i = 0; i < 10; i++) {
      detector.addSample((x: 0, y: 0, z: 1024));
    }
    final flick = detector.addSample((x: 2000, y: 1200, z: 1200));
    expect(flick?.gesture, RingGesture.flick);
    expect(detector.flickCount, 1);
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
}

List<int> _hex(String input) => [
  for (var i = 0; i < input.length; i += 2)
    int.parse(input.substring(i, i + 2), radix: 16),
];
