package org.js.samplasion.gymtracker

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.*
import androidx.health.connect.client.records.metadata.Metadata
import androidx.health.connect.client.units.Energy
import androidx.work.*
import org.js.samplasion.gymtracker.wearable.*
import java.time.Instant
import java.time.ZoneId
import java.util.concurrent.TimeUnit

/** Health Connect failures never roll back a Gym Bro history import. */
class HealthExport(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result {
        if (android.os.Build.VERSION.SDK_INT < 28 || HealthConnectClient.getSdkStatus(applicationContext) != HealthConnectClient.SDK_AVAILABLE) return Result.success()
        val client = HealthConnectClient.getOrCreate(applicationContext)
        if (!client.permissionController.getGrantedPermissions().containsAll(permissions)) return Result.success()
        val store = Store(applicationContext)
        val owner = store.get("state")?.text("ownerScope") ?: return Result.success()
        return try {
            for (doc in store.list("health-outbox").filter { it.text("ownerScope") == owner }) {
                val id = doc.getString("id")
                val key = "$owner/$id"
                val prefix = "gymbro:${Link.digest(key)}"
                if (doc.optString("status") != "completed" || store.get("health-deleted", key) != null) {
                    client.deleteRecords(ExerciseSessionRecord::class, clientRecordIdsList = listOf("$prefix:session"), recordIdsList = emptyList())
                    client.deleteRecords(TotalCaloriesBurnedRecord::class, clientRecordIdsList = listOf("$prefix:energy"), recordIdsList = emptyList())
                    client.deleteRecords(HeartRateRecord::class, clientRecordIdsList = listOf("$prefix:heart"), recordIdsList = emptyList())
                    store.put("health-receipt", doc, key)
                    continue
                }
                val start = Instant.ofEpochMilli(doc.getLong("time"))
                val end = Instant.ofEpochMilli(doc.getLong("end"))
                if (end <= start) continue
                val segments = store.list("metrics").filter { it.text("id") == id && it.text("ownerScope") == owner }
                val fingerprint = Link.digest(doc.toString() + segments.sortedBy { it.optString("segment") }.joinToString { it.toString() })
                if (store.get("health-receipt", key)?.text("fingerprint") == fingerprint) continue
                val reservation = ExportVersion.reserve(store.get("health-intent", key), store.get("health-receipt", key), fingerprint)
                val version = reservation.getLong("version")
                store.put("health-intent", reservation, key)
                fun metadata(suffix: String) = Metadata.activelyRecorded(clientRecordId = "$prefix:$suffix", clientRecordVersion = version,
                    device = androidx.health.connect.client.records.metadata.Device(type = androidx.health.connect.client.records.metadata.Device.TYPE_WATCH))
                val zone = ZoneId.systemDefault()
                val records = mutableListOf<Record>(ExerciseSessionRecord(startTime = start, startZoneOffset = zone.rules.getOffset(start),
                    endTime = end, endZoneOffset = zone.rules.getOffset(end), exerciseType = ExerciseSessionRecord.EXERCISE_TYPE_STRENGTH_TRAINING,
                    title = doc.optString("name", "Gym Bro"), metadata = metadata("session")))
                val energy = segments.sumOf { it.optDouble("energy", 0.0) }
                if (energy.isFinite() && energy > 0) records.add(TotalCaloriesBurnedRecord(startTime = start, startZoneOffset = zone.rules.getOffset(start),
                    endTime = end, endZoneOffset = zone.rules.getOffset(end), energy = Energy.kilocalories(energy), metadata = metadata("energy")))
                val samples = segments.flatMap { it.objects("samples") }.filter { it.optLong("time") in start.toEpochMilli()..end.toEpochMilli() && it.optLong("bpm") in 1..300 }
                    .distinctBy { it.optLong("time") }.sortedBy { it.optLong("time") }
                    .map { HeartRateRecord.Sample(Instant.ofEpochMilli(it.getLong("time")), it.getLong("bpm")) }
                if (samples.isNotEmpty()) records.add(HeartRateRecord(startTime = start, startZoneOffset = zone.rules.getOffset(start),
                    endTime = end, endZoneOffset = zone.rules.getOffset(end), samples = samples, metadata = metadata("heart")))
                if (store.get("state")?.text("ownerScope") != owner) return Result.retry()
                client.insertRecords(records)
                store.put("health-receipt", org.json.JSONObject().put("fingerprint", fingerprint).put("version", version), key)
            }
            Result.success()
        } catch (_: Exception) { Result.retry() }
    }
    companion object {
        val permissions = setOf(HealthPermission.getWritePermission(ExerciseSessionRecord::class), HealthPermission.getWritePermission(HeartRateRecord::class), HealthPermission.getWritePermission(TotalCaloriesBurnedRecord::class))
        fun schedule(context: Context) {
            WorkManager.getInstance(context).enqueueUniqueWork("gymbro-wear-health-export", ExistingWorkPolicy.APPEND_OR_REPLACE,
                OneTimeWorkRequestBuilder<HealthExport>().setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS).build())
        }
    }
}
