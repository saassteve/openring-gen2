import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:ring_protocol/ring_protocol.dart';

import '../ble/ring_controller.dart';
import 'sparkline.dart';

/// Live sensor lab & hidden-channel explorer for unused ring hardware:
/// - `06 05 00` -> `0x12`: 4-ch optical PPG biofeedback (live BPM, RMSSD, PI%)
/// - `23 03 00` -> `0x13`: 25 Hz 3-axis accelerometer & finger gestures
/// - `29 00 00` -> `0xa9`: live dual-NTC thermal gradient
/// - `0x4c` / `0x47` SQLite history: hidden 30 s ambient light & thermal delta
class SensorLabScreen extends StatefulWidget {
  const SensorLabScreen(this.ring, {super.key});

  final RingController ring;

  @override
  State<SensorLabScreen> createState() => _SensorLabScreenState();
}

class _SensorLabScreenState extends State<SensorLabScreen> {
  Future<CircadianInsights>? _insights;
  String? _insightsDevice;

  @override
  void initState() {
    super.initState();
    _refreshInsights();
  }

  @override
  void didUpdateWidget(covariant SensorLabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ring.deviceId != _insightsDevice) {
      _refreshInsights();
    }
  }

  void _refreshInsights() {
    _insightsDevice = widget.ring.deviceId;
    _insights = widget.ring.database.loadCircadianInsights(
      deviceId: _insightsDevice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ring = widget.ring;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final ppg = ring.ppgAnalyzer;
    final acc = ring.gestureDetector;
    final temp = ring.sensorTemperature;
    final gradient = temp != null
        ? ThermalGradient(ntc1: temp.temperature1, ntc2: temp.temperature2)
        : (ring.telemetry != null
              ? ThermalGradient(
                  ntc1: ring.telemetry!.temperature1,
                  ntc2: ring.telemetry!.temperature2,
                )
              : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Heading('PPG Biofeedback & Breathing'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Streams raw 25 Hz optical PPG (0x12) to compute live '
                'beat-to-beat HRV and finger Perfusion Index (PI%).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              if (ring.ppgStreaming) ...[
                const _BreathPacer(),
                const SizedBox(height: 14),
              ],
              Wrap(
                spacing: 22,
                runSpacing: 10,
                children: [
                  _Stat(
                    'Live BPM',
                    ppg.liveBpm != null
                        ? ppg.liveBpm!.toStringAsFixed(0)
                        : '—',
                  ),
                  _Stat(
                    'Live RMSSD',
                    ppg.liveRmssdMs != null
                        ? '${ppg.liveRmssdMs!.toStringAsFixed(0)} ms'
                        : '—',
                  ),
                  _Stat(
                    'Perfusion (PI%)',
                    ppg.perfusionIndexPercent != null
                        ? '${ppg.perfusionIndexPercent!.toStringAsFixed(2)}%'
                        : '—',
                  ),
                  _Stat('Beats', '${ppg.beatCount}'),
                ],
              ),
              if (ppg.waveform.isNotEmpty) ...[
                const SizedBox(height: 14),
                Sparkline(
                  points: [
                    for (var i = 0; i < ppg.waveform.length; i++)
                      (x: i, value: ppg.waveform[i]),
                  ],
                  label: 'Live optical PPG waveform',
                  color: colors.primary,
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: ring.connected && !ring.syncing
                    ? () => ring.setDensePpg(!ring.ppgStreaming)
                    : null,
                icon: Icon(
                  ring.ppgStreaming ? Icons.stop : Icons.waves_outlined,
                ),
                label: Text(
                  ring.ppgStreaming
                      ? 'Stop PPG biofeedback'
                      : 'Start PPG biofeedback',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('25 Hz Motion & Finger Gestures'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Streams live 3-axis accelerometer data (23 03 00 → 0x13) in '
                'normal mode to detect finger taps, double-taps, and wrist flicks.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 22,
                runSpacing: 10,
                children: [
                  _Stat(
                    'Accel',
                    acc.latestG != null
                        ? '${acc.latestG!.toStringAsFixed(2)} g'
                        : '—',
                  ),
                  _Stat('Taps', '${acc.tapCount}'),
                  _Stat('Double taps', '${acc.doubleTapCount}'),
                  _Stat('Wrist flicks', '${acc.flickCount}'),
                ],
              ),
              if (acc.latestSample case final s?) ...[
                const SizedBox(height: 8),
                Text(
                  'XYZ (g): '
                  '${(s.x / 1024).toStringAsFixed(2)}, '
                  '${(s.y / 1024).toStringAsFixed(2)}, '
                  '${(s.z / 1024).toStringAsFixed(2)}'
                  '${acc.lastGesture != null ? '  •  Last: ${acc.lastGesture!.gesture.label}' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ],
              if (acc.magnitudeTrace.isNotEmpty) ...[
                const SizedBox(height: 12),
                Sparkline(
                  points: [
                    for (var i = 0; i < acc.magnitudeTrace.length; i++)
                      (x: i, value: acc.magnitudeTrace[i]),
                  ],
                  label: 'Live 25 Hz acceleration magnitude',
                  color: colors.secondary,
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: ring.connected && !ring.syncing
                    ? () => ring.setAccelerometer(!ring.accStreaming)
                    : null,
                icon: Icon(
                  ring.accStreaming ? Icons.stop : Icons.touch_app_outlined,
                ),
                label: Text(
                  ring.accStreaming
                      ? 'Stop 25 Hz gesture stream'
                      : 'Start 25 Hz gesture stream',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Dual-NTC Thermal Gradient'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compares inner finger skin temperature against the outer ring '
                'shell (29 00 00 → 0xa9) as a live vasodilation indicator.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 22,
                runSpacing: 10,
                children: [
                  _Stat(
                    'NTC 1',
                    gradient != null
                        ? '${gradient.ntc1.toStringAsFixed(1)} °C'
                        : '—',
                  ),
                  _Stat(
                    'NTC 2',
                    gradient != null
                        ? '${gradient.ntc2.toStringAsFixed(1)} °C'
                        : '—',
                  ),
                  _Stat(
                    'Delta (Δ)',
                    gradient != null
                        ? '${gradient.delta >= 0 ? '+' : ''}${gradient.delta.toStringAsFixed(1)} °C'
                        : '—',
                  ),
                  _Stat('State', gradient?.stateLabel ?? '—'),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: ring.connected && !ring.syncing
                    ? ring.readSensorTemperature
                    : null,
                icon: const Icon(Icons.thermostat_outlined),
                label: const Text('Read Dual NTC now'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Hidden History: Light, Thermal & HRV'),
        _Card(
          child: FutureBuilder<CircadianInsights>(
            future: _insights,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Could not decode local history insights.');
              }
              final data = snapshot.data;
              if (data == null) {
                return const LinearProgressIndicator();
              }
              if (data.epochCount == 0 && data.thermalBlockCount == 0) {
                return Text(
                  'Sync ring history to unlock hidden 30-second ambient light '
                  'hygiene, dual-NTC thermal deltas, and full HRV ranges.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Decoded from ${data.epochCount} epochs and '
                    '${data.thermalBlockCount} thermal blocks stored locally.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 22,
                    runSpacing: 10,
                    children: [
                      _Stat(
                        'Pitch-dark time',
                        '${data.darkMinutes.toStringAsFixed(0)} min',
                      ),
                      _Stat(
                        'Dim light',
                        '${data.dimMinutes.toStringAsFixed(0)} min',
                      ),
                      _Stat(
                        'Bright light',
                        '${data.brightMinutes.toStringAsFixed(0)} min',
                      ),
                      _Stat('Dark light spikes', '${data.darkLightSpikes}'),
                      _Stat(
                        'HRV (min/med/max)',
                        data.hrvMedianMs != null
                            ? '${data.hrvMinMs}/${data.hrvMedianMs}/${data.hrvMaxMs} ms'
                            : '—',
                      ),
                      _Stat(
                        'Mean inner−outer Δ',
                        data.meanThermalDeltaC != null
                            ? '${data.meanThermalDeltaC! >= 0 ? '+' : ''}${data.meanThermalDeltaC!.toStringAsFixed(2)} °C'
                            : '—',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => setState(_refreshInsights),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh from local history'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 5.5 s inhale / 5.5 s exhale (~5.5 breaths/min) coherent breathing pacer.
class _BreathPacer extends StatefulWidget {
  const _BreathPacer();

  @override
  State<_BreathPacer> createState() => _BreathPacerState();
}

class _BreathPacerState extends State<_BreathPacer> {
  static const _cycleMs = 11000;
  final Stopwatch _clock = Stopwatch()..start();
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pos = (_clock.elapsedMilliseconds % _cycleMs) / _cycleMs;
    final inhaling = pos < 0.5;
    final phase = inhaling ? pos * 2 : (1 - pos) * 2;
    final fill = 0.5 - 0.5 * math.cos(phase * math.pi);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          inhaling
              ? 'Coherent pacer • Inhale slowly (5.5 s)'
              : 'Coherent pacer • Exhale gently (5.5 s)',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fill,
            minHeight: 8,
            backgroundColor: colors.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: Padding(padding: const EdgeInsets.all(18), child: child),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}
