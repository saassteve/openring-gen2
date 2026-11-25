# Verified on hardware — RingConn Gen 2, firmware FR02.023

Independent implementation (macOS/CoreBluetooth, `ringconn.swift`) reached a full
authenticated session against the actual ring. This file records only what *we*
reproduced here; `PROTOCOL.md` summarizes the resulting wire specification.

## Device

| Fact | Value | How obtained |
|---|---|---|
| Advertised name | `RingConn Gen2-00A5` (device suffix redacted) | scan (name lives in SCAN_RSP only) |
| MAC (identity) | `F8:79:99:00:00:A5` (redacted; same tail XOR `0xA5`) | DIS System ID `2A23`, validated against name suffix |
| SYSID raw | `f8 79 99 00 00 a5` (6-byte form, redacted) | GATT read |
| Serial | `<redacted>` | DIS `2A25` |
| Firmware | `FR02.023` | DIS `2A26` |
| Adv payload | name only, **no service UUID, no manufacturer data** | scan logging |
| Write char props | `0x08` = write with response | discovery |
| Notify char props | `0x10` = notify | discovery |
| ATT MTU (macOS) | 512 write w/ response, 244 without | `maximumWriteValueLength` |

A filtered scan (`withServices:`) **misses the ring** — it advertises no UUIDs.
Scan unfiltered with `AllowDuplicatesKey`.

## Auth — reproduced

- Ring sends `81 00 <chal> <xor>` unprompted right after CCCD subscribe.
- Computed tail XOR `mac3 ^ mac4 ^ mac5 = 0xa5` (represented here by redacted identity `f8 79 99 00 00 a5`, `00 ^ 00 ^ a5 = a5`).
- SM3([tailxor, chal])[29..31] accepted, ring returned `81 01 …` status table and
  began streaming telemetry. Three separate sessions (chal 0xbd/0x46/…) all accepted.
- SM3 implementation validated against GB/T 32905 KAT and the 24 captured pairs.

## Live HR — reproduced

Sequence `d0 00 00`, `06 01 00`, `07 00 00`, then `95 00 00` every 2 s.
Mode ack `86 00`, then `15 00 <hr> …` at ~2 s intervals; values < 0x1e are warm-up.
Observed HR bytes 0x2a, 0x16, 0x20 etc.

## Telemetry (descriptor) frames observed

`10 59 03 00 00 00 1f 01 45 01 4f 00 00 00 00 01 00 00 10 8a 00 42 00 00 0b 01 24 5c b7 02 f4 00 00 49 <xor>`
and the `07`-triggered variant `87 59 03 …`.
Byte 1 = 0x59 = 89 % battery, byte 2 = 0x03. Remaining fields (steps / skin temp /
voltage) still need mapping on this firmware.

## Contention rules confirmed

- Ring stops advertising entirely while another central (the phone) holds it.
- Re-enabling the phone's Bluetooth alone is enough for the ring to be re-grabbed
  and a Mac connect to time out.
- Both sides of a session must be quiet: `adb shell svc bluetooth disable`
  (or app force-stop + radio off) before probing, then restore.

## Tool

`tools/ringconn.swift` → `swiftc -O ringconn.swift -o ringconn`
- `./ringconn selftest`
- `./ringconn --scan --seconds 30`
- `./ringconn --name "RingConn Gen2" --live --seconds 60`

## Descriptor map (empirical, FR02.023) — 35-byte frames `10`/`87`

Length 35, final byte XOR of all preceding bytes (verified on every frame).

| Off | Meaning | Evidence |
|---|---|---|
| 0 | opcode: `10` unsolicited, `87` = reply to `07 00 00` | 0x87 == 0x07^0x80 |
| 1 | battery % | 0x56 = 86 stable |
| 2 | wear/mode state: `02` idle off-finger, `03` worn, `01` during HR mode | flips on wear |
| 3..5 | zero | |
| 6..7 | temp1 BE ×0.1 °C | 0x0145 = 32.5 °C, drops off-finger |
| 8..9 | temp2 BE ×0.1 °C | moves inversely to temp1 (gradient) |
| 10..13 | zero | |
| 14..15 | battery voltage BE mV | 0x106c = 4204 mV, constant |
| 16 | mode/flag byte | 0x03 idle, 0x0b while HR mode active |
| 17 | 0xff constant | |
| 18+ | zero in all samples | |
| 34 | XOR | |

No HR value in the descriptor; HR only in `15 00 <hr>` frames.

## Corrections to community notes found here

