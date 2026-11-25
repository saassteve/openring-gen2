# RingConn Gen 2 BLE Protocol (`FR02.023`)

Independent, community-maintained wire protocol specification for local BLE
interoperability with RingConn Gen 2 smart rings (tested on firmware `FR02.023`).
This project is not affiliated with or endorsed by RingConn.

Confidence tags:
- **`verified-on-device`**: reproduced on physical `FR02.023` hardware.
- **`inactive-on-FR02.023`**: probed on `FR02.023` with no reply (absent or firmware-gated).
- **`documented-unverified`**: known wire command not yet exercised on live `FR02.023` hardware.

## GATT layout (`verified-on-device`)

| Service | UUID / Characteristics |
|---|---|
| Primary vendor service | `8327ad99-2d87-4a22-a8ce-6dd7971c0437` |
| Write characteristic | `8327ad98-2d87-4a22-a8ce-6dd7971c0437` (write with response) |
| Notify characteristic | `8327ad97-2d87-4a22-a8ce-6dd7971c0437` (notify, encrypted link required) |
| Device Information | `180a` (`2a23` System ID = MAC, `2a25` serial, `2a26` firmware, `2a27` hw, `2a29` manufacturer) |
| OTA / DFU service | `1d14d6ee-fd63-4fa1-bfa4-8f47b42119f0`, chars `f7bf3564-…` (write) and `984227f3-…` (write+indicate) — standard Silicon Labs Gecko bootloader UUIDs (`documented-unverified`) |

No standard Battery service exists; battery is reported in telemetry (`0x10`/`0x87`) and
the auth status table (`81 01`).

## Identity and authentication (`verified-on-device`)

1. Read DIS `2a23` (System ID) → 6-byte MAC. Validate the last two bytes against the
   advertised name suffix (e.g. `RingConn Gen2-XXXX`).
2. On macOS, write `01 00 00` to `8327ad98-…` first to trigger SMP encryption before
   subscribing to `8327ad97-…` (see `docs/MACOS-PAIRING.md`), then request `01 00 00`
   again once notifications are enabled.
3. Ring sends `81 00 <challenge> <xor>`.
4. Reply `01 01 r0 r1 r2 00` where `r = SM3([mac3^mac4^mac5, challenge])[29..31]`
   (SM3 = GB/T 32905).
5. Ring answers with the 38-byte `81 01 …` status table and accepts data commands.

Authentication is per connection: every reconnect repeats the challenge/response.
Reference SM3 known-answer vectors are in `tools/ringconn.swift selftest`.

## Framing (`verified-on-device`)

- **TX commands**: `[cmd][sub][payload][00]`. Every TX frame ends with a `0x00` trailer
  byte accepted by the ring.
- **RX responses**: `[cmd ^ 0x80] … [xor]`, where the final byte is the XOR of every
  preceding byte.
- Notifications can coalesce or split across ATT packets; reassemble using length and XOR
  validation.
- **Note on `d0 00 00`**: `d0 00 00` is the ACK for `0x50` (ring log chunk, `0x50 | 0x80`),
  not a dedicated session-init command. Sending it after auth is a harmless no-op when no
  log chunk is queued.
- **Note on epoch**: History captures on `FR02.023` aligned to Unix epoch offset
  `1577793600` (whereas `1577808000` = `2020-01-01 00:00:00 UTC+8` is 4 hours later).
  Verify timestamp alignment against a live clock sync on your device.

## Commands

### Safe / operational commands

