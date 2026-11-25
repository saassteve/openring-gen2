import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../data/health_exporter.dart';
import '../data/health_metric.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(this.exporter, {super.key});

  final HealthExporter exporter;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  HealthExporter get _exporter => widget.exporter;
  late Future<HealthExportReport?> _report = _exporter.latestReport();
  bool _autoExport = true;
  bool _exporting = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadAutoExport();
  }

  Future<void> _loadAutoExport() async {
    final enabled = await _exporter.database.getAutoHealthExport();
    if (!mounted) return;
    setState(() => _autoExport = enabled);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              'Health Connect (Android)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (!HealthExporter.supportedPlatform)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Android only'),
                subtitle: Text(
                  'Automatic Health Connect export is available on Android. '
                  'On iOS, ring history is stored locally in SQLite and can be '
                  'shared from Diagnostics.',
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.autorenew),
                    title: const Text('Auto-export after history sync'),
                    subtitle: const Text(
                      'Automatically writes HR, HRV, SpO₂, respiratory '
                      'rate, steps, and skin temperature to Android Health '
                      'Connect whenever ring history finishes syncing.',
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
                        _ when report != null => _formatReport(context, report),
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
        ],
      ),
    ),
  );

  Future<void> _toggleAutoExport(bool enabled) async {
    setState(() => _autoExport = enabled);
    await _exporter.database.setAutoHealthExport(enabled);
    if (!mounted) return;
    if (enabled) {
      // Prompt once if permissions are not yet granted, and export any backlog.
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
