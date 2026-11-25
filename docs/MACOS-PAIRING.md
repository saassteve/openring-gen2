# Pairing the ring from macOS (CoreBluetooth)

macOS behaves differently from Android here and the first attempts look like a "dead ring".

## Why it fails naively

- `bluetoothd` only starts SMP (pairing) when a **protected characteristic** returns ATT
  `Insufficient Encryption (0x0F)` or `Insufficient Authentication (0x05)`, or when the
  peripheral sends an SMP Security Request.
- A **CCCD write** (`setNotifyValue`) is intercepted by CoreBluetooth; its `0x05` error
  usually surfaces to the delegate **without** starting SMP. So subscribing first yields
  endless `Authentication is insufficient` and nothing else.
- A bare CLI in a non-GUI context cannot present the pairing sheet. `bluetoothd` hardcodes
  `KeyboardDisplay` + `MITM=1`; the pairing UI is served by `BluetoothUIServer` inside the
  logged-in Aqua session.

## What works

1. Run the client from a GUI-session Terminal (not ssh/launchd), TCC → Bluetooth allowed.
2. Connect, discover `8327ad99-…`, then **write with response to `8327ad98-…` first**
   (e.g. the harmless `01 00 00` status frame) — *before* touching the CCCD.
3. Accept the macOS pairing prompt. Just Works completes silently only if the ring
   advertises `NoInputNoOutput`; this firmware advertises display caps and negotiates
   Numeric Comparison, so a prompt appears.
4. Only after the write succeeds, subscribe to `8327ad97-…`. Retrying the write after a
   `0x05` also works once the bond exists.

`tools/ringconn.swift` now implements this order (status write → subscribe) with retries.

## Clearing a single stale bond (macOS 26)

`blueutil --unpair` is experimental and leaves records behind. Prefer System Settings →
Bluetooth → ⓘ → Forget, or surgically:

```bash
sudo tar czf ~/bt-backup.tgz /Library/Bluetooth        # backup
# Bluetooth OFF first, then delete ONLY the ring's rows
sudo sqlite3 /Library/Bluetooth/com.apple.MobileBluetooth.ledevices.paired.db \
  "DELETE FROM PairedDevices WHERE Address LIKE '%F8:79:99:XX:XX:XX%';"
sudo security delete-generic-password -s BluetoothLE -a "Public <MAC>" /Library/Keychains/System.keychain
sudo pkill bluetoothd
```

Keep only one central connected at a time; the ring stores ~2 bonds. Re-bond order:
Mac first after a clean state, phone last — and never forget on only one side.

## Verification

```bash
/usr/bin/log stream --level debug --predicate '
  process == "bluetoothd" AND subsystem == "com.apple.bluetooth" AND
  category != "Server.LE.Scan" OR process == "BluetoothUIServer"'
```

Success: SMP start, encryption status 0, pairing complete with no `BluetoothUIServer`
prompt on later reconnects. `Pairing Failed reason=3` means the ring wants MITM while the
Mac offered none; `reason=5` means its bond table is full.
