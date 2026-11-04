package org.js.samplasion.gymtracker.wearable

import org.json.JSONObject
import org.junit.Assert.*
import org.junit.Test

class TrainingTest {
    private fun routine() = JSONObject("""{"id":"routine","name":"Strength","restTime":30000000,"custom":{"keep":true},"exercises":[{"type":"exercise","id":"squat","name":"Squat","restTime":60000000,"notes":"notes","sets":[{"id":"a","kind":"normal","parameters":"repsWeight","weight":42.5,"reps":8,"time":0,"custom":"preserved"},{"id":"b","kind":"failure","parameters":"repsWeight","reps":8,"weight":40}]}]}""")
    @Test fun cloneRetainsSourcesAndUnknownFields() {
        val source = routine()
        val started = Training.start(source, "guest", 1000)
        assertEquals("routine", started.getString("parentID"))
        assertNotEquals("routine", started.getString("id"))
        assertEquals("squat", Training.ordered(started)[0].exercise.getString("supersedesID"))
        assertEquals("preserved", Training.ordered(started)[0].set.getString("custom"))
        assertEquals(0, Training.ordered(started)[1].set.getInt("reps"))
        assertEquals(8, Training.ordered(source)[1].set.getInt("reps"))
        assertTrue(started.getJSONObject("custom").getBoolean("keep"))
    }
    @Test fun completionAdvancesAndUsesMillisecondsForRest() {
        val start = Training.start(routine(), "guest", 1000)
        val done = Training.perform(start, "markThisSetAsDone", now = 2000)
        assertTrue(Training.ordered(done)[0].set.getBoolean("done"))
        assertFalse(Training.ordered(start)[0].set.optBoolean("done"))
        assertEquals(62000L, done.getLong("restEnd"))
        assertEquals(Training.ordered(done)[1].set.getString("id"), done.getString("cursor"))
        assertEquals("watch", done.getJSONObject("stamps").getJSONObject(start.getString("cursor")).getString("device"))
    }
    @Test fun supersetInterleavesRoundsAndRestsOnlyAfterLastChild() {
        val doc = JSONObject("""{"exercises":[{"id":"super","type":"superset","restTime":90000000,"notes":"group","exercises":[{"id":"a","sets":[{"id":"a1"},{"id":"a2"}]},{"id":"b","sets":[{"id":"b1"},{"id":"b2"}]}]}]}""")
        val ordered = Training.ordered(doc)
        assertEquals(listOf("a1", "b1", "a2", "b2"), ordered.map { it.set.getString("id") })
        assertEquals(listOf(0L, 90000000L, 0L, 90000000L), ordered.map { it.restMicros })
        assertEquals("group", ordered[0].notes)
    }
    @Test fun timeIsConvertedOnlyAtWireBoundary() {
        val doc = Training.start(routine(), "guest", 1000)
        Training.current(doc)!!.set.put("parameters", "timeWeight")
        val result = Training.perform(doc, "updateSetParameters", JSONObject().put("time", 25.5).put("weight", 30), 2000)
        assertEquals(25500000L, Training.current(result)!!.set.getLong("time"))
        assertEquals(2500000L, Training.finish(result, true, 3500).getLong("duration"))
    }
    @Test fun outdatedAcknowledgementCannotTakeOwnership() {
        val sent = Training.start(routine(), "guest", 1000)
        val modified = Training.perform(sent, "markThisSetAsDone", now = 2000)
        assertFalse(Training.sameOutgoing(sent, modified))
        assertTrue(Training.sameOutgoing(sent, sent.copyJson()))
    }
    @Test fun canonicalNormalizesNumbersAndNullFields() {
        assertEquals(Training.canonical(JSONObject("""{"b":42.0,"a":null}""")), Training.canonical(JSONObject("""{"b":42}""")))
    }
    @Test(expected = IllegalArgumentException::class) fun terminalCannotBeEdited() {
        Training.perform(Training.finish(Training.start(routine(), "guest", 1000), false, 2000), "markThisSetAsDone")
    }
    @Test(expected = IllegalArgumentException::class) fun invalidParametersAreRejected() {
        Training.perform(Training.start(routine(), "guest", 1000), "updateSetParameters", JSONObject().put("time", 10))
    }
    @Test fun liveMetricsNeverEraseHistoryOrDecreaseCalories() {
        val full = JSONObject("""{"id":"a","ownerScope":"guest","segment":"s","revision":2,"energy":10,"state":"ended","samples":[{"time":1,"bpm":100}]}""")
        val live = full.copyJson().put("revision", 3).put("energy", 5).put("state", "running").apply { remove("samples") }
        val result = Metrics.merge(full, live)
        assertEquals(10.0, result.getDouble("energy"), 0.0)
        assertEquals("ended", result.getString("state"))
        assertEquals(1, result.objects("samples").size)
        assertEquals(Training.canonical(full), Training.canonical(Metrics.merge(full, live.put("revision", 1))))
    }
}
