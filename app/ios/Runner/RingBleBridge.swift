import CoreBluetooth
import Flutter
import Foundation

final class RingBleBridge: NSObject, FlutterStreamHandler, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let methods: FlutterMethodChannel
    private let events: FlutterEventChannel
    private var sink: FlutterEventSink?
    private var central: CBCentralManager?
    private var link: CBPeripheral?
    private var closing: CBPeripheral?
    private var discovered: [UUID: CBPeripheral] = [:]
    private var scanActive = false
    private var scanRequested = false
    private var scanTimer: DispatchWorkItem?
    private var timeout: DispatchWorkItem?

    private let serviceID = CBUUID(string: "8327ad99-2d87-4a22-a8ce-6dd7971c0437")
    private let writeID = CBUUID(string: "8327ad98-2d87-4a22-a8ce-6dd7971c0437")
    private let notifyID = CBUUID(string: "8327ad97-2d87-4a22-a8ce-6dd7971c0437")
    private let infoID = CBUUID(string: "180A")
    private let systemID = CBUUID(string: "2A23")
    private let firmwareID = CBUUID(string: "2A26")
    private let serialID = CBUUID(string: "2A25")
    private var discovering: Set<CBUUID> = []
    private var reads: [CBCharacteristic] = []
    private var activeRead: CBUUID?
    private var info: [CBUUID: Data] = [:]
    private var writeChar: CBCharacteristic?
    private var notifyChar: CBCharacteristic?
    private var ready = false
    private var subscribed = false
    private var subscribeResult: FlutterResult?

    private struct WriteRequest {
        let data: Data
        let result: FlutterResult
    }
    private var writes: [WriteRequest] = []
    private var activeWrite: WriteRequest?

    init(messenger: FlutterBinaryMessenger) {
        methods = FlutterMethodChannel(name: "ringconn/ble", binaryMessenger: messenger)
        events = FlutterEventChannel(name: "ringconn/ble/events", binaryMessenger: messenger)
        super.init()
        events.setStreamHandler(self)
        methods.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterError(code: "closed", message: "BLE bridge closed", details: nil))
                return
            }
            self.handle(call, result: result)
        }
    }

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        sink = eventSink
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        stopScan()
        close("Event stream closed")
        return nil
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case "startScan":
            guard link == nil, closing == nil else {
                result(error("scan", "Wait for the ring to disconnect before scanning"))
                return
            }
            stopScan()
            discovered.removeAll()
            scanRequested = true
            if let central {
                switch central.state {
                case .poweredOn: beginScan(central)
                case .unknown, .resetting: break
                default:
                    stopScan()
                    result(error("bluetooth", stateMessage(central.state)))
                    return
                }
            } else {
                central = CBCentralManager(delegate: self, queue: .main)
            }
            scanTimer = schedule(after: 15) { [weak self] in
                guard let self else { return }
                if self.scanRequested {
                    self.emit("error", ["message": "Bluetooth did not become available"])
                }
                self.stopScan()
            }
            result(nil)
        case "stopScan":
            stopScan()
            result(nil)
        case "connect":
            guard link == nil, closing == nil, let central, central.state == .poweredOn,
                  let id = (arguments?["id"] as? String).flatMap(UUID.init(uuidString:)),
                  let peripheral = discovered[id] else {
                result(error("connect", "Select a discovered ring while disconnected"))
                return
            }
            stopScan()
            link = peripheral
            peripheral.delegate = self
            arm(25, "Timed out connecting to the ring")
            central.connect(peripheral)
            result(nil)
        case "disconnect":
            stopScan()
            close("Disconnected")
            result(nil)
        case "subscribe":
            guard ready, let link, let notifyChar, subscribeResult == nil, !subscribed else {
                result(error("subscribe", "GATT is unavailable or already subscribed"))
                return
            }
            // CoreBluetooth handles CCCD access and system pairing.
            subscribeResult = result
            arm(45, "Notification subscription or pairing timed out")
            link.setNotifyValue(true, for: notifyChar)
        case "write":
            guard subscribed, let link, let bytes = arguments?["bytes"] as? FlutterStandardTypedData,
                  !bytes.data.isEmpty, bytes.data.count <= link.maximumWriteValueLength(for: .withResponse)
            else {
                result(error("write", "BLE is unavailable or payload exceeds the ATT limit"))
                return
            }
            guard writes.count < 32 else {
                result(error("write", "BLE write queue is full"))
                return
            }
            writes.append(WriteRequest(data: bytes.data, result: result))
            pumpWrites()
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if scanRequested { beginScan(central) }
        } else if central.state != .unknown {
            let hadWork = scanRequested || scanActive || link != nil
            stopScan()
            close(stateMessage(central.state))
            closing = nil
            if hadWork { emit("error", ["message": stateMessage(central.state)]) }
        }
    }

    private func stateMessage(_ state: CBManagerState) -> String {
        switch state {
        case .unsupported: return "This device does not support Bluetooth LE"
        case .unauthorized: return "Allow Bluetooth access in Settings"
        case .poweredOff: return "Turn on Bluetooth to scan"
        default: return "Bluetooth is unavailable"
        }
    }

    private func beginScan(_ central: CBCentralManager) {
        scanRequested = false
        scanActive = true
        central.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
        emit("scan", ["active": true])
    }

    private func stopScan() {
        scanTimer?.cancel()
        scanTimer = nil
        let wasScanning = scanActive || scanRequested
        scanRequested = false
        scanActive = false
        if central?.state == .poweredOn { central?.stopScan() }
        if wasScanning { emit("scan", ["active": false]) }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        guard scanActive,
              let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name,
              name.localizedCaseInsensitiveContains("RingConn Gen2") else { return }
        discovered[peripheral.identifier] = peripheral
        emit("device", ["id": peripheral.identifier.uuidString, "name": name, "rssi": RSSI])
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral === link else { return }
        arm(8, "Service discovery timed out")
        peripheral.discoverServices([serviceID, infoID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if peripheral === closing { closing = nil }
        guard peripheral === link else { return }
        fail(error?.localizedDescription ?? "Could not connect to the ring")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral === closing { closing = nil }
        guard peripheral === link else { return }
        close(error?.localizedDescription ?? "Ring disconnected")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral === link else { return }
        guard error == nil, let services = peripheral.services,
              let primary = services.first(where: { $0.uuid == serviceID }),
              let deviceInfo = services.first(where: { $0.uuid == infoID }) else {
            fail(error?.localizedDescription ?? "The ring did not expose the expected GATT services")
            return
        }
        discovering = [serviceID, infoID]
        arm(8, "Characteristic discovery timed out")
        peripheral.discoverCharacteristics([writeID, notifyID], for: primary)
        peripheral.discoverCharacteristics([systemID, firmwareID, serialID], for: deviceInfo)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard peripheral === link, discovering.remove(service.uuid) != nil else { return }
        guard error == nil, let characteristics = service.characteristics else {
            fail(error?.localizedDescription ?? "Could not discover ring characteristics")
            return
        }
        if service.uuid == serviceID {
            writeChar = characteristics.first { $0.uuid == writeID && $0.properties.contains(.write) }
            notifyChar = characteristics.first { $0.uuid == notifyID && $0.properties.contains(.notify) }
        } else {
            reads = [systemID, firmwareID, serialID].compactMap { uuid in
                characteristics.first { $0.uuid == uuid && $0.properties.contains(.read) }
            }
        }
        if discovering.isEmpty {
            guard writeChar != nil, notifyChar != nil else {
                fail("The ring did not expose write and notify characteristics")
                return
            }
            readNext(peripheral)
        }
    }

    private func readNext(_ peripheral: CBPeripheral) {
        if !reads.isEmpty {
            let characteristic = reads.removeFirst()
            activeRead = characteristic.uuid
            arm(8, "Device Information read timed out")
            peripheral.readValue(for: characteristic)
            return
        }
        disarm()
        guard let identity = info[systemID] else {
            fail("Could not read the ring System ID")
            return
        }
        ready = true
        var fields: [String: Any] = [
            "id": peripheral.identifier.uuidString,
            "systemId": FlutterStandardTypedData(bytes: identity),
            "writeLimit": peripheral.maximumWriteValueLength(for: .withResponse),
        ]
        for (key, uuid) in [("firmware", firmwareID), ("serial", serialID)] {
            if let data = info[uuid], let text = String(data: data, encoding: .utf8) {
                fields[key] = text.trimmingCharacters(in: CharacterSet(charactersIn: "\0"))
            }
        }
        emit("ready", fields)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral === link else { return }
        if characteristic.uuid == activeRead {
            activeRead = nil
            if error == nil { info[characteristic.uuid] = characteristic.value }
            readNext(peripheral)
        } else if characteristic.uuid == notifyID {
            if let error {
                fail(error.localizedDescription)
            } else if let data = characteristic.value {
                emit("notification", ["bytes": FlutterStandardTypedData(bytes: data)])
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral === link, characteristic.uuid == notifyID,
              let result = subscribeResult else { return }
        guard error == nil, characteristic.isNotifying else {
            fail(error?.localizedDescription ?? "Could not enable ring notifications")
            return
        }
        disarm()
        subscribeResult = nil
        subscribed = true
        result(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral === link, characteristic.uuid == writeID, let request = activeWrite else { return }
        disarm()
        activeWrite = nil
        if let error {
            request.result(self.error("write", error.localizedDescription))
            fail(error.localizedDescription)
        } else {
            request.result(nil)
            pumpWrites()
        }
    }

    private func pumpWrites() {
        guard let link, let writeChar, activeWrite == nil, !writes.isEmpty else { return }
        let request = writes.removeFirst()
        activeWrite = request
        arm(8, "GATT write response timed out")
        link.writeValue(request.data, for: writeChar, type: .withResponse)
    }

    private func schedule(after seconds: TimeInterval, _ body: @escaping () -> Void) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: body)
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: item)
        return item
    }

    private func arm(_ seconds: TimeInterval, _ message: String) {
        disarm()
        timeout = schedule(after: seconds) { [weak self] in self?.fail(message) }
    }

    private func disarm() {
        timeout?.cancel()
        timeout = nil
    }

    private func error(_ code: String, _ message: String) -> FlutterError {
        FlutterError(code: code, message: message, details: nil)
    }

    private func emit(_ type: String, _ fields: [String: Any]) {
        var event = fields
        event["type"] = type
        sink?(event)
    }

    private func fail(_ message: String) {
        emit("error", ["message": message])
        close(message)
    }

    private func close(_ reason: String) {
        disarm()
        let previous = link
        link = nil
        writeChar = nil
        notifyChar = nil
        reads.removeAll()
        discovering.removeAll()
        info.removeAll()
        activeRead = nil
        ready = false
        subscribed = false
        subscribeResult?(error("subscribe", reason))
        subscribeResult = nil
        activeWrite?.result(error("write", reason))
        activeWrite = nil
        for request in writes { request.result(error("write", reason)) }
        writes.removeAll()
        if let previous {
            if previous.state != .disconnected, central?.state == .poweredOn {
                closing = previous
                central?.cancelPeripheralConnection(previous)
            }
            emit("disconnected", ["reason": reason])
        }
    }
}
