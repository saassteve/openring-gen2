import 'dart:math' as math;

import 'frames.dart';

/// Streaming 25 Hz optical PPG analyzer for `0x12` ([DensePpgFrame]) frames.
///
/// Extracts:
/// - Normalized detrended pulse waveform for real-time visualization.
/// - Perfusion Index (`PI% = (max - min) / mean * 100`) on a rolling 2 s window.
/// - Beat-to-beat inter-beat intervals (IBI), live BPM, and rolling RMSSD HRV.
final class PpgBiofeedbackAnalyzer {
  PpgBiofeedbackAnalyzer({this.sampleRateHz = 25});

  final int sampleRateHz;

  static const _rawCapacity = 150; // 6 s at 25 Hz
  static const _waveCapacity = 100; // 4 s display window
  static const _maWindow = 25; // 1 s baseline detrend
  static const _piWindow = 50; // 2 s AC/DC window
  static const _minBeatSamples = 10; // 400 ms (150 bpm max)
  static const _maxBeatSamples = 38; // 1520 ms (39.5 bpm min)

  final List<double> _rawCh0 = [];
  final List<double> _detrended = [];
  final List<double> _smoothed = [];
  final List<int> _ibisMs = [];

  int _sampleIndex = 0;
  int? _lastPeakIndex;
  int _beatCount = 0;
  double? _perfusionIndexPercent;
  double? _liveBpm;
  double? _liveRmssdMs;
  int? _lastIbiMs;

  List<double> get waveform => List.unmodifiable(_smoothed);
  double? get perfusionIndexPercent => _perfusionIndexPercent;
  double? get liveBpm => _liveBpm;
  double? get liveRmssdMs => _liveRmssdMs;
  int? get lastIbiMs => _lastIbiMs;
  int get beatCount => _beatCount;
  int get sampleCount => _sampleIndex;

  void reset() {
    _rawCh0.clear();
    _detrended.clear();
    _smoothed.clear();
    _ibisMs.clear();
    _sampleIndex = 0;
    _lastPeakIndex = null;
    _beatCount = 0;
    _perfusionIndexPercent = null;
    _liveBpm = null;
    _liveRmssdMs = null;
    _lastIbiMs = null;
  }

  void addFrame(DensePpgFrame frame) {
    for (final sample in frame.samples) {
      addSample(sample.channel0.toDouble());
    }
  }

  void addSample(double ch0) {
    _rawCh0.add(ch0);
    if (_rawCh0.length > _rawCapacity) _rawCh0.removeAt(0);

    // Rolling 2-second Perfusion Index (AC/DC %)
    if (_rawCh0.length >= _piWindow) {
      final start = _rawCh0.length - _piWindow;
      var minV = _rawCh0[start];
      var maxV = minV;
      var sum = 0.0;
      for (var i = start; i < _rawCh0.length; i++) {
        final v = _rawCh0[i];
        if (v < minV) minV = v;
        if (v > maxV) maxV = v;
        sum += v;
      }
      final dc = sum / _piWindow;
      if (dc > 1000) {
        _perfusionIndexPercent = ((maxV - minV) / dc) * 100.0;
      }
    }

    // 1-second moving-average detrend
    if (_rawCh0.length >= _maWindow) {
      final start = _rawCh0.length - _maWindow;
      var sum = 0.0;
      for (var i = start; i < _rawCh0.length; i++) {
        sum += _rawCh0[i];
      }
      final det = ch0 - sum / _maWindow;
      _detrended.add(det);
      if (_detrended.length > _waveCapacity + 4) _detrended.removeAt(0);

      if (_detrended.length >= 3) {
        final n = _detrended.length;
        final sm =
            (_detrended[n - 3] + 2 * _detrended[n - 2] + _detrended[n - 1]) /
            4.0;
        _smoothed.add(sm);
        if (_smoothed.length > _waveCapacity) _smoothed.removeAt(0);
        _detectPeak();
      }
    }
    _sampleIndex++;
  }

  void _detectPeak() {
    final n = _smoothed.length;
    if (n < 5) return;
    // Check candidate peak at n - 2 (1-sample lookahead)
    final prev = _smoothed[n - 3];
    final curr = _smoothed[n - 2];
    final next = _smoothed[n - 1];
    if (!(curr > prev && curr >= next)) return;

    final winStart = math.max(0, n - 50);
    var sqSum = 0.0;
    final count = n - winStart;
    for (var i = winStart; i < n; i++) {
      final v = _smoothed[i];
      sqSum += v * v;
    }
    final rms = math.sqrt(sqSum / count);
    if (rms < 20 || curr < 0.6 * rms) return;

    final peakIndex = _sampleIndex - 1;
    final last = _lastPeakIndex;
    if (last != null) {
      final deltaSamples = peakIndex - last;
      if (deltaSamples < _minBeatSamples) return;
      if (deltaSamples <= _maxBeatSamples) {
        final ibiMs = (deltaSamples * 1000 / sampleRateHz).round();
        _beatCount++;
        _lastIbiMs = ibiMs;
        _ibisMs.add(ibiMs);
        if (_ibisMs.length > 20) _ibisMs.removeAt(0);
        _recomputeMetrics();
      }
    }
    _lastPeakIndex = peakIndex;
  }

