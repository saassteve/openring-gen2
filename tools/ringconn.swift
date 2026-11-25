// RingConn Gen 2 BLE probe (macOS CoreBluetooth)
// Protocol per community RE notes; auth = SM3([mac3^mac4^mac5, challenge])[29..31]
import Foundation
import CoreBluetooth

// ---------------------------------------------------------------- SM3 (GB/T 32905-2016)

@inline(__always) func rotl(_ x: Int32, _ n: Int32) -> Int32 {
    let s = n % 32
    return (x << s) | (Int32(bitPattern: UInt32(bitPattern: x) >> UInt32(32 - s)))
}
@inline(__always) func p0(_ x: Int32) -> Int32 { x ^ rotl(x, 9) ^ rotl(x, 17) }
@inline(__always) func p1(_ x: Int32) -> Int32 { x ^ rotl(x, 15) ^ rotl(x, 23) }

func sm3(_ data: [UInt8]) -> [UInt8] {
    var msg = data
    msg.append(0x80)
    while msg.count % 64 != 56 { msg.append(0) }
    let bitLen = UInt64(data.count) * 8
    for i in stride(from: 56, through: 0, by: -8) { msg.append(UInt8((bitLen >> UInt64(i)) & 0xff)) }
    var v: [Int32] = [0x7380166f, 0x4914b2b9, 0x172442d7, Int32(bitPattern: 0xda8a0600),
                      Int32(bitPattern: 0xa96f30bc), 0x163138aa, Int32(bitPattern: 0xe38dee4d), Int32(bitPattern: 0xb0fb0e4e)]
    var w = [Int32](repeating: 0, count: 68)
    var w1 = [Int32](repeating: 0, count: 64)
    for blk in stride(from: 0, to: msg.count, by: 64) {
        for j in 0..<16 {
            let o = blk + 4 * j
            w[j] = (Int32(msg[o]) << 24) | (Int32(msg[o+1]) << 16) | (Int32(msg[o+2]) << 8) | Int32(msg[o+3])
        }
        for j in 16..<68 {
            w[j] = p1(w[j-16] ^ w[j-9] ^ rotl(w[j-3], 15)) ^ rotl(w[j-13], 7) ^ w[j-6]
        }
        for j in 0..<64 { w1[j] = w[j] ^ w[j+4] }
        var a = v[0], b = v[1], c = v[2], d = v[3], e = v[4], f = v[5], g = v[6], h = v[7]
        for j in 0..<64 {
            let t: Int32 = j < 16 ? 0x79cc4519 : Int32(bitPattern: 0x7a879d8a)
            let ss1 = rotl(rotl(a, 12) &+ e &+ rotl(t, Int32(j % 32)), 7)
            let ss2 = ss1 ^ rotl(a, 12)
            let ff: Int32 = j < 16 ? (a ^ b ^ c) : ((a & b) | (a & c) | (b & c))
            let gg: Int32 = j < 16 ? (e ^ f ^ g) : ((e & f) | (~e & g))
            let tt1 = ff &+ d &+ ss2 &+ w1[j]
            let tt2 = gg &+ h &+ ss1 &+ w[j]
            d = c; c = rotl(b, 9); b = a; a = tt1
            h = g; g = rotl(f, 19); f = e; e = p0(tt2)
        }
        v[0] ^= a; v[1] ^= b; v[2] ^= c; v[3] ^= d
        v[4] ^= e; v[5] ^= f; v[6] ^= g; v[7] ^= h
    }
    var out = [UInt8]()
    for x in v { out += [UInt8((x >> 24) & 0xff), UInt8((x >> 16) & 0xff), UInt8((x >> 8) & 0xff), UInt8(x & 0xff)] }
    return out
}

func hex(_ s: String) -> [UInt8] {
    var out = [UInt8](); var i = s.startIndex
    while i < s.endIndex {
        let j = s.index(i, offsetBy: 2)
        out.append(UInt8(s[i..<j], radix: 16)!); i = j
    }
    return out
}
func hexs(_ b: [UInt8]) -> String { b.map { String(format: "%02x", $0) }.joined(separator: " ") }

// self-test against GB/T 32905 example 1 + captured ring pair
func selfTest() -> Bool {
    let a = hexs(sm3(Array("abc".utf8)))
    let expected = "66 c7 f0 f4 62 ee ed d9 d1 f2 d4 6b dc 10 e4 e2 41 67 c4 87 5c f2 f7 a2 29 7d a0 2b 8f 4b a8 e0"
    let mac: [UInt8] = hex("f87999f703ad")
    let x = mac[3] ^ mac[4] ^ mac[5]
    let r = Array(sm3([x, 0xb0])[29..<32])
    let rhex = hexs(r)
    print("SM3(abc)     = \(a)\nSM3(auth b0) = \(rhex)")
    return a == expected && rhex == "31 82 67" && x == 0x59
}

