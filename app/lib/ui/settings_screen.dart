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
  bool _exporting = false;
  String? _message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: FutureBuilder(
              future: _report,
              builder: (context, snapshot) {
                final report = snapshot.data;
                final subtitle = switch (snapshot) {
                  _ when snapshot.hasError => 'Could not load export history.',
                  _ when !HealthExporter.supportedPlatform =>
                    'Available on Android.',
                  _ when report != null => _formatReport(context, report),
                  _ when snapshot.connectionState == ConnectionState.waiting =>
                    'Loading export history…',
                  _ => 'No readings exported yet.',
                };
                return ListTile(
                  leading: const Icon(Icons.monitor_heart_outlined),
                  title: const Text('Sync to Health Connect'),
                  subtitle: Text(subtitle),
                  onTap: HealthExporter.supportedPlatform && !_exporting
                      ? _export
                      : null,
                  trailing: _exporting
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                );
              },
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
      _message = 'Exporting ring history…';
    });
    String message;
    try {
      final result = await _exporter.export();
      final count = result.counts.values.fold(0, (sum, count) => sum + count);
      message = [
        if (count > 0)
          'Exported $count records.'
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
      message = error.message ?? 'Could not export to Health Connect.';
    } catch (error) {
      message = 'Could not export to Health Connect. $error';
    }
    if (!mounted) return;
    setState(() {
      _exporting = false;
      _report = _exporter.latestReport();
      _message = message;
    });
  }
}
