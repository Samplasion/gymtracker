package org.js.samplasion.gymtracker.wearable

import org.json.JSONObject

/** A live packet can refine a segment without erasing its stored sample history. */
object Metrics {
    fun merge(previous: JSONObject?, incoming: JSONObject): JSONObject {
        require(incoming.text("id") != null && incoming.text("ownerScope") != null && incoming.text("segment") != null)
        require(incoming.optDouble("energy", 0.0).let { it.isFinite() && it >= 0 })
        if (previous == null) return incoming.copyJson()
        require(listOf("id", "ownerScope", "segment").all { incoming.text(it) == previous.text(it) })
        if (incoming.optLong("revision") < previous.optLong("revision")) return previous.copyJson()
        return incoming.copyJson().apply {
            put("energy", maxOf(previous.optDouble("energy", 0.0), incoming.optDouble("energy", 0.0)))
            if (previous.optString("state") == "ended") put("state", "ended")
            if (!has("samples") || objects("samples").size < previous.objects("samples").size) previous.optJSONArray("samples")?.let { put("samples", it) }
        }
    }
}
