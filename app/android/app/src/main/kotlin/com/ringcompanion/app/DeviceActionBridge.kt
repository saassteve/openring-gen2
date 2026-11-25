package com.ringcompanion.app

import android.Manifest
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.view.KeyEvent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

internal const val DEVICE_ACTIONS_CHANNEL = "ringconn/device_actions"

internal class DeviceActionBridge(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private companion object {
        const val NOTIFICATION_PERMISSION_REQUEST = 7106
        const val ACTION_RING_GESTURE = "com.ringcompanion.app.ACTION_RING_GESTURE"
    }

    private val channel = MethodChannel(messenger, DEVICE_ACTIONS_CHANNEL)
    private val main = Handler(Looper.getMainLooper())
    private val ioExecutor = Executors.newSingleThreadExecutor()
    private val audio = activity.getSystemService(AudioManager::class.java)
    private val camera = activity.getSystemService(CameraManager::class.java)
    private var torchCameraId: String? = null
    private var torchEnabled = false
    private var pendingServiceSummary: String? = null

    private val torchCallback = object : CameraManager.TorchCallback() {
        override fun onTorchModeChanged(cameraId: String, enabled: Boolean) {
            if (cameraId == torchCameraId) torchEnabled = enabled
        }
    }

    private val stopReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == RingGestureService.ACTION_STOP_FROM_NOTIFICATION) {
                stopForegroundService()
                main.post { channel.invokeMethod("stopGesturesFromNotification", null) }
            }
        }
    }

    init {
        channel.setMethodCallHandler(this)
        torchCameraId = findBackFlashCamera()
        runCatching { camera?.registerTorchCallback(torchCallback, main) }
        val filter = IntentFilter(RingGestureService.ACTION_STOP_FROM_NOTIFICATION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(stopReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            activity.registerReceiver(stopReceiver, filter)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "performAction" -> {
                val action = call.argument<String>("action") ?: "none"
                val gesture = call.argument<String>("gesture") ?: "tap"
                val peakG = call.argument<Double>("peakG") ?: 0.0
                val haptic = call.argument<Boolean>("haptic") ?: true
                val webhookUrl = call.argument<String>("webhookUrl")
                if (haptic && action != "none") vibrate(gesture)
                executeAction(action, gesture, peakG, webhookUrl, result)
            }
            "setBackgroundService" -> {
                val active = call.argument<Boolean>("active") ?: false
                val summary = call.argument<String>("summary") ?: ""
                if (active) {
                    startForegroundServiceWithPermission(summary)
                } else {
                    pendingServiceSummary = null
                    stopForegroundService()
                }
                result.success(true)
            }
            "accessibilityStatus" -> result.success(RingAccessibilityService.isRunning())
            "openAccessibilitySettings" -> {
                val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                activity.startActivity(intent)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    fun onPermissions(requestCode: Int, grantResults: IntArray) {
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST) return
        val summary = pendingServiceSummary ?: return
        pendingServiceSummary = null
        // Even if notifications are declined, Android still permits FGS start on
        // connectedDevice; start best-effort if the user still wants it active.
        startForegroundServiceNow(summary)
    }

    private fun startForegroundServiceWithPermission(summary: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            pendingServiceSummary = summary
            activity.requestPermissions(
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                NOTIFICATION_PERMISSION_REQUEST,
            )
            return
        }
        startForegroundServiceNow(summary)
    }

    private fun startForegroundServiceNow(summary: String) {
        val intent = Intent(activity, RingGestureService::class.java).apply {
            putExtra(RingGestureService.EXTRA_SUMMARY, summary)
        }
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                activity.startForegroundService(intent)
            } else {
                activity.startService(intent)
            }
        }
    }

    private fun stopForegroundService() {
        runCatching {
            activity.stopService(Intent(activity, RingGestureService::class.java))
        }
    }

    private fun executeAction(
        action: String,
        gesture: String,
        peakG: Double,
        webhookUrl: String?,
        result: MethodChannel.Result,
    ) {
        when (action) {
            "none" -> result.success(mapOf("ok" to true, "detail" to "No action"))
            "mediaPlayPause" -> {
                dispatchMediaKey(KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
                result.success(mapOf("ok" to true, "detail" to "Play / Pause media"))
            }
            "mediaNext" -> {
                dispatchMediaKey(KeyEvent.KEYCODE_MEDIA_NEXT)
                result.success(mapOf("ok" to true, "detail" to "Next track"))
            }
            "mediaPrevious" -> {
                dispatchMediaKey(KeyEvent.KEYCODE_MEDIA_PREVIOUS)
                result.success(mapOf("ok" to true, "detail" to "Previous track"))
            }
            "volumeUp" -> {
                audio?.adjustStreamVolume(
                    AudioManager.STREAM_MUSIC,
                    AudioManager.ADJUST_RAISE,
                    AudioManager.FLAG_SHOW_UI,
                )
                result.success(mapOf("ok" to true, "detail" to "Volume up"))
            }
            "volumeDown" -> {
                audio?.adjustStreamVolume(
                    AudioManager.STREAM_MUSIC,
                    AudioManager.ADJUST_LOWER,
                    AudioManager.FLAG_SHOW_UI,
                )
                result.success(mapOf("ok" to true, "detail" to "Volume down"))
            }
            "toggleFlashlight" -> {
                val id = torchCameraId ?: findBackFlashCamera().also { torchCameraId = it }
                if (id == null || camera == null) {
                    result.success(mapOf("ok" to false, "detail" to "Flashlight unavailable"))
                    return
                }
                val next = !torchEnabled
                val ok = runCatching { camera.setTorchMode(id, next) }.isSuccess
                if (ok) torchEnabled = next
                result.success(
                    mapOf(
                        "ok" to ok,
                        "detail" to if (ok) (if (next) "Flashlight on" else "Flashlight off") else "Could not toggle flashlight",
                    ),
                )
            }
            "scrollDown", "scrollUp", "nextPage", "prevPage", "screenshot", "back" -> {
                val service = RingAccessibilityService.instance
                if (service == null) {
                    result.success(
                        mapOf(
                            "ok" to false,
                            "detail" to "Enable Ring Companion in Android Accessibility settings",
                        ),
                    )
                    return
                }
                val ok = when (action) {
                    "scrollDown" -> service.performScrollDown()
                    "scrollUp" -> service.performScrollUp()
                    "nextPage" -> service.performNextPage()
                    "prevPage" -> service.performPrevPage()
                    "screenshot" -> service.performScreenshot()
                    else -> service.performBack()
                }
                result.success(mapOf("ok" to ok, "detail" to if (ok) action else "Gesture not accepted"))
            }
            "broadcast" -> {
                val intent = Intent(ACTION_RING_GESTURE).apply {
                    putExtra("gesture", gesture)
                    putExtra("peak_g", peakG)
                    putExtra("timestamp_ms", System.currentTimeMillis())
                }
                activity.sendBroadcast(intent)
                result.success(mapOf("ok" to true, "detail" to "Sent Android broadcast ($gesture)"))
            }
            "webhook" -> {
                val urlText = webhookUrl?.trim().orEmpty()
                if (urlText.isEmpty() || (!urlText.startsWith("http://") && !urlText.startsWith("https://"))) {
                    result.success(mapOf("ok" to false, "detail" to "Set an http:// or https:// webhook URL first"))
                    return
                }
                ioExecutor.execute {
                    val outcome = postWebhook(urlText, gesture, peakG)
                    main.post { result.success(outcome) }
                }
            }
            else -> result.success(mapOf("ok" to false, "detail" to "Unknown action: $action"))
        }
    }

    private fun dispatchMediaKey(keyCode: Int) {
        val manager = audio ?: return
        val now = SystemClock.uptimeMillis()
        manager.dispatchMediaKeyEvent(KeyEvent(now, now, KeyEvent.ACTION_DOWN, keyCode, 0))
        manager.dispatchMediaKeyEvent(KeyEvent(now, now + 20, KeyEvent.ACTION_UP, keyCode, 0))
    }

    private fun vibrate(gesture: String) {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            activity.getSystemService(VibratorManager::class.java)?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            activity.getSystemService(Vibrator::class.java)
        } ?: return
        if (!vibrator.hasVibrator()) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val effect = when (gesture) {
                "doubleTap" -> VibrationEffect.createWaveform(longArrayOf(0, 30, 55, 35), -1)
                "flick" -> VibrationEffect.createOneShot(55, VibrationEffect.DEFAULT_AMPLITUDE)
                else -> VibrationEffect.createOneShot(28, VibrationEffect.DEFAULT_AMPLITUDE)
            }
            runCatching { vibrator.vibrate(effect) }
        } else {
            @Suppress("DEPRECATION")
            runCatching { vibrator.vibrate(35) }
        }
    }

    private fun findBackFlashCamera(): String? {
        val manager = camera ?: return null
        return runCatching {
            manager.cameraIdList.firstOrNull { id ->
                val chars = manager.getCameraCharacteristics(id)
                val hasFlash = chars.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
                val facing = chars.get(CameraCharacteristics.LENS_FACING)
                hasFlash && facing == CameraCharacteristics.LENS_FACING_BACK
            }
        }.getOrNull()
    }

    private fun postWebhook(urlText: String, gesture: String, peakG: Double): Map<String, Any> {
        return try {
            val conn = (URL(urlText).openConnection() as HttpURLConnection).apply {
                requestMethod = "POST"
                connectTimeout = 4000
                readTimeout = 4000
                doOutput = true
                setRequestProperty("Content-Type", "application/json")
            }
            val payload = JSONObject()
                .put("gesture", gesture)
                .put("peak_g", peakG)
                .put("timestamp_ms", System.currentTimeMillis())
                .toString()
            conn.outputStream.use { it.write(payload.toByteArray(Charsets.UTF_8)) }
            val code = conn.responseCode
            conn.disconnect()
            mapOf("ok" to (code in 200..299), "detail" to "Webhook HTTP $code")
        } catch (error: Exception) {
            mapOf("ok" to false, "detail" to "Webhook failed: ${error.message ?: error.javaClass.simpleName}")
        }
    }

    fun dispose() {
        stopForegroundService()
        runCatching { camera?.unregisterTorchCallback(torchCallback) }
        runCatching { activity.unregisterReceiver(stopReceiver) }
        ioExecutor.shutdownNow()
        channel.setMethodCallHandler(null)
    }
}
