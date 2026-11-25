package com.ringcompanion.app

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.BluetoothStatusCodes
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

@SuppressLint("MissingPermission")
internal class RingBleBridge(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private companion object {
        const val PERMISSION_REQUEST = 7102
        const val ATT_TIMEOUT = 8_000L
        val RING_SERVICE = UUID.fromString("8327ad99-2d87-4a22-a8ce-6dd7971c0437")
        val WRITE = UUID.fromString("8327ad98-2d87-4a22-a8ce-6dd7971c0437")
        val NOTIFY = UUID.fromString("8327ad97-2d87-4a22-a8ce-6dd7971c0437")
        fun standard(id: String): UUID = UUID.fromString("0000$id-0000-1000-8000-00805f9b34fb")
        val DEVICE_INFO = standard("180a")
        val SYSTEM_ID = standard("2a23")
        val FIRMWARE = standard("2a26")
        val SERIAL = standard("2a25")
        val CCCD = standard("2902")
    }

    private val methods = MethodChannel(messenger, "ringconn/ble")
    private val events = EventChannel(messenger, "ringconn/ble/events")
    private val manager = activity.getSystemService(BluetoothManager::class.java)
    private val main = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    private var permissionResult: MethodChannel.Result? = null
    private var scan: ScanCallback? = null
    private var scanTimer: Runnable? = null
    private val discovered = mutableMapOf<String, String>()
    private var gatt: BluetoothGatt? = null
    private var mtu = 23
    private var awaitingMtu = false
    private var ready = false
    private var subscribed = false
    private var subscribeResult: MethodChannel.Result? = null
    private var waitingForBond = false
    private var bondRetry = false
    private var timer: Runnable? = null
    private var writeChar: BluetoothGattCharacteristic? = null
    private var notifyChar: BluetoothGattCharacteristic? = null
    private val reads = ArrayDeque<BluetoothGattCharacteristic>()
    private var activeRead: UUID? = null
    private val info = mutableMapOf<UUID, ByteArray>()
    private data class WriteRequest(
        val bytes: ByteArray,
        val result: MethodChannel.Result,
        var retries: Int = 0,
    )
    private val writes = ArrayDeque<WriteRequest>()
    private var activeWrite: WriteRequest? = null
    private var retryWriteTimer: Runnable? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        sink = eventSink
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        stopScan()
        closeConnection("Event stream closed")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "startScan" -> requestScan(result)
                "stopScan" -> {
                    stopScan()
                    result.success(null)
                }
                "connect" -> {
                    val id = call.argument<String>("id")
                    if (id == null || id !in discovered || gatt != null) {
                        result.error("connect", "Select a discovered ring while disconnected", null)
                        return
                    }
                    stopScan()
                    val device = manager?.adapter?.getRemoteDevice(id)
                    if (device == null) {
                        result.error("connect", "Bluetooth adapter unavailable", null)
                        return
                    }
                    gatt = device.connectGatt(activity, false, callback, BluetoothDevice.TRANSPORT_LE)
                    if (gatt == null) {
                        result.error("connect", "Android could not open the GATT connection", null)
                        return
                    }
                    arm(25_000L) { fail("Timed out connecting to the ring") }
                    result.success(null)
                }
                "disconnect" -> {
                    stopScan()
                    closeConnection("Disconnected")
                    result.success(null)
                }
                "setHighPriority" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val priority = if (enabled) {
                        BluetoothGatt.CONNECTION_PRIORITY_HIGH
                    } else {
                        BluetoothGatt.CONNECTION_PRIORITY_BALANCED
                    }
                    val ok = gatt?.requestConnectionPriority(priority) ?: false
                    result.success(ok)
                }
                "subscribe" -> {
                    if (!ready || gatt == null || subscribeResult != null || subscribed) {
                        result.error("subscribe", "GATT is unavailable or already subscribed", null)
                        return
                    }
                    subscribeResult = result
                    subscribe()
                }
                "write" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    if (!subscribed || bytes == null || bytes.isEmpty() || bytes.size > mtu - 3) {
                        result.error("write", "BLE is unavailable or payload exceeds the ATT limit", null)
                        return
                    }
                    if (writes.size >= 32) {
                        result.error("write", "BLE write queue is full", null)
                        return
                    }
                    writes.addLast(WriteRequest(bytes, result))
                    pumpWrites()
                }
                else -> result.notImplemented()
            }
        } catch (error: SecurityException) {
            result.error("permissions", error.message ?: "Bluetooth permission required", null)
        } catch (error: IllegalStateException) {
            result.error("bluetooth", error.message ?: "Bluetooth is unavailable", null)
        }
    }

    private fun requestScan(result: MethodChannel.Result) {
        if (gatt != null || permissionResult != null) {
            result.error("scan", "Disconnect or finish granting permissions before scanning", null)
            return
        }
        val required = if (Build.VERSION.SDK_INT >= 31) {
            arrayOf(Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT)
        } else {
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
        }
        val missing = required.filter { activity.checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED }
        if (missing.isEmpty()) {
            startScan(result)
        } else {
            permissionResult = result
            activity.requestPermissions(missing.toTypedArray(), PERMISSION_REQUEST)
        }
    }

    fun onPermissions(requestCode: Int, grantResults: IntArray) {
        if (requestCode != PERMISSION_REQUEST) return
        val result = permissionResult ?: return
        permissionResult = null
        if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
            startScan(result)
        } else {
            result.error("permissions", "Allow Bluetooth access to scan for the ring", null)
        }
    }

    private fun startScan(result: MethodChannel.Result) {
        val scanner = manager?.adapter?.bluetoothLeScanner
        if (scanner == null) {
            result.error("scan", "Turn on Bluetooth to scan", null)
            return
        }
        stopScan()
        discovered.clear()
        val callback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                main.post {
                    if (scan !== this) return@post
                    val name = result.scanRecord?.deviceName ?: result.device.name ?: return@post
                    if (!name.contains("RingConn Gen2", ignoreCase = true)) return@post
                    val id = result.device.address
                    discovered[id] = name
                    emit("device", "id" to id, "name" to name, "rssi" to result.rssi)
                }
            }

            override fun onScanFailed(errorCode: Int) {
                main.post {
                    if (scan !== this) return@post
                    stopScan()
                    emit("error", "message" to "Bluetooth scan failed ($errorCode)")
                }
            }
        }
        scan = callback
        emit("scan", "active" to true)
        // Rings already connected to another app on this phone stop advertising.
        // Surface connected and bonded rings immediately alongside live BLE scan results.
        val connected = runCatching { manager?.getConnectedDevices(BluetoothProfile.GATT).orEmpty() }
            .getOrDefault(emptyList())
        for (device in connected) {
            val name = device.name ?: continue
            if (!name.contains("RingConn Gen2", ignoreCase = true)) continue
            val id = device.address
            discovered[id] = name
            emit("device", "id" to id, "name" to name, "rssi" to 0, "source" to "connected")
        }
        val bonded = runCatching { manager?.adapter?.bondedDevices.orEmpty() }
            .getOrDefault(emptyList())
        for (device in bonded) {
            val name = device.name ?: continue
            if (!name.contains("RingConn Gen2", ignoreCase = true)) continue
            val id = device.address
            if (id in discovered) continue
            discovered[id] = name
            emit("device", "id" to id, "name" to name, "rssi" to -1, "source" to "bonded")
        }
        // The ring advertises its name in the scan response without a service UUID.
        scanner.startScan(null, ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build(), callback)
        scanTimer = Runnable { stopScan() }.also { main.postDelayed(it, 15_000L) }
        result.success(null)
    }

    private fun stopScan() {
        scanTimer?.let(main::removeCallbacks)
        scanTimer = null
        val callback = scan ?: return
        scan = null
        runCatching { manager?.adapter?.bluetoothLeScanner?.stopScan(callback) }
        emit("scan", "active" to false)
    }

    private val callback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(link: BluetoothGatt, status: Int, state: Int) =
            onLink(link) {
                when {
                    status != BluetoothGatt.GATT_SUCCESS -> fail("GATT connection error ($status)")
                    state == BluetoothProfile.STATE_DISCONNECTED -> closeConnection("Ring disconnected")
                    state == BluetoothProfile.STATE_CONNECTED -> {
                        arm(ATT_TIMEOUT) { fail("Service discovery timed out") }
                        if (!link.discoverServices()) fail("Could not start service discovery")
                    }
                }
            }

        override fun onServicesDiscovered(link: BluetoothGatt, status: Int) = onLink(link) {
            if (status != BluetoothGatt.GATT_SUCCESS) {
                fail("Service discovery failed ($status)")
                return@onLink
            }
            val service = link.getService(RING_SERVICE)
            val write = service?.getCharacteristic(WRITE)
            val notify = service?.getCharacteristic(NOTIFY)
            val dis = link.getService(DEVICE_INFO)
            val systemId = dis?.getCharacteristic(SYSTEM_ID)
            if (write == null || notify == null || systemId == null ||
                write.properties and BluetoothGattCharacteristic.PROPERTY_WRITE == 0 ||
                notify.properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY == 0
            ) {
                fail("The ring did not expose the expected GATT profile")
                return@onLink
            }
            writeChar = write
            notifyChar = notify
            reads.addLast(systemId)
            dis.getCharacteristic(FIRMWARE)?.let(reads::addLast)
            dis.getCharacteristic(SERIAL)?.let(reads::addLast)
            awaitingMtu = true
            // Continue with the default MTU when the handset rejects the request.
            if (link.requestMtu(247)) {
                arm(ATT_TIMEOUT) { fail("ATT MTU request timed out") }
            } else {
                awaitingMtu = false
                readNext(link)
            }
        }

        override fun onMtuChanged(link: BluetoothGatt, value: Int, status: Int) = onLink(link) {
            if (status == BluetoothGatt.GATT_SUCCESS) mtu = value
            if (awaitingMtu) {
                awaitingMtu = false
                readNext(link)
            }
        }

        override fun onCharacteristicRead(
            link: BluetoothGatt, characteristic: BluetoothGattCharacteristic, value: ByteArray, status: Int,
        ) = acceptRead(link, characteristic.uuid, value.copyOf(), status)

        @Deprecated("Used by Android API 23–32")
        @Suppress("DEPRECATION")
        override fun onCharacteristicRead(
            link: BluetoothGatt, characteristic: BluetoothGattCharacteristic, status: Int,
        ) {
            if (Build.VERSION.SDK_INT < 33) {
                acceptRead(link, characteristic.uuid, characteristic.value?.copyOf(), status)
            }
        }

        override fun onCharacteristicChanged(
            link: BluetoothGatt, characteristic: BluetoothGattCharacteristic, value: ByteArray,
        ) = notification(link, characteristic.uuid, value.copyOf())

        @Deprecated("Used by Android API 23–32")
        @Suppress("DEPRECATION")
        override fun onCharacteristicChanged(link: BluetoothGatt, characteristic: BluetoothGattCharacteristic) {
            if (Build.VERSION.SDK_INT < 33) {
                characteristic.value?.copyOf()?.let { notification(link, characteristic.uuid, it) }
            }
        }

        override fun onDescriptorWrite(link: BluetoothGatt, descriptor: BluetoothGattDescriptor, status: Int) =
            onLink(link) {
                val result = subscribeResult ?: return@onLink
                if (descriptor.uuid != CCCD || waitingForBond) return@onLink
                when {
                    status == BluetoothGatt.GATT_SUCCESS -> {
                        disarm()
                        subscribeResult = null
                        subscribed = true
                        result.success(null)
                    }
                    (status == BluetoothGatt.GATT_INSUFFICIENT_AUTHENTICATION ||
                        status == BluetoothGatt.GATT_INSUFFICIENT_ENCRYPTION) && !bondRetry -> {
                        bondRetry = true
                        val device = link.device
                        if (device.bondState == BluetoothDevice.BOND_BONDED) {
                            subscribe()
                        } else {
                            waitingForBond = true
                            emit("bond", "state" to "pairing")
                            arm(45_000L) { fail("Bluetooth pairing timed out") }
                            if (device.bondState != BluetoothDevice.BOND_BONDING && !device.createBond()) {
                                fail("Android could not start Bluetooth pairing")
                            }
                        }
                    }
                    else -> fail("Notification subscription failed ($status)")
                }
            }

        override fun onCharacteristicWrite(link: BluetoothGatt, characteristic: BluetoothGattCharacteristic, status: Int) =
            onLink(link) {
                val request = activeWrite ?: return@onLink
                if (characteristic.uuid != WRITE) return@onLink
                disarm()
                activeWrite = null
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    request.result.success(null)
                    pumpWrites()
                } else {
                    request.result.error("write", "GATT write failed ($status)", null)
                    fail("GATT write failed ($status)")
                }
            }
    }

    private fun onLink(link: BluetoothGatt, block: () -> Unit) {
        main.post {
            if (link !== gatt) return@post
            try {
                block()
            } catch (error: SecurityException) {
                fail(error.message ?: "Bluetooth permission was revoked")
            }
        }
    }

    private fun notification(link: BluetoothGatt, uuid: UUID, bytes: ByteArray) = onLink(link) {
        if (uuid == NOTIFY && (subscribeResult != null || subscribed)) {
            emit("notification", "bytes" to bytes)
        }
    }

    private fun acceptRead(link: BluetoothGatt, uuid: UUID, bytes: ByteArray?, status: Int) =
        onLink(link) {
            if (uuid != activeRead) return@onLink
            activeRead = null
            if (status == BluetoothGatt.GATT_SUCCESS && bytes != null) info[uuid] = bytes
            readNext(link)
        }

    private fun readNext(link: BluetoothGatt) {
        val characteristic = reads.removeFirstOrNull()
        if (characteristic != null) {
            activeRead = characteristic.uuid
            arm(ATT_TIMEOUT) { fail("Device Information read timed out") }
            if (!link.readCharacteristic(characteristic)) {
                activeRead = null
                readNext(link)
            }
            return
        }
        disarm()
        val identity = info[SYSTEM_ID]
        if (identity == null) {
            fail("Could not read the ring System ID")
            return
        }
        ready = true
        emit(
            "ready", "id" to link.device.address, "systemId" to identity,
            "firmware" to info[FIRMWARE]?.decodeToString()?.trim('\u0000'),
            "serial" to info[SERIAL]?.decodeToString()?.trim('\u0000'), "writeLimit" to mtu - 3,
        )
    }

    private fun subscribe() {
        val link = gatt ?: return
        val characteristic = notifyChar ?: return
        val descriptor = characteristic.getDescriptor(CCCD)
        if (descriptor == null || !link.setCharacteristicNotification(characteristic, true)) {
            fail("The ring did not expose a usable notification descriptor")
            return
        }
        arm(45_000L) { fail("Notification subscription or pairing timed out") }
        val enabled = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
        val started = if (Build.VERSION.SDK_INT >= 33) {
            link.writeDescriptor(descriptor, enabled) == BluetoothStatusCodes.SUCCESS
        } else {
            @Suppress("DEPRECATION")
            run {
                descriptor.value = enabled
                link.writeDescriptor(descriptor)
            }
        }
        if (!started) fail("Could not start the notification descriptor write")
    }

    private val bondReceiver = object : BroadcastReceiver() {
        @Suppress("DEPRECATION")
        override fun onReceive(context: Context, intent: Intent) {
            val link = gatt ?: return
            val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
            if (device != link.device) return
            val state = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR)
            emit("bond", "state" to when (state) {
                BluetoothDevice.BOND_BONDING -> "pairing"
                BluetoothDevice.BOND_BONDED -> "bonded"
                else -> "unbonded"
            })
            if (!waitingForBond) return
            when (state) {
                BluetoothDevice.BOND_BONDED -> {
                    waitingForBond = false
                    subscribe()
                }
                BluetoothDevice.BOND_NONE -> fail("Bluetooth pairing did not complete")
            }
        }
    }

    init {
        methods.setMethodCallHandler(this)
        events.setStreamHandler(this)
        val filter = IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
        if (Build.VERSION.SDK_INT >= 33) {
            // Bluetooth broadcasts can originate in the privileged Bluetooth process.
            activity.registerReceiver(bondReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            activity.registerReceiver(bondReceiver, filter)
        }
    }

    private fun pumpWrites() {
        val link = gatt ?: return
        val characteristic = writeChar ?: return
        if (activeWrite != null || retryWriteTimer != null) return
        val request = writes.removeFirstOrNull() ?: return
        activeWrite = request
        arm(ATT_TIMEOUT) { fail("GATT write response timed out") }
        if (Build.VERSION.SDK_INT >= 33) {
            val code = link.writeCharacteristic(
                characteristic,
                request.bytes,
                BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT,
            )
            if (code == BluetoothStatusCodes.SUCCESS) return
            if (code == BluetoothStatusCodes.ERROR_GATT_WRITE_REQUEST_BUSY && request.retries < 10) {
                disarm()
                activeWrite = null
                request.retries += 1
                writes.addFirst(request)
                retryWriteTimer = Runnable {
                    retryWriteTimer = null
                    pumpWrites()
                }.also { main.postDelayed(it, 120L) }
                return
            }
            if (code == BluetoothStatusCodes.ERROR_GATT_WRITE_REQUEST_BUSY) {
                fail("GATT write busy — close or force-stop the other ring app and retry")
            } else {
                fail("Could not queue the GATT write ($code)")
            }
            return
        }
        @Suppress("DEPRECATION")
        val started = run {
            characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            characteristic.value = request.bytes
            link.writeCharacteristic(characteristic)
        }
        if (!started) {
            if (request.retries < 5) {
                disarm()
                activeWrite = null
                request.retries += 1
                writes.addFirst(request)
                retryWriteTimer = Runnable {
                    retryWriteTimer = null
                    pumpWrites()
                }.also { main.postDelayed(it, 120L) }
                return
            }
            fail("Could not queue the GATT write — close or force-stop any other ring app and retry")
        }
    }

    private fun arm(delay: Long, block: () -> Unit) {
        disarm()
        timer = Runnable(block).also { main.postDelayed(it, delay) }
    }

    private fun disarm() {
        timer?.let(main::removeCallbacks)
        timer = null
    }

    private fun emit(type: String, vararg fields: Pair<String, Any?>) {
        sink?.success(mapOf("type" to type, *fields))
    }

    private fun fail(message: String) {
        emit("error", "message" to message)
        closeConnection(message)
    }

    private fun closeConnection(reason: String) {
        disarm()
        retryWriteTimer?.let(main::removeCallbacks)
        retryWriteTimer = null
        val link = gatt
        gatt = null
        writeChar = null
        notifyChar = null
        reads.clear()
        info.clear()
        activeRead = null
        awaitingMtu = false
        ready = false
        subscribed = false
        waitingForBond = false
        bondRetry = false
        mtu = 23
        subscribeResult?.error("subscribe", reason, null)
        subscribeResult = null
        activeWrite?.result?.error("write", reason, null)
        activeWrite = null
        while (writes.isNotEmpty()) writes.removeFirst().result.error("write", reason, null)
        if (link != null) {
            runCatching { link.disconnect() }
            runCatching { link.close() }
            emit("disconnected", "reason" to reason)
        }
    }

    fun dispose() {
        permissionResult?.error("closed", "Activity closed", null)
        permissionResult = null
        stopScan()
        closeConnection("Activity closed")
        activity.unregisterReceiver(bondReceiver)
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
        sink = null
    }
}
