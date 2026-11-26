import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:ring_protocol/ring_protocol.dart';
import 'package:share_plus/share_plus.dart';

import '../ble/ring_controller.dart';
import '../data/gesture_actions.dart';
import '../data/health_exporter.dart';
import '../data/ring_database.dart';
import 'command_console_screen.dart';
import 'sensor_lab_screen.dart';
import 'settings_screen.dart';
import 'sparkline.dart';

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen>
    with WidgetsBindingObserver {
  int selected = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<RingController>().onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ring = context.watch<RingController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('RingPilot'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      SettingsScreen(ring.healthExporter, ring: ring),
                ),
              );
              final enabled = await ring.database.getAutoHealthExport();
              if (enabled != ring.autoHealthExport) {
                await ring.setAutoHealthExport(enabled);
              }
            },
          ),
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Diagnostics',
              icon: const Icon(Icons.tune),
              onPressed: Scaffold.of(context).openEndDrawer,
            ),
          ),
        ],
      ),
      endDrawer: const _DiagnosticsDrawer(),
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              key: PageStorageKey(selected),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              children: [
                _ConnectionHeader(ring),
                if (ring.message case final message?)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _Notice(icon: Icons.info_outline, text: message),
                  ),
                const SizedBox(height: 22),
                switch (selected) {
                  0 => _HomeScreen(
                    ring,
                    onOpenControl: () => setState(() => selected = 1),
                    onOpenRing: () => setState(() => selected = 3),
                  ),
                  1 => ControlScreen(ring),
                  2 => WellnessScreen(ring),
                  _ => _RingScreen(ring),
                },
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (index) => setState(() => selected = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.touch_app_outlined),
            selectedIcon: Icon(Icons.touch_app_rounded),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa_rounded),
            label: 'Wellness',
          ),
          NavigationDestination(
            icon: Icon(Icons.watch_outlined),
            selectedIcon: Icon(Icons.watch_rounded),
            label: 'Ring',
          ),
        ],
      ),
    );
  }
}

class _ConnectionHeader extends StatelessWidget {
  const _ConnectionHeader(this.ring);
  final RingController ring;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final telemetry = ring.telemetry;
    final stateLabel = switch (ring.state) {
      LinkState.disconnected =>
        ring.reconnecting ? 'Reconnecting automatically…' : 'Not connected',
      LinkState.scanning => 'Searching for nearby rings…',
      LinkState.connecting => 'Connecting…',
      LinkState.subscribing => 'Pairing with ring…',
      LinkState.authenticating => 'Securing connection…',
      LinkState.ready => 'Connected',
    };