- Descriptor frames are **20 bytes**, not 35 (offsets above re-verified: XOR is at [19]).
- `06 05 00` (dense PPG) **does work on plain Gen 2 FR02.023** — notes thought Gen 3 only.
- `06 02 00` (SpO2 mode) starts **both** `0x12` (135 B, dense) and `0x13` (160 B, raw) streams,
  without the `06 10 00` prime. 0x13 arrived on a plain Gen 2 too.
- 0x13/0x12 layouts confirmed byte-exact as documented (seq, counter, sample packing).

## Verified PPG structure

- `0x13` len 160: [2]=seq +1/frame, samples 25×6 B at [6..155] — later confirmed as **25 Hz 3-axis accelerometer** (`x, y, z` signed BE16, resting norm ≈ 1024 = 1g; also streamable directly via `23 03 00`), [156..158]=24-bit counter (+25/frame), [159]=XOR.
- `0x12` len 135: [1..2]=BE16 seq, [130..132]=3-byte counter (+10/frame), 10×4×24-bit at
  [6..125], ch3 signed-20-bit ≈ 0x0ffffb (ambient), [3..5]=`01 00 83`.

Decoder: `decode_ppg.py <trace.jsonl> <outdir>`.

## History drain — protocol decoded and working

- Open: `d0 00 00`, then `02 00 <cursor BE4> <ch> 01 00`; ring answers `82 00 00`.
  Cursor = unix seconds − 1577793600. Must be sent **after** auth.
- Pages: `0x4c` = 3-byte header (`4c 00 <remaining>`) + N×23-byte epochs, 150 s apart.
  `0x47` = same header + N×47-byte optical blocks, 900 s apart.
- Header byte **[2] = records still queued after this page**; drain ends at 0.
  There is no `0x50` end frame.
- ACK each page: `cc 00 00` (0x4c) / `c7 00 00` (0x47). Ring pauses until ACKed;
  re-issue the sync-open if it stalls.
- `07 00 00` during a drain *disturbs* it — nudge with a fresh `02 00 …` instead.
- Ring normally serves both channels from one open; 200+ epoch and 30+ optical
  block records drained in one session, and a later drain terminated cleanly.
- Shared resume pointer advances only with ACKs — a drain takes the backlog away
  from the official app.

### Partial 0x4c record map
`[0..3]` cursor. `[4]` = HR bpm (sleep 46–67, resting 55–62 — solid correlation).
`[5]` = HRV-like, 35–155, higher in sleep. `[6]` 5–10, `[7]` 106–124, `[8]` 18–99,
`[9]` ≈10 constant, `[10..17]` often `01 01 01 01 01 00 00 00` (validity flags?),
`[18..22]` usually 0. SpO2 / confidence not yet identified — needs a ground-truth run.

## Full record maps (verified statistically on 212 epochs / 31 blocks)

### 0x4c — 2.5-min epoch, end-timestamped
| Off | Field | Encoding |
|---|---|---|
| 0..3 | cursor | s since 1577793600, +150 per record |
| 4 | heart rate | bpm; `4` = off-finger error |
| 5 | HRV (RMSSD) | ms; `0` = rejected |
| 6 | PPG quality | 0..10 (valid 15 s sub-windows) |
| 7 | respiratory rate | ×10 brpm; `0` = invalid; hard floor 105 |
| 8 | SpO2 | %; `18` = slot not scheduled, `17` = failed |
| 9 | activity | MET ×10 (10 = 1.0 MET rest) |
| 10..14 | 5 × 30 s ambient light | `1` = dark floor |
| 15..22 | 5 × u12be motion energy + 4-bit flags | bit2 = SpO2 slot scheduled, bit1 = high motion |

Cross-checks: `tail4==4` in 94/94 scheduled SpO2 epochs (93–100 %, one failed at 17 while
off-finger); MET rises 10→23/24/33/40 exactly on walking epochs; motion 0 during still epochs
and 20 000+ while walking.

### 0x47 — 15-min block, end-timestamped: **dual skin temperature + activity summary**
| Off | Field | Encoding |
|---|---|---|
| 0..3 | cursor | +900 per record |
| 4 | subtype | constant 0x02 |
| 5 bit7..1 | battery | % (89→86 during drain) |
| 5 bit0 | activity flag | 1 only in the walking block |
| 6..7 | steps | be16 (608 on the walking block, 0 asleep) |
| 8 | active time | multiples of 5 (0/5/10/110) |
| 9..46 | 4 pad bits + 15 × (u10 ChA outer, u10 ChB inner) | 0.05 °C |

Temps decode 27.9–33.0 °C, inner warmer in 87 % of samples, plunging to 27.9 °C exactly when
the 0x4c epoch says off-finger. **0x47 is NOT optical PPG** — the earlier note was wrong.

Decoder: `python3 tools/decode_history.py <trace.jsonl> <outdir>`.
