import 'dart:typed_data';

int uint16(List<int> bytes, int offset) =>
    (bytes[offset] << 8) | bytes[offset + 1];

int uint24(List<int> bytes, int offset) =>
    (bytes[offset] << 16) | uint16(bytes, offset + 1);

int uint32(List<int> bytes, int offset) =>
    (uint16(bytes, offset) << 16) | uint16(bytes, offset + 2);

int signed16(int value) => value < 0x8000 ? value : value - 0x10000;

int signed20(int value) {
  final bits = value & 0xfffff;
  return bits < 0x80000 ? bits : bits - 0x100000;
}

int packedBits(List<int> bytes, int offset, int count) {
  var value = 0;
  for (var bit = offset; bit < offset + count; bit++) {
    value = (value << 1) | ((bytes[bit ~/ 8] >> (7 - bit % 8)) & 1);
  }
  return value;
}

Uint8List freeze(List<int> bytes) =>
    Uint8List.fromList(bytes).asUnmodifiableView();

bool validXor(List<int> bytes) {
  if (bytes.length < 2) return false;
  var xor = 0;
  for (final byte in bytes) {
    xor ^= byte;
  }
  return xor == 0;
}
