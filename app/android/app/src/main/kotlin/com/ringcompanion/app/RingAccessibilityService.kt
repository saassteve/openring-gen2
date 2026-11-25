package com.ringcompanion.app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import java.lang.ref.WeakReference

class RingAccessibilityService : AccessibilityService() {
    companion object {
        @Volatile
        private var activeRef: WeakReference<RingAccessibilityService>? = null

        val instance: RingAccessibilityService?
            get() = activeRef?.get()

        fun isRunning(): Boolean = instance != null
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        activeRef = WeakReference(this)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Privacy-first: this service does not inspect or log screen content.
    }

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        if (activeRef?.get() === this) activeRef = null
        super.onDestroy()
    }

    fun performScrollDown(): Boolean = swipe(0.5f, 0.76f, 0.5f, 0.24f)

    fun performScrollUp(): Boolean = swipe(0.5f, 0.24f, 0.5f, 0.76f)

    fun performNextPage(): Boolean = swipe(0.84f, 0.5f, 0.16f, 0.5f)

    fun performPrevPage(): Boolean = swipe(0.16f, 0.5f, 0.84f, 0.5f)

    fun performBack(): Boolean = performGlobalAction(GLOBAL_ACTION_BACK)

    fun performScreenshot(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            performGlobalAction(GLOBAL_ACTION_TAKE_SCREENSHOT)
        } else {
            false
        }

    fun performCameraShutter(): Boolean {
        val metrics = resources.displayMetrics
        val landscape = metrics.widthPixels > metrics.heightPixels
        val x = if (landscape) metrics.widthPixels * 0.88f else metrics.widthPixels * 0.50f
        val y = if (landscape) metrics.heightPixels * 0.50f else metrics.heightPixels * 0.84f
        val path = Path().apply { moveTo(x, y) }
        val stroke = GestureDescription.StrokeDescription(path, 0L, 60L)
        val gesture = GestureDescription.Builder().addStroke(stroke).build()
        return dispatchGesture(gesture, null, null)
    }

    private fun swipe(x1: Float, y1: Float, x2: Float, y2: Float): Boolean {
        val metrics = resources.displayMetrics
        val path = Path().apply {
            moveTo(metrics.widthPixels * x1, metrics.heightPixels * y1)
            lineTo(metrics.widthPixels * x2, metrics.heightPixels * y2)
        }
        val stroke = GestureDescription.StrokeDescription(path, 0L, 240L)
        val gesture = GestureDescription.Builder().addStroke(stroke).build()
        return dispatchGesture(gesture, null, null)
    }
}
