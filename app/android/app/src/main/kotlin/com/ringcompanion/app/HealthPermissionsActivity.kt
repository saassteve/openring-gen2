package com.ringcompanion.app

import android.app.Activity
import android.app.AlertDialog
import android.os.Bundle

class HealthPermissionsActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AlertDialog.Builder(this)
            .setTitle("Ring Companion and Health Connect")
            .setMessage(
                "When you choose Sync to Health Connect, Ring Companion writes stored " +
                    "heart rate, heart rate variability, oxygen saturation, breathing rate, " +
                    "and skin temperature for the types you allow. You can view these readings " +
                    "and manage write access in Health Connect."
            )
            .setPositiveButton(android.R.string.ok) { _, _ -> finish() }
            .setOnCancelListener { finish() }
            .show()
    }
}
