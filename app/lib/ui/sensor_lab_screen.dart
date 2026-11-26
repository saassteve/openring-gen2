import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:ring_protocol/ring_protocol.dart';

import '../ble/ring_controller.dart';
import '../data/gesture_actions.dart';
import 'sparkline.dart';

/// Consumer-friendly Gestures & Smart Automations tab.
class ControlScreen extends StatefulWidget {
  const ControlScreen(this.ring, {super.key});

  final RingController ring;

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late final TextEditingController _webhookController;
  late final TextEditingController _eventWebhookController;

  @override
  void initState() {
    super.initState();
    _webhookController = TextEditingController(
      text: widget.ring.gestureConfig.webhookUrl,
    );
    _eventWebhookController = TextEditingController(
      text: widget.ring.smartConfig.eventWebhookUrl,
    );
    unawaited(widget.ring.refreshAccessibilityStatus());
  }

  @override
  void didUpdateWidget(covariant ControlScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final url = widget.ring.gestureConfig.webhookUrl;
    if (_webhookController.text != url) _webhookController.text = url;
    final eventUrl = widget.ring.smartConfig.eventWebhookUrl;
    if (_eventWebhookController.text != eventUrl) {
      _eventWebhookController.text = eventUrl;
    }
  }

  @override
  void dispose() {
    _webhookController.dispose();
    _eventWebhookController.dispose();
    super.dispose();
  }

  IconData _presetIcon(String id) => switch (id) {
    'music' => Icons.music_note_rounded,
    'finder' => Icons.notifications_active_rounded,
    'camera' => Icons.camera_alt_rounded,
    'reader' => Icons.menu_book_rounded,
    _ => Icons.touch_app_rounded,
  };

