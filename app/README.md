# Ring Companion

An independent, unofficial local-first companion app compatible with RingConn Gen 2 smart rings. Android and iOS use native BLE,
with framing, authentication and history sync implemented in pure Dart.
Readings and trace packets are stored in the app's SQLite database.

## Build

Use Flutter 3.50 or newer, with the Android SDK and Java 17+ for Android or
Xcode with Swift Package Manager for iOS. A real phone is required to verify
BLE and pairing. Select a development signing team in Xcode for iOS hardware.

Run the following from `app/`.

```sh
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
flutter run -d <device-id>
```

The debug APK is written to `build/app/outputs/flutter-apk/app-debug.apk`.
The Drift bindings are included. Regenerate them after changing the schema.
Run the protocol tests with Dart alone.

```sh
cd packages/ring_protocol
dart pub get
dart test
```

See [BLE channel contract](BLE_CHANNEL.md) for the native interface.

## Connect and authenticate

1. Disconnect the official app from the ring before scanning. The ring can
   disappear from scans while another central holds its connection. Scan
   without a service filter and select the advertised `RingConn Gen2-xxxx`.
2. Connect and discover the write and notify characteristics. Android requests
   MTU 247. Read Device Information and match the System ID to the four-digit
   advertised suffix to resolve the ring's six-byte identity.
3. Enable notifications. Android writes the CCCD and requests a bond if
   access fails for insufficient authentication or encryption. On iOS,
   accept the system pairing prompt if CoreBluetooth presents one.
4. Keep any challenge arriving during subscription, then send status
   `01 00 00`. For `81 00 <challenge> <xor>`, send
   `01 01 <digest[29..31]> 00` where the digest is SM3 over the XOR of the
   last three identity bytes followed by the challenge byte.
5. Wait for a successful `81 01` status before requesting telemetry or
   starting a mode. App authentication repeats on every connection, including
   when the phone already has a Bluetooth bond.

Live HR sends `d0 00 00` before the first live/history operation, then
`06 01 00`, `07 00 00`, and polls with `95 00 00` every two seconds.
Values below 30 are warm-up. Diagnostics can send `06 00 00` to return to
idle. The battery view uses telemetry recorded while connected.

## Sync history

**Sync the official app first** if you need the backlog there. Every history
ACK advances a position shared with the official app.

The app opens channel 0 with the current ring-relative timestamp, which
requests available history through that time. It commits the raw page and
decoded records before sending the page ACK. It then records the confirmed
cursor and progress. Replayed records are deduplicated by physical ring and
record cursor. The saved cursors are local checkpoints. The ring maintains
the shared backlog position.

Epochs and thermal blocks each report their own remaining count. Sync
completes after an acknowledged zero-remaining page from each stream. A stalled
session reopens the same request up to twice and shows a partial or unconfirmed
result if both streams never report completion. Stopping sync disconnects the
ring and preserves committed pages.

Diagnostics exports the latest connection as a JSONL file with raw RX chunks
and TX attempts. Trace files can include health readings. The share sheet
lets you choose where to save or send the file.

## Command console

Open **Diagnostics → Command console** with an authenticated, idle ring.
Enter hex bytes such as `030000` or `03 00 00`, then tap **Send** to write
with response. The log shows UTC timestamps, TX/RX hex, known frame summaries,
and an opcode and byte count for opaque responses. Boundaries for unknown
responses are inferred from the notification stream.

Enter up to 120 comma- or space-separated opcodes to run a scan. The console
sends `[opcode, 00, 00]` with one-second spacing and marks an ACK if it
sees `opcode ^ 0x80` in that command's response window. **Stop scan**,
leaving the screen, or disconnecting ends the scan. **Share command log**
opens the share sheet for `ringconn-command-console.txt` in the app documents
directory. The file persists across app restarts and may contain health data.

## Health Connect (Android only)

On Android, **Auto-export after history sync** is enabled by default in
**Settings → Health Connect (Android)**. Grant Health Connect write
permissions once (from **Settings** or the one-tap prompt on the **History**
tab), and every future ring history sync will silently export newly synced
readings to Health Connect with no extra taps.

When you grant only some permissions, the app exports those types. The
Settings row shows the time and per-metric record counts from the last export
that wrote readings. Epoch data supplies heart rate, 2.5-minute RMSSD in
milliseconds, measured SpO₂, and respiratory rate. Each 15-minute thermal/
activity block supplies step counts and two separate 15-sample skin
temperature records, one per NTC. On iOS, ring history is saved locally in
SQLite (Apple HealthKit is not yet integrated).
The minute samples end at the block cursor. All timestamps use the ring epoch `1577793600` in UTC. Skin temperature
requires a Health Connect version that supports it. Invalid readings and
RMSSD outside Health Connect's 1–200 ms range are skipped.

The Android platform channel uses [Jetpack Health Connect](https://developer.android.com/jetpack/androidx/releases/health-connect)
directly for Android's permission screen, batched writes, stable client
record IDs, and support for skin temperature series. The app uses the
stable 1.1.0 client and loads it only on Android 9 or later, where Health
Connect can be installed or built in. The Dart exporter reads Drift
and records the largest accepted cursor per ring and metric. It also tracks
confirmed writes by cursor so late history can be exported and retries can
resume after a partial write.

## FR02.023 verification

The following files record results from the physical Gen 2 ring on the
Mac. They are the references for this scaffold.

| File | Verified on FR02.023 |
| --- | --- |
| [`tools/ringconn.swift`](../tools/ringconn.swift) | CoreBluetooth pairing and auth, TX/RX framing, descriptors, live HR, PPG modes and history ACKs |
| [`docs/HARDWARE-EVIDENCE.md`](../docs/HARDWARE-EVIDENCE.md) | GATT profile and measured packet and record layouts. Its corrections specify 20-byte telemetry and thermal/activity data in `0x47`. |
| [`PROTOCOL.md`](../PROTOCOL.md) | Wire protocol specification and record layouts |
| [`packages/ring_protocol/test/fixtures/`](packages/ring_protocol/test/fixtures/) | Capture excerpts for live HR, both PPG formats, coalesced responses, and a two-stream drain |

The epoch motion decoder follows the documented five 12-bit samples and
trailing four flag bits. The older CSV decoder includes the flag nibble in
its last motion window. Thermal samples start at byte 9 and end with four
pad bits, as shown by the captures and thermal CSV. Bulk pages use a brief
quiet window because the header has no byte length.

- [ ] Verify pairing, fragmentation at handset MTUs, reconnection after using
  the official app, mode exit, and history sync on physical Android and iOS phones.
- [ ] Replace the template launcher artwork and configure production signing
  before distributing the app.
