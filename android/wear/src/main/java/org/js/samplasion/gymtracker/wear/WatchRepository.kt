package org.js.samplasion.gymtracker.wear

import android.content.Context
import android.content.Intent
import com.google.android.gms.wearable.*
import kotlinx.coroutines.*
import androidx.concurrent.futures.await
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.json.JSONObject
import org.js.samplasion.gymtracker.wearable.*
import java.time.LocalDate
import java.util.UUID

class WatchRepository private constructor(private val context: Context) {
    val store = Store(context)
    private val link = Link(context, "watch")
    private val lock = Mutex()
    private val networkScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val flushLock = Mutex()
    private val flushAgain = java.util.concurrent.atomic.AtomicBoolean(false)
    private fun requestFlush() { networkScope.launch { flush() } }
    val error = MutableStateFlow<String?>(null)
    private suspend fun owner() = store.get("context")?.text("ownerScope")
    suspend fun start(routine: JSONObject) = lock.withLock {
        val owner = owner() ?: kotlin.error(context.getString(R.string.routines_sync_prompt))
        require(store.get("active", owner) == null)
        val session = Training.start(routine, owner)
        store.transaction {
            store.put("active", session, owner)
            store.put("dirty", session, owner)
        }
        requestFlush()
    }
    suspend fun perform(method: String, values: JSONObject = JSONObject()) = lock.withLock {
        val owner = owner() ?: return@withLock
        val active = store.get("active", owner) ?: return@withLock
        val offset = store.get("clock")?.optLong("offset") ?: 0
        val next = Training.perform(active, method, values, System.currentTimeMillis() + offset)
        store.transaction { store.put("active", next, owner); store.put("dirty", next, owner) }
        RestAlarm.schedule(context, next)
        requestFlush()
    }
    suspend fun finish(save: Boolean) = lock.withLock {
        val owner = owner() ?: return@withLock
        val active = store.get("active", owner) ?: return@withLock
        val next = Training.finish(active, save, System.currentTimeMillis() + (store.get("clock")?.optLong("offset") ?: 0))
        val key = "$owner/${next.getString("id")}"
        store.transaction {
            store.put("pending", next, key)
            store.put("finished", next, key)
            store.put("summary", next)
            store.remove("active", owner); store.remove("dirty", owner)
        }
        stopRecording(active.getString("id"))
        requestFlush()
    }
    suspend fun addWater(amount: Double) = lock.withLock {
        require(amount.isFinite() && amount in 50.0..2000.0)
        val owner = owner() ?: kotlin.error(context.getString(R.string.routines_sync_prompt))
        val entry = JSONObject().put("id", UUID.randomUUID().toString()).put("ownerScope", owner)
            .put("milliliters", amount).put("timeMilliseconds", System.currentTimeMillis())
        store.put("water", entry, "$owner/${entry.getString("id")}")
        requestFlush()
    }
    suspend fun flush() {
        if (!flushLock.tryLock()) { flushAgain.set(true); return }
        try {
            do {
                flushAgain.set(false)
                val snapshot = lock.withLock {
                    val owner = owner() ?: return
                    val active = store.get("active", owner)?.takeIf { store.get("dirty", owner) != null }
                    val pending = store.list("pending").filter { it.text("ownerScope") == owner }
                    val water = store.list("water").filter { it.text("ownerScope") == owner }
                    Triple(owner, active, pending.map { "training" to it } + water.map { "water" to it })
                }
                runCatching {
                    withTimeout(4000) {
                        val (owner, active, entries) = snapshot
                        val previousProbe = store.get("clock-probe")
                        if (System.currentTimeMillis() - (previousProbe?.optLong("sent") ?: 0) > 60_000) {
                            val probe = JSONObject().put("token", UUID.randomUUID().toString()).put("sent", System.currentTimeMillis()).put("ownerScope", owner)
                            store.put("clock-probe", probe)
                            link.message("clock", probe)
                        }
                        if (active != null) {
                            val sent = active.copyJson().put("transferID", Link.identity(active))
                            store.put("sent", sent, owner)
                            link.publish("training", sent, "$owner/active")
                            link.message("training", sent)
                        }
                        for ((type, entry) in entries) {
                            link.publish(type, entry, "$owner/${entry.getString("id")}")
                        }
                    }
                }
            } while (flushAgain.getAndSet(false))
        } finally {
            flushLock.unlock()
            if (flushAgain.getAndSet(false)) requestFlush()
        }
    }
    suspend fun replay() { runCatching { link.replay(::receive) }; flush() }
    suspend fun receive(envelope: JSONObject) = lock.withLock {
        if (envelope.optInt("version") != 1 || envelope.optString("origin") != "phone") return@withLock
        val value = envelope.optJSONObject("payload") ?: return@withLock
        when (envelope.optString("type")) {
            "clock" -> {
                val probe = store.get("clock-probe") ?: return@withLock
                if (value.text("ownerScope") != owner() || value.text("token") != probe.text("token") || !value.has("serverTime")) return@withLock
                val now = System.currentTimeMillis()
                val rtt = now - probe.optLong("sent")
                if (rtt in 0..10_000 && rtt < (store.get("clock")?.optLong("rtt") ?: Long.MAX_VALUE))
                    store.put("clock", JSONObject().put("rtt", rtt).put("offset", value.getLong("serverTime") - (probe.getLong("sent") + now) / 2))
            }
            "state" -> {
                if (value.optInt("version") != 1 || value.text("ownerScope") == null) return@withLock
                val old = store.get("context")
                if (value.optLong("generation") < (old?.optLong("generation") ?: -1)) return@withLock
                val owner = value.getString("ownerScope")
                if (old?.text("ownerScope") != owner) {
                    // The next account cannot see the previous account's session/food.
                    old?.text("ownerScope")?.let { previous -> store.get("active", previous)?.text("id")?.let { stopRecording(it) } }
                }
                val nextCatalog = value.optJSONObject("catalog")
                val previousCatalog = old?.optJSONObject("catalog")
                if (old?.text("ownerScope") == owner && nextCatalog != null && previousCatalog != null && nextCatalog.optLong("revision") < previousCatalog.optLong("revision")) value.put("catalog", previousCatalog)
                store.put("context", value)
                val remote = value.optJSONObject("session")
                if (remote != null && Training.valid(remote) && remote.text("ownerScope") == owner) {
                    if (remote.optString("status") != "active") close(remote)
                    else if (store.get("finished", "$owner/${remote.getString("id")}") == null && store.get("dirty", owner) == null) {
                        val current = store.get("active", owner)
                        if ((current == null || current.text("id") == remote.text("id")) && remote.optLong("modified") >= (current?.optLong("modified") ?: 0)) {
                            store.put("active", remote, owner)
                            RestAlarm.schedule(context, remote)
                        }
                    }
                }
            }
            "ack" -> {
                val owner = owner() ?: return@withLock
                if (!value.optBoolean("accepted") || value.text("ownerScope") != owner) return@withLock
                val doc = value.optJSONObject("document") ?: return@withLock
                if (value.optBoolean("terminal")) close(doc)
                else {
                    val active = store.get("active", owner) ?: return@withLock
                    val source = value.optJSONObject("source") ?: return@withLock
                    if (Training.sameOutgoing(source, active) && doc.text("id") == active.text("id") && doc.text("ownerScope") == owner) {
                        store.transaction { store.put("active", doc, owner); store.remove("dirty", owner) }
                        RestAlarm.schedule(context, doc)
                    }
                }
            }
            "terminal" -> if (value.text("ownerScope") == owner() && Training.valid(value)) close(value)
            "food", "statistics" -> {
                // State is account-scoped by the phone before it is published.
                if (value.text("ownerScope") != owner()) return@withLock
                store.transaction {
                    store.put(envelope.getString("type"), value)
                    if (envelope.optString("type") == "food") {
                        val ids = value.optJSONArray("waterEntryIds")
                        if (ids != null) for (index in 0 until ids.length()) {
                            val key = "${value.getString("ownerScope")}/${ids.getString(index)}"
                            store.put("water-seen", JSONObject().put("id", ids.getString(index)), key)
                            store.remove("water-confirmed", key)
                            store.remove("water", key)
                        }
                    }
                }
                Complications.refresh(context)
            }
            "waterAck" -> {
                val owner = value.text("ownerScope") ?: return@withLock
                val key = "$owner/${value.optString("id")}"
                // Keep an acknowledged overlay until a food snapshot includes its ID.
                store.transaction {
                    if (store.get("water-seen", key) == null && store.get("water", key) != null) store.put("water-confirmed", value, key)
                    store.remove("water", key)
                }
                runCatching { link.remove("water", key) }
            }
            "sensor" -> {
                if (value.text("ownerScope") != owner()) return@withLock
                when (value.optString("action")) {
                    "stop" -> value.text("id")?.let { stopRecording(it) }
                    "start" -> if (value.optLong("deadline") > System.currentTimeMillis()) {
                        store.put("recording-request", value)
                        RecordingPrompt.show(context)
                    }
                    "adopt" -> Unit // Session identity changes do not create sensor sessions.
                }
            }
        }
        error.value = null
    }
    private suspend fun close(doc: JSONObject) {
        val owner = doc.text("ownerScope") ?: return
        val id = doc.text("id") ?: return
        store.transaction {
            store.put("finished", doc, "$owner/$id")
            store.remove("pending", "$owner/$id")
            if (store.get("active", owner)?.text("id") == id) {
                store.put("summary", doc)
                store.remove("active", owner); store.remove("dirty", owner)
            }
        }
        stopRecording(id)
        runCatching { link.remove("training", "$owner/$id") }
    }
    @android.annotation.SuppressLint("WrongConstant", "RestrictedApi")
    private suspend fun stopRecording(id: String) {
        if (WorkoutService.stopIfRunning(id)) return
        val recording = store.get("recording")?.takeIf { it.text("id") == id && it.optString("state") != "ended" } ?: return
        // Ending an orphaned recording never starts a foreground service.
        runCatching {
            withTimeout(4000) {
                val client = androidx.health.services.client.HealthServices.getClient(context).exerciseClient
                val info = client.getCurrentExerciseInfoAsync().await()
                if (info.exerciseTrackedStatus == androidx.health.services.client.data.ExerciseTrackedStatus.OWNED_EXERCISE_IN_PROGRESS) client.endExerciseAsync().await()
                recording.put("state", "ended").put("revision", recording.optLong("revision") + 1)
                store.put("recording", recording)
                val key = "${recording.optString("ownerScope")}/$id/${recording.optString("segment")}"
                store.put("metrics", recording, key)
                link.publish("metrics", recording, key)
            }
        }
    }
    companion object {
        @Volatile private var instance: WatchRepository? = null
        fun get(context: Context) = instance ?: synchronized(this) { instance ?: WatchRepository(context.applicationContext).also { instance = it } }
        fun today() = LocalDate.now().toString()
    }
}
class WatchListener : WearableListenerService() {
    override fun onDataChanged(events: DataEventBuffer) = runBlocking(Dispatchers.IO) {
        val link = Link(this@WatchListener, "watch")
        for (event in events) if (event.type == DataEvent.TYPE_CHANGED) runCatching {
            link.read(event.dataItem)?.let { WatchRepository.get(this@WatchListener).receive(it) }
        }
    }
    override fun onMessageReceived(event: MessageEvent) {
        if (event.path == "/gymbro/v1/live") runBlocking(Dispatchers.IO) { runCatching {
            WatchRepository.get(this@WatchListener).receive(JSONObject(String(event.data)))
        } }
    }
}
