# BLE channel contract

The foreground Flutter app owns the RingConn protocol and database. Native
code owns permissions, discovery, Device Information reads, pairing,
notification subscription, and GATT writes. Both mobile targets use
Flutter's standard codecs on the platform main thread.

## Methods on `ringconn/ble`

| Method | Arguments | Completion |
| --- | --- | --- |
| `startScan` | none | Starts a 15-second unfiltered scan or requests access. On iOS the scan can start after the central powers on. |
| `stopScan` | none | Stops discovery and retains devices from the current scan. |
| `connect` | `{id: String}` | Accepts a device from the current scan. Wait for `ready` before subscribing. |
| `subscribe` | none | Resolves when notifications are enabled. The system may display a Bluetooth pairing prompt. |
| `write` | `{bytes: Uint8List}` | Resolves on the ATT write response. A FIFO queue allows one outstanding GATT write with response. |
| `disconnect` | none | Cancels the link and fails pending operations. |

Methods return `null` on success. Failed methods return a platform error
with a code and message. One scan and one connection are supported. The app
listens to events before starting a scan. Removing that listener closes BLE.

## Events on `ringconn/ble/events`

| `type` | Additional fields |
| --- | --- |
| `scan` | `active: bool` |
| `device` | `id: String`, `name: String`, `rssi: int`. ID is the Android address or iOS CoreBluetooth UUID. |
| `ready` | `id: String`, `systemId: Uint8List`, optional `firmware: String` and `serial: String`, `writeLimit: int` |
| `bond` | Android only. `state: String` is `pairing`, `bonded`, or `unbonded`. |
| `notification` | `bytes: Uint8List`, one raw value update. A challenge may arrive before the subscribe method resolves. |
| `error` | `message: String` |
| `disconnected` | `reason: String` |

The main GATT profile is service `8327ad99-2d87-4a22-a8ce-6dd7971c0437`,
write characteristic `8327ad98-2d87-4a22-a8ce-6dd7971c0437`, and notify
characteristic `8327ad97-2d87-4a22-a8ce-6dd7971c0437`. Device Information
service `180A` supplies System ID `2A23`, firmware `2A26`, and serial
`2A25`. Android requests MTU 247 and uses the reported or default ATT
payload limit. CoreBluetooth exposes its negotiated maximum write size.
Android writes CCCD `2902` and retries following a bond if the descriptor
returns insufficient authentication or encryption. iOS pairs through
CoreBluetooth when protected GATT access requires it.
