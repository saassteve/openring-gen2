import 'dart:typed_data';

import 'commands.dart';
import 'frames.dart';

enum DrainPhase {
  idle,
  waiting,
  persisting,
  acknowledging,
  complete,
  partial,
  failed,
  cancelled,
}

/// One authenticated history drain. The caller commits the raw and decoded
/// page before [pagePersisted] and waits for the ATT write callback before
/// [acknowledged]. Any buffered following pages must be processed in order.
final class HistoryDrain {
  HistoryDrain({required this.cursor, this.channel = 0, this.maxRetries = 2}) {
    RangeError.checkNotNegative(maxRetries, 'maxRetries');
  }

  final int cursor;
  final int channel;
  final int maxRetries;
  final Map<HistoryStream, int> _remaining = {};
  final Map<HistoryStream, Set<int>> _cursors = {};
  HistoryPage? _pending;
  int _retries = 0;
  DrainPhase _phase = DrainPhase.idle;

  DrainPhase get phase => _phase;
  Map<HistoryStream, int> get remaining => Map.unmodifiable(_remaining);
  int get pagesAcknowledged => _pagesAcknowledged;
  int _pagesAcknowledged = 0;
  int get recordsAcknowledged =>
      _cursors.values.fold(0, (sum, set) => sum + set.length);
  bool get finished => switch (_phase) {
    DrainPhase.complete ||
    DrainPhase.partial ||
    DrainPhase.failed ||
    DrainPhase.cancelled => true,
    _ => false,
  };

  Uint8List start() {
    _require(DrainPhase.idle);
    _phase = DrainPhase.waiting;
    return RingCommands.openHistory(cursor, channel: channel);
  }

  void pageReceived(HistoryPage page) {
    _require(DrainPhase.waiting);
    _pending = page;
    _phase = DrainPhase.persisting;
  }

  Uint8List pagePersisted() {
    _require(DrainPhase.persisting);
    _phase = DrainPhase.acknowledging;
    return RingCommands.acknowledgePage(_pending!.stream);
  }

  void acknowledged() {
    _require(DrainPhase.acknowledging);
    final page = _pending!;
    final existing = _cursors.putIfAbsent(page.stream, () => <int>{});
    final countBefore = existing.length;
    existing.addAll(page.records.map((record) => record.cursor));
    if (existing.length > countBefore || !_remaining.containsKey(page.stream)) {
      _remaining[page.stream] = page.remaining;
      _retries = 0;
    }
    _pagesAcknowledged++;
    _pending = null;
    // Each stream reports its own remainder. End only after both report zero.
    _phase = HistoryStream.values.every((stream) => _remaining[stream] == 0)
        ? DrainPhase.complete
        : DrainPhase.waiting;
  }

  Uint8List? stalled() {
    _require(DrainPhase.waiting);
    if (_retries < maxRetries) {
      _retries++;
      return RingCommands.openHistory(cursor, channel: channel);
    }
    _phase = _remaining.isEmpty ? DrainPhase.failed : DrainPhase.partial;
    return null;
  }

  void fail() {
    if (!finished) _phase = DrainPhase.failed;
    _pending = null;
  }

  void cancel() {
    if (!finished) _phase = DrainPhase.cancelled;
    _pending = null;
  }

  void _require(DrainPhase expected) {
    if (_phase != expected) throw StateError('Expected $expected, got $_phase');
  }
}
