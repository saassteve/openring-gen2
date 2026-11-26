package com.ringcompanion.app

import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class RingQuickTileService : TileService() {
    companion object {
        const val ACTION_TILE_TOGGLE_GESTURES = "com.ringcompanion.app.ACTION_TILE_TOGGLE_GESTURES"
        const val EXTRA_TOGGLE_GESTURES = "toggle_gestures_from_tile"

        @Volatile var appRunning: Boolean = false
        @Volatile var ringConnected: Boolean = false
        @Volatile var gesturesActive: Boolean = false
        @Volatile var summarySubtitle: String = "Tap to arm gestures"

        fun requestRefresh(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                runCatching {
                    requestListeningState(
                        context,
                        ComponentName(context, RingQuickTileService::class.java),
                    )
                }
            }
        }
    }

    override fun onStartListening() {
        super.onStartListening()
        refreshTile()
    }

    override fun onClick() {
        super.onClick()
        if (appRunning) {
            sendBroadcast(
                Intent(ACTION_TILE_TOGGLE_GESTURES).setPackage(packageName),
            )
            // Optimistic UI update while Flutter toggles stream.
            gesturesActive = !gesturesActive
            refreshTile()
            return
        }
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(EXTRA_TOGGLE_GESTURES, true)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val pending = PendingIntent.getActivity(
                this,
                7120,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            startActivityAndCollapse(pending)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(launchIntent)
        }
    }

    private fun refreshTile() {
        val tile = qsTile ?: return
        tile.label = "RingPilot"
        tile.state = when {
            gesturesActive -> Tile.STATE_ACTIVE
            else -> Tile.STATE_INACTIVE
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = when {
                gesturesActive -> summarySubtitle.ifBlank { "Gestures active" }
                ringConnected -> "Connected · Off"
                else -> "Tap to connect"
            }
        }
        tile.updateTile()
    }
}