  void _recomputeMetrics() {
    if (_ibisMs.isEmpty) return;
    final recentStart = math.max(0, _ibisMs.length - 6);
    var sum = 0;
    for (var i = recentStart; i < _ibisMs.length; i++) {
      sum += _ibisMs[i];
    }
    final meanIbi = sum / (_ibisMs.length - recentStart);
    _liveBpm = 60000.0 / meanIbi;

    if (_ibisMs.length >= 3) {
      var sqDiffSum = 0.0;
      var validDiffs = 0;
      for (var i = 1; i < _ibisMs.length; i++) {
        final diff = (_ibisMs[i] - _ibisMs[i - 1]).abs();
        if (diff < 250) {
          sqDiffSum += diff * diff;
          validDiffs++;
        }
      }
      if (validDiffs >= 2) {
        _liveRmssdMs = math.sqrt(sqDiffSum / validDiffs);
      }
    }
  }
}

enum RingGesture {
  tap('Tap'),
  doubleTap('Double tap'),
  flick('Wrist flick');

  const RingGesture(this.label);
  final String label;
}

typedef GestureEvent = ({RingGesture gesture, double peakG, int sampleIndex});

/// Real-time 25 Hz 3-axis accelerometer gesture detector for `0x13` frames.
///
/// Resting magnitude on Gen 2 `FR02.023` is approximately `1024` LSB = 1.0 g.
final class GestureDetector3D {
  GestureDetector3D({this.sampleRateHz = 25, this.lsbPerG = 1024.0});

  final int sampleRateHz;
  final double lsbPerG;

  static const _traceCapacity = 100; // 4 s at 25 Hz
  static const _eventCapacity = 20;
  static const _tapThresholdG = 0.55; // dynamic |g - baseline|
  static const _flickThresholdG = 1.25; // high-energy flick impulse
  static const _refractorySamples = 5; // 200 ms between peaks
  static const _doubleTapMaxSamples = 18; // 720 ms window for second tap

  final List<double> _magnitudeTrace = [];
  final List<GestureEvent> _events = [];

  double _baselineG = 1.0;
  int _sampleIndex = 0;
  int _lastImpulseSample = -100;
  int? _pendingTapSample;
  AccSample? _latestSample;
  double? _latestG;
  int _tapCount = 0;
  int _doubleTapCount = 0;
  int _flickCount = 0;

  AccSample? get latestSample => _latestSample;
  double? get latestG => _latestG;
  List<double> get magnitudeTrace => List.unmodifiable(_magnitudeTrace);
  List<GestureEvent> get events => List.unmodifiable(_events);
  GestureEvent? get lastGesture => _events.isEmpty ? null : _events.last;
  int get tapCount => _tapCount;
  int get doubleTapCount => _doubleTapCount;
  int get flickCount => _flickCount;

  void reset() {
    _magnitudeTrace.clear();
    _events.clear();
    _baselineG = 1.0;
    _sampleIndex = 0;
    _lastImpulseSample = -100;
    _pendingTapSample = null;
    _latestSample = null;
    _latestG = null;
    _tapCount = 0;
    _doubleTapCount = 0;
    _flickCount = 0;
  }

  /// Feeds a full `0x13` frame and returns any gestures triggered during it.
  List<GestureEvent> addFrame(RawPpgFrame frame) {
    final triggered = <GestureEvent>[];
    for (final sample in frame.accSamples) {
      final event = addSample(sample);
      if (event != null) triggered.add(event);
    }
    return triggered;
  }

  GestureEvent? addSample(AccSample sample) {
    _latestSample = sample;
    final gx = sample.x / lsbPerG;
    final gy = sample.y / lsbPerG;
    final gz = sample.z / lsbPerG;
    final magG = math.sqrt(gx * gx + gy * gy + gz * gz);
    _latestG = magG;

    _magnitudeTrace.add(magG);
    if (_magnitudeTrace.length > _traceCapacity) _magnitudeTrace.removeAt(0);

    final dynamicG = (magG - _baselineG).abs();
    // Slow baseline tracking when near rest so orientation drift never trips.
    if (dynamicG < 0.25) {
      _baselineG = _baselineG * 0.92 + magG * 0.08;
    }

    GestureEvent? emitted;
    if (dynamicG >= _tapThresholdG &&
        (_sampleIndex - _lastImpulseSample) >= _refractorySamples) {
      _lastImpulseSample = _sampleIndex;
      if (dynamicG >= _flickThresholdG) {
        _pendingTapSample = null;
        _flickCount++;
        emitted = (
          gesture: RingGesture.flick,
          peakG: magG,
          sampleIndex: _sampleIndex,
        );
      } else {
        final pending = _pendingTapSample;
        if (pending != null &&
            (_sampleIndex - pending) <= _doubleTapMaxSamples) {
          _pendingTapSample = null;
          _doubleTapCount++;
          emitted = (
            gesture: RingGesture.doubleTap,
            peakG: magG,
            sampleIndex: _sampleIndex,
          );
        } else {
          _pendingTapSample = _sampleIndex;
          _tapCount++;
          emitted = (
            gesture: RingGesture.tap,
            peakG: magG,
            sampleIndex: _sampleIndex,
          );
        }
      }
      _events.add(emitted);
      if (_events.length > _eventCapacity) _events.removeAt(0);
    }

    if (_pendingTapSample != null &&
        (_sampleIndex - _pendingTapSample!) > _doubleTapMaxSamples) {
      _pendingTapSample = null;
    }

    _sampleIndex++;
    return emitted;
  }
}

