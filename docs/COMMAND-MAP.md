# Wire Protocol Command Map

Functional summary of BLE command and notification families for compatible
Gen 2 smart rings (tested on firmware `FR02.023`).

Confidence tags:
- **`verified-on-device`**: observed and verified on physical `FR02.023` hardware.
- **`inactive-on-FR02.023`**: probed on `FR02.023` with no reply (feature absent or firmware-gated).
- **`documented-unverified`**: known wire command family not yet exercised on live `FR02.023` hardware (many are destructive or factory-only).

## Command & notification families

| Category | TX Command (Hex) | RX Opcode | Status | Notes |
|---|---|---|---|---|
| Authentication | `01 00 00`, `01 01 <sm3[29..31]> 00` | `81 00`, `81 01` (38 B) | `verified-on-device` | `81 01` includes `ecoMode` `[16]`, `monitorStatus` `[17]`, `monitorPlanStatus` `[18]`, `mtu` `[31]`, `curUtc` `[32..35]`, `sportsMonitor` `[36]`. |
| Work Mode & Sync | `02 <00\|01\|02> <utc BE4> [int] [sys] 00` | `82 <status> [00] <xor>` | `verified-on-device` (`02 00`) | `00` Normal + history sync, `01` Unbound (do not probe), `02` Factory mode (do not probe). |
| User Binding | `03 <uid BE4> <profile...> 00` | `83 <status> <xor>` | `documented-unverified` | Writes user profile / binding state (do not probe on primary ring). |
| Background Parameters | `05 <22\|23\|24\|25\|30> <val...> 00` | `85 00 85` or `85 <id> <status> <xor>` | `verified-on-device` (`23`, `25`) | `22` OSA plan, `23` Auto-Sports, `24` Sleep Pro PPG, `25` Auto offline BP, `30` Gen 3 haptics config. No raw HR/SpO2 cadence setters are exposed. |
| Realtime Mode Control | `06 <00\|01\|02\|03\|05\|10> ... 00` | `86 <status> <xor>` | `verified-on-device` (`00`,`01`,`02`,`05`,`10`) | `00` stop, `01` HR, `02` SpO2, `03 <sport> 04` Sport, `05` Dense 4-ch PPG, `10` optical prime. |
| Telemetry Poll | `07 00 00` | `87 <18B> <xor>` (20 B) | `verified-on-device` | Active poll of battery %, voltage, dual NTC temperatures, wear & mode flags. |
| System Control | `08 <01..05> 00` | `88 <status> <xor>` | `documented-unverified` | `01`–`03` reboot/reset/shutdown, `04` flight mode, `05` stockpile deep-sleep (requires physical charger to wake — do not probe). |
| Bootloader / DFU | `09 <params...> 00` | `89 <status> <xor>` | `documented-unverified` | Enters OTA bootloader (do not probe). |
| Legacy OSA Query | `0a ... 00` | `8a ... <xor>` | `documented-unverified` | Legacy offline OSA request. |
| Gen 3 Haptics | `0b 03 <pat> 64 00`, `25 00 00` | `8b`, `a5` | `inactive-on-FR02.023` | Vibration trigger & stop (Gen 3 hardware only; silent on Gen 2). |
| Passive Telemetry | *(unsolicited)* | `10 <18B> <xor>` (20 B) | `verified-on-device` | Periodic push with the same 20-byte body as `0x87`. |
| Event Notifications | ACK `91 00 00` | `11 <err> <st> <ev> <xor>` | `verified-on-device` | Wear (`03`), off-finger (`04`), HR alerts (`05`/`06`), low battery (`09`), memory full (`0a`), weak signal (`0b`). |
| Realtime 4-ch PPG | *(streamed under `06 02` / `06 05`)* | `12` (135 B) | `verified-on-device` | 10 × 4 × 24-bit optical channels (`led_G`, `led_G_Amb`, `led_Red_Amb`, `led_IR`). |
| Realtime 3-Axis ACC | `23 03 00` (or under `06 02`; pull `96 01 00 00 00`) | `13` (160 B) | `verified-on-device` | 25 Hz 3-axis accelerometer (`25 × s16be x,y,z`, 1 Hz frames); stop with `06 00 00`. |
| Realtime HR Poll | `95 00 00` | `15 00 <hr> ... <xor>` (6 B) | `verified-on-device` | Polled every ~2 s during active live measurement. |
| Exit Factory Mode | `20 01 00` | `a0 <status> <xor>` | `documented-unverified` | Exits `02 02` factory mode. |
| Sensor / LED Diagnostics | `22 <mode> 00`, `23 03 00`, `24 01 00` | `a2`, `a3`, `a4` | `verified-on-device` | `22 00 00` → `a2 00 a2`, `23 03 00` → `a3 00 a3` + live `0x13` ACC, `24 01 00` → `a4 00 a4`. |
| Temperature Query | `29 00 00` | `a9 <ntc1:s16be> <ntc2:s16be> 00 00 00 00 <xor>` (10 B) | `verified-on-device` | Read-only dual-NTC sensor temperature (0.1 °C). |
| History Epochs & Thermal | ACKs `cc 00 00`, `c7 00 00` (legacy `9e`/`c0`, `9c`/`c4`/`c3`) | `4c` (23 B/rec), `47` (47 B/rec) | `verified-on-device` | 2.5-minute epochs (`4c`: HR, HRV, SpO2, RR, MET, ambient, motion) and 15-minute thermal/activity blocks (`47`: steps, battery, dual NTC). |
| Auto Offline BP History | ACKs `b2 00 00`, `b5 00 00` | `32` (raw), `35` (compressed) | `documented-unverified` | Controlled via `05 25 <00\|01> 00`. |
| OSA History Streams | ACKs `b4`/`c8`/`c5`/`c6 00 00` | `34`/`48`, `45`, `46` | `documented-unverified` | Controlled via `05 22 <00\|01\|02> 00`. |
| Sports History & Live | ACKs `c1`/`cd`/`ca`/`c2`/`ce 00 00` | `41`/`4d`, `4a`, `42`/`4e` | `documented-unverified` | Started via `06 03 <type> 04 00` or auto-sports `05 23 01 00`. |
| Sleep Index Table | ACK `cf <00\|01> 00` | `4f <rem BE16> <N×8B> <xor>` | `documented-unverified` | Sleep segment intervals `(startRel BE32, endRel BE32)`. |
| Compressed PPG Sectors | ACKs `cb`/`d1 <00\|01> 00` | `4b` (legacy), `51` (Sleep Pro) | `documented-unverified` | Sleep Pro storage toggled via `05 24 <00\|01> 00`. |
| Ring Logs & Debug Trace | `55 00 00`; ACK `d0 00 00` | `d5 ...`, `50 ...` | `inactive-on-FR02.023` (`55`) | `55 00 00` is silent on `FR02.023`; `d0 00 00` acknowledges `0x50` ring log chunks. |
