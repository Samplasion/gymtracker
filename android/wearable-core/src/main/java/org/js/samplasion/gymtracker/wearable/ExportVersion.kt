package org.js.samplasion.gymtracker.wearable

import org.json.JSONObject

/** Reserve before the external write: a lost receipt cannot reuse a version for
 * different content, while an unchanged retry reuses its stable version. */
object ExportVersion {
    fun reserve(intent: JSONObject?, receipt: JSONObject?, fingerprint: String): JSONObject {
        val version = if (intent?.text("fingerprint") == fingerprint) intent.getLong("version")
            else maxOf(intent?.optLong("version") ?: 0, receipt?.optLong("version") ?: 0) + 1
        return JSONObject().put("fingerprint", fingerprint).put("version", version)
    }
}
