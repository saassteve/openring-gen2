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
  double? _ambientBaseline;
  int _opticalTapCount = 0;
  int _lastOpticalTapSample = -100;

  List<double> get waveform => List.unmodifiable(_smoothed);
  double? get perfusionIndexPercent => _perfusionIndexPercent;
  double? get liveBpm => _liveBpm;
  double? get liveRmssdMs => _liveRmssdMs;
  int? get lastIbiMs => _lastIbiMs;
  int get beatCount => _beatCount;
  int get sampleCount => _sampleIndex;
  int get opticalTapCount => _opticalTapCount;

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
    _ambientBaseline = null;
    _opticalTapCount = 0;
    _lastOpticalTapSample = -100;
  }

  /// Processes a 400 ms `0x12` frame and returns `true` if a fast optical
  /// cover/tap impulse was detected on the ambient photodiode channel.
  bool addFrame(DensePpgFrame frame) {
    var opticalTap = false;
    for (final sample in frame.samples) {
      addSample(sample.channel0.toDouble());
      if (checkOpticalAmbient(sample.ambient.toDouble())) {
        opticalTap = true;
      }
    }
    return opticalTap;
  }

  /// Evaluates one 25 Hz ambient optical sample for a fast cover/tap impulse.
  bool checkOpticalAmbient(double ambient) {
    final base = _ambientBaseline;
    if (base == null) {
      _ambientBaseline = ambient;
      return false;
    }
    final delta = (ambient - base).abs();
    final threshold = math.max(1200.0, base.abs() * 0.45);
    if (delta < threshold * 0.5) {
      _ambientBaseline = base * 0.90 + ambient * 0.10;
    }
    if (delta >= threshold && (_sampleIndex - _lastOpticalTapSample) >= 30) {
      _lastOpticalTapSample = _sampleIndex;
      _opticalTapCount++;
      return true;
    }
    return false;
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

enum GestureSensitivity {
  high('High', tapThresholdG: 0.22, flickThresholdG: 0.90),
  medium('Medium', tapThresholdG: 0.34, flickThresholdG: 1.15),
  low('Low', tapThresholdG: 0.50, flickThresholdG: 1.45);

  const GestureSensitivity(
    this.label, {
    required this.tapThresholdG,
    required this.flickThresholdG,
  });

  final String label;
  final double tapThresholdG;
  final double flickThresholdG;
}

typedef GestureEvent = ({RingGesture gesture, double peakG, int sampleIndex});

/// Real-time 25 Hz 3-axis accelerometer gesture detector for `0x13` frames.
///
/// Uses a 3D gravity vector tracker plus 3D jerk so taps perpendicular to
/// gravity register with the same sensitivity as vertical taps. Single taps
/// wait for the double-tap window before emitting so double-tapping never
/// double-fires a single-tap action first.
final class GestureDetector3D {
  GestureDetector3D({
    this.sampleRateHz = 25,
    this.lsbPerG = 1024.0,
    this.sensitivity = GestureSensitivity.medium,
  });

  final int sampleRateHz;
  final double lsbPerG;

  static const _traceCapacity = 100; // 4 s at 25 Hz
  static const _eventCapacity = 20;
  static const _hysteresisRatio = 0.65;
  static const _minInterTapSamples = 3; // 120 ms minimum gap between tap peaks
  static const _maxTapBurstSamples = 5; // <= 200 ms crisp impulse = tap
  static const _maxBurstSamples = 12; // 480 ms burst cap
  static const _doubleTapMaxSamples = 22; // 880 ms window for second tap

  final List<double> _magnitudeTrace = [];
  final List<double> _impulseTrace = [];
  final List<GestureEvent> _events = [];

  GestureSensitivity sensitivity;
  bool _initialized = false;
  double _gravX = 0;
  double _gravY = 0;
  double _gravZ = 1.0;
  double _prevX = 0;
  double _prevY = 0;
  double _prevZ = 1.0;

  int _sampleIndex = 0;
  bool _inBurst = false;
  int _burstSamples = 0;
  double _burstPeakG = 0;
  int _burstPeakSample = -100;
  int _lastTapPeakSample = -100;
  ({double peakG, int sampleIndex})? _pendingTap;

  AccSample? _latestSample;
  double? _latestG;
  double? _latestImpulseG;
  int _tapCount = 0;
  int _doubleTapCount = 0;
  int _flickCount = 0;
  int _repCount = 0;
  double _smoothVerticalG = 0;
  bool _repArmedHigh = false;
  int _lastRepSample = -100;

  double get tapThresholdG => sensitivity.tapThresholdG;
  double get rollDeg =>
      math.atan2(_gravY, _gravZ) * (180.0 / math.pi);
  double get pitchDeg =>
      math.atan2(-_gravX, math.sqrt(_gravY * _gravY + _gravZ * _gravZ)) *
      (180.0 / math.pi);
  int get repCount => _repCount;

  void resetReps() {
    _repCount = 0;
    _repArmedHigh = false;
  }
  double get flickThresholdG => sensitivity.flickThresholdG;

  AccSample? get latestSample => _latestSample;
  double? get latestG => _latestG;
  double? get latestImpulseG => _latestImpulseG;
  List<double> get magnitudeTrace => List.unmodifiable(_magnitudeTrace);
  List<double> get impulseTrace => List.unmodifiable(_impulseTrace);
  List<GestureEvent> get events => List.unmodifiable(_events);
  GestureEvent? get lastGesture => _events.isEmpty ? null : _events.last;
  int get tapCount => _tapCount;
  int get doubleTapCount => _doubleTapCount;
  int get flickCount => _flickCount;

  void reset() {
    _magnitudeTrace.clear();
    _impulseTrace.clear();
    _events.clear();
    _initialized = false;
    _gravX = 0;
    _gravY = 0;
    _gravZ = 1.0;
    _prevX = 0;
    _prevY = 0;
    _prevZ = 1.0;
    _sampleIndex = 0;
    _inBurst = false;
    _burstSamples = 0;
    _burstPeakG = 0;
    _burstPeakSample = -100;
    _lastTapPeakSample = -100;
    _pendingTap = null;
    _latestSample = null;
    _latestG = null;
    _latestImpulseG = null;
    _tapCount = 0;
    _doubleTapCount = 0;
    _flickCount = 0;
    _repCount = 0;
    _smoothVerticalG = 0;
    _repArmedHigh = false;
    _lastRepSample = -100;
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
    final ax = sample.x / lsbPerG;
    final ay = sample.y / lsbPerG;
    final az = sample.z / lsbPerG;
    final magG = math.sqrt(ax * ax + ay * ay + az * az);
    _latestG = magG;

    if (!_initialized) {
      _initialized = true;
      _gravX = ax;
      _gravY = ay;
      _gravZ = az;
      _prevX = ax;
      _prevY = ay;
      _prevZ = az;
    }

    final dxG = ax - _gravX;
    final dyG = ay - _gravY;
    final dzG = az - _gravZ;
    final linG = math.sqrt(dxG * dxG + dyG * dyG + dzG * dzG);

    final jx = ax - _prevX;
    final jy = ay - _prevY;
    final jz = az - _prevZ;
    final jerkG = math.sqrt(jx * jx + jy * jy + jz * jz);

    // Combine orientation-independent linear accel with sharp sample-to-sample
    // jerk so taps in any plane (vertical or sideways pinch) register cleanly.
    final impulseG = 0.45 * linG + 0.55 * jerkG;
    _latestImpulseG = impulseG;

    // Adapt gravity baseline quickly near rest and slowly during motion.
    final alpha = linG < 0.25 ? 0.14 : 0.03;
    _gravX += alpha * dxG;
    _gravY += alpha * dyG;
    _gravZ += alpha * dzG;
    _prevX = ax;
    _prevY = ay;
    _prevZ = az;

    // Low-pass filtered dynamic acceleration along the gravity axis tracks
    // smooth periodic workout reps (curls, pushups, squats) at 0.3-2.5 Hz.
    final gravNorm = math.sqrt(
      _gravX * _gravX + _gravY * _gravY + _gravZ * _gravZ,
    );
    if (gravNorm > 0.2) {
      final projG =
          (dxG * _gravX + dyG * _gravY + dzG * _gravZ) / gravNorm;
      _smoothVerticalG = _smoothVerticalG * 0.72 + projG * 0.28;
      if (!_repArmedHigh && _smoothVerticalG >= 0.24) {
        _repArmedHigh = true;
      } else if (_repArmedHigh &&
          _smoothVerticalG <= -0.18 &&
          (_sampleIndex - _lastRepSample) >= 12) {
        _repArmedHigh = false;
        _lastRepSample = _sampleIndex;
        _repCount++;
      }
    }

    _magnitudeTrace.add(magG);
    if (_magnitudeTrace.length > _traceCapacity) _magnitudeTrace.removeAt(0);
    _impulseTrace.add(impulseG);
    if (_impulseTrace.length > _traceCapacity) _impulseTrace.removeAt(0);

    GestureEvent? emitted;
    final tapThresh = sensitivity.tapThresholdG;
    final releaseThresh = tapThresh * _hysteresisRatio;

    if (!_inBurst) {
      if (impulseG >= tapThresh) {
        _inBurst = true;
        _burstSamples = 1;
        _burstPeakG = impulseG;
        _burstPeakSample = _sampleIndex;
      }
    } else {
      if (impulseG >= releaseThresh && _burstSamples < _maxBurstSamples) {
        _burstSamples++;
        if (impulseG > _burstPeakG) {
          _burstPeakG = impulseG;
          _burstPeakSample = _sampleIndex;
        }
      } else {
        emitted = _finalizeBurst();
      }
    }

    // Emit a deferred single tap once the double-tap window elapses cleanly.
    if (emitted == null &&
        !_inBurst &&
        _pendingTap != null &&
        (_sampleIndex - _pendingTap!.sampleIndex) > _doubleTapMaxSamples) {
      final pending = _pendingTap!;
      _pendingTap = null;
      _tapCount++;
      emitted = _record(
        (
          gesture: RingGesture.tap,
          peakG: pending.peakG,
          sampleIndex: pending.sampleIndex,
        ),
      );
    }

    _sampleIndex++;
    return emitted;
  }

  GestureEvent? _finalizeBurst() {
    _inBurst = false;
    final peakG = _burstPeakG;
    final peakSample = _burstPeakSample;
    final duration = _burstSamples;
    final flickThresh = sensitivity.flickThresholdG;
    final tapThresh = sensitivity.tapThresholdG;

    final isFlick =
        peakG >= flickThresh ||
        (duration > _maxTapBurstSamples && peakG >= tapThresh * 1.4);

    if (isFlick) {
      _pendingTap = null;
      _lastTapPeakSample = peakSample;
      _flickCount++;
      return _record(
        (gesture: RingGesture.flick, peakG: peakG, sampleIndex: peakSample),
      );
    }

    if (duration > _maxTapBurstSamples) {
      // Broad low-energy drift/movement — ignore rather than false-tapping.
      return null;
    }

    if ((peakSample - _lastTapPeakSample) < _minInterTapSamples) {
      // Rebound from the same tap.
      return null;
    }
    _lastTapPeakSample = peakSample;

    final pending = _pendingTap;
    if (pending != null &&
        (peakSample - pending.sampleIndex) <= _doubleTapMaxSamples) {
      _pendingTap = null;
      _doubleTapCount++;
      return _record(
        (gesture: RingGesture.doubleTap, peakG: peakG, sampleIndex: peakSample),
      );
    }

    _pendingTap = (peakG: peakG, sampleIndex: peakSample);
    return null;
  }

  GestureEvent _record(GestureEvent event) {
    _events.add(event);
    if (_events.length > _eventCapacity) _events.removeAt(0);
    return event;
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