// ---------------------------------------------------------------- UUIDs
let SVC  = CBUUID(string: "8327ad99-2d87-4a22-a8ce-6dd7971c0437")
let WRITE = CBUUID(string: "8327ad98-2d87-4a22-a8ce-6dd7971c0437")
let NOTIFY = CBUUID(string: "8327ad97-2d87-4a22-a8ce-6dd7971c0437")
let SVC2 = CBUUID(string: "1d14d6ee-fd63-4fa1-bfa4-8f47b42119f0")
let W2 = CBUUID(string: "f7bf3564-fb6d-4e53-88a4-5e37e0326063")
let N2 = CBUUID(string: "984227f3-34fc-4045-a5d0-2c581f81a153")
let DIS = CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")
let SYSID = CBUUID(string: "00002a23-0000-1000-8000-00805f9b34fb")
let FW = CBUUID(string: "00002a26-0000-1000-8000-00805f9b34fb")
let SERIAL = CBUUID(string: "00002a25-0000-1000-8000-00805f9b34fb")

func log(_ s: String) {
    let f = DateFormatter(); f.dateFormat = "HH:mm:ss.SSS"
    print("\(f.string(from: Date()))  \(s)"); fflush(stdout)
}

// ---------------------------------------------------------------- BLE
class Probe: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var central: CBCentralManager!
    var target: CBPeripheral?
    var nameSub: String
    var seconds: Double
    var scanOnly: Bool
    var w: CBCharacteristic?
    var n: CBCharacteristic?
    var w2: CBCharacteristic?
    var n2: CBCharacteristic?
    var mac: [UInt8]?
    var expectTail = ""
    var started = false
    var pendingChallenge: UInt8?
    var live = false
    var ppg13Mode = false
    var denseMode = false
    var historyMode = false
    var dumpAll = false
    var batteryMode = false
    var noAck = false
    var batteryInterval: Double = 60
    var gestureMode = false
    var onTapCmd: String? = nil
    var onDoubleTapCmd: String? = nil
    var onFlickCmd: String? = nil
    var gInit = false
    var gGravX = 0.0, gGravY = 0.0, gGravZ = 1.0
    var gPrevX = 0.0, gPrevY = 0.0, gPrevZ = 1.0
    var gSampleIdx = 0
    var gInTap = false
    var gTapSamples = 0
    var gTapPeakG = 0.0
    var gTapPeakSample = -100
    var gLastTapPeak = -100
    var gRotStreak = 0
    var gLastFlickSample = -100
    var gPendingTap: (peakG: Double, sample: Int)? = nil

    var histCh = 0
    var pages = 0
    var records = 0
    var histEndSeen = false
    var lastDesc = ""
    var trace: FileHandle?
    var traceStart = Date()
    var poll07: Double = 0
    var poll07Count = 0
    var ppg13Count = 0
    var ppg12Count = 0
    var hrNow = 0
    var authed = false
    var pendingCmds: [[UInt8]]
    var cmdTimer: Timer?
    var pollTimer: Timer?

    init(nameSub: String, seconds: Double, scanOnly: Bool, cmds: [[UInt8]], liveMode: Bool = false,
         tracePath: String? = nil, poll07: Double = 0, poll07Count: Int = 0, ppg13: Bool = false, dense: Bool = false, hist: Bool = false, noack: Bool = false, dump: Bool = false, battery: Bool = false, interval: Double = 60,
         gestures: Bool = false, onTap: String? = nil, onDoubleTap: String? = nil, onFlick: String? = nil) {
        self.nameSub = nameSub; self.seconds = seconds; self.scanOnly = scanOnly
        self.pendingCmds = cmds
        self.live = liveMode
        self.poll07 = poll07; self.poll07Count = poll07Count; self.ppg13Mode = ppg13; self.denseMode = dense
        self.historyMode = hist; self.noAck = noack; self.dumpAll = dump; self.batteryMode = battery; self.batteryInterval = interval
        self.gestureMode = gestures; self.onTapCmd = onTap; self.onDoubleTapCmd = onDoubleTap; self.onFlickCmd = onFlick
        if let tp = tracePath {
            FileManager.default.createFile(atPath: tp, contents: nil)
            trace = FileHandle(forWritingAtPath: tp)
            trace?.truncateFile(atOffset: 0)
        }
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ c: CBCentralManager) {
        log("central state: \(c.state.rawValue) auth: \(c.authorization.rawValue)")
        guard c.state == .poweredOn else { return }
        if scanOnly {
            c.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { c.stopScan(); log("scan done"); exit(0) }
        } else {
            // Already-connected check (macOS hides connected peripherals from scans)
            for p in c.retrieveConnectedPeripherals(withServices: [SVC, DIS]) {
                log("already connected: \(p.name ?? p.identifier.uuidString)")
                target = p; p.delegate = self
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { p.discoverServices([SVC, DIS]) }
            }
            c.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            DispatchQueue.main.asyncAfter(deadline: .now() + 240) {
                if self.target == nil { log("not found in 240 s"); exit(2) }
            }
        }
    }

    func centralManager(_ c: CBCentralManager, didDiscover p: CBPeripheral, advertisementData d: [String: Any], rssi: NSNumber) {
        let name = (d[CBAdvertisementDataLocalNameKey] as? String) ?? p.name ?? ""
        let mf = d[CBAdvertisementDataManufacturerDataKey] as? Data
        if scanOnly {
            let su = (d[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID])?.map { $0.uuidString }.joined(separator: ",") ?? "-"
            log("ADV name=\(name.isEmpty ? "-" : name) cached=\(p.name ?? "-") rssi=\(rssi) svc=\(su) mf=\(mf.map { $0.map { String(format: "%02x", $0) }.joined() } ?? "-") conn=\((d[CBAdvertisementDataIsConnectable] as? Bool) ?? false)")
            return
        }
        guard target == nil, name.localizedCaseInsensitiveContains(nameSub) || (nameSub.isEmpty && d[CBAdvertisementDataServiceUUIDsKey] != nil) else { return }
        log("found \(name) rssi=\(rssi) mf=\(mf.map { $0.map { String(format: "%02x", $0) }.joined() } ?? "-")")
        // MAC hint from advertised name suffix e.g. "RingConn Gen2-03AD"
        if let suf = name.split(separator: "-").last, suf.count == 4 { expectTail = suf.uppercased(); log("expected MAC tail from name: \(expectTail)") }
        c.stopScan()
        target = p; p.delegate = self
        c.connect(p, options: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            switch p.state {
            case .connecting: log("connect timeout -> cancel"); c.cancelPeripheralConnection(p)
            default: break
            }
        }
    }

    func centralManager(_ c: CBCentralManager, didConnect p: CBPeripheral) {
        log("connected; discovering services")
        DispatchQueue.main.asyncAfter(deadline: .now() + max(20, seconds - 3)) { log("time limit reached"); exit(0) }
        p.discoverServices(dumpAll ? nil : [SVC, DIS, SVC2])
    }

    var connectRetries = 0
    func centralManager(_ c: CBCentralManager, didFailToConnect p: CBPeripheral, error: Error?) {
        log("connect failed (\(connectRetries)): \(error?.localizedDescription ?? "?")")
        connectRetries += 1
        if connectRetries < 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { c.connect(p, options: nil) }
        } else { exit(3) }
    }

    func centralManager(_ c: CBCentralManager, didDisconnectPeripheral p: CBPeripheral, error: Error?) {
        log("disconnected: \(error?.localizedDescription ?? "-")"); exit(0)
    }

    func peripheral(_ p: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error { log("discoverServices: \(e)"); exit(4) }
        for s in p.services ?? [] {
            log("service \(s.uuid)")
            p.discoverCharacteristics(nil, for: s)
        }
    }

    func peripheral(_ p: CBPeripheral, didDiscoverCharacteristicsFor s: CBService, error: Error?) {
        for ch in s.characteristics ?? [] {
            log("  char \(ch.uuid) props=\(ch.properties.rawValue)")
            if ch.uuid == WRITE { w = ch }
            if ch.uuid == NOTIFY { n = ch }
            if ch.uuid == W2 { w2 = ch }
            if ch.uuid == N2 { n2 = ch }
        }
        // read DIS strings when we discover them
        for ch in s.characteristics ?? [] where [SYSID, FW, SERIAL].contains(ch.uuid) {
            p.readValue(for: ch)
        }
        if dumpAll {
            for ch in s.characteristics ?? [] where ch.properties.contains(.read) {
                log("  DUP read \(ch.uuid)")
                p.readValue(for: ch)
            }
        }
        if s.uuid == SVC {
            log("svc chars ready (write=\(w != nil) notify=\(n != nil)); waiting for System ID before subscribing")
            maybeStart(p)
        }
        if s.uuid == DIS, let sys = (s.characteristics ?? []).first(where: { $0.uuid == SYSID }) {
            p.readValue(for: sys)
        }
    }

    var sessionStarted = false
    var authConfirmed = false

    func maybeStart(_ p: CBPeripheral) {
        guard !started, mac != nil, w != nil, n != nil else { return }
        started = true
        // macOS only initiates SMP on a protected characteristic write/read, not on a CCCD write.
        log("sending STATUS 010000 first (triggers pairing)")
        p.writeValue(Data([0x01, 0x00, 0x00]), for: w!, type: .withResponse)
    }

    func startSession(_ p: CBPeripheral) {
        guard !sessionStarted, let w = w else { return }
        sessionStarted = true
        if let ch = pendingChallenge { answer(ch, p) }
        if gestureMode { startGestures(p) } else if batteryMode { startBattery(p) } else if historyMode { startHistory(p) } else if denseMode { startDense(p) } else if ppg13Mode { startPpg13(p) } else if live { startLive(p) } else { runCmdSchedule() }
        if poll07 > 0 {
            var n = 0
            let t = Timer.scheduledTimer(withTimeInterval: poll07, repeats: true) { tt in
                guard self.authConfirmed else { return }
                self.tx([0x07, 0x00, 0x00], on: p, w: w)
                n += 1
                if self.poll07Count > 0 && n >= self.poll07Count { tt.invalidate() }
            }
            pollTimer = t
        }
    }

    func startBattery(_ p: CBPeripheral) {
        guard let w = w else { return }
        log("BATT: sampling every \(Int(batteryInterval))s")
        tx([0xd0, 0x00, 0x00], on: p, w: w)
        pollTimer = Timer.scheduledTimer(withTimeInterval: batteryInterval, repeats: true) { _ in
            guard self.authed else { return }
            self.tx([0x07, 0x00, 0x00], on: p, w: w)
        }
    }

    func startGestures(_ p: CBPeripheral) {
        log("GESTURES: armed (25 Hz 0x13), waiting for auth")
        DispatchQueue.main.asyncAfter(deadline: .now() + max(2.0, seconds - 1.5)) {
            if let w = self.w {
                log("GESTURES: stopping stream (06 00 00)")
                self.tx([0x06, 0x00, 0x00], on: p, w: w)
            }
        }
    }

    func runGestureHook(_ shellCmd: String?, label: String, peakG: Double) {
        log(String(format: "GESTURE: %@ (peak=%.2fg)", label, peakG))
        guard let cmd = shellCmd, !cmd.isEmpty else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/bin/sh")
            proc.arguments = ["-c", cmd]
            try? proc.run()
        }
    }

    func processAccGestures(_ b: [UInt8]) {
        guard b.count >= 156 else { return }
        let tapThresh = 0.34
        let flickAngleDeg = 45.0
        for s in 0..<25 {
            let off = 6 + s * 6
            let ax = Double(Int16(bitPattern: (UInt16(b[off]) << 8) | UInt16(b[off + 1]))) / 1024.0
            let ay = Double(Int16(bitPattern: (UInt16(b[off + 2]) << 8) | UInt16(b[off + 3]))) / 1024.0
            let az = Double(Int16(bitPattern: (UInt16(b[off + 4]) << 8) | UInt16(b[off + 5]))) / 1024.0
            let magG = sqrt(ax * ax + ay * ay + az * az)
            if !gInit {
                gInit = true
                gGravX = ax; gGravY = ay; gGravZ = az
                gPrevX = ax; gPrevY = ay; gPrevZ = az
            }
            let gravNorm = max(1e-6, sqrt(gGravX * gGravX + gGravY * gGravY + gGravZ * gGravZ))
            let dx = ax - gGravX, dy = ay - gGravY, dz = az - gGravZ
            let linG = sqrt(dx * dx + dy * dy + dz * dz)
            let jx = ax - gPrevX, jy = ay - gPrevY, jz = az - gPrevZ
            let jerkG = sqrt(jx * jx + jy * jy + jz * jz)
            let dot = ax * gGravX + ay * gGravY + az * gGravZ
            let cosAngle = min(1.0, max(-1.0, dot / max(1e-6, magG * gravNorm)))
            let angleDeg = acos(cosAngle) * (180.0 / .pi)
            // Positive impact above resting gravity (ignores <1g wind-up finger lift).
            let posImpactG = max(0.0, magG - gravNorm)

            var emitted = false
            // 1. Wrist flick: sustained 3D gravity-vector rotation (>= 120 ms).
            if angleDeg >= flickAngleDeg && magG < 1.65 {
                gRotStreak += 1
                if gRotStreak == 3 && (gSampleIdx - gLastFlickSample) >= 20 {
                    gLastFlickSample = gSampleIdx
                    gPendingTap = nil
                    gInTap = false
                    emitted = true
                    runGestureHook(onFlickCmd, label: "flick", peakG: angleDeg)
                }
            } else {
                gRotStreak = 0
            }

            // 2. Tap / Double tap: crisp positive impact with steady orientation.
            if !emitted {
                if !gInTap {
                    if posImpactG >= tapThresh && jerkG >= tapThresh && angleDeg < 38.0 && (gSampleIdx - gLastFlickSample) >= 12 {
                        gInTap = true
                        gTapSamples = 1
                        gTapPeakG = posImpactG
                        gTapPeakSample = gSampleIdx
                    }
                } else if posImpactG >= tapThresh * 0.5 && gTapSamples <= 4 {
                    gTapSamples += 1
                    if posImpactG > gTapPeakG {
                        gTapPeakG = posImpactG
                        gTapPeakSample = gSampleIdx
                    }
                } else {
                    gInTap = false
                    if gTapSamples <= 4 && (gTapPeakSample - gLastTapPeak) >= 5 {
                        gLastTapPeak = gTapPeakSample
                        if let prev = gPendingTap, (gTapPeakSample - prev.sample) <= 18 {
                            gPendingTap = nil
                            emitted = true
                            runGestureHook(onDoubleTapCmd, label: "double-tap", peakG: gTapPeakG)
                        } else {
                            gPendingTap = (gTapPeakG, gTapPeakSample)
                        }
                    }
                }
            }

            if !emitted && !gInTap, let prev = gPendingTap, (gSampleIdx - prev.sample) > 18 {
                gPendingTap = nil
                runGestureHook(onTapCmd, label: "tap", peakG: prev.peakG)
            }

            let alpha = linG < 0.25 ? 0.12 : 0.025
            gGravX += alpha * dx; gGravY += alpha * dy; gGravZ += alpha * dz
            gPrevX = ax; gPrevY = ay; gPrevZ = az
            gSampleIdx += 1
        }
    }

    func startHistory(_ p: CBPeripheral) {
        guard w != nil else { return }
        let epoch: UInt64 = 1577793600
        let now = UInt64(Date().timeIntervalSince1970)
        let cursor = now > epoch ? now - epoch : 0
        let ch = UInt8(histCh)
        let c = cursor
        let cmd: [UInt8] = [0x02, 0x00, UInt8((c >> 24) & 0xff), UInt8((c >> 16) & 0xff), UInt8((c >> 8) & 0xff), UInt8(c & 0xff), ch, 0x01, 0x00]
        log("HIST: armed, waiting for auth")
        histCmd = cmd
    }

    var lastPageRef: ((Date) -> Void)?
    var histCmd: [UInt8]?

    func finishHistory(_ p: CBPeripheral) {
        guard let w = w else { return }
        log("HIST: done pages=\(pages) records=\(records) endSeen=\(histEndSeen)")
        if !noAck && !histEndSeen { tx([0x06, 0x00, 0x00], on: p, w: w) }
    }

    func startDense(_ p: CBPeripheral) {
        guard let w = w else { return }
        log("MODE5: start dense PPG (06 05 00)")
        tx([0x06, 0x05, 0x00], on: p, w: w)
        var last = Date()
        let watch = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if self.ppg12Count > 0 { last = Date() }
        }
        _ = watch
        let ppt = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            guard self.authed else { return }
            self.tx([0x95, 0x00, 0x00], on: p, w: w)
        }
        pollTimer = ppt
        DispatchQueue.main.asyncAfter(deadline: .now() + max(10, self.seconds - 8)) {
            ppt.invalidate()
            log("MODE5: stop (06 00 00); f12=\(self.ppg12Count) lastGap=\(Int(Date().timeIntervalSince(last)))s")
            self.tx([0x06, 0x00, 0x00], on: p, w: w)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                log("MODE5: post-stop f12=\(self.ppg12Count) (expect no growth)")
                self.tx([0x07, 0x00, 0x00], on: p, w: w)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    log("MODE5: descriptor=\(self.lastDesc)")
                }
            }
        }
    }

    func startPpg13(_ p: CBPeripheral) {
        guard let w = w else { return }
        log("PPG13: priming optical engine (06 10 00)")
        tx([0x06, 0x10, 0x00], on: p, w: w)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.tx([0x06, 0x00, 0x00], on: p, w: w)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tx([0x06, 0x01, 0x00], on: p, w: w)
                var lastFetch = Date(); var lastPoll = Date()
                let t = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { tt in
                    guard self.authed else { tt.invalidate(); return }
                    let now = Date()
                    if now.timeIntervalSince(lastFetch) > 1.2 && now.timeIntervalSince(lastPoll) > 1.0 || self.ppg13Count == 0 && now.timeIntervalSince(lastFetch) > 1.2 {
                        self.tx([0x96, 0x01, 0x00, 0x00, 0x00], on: p, w: w); lastFetch = now
                    }
                    if now.timeIntervalSince(lastPoll) > 8 { self.tx([0x95, 0x00, 0x00], on: p, w: w); lastPoll = now }
                }
                self.pollTimer = t
                DispatchQueue.main.asyncAfter(deadline: .now() + max(8, self.seconds - 8)) {
                    self.pollTimer?.invalidate()
                    log("PPG13: stopping (06 00 00); frames=\(self.ppg13Count)")
                    self.tx([0x06, 0x00, 0x00], on: p, w: w)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        log("PPG13: post-stop frames=\(self.ppg13Count) (expect no growth)")
                        self.tx([0x07, 0x00, 0x00], on: p, w: w)
                    }
                }
            }
        }
    }

    func startLive(_ p: CBPeripheral) {
        guard let w = w else { return }
        let t = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.tx([0xd0, 0x00, 0x00], on: p, w: w)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.tx([0x06, 0x01, 0x00], on: p, w: w) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.tx([0x07, 0x00, 0x00], on: p, w: w) }
        }
        _ = t
        pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            guard self.authed else { return }
            self.tx([0x95, 0x00, 0x00], on: p, w: w)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + max(6.0, self.seconds - 4)) {
            log("stopping mode (060000)")
            self.tx([0x06, 0x00, 0x00], on: p, w: w)
        }
    }

    func answer(_ chal: UInt8, _ p: CBPeripheral) {
        guard let m = mac, let w = w else { return }
        let x = m[3] ^ m[4] ^ m[5]
        let r = Array(sm3([x, chal])[29..<32])
        authed = true
        log("answering challenge \(String(format: "%02x", chal)) -> \(hexs(r))")
        p.writeValue(Data([0x01, 0x01, r[0], r[1], r[2], 0x00]), for: w, type: .withResponse)
    }

    func requestMtuAndGo(_ p: CBPeripheral) {
        guard let w = w, let n = n else { log("missing chars"); exit(5) }
        log("maxWriteWithoutResponse=\(p.maximumWriteValueLength(for: .withoutResponse)) maxWriteWithResponse=\(p.maximumWriteValueLength(for: .withResponse))")
        p.setNotifyValue(true, for: n)
        log("notify requested; sending STATUS 010000")
        p.writeValue(Data([0x01, 0x00, 0x00]), for: w, type: .withResponse)
        runCmdSchedule()
    }

    func runCmdSchedule() {
        guard !pendingCmds.isEmpty else { return }
        cmdTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            guard self.authConfirmed else { return }
            guard let c = self.pendingCmds.first, let p = self.target, let w = self.w else { t.invalidate(); return }
            self.pendingCmds.removeFirst()
            self.tx(c, on: p, w: w)
            if self.pendingCmds.isEmpty { t.invalidate() }
        }
    }

    var rxbuf: [UInt8] = []
    static let lengths: [UInt8: Int] = [0x86: 3, 0x82: 4, 0x15: 6, 0x11: 5, 0x10: 20, 0x87: 20, 0x13: 160, 0x12: 135]

    // Split a notification stream into logical frames; emit only XOR-valid ones.
    func feed(_ chunk: [UInt8]) {
        rxbuf += chunk
        if rxbuf.count > 8192 { rxbuf.removeFirst(rxbuf.count - 8192) }
        while !rxbuf.isEmpty {
            let op = rxbuf[0]
            if op == 0x4c || op == 0x47 {
                // bulk page: [op][00][?] + N x recSize + XOR; find largest N whose frame validates
                let rec = op == 0x4c ? 23 : 47
                var done = false
                var k = (rxbuf.count - 4) / rec
                while k >= 1 {
                    let len = 3 + k * rec + 1
                    if rxbuf.count >= len {
                        let fr = Array(rxbuf[0..<len])
                        var x = 0; for b in fr.dropLast() { x ^= Int(b) }
                        if fr.last == UInt8(x) { emit(fr); rxbuf.removeFirst(len); done = true; break }
                    }
                    k -= 1
                }
                if done { continue }
                return  // wait for the rest of the page
            }
            if let l = Self.lengths[op], l > 0 {
                guard rxbuf.count >= l else { return }
                let fr = Array(rxbuf[0..<l])
                var x = 0; for b in fr.dropLast() { x ^= Int(b) }
                if fr.last == UInt8(x) { emit(fr); rxbuf.removeFirst(l) }
                else { rxbuf.removeFirst() }
                continue
            }
            // unknown/variable: emit remainder if XOR-valid
            var x = 0; for b in rxbuf.dropLast() { x ^= Int(b) }
            if rxbuf.last == UInt8(x) { emit(rxbuf); rxbuf = [] } else if rxbuf.count > 300 { rxbuf.removeFirst() } else { return }
        }
    }

    func emit(_ fr: [UInt8]) {
        tr("rx", fr)
        onFrame(fr)
    }

    func tr(_ dir: String, _ b: [UInt8], note: String = "") {
        guard let t = trace else { return }
        let ms = Int(Date().timeIntervalSince(traceStart) * 1000)
        let hex = b.map { String(format: "%02x", $0) }.joined()
        var xor = 0; for x in b.dropLast() { xor ^= Int(x) }
        let tail = b.last.map { Int($0) } ?? -1
        let line = "{\"t_ms\":\(ms),\"dir\":\"Rx\",\"len\":\(b.count),\"hex\":\"VERBATIM\",\"tailxor\":\(tail),\"xorAllButLast\":\(xor),\"note\":\"\(note)\"}\n"
            .replacingOccurrences(of: "Rx", with: dir)
            .replacingOccurrences(of: "VERBATIM", with: hex)
        t.write(line.data(using: .utf8)!)
    }

    func tx(_ b: [UInt8], on p: CBPeripheral, w: CBCharacteristic) {
        tr("tx", b)
        log("TX \(hexs(b))")
        p.writeValue(Data(b), for: w, type: .withResponse)
    }

    var pairingTries = 0
    func peripheral(_ p: CBPeripheral, didUpdateNotificationStateFor ch: CBCharacteristic, error: Error?) {
        log("notifyState \(ch.uuid) err=\(error?.localizedDescription ?? "nil") notifying=\(ch.isNotifying)")
        if let e = error {
            if pairingTries < 4, e.localizedDescription.contains("nsufficient") {
                pairingTries += 1
                log("retrying notify to trigger pairing (\(pairingTries))")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { p.setNotifyValue(true, for: ch) }
            }
            return
        }
        if ch.uuid == NOTIFY && ch.isNotifying, let w = w {
            log("notify active -> requesting auth challenge (010000)")
            tx([0x01, 0x00, 0x00], on: p, w: w)
            startSession(p)
        }
    }

    var statusTries = 0
    func peripheral(_ p: CBPeripheral, didWriteValueFor ch: CBCharacteristic, error: Error?) {
        if let e = error {
            log("write err \(ch.uuid): \(e.localizedDescription)")
            if statusTries < 5, e.localizedDescription.contains("nsufficient"), let w = w {
                statusTries += 1
                log("retrying status write to force pairing (\(statusTries))")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    p.writeValue(Data([0x01, 0x00, 0x00]), for: w, type: .withResponse)
                }
            }
            return
        }
        if ch.uuid == WRITE, let n = n, !n.isNotifying {
            log("status write OK -> subscribing to notify (link is encrypted)")
            p.setNotifyValue(true, for: n)
        }
    }

    func peripheral(_ p: CBPeripheral, didUpdateValueFor ch: CBCharacteristic, error: Error?) {
        guard let d = ch.value else { return }
        tr("rx", [UInt8](d))
        if ch.uuid == SYSID {
            let b = [UInt8](d)
            log("SYSID \(hexs(b))")
            // candidate interpretations of EUI-64 / raw bytes
            var cands: [[UInt8]] = []
            if b.count == 8 {
                if b[3] == 0xff && b[4] == 0xfe { cands.append([b[0], b[1], b[2], b[5], b[6], b[7]]) }
                if b[3] == 0xfe && b[4] == 0xff { cands.append([b[0], b[1], b[2], b[5], b[6], b[7]]) }
                let r = Array(b.reversed())
                if r[3] == 0xff && r[4] == 0xfe { cands.append([r[0], r[1], r[2], r[5], r[6], r[7]]) }
                if r[3] == 0xfe && r[4] == 0xff { cands.append([r[0], r[1], r[2], r[5], r[6], r[7]]) }
            }
            if b.count == 6 { cands.append(b); cands.append(Array(b.reversed())) }
            // validate against the advertised name suffix (last two MAC bytes, big-endian hex)
            let suffixChecked: [UInt8]?
            if expectTail.count == 4, let hi = UInt8(expectTail.prefix(2), radix: 16), let lo = UInt8(expectTail.suffix(2), radix: 16) {
                suffixChecked = cands.first { $0[4] == hi && $0[5] == lo }
                log("MAC suffix match: \(suffixChecked != nil ? "yes" : "NO (expected \(expectTail))")")
            } else { suffixChecked = nil }
            mac = suffixChecked ?? (cands.count == 1 ? cands[0] : nil)
            if let m = mac { log("MAC \(hexs(m)) tail xor=\(String(format: "%02x", m[3] ^ m[4] ^ m[5]))") }
            else { log("!! MAC ambiguous: " + cands.map { hexs($0) }.joined(separator: " | ")) }
            if let p = target { maybeStart(p) }
            return
        }
        if ch.uuid == N2 { log("SVC2 RX \(d.map { String(format: "%02x", $0) }.joined(separator: " "))"); return }
        if ch.uuid == FW || ch.uuid == SERIAL { log("\(ch.uuid) = \(String(data: d, encoding: .utf8) ?? "")"); return }
        let b = [UInt8](d)
        let now = Date()
        if b == lastRaw && now.timeIntervalSince(lastRawAt) < 0.06 { return }
        lastRaw = b; lastRawAt = now
        feed(b)
    }
    var lastRaw: [UInt8] = []
    var lastRawAt = Date()

    // Logical frame dispatch (bytes already reassembled + XOR-validated).
    func onFrame(_ b: [UInt8]) {
        log("RX \u{2713} \(hexs(b))")
        guard let p = target, let w = w else { return }
        if b.count >= 3 && b[0] == 0x81 && b[1] == 0x00 {
            if mac == nil { pendingChallenge = b[2]; log("challenge buffered until MAC known") }
            else { answer(b[2], p) }
            return
        }
        if b.count >= 2 && b[0] == 0x11 { tx([0x91, 0x00, 0x00], on: p, w: w) }
        if b.count >= 3 && b[0] == 0x15 { if let h = b.last.map({ _ in 0 }) { _ = h } }
        if b.count >= 1 && b[0] == 0x4c || b[0] == 0x47 {
            pages += 1
            lastPageRef?(Date())
            // count 23-byte records inside the page if length implies bulk
            records += b[0] == 0x4c ? (b.count - 4) / 23 : (b.count - 4) / 47
            let rem = Int(b[2])
            let n = b[0] == 0x4c ? (b.count - 4) / 23 : (b.count - 4) / 47
            log("ACK page op=\(String(format: "%02x", b[0])) n=\(n) remaining=\(rem) recordsSoFar=\(records)")
            if rem == 0 { histEndSeen = true; log("HIST: backlog exhausted") }
            if !noAck { tx(b[0] == 0x4c ? [0xcc, 0x00, 0x00] : [0xc7, 0x00, 0x00], on: p, w: w) }
        }
        if b.count >= 1 && b[0] == 0x50 { histEndSeen = true; lastPageRef?(Date()) }
        if b.count >= 3 && b[0] == 0x81 && b[1] == 0x01 {
            authConfirmed = true
            if b.count >= 38 {
                let batt = b[3], wear = b[4]
                let t1 = Double(Int16(bitPattern: (UInt16(b[8]) << 8) | UInt16(b[9]))) / 10.0
                let t2 = Double(Int16(bitPattern: (UInt16(b[10]) << 8) | UInt16(b[11]))) / 10.0
                let eco = b[16], mon = b[17], plan = b[18]
                let mv = (UInt16(b[19]) << 8) | UInt16(b[20])
                let mtu = b[31], sports = b[36]
                log("AUTH8101 ok=\(b[2]==0) batt=\(batt)% \(mv)mV wear=\(wear) temp=\(t1)/\(t2)C mtu=\(mtu) ecoMode=\(eco) monitorStatus=\(mon) monitorPlan=\(plan) sportsMonitor=\(sports)")
            }
        }
        if gestureMode && b.count >= 2 && b[0] == 0x81 && b[1] == 0x01 {
            log("GESTURES: auth confirmed; starting 25 Hz ACC stream (23 03 00)")
            tx([0x23, 0x03, 0x00], on: p, w: w)
        }
        if historyMode && b.count >= 2 && b[0] == 0x81 && b[1] == 0x01 {  // w already unwrapped above
            log("HIST: auth table received; sending d0 + sync-open")
            tx([0xd0, 0x00, 0x00], on: p, w: w)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let c = self.histCmd { self.tx(c, on: p, w: w) }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.tx([0x07, 0x00, 0x00], on: p, w: w)
                    var lastPage = Date()
                    self.lastPageRef = { lastPage = $0 }
                    let t = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { tt in
                        if self.histEndSeen || self.pages >= 400 { tt.invalidate(); self.finishHistory(p); return }
                        if Date().timeIntervalSince(lastPage) > 6.0 {
                            if let c = self.histCmd { self.tx(c, on: p, w: w) }; lastPage = Date()
                        }
                    }
                    self.pollTimer = t
                }
            }
        }
        if b[0] == 0x87 || b[0] == 0x10 { lastDesc = hexs(b) }
        switch b[0] {
        case 0x13:
            ppg13Count += 1
            if gestureMode { processAccGestures(b) }
        case 0x12: ppg12Count += 1
        case 0x15: if b.count > 2 { hrNow = Int(b[2]) }
        default: break
        }
    }
}

