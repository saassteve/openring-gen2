import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:ring_protocol/ring_protocol.dart';

import '../ble/ring_controller.dart';
import '../data/gesture_actions.dart';
import 'sparkline.dart';

String formatDurationHm(double totalMinutes) {
  final mins = totalMinutes.round();
  if (mins < 60) return '${mins}m';
  final h = mins ~/ 60;
  final m = mins % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

/// Consumer-friendly Ring Remote & Everyday Automations tab.
class ControlScreen extends StatefulWidget {
  const ControlScreen(this.ring, {super.key});

  final RingController ring;

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _showCustom = false;
  late final TextEditingController _webhookController;

  @override
  void initState() {
    super.initState();
    _webhookController = TextEditingController(
      text: widget.ring.gestureConfig.webhookUrl,
    );
    unawaited(widget.ring.refreshAccessibilityStatus());
  }

  @override
  void didUpdateWidget(covariant ControlScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final url = widget.ring.gestureConfig.webhookUrl;
    if (_webhookController.text != url) _webhookController.text = url;
  }

  @override
  void dispose() {
    _webhookController.dispose();
    super.dispose();
  }

  IconData _presetIcon(String id) => switch (id) {
    'music' => Icons.music_note_rounded,
    'finder' => Icons.notifications_active_rounded,
    'camera' => Icons.camera_alt_rounded,
    'reader' => Icons.menu_book_rounded,
    _ => Icons.touch_app_rounded,
  };

  String _presetWhy(GesturePreset preset) => switch (preset.id) {
    'music' => 'Double-tap to play or pause · Twist wrist to skip track',
    'finder' =>
      'Double-tap for flashlight · Twist wrist to ring phone loudly (even on Silent)',
    'camera' =>
      'Double-tap to snap a hands-free photo · Twist wrist for flashlight',
    'reader' =>
      'Double-tap to scroll or turn page · Twist wrist to go back up',
    _ => preset.subtitle,
  };

  String _sensitivityLabel(GestureSensitivity s) => switch (s) {
    GestureSensitivity.high => 'Light',
    GestureSensitivity.medium => 'Balanced',
    GestureSensitivity.low => 'Firm',
  };

  @override
  Widget build(BuildContext context) {
    final ring = widget.ring;
    final acc = ring.gestureDetector;
    final cfg = ring.gestureConfig;
    final smart = ring.smartConfig;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Heading('Ring Remote'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ring.accStreaming
                          ? colors.primary.withValues(alpha: 0.16)
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      ring.accStreaming
                          ? Icons.touch_app_rounded
                          : Icons.touch_app_outlined,
                      color: ring.accStreaming
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ring.accStreaming
                              ? 'Ring Remote is active'
                              : 'Ring Remote is off',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          'Tap your ring finger twice or twist your wrist firmly — works even with your screen off.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ring.accStreaming,
                    onChanged: ring.connected && !ring.syncing
                        ? (on) => unawaited(ring.setAccelerometer(on))
                        : null,
                  ),
                ],
              ),
              if (ring.lastGestureActionDetail case final detail?) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          detail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Pick what your ring controls',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              for (final preset in GestureActionConfig.presets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PresetTile(
                    icon: _presetIcon(preset.id),
                    title: preset.title,
                    subtitle: _presetWhy(preset),
                    selected: preset.matches(cfg),
                    onTap: () => unawaited(
                      ring.updateGestureConfig(cfg.applyPreset(preset)),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                'Tap strength',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final level in GestureSensitivity.values)
                    ChoiceChip(
                      label: Text(_sensitivityLabel(level)),
                      selected: cfg.sensitivity == level,
                      onSelected: (selected) {
                        if (selected) {
                          unawaited(
                            ring.updateGestureConfig(
                              cfg.copyWith(sensitivity: level),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Use Firm if typing or everyday bumps trigger accidental taps.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (ring.deviceActions.supported &&
                  cfg.usesAccessibility &&
                  !ring.accessibilityEnabled) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'One-time Android permission needed so RingPilot can snap photos or scroll other apps.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onTertiaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: ring.openAccessibilitySettings,
                            child: const Text('Enable permission'),
                          ),
                          TextButton(
                            onPressed: ring.refreshAccessibilityStatus,
                            child: const Text('Recheck'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showCustom = !_showCustom),
                  icon: Icon(
                    _showCustom
                        ? Icons.expand_less_rounded
                        : Icons.tune_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _showCustom
                        ? 'Hide custom actions & tap meter'
                        : 'Customize actions & test taps',
                  ),
                ),
              ),
              if (_showCustom) ...[
                const Divider(height: 20),
                Wrap(
                  spacing: 18,
                  runSpacing: 10,
                  children: [
                    _Stat(
                      'Tap force',
                      acc.latestImpulseG != null
                          ? '${acc.latestImpulseG!.toStringAsFixed(2)} g'
                          : '—',
                    ),
                    _Stat('Wrist twist', '${acc.latestAngleDeg.toStringAsFixed(0)}°'),
                    _Stat('Double taps', '${acc.doubleTapCount}'),
                    _Stat('Wrist twists', '${acc.flickCount}'),
                  ],
                ),
                if (acc.impulseTrace.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Sparkline(
                    points: [
                      for (var i = 0; i < acc.impulseTrace.length; i++)
                        (x: i, value: acc.impulseTrace[i]),
                    ],
                    label: 'Live tap meter',
                    color: colors.secondary,
                    threshold: acc.tapThresholdG,
                    thresholdColor: colors.primary,
                    minValue: 0,
                    maxValue: 1.6,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Spikes above the dashed line count as taps; twisting ≥ ${acc.flickAngleDeg.toStringAsFixed(0)}° counts as a wrist flick.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                const Divider(height: 24),
                if (ring.deviceActions.supported) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Keep working with screen off'),
                    subtitle: const Text(
                      'Shows a quiet Android status notification while active',
                    ),
                    value: cfg.backgroundService,
                    onChanged: (value) => unawaited(
                      ring.updateGestureConfig(
                        cfg.copyWith(backgroundService: value),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Vibrate phone when triggered'),
                    subtitle: const Text(
                      'Quick confirmation buzz so you know your tap registered',
                    ),
                    value: cfg.hapticFeedback,
                    onChanged: (value) => unawaited(
                      ring.updateGestureConfig(
                        cfg.copyWith(hapticFeedback: value),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _GestureActionRow(
                  label: 'Single tap',
                  gesture: RingGesture.tap,
                  selected: cfg.tapAction,
                  onChanged: (action) => unawaited(
                    ring.updateGestureConfig(cfg.copyWith(tapAction: action)),
                  ),
                  onTest: () =>
                      unawaited(ring.testGestureAction(RingGesture.tap)),
                ),
                const SizedBox(height: 10),
                _GestureActionRow(
                  label: 'Double tap',
                  gesture: RingGesture.doubleTap,
                  selected: cfg.doubleTapAction,
                  onChanged: (action) => unawaited(
                    ring.updateGestureConfig(
                      cfg.copyWith(doubleTapAction: action),
                    ),
                  ),
                  onTest: () =>
                      unawaited(ring.testGestureAction(RingGesture.doubleTap)),
                ),
                const SizedBox(height: 10),
                _GestureActionRow(
                  label: 'Wrist twist / flick',
                  gesture: RingGesture.flick,
                  selected: cfg.flickAction,
                  onChanged: (action) => unawaited(
                    ring.updateGestureConfig(cfg.copyWith(flickAction: action)),
                  ),
                  onTest: () =>
                      unawaited(ring.testGestureAction(RingGesture.flick)),
                ),
                if (cfg.usesWebhook) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _webhookController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Webhook URL',
                      hintText: 'http://homeassistant.local:8123/api/webhook/...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (url) => unawaited(
                      ring.updateGestureConfig(cfg.copyWith(webhookUrl: url)),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Everyday Automations'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Helpful background automations that run automatically with zero extra ring battery drain.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pause audio when ring comes off'),
                subtitle: const Text(
                  'Taking your ring off to wash hands or shower pauses music or videos',
                ),
                value: smart.ringOffPauseMedia,
                onChanged: (v) => unawaited(
                  ring.updateSmartConfig(smart.copyWith(ringOffPauseMedia: v)),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-pause if you fall asleep'),
                subtitle: const Text(
                  'Pauses podcasts or videos when your finger naturally warms up as you drift off',
                ),
                value: smart.dozeOffPauseMedia,
                onChanged: (v) => unawaited(
                  ring.updateSmartConfig(smart.copyWith(dozeOffPauseMedia: v)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Left-ring-behind reminder',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Notifies you if your ring is left off your finger and not charging.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final mins in [0, 5, 15, 30])
                    ChoiceChip(
                      label: Text(mins == 0 ? 'Off' : 'After $mins min'),
                      selected: smart.ringOffReminderMinutes == mins,
                      onSelected: (selected) {
                        if (selected) {
                          unawaited(
                            ring.updateSmartConfig(
                              smart.copyWith(ringOffReminderMinutes: mins),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Charge-before-bed reminder',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Alerts you to top up so your ring never runs out overnight.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final pct in [0, 15, 20, 30])
                    ChoiceChip(
                      label: Text(pct == 0 ? 'Off' : 'Below $pct%'),
                      selected: smart.lowBatteryGuardPercent == pct,
                      onSelected: (selected) {
                        if (selected) {
                          unawaited(
                            ring.updateSmartConfig(
                              smart.copyWith(lowBatteryGuardPercent: pct),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
              if (ring.lastAutomationDetail case final autoDetail?) ...[
                const SizedBox(height: 12),
                Text(
                  'Last triggered: $autoDetail',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Consumer-friendly Stress Reset, Recovery Check & Sleep Environment tab.
class WellnessScreen extends StatefulWidget {
  const WellnessScreen(this.ring, {super.key});

  final RingController ring;

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  late Future<CircadianInsights> _insights;
  int _lastSyncCount = -1;

  @override
  void initState() {
    super.initState();
    _lastSyncCount = widget.ring.syncCompletedCount;
    _refreshInsights();
  }

  @override
  void didUpdateWidget(covariant WellnessScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ring.syncCompletedCount != _lastSyncCount) {
      _lastSyncCount = widget.ring.syncCompletedCount;
      _refreshInsights();
    }
  }

  void _refreshInsights() {
    _insights = widget.ring.database.loadCircadianInsights();
  }

  String _circulationLabel(double? pi) {
    if (pi == null) return '—';
    if (pi >= 2.0) return 'Strong (${pi.toStringAsFixed(1)}%)';
    if (pi >= 0.7) return 'Good (${pi.toStringAsFixed(1)}%)';
    return 'Low / cool (${pi.toStringAsFixed(1)}%)';
  }

  ({String title, String explanation}) _warmthSummary(double delta) {
    if (delta >= 0.4) {
      return (
        title: 'Relaxed & warm',
        explanation:
            'Strong blood flow to your fingers — typical when calm, resting, or winding down for sleep.',
      );
    }
    if (delta <= -0.2) {
      return (
        title: 'Cool fingers',
        explanation:
            'Blood is pulling inward — often caused by a cool room, caffeine, or mild stress.',
      );
    }
    return (
      title: 'Balanced',
      explanation: 'Normal, steady daytime circulation and skin warmth.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ring = widget.ring;
    final ppg = ring.ppgAnalyzer;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final tempReply = ring.sensorTemperature;
    final t1 = tempReply?.temperature1 ?? ring.telemetry?.temperature1;
    final t2 = tempReply?.temperature2 ?? ring.telemetry?.temperature2;
    final delta = (t1 != null && t2 != null) ? (t2 - t1) : null;
    final warmth = delta != null ? _warmthSummary(delta) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Heading('Stress Reset'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Slow breathing at 5.5 breaths per minute calms your nervous system and '
                'raises your HRV within minutes. Watch your pulse & calmness react live.',
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
                    'Heart rate',
                    ppg.liveBpm != null
                        ? '${ppg.liveBpm!.toStringAsFixed(0)} bpm'
                        : '—',
                  ),
                  _Stat(
                    'Live HRV',
                    ppg.liveRmssdMs != null
                        ? '${ppg.liveRmssdMs!.toStringAsFixed(0)} ms'
                        : '—',
                  ),
                  _Stat(
                    'Blood flow',
                    _circulationLabel(ppg.perfusionIndexPercent),
                  ),
                ],
              ),
              if (ppg.waveform.isNotEmpty) ...[
                const SizedBox(height: 14),
                Sparkline(
                  points: [
                    for (var i = 0; i < ppg.waveform.length; i++)
                      (x: i, value: ppg.waveform[i]),
                  ],
                  label: 'Live pulse wave',
                  color: colors.primary,
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: ring.connected && !ring.syncing
                    ? () => ring.setDensePpg(!ring.ppgStreaming)
                    : null,
                icon: Icon(
                  ring.ppgStreaming ? Icons.stop_rounded : Icons.air_rounded,
                ),
                label: Text(
                  ring.ppgStreaming
                      ? 'Finish session'
                      : 'Start guided breathing',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Relaxation Check'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stress or cold air pulls blood away from your hands; relaxation warms your '
                'fingers above the room. Use this for a quick check-in.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              if (warmth != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        warmth.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        warmth.explanation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 22,
                runSpacing: 10,
                children: [
                  _Stat(
                    'Finger warmth',
                    t2 != null ? '${t2.toStringAsFixed(1)} °C' : '—',
                  ),
                  _Stat(
                    'Ring exterior',
                    t1 != null ? '${t1.toStringAsFixed(1)} °C' : '—',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: ring.connected && !ring.syncing
                    ? ring.readSensorTemperature
                    : null,
                icon: const Icon(Icons.thermostat_rounded),
                label: const Text('Refresh warmth check'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Sleep Environment & HRV'),
        _Card(
          child: FutureBuilder<CircadianInsights>(
            future: _insights,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Could not load synced insights yet.');
              }
              final data = snapshot.data;
              if (data == null) {
                return const LinearProgressIndicator();
              }
              if (data.epochCount == 0 && data.thermalBlockCount == 0) {
                return Text(
                  'Once your ring syncs, you will see how dark your sleep environment '
                  'really is, overnight light disruptions, and your HRV recovery range.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                );
              }
              final lightVerdict = data.darkLightSpikes == 0
                  ? 'Great — no sudden light interruptions detected during dark rest.'
                  : '${data.darkLightSpikes} sudden light spike${data.darkLightSpikes == 1 ? '' : 's'} during dark rest (phone screen or hallway light can fragment deep sleep).';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your ring’s optical sensor quietly checks bedroom darkness alongside '
                    'your HRV recovery so you can spot hidden sleep disruptors.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 22,
                    runSpacing: 12,
                    children: [
                      _Stat(
                        'Typical HRV',
                        data.hrvMedianMs != null
                            ? '${data.hrvMedianMs} ms'
                            : '—',
                      ),
                      _Stat(
                        'HRV range',
                        data.hrvMinMs != null && data.hrvMaxMs != null
                            ? '${data.hrvMinMs}–${data.hrvMaxMs} ms'
                            : '—',
                      ),
                      _Stat(
                        'Pitch-dark rest',
                        formatDurationHm(data.darkMinutes),
                      ),
                      _Stat(
                        'Daylight / bright',
                        formatDurationHm(data.brightMinutes),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lightVerdict,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: data.darkLightSpikes == 0
                          ? colors.primary
                          : colors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
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

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.14)
          : const Color(0xff1b2623),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? colors.primary : const Color(0xff273530),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: selected ? colors.primary : colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GestureActionRow extends StatelessWidget {
  const _GestureActionRow({
    required this.label,
    required this.gesture,
    required this.selected,
    required this.onChanged,
    required this.onTest,
  });

  final String label;
  final RingGesture gesture;
  final RingDeviceAction selected;
  final ValueChanged<RingDeviceAction> onChanged;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
            IconButton(
              onPressed: selected == RingDeviceAction.none ? null : onTest,
              tooltip: 'Test $label action',
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        DropdownButtonFormField<RingDeviceAction>(
          initialValue: selected,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: [
            for (final action in RingDeviceAction.values)
              DropdownMenuItem(
                value: action,
                child: Text(action.label, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
        const SizedBox(height: 3),
        Text(
          selected.description,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
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
    final inhale = pos < 0.5;
    final phase = inhale ? pos * 2 : (1.0 - pos) * 2;
    final eased = 0.5 - 0.5 * math.cos(phase * math.pi);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              inhale ? 'Breathe in slowly…' : 'Breathe out gently…',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '5.5 breaths/min',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: eased,
            minHeight: 12,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              inhale ? colors.primary : colors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
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
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}
