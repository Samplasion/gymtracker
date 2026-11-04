package org.js.samplasion.gymtracker.wearable

import android.content.Context
import com.google.android.gms.wearable.*
import kotlinx.coroutines.tasks.await
import org.json.JSONObject
import java.security.MessageDigest

/** DataItems are replaceable only at explicit keys; results remain until ACK. */
class Link(private val context: Context, private val role: String) {
    private val data = Wearable.getDataClient(context)
    suspend fun publish(type: String, payload: JSONObject, key: String = "current") {
        val envelope = JSONObject().put("version", 1).put("origin", role).put("type", type).put("payload", payload)
        val request = PutDataMapRequest.create(path(type, key))
        request.dataMap.putAsset("body", Asset.createFromBytes(envelope.toString().toByteArray(Charsets.UTF_8)))
        data.putDataItem(request.asPutDataRequest().setUrgent()).await()
    }
    suspend fun remove(type: String, key: String) {
        val uri = android.net.Uri.Builder().scheme("wear").path(path(type, key)).build()
        data.deleteDataItems(uri, DataClient.FILTER_LITERAL).await()
    }
    suspend fun message(type: String, payload: JSONObject): Boolean {
        val other = if (role == "phone") "gymbro_watch_v1" else "gymbro_phone_v1"
        val nodes = Wearable.getCapabilityClient(context).getCapability(other, CapabilityClient.FILTER_REACHABLE).await().nodes
        val node = nodes.sortedWith(compareByDescending<Node> { it.isNearby }.thenBy { it.id }).firstOrNull() ?: return false
        val bytes = JSONObject().put("version", 1).put("origin", role).put("type", type).put("payload", payload).toString().toByteArray()
        if (bytes.size > 60_000) return false
        Wearable.getMessageClient(context).sendMessage(node.id, "/gymbro/v1/live", bytes).await()
        return true
    }
    suspend fun read(item: DataItem): JSONObject? {
        if (!item.uri.path.orEmpty().startsWith("/gymbro/v1/")) return null
        val asset = DataMapItem.fromDataItem(item).dataMap.getAsset("body") ?: return null
        val response = data.getFdForAsset(asset).await()
        return response.inputStream.use { stream ->
            val output = java.io.ByteArrayOutputStream()
            val buffer = ByteArray(8192)
            while (true) {
                val count = stream.read(buffer)
                if (count < 0) break
                require(output.size() + count <= 8 * 1024 * 1024) { "Wearable document too large" }
                output.write(buffer, 0, count)
            }
            val bytes = output.toByteArray()
            JSONObject(String(bytes, Charsets.UTF_8))
        }
    }
    suspend fun replay(receive: suspend (JSONObject) -> Unit) {
        val items = data.dataItems.await()
        try { for (item in items) read(item)?.let { receive(it) } } finally { items.release() }
    }
    private fun path(type: String, key: String) = "/gymbro/v1/$role/$type/${digest(key)}"
    companion object {
        fun identity(doc: JSONObject) = "${doc.optString("ownerScope")}/${doc.optString("id")}/${doc.optLong("sequence")}/${doc.optLong("modified")}/${doc.optString("status")}"
        fun digest(value: String) = MessageDigest.getInstance("SHA-256").digest(value.toByteArray()).joinToString("") { "%02x".format(it) }
    }
}
