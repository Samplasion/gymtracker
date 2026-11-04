package org.js.samplasion.gymtracker.wear

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import org.json.JSONObject
import org.js.samplasion.gymtracker.wearable.*

class WatchViewModel(app: Application) : AndroidViewModel(app) {
    val repository = WatchRepository.get(app)
    val documents = repository.store.dao.observe().stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())
    val error = repository.error
    val busy = MutableStateFlow(false)
    val connected = MutableStateFlow(false)
    suspend fun refreshConnection() {
        connected.value = runCatching {
            com.google.android.gms.wearable.Wearable.getCapabilityClient(getApplication<Application>())
                .getCapability("gymbro_phone_v1", com.google.android.gms.wearable.CapabilityClient.FILTER_REACHABLE).await().nodes.isNotEmpty()
        }.getOrDefault(false)
    }
    fun act(block: suspend WatchRepository.() -> Unit) = viewModelScope.launch {
        if (!busy.compareAndSet(false, true)) return@launch
        try { repository.block() } catch (failure: Exception) { error.value = failure.message }
        finally { busy.value = false }
    }
    fun screenshots(scene: String, appStore: Boolean = false, restSeconds: Int = 90) = viewModelScope.launch { ScreenshotFixtures.seed(repository, scene, appStore, restSeconds) }
    init { act { replay() } }
}

class WatchState(private val rows: List<Document>) {
    fun get(kind: String, key: String = "current") = rows.firstOrNull { it.kind == kind && it.key == key }?.let { JSONObject(it.body) }
    fun list(kind: String) = rows.filter { it.kind == kind }.map { JSONObject(it.body) }
    val context get() = get("context")
    val owner get() = context?.text("ownerScope")
    val catalog get() = context?.optJSONObject("catalog")
    val active get() = owner?.let { get("active", it) }
    val pending get() = list("pending").filter { it.text("ownerScope") == owner }
    val food get() = get("food")?.takeIf { it.text("ownerScope") == owner }
    val currentFood get() = food?.takeIf { it.text("referenceDay") == WatchRepository.today() }
    val statistics get() = get("statistics")?.takeIf { it.text("ownerScope") == owner }
    val water get() = list("water").filter { it.text("ownerScope") == owner }
    val waterOverlay get() = (water + list("water-confirmed").filter { it.text("ownerScope") == owner }).filter { entry ->
        val ids = food?.optJSONArray("waterEntryIds")
        val known = ids?.let { (0 until it.length()).map { i -> it.optString(i) } } ?: emptyList()
        val day = java.time.Instant.ofEpochMilli(entry.optLong("timeMilliseconds")).atZone(java.time.ZoneId.systemDefault()).toLocalDate().toString()
        entry.optString("id") !in known && day == WatchRepository.today()
    }.sumOf { it.optDouble("milliliters", 0.0) }
    val waterTotal get() = (currentFood?.optDouble("waterIntake", 0.0) ?: 0.0) + waterOverlay
    val metrics get() = list("metrics").filter { it.text("ownerScope") == owner && it.text("id") == active?.text("id") }
}
