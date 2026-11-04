package org.js.samplasion.gymtracker.wear

import android.app.*
import android.content.*
import android.os.*
import androidx.core.app.NotificationCompat
import androidx.health.services.client.*
import androidx.health.services.client.data.*
import androidx.concurrent.futures.await
import androidx.wear.ongoing.OngoingActivity
import androidx.wear.ongoing.Status
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.json.JSONObject
import org.json.JSONArray
import org.js.samplasion.gymtracker.wearable.*
import java.util.UUID

/** Sensor recording belongs to the service, never to a Compose screen. */
class WorkoutService : Service() {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate + CoroutineExceptionHandler { _, failure ->
        WatchRepository.get(this).error.value = failure.message
        stopForeground(STOP_FOREGROUND_REMOVE); stopSelf()
    })
    private val client by lazy { HealthServices.getClient(this).exerciseClient }
    private val store by lazy { Store(this) }
    private val lock = Mutex()
    private var metrics: JSONObject? = null
    private var lastPublish = 0L
    private val stopRequested = mutableSetOf<String>()
    private var restJob: Job? = null
    private val callback = object : ExerciseUpdateCallback {
        override fun onRegistered() {}
        override fun onRegistrationFailed(throwable: Throwable) { fail(throwable.message ?: "Recording unavailable") }
        override fun onExerciseUpdateReceived(update: ExerciseUpdate) {
            scope.launch { lock.withLock {
                val packet = metrics ?: return@withLock
                update.latestMetrics.getData(DataType.CALORIES_TOTAL)?.let { packet.put("energy", maxOf(packet.optDouble("energy", 0.0), it.total)) }
                val samples = packet.optJSONArray("samples") ?: JSONArray()
                update.latestMetrics.getData(DataType.HEART_RATE_BPM).forEach { point ->
                    val time = System.currentTimeMillis() - (SystemClock.elapsedRealtime() - point.timeDurationFromBoot.toMillis())
                    if (point.value.isFinite() && point.value > 0) {
                        packet.put("heartRate", point.value).put("heartRateTime", time)
                        if ((samples.length() == 0 || time > samples.getJSONObject(samples.length() - 1).optLong("time")))
                            samples.put(JSONObject().put("time", time).put("bpm", point.value.toLong()))
                    }
                }
                packet.put("samples", samples).put("revision", packet.optLong("revision") + 1)
                if (update.exerciseStateInfo.state.isEnded) packet.put("state", "ended")
                persist(packet)
                if (System.currentTimeMillis() - lastPublish >= 5000 || update.exerciseStateInfo.state.isEnded) publish(packet)
                if (update.exerciseStateInfo.state.isEnded) { stopForeground(STOP_FOREGROUND_REMOVE); stopSelf() }
            } }
        }
        override fun onLapSummaryReceived(lapSummary: ExerciseLapSummary) {}
        override fun onAvailabilityChanged(dataType: DataType<*, *>, availability: Availability) {}
    }
    override fun onBind(intent: Intent?) = null
    override fun onCreate() {
        super.onCreate(); running = this
        getSystemService(NotificationManager::class.java).createNotificationChannel(NotificationChannel("workout", "Gym Bro", NotificationManager.IMPORTANCE_LOW))
    }
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try { showNotification() } catch (failure: SecurityException) {
            WatchRepository.get(this).error.value = getString(R.string.sensors_denied)
            stopSelf(); return START_NOT_STICKY
        }
        scope.launch {
            try {
                val context = store.get("context") ?: error(getString(R.string.routines_sync_prompt))
                val owner = context.getString("ownerScope")
                val session = store.get("active", owner) ?: error("No active workout")
                attach(session)
                observeRest(owner)
            } catch (error: Exception) { fail(error.message ?: "Recording unavailable") }
        }
        return START_STICKY
    }
    // Health Services 1.1 exposes these documented public @IntDef constants
    // through a restricted Kotlin Companion, which older lint misidentifies.
    @android.annotation.SuppressLint("WrongConstant", "RestrictedApi")
    private suspend fun attach(session: JSONObject) = lock.withLock {
        val id = session.getString("id")
        require(id !in stopRequested && store.get("finished", "${session.getString("ownerScope")}/$id") == null) { "Workout has ended" }
        if (metrics?.text("id") == id) return@withLock
        val info = client.getCurrentExerciseInfoAsync().await()
        if (info.exerciseTrackedStatus == ExerciseTrackedStatus.OTHER_APP_IN_PROGRESS) error("Another app is recording a workout")
        val previous = store.get("recording")
        val owned = info.exerciseTrackedStatus == ExerciseTrackedStatus.OWNED_EXERCISE_IN_PROGRESS
        if (owned && previous?.text("id") != id) error("A different Gym Bro recording is active")
        val packet = if (owned && previous != null) previous else JSONObject().put("id", id)
            .put("ownerScope", session.getString("ownerScope")).put("segment", UUID.randomUUID().toString())
            .put("energy", 0.0).put("samples", JSONArray()).put("revision", 0).put("start", System.currentTimeMillis())
        metrics = packet.put("state", "starting")
        persist(packet)
        client.setUpdateCallback(callback)
        if (!owned) {
            val capabilities = client.getCapabilitiesAsync().await()
            require(ExerciseType.STRENGTH_TRAINING in capabilities.supportedExerciseTypes) { "Strength training recording unsupported" }
            val supported = capabilities.getExerciseTypeCapabilities(ExerciseType.STRENGTH_TRAINING).supportedDataTypes
            val types = setOf(DataType.HEART_RATE_BPM, DataType.CALORIES_TOTAL).filter { it in supported }.toSet()
            require(types.isNotEmpty()) { "No supported workout sensors" }
            require(id !in stopRequested && store.get("active", session.getString("ownerScope"))?.text("id") == id) { "Workout has ended" }
            client.startExerciseAsync(ExerciseConfig(ExerciseType.STRENGTH_TRAINING, dataTypes = types,
                isAutoPauseAndResumeEnabled = false, isGpsEnabled = false)).await()
        }
        packet.put("state", "running"); persist(packet); publish(packet)
    }
    private suspend fun persist(packet: JSONObject) {
        store.transaction {
            store.put("recording", packet)
            store.put("metrics", packet, "${packet.optString("ownerScope")}/${packet.optString("id")}/${packet.optString("segment")}")
        }
    }
    private suspend fun publish(packet: JSONObject) {
        lastPublish = System.currentTimeMillis()
        runCatching {
            withTimeout(4000) {
                val link = Link(this@WorkoutService, "watch")
                link.publish("metrics", packet, "${packet.optString("ownerScope")}/${packet.optString("id")}/${packet.optString("segment")}")
                // Live display doesn't need the historical samples.
                link.message("metrics", packet.copyJson().apply { remove("samples") })
            }
        }
    }
    private fun observeRest(owner: String) {
        restJob?.cancel()
        restJob = scope.launch {
            while (isActive) {
                val active = store.get("active", owner) ?: break
                RestAlarm.notify(this@WorkoutService, active)
                delay(500)
            }
        }
    }
    private fun showNotification() {
        val pending = PendingIntent.getActivity(this, 0, Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val builder = NotificationCompat.Builder(this, "workout").setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("Gym Bro").setContentText(getString(R.string.workout_recording)).setOngoing(true).setContentIntent(pending)
        OngoingActivity.Builder(this, 20, builder).setStaticIcon(R.drawable.ic_launcher_foreground).setTouchIntent(pending)
            .setStatus(Status.Builder().addTemplate("Gym Bro").build()).build().apply(this)
        if (Build.VERSION.SDK_INT >= 34) startForeground(20, builder.build(), android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH)
        else startForeground(20, builder.build())
    }
    private fun fail(message: String) {
        scope.launch {
            WatchRepository.get(this@WorkoutService).error.value = message
            store.put("recording-error", JSONObject().put("message", message))
            stopForeground(STOP_FOREGROUND_REMOVE); stopSelf()
        }
    }
    private fun end(id: String) {
        stopRequested.add(id)
        scope.launch { lock.withLock {
            val packet = metrics ?: run { stopForeground(STOP_FOREGROUND_REMOVE); stopSelf(); return@withLock }
            if (packet.text("id") != id) return@withLock
            try {
                client.endExerciseAsync().await()
                packet.put("state", "ended").put("revision", packet.optLong("revision") + 1)
                persist(packet); publish(packet)
            } catch (failure: Exception) {
                WatchRepository.get(this@WorkoutService).error.value = failure.message
            } finally { stopForeground(STOP_FOREGROUND_REMOVE); stopSelf() }
        } }
    }
    override fun onDestroy() {
        running = null; restJob?.cancel()
        client.clearUpdateCallbackAsync(callback)
        scope.cancel(); super.onDestroy()
    }
    companion object {
        private var running: WorkoutService? = null
        fun isRecording(id: String) = running?.metrics?.text("id") == id
        fun stopIfRunning(id: String): Boolean {
            val service = running ?: return false
            service.end(id)
            return true
        }
    }
}
