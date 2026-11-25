import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:ring_protocol/ring_protocol.dart';

import '../ble/ring_controller.dart';
import '../data/gesture_actions.dart';
import 'sparkline.dart';

/// Live sensor lab & hidden-channel explorer for unused ring hardware:
/// - `06 05 00` -> `0x12`: 4-ch optical PPG biofeedback (live BPM, RMSSD, PI%)
/// - `23 03 00` -> `0x13`: 25 Hz 3-axis accelerometer & system-wide gestures
/// - `29 00 00` -> `0xa9`: live dual-NTC thermal gradient
/// - `0x4c` / `0x47` SQLite history: hidden 30 s ambient light & thermal delta
class SensorLabScreen extends StatefulWidget {
  const SensorLabScreen(this.ring, {super.key});

  final RingController ring;

  @override
  State<SensorLabScreen> createState() => _SensorLabScreenState();
}

class _SensorLabScreenState extends State<SensorLabScreen>
    with WidgetsBindingObserver {
  Future<CircadianInsights>? _insights;
  String? _insightsDevice;
  late final TextEditingController _webhookController;
  late final TextEditingController _eventWebhookController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _webhookController = TextEditingController(
      text: widget.ring.gestureConfig.webhookUrl,
    );
    _eventWebhookController = TextEditingController(
      text: widget.ring.smartConfig.eventWebhookUrl,
    );
    _refreshInsights();
    unawaited(widget.ring.refreshAccessibilityStatus());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.ring.refreshAccessibilityStatus());
    }
  }

  @override
  void didUpdateWidget(covariant SensorLabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ring.deviceId != _insightsDevice) {
      _refreshInsights();
    }
    final storedUrl = widget.ring.gestureConfig.webhookUrl;
    if (_webhookController.text != storedUrl &&
        _webhookController.text.isEmpty) {
      _webhookController.text = storedUrl;
    }
    final storedEventUrl = widget.ring.smartConfig.eventWebhookUrl;
    if (_eventWebhookController.text != storedEventUrl &&
        _eventWebhookController.text.isEmpty) {
      _eventWebhookController.text = storedEventUrl;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _webhookController.dispose();
    _eventWebhookController.dispose();
    super.dispose();
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
    final cfg = ring.gestureConfig;
    final smart = ring.smartConfig;
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
        const _Heading('Hands-Free & Auto-Connect'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connect automatically to your saved ring without scanning, '
                'or add the "Ring Control" tile to Android Quick Settings to '
                'toggle gestures from your notification shade.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-connect saved ring on launch'),
                subtitle: const Text(
                  'Connects directly to your remembered ring without scanning',
                ),
                value: ring.autoConnect,
                onChanged: (v) => unawaited(ring.setAutoConnect(v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-arm gestures on connect'),
                subtitle: const Text(
                  'Automatically starts 25 Hz Gesture Control + background '
                  'service as soon as the ring connects',
                ),
                value: cfg.autoStartGestures,
                onChanged: (v) => unawaited(
                  ring.updateGestureConfig(cfg.copyWith(autoStartGestures: v)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('Always-On Ring Automations'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Powered by passive 0x11 hardware events & 0x10 telemetry '
                '(wear state, battery mV, dual-NTC thermal delta) — zero extra '
                'ring battery drain.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pause media when ring comes off'),
                subtitle: const Text(
                  'Taking your ring off pauses Spotify, YouTube, or podcasts',
                ),
                value: smart.ringOffPauseMedia,
                onChanged: (v) => unawaited(
                  ring.updateSmartConfig(smart.copyWith(ringOffPauseMedia: v)),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Doze-off thermal media pause'),
                subtitle: const Text(
                  'Pauses playback when sustained skin vasodilation (+0.5 °C Δ) '
                  'signals sleep onset',
                ),
                value: smart.dozeOffPauseMedia,
                onChanged: (v) => unawaited(
                  ring.updateSmartConfig(smart.copyWith(dozeOffPauseMedia: v)),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Broadcast live biometrics'),
                subtitle: const Text(
                  'Emits ACTION_RING_EVENT (HR, HRV, PI%, temp, battery, wear) '
                  'for Tasker, KWGT, or overlays',
                ),
                value: smart.broadcastBiometrics,
                onChanged: (v) => unawaited(
                  ring.updateSmartConfig(
                    smart.copyWith(broadcastBiometrics: v),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Don't-forget-ring reminder (off finger & not charging)",
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
                'Pre-bed low-battery alert',
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
              const SizedBox(height: 14),
              TextField(
                controller: _eventWebhookController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Event webhook URL (Home Assistant / IFTTT)',
                  hintText: 'Optional: receives ring_off, ring_on, low_battery',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (url) => unawaited(
                  ring.updateSmartConfig(smart.copyWith(eventWebhookUrl: url)),
                ),
              ),
              if (ring.lastAutomationDetail case final autoDetail?) ...[
                const SizedBox(height: 10),
                Text(
                  'Last event: $autoDetail',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
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
                  _Stat('Optical taps', '${ppg.opticalTapCount}'),
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
              DropdownButtonFormField<RingDeviceAction>(
                initialValue: smart.opticalTapAction,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Fast 400 ms optical cover-tap action',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: [
                  for (final action in RingDeviceAction.values)
                    DropdownMenuItem(
                      value: action,
                      child: Text(
                        action.requiresAccessibility
                            ? '${action.label} (Accessibility)'
                            : action.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
              const SizedBox(height: 6),
              Text(
                'Briefly cover or tap over the optical window while streaming '
                'PPG — 0x12 sends every 400 ms (2.5× faster than 0x13).',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
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
                'Separates crisp positive finger impacts (taps & double taps) '
                'from sustained 3D hand rotations ≥ ${acc.flickAngleDeg.toStringAsFixed(0)}° '
                '(wrist flicks) — so hard double taps never misfire as flicks.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _Stat(
                    'Impact',
                    acc.latestImpulseG != null
                        ? '${acc.latestImpulseG!.toStringAsFixed(2)} g'
                        : '—',
                  ),
                  _Stat(
                    'Rotation',
                    '${acc.latestAngleDeg.toStringAsFixed(0)}°',
                  ),
                  _Stat(
                    'Threshold',
                    '${acc.tapThresholdG.toStringAsFixed(2)} g',
                  ),
                  _Stat('Taps', '${acc.tapCount}'),
                  _Stat('Double taps', '${acc.doubleTapCount}'),
                  _Stat('Wrist flicks', '${acc.flickCount}'),
                  _Stat('Reps', '${acc.repCount}'),
                ],
              ),
              if (acc.latestSample != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Pitch ${acc.pitchDeg.toStringAsFixed(0)}°  •  '
                  'Roll ${acc.rollDeg.toStringAsFixed(0)}°'
                  '${acc.lastGesture != null ? '  •  Last: ${acc.lastGesture!.gesture.label}' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ],
              if (acc.impulseTrace.isNotEmpty) ...[
                const SizedBox(height: 12),
                Sparkline(
                  points: [
                    for (var i = 0; i < acc.impulseTrace.length; i++)
                      (x: i, value: acc.impulseTrace[i]),
                  ],
                  label: 'Live 25 Hz positive impact (g) with tap threshold',
                  color: colors.secondary,
                  threshold: acc.tapThresholdG,
                  thresholdColor: colors.primary,
                  minValue: 0,
                  maxValue: 1.6,
                ),
                const SizedBox(height: 4),
                Text(
                  'Dashed line = tap threshold (${acc.tapThresholdG.toStringAsFixed(2)} g). '
                  'Wrist flicks require rotating your hand ≥ ${acc.flickAngleDeg.toStringAsFixed(0)}°.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                'Sensitivity',
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
                      label: Text(
                        '${level.label} (${level.tapThresholdG.toStringAsFixed(2)}g)',
                      ),
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
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
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
                  if (acc.repCount > 0)
                    TextButton.icon(
                      onPressed: ring.resetWorkoutReps,
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Reset reps'),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _Heading('System-Wide Device Control'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ring.deviceActions.supported
                    ? 'Map ring gestures to Android actions that work across '
                          'Spotify, YouTube, Camera, Kindle, Tasker, or Home '
                          'Assistant — even in the background or with the screen off.'
                    : 'System-wide Android device actions (media, flashlight, '
                          'scroll, webhooks) are available on Android. On macOS, '
                          'use the CLI --gestures hooks.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '1-Tap Presets',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final preset in GestureActionConfig.presets)
                    ChoiceChip(
                      label: Text(preset.title),
                      tooltip: preset.subtitle,
                      selected: preset.matches(cfg),
                      onSelected: (_) => unawaited(
                        ring.updateGestureConfig(cfg.applyPreset(preset)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Trigger device actions'),
                subtitle: const Text(
                  'Run mapped actions whenever the gesture stream detects a gesture',
                ),
                value: cfg.actionsEnabled,
                onChanged: (value) => unawaited(
                  ring.updateGestureConfig(cfg.copyWith(actionsEnabled: value)),
                ),
              ),
              if (ring.deviceActions.supported) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Keep active in background'),
                  subtitle: const Text(
                    'Runs an Android foreground notification so gestures keep '
                    'working in other apps and when the screen is off',
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
                  title: const Text('Haptic confirmation'),
                  subtitle: const Text(
                    'Vibrate phone subtly when a gesture triggers an action',
                  ),
                  value: cfg.hapticFeedback,
                  onChanged: (value) => unawaited(
                    ring.updateGestureConfig(
                      cfg.copyWith(hapticFeedback: value),
                    ),
                  ),
                ),
              ],
              const Divider(height: 24),
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
                const SizedBox(height: 14),
                TextField(
                  controller: _webhookController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Webhook URL (POST JSON)',
                    hintText: 'http://homeassistant.local:8123/api/webhook/...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (url) => unawaited(
                    ring.updateGestureConfig(cfg.copyWith(webhookUrl: url)),
                  ),
                ),
              ],
              if (ring.deviceActions.supported && cfg.usesAccessibility) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ring.accessibilityEnabled
                        ? colors.primaryContainer.withValues(alpha: 0.45)
                        : colors.secondaryContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ring.accessibilityEnabled
                            ? 'Accessibility service active — scroll, swipe, back, and screenshot are ready.'
                            : 'Scroll, swipe, back, and screenshot need the optional Ring Companion Accessibility service (never reads screen content).',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (!ring.accessibilityEnabled)
                            FilledButton.tonalIcon(
                              onPressed: () => unawaited(
                                ring.openAccessibilitySettings(),
                              ),
                              icon: const Icon(Icons.accessibility_new, size: 18),
                              label: const Text('Enable Accessibility'),
                            ),
                          TextButton.icon(
                            onPressed: () => unawaited(
                              ring.refreshAccessibilityStatus(),
                            ),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Check status'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (ring.lastGestureActionDetail case final detail?) ...[
                const SizedBox(height: 12),
                Text(
                  'Last action: $detail',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                  action.requiresAccessibility
                      ? '${action.label} (Accessibility)'
                      : action.label,
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
              inhale ? 'Inhale slowly (5.5 s)' : 'Exhale gently (5.5 s)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
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
            value: eased.clamp(0.04, 1.0),
            minHeight: 10,
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