// ---------------------------------------------------------------- main
let args = CommandLine.arguments
if args.count <= 1 || args[1] == "selftest" {
    if selfTest() { print("SM3 self-test OK"); exit(0) } else { print("SM3 self-test FAILED"); exit(1) }
}

var nameSub = ""
var seconds = 20.0
var scanOnly = false
var cmds: [[UInt8]] = []
var liveMode = false
var tracePath: String? = nil
var batterySecs: Double = 60
var poll07: Double = 0
var poll07Count = 0
var ppg13Mode = false
var denseMode = false
var historyMode = false
var noAck = false
var dumpAll = false
var batteryMode = false
var histCh = 0
var gestureMode = false
var onTapCmd: String? = nil
var onDoubleTapCmd: String? = nil
var onFlickCmd: String? = nil
var i = 1
while i < args.count {
    switch args[i] {
    case "--name": nameSub = args[i+1]; i += 2
    case "--seconds": seconds = Double(args[i+1]) ?? 20; i += 2
    case "--scan": scanOnly = true; i += 1
    case "--cmd": cmds.append(hex(args[i+1])); i += 2
    case "--live": liveMode = true; i += 1
    case "--trace": tracePath = args[i+1]; i += 2
    case "--poll07": poll07 = Double(args[i+1]) ?? 0; poll07Count = Int(args[i+2]) ?? 0; i += 3
    case "--ppg13": ppg13Mode = true; i += 1
    case "--dense": denseMode = true; i += 1
    case "--history": historyMode = true; i += 1
    case "--noack": noAck = true; i += 1
    case "--dump": dumpAll = true; i += 1
    case "--interval": batterySecs = Double(args[i+1]) ?? 60; i += 2
    case "--battery": batteryMode = true; i += 1
    case "--channel": histCh = Int(args[i+1]) ?? 0; i += 2
    case "--gestures": gestureMode = true; i += 1
    case "--on-tap": onTapCmd = args[i+1]; i += 2
    case "--on-double-tap": onDoubleTapCmd = args[i+1]; i += 2
    case "--on-flick": onFlickCmd = args[i+1]; i += 2
    default: i += 1
    }
}
print("selftest: \(selfTest() ? "OK" : "FAILED")")
let probe = Probe(nameSub: nameSub, seconds: seconds, scanOnly: scanOnly, cmds: cmds, liveMode: liveMode,
                  tracePath: tracePath, poll07: poll07, poll07Count: poll07Count, ppg13: ppg13Mode, dense: denseMode, hist: historyMode, noack: noAck, dump: dumpAll, battery: batteryMode, interval: batterySecs,
                  gestures: gestureMode, onTap: onTapCmd, onDoubleTap: onDoubleTapCmd, onFlick: onFlickCmd)
if scanOnly {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { log("scan time limit"); exit(0) }
}
RunLoop.main.run()
