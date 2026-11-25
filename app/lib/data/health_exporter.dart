import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ring_protocol/ring_protocol.dart';

import 'health_metric.dart';
import 'ring_database.dart';

typedef HealthExportResult = ({
  Map<HealthMetric, int> counts,
  List<HealthMetric> granted,
  List<HealthMetric> denied,
  List<HealthMetric> unavailable,
  Map<HealthMetric, String> failures,
});

final class HealthExporter {
  HealthExporter(this.database);

  static const _channel = MethodChannel('ringconn/health_connect');
  static const _batchSize = 250;

  final RingDatabase database;
  Future<HealthExportResult>? _active;

  Future<HealthExportReport?> latestReport() => database.latestHealthExport();

  Future<HealthExportResult> export() =>
      _active ??= _export().whenComplete(() => _active = null);

  Future<HealthExportResult> _export() async {
    final permissions = await _channel.invokeMapMethod<String, Object?>(
      'authorize',
    );
    if (permissions == null) {
      throw const FormatException(
        'Missing Health Connect permission response.',
      );
    }
    final available = (permissions['available'] as List).cast<String>().toSet();
    final granted = (permissions['granted'] as List).cast<String>().toSet();
    final started = DateTime.now().toUtc();
    final through = cursorFromTime(started);
    final counts = <HealthMetric, int>{};
    final failures = <HealthMetric, String>{};

    for (final metric in HealthMetric.values.where(
      (metric) => granted.contains(metric.name),
    )) {
      while (true) {
        final samples = await database.pendingHealthSamples(
          metric,
          through: through,
          limit: _batchSize,
        );
        if (samples.isEmpty) break;
        try {
          await _channel.invokeMethod<void>('insert', {
            'metric': metric.name,
            'records': [
              for (final sample in samples)
                {
                  'id':
                      'ringconn:${sample.deviceId}:${metric.name}:${sample.cursor}',
                  'timeMs': timeFromCursor(sample.cursor)
                      .millisecondsSinceEpoch,
                  'values': sample.values,
                },
            ],
          });
        } on PlatformException catch (error) {
          failures[metric] =
              error.message ?? 'Health Connect could not write these records.';
          break;
        }
        await database.confirmHealthWrites(metric, samples, started);
        counts.update(
          metric,
          (count) => count + samples.length,
          ifAbsent: () => samples.length,
        );
      }
    }
    return (
      counts: counts,
      granted: HealthMetric.values
          .where((metric) => granted.contains(metric.name))
          .toList(),
      failures: failures,
      denied: HealthMetric.values
          .where(
            (metric) =>
                available.contains(metric.name) &&
                !granted.contains(metric.name),
          )
          .toList(),
      unavailable: HealthMetric.values
          .where((metric) => !available.contains(metric.name))
          .toList(),
    );
  }

  static bool get supportedPlatform => Platform.isAndroid;
}
