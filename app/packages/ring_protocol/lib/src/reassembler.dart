import 'commands.dart';
import 'frames.dart';

/// Observes decoded frames and opaque bytes skipped by the decoder.
typedef FrameObserver = void Function(List<int> bytes, RingFrame? frame);

/// Reassembles the notification stream for FR02.023.
///
/// A history page has no byte length in its header. Wait for a short gap
/// between notifications and consider record-aligned XOR matches. Prefer a
/// boundary with a complete sequence of known trailing frames. Otherwise use the
/// largest match. The caller drives the gap via [flush].
final class FrameReassembler {
  static const bulkQuietPeriod = Duration(milliseconds: 120);
  static const _maxBufferedBytes = 8192;
  final List<int> _buffer = [];

  bool get hasPendingBytes => _buffer.isNotEmpty;
  int discardedBytes = 0;

  List<RingFrame> add(List<int> chunk, {FrameObserver? observe}) {
    _buffer.addAll(chunk);
    if (_buffer.length > _maxBufferedBytes) {
      _discard(_buffer.length - _maxBufferedBytes);
    }
    return _decode(allowBulk: false, observe: observe);
  }

  List<RingFrame> flush({FrameObserver? observe}) {
    final frames = _decode(allowBulk: true, observe: observe);
    // The console must retain opaque replies even if their first byte matches
    // a known frame type with a different length. The normal reader keeps
    // incomplete frames buffered across quiet gaps.
    if (observe != null && _buffer.isNotEmpty) {
      observe(List<int>.of(_buffer), null);
      discardPending();
    }
    return frames;
  }

  void reset() {
    _buffer.clear();
    discardedBytes = 0;
  }

  List<RingFrame> _decode({
    required bool allowBulk,
    required FrameObserver? observe,
  }) {
    final frames = <RingFrame>[];
    var skipped = <int>[];

    void reportSkipped() {
      if (skipped.isEmpty) return;
      observe?.call(skipped, null);
      skipped = [];
    }

    void decode(List<int> bytes) {
      final frame = RingFrame.decode(bytes);
      frames.add(frame);
      reportSkipped();
      observe?.call(frame.raw, frame);
      _buffer.removeRange(0, bytes.length);
    }

    while (_buffer.isNotEmpty) {
      if (_buffer.length < 2) break;
      final opcode = _buffer[0];
      final sub = _buffer[1];
      final stream = HistoryStream.forOpcode(opcode);
      if (stream != null && sub == 0) {
        if (!allowBulk) break;
        final length = _bulkLength(stream.recordSize);
        if (length == null) break;
        decode(_buffer.sublist(0, length));
        continue;
      }
      // This opaque FR02.023 notice lacks a verified trailer or semantics.
      // Raw notifications retain it. It never marks the end of a drain.
      if (opcode == 0x50 && sub == 0) {
        if (_buffer.length < 27) break;
        reportSkipped();
        observe?.call(_buffer.sublist(0, 27), null);
        _discard(27);
        continue;
      }
      final length = RingFrame.fixedLength(opcode, sub);
      if (length != null) {
        if (_buffer.length < length) break;
        final frame = _buffer.sublist(0, length);
        if (validXor(frame)) {
          decode(frame);
          continue;
        }
      }
      if (observe != null) skipped.add(opcode);
      _discard(1);
    }
    if (observe != null && _buffer.length == 1) {
      final tail = _buffer.single;
      final canStartKnownFrame =
          tail == 0x81 ||
          tail == 0x15 ||
          tail == 0x50 ||
          HistoryStream.forOpcode(tail) != null ||
          RingFrame.fixedLength(tail, null) != null;
      if ((skipped.isNotEmpty && validXor([...skipped, tail])) ||
          (!canStartKnownFrame && (allowBulk || skipped.isNotEmpty))) {
        skipped.add(tail);
        _discard(1);
      }
    }
    reportSkipped();
    return frames;
  }

  int? _bulkLength(int recordSize) {
    int? largest;
    var length = 4 + (_buffer.length - 4) ~/ recordSize * recordSize;
    for (; length >= 4 + recordSize; length -= recordSize) {
      if (!validXor(_buffer.sublist(0, length))) continue;
      largest ??= length;
      // XOR also validates a concatenation of valid frames. A complete
      // sequence of trailing fixed frames is evidence of an earlier boundary.
      if (length < _buffer.length && _hasFixedSuffix(length)) return length;
    }
    return largest;
  }

  bool _hasFixedSuffix(int offset) {
    while (offset + 1 < _buffer.length) {
      final length = RingFrame.fixedLength(
        _buffer[offset],
        _buffer[offset + 1],
      );
      if (length == null ||
          offset + length > _buffer.length ||
          !validXor(_buffer.sublist(offset, offset + length))) {
        return false;
      }
      offset += length;
    }
    return offset == _buffer.length;
  }

  void discardPending() => _discard(_buffer.length);

  void _discard(int count) {
    discardedBytes += count;
    _buffer.removeRange(0, count);
  }
}
