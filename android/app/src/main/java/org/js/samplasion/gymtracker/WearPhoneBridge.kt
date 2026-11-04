package org.js.samplasion.gymtracker

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.google.android.gms.wearable.*
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.*
import org.json.JSONObject
import org.js.samplasion.gymtracker.wearable.*

/** Process-independent inbox. Flutter alone reconciles/imports training results. */
class WearPhoneBridge private constructor(private val context: Context) {
    val store = Store(context)
    private val link = Link(context, "phone")
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val main = Handler(Looper.getMainLooper())
    private var channel: MethodChannel? = null
    private var flutter: GymBroNativeFlutterAPI? = null
    private var heartExpiry: Runnable? = null
    private var waterReady = false
    private val waterLock = kotlinx.coroutines.sync.Mutex()
    fun attach(messenger: BinaryMessenger, api: GymBroNativeFlutterAPI) {
        flutter = api
        channel?.setMethodCallHandler(null)
        channel = MethodChannel(messenger, "gymbro/training").also { channel ->
            channel.setMethodCallHandler { call, result ->
                scope.launch {
                    try {
                        val args = (call.arguments as? Map<*, *>)?.let(::json) ?: JSONObject()
                        val answer: Any? = when (call.method) {
                            "statistics" -> { store.put("statistics", args); runCatching { link.publish("statistics", args) }; null }
                            "deleteHealthWorkout" -> {
                                val key = "${args.getString("ownerScope")}/${args.getString("id")}"
                                val deleted = args.copyJson().put("status", "discarded")
                                store.transaction { store.put("health-deleted", deleted, key); store.put("health-outbox", deleted, key) }
                                HealthExport.schedule(context)
                                null
                            }
                            "exchange" -> exchange(args)
                            "acknowledge" -> { acknowledge(args.getJSONObject("source"), args.getJSONObject("response")); null }
                            "adoptSensors" -> { publish("sensor", args.copyJson().put("action", "adopt")); null }
                            "terminal" -> { terminal(args); null }
                            else -> { main.post { result.notImplemented() }; return@launch }
                        }
                        main.post { result.success(answer) }
                    } catch (error: Exception) {
                        main.post { result.error("wearable_storage", error.message, null) }
                    }
                }
            }
        }
        scope.launch { runCatching { link.replay(::receive); drainWater() }; HealthExport.schedule(context) }
    }
    fun detach() { channel?.setMethodCallHandler(null); channel = null; flutter = null; waterReady = false; heartExpiry?.let { main.removeCallbacks(it) }; heartExpiry = null }
    suspend fun exchange(state: JSONObject): List<Map<String, Any?>> {
        val old = store.get("state")
        val changed = old?.text("ownerScope") != state.text("ownerScope")
        val generation = (old?.optLong("generation") ?: 0) + if (changed) 1 else 0
        val next = state.copyJson().put("generation", generation)
        val catalog = state.optJSONObject("catalog") ?: if (!changed) old?.optJSONObject("catalog") else null
        catalog?.put("generation", generation)?.put("revision", if (state.has("catalog")) System.currentTimeMillis() else catalog.optLong("revision"))
        if (catalog != null) next.put("catalog", catalog)
        store.put("state", next)
        // Sending failure never loses the cached context or inbox.
        runCatching {
            link.publish("state", next)
            for (type in listOf("food", "statistics")) store.get(type)?.takeIf { it.text("ownerScope") == next.text("ownerScope") }?.let { link.publish(type, it) }
        }
        drainWater()
        return store.list("training-inbox").filter { it.text("ownerScope") == next.text("ownerScope") }.map { it.toMap() }
    }
    suspend fun acknowledge(source: JSONObject, response: JSONObject) {
        if (!response.optBoolean("accepted")) return
        val key = Link.identity(source)
        store.transaction {
            store.put("training-ack", response.copyJson().put("source", source), key)
            store.remove("training-inbox", key)
            if (response.optBoolean("terminal")) {
                val doc = response.optJSONObject("document") ?: source
                store.put("health-outbox", doc, "${source.optString("ownerScope")}/${source.optString("id")}")
            }
        }
        runCatching { link.publish("ack", response.copyJson().put("source", source), key) }
        HealthExport.schedule(context)
    }
    suspend fun terminal(doc: JSONObject) {
        store.transaction {
            store.put("terminal", doc, "${doc.optString("ownerScope")}/${doc.optString("id")}")
            store.put("health-outbox", doc, "${doc.optString("ownerScope")}/${doc.optString("id")}")
        }
        runCatching { link.publish("terminal", doc, "${doc.optString("ownerScope")}/${doc.optString("id")}") }
        HealthExport.schedule(context)
    }
    fun publishAsync(type: String, payload: JSONObject) = scope.launch {
        if (type in listOf("food", "statistics", "sensor", "snapshot")) {
            val owner = if (type == "food") payload.text("waterOwnerScope") else store.get("state")?.text("ownerScope")
            if (owner == null) return@launch
            payload.put("ownerScope", owner)
        }
        store.put(type, payload)
        runCatching { link.publish(type, payload) }
    }
    private suspend fun publish(type: String, payload: JSONObject) {
        store.put(type, payload)
        runCatching { link.publish(type, payload); link.message(type, payload) }
    }
    fun start(id: String, start: Long) = publishAsync("sensor", JSONObject().put("action", "start").put("id", id)
        .put("start", start).put("deadline", System.currentTimeMillis() + 30_000))
    fun stop(id: String, save: Boolean) = publishAsync("sensor", JSONObject().put("action", "stop").put("id", id).put("save", save))
    fun readyForWater() { waterReady = true; scope.launch { drainWater() } }
    private suspend fun drainWater() {
        if (!waterReady || !waterLock.tryLock()) return
        try {
        val owner = store.get("state")?.text("ownerScope") ?: return
        for (entry in store.list("water-inbox").filter { it.text("ownerScope") == owner }) {
            val api = flutter ?: return
            val accepted = withTimeoutOrNull(5000) { withContext(Dispatchers.Main) {
                suspendCancellableCoroutine<Boolean> { continuation ->
                    api.importWaterEntry(entry.getString("id"), entry.getDouble("milliliters"), entry.getLong("timeMilliseconds"), owner) {
                        if (continuation.isActive) continuation.resume(it.getOrDefault(false), null)
                    }
                }
            } } ?: false
            if (accepted) {
                val key = "$owner/${entry.getString("id")}"
                store.put("water-ack", entry, key)
                store.remove("water-inbox", key)
                runCatching { link.publish("waterAck", entry, key) }
            }
        }
        } finally { waterLock.unlock() }
    }
    suspend fun receive(envelope: JSONObject) {
        if (envelope.optInt("version") != 1 || envelope.optString("origin") != "watch") return
        val payload = envelope.optJSONObject("payload") ?: return
        when (envelope.optString("type")) {
            "clock" -> {
                if (payload.text("ownerScope") == store.get("state")?.text("ownerScope")) runCatching { link.message("clock", payload.copyJson().put("serverTime", System.currentTimeMillis())) }
            }
            "training" -> {
                if (!Training.valid(payload)) return
                val key = Link.identity(payload)
                val ack = store.get("training-ack", key)
                if (ack != null) runCatching { link.publish("ack", ack, key) }
                else store.put("training-inbox", payload, key)
            }
            "water" -> {
                val id = payload.text("id") ?: return
                val owner = payload.text("ownerScope") ?: return
                val amount = payload.optDouble("milliliters")
                if (!amount.isFinite() || amount <= 0 || payload.optLong("timeMilliseconds") <= 0) return
                val key = "$owner/$id"
                if (store.get("water-ack", key) != null) runCatching { link.publish("waterAck", payload, key) }
                else { store.put("water-inbox", payload, key); drainWater() }
            }
            "metrics" -> {
                val id = payload.text("id") ?: return
                val owner = payload.text("ownerScope") ?: return
                val metricKey = "$owner/$id/${payload.optString("segment")}"
                val merged = Metrics.merge(store.get("metrics", metricKey), payload)
                if (Training.canonical(store.get("metrics", metricKey)) == Training.canonical(merged)) return
                store.put("metrics", merged, metricKey)
                if (store.get("state")?.optJSONObject("session")?.text("id") == id && store.get("state")?.text("ownerScope") == owner) {
                    val energy = store.list("metrics").filter { it.text("id") == id && it.text("ownerScope") == owner }.sumOf { it.optDouble("energy", 0.0) }
                    val age = System.currentTimeMillis() - payload.optLong("heartRateTime")
                    val heart = payload.optDouble("heartRate", 0.0).takeIf { age in -5000..30_000 && payload.optString("state") != "ended" } ?: 0.0
                    main.post {
                        heartExpiry?.let { main.removeCallbacks(it) }
                        flutter?.handleWorkoutMetrics(energy, heart) {}
                        heartExpiry = Runnable { flutter?.handleWorkoutMetrics(null, 0.0) {} }.also {
                            main.postDelayed(it, (30_000 - age).coerceIn(0, 35_000))
                        }
                    }
                }
                if (store.get("health-outbox", "$owner/$id") != null) HealthExport.schedule(context)
            }
        }
    }
    companion object {
        @Volatile private var instance: WearPhoneBridge? = null
        fun get(context: Context) = instance ?: synchronized(this) { instance ?: WearPhoneBridge(context.applicationContext).also { instance = it } }
    }
}

class WearPhoneListener : WearableListenerService() {
    override fun onDataChanged(events: DataEventBuffer) {
        runBlocking(Dispatchers.IO) {
            val link = Link(this@WearPhoneListener, "phone")
            for (event in events) if (event.type == DataEvent.TYPE_CHANGED) runCatching {
                link.read(event.dataItem)?.let { WearPhoneBridge.get(this@WearPhoneListener).receive(it) }
            }
        }
    }
    override fun onMessageReceived(event: MessageEvent) {
        if (event.path != "/gymbro/v1/live") return
        runBlocking(Dispatchers.IO) { runCatching { WearPhoneBridge.get(this@WearPhoneListener).receive(JSONObject(String(event.data))) } }
    }
}
