import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:ring_protocol/ring_protocol.dart';
import 'package:share_plus/share_plus.dart';

import '../ble/ring_controller.dart';
import '../data/health_exporter.dart';
import '../data/ring_database.dart';
import 'command_console_screen.dart';
import 'settings_screen.dart';
import 'sparkline.dart';

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final ring = context.watch<RingController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ring Companion'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(ring.healthExporter),
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _ConnectionHeader(ring),
                if (ring.message case final message?)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _Notice(icon: Icons.info_outline, text: message),
                  ),
                const SizedBox(height: 28),
                switch (selected) {
                  0 => _LiveScreen(ring),
                  1 => _HistoryScreen(ring),
                  _ => _BatteryScreen(ring),
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
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Live',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.battery_5_bar_outlined),
            label: 'Battery',
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
    final colors = Theme.of(context).colorScheme;
    final telemetry = ring.telemetry;
    final stateLabel = switch (ring.state) {
      LinkState.disconnected => 'Disconnected',
      LinkState.scanning => 'Scanning for nearby rings',
      LinkState.connecting => 'Connecting',
      LinkState.subscribing => 'Bluetooth pairing or subscription',
      LinkState.authenticating => 'Authenticating',
      LinkState.ready => 'Connected',
    };
    final ringName = ring.name ?? 'RingConn Gen 2';
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: const Icon(Icons.radio_button_unchecked, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ringName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      stateLabel,
                      style: TextStyle(
                        color: ring.connected
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              switch (ring.state) {
                LinkState.disconnected => FilledButton.tonal(
                  onPressed: ring.scan,
                  child: const Text('Scan'),
                ),
                LinkState.scanning => TextButton(
                  onPressed: ring.stopScan,
                  child: const Text('Stop'),
                ),
                LinkState.ready => IconButton(
                  onPressed: ring.disconnect,
                  tooltip: 'Disconnect ring',
                  icon: const Icon(Icons.link_off),
                ),
                _ => const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              },
            ],
          ),
          if (ring.state == LinkState.scanning ||
              ring.state == LinkState.disconnected)
            for (final device in ring.nearby)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bluetooth),
                title: Text(device.name),
                subtitle: Text('${device.rssi} dBm'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ring.connect(device),
              ),
          if (telemetry != null && ring.connected) ...[
            const Divider(height: 28),
            Wrap(
              spacing: 22,
              runSpacing: 12,
              children: [
                _Metric('Battery', '${telemetry.batteryPercent}%'),
                _Metric('Voltage', '${telemetry.batteryMillivolts} mV'),
                _Metric(
                  'Temp 1',
                  '${telemetry.temperature1.toStringAsFixed(1)} °C',
                ),
                _Metric(
                  'Temp 2',
                  '${telemetry.temperature2.toStringAsFixed(1)} °C',
                ),
                _Metric('Wear', switch (telemetry.wear) {
                  WearState.worn => 'Worn',
                  WearState.offFinger => 'Off finger',
                  WearState.measuring => 'Measuring',
                  WearState.unknown => 'Unknown (${telemetry.wearCode})',
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LiveScreen extends StatelessWidget {
  const _LiveScreen(this.ring);
  final RingController ring;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final samples = ring.heartRate;
    final latest = samples.lastOrNull?.bpm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Live heart rate'),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    latest?.toString() ?? '—',
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(width: 8),
                  Text('bpm', style: theme.textTheme.titleMedium),
                ],
              ),
              if (samples.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    ring.measuring
                        ? 'Warming up. Keep the ring still on your finger.'
                        : 'Connect your ring and start a reading.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              else ...[
                Sparkline(
                  points: [
                    for (final sample in samples)
                      (
                        x: sample.time.millisecondsSinceEpoch,
                        value: sample.bpm,
                      ),
                  ],
                  label: 'Heart rate trend, latest $latest beats per minute',
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 14),
              ],
              FilledButton.icon(
                onPressed: ring.connected && !ring.syncing
                    ? () => ring.setHeartRate(!ring.measuring)
                    : null,
                icon: Icon(ring.measuring ? Icons.stop : Icons.play_arrow),
                label: Text(ring.measuring ? 'Stop reading' : 'Start reading'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryScreen extends StatelessWidget {
  const _HistoryScreen(this.ring);
  final RingController ring;

  @override
  Widget build(BuildContext context) {
    final drain = ring.drain;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('History sync'),
        const _Notice(
          icon: Icons.warning_amber_rounded,
          text:
              'Sync the official app first if you need this history there. '
              'Saving pages here advances the ring’s shared sync position.',
        ),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (drain != null) ...[
                Text(
                  _status(drain.phase),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('${drain.recordsAcknowledged} records acknowledged'),
                if (ring.drainDetail case final detail?) Text(detail),
                if (ring.syncing) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      _Metric(
                        'Epochs remaining',
                        drain.remaining[HistoryStream.epochs]?.toString() ??
                            '—',
                      ),
                      _Metric(
                        'Thermal blocks remaining',
                        drain.remaining[HistoryStream.thermal]?.toString() ??
                            '—',
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
              ] else
                StreamBuilder<DrainSession?>(
                  stream: ring.drainHistory,
                  builder: (context, snapshot) {
                    final last = snapshot.data;
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text('Could not load the previous sync.'),
                      );
                    }
                    if (last == null) return const SizedBox.shrink();
                    final phase = DrainPhase.values
                        .where((value) => value.name == last.state)
                        .firstOrNull;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phase == null
                                ? 'Previous sync interrupted'
                                : _status(phase),
                          ),
                          Text(
                            '${last.recordsAcknowledged} records acknowledged',
                          ),
                          if (last.detail case final detail?) Text(detail),
                        ],
                      ),
                    );
                  },
                ),
              if (ring.syncing)
                OutlinedButton(
                  onPressed: ring.cancelSync,
                  child: const Text('Stop sync'),
                )
              else
                FilledButton.icon(
                  onPressed: ring.connected ? () => _confirm(context) : null,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync ring history'),
                ),
              if (HealthExporter.supportedPlatform) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _HealthAutoExportFooter(ring),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _status(DrainPhase phase) => switch (phase) {
    DrainPhase.idle => 'Ready to sync',
    DrainPhase.waiting ||
    DrainPhase.persisting ||
    DrainPhase.acknowledging => 'Syncing history',
    DrainPhase.complete => 'Sync complete',
    DrainPhase.partial => 'Partial sync',
    DrainPhase.failed => 'Sync interrupted',
    DrainPhase.cancelled => 'Sync stopped',
  };

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync from the ring?'),
        content: const Text(
          'Sync the official app first if you want this backlog available there.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sync history'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await ring.syncHistory();
  }
}

class _BatteryScreen extends StatelessWidget {
  const _BatteryScreen(this.ring);
  final RingController ring;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Battery'),
        StreamBuilder<List<TelemetrySnapshot>>(
          stream: ring.batteryHistory,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _Panel(
                child: Text('Could not load stored battery readings.'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _Panel(child: LinearProgressIndicator());
            }
            final samples = snapshot.data ?? [];
            final last = samples.lastOrNull;
            if (last == null) {
              return const _Panel(
                child: Text('Battery readings appear after the ring connects.'),
              );
            }
            final colors = Theme.of(context).colorScheme;
            return Column(
              children: [
                _batteryChart(
                  context,
                  samples,
                  title: 'Charge',
                  reading: '${last.batteryPercent}%',
                  value: (row) => row.batteryPercent,
                  color: colors.primary,
                ),
                const SizedBox(height: 12),
                _batteryChart(
                  context,
                  samples,
                  title: 'Voltage',
                  reading: '${last.batteryMillivolts} mV',
                  value: (row) => row.batteryMillivolts,
                  color: colors.secondary,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        const _SectionHeading('Power & background monitors'),
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
          ),
        ],
      ),
    );
  }
}


class _PowerMonitorsPanel extends StatelessWidget {
  const _PowerMonitorsPanel(this.ring);
  final RingController ring;

  @override
  Widget build(BuildContext context) {
    final auth = ring.authStatus;
    final busy = ring.pendingParam != null;
    final canEdit = ring.canSendCommands && !busy;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (auth != null) ...[
            _Metric('Eco mode', '${auth.ecoMode}'),
            _Metric('Ring MTU', '${auth.mtu} bytes'),
            _Metric('Monitor status', '${auth.monitorStatus}'),
            const Divider(height: 24),
          ] else
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Connect to read active ring flags and toggle background monitors.',
              ),
            ),
          _paramToggle(
            param: RingParam.autoSports,
            subtitle: '05 23 · flash-backed auto workout detection',
            value: (ring.paramValue(RingParam.autoSports) ?? 0) != 0,
            enabled: canEdit,
            onChanged: (on) =>
                ring.setRingParam(RingParam.autoSports, on ? 1 : 0),
          ),
          _paramToggle(
            param: RingParam.sleepProPpg,
            subtitle: '05 24 · Sleep Pro compressed PPG storage',
            value: (ring.paramValue(RingParam.sleepProPpg) ?? 0) != 0,
            enabled: canEdit,
            onChanged: (on) =>
                ring.setRingParam(RingParam.sleepProPpg, on ? 1 : 0),
          ),
          _paramToggle(
            param: RingParam.autoBloodPressure,
            subtitle: '05 25 · automatic offline BP assessment',
            value: (ring.paramValue(RingParam.autoBloodPressure) ?? 0) != 0,
            enabled: canEdit,
            onChanged: (on) =>
                ring.setRingParam(RingParam.autoBloodPressure, on ? 1 : 0),
          ),
          _paramToggle(
            param: RingParam.osaPlan,
            subtitle: '05 22 · sleep apnoea monitoring plan',
            value: (ring.paramValue(RingParam.osaPlan) ?? 0) == 1,
            enabled: canEdit,
            onChanged: (on) => ring.setRingParam(RingParam.osaPlan, on ? 1 : 0),
          ),
        ],
      ),
    );
  }

  Widget _paramToggle({
    required RingParam param,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(param.label),
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
            if (ring.bond case final bond?) _Metric('Android bond', bond),
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
        borderRadius: BorderRadius.circular(12),
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
