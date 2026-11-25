import 'dart:typed_data';

const _word = 0xffffffff;

int _rotate(int value, int count) {
  final shift = count % 32;
  return ((value << shift) | (value >> (32 - shift))) & _word;
}

int _p0(int value) => value ^ _rotate(value, 9) ^ _rotate(value, 17);
int _p1(int value) => value ^ _rotate(value, 15) ^ _rotate(value, 23);

/// SM3 (GB/T 32905). Protocol input is just the identity XOR byte and challenge.
Uint8List sm3(List<int> input) {
  final length = (input.length + 9 + 63) ~/ 64 * 64;
  final message = Uint8List(length)..setAll(0, input);
  message[input.length] = 0x80;
  final data = ByteData.sublistView(message)
    ..setUint64(length - 8, input.length * 8);
  final state = Uint32List.fromList([
    0x7380166f,
    0x4914b2b9,
    0x172442d7,
    0xda8a0600,
    0xa96f30bc,
    0x163138aa,
    0xe38dee4d,
    0xb0fb0e4e,
  ]);
  final words = Uint32List(68);
  for (var block = 0; block < length; block += 64) {
    for (var round = 0; round < 16; round++) {
      words[round] = data.getUint32(block + 4 * round);
    }
    for (var round = 16; round < 68; round++) {
      words[round] =
          _p1(
            words[round - 16] ^
                words[round - 9] ^
                _rotate(words[round - 3], 15),
          ) ^
          _rotate(words[round - 13], 7) ^
          words[round - 6];
    }
    var [a, b, c, d, e, f, g, h] = state;
    for (var round = 0; round < 64; round++) {
      final early = round < 16;
      final rotatedA = _rotate(a, 12);
      final constant = _rotate(early ? 0x79cc4519 : 0x7a879d8a, round);
      final ss1 = _rotate((rotatedA + e + constant) & _word, 7);
      final ss2 = ss1 ^ rotatedA;
      final majority = early ? a ^ b ^ c : (a & b) | (a & c) | (b & c);
      final choice = early ? e ^ f ^ g : (e & f) | (~e & g);
      final tt1 =
          (majority + d + ss2 + (words[round] ^ words[round + 4])) & _word;
      final tt2 = (choice + h + ss1 + words[round]) & _word;
      (a, b, c, d) = (tt1, a, _rotate(b, 9), c);
      (e, f, g, h) = (_p0(tt2), e, _rotate(f, 19), g);
    }
    final compressed = [a, b, c, d, e, f, g, h];
    for (var index = 0; index < state.length; index++) {
      state[index] ^= compressed[index];
    }
  }
  final digest = ByteData(32);
  for (var index = 0; index < state.length; index++) {
    digest.setUint32(index * 4, state[index]);
  }
  return digest.buffer.asUint8List();
}

/// Resolves the six-byte device identity by matching the advertised suffix.
/// Handles the observed raw layout and EUI-64 with an inserted FF FE or FE FF.
Uint8List? identityFromSystemId(List<int> systemId, String advertisedName) {
  final match = RegExp(
    r'-([0-9a-f]{4})$',
    caseSensitive: false,
  ).firstMatch(advertisedName);
  if (match == null) return null;
  final tail = int.parse(match.group(1)!, radix: 16);
  Uint8List? identity;
  for (final bytes in [systemId, systemId.reversed.toList()]) {
    final inserted =
        bytes.length == 8 &&
        ((bytes[3] == 0xff && bytes[4] == 0xfe) ||
            (bytes[3] == 0xfe && bytes[4] == 0xff));
    final candidate = inserted ? [...bytes.take(3), ...bytes.skip(5)] : bytes;
    if (candidate.length != 6 || ((candidate[4] << 8) | candidate[5]) != tail) {
      continue;
    }
    if (identity != null &&
        Iterable<int>.generate(6).any((i) => identity![i] != candidate[i])) {
      return null;
    }
    identity = Uint8List.fromList(candidate);
  }
  return identity;
}

Uint8List authResponse(List<int> identity, int challenge) {
  if (identity.length != 6) {
    throw ArgumentError.value(
      identity.length,
      'identity length',
      'Expected 6 bytes',
    );
  }
  RangeError.checkValueInInterval(challenge, 0, 255, 'challenge');
  final tail = identity[3] ^ identity[4] ^ identity[5];
  return sm3([tail, challenge]).sublist(29);
}
