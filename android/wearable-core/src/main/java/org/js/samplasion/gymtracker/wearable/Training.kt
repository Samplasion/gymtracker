package org.js.samplasion.gymtracker.wearable

import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

fun JSONObject.objects(key: String): List<JSONObject> = optJSONArray(key)?.let { a ->
    (0 until a.length()).mapNotNull { a.optJSONObject(it) }
} ?: emptyList()
fun JSONObject.copyJson() = JSONObject(toString())
fun JSONObject.text(key: String): String? = if (isNull(key)) null else optString(key).takeIf { it.isNotEmpty() }
fun JSONObject.toMap(): Map<String, Any?> = keys().asSequence().associateWith { key -> jsonValue(get(key)) }
private fun jsonValue(v: Any?): Any? = when (v) {
    JSONObject.NULL -> null
    is JSONObject -> v.toMap()
    is JSONArray -> (0 until v.length()).map { jsonValue(v.get(it)) }
    else -> v
}
fun json(map: Map<*, *>): JSONObject = JSONObject(map)

/** Wire v1: Dart durations are microseconds; dates are Unix milliseconds. */
object Training {
    data class Position(val exercise: JSONObject, val set: JSONObject, val restMicros: Long, val notes: String)
    fun ordered(doc: JSONObject): List<Position> = buildList {
        for (group in doc.objects("exercises")) {
            val superset = group.optString("type") == "superset"
            val children = if (superset) group.objects("exercises") else listOf(group)
            repeat(children.maxOfOrNull { it.objects("sets").size } ?: 0) { index ->
                children.forEachIndexed { childIndex, exercise ->
                    val sets = exercise.objects("sets")
                    sets.getOrNull(index)?.let { set ->
                        val stripping = sets.getOrNull(index + 1)?.optString("kind") == "failureStripping"
                        val rest = if (stripping || (superset && childIndex != children.lastIndex)) 0L else group.optLong("restTime")
                        add(Position(exercise, set, rest, if (superset) group.optString("notes") else ""))
                    }
                }
            }
        }
    }
    fun current(doc: JSONObject) = ordered(doc).firstOrNull { it.set.text("id") == doc.text("cursor") }
    fun start(routine: JSONObject, owner: String, now: Long = System.currentTimeMillis()): JSONObject {
        val result = routine.copyJson()
        val id = UUID.randomUUID().toString()
        result.put("parentID", result.opt("id")).put("id", id).put("nativeWorkoutId", id)
            .put("ownerScope", owner).put("version", 1).put("time", now).put("status", "active")
            .put("weightUnit", routine.optString("weightUnit", "kg"))
            .put("distanceUnit", routine.optString("distanceUnit", "km"))
        result.remove("folder")
        fun clone(exercise: JSONObject) {
            exercise.put("supersedesID", exercise.opt("id")).put("id", UUID.randomUUID().toString())
                .put("workoutID", id).put("rpe", JSONObject.NULL)
            exercise.objects("sets").forEach { set ->
                set.put("id", UUID.randomUUID().toString()).put("done", false)
                if (set.optString("kind") in listOf("failure", "failureStripping")) set.put("reps", 0)
            }
        }
        result.objects("exercises").forEach { group ->
            if (group.optString("type") == "superset") {
                group.put("supersedesID", group.opt("id")).put("id", UUID.randomUUID().toString()).put("workoutID", id)
                group.objects("exercises").forEach { clone(it); it.put("supersetID", group.opt("id")) }
            } else clone(group)
        }
        return result.put("cursor", ordered(result).firstOrNull()?.set?.opt("id") ?: JSONObject.NULL)
            .put("stamps", JSONObject()).put("sequence", 0).put("epoch", 0).put("modified", now)
    }
    fun perform(source: JSONObject, method: String, values: JSONObject = JSONObject(), now: Long = System.currentTimeMillis()): JSONObject {
        val doc = source.copyJson()
        require(doc.optString("status") == "active")
        val ordered = ordered(doc)
        val index = ordered.indexOfFirst { it.set.text("id") == doc.text("cursor") }
        require(index >= 0) { "No current set" }
        val current = ordered[index]
        val sequence = doc.optLong("sequence") + 1
        when (method) {
            "moveWorkoutCursorNext", "moveWorkoutCursorPrevious" -> {
                val next = index + if (method.endsWith("Next")) 1 else -1
                ordered.getOrNull(next)?.let { doc.put("cursor", it.set.opt("id")) }
            }
            "markThisSetAsDone", "updateSetParameters" -> {
                if (method == "markThisSetAsDone") {
                    current.set.put("done", true)
                    if (current.restMicros > 0) doc.put("restStart", now).put("restEnd", now + current.restMicros / 1000)
                } else {
                    val parameters = current.set.optString("parameters")
                    val allowed = fields(parameters)
                    values.keys().forEach { key ->
                        require(key in allowed) { "Unsupported set parameter" }
                        val number = values.getDouble(key)
                        val maximum = when (key) { "reps" -> 100.0; "time" -> 600.0; else -> 1000.0 }
                        require(number.isFinite() && number in 0.0..maximum)
                        current.set.put(key, when (key) { "time" -> (number * 1_000_000).toLong(); "reps" -> number.toInt(); else -> number })
                    }
                }
                val stamps = doc.optJSONObject("stamps") ?: JSONObject()
                stamps.put(current.set.getString("id"), JSONObject().put("time", now).put("device", "watch").put("sequence", sequence))
                doc.put("stamps", stamps)
                if (method == "markThisSetAsDone") doc.put("cursor", (ordered.drop(index + 1) + ordered)
                    .firstOrNull { !it.set.optBoolean("done") }?.set?.opt("id") ?: JSONObject.NULL)
            }
            else -> error("Unsupported training command")
        }
        return doc.put("sequence", sequence).put("modified", now)
    }
    fun fields(parameters: String): Set<String> = when (parameters) {
        "repsWeight", "repsNegWeight" -> setOf("reps", "weight")
        "timeWeight" -> setOf("time", "weight")
        "freeBodyReps" -> setOf("reps")
        "time" -> setOf("time")
        "distance" -> setOf("distance")
        else -> emptySet()
    }
    fun finish(source: JSONObject, save: Boolean, now: Long = System.currentTimeMillis()) = source.copyJson()
        .put("status", if (save) "completed" else "discarded").put("end", now)
        .put("duration", (now - source.getLong("time")).coerceAtLeast(0) * 1000)
    fun sameOutgoing(sent: JSONObject, current: JSONObject): Boolean = listOf("id", "ownerScope", "sequence", "modified", "cursor", "epoch", "exercises")
        .all { canonical(sent.opt(it)) == canonical(current.opt(it)) }
    fun canonical(value: Any?): String = when (value) {
        null, JSONObject.NULL -> "null"
        is JSONObject -> value.keys().asSequence().sorted().filter { !value.isNull(it) }
            .joinToString(",", "{", "}") { JSONObject.quote(it) + ":" + canonical(value.get(it)) }
        is JSONArray -> (0 until value.length()).joinToString(",", "[", "]") { canonical(value.get(it)) }
        is Number -> if (value.toDouble() == value.toLong().toDouble()) value.toLong().toString() else value.toString()
        is String -> JSONObject.quote(value)
        else -> value.toString()
    }
    fun valid(doc: JSONObject) = doc.optInt("version") == 1 && doc.text("ownerScope") != null && doc.text("id") != null &&
        doc.optJSONArray("exercises") != null && doc.optLong("time") > 0 &&
        doc.optString("status") in listOf("active", "completed", "discarded") &&
        (doc.optString("status") == "active" || doc.optLong("end") >= doc.optLong("time"))
}