    final dotColor = switch (ring.state) {
      LinkState.ready => colors.primary,
      LinkState.disconnected =>
        ring.reconnecting ? colors.secondary : colors.onSurfaceVariant,
      _ => colors.secondary,
    };

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ring.connected
                      ? colors.primary.withValues(alpha: 0.16)
                      : colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.radio_button_unchecked_rounded,
                  size: 24,
                  color: ring.connected
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
                      ring.displayRingName,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            stateLabel,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ring.connected
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                              fontWeight: ring.connected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              switch (ring.state) {
                LinkState.ready => IconButton(
                  onPressed: ring.disconnect,
                  tooltip: 'Disconnect ring',
                  icon: const Icon(Icons.link_off),
                ),
                LinkState.scanning => TextButton(
                  onPressed: ring.stopScan,
                  child: const Text('Stop'),
                ),
                LinkState.disconnected => const SizedBox.shrink(),
                _ => const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              },
            ],
          ),
          if (ring.state == LinkState.disconnected) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (ring.canReconnect)
                  FilledButton.icon(
                    onPressed: ring.reconnect,
                    icon: const Icon(Icons.bluetooth_connected, size: 18),
                    label: const Text('Reconnect'),
                  ),
                OutlinedButton.icon(
                  onPressed: ring.scan,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: Text(ring.canReconnect ? 'Scan for ring' : 'Find Ring'),
                ),
              ],
            ),
          ],
          if (ring.state == LinkState.scanning ||
              ring.state == LinkState.disconnected)
            for (final device in ring.nearby) ...[
              const SizedBox(height: 8),
              Material(
                color: const Color(0xff1b2623),
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(
                    device.source == 'connected'
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    color: colors.primary,
                  ),
                  title: Text(friendlyRingName(device.name)),
                  subtitle: Text(switch (device.source) {
                    'connected' => 'Active on this phone · tap to connect',
                    'bonded' => 'Paired on this phone · tap to connect',
                    _ => 'Nearby smart ring',
                  }),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ring.connect(device),
                ),
              ),
            ],
          if (telemetry != null && ring.connected) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusPill(
                  icon: Icons.battery_std_rounded,
                  label: '${telemetry.batteryPercent}%',
                  highlight: telemetry.batteryPercent > 20,
                ),
                _StatusPill(
                  icon: telemetry.wear == WearState.worn
                      ? Icons.pan_tool_alt_outlined
                      : Icons.do_not_touch_outlined,
                  label: switch (telemetry.wear) {
                    WearState.worn => 'On finger',
                    WearState.offFinger => 'Off finger',
                    WearState.measuring => 'Measuring',
                    WearState.unknown => 'Standby',
                  },
                ),
                _StatusPill(
                  icon: Icons.thermostat_rounded,
                  label: '${telemetry.temperature2.toStringAsFixed(1)} °C',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen(
    this.ring, {
    required this.onOpenControl,
    required this.onOpenRing,
  });

  final RingController ring;
  final VoidCallback onOpenControl;
  final VoidCallback onOpenRing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cfg = ring.gestureConfig;
    final samples = ring.heartRate;
    final latest = samples.lastOrNull?.bpm;

    GesturePreset? activePreset;
    for (final preset in GestureActionConfig.presets) {
      if (preset.matches(cfg)) {
        activePreset = preset;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
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
                          'Ring Gestures',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          activePreset?.title ?? 'Custom actions',
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final preset in GestureActionConfig.presets)
                    ChoiceChip(
                      label: Text(preset.title),
                      selected: preset.matches(cfg),
                      onSelected: (_) => unawaited(
                        ring.updateGestureConfig(cfg.applyPreset(preset)),
                      ),
                    ),
                ],
              ),
              if (ring.lastGestureActionDetail case final detail?) ...[
                const SizedBox(height: 10),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onOpenControl,
                  child: const Text('Customize & automations →'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Live heart rate',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (ring.measuring)
                    _StatusPill(
                      icon: Icons.favorite_rounded,
                      label: 'Live',
                      highlight: true,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    latest?.toString() ?? '—',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'bpm',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (samples.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    ring.measuring
                        ? 'Warming up… keep your hand relaxed.'
                        : ring.connected
                        ? 'Tap below for an instant heart rate reading.'
                        : 'Connect your ring to measure live heart rate.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                )
              else ...[
                const SizedBox(height: 8),
                Sparkline(
                  points: [
                    for (final sample in samples)
                      (
                        x: sample.time.millisecondsSinceEpoch,
                        value: sample.bpm,
                      ),
                  ],
                  label: 'Heart rate trend, latest $latest beats per minute',
                  color: colors.primary,
                ),
                const SizedBox(height: 14),
              ],
              FilledButton.tonalIcon(
                onPressed: ring.connected && !ring.syncing
                    ? () => ring.setHeartRate(!ring.measuring)
                    : null,
                icon: Icon(
                  ring.measuring ? Icons.stop_rounded : Icons.favorite_outline,
                ),
                label: Text(
                  ring.measuring ? 'Stop reading' : 'Measure heart rate',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Health Sync',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: onOpenRing,
                    child: const Text('Details'),
                  ),
                ],
              ),
              if (HealthExporter.supportedPlatform) ...[
                const SizedBox(height: 4),
                _HealthAutoExportFooter(ring),
              ] else
                Text(
                  'Your ring readings sync privately to this device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: ring.connected && !ring.syncing
                    ? ring.syncHistory
                    : null,
                icon: Icon(ring.syncing ? Icons.sync : Icons.download_rounded),
                label: Text(ring.syncing ? 'Syncing ring…' : 'Sync now'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingScreen extends StatelessWidget {
  const _RingScreen(this.ring);
  final RingController ring;

  @override
  Widget build(BuildContext context) {
    final drain = ring.drain;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Health Sync'),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-sync when ring connects'),
                subtitle: const Text(
                  'Automatically fetches new sleep, HRV & skin temperature every 30 min',
                ),
                value: ring.autoSyncHistory,
                onChanged: (v) => unawaited(ring.setAutoSyncHistory(v)),
              ),
              const Divider(height: 20),
              if (drain != null) ...[
                Text(_status(drain.phase), style: theme.textTheme.titleMedium),
                Text('${drain.recordsAcknowledged} readings saved'),
                if (ring.drainDetail case final detail?) Text(detail),
                if (ring.syncing) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
                const SizedBox(height: 14),
              ] else
                StreamBuilder<DrainSession?>(
                  stream: ring.drainHistory,
                  builder: (context, snapshot) {
                    final last = snapshot.data;
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: Text('Could not read previous sync history.'),
                      );
                    }
                    if (last == null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          'No ring history synced yet.',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      );
                    }
                    final completed = last.finishedAt ?? last.startedAt;
                    final local = completed.toLocal();
                    final layout = MaterialLocalizations.of(context);
                    final when =
                        '${layout.formatShortDate(local)}, '
                        '${layout.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last sync · $when',
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            '${last.recordsAcknowledged} readings saved privately on this device',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: ring.connected && !ring.syncing
                        ? ring.syncHistory
                        : null,
                    icon: const Icon(Icons.sync),
                    label: Text(ring.syncing ? 'Syncing…' : 'Sync now'),
                  ),
                  if (ring.syncing)
                    OutlinedButton(
                      onPressed: ring.cancelSync,
                      child: const Text('Cancel'),
                    ),
                ],
              ),
              if (HealthExporter.supportedPlatform) ...[
                const Divider(height: 24),
                _HealthAutoExportFooter(ring),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tip: If you also use another ring app, sync that app first — syncing '
          'advances the ring’s internal history pointer.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeading('Battery Health'),
        StreamBuilder<List<TelemetrySnapshot>>(
          stream: ring.batteryHistory,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _Panel(
                child: Text('Could not load saved battery history.'),
              );
            }
            final samples = snapshot.data ?? const [];
            if (samples.isEmpty) {
              return const _Panel(
                child: Text('Battery trends appear after your ring connects.'),
              );
            }
            final last = samples.last;
            return Column(
              children: [
                _batteryChart(
                  context,
                  samples,
                  title: 'Charge level',
                  reading: '${last.batteryPercent}%',
                  value: (row) => row.batteryPercent,
                  color: colors.primary,
                ),
                const SizedBox(height: 12),
                _batteryChart(
                  context,
                  samples,
                  title: 'Cell health (voltage)',
                  reading: '${last.batteryMillivolts} mV',
                  value: (row) => row.batteryMillivolts,
                  color: colors.secondary,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const _SectionHeading('On-Ring Tracking'),
        _PowerMonitorsPanel(ring),
      ],
    );
  }

  Widget _batteryChart(
    BuildContext context,
    List<TelemetrySnapshot> samples, {
    required String title,
    required String reading,
    required int Function(TelemetrySnapshot) value,
    required Color color,
  }) {
    final layout = MaterialLocalizations.of(context);
    final first = samples.first.capturedAt.toLocal();
    final last = samples.last.capturedAt.toLocal();
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(reading, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Sparkline(
            points: [
              for (var i = 0; i < samples.length; i++)
                (
                  x: samples[i].capturedAt.millisecondsSinceEpoch,
                  value: value(samples[i]),
                ),
            ],
            color: color,
            label: '$title trend. Latest reading $reading.',
          ),
          const SizedBox(height: 8),
          Text(
            samples.length == 1
                ? 'Last reading ${layout.formatShortDate(last)}, ${layout.formatTimeOfDay(TimeOfDay.fromDateTime(last))}'
                : '${samples.length} readings · ${layout.formatShortDate(first)} – ${layout.formatShortDate(last)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _status(DrainPhase phase) => switch (phase) {
    DrainPhase.idle => 'Ready to sync',
    DrainPhase.waiting => 'Downloading health readings…',
    DrainPhase.persisting => 'Saving health readings…',
    DrainPhase.acknowledging => 'Confirming sync…',
    DrainPhase.complete => 'Sync complete',
    DrainPhase.partial => 'Sync finished partially',
    DrainPhase.cancelled => 'Sync cancelled',
    DrainPhase.failed => 'Sync failed',
  };
}

class _PowerMonitorsPanel extends StatelessWidget {
  const _PowerMonitorsPanel(this.ring);
  final RingController ring;

  @override
  Widget build(BuildContext context) {
    final busy = ring.pendingParam != null;
    final canEdit = ring.canSendCommands && !busy;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!ring.connected)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Connect your ring to manage on-ring background tracking.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          _paramToggle(
            title: 'Automatic workout detection',
            subtitle: 'Detects walks, runs, and workouts on the ring',
            value: (ring.paramValue(RingParam.autoSports) ?? 0) != 0,
            enabled: canEdit,
            onChanged: (on) =>
                ring.setRingParam(RingParam.autoSports, on ? 1 : 0),
          ),
          _paramToggle(
            title: 'High-detail sleep tracking',
            subtitle: 'Records high-resolution optical sleep data overnight',
            value: (ring.paramValue(RingParam.sleepProPpg) ?? 0) != 0,
            enabled: canEdit,
            onChanged: (on) =>
                ring.setRingParam(RingParam.sleepProPpg, on ? 1 : 0),
          ),
          _paramToggle(
            title: 'Overnight blood pressure insights',
            subtitle: 'Background overnight cardiovascular tracking',
            value: (ring.paramValue(RingParam.autoBloodPressure) ?? 0) != 0,
            enabled: canEdit,
            onChanged: (on) =>
                ring.setRingParam(RingParam.autoBloodPressure, on ? 1 : 0),
          ),
          _paramToggle(
            title: 'Sleep breathing monitor',
            subtitle: 'Overnight breathing disturbance monitoring',
            value: (ring.paramValue(RingParam.osaPlan) ?? 0) == 1,
            enabled: canEdit,
            onChanged: (on) => ring.setRingParam(RingParam.osaPlan, on ? 1 : 0),
          ),
        ],
      ),
    );
  }

  Widget _paramToggle({
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: Text(subtitle),
    value: value,
    onChanged: enabled ? onChanged : null,
  );
}

