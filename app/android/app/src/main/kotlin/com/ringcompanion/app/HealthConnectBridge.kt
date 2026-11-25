package com.ringcompanion.app

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.HealthConnectFeatures
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.HeartRateVariabilityRmssdRecord
import androidx.health.connect.client.records.OxygenSaturationRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.RespiratoryRateRecord
import androidx.health.connect.client.records.SkinTemperatureRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.metadata.Device
import androidx.health.connect.client.records.metadata.Metadata
import androidx.health.connect.client.units.Percentage
import androidx.health.connect.client.units.Temperature
import androidx.health.connect.client.units.TemperatureDelta
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

internal const val HEALTH_CONNECT_CHANNEL = "ringconn/health_connect"

internal class HealthConnectBridge(
    private val context: Context,
    messenger: BinaryMessenger,
    private val requestPermissions: (Set<String>) -> Unit,
) {
    private val channel = MethodChannel(messenger, HEALTH_CONNECT_CHANNEL)
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var pendingAuthorization: MethodChannel.Result? = null

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "authorize" -> authorize(result)
                "checkPermissions" -> checkPermissions(result)
                "insert" -> withClient(result) { client ->
                    val metric = requireNotNull(call.argument<String>("metric"))
                    val rows = requireNotNull(call.argument<List<Map<String, Any>>>("records"))
                    client.insertRecords(rows.map { record(metric, it) })
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkPermissions(result: MethodChannel.Result) = withClient(result) { client ->
        val permissions = availablePermissions(client)
        val granted = client.permissionController.getGrantedPermissions()
        result.success(permissionReport(permissions, granted))
    }

    private fun authorize(result: MethodChannel.Result) = withClient(result) { client ->
        if (pendingAuthorization != null) {
            result.error("permission_in_progress", "A permission request is already open.", null)
            return@withClient
        }
        val permissions = availablePermissions(client)
        val granted = client.permissionController.getGrantedPermissions()
        val missing = permissions.values.toSet() - granted
        if (missing.isEmpty()) {
            result.success(permissionReport(permissions, granted))
        } else {
            pendingAuthorization = result
            try {
                requestPermissions(missing)
            } catch (error: Exception) {
                pendingAuthorization = null
                throw error
            }
        }
    }

    fun onPermissionsResult() {
        val result = pendingAuthorization ?: return
        pendingAuthorization = null
        withClient(result) { client ->
            result.success(permissionReport(
                availablePermissions(client),
                client.permissionController.getGrantedPermissions(),
            ))
        }
    }

    private fun availablePermissions(client: HealthConnectClient): Map<String, String> {
        val permissions = mutableMapOf(
            "heartRate" to HealthPermission.getWritePermission(HeartRateRecord::class),
            "hrv" to HealthPermission.getWritePermission(HeartRateVariabilityRmssdRecord::class),
            "oxygen" to HealthPermission.getWritePermission(OxygenSaturationRecord::class),
            "respiratoryRate" to HealthPermission.getWritePermission(RespiratoryRateRecord::class),
            "steps" to HealthPermission.getWritePermission(StepsRecord::class),
        )
        if (client.features.getFeatureStatus(HealthConnectFeatures.FEATURE_SKIN_TEMPERATURE) ==
            HealthConnectFeatures.FEATURE_STATUS_AVAILABLE
        ) {
            val permission = HealthPermission.getWritePermission(SkinTemperatureRecord::class)
            permissions["outerTemperature"] = permission
            permissions["innerTemperature"] = permission
        }
        return permissions
    }

    private fun permissionReport(permissions: Map<String, String>, granted: Set<String>) = mapOf(
        "available" to permissions.keys.toList(),
        "granted" to permissions.filterValues { it in granted }.keys.toList(),
    )

    private fun withClient(
        result: MethodChannel.Result,
        operation: suspend (HealthConnectClient) -> Unit,
    ) {
        scope.launch {
            try {
                when (HealthConnectClient.getSdkStatus(context)) {
                    HealthConnectClient.SDK_AVAILABLE ->
                        operation(HealthConnectClient.getOrCreate(context))
                    HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED ->
                        result.error("update_required", "Install or update Health Connect, then try again.", null)
                    else ->
                        result.error("unavailable", "Health Connect is unavailable on this device.", null)
                }
            } catch (error: CancellationException) {
                throw error
            } catch (error: SecurityException) {
                result.error("permission_denied", "Health Connect write permission is required. Check its app permissions and try again.", null)
            } catch (error: Exception) {
                result.error("health_connect", error.message ?: "Health Connect export failed.", null)
            }
        }
    }

    private fun record(metric: String, row: Map<String, Any>): Record {
        val time = Instant.ofEpochMilli((row.getValue("timeMs") as Number).toLong())
        val metadata = Metadata.autoRecorded(
            device = Device(type = Device.TYPE_RING),
            clientRecordId = row.getValue("id") as String,
        )
        val values = (row.getValue("values") as List<*>).map { (it as Number).toDouble() }
        // Shift interval bounds by 1 ms so the end-of-epoch sample is inside
        // the interval and consecutive epochs remain adjacent.
        val end = time.plusMillis(1)
        return when (metric) {
            "heartRate" -> HeartRateRecord(
                startTime = end.minusSeconds(150),
                startZoneOffset = null,
                endTime = end,
                endZoneOffset = null,
                samples = listOf(HeartRateRecord.Sample(time, values.single().toLong())),
                metadata = metadata,
            )
            "hrv" -> HeartRateVariabilityRmssdRecord(time, null, values.single(), metadata)
            "oxygen" -> OxygenSaturationRecord(time, null, Percentage(values.single()), metadata)
            "respiratoryRate" -> RespiratoryRateRecord(time, null, values.single(), metadata)
            "steps" -> StepsRecord(
                startTime = end.minusSeconds(900),
                startZoneOffset = null,
                endTime = end,
                endZoneOffset = null,
                count = values.single().toLong(),
                metadata = metadata,
            )
            "outerTemperature", "innerTemperature" -> {
                require(values.size == 15)
                val baseline = (values.min() + values.max()) / 2
                SkinTemperatureRecord(
                    startTime = end.minusSeconds(900),
                    startZoneOffset = null,
                    endTime = end,
                    endZoneOffset = null,
                    baseline = Temperature.celsius(baseline),
                    deltas = values.mapIndexed { index, celsius ->
                        SkinTemperatureRecord.Delta(
                            time.minusSeconds((values.lastIndex - index) * 60L),
                            TemperatureDelta.celsius(celsius - baseline),
                        )
                    },
                    measurementLocation = SkinTemperatureRecord.MEASUREMENT_LOCATION_FINGER,
                    metadata = metadata,
                )
            }
            else -> error("Unsupported Health Connect metric.")
        }
    }

    fun dispose() {
        pendingAuthorization = null
        channel.setMethodCallHandler(null)
        scope.cancel()
    }
}