/// Dual-NTC finger-vs-shell thermal gradient.
final class ThermalGradient {
  const ThermalGradient({required this.ntc1, required this.ntc2});

  final double ntc1;
  final double ntc2;

  /// `ntc2 - ntc1` (positive when inner finger skin is warmer than outer shell).
  double get delta => ntc2 - ntc1;

  String get stateLabel {
    if (delta >= 0.4) return 'Warm / vasodilated';
    if (delta <= -0.2) return 'Cool / vasoconstricted';
    return 'Balanced thermal flow';
  }
}

/// Summary of hidden history channels (30-second ambient light, HRV range,
/// and dual-NTC thermal gradient) from local `0x4c` epochs and `0x47` blocks.
final class CircadianInsights {
  const CircadianInsights({
    required this.epochCount,
    required this.thermalBlockCount,
    required this.darkMinutes,
    required this.dimMinutes,
    required this.brightMinutes,
    required this.darkLightSpikes,
    required this.hrvMinMs,
    required this.hrvMedianMs,
    required this.hrvMaxMs,
    required this.meanThermalDeltaC,
    required this.peakThermalDeltaC,
  });

  final int epochCount;
  final int thermalBlockCount;
  final double darkMinutes;
  final double dimMinutes;
  final double brightMinutes;
  final int darkLightSpikes;
  final int? hrvMinMs;
  final int? hrvMedianMs;
  final int? hrvMaxMs;
  final double? meanThermalDeltaC;
  final double? peakThermalDeltaC;

  double get totalLightMinutes => darkMinutes + dimMinutes + brightMinutes;

  factory CircadianInsights.fromRecords({
    required Iterable<EpochRecord> epochs,
    required Iterable<ThermalBlock> thermalBlocks,
  }) {
    var epochCount = 0;
    var darkHalfMins = 0;
    var dimHalfMins = 0;
    var brightHalfMins = 0;
    var darkLightSpikes = 0;
    final hrvs = <int>[];
    var inDarkStreak = 0;

    for (final epoch in epochs) {
      epochCount++;
      final hrv = epoch.hrvMs;
      if (hrv != null && hrv >= 1 && hrv <= 200) hrvs.add(hrv);
      for (final light in epoch.ambient) {
        if (light <= 2) {
          darkHalfMins++;
          inDarkStreak++;
        } else if (light <= 20) {
          dimHalfMins++;
          if (inDarkStreak >= 10) darkLightSpikes++;
          inDarkStreak = 0;
        } else {
          brightHalfMins++;
          if (inDarkStreak >= 10) darkLightSpikes++;
          inDarkStreak = 0;
        }
      }
    }

    hrvs.sort();
    int? hrvMin;
    int? hrvMedian;
    int? hrvMax;
    if (hrvs.isNotEmpty) {
      hrvMin = hrvs.first;
      hrvMax = hrvs.last;
      hrvMedian = hrvs[hrvs.length ~/ 2];
    }

    var blockCount = 0;
    var deltaSum = 0.0;
    var deltaSamples = 0;
    double? peakDelta;
    for (final block in thermalBlocks) {
      blockCount++;
      final outer = block.outerTemperatures;
      final inner = block.innerTemperatures;
      final n = math.min(outer.length, inner.length);
      for (var i = 0; i < n; i++) {
        final d = inner[i] - outer[i];
        deltaSum += d;
        deltaSamples++;
        if (peakDelta == null || d > peakDelta) peakDelta = d;
      }
    }

    return CircadianInsights(
      epochCount: epochCount,
      thermalBlockCount: blockCount,
      darkMinutes: darkHalfMins / 2.0,
      dimMinutes: dimHalfMins / 2.0,
      brightMinutes: brightHalfMins / 2.0,
      darkLightSpikes: darkLightSpikes,
      hrvMinMs: hrvMin,
      hrvMedianMs: hrvMedian,
      hrvMaxMs: hrvMax,
      meanThermalDeltaC: deltaSamples == 0 ? null : deltaSum / deltaSamples,
      peakThermalDeltaC: peakDelta,
    );
  }
}