class _DiagnosticsDrawer extends StatefulWidget {
  const _DiagnosticsDrawer();

  @override
  State<_DiagnosticsDrawer> createState() => _DiagnosticsDrawerState();
}

class _DiagnosticsDrawerState extends State<_DiagnosticsDrawer> {
  bool exporting = false;

  @override
  Widget build(BuildContext context) {
    final ring = context.watch<RingController>();
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Diagnostics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close diagnostics',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ring.firmware case final firmware?)
              _Metric('Firmware', firmware),
            if (ring.writeLimit case final limit?)
              _Metric('ATT write limit', '$limit bytes'),
            if (ring.bond case final bond?) _Metric('Bluetooth bond', bond),
            if (ring.authStatus case final auth?) ...[
              _Metric('Eco mode', '${auth.ecoMode}'),
              _Metric('Auto-sports', auth.sportsMonitor ? 'On' : 'Off'),
              _Metric('Ring MTU', '${auth.mtu} bytes'),
            ],
            if (ring.connected)
              _Metric(
                'Bytes skipped by decoder',
                ring.discardedBytes.toString(),
              ),
            const Divider(height: 32),
            OutlinedButton.icon(
              onPressed: ring.connected && !ring.syncing
                  ? ring.forceStopModes
                  : null,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Force-stop modes'),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (buttonContext) => OutlinedButton.icon(
                onPressed: exporting
                    ? null
                    : () => _export(buttonContext, ring),
                icon: const Icon(Icons.ios_share),
                label: Text(
                  exporting ? 'Preparing trace…' : 'Export raw trace',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The latest connection trace may include health readings.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.terminal),
              label: const Text('Command console'),
              onPressed: () {
                final navigator = Navigator.of(context);
                Scaffold.of(context).closeEndDrawer();
                navigator.push<void>(
                  MaterialPageRoute(builder: (_) => CommandConsoleScreen(ring)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, RingController ring) async {
    final box = context.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;
    setState(() => exporting = true);
    try {
      final trace = await ring.exportTrace();
      if (!context.mounted) return;
      if (trace == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No trace captured yet.')));
      } else {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(trace.path, mimeType: 'application/x-ndjson')],
            sharePositionOrigin: origin,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not export trace. $error')),
        );
      }
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? colors.primary.withValues(alpha: 0.14)
            : const Color(0xff1d2724),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: highlight ? colors.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: highlight ? colors.primary : colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: child),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
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
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: colors.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthAutoExportFooter extends StatelessWidget {
  const _HealthAutoExportFooter(this.ring);

  final RingController ring;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status =
        ring.healthExportStatus ??
        (ring.autoHealthExport
            ? 'Auto-export to Android Health Connect is on.'
            : 'Auto-export to Android Health Connect is paused.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (ring.healthExporting)
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  ring.healthNeedsPermission
                      ? Icons.health_and_safety_outlined
                      : Icons.monitor_heart_outlined,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
              ),
            Expanded(
              child: Text(status, style: theme.textTheme.bodySmall),
            ),
          ],
        ),
        if (ring.healthNeedsPermission && !ring.healthExporting) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ring.exportToHealthConnect(interactive: true),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Enable Android Health Connect'),
          ),
        ],
      ],
    );
  }
}