| Cmd (hex) | Meaning | Response | Status |
|---|---|---|---|
| `01 00 00` | Auth challenge request | `81 00 <chal> <xor>` | `verified-on-device` |
| `01 01 <r0 r1 r2> 00` | SM3 auth response | `81 01 <35B status> <xor>` (38 B) | `verified-on-device` |
| `02 00 <utc:u32be> <interval:u8> <sysInfo:u8> 00` | Normal work mode + clock sync + start history push (`sysInfo`: `00` Android, `01` iOS) | `82 00 00 <xor>` | `verified-on-device` |
| `05 22 <00\|01\|02> 00` | Set OSA plan (`00` idle, `01` monitoring, `02` closing) | `85 00 85` or `85 22 <status> <xor>` | `documented-unverified` |
| `05 23 <00\|01> 00` | Set auto-sports monitor (`sportsMonitor`) | `85 00 85` (or `85 23 <status> <xor>`) | `verified-on-device` |
| `05 24 <00\|01> 00` | Set Sleep Pro / compressed PPG storage | `85 00 85` or `85 24 <status> <xor>` | `documented-unverified` |
| `05 25 <00\|01> 00` | Set auto offline blood pressure | `85 00 85` (3 B ACK) | `verified-on-device` |
| `05 30 <cfg...> 00` | Vibration group config (Gen 3 haptics) | `85 30 <status> <xor>` | `documented-unverified` |
| `06 00 00` | Stop realtime measurement mode | `86 00 <xor>` | `verified-on-device` |
| `06 01 00` | Start live HR mode | `86 00 <xor>` | `verified-on-device` |
| `06 02 00` | Start SpO2 mode (also emits `0x12` PPG + `0x13` ACC) | `86 00 <xor>` | `verified-on-device` |
| `06 03 <sportType> 04 00` | Start realtime sports mode | `86 <status> <xor>` | `documented-unverified` |
| `06 05 00` | Start dense 4-ch PPG (`0x12` frames) | `86 00 <xor>` | `verified-on-device` |
| `06 10 00` | Prime optical engine | `86 00 <xor>` | `verified-on-device` |
| `07 00 00` | Poll telemetry descriptor | `87 <18B> <xor>` (20 B) | `verified-on-device` |
| `29 00 00` | Read sensor temperature | `a9 <ntc1:s16be> <ntc2:s16be> 00 00 00 00 <xor>` (10 B, 0.1 °C) | `verified-on-device` |
| `55 00 00` | Request auto debug trace | silent on `FR02.023` (`d5 ...` on older firmware) | `inactive-on-FR02.023` |
| `23 03 00` | Start 25 Hz 3-axis accelerometer stream (works in normal mode; stop with `06 00 00`) | `a3 00 a3` + `0x13` (160 B, 1 Hz) | `verified-on-device` |
| `91 00 00` | ACK unsolicited `0x11` event/heartbeat | — | `verified-on-device` |
| `95 00 00` | Poll live HR during `06 01/02/05` | `15 00 <hr> ... <xor>` (6 B) | `verified-on-device` |
| `96 01 00 00 00` | Pull realtime `0x13` frames | `0x13` (160 B) | `verified-on-device` |
| `cc`/`c7`/`cf`/`cb`/`d1`/`d0 00 00` | Bulk ACKs (`4c`, `47`, `4f`, `4b`, `51`, `50`) | — | `verified-on-device` (`cc`/`c7`/`d0`) |

Note: No `0x05` sub-opcodes are known for changing raw sampling rate, auto-HR cadence,
or SpO2 interval scheduling on `FR02.023`.

### Factory, bind, and destructive commands (DO NOT PROBE on primary ring)

| Cmd (hex) | Meaning | Status | Risk |
|---|---|---|---|
| `02 01 ... 00` | Work mode: unbound | `documented-unverified` | Breaks binding |
| `02 02 ... 00` | Work mode: **Factory Mode** | `documented-unverified` | Locks ring in factory mode until `20 01 00` |
| `03 <uid BE4> ... 00` | Bind user profile | `documented-unverified` | Re-binds ring / alters data access |
| `08 <01..05> 00` | System control (`01`–`03` reboot/reset/shutdown, `04` flight mode, `05` **stockpile deep-sleep**) | `documented-unverified` | **`08 05` requires physical charger to wake** |
| `09 <params...> 00` | Enter OTA / DFU bootloader | `documented-unverified` | Enters bootloader |
| `20 01 00` | Exit Factory Mode | `documented-unverified` | Only for leaving `02 02` |
| `22 <mode> 00` / `24 01 00` | PPG test / LED test (`22 00 00` → `a2 00 a2`, `24 01 00` → `a4 00 a4` in normal mode; no brightness/color args) | `verified-on-device` | Optical/LED diagnostic commands |
| `0b 03 <pattern> 64 00` / `25 00 00` | Gen 3 vibration trigger / stop | `inactive-on-FR02.023` | Gen 3 haptics only (no motor on Gen 2) |

## Auth status table (`81 01`, 38 bytes — `verified-on-device`)

| Off | Field | Example (`FR02.023`) |
|---|---|---|
| 0–1 | `81 01` | `81 01` |
| 2 | auth status (`00` = accepted) | `00` |
| 3 | battery % | `56` (86%) |
| 4 | wear/mode (`01` measuring, `02` off-finger, `03` worn) | `02` |
| 8–9 | NTC 1, BE s16, 0.1 °C | `01 46` (32.6 °C) |
| 10–11 | NTC 2, BE s16, 0.1 °C | `01 4a` (33.0 °C) |
| 16 | `ecoMode` | `01` |
| 17 | `monitorStatus` | `00` |
| 18 | `monitorPlanStatus` (OSA plan state) | `00` |
| 19–20 | battery voltage, BE u16 mV | `10 64` (4196 mV) |
| 31 | negotiated ring `mtu` | `f4` (244) |
| 32–35 | ring `curUtc` counter (BE u32 relative to ring epoch) | `00 00 c0 f8` |
| 36 | `sportsMonitor` (auto-sports enabled: `00`/`01`) | `01` |
| 37 | XOR trailer | `ec` |

