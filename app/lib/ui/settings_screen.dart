import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../ble/ring_controller.dart';
import '../data/health_exporter.dart';
import '../data/health_metric.dart';
import 'command_console_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(this.exporter, {this.ring, super.key});

  final HealthExporter exporter;
  final RingController? ring;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  HealthExporter get _exporter => widget.exporter;
  late Future<HealthExportReport?> _report = _exporter.latestReport();
  bool _autoExport = true;
  bool _exporting = false;
  bool _showDevTools = false;
  bool _exportingTrace = false;
  String? _message;
  late final TextEditingController _eventWebhookController;

  @override
  void initState() {
    super.initState();
    _eventWebhookController = TextEditingController(
      text: widget.ring?.smartConfig.eventWebhookUrl ?? '',
    );
    _loadAutoExport();
  }

  @override
  void dispose() {
    _eventWebhookController.dispose();
    super.dispose();
  }

  Future<void> _loadAutoExport() async {
    final enabled = await _exporter.database.getAutoHealthExport();
    if (!mounted) return;
    setState(() => _autoExport = enabled);
  }

  String _connectionSummary(RingController ring) => switch (ring.state) {
    LinkState.ready => 'Connected (${ring.displayRingName})',
    LinkState.disconnected =>
      ring.reconnecting ? 'Reconnecting automatically…' : 'Not connected',
    LinkState.scanning => 'Searching for nearby rings…',
    LinkState.connecting => 'Connecting…',
    LinkState.subscribing => 'Pairing with ring…',
    LinkState.authenticating => 'Securing connection…',
  };

  @override
  Widget build(BuildContext context) {
    final ring = widget.ring;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (ring != null)
              ListenableBuilder(
                listenable: ring,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Automation'),
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Icon(Icons.bluetooth_connected),
                            title: const Text('Auto-connect on launch'),
                            subtitle: const Text(
                              'Automatically reconnects to your ring when opening the app or after brief drops.',
                            ),
                            value: ring.autoConnect,
                            onChanged: (v) => unawaited(ring.setAutoConnect(v)),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            secondary: const Icon(Icons.sync),
                            title: const Text('Auto-sync HRV & health data'),
                            subtitle: const Text(
                              'Automatically downloads sleep, HRV, heart rate, and skin temperature when connected.',
                            ),
                            value: ring.autoSyncHistory,
                            onChanged: (v) =>
                                unawaited(ring.setAutoSyncHistory(v)),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            secondary: const Icon(Icons.touch_app_outlined),
                            title: const Text(
                              'Auto-enable Ring Remote on connect',
                            ),
                            subtitle: const Text(
                              'Turns on finger taps and wrist twists automatically as soon as your ring connects.',
                            ),
                            value: ring.gestureConfig.autoStartGestures,
                            onChanged: (v) => unawaited(
                              ring.updateGestureConfig(
                                ring.gestureConfig.copyWith(
                                  autoStartGestures: v,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            _SectionLabel('Health Connect (Android)'),
            if (!HealthExporter.supportedPlatform)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Android only'),
                  subtitle: Text(
                    'Automatic Health Connect export is available on Android. '
                    'On iOS, ring history is stored privately on your device.',
                  ),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.autorenew),
                      title: const Text('Auto-export after sync'),
                      subtitle: const Text(
                        'Automatically saves heart rate, HRV, SpO₂, breathing, '
                        'steps, and skin temperature to Android Health Connect.',
                      ),
                      value: _autoExport,
                      onChanged: _exporting ? null : _toggleAutoExport,
                    ),
                    const Divider(height: 1),
                    FutureBuilder(
                      future: _report,
                      builder: (context, snapshot) {
                        final report = snapshot.data;
                        final subtitle = switch (snapshot) {
                          _ when snapshot.hasError =>
                            'Could not load export history.',
                          _ when report != null =>
                            _formatReport(context, report),
                          _ when snapshot.connectionState ==
                              ConnectionState.waiting =>
                            'Loading export history…',
                          _ => 'No readings exported yet.',
                        };
                        return ListTile(
                          leading: const Icon(Icons.monitor_heart_outlined),
                          title: const Text('Sync to Health Connect now'),
                          subtitle: Text(subtitle),
                          onTap: !_exporting ? _export : null,
                          trailing: _exporting
                              ? const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.sync),
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (_message case final message?) ...[
              const SizedBox(height: 12),
              Text(message),
            ],
            if (ring != null) ...[
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: ring,
                builder: (context, _) {
                  final smart = ring.smartConfig;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Ring Info & Troubleshooting'),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.info_outline),
                              title: const Text('Connection status'),
                              subtitle: Text(_connectionSummary(ring)),
                            ),
                            if (ring.firmware case final firmware?) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.memory_outlined),
                                title: const Text('Ring firmware'),
                                subtitle: Text(firmware),
                              ),
                            ],
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.restart_alt_rounded),
                              title: const Text('Reset stuck sensors'),
                              subtitle: const Text(
                                'Stops any active heart-rate or gesture stream if the ring stops responding.',
                              ),
                              enabled: ring.connected && !ring.syncing,
                              onTap: ring.connected && !ring.syncing
                                  ? () {
                                      unawaited(ring.forceStopModes());
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Reset signal sent to ring.',
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showDevTools = !_showDevTools),
                        icon: Icon(
                          _showDevTools
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                        label: const Text('Developer & Smart Home Tools'),
                      ),
                      if (_showDevTools) ...[
                        const SizedBox(height: 6),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SwitchListTile(
                                secondary: const Icon(Icons.hub_outlined),
                                title: const Text(
                                  'Broadcast live events (Tasker / KWGT)',
                                ),
                                subtitle: const Text(
                                  'Sends local Android broadcasts when heart rate, wear state, or battery changes.',
                                ),
                                value: smart.broadcastBiometrics,
                                onChanged: (v) => unawaited(
                                  ring.updateSmartConfig(
                                    smart.copyWith(broadcastBiometrics: v),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  16,
                                ),
                                child: TextField(
                                  controller: _eventWebhookController,
                                  keyboardType: TextInputType.url,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Home Assistant / IFTTT webhook URL',
                                    hintText:
                                        'Optional: receives ring_off, ring_on, low_battery',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (url) => unawaited(
                                    ring.updateSmartConfig(
                                      smart.copyWith(eventWebhookUrl: url),
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              Builder(
                                builder: (buttonContext) => ListTile(
                                  leading: const Icon(Icons.ios_share),
                                  title: Text(
                                    _exportingTrace
                                        ? 'Preparing debug log…'
                                        : 'Export debug log',
                                  ),
                                  subtitle: Text(
                                    'Share the latest Bluetooth trace for troubleshooting (may include health readings).',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  enabled: !_exportingTrace,
                                  onTap: _exportingTrace
                                      ? null
                                      : () => _exportTrace(buttonContext, ring),
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.terminal),
                                title: const Text('BLE Command Console'),
                                subtitle: const Text(
                                  'Send raw protocol commands or scan ring opcodes.',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) => CommandConsoleScreen(ring),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _exportTrace(BuildContext context, RingController ring) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? Rect.zero
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _exportingTrace = true);
    try {
      final trace = await ring.exportTrace();
      if (!context.mounted) return;
      if (trace == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No debug log captured yet.')),
        );
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
          SnackBar(content: Text('Could not export debug log. $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingTrace = false);
    }
  }

  Future<void> _toggleAutoExport(bool enabled) async {
    setState(() => _autoExport = enabled);
    await _exporter.database.setAutoHealthExport(enabled);
    if (!mounted) return;
    if (enabled) {
      await _export();
    } else {
      setState(() {
        _message =
            'Auto-export paused. You can still sync manually here anytime.';
      });
    }
  }

  String _formatReport(BuildContext context, HealthExportReport report) {
    final local = report.at.toLocal();
    final formats = MaterialLocalizations.of(context);
    final date = formats.formatMediumDate(local);
    final time = formats.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final counts = [
      for (final metric in HealthMetric.values)
        '${metric.label} ${report.counts[metric] ?? 0}',
    ].join(' · ');
    return 'Last export $date at $time\n$counts';
  }

  Future<void> _export() async {
    setState(() {
      _exporting = true;
      _message = 'Exporting ring history to Android Health Connect…';
    });
    String message;
    try {
      final result = await _exporter.export();
      final count = result.counts.values.fold(0, (sum, count) => sum + count);
      message = [
        if (count > 0)
          'Exported $count records to Android Health Connect.'
        else if (result.failures.isEmpty && result.granted.isNotEmpty)
          'No new readings for the allowed metrics.',
        if (result.denied.isNotEmpty)
          'Write access needed for ${result.denied.map((metric) => metric.label).join(', ')}.',
        if (result.unavailable.isNotEmpty)
          'Unavailable on this device: ${result.unavailable.map((metric) => metric.label).join(', ')}.',
        for (final entry in result.failures.entries)
          'Could not export ${entry.key.label}. ${entry.value}',
      ].join('\n');
    } on PlatformException catch (error) {
      message = error.message ?? 'Could not export to Android Health Connect.';
    } catch (error) {
      message = 'Could not export to Android Health Connect. $error';
    }
    if (!mounted) return;
    setState(() {
      _exporting = false;
      _report = _exporter.latestReport();
      _message = message;
    });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