  String _sensitivityLabel(GestureSensitivity s) => switch (s) {
    GestureSensitivity.high => 'Gentle',
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
        const _Heading('Ring Control'),
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
                              ? 'Ring gestures active'
                              : 'Ring gestures paused',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          ring.accStreaming
                              ? cfg.notificationSummary
                              : 'Double-tap or flick your wrist to control your phone',
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
                'Choose a mode',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  for (final preset in GestureActionConfig.presets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PresetTile(
                        icon: _presetIcon(preset.id),
                        title: preset.title,
                        subtitle: preset.subtitle,
                        selected: preset.matches(cfg),
                        onTap: () => unawaited(
                          ring.updateGestureConfig(cfg.applyPreset(preset)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap sensitivity',
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
                        'One-time Android permission needed for Camera Shutter & Scrolling.',
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
                            child: const Text('Enable in Android Settings'),
                          ),
                          TextButton(
                            onPressed: ring.refreshAccessibilityStatus,
                            child: const Text('Check status'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Customize gestures & motion monitor'),
            subtitle: Text(
              'Map individual taps, test actions, or view live motion',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Wrap(
                spacing: 18,
                runSpacing: 10,
                children: [
                  _Stat(
                    'Impact',
                    acc.latestImpulseG != null
                        ? '${acc.latestImpulseG!.toStringAsFixed(2)} g'
                        : '—',
                  ),
                  _Stat('Rotation', '${acc.latestAngleDeg.toStringAsFixed(0)}°'),
                  _Stat('Taps', '${acc.tapCount}'),
                  _Stat('Double taps', '${acc.doubleTapCount}'),
                  _Stat('Flicks', '${acc.flickCount}'),
                  _Stat('Reps', '${acc.repCount}'),
                ],
              ),
              if (acc.impulseTrace.isNotEmpty) ...[
                const SizedBox(height: 12),
                Sparkline(
                  points: [
                    for (var i = 0; i < acc.impulseTrace.length; i++)
                      (x: i, value: acc.impulseTrace[i]),
                  ],
                  label: 'Live finger impact with tap threshold',
                  color: colors.secondary,
                  threshold: acc.tapThresholdG,
                  thresholdColor: colors.primary,
                  minValue: 0,
                  maxValue: 1.6,
                ),
                const SizedBox(height: 4),
                Text(
                  'Dashed line = tap threshold (${acc.tapThresholdG.toStringAsFixed(2)} g). '
                  'Wrist flicks need ≥ ${acc.flickAngleDeg.toStringAsFixed(0)}° rotation.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (acc.repCount > 0) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: ring.resetWorkoutReps,
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text('Reset workout reps'),
                  ),
                ),
              ],
              const Divider(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Trigger phone actions'),
                value: cfg.actionsEnabled,
                onChanged: (value) => unawaited(
                  ring.updateGestureConfig(cfg.copyWith(actionsEnabled: value)),
                ),
              ),
              if (ring.deviceActions.supported) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Work in background & screen off'),
                  value: cfg.backgroundService,
                  onChanged: (value) => unawaited(
                    ring.updateGestureConfig(
                      cfg.copyWith(backgroundService: value),
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Subtle phone vibration on gesture'),
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
                onTest: () => unawaited(ring.testGestureAction(RingGesture.tap)),
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
                label: 'Wrist flick',
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
                    labelText: 'Gesture webhook URL',
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
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Hands-Free Automations'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Runs automatically in the background with virtually zero extra ring battery use. '
                'Tip: add the RingPilot tile to Android Quick Settings to toggle gestures from anywhere.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-connect on launch'),
                subtitle: const Text(
                  'Reconnects automatically without scanning',
                ),
                value: ring.autoConnect,
                onChanged: (v) => unawaited(ring.setAutoConnect(v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-enable gestures when connected'),
                subtitle: const Text(
                  'Starts your active preset as soon as the ring links',
                ),
                value: cfg.autoStartGestures,
                onChanged: (v) => unawaited(
                  ring.updateGestureConfig(cfg.copyWith(autoStartGestures: v)),
                ),
              ),
              const Divider(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pause media when ring comes off'),
                subtitle: const Text(
                  'Taking your ring off pauses music, videos, or podcasts',
                ),
                value: smart.ringOffPauseMedia,
                onChanged: (v) => unawaited(
                  ring.updateSmartConfig(smart.copyWith(ringOffPauseMedia: v)),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pause media when you fall asleep'),
                subtitle: const Text(
                  'Detects sleep-onset warmth on your finger and pauses playback',
                ),
                value: smart.dozeOffPauseMedia,
                onChanged: (v) => unawaited(
                  ring.updateSmartConfig(smart.copyWith(dozeOffPauseMedia: v)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Don't-forget-your-ring reminder",
                style: theme.textTheme.labelMedium?.copyWith(
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
                      label: Text(mins == 0 ? 'Off' : '$mins min'),
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
              const SizedBox(height: 12),
              Text(
                'Bedtime low-battery reminder',
                style: theme.textTheme.labelMedium?.copyWith(
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
                      label: Text(pct == 0 ? 'Off' : '≤ $pct%'),
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
                const SizedBox(height: 10),
                Text(
                  'Latest: $autoDetail',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            leading: const Icon(Icons.hub_outlined),
            title: const Text('Smart home & Tasker integrations'),
            subtitle: Text(
              'Optional Home Assistant webhooks & Android broadcasts',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Broadcast live events for Tasker / KWGT'),
                subtitle: const Text(
                  'Sends heart rate, HRV, wear state, and battery events locally',
                ),
                value: smart.broadcastBiometrics,
                onChanged: (v) => unawaited(
                  ring.updateSmartConfig(
                    smart.copyWith(broadcastBiometrics: v),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _eventWebhookController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Home Assistant / IFTTT webhook URL',
                  hintText: 'Optional: receives ring_off, ring_on, low_battery',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (url) => unawaited(
                  ring.updateSmartConfig(smart.copyWith(eventWebhookUrl: url)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Consumer-friendly Breathing, Live HRV & Recovery Insights tab.
class WellnessScreen extends StatefulWidget {
  const WellnessScreen(this.ring, {super.key});

  final RingController ring;

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  late Future<CircadianInsights> _insights;

  @override
  void initState() {
    super.initState();
    _refreshInsights();
  }

  void _refreshInsights() {
    _insights = widget.ring.database.loadCircadianInsights();
  }

  @override
  Widget build(BuildContext context) {
    final ring = widget.ring;
    final ppg = ring.ppgAnalyzer;
    final smart = ring.smartConfig;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final tempReply = ring.sensorTemperature;
    final t1 = tempReply?.temperature1 ?? ring.telemetry?.temperature1;
    final t2 = tempReply?.temperature2 ?? ring.telemetry?.temperature2;
    final gradient = (t1 != null && t2 != null)
        ? ThermalGradient(ntc1: t1, ntc2: t2)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Heading('Guided Breathing & HRV'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Follow the 5.5-second breathing pacer while watching your live heart rate, '
                'HRV, and finger circulation respond in real time.',
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
                    'Circulation',
                    ppg.perfusionIndexPercent != null
                        ? '${ppg.perfusionIndexPercent!.toStringAsFixed(2)}%'
                        : '—',
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
                  label: 'Live pulse waveform',
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
                      ? 'End breathing session'
                      : 'Start breathing session',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RingDeviceAction>(
                initialValue: smart.opticalTapAction,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Quick ring cover-tap during session',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final action in [
                    RingDeviceAction.none,
                    RingDeviceAction.mediaPlayPause,
                    RingDeviceAction.mediaNext,
                    RingDeviceAction.toggleFlashlight,
                    RingDeviceAction.findPhone,
                  ])
                    DropdownMenuItem(value: action, child: Text(action.label)),
                ],
                onChanged: (next) {
                  if (next != null) {
                    unawaited(
                      ring.updateSmartConfig(
                        smart.copyWith(opticalTapAction: next),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Temperature Balance'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compares inner finger warmth with outer ring temperature — a quick indicator '
                'of relaxation and circulation.',
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
                    'Skin temp',
                    t2 != null ? '${t2.toStringAsFixed(2)} °C' : '—',
                  ),
                  _Stat(
                    'Outer shell',
                    t1 != null ? '${t1.toStringAsFixed(2)} °C' : '—',
                  ),
                  _Stat(
                    'Balance',
                    gradient != null
                        ? '${gradient.delta >= 0 ? '+' : ''}${gradient.delta.toStringAsFixed(2)} °C'
                        : '—',
                  ),
                ],
              ),
              if (gradient != null) ...[
                const SizedBox(height: 8),
                Text(
                  gradient.stateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: ring.connected && !ring.syncing
                    ? ring.readSensorTemperature
                    : null,
                icon: const Icon(Icons.thermostat_rounded),
                label: const Text('Check temperature now'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Light & Recovery Insights'),
        _Card(
          child: FutureBuilder<CircadianInsights>(
            future: _insights,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Could not load local history insights.');
              }
              final data = snapshot.data;
              if (data == null) {
                return const LinearProgressIndicator();
              }
              if (data.epochCount == 0 && data.thermalBlockCount == 0) {
                return Text(
                  'Sync your ring in the Ring tab to see dark-sleep hygiene, '
                  'overnight light disruptions, and your full HRV range.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyzed privately on your phone from ${data.epochCount} readings.',
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
                        'Dark sleep time',
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
                      _Stat('Night light spikes', '${data.darkLightSpikes}'),
                      _Stat(
                        'HRV range',
                        data.hrvMedianMs != null
                            ? '${data.hrvMinMs}–${data.hrvMaxMs} ms (med ${data.hrvMedianMs})'
                            : '—',
                      ),
                      _Stat(
                        'Avg warmth Δ',
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
                    label: const Text('Refresh insights'),
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
                Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
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
            Expanded(
              child: Text(label, style: theme.textTheme.titleSmall),
            ),
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
                child: Text(
                  action.label,
                  overflow: TextOverflow.ellipsis,
                ),
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
              inhale ? 'Inhale slowly…' : 'Exhale gently…',
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
