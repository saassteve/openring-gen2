package com.ringcompanion.app

import android.os.Build
import androidx.health.connect.client.PermissionController
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var ble: RingBleBridge? = null
    private var health: HealthConnectBridge? = null
    private var deviceActions: DeviceActionBridge? = null
    private var unavailableHealthChannel: MethodChannel? = null
    private val healthPermissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        registerForActivityResult(
            PermissionController.createRequestPermissionResultContract(),
        ) { health?.onPermissionsResult() }
    } else {
        null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        ble = RingBleBridge(this, messenger)
        deviceActions = DeviceActionBridge(this, messenger)
        val permissionLauncher = healthPermissions
        if (permissionLauncher != null) {
            health = HealthConnectBridge(this, messenger, permissionLauncher::launch)
        } else {
            unavailableHealthChannel = MethodChannel(messenger, HEALTH_CONNECT_CHANNEL).apply {
                setMethodCallHandler { _, result ->
                    result.error("unavailable", "Health Connect export requires Android 9 or later.", null)
                }
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        ble?.onPermissions(requestCode, grantResults)
        deviceActions?.onPermissions(requestCode, grantResults)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        ble?.dispose()
        ble = null
        health?.dispose()
        health = null
        deviceActions?.dispose()
        deviceActions = null
        unavailableHealthChannel?.setMethodCallHandler(null)
        unavailableHealthChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