## Telemetry descriptor (`0x10` passive, `0x87` polled — 20 bytes, `verified-on-device`)

| Off | Field |
|---|---|
| 0 | opcode (`0x10` or `0x87`) |
| 1 | battery % |
| 2 | wear/mode: `02` off-finger, `03` worn, `01` during HR mode |
| 3–5 | zero |
| 6–7 | NTC 1, BE s16, 0.1 °C |
| 8–9 | NTC 2, BE s16, 0.1 °C (moves inversely to NTC 1) |
| 10–13 | zero |
| 14–15 | battery voltage, BE u16 mV |
| 16 | mode flags (`03` idle, `0b` measuring) |
| 17 | `ff` |
| 18–19 | `00`, XOR trailer |

## History streams

`0x4c` = 2.5-minute epoch, 23 bytes, end-timestamped (`verified-on-device`):

| Off | Field |
|---|---|
| 0–3 | cursor (+150 per record) |
| 4 | heart rate bpm (`< 30` / `4` = off-finger error) |
| 5 | HRV RMSSD ms (`0` = rejected) |
| 6 | PPG quality 0–10 |
| 7 | respiratory rate ×10 brpm (`0` invalid, floor 105) |
| 8 | SpO2 % (`18` not scheduled, `17` failed) |
| 9 | activity MET ×10 (`10` = rest) |
| 10–14 | 5 × 30 s ambient light (`1` = dark floor) |
| 15–22 | 5 × 12-bit motion energy + 4-bit flags (bit 2 = SpO2 slot, bit 1 = high motion) |

`0x47` = 15-minute block, 47 bytes, end-timestamped (`verified-on-device`):

| Off | Field |
|---|---|
| 0–3 | cursor (+900 per record) |
| 4 | `02` constant |
| 5 | battery % in bits 7..1, bit 0 = activity flag |
| 6–7 | steps, BE u16 |
| 8 | active time, multiples of 5 s |
| 9–46 | 4 pad bits + 15 × (outer NTC u10, inner NTC u10), 0.05 °C |

Additional history opcodes (`documented-unverified`):
- `0x4f` (ACK `cf 00 00`): Sleep index table — `[4f][rem BE16][N × (startRel BE32, endRel BE32)][xor]`.
- `0x4b` / `0x51` (ACKs `cb` / `d1 <00|01> 00`): Legacy / Sleep Pro compressed PPG sectors.
- `0x32` / `0x35` (ACKs `b2` / `b5 00 00`): Auto offline BP raw / compressed sectors.
- `0x34` / `0x48` / `0x45` / `0x46` (ACKs `b4`/`c8`/`c5`/`c6 00 00`): OSA streams.
- `0x41` / `0x4d` / `0x4a` / `0x42` / `0x4e` (ACKs `c1`/`cd`/`ca`/`c2`/`ce 00 00`): History / auto / realtime sports.

Page header byte `[2]` on `0x4c`/`0x47` = records still queued after this page; a drain
ends at `0` with no sentinel frame.

## Realtime sensor streams (`verified-on-device`)

- **`0x13` (160 B) — 25 Hz 3-axis accelerometer**:
  header `[0..5]`, 25 × `(x s16be, y s16be, z s16be)` at `[6..155]`, 24-bit sample counter
  at `[156..158]` (40 ms/sample = 25 Hz), XOR at `[159]`. Resting captures show
  `sqrt(x^2 + y^2 + z^2) ≈ 1024` (1g).
- **`0x12` (135 B) — 4-channel optical PPG**:
  BE16 seq, 10 × 4 channels of 24-bit BE (`led_G`, `led_G_Amb`, `led_Red_Amb`, `led_IR`),
  24-bit counter (+10/frame), XOR trailer.

## Hazards

- A realtime mode left running suppresses history recording; always stop with `06 00 00`
  and verify idle state via `07 00 00`.
- History has a single shared resume pointer: ACKing pages advances the ring's cursor and
  removes those pages from the backlog seen by any other client. Avoid `07 00 00` mid-drain.
- Never probe `08` (`08 05` enters charger-only deep sleep), `09` (OTA), `02 01`/`02 02`
  (unbound/factory), or `03` (bind) on a primary ring.
- Battery: ~0.26 %/h overnight when worn but disconnected; a permanently open BLE link
  roughly doubles draw. Disabling unused background monitors (`05 23` auto-sports,
  `05 24` Sleep Pro PPG, `05 25` auto BP, `05 22` OSA) is the firmware-supported lever.
