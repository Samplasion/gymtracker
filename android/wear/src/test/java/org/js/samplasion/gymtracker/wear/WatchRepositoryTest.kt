package org.js.samplasion.gymtracker.wear

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import kotlinx.coroutines.runBlocking
import org.json.JSONObject
import org.junit.*
import org.junit.Assert.*
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.js.samplasion.gymtracker.wearable.*

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [30])
class WatchRepositoryTest {
    private lateinit var repo: WatchRepository
    @Before fun setup() = runBlocking {
        repo = WatchRepository.get(ApplicationProvider.getApplicationContext<Context>())
        kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) { repo.store.db.clearAllTables() }
        repo.store.put("context", JSONObject().put("version", 1).put("ownerScope", "guest").put("generation", 1))
    }
    private fun session() = JSONObject("""{"version":1,"ownerScope":"guest","id":"workout","time":1000,"status":"active","modified":1000,"sequence":1,"epoch":0,"cursor":"set","exercises":[{"id":"exercise","sets":[{"id":"set","parameters":"repsWeight","reps":8,"weight":20}]}]}""")
    private fun envelope(type: String, value: JSONObject) = JSONObject().put("version", 1).put("origin", "phone").put("type", type).put("payload", value)
    @Test fun dirtyReplicaRejectsUnsolicitedSnapshotsAndStaleAck() = runBlocking {
        val active = session().put("sequence", 2).put("modified", 2000)
        repo.store.put("active", active, "guest"); repo.store.put("dirty", active, "guest")
        val old = session()
        repo.receive(envelope("state", JSONObject().put("version", 1).put("ownerScope", "guest").put("generation", 1).put("session", old)))
        assertEquals(2, repo.store.get("active", "guest")!!.getInt("sequence"))
        repo.receive(envelope("ack", JSONObject().put("accepted", true).put("ownerScope", "guest").put("document", old).put("source", old)))
        assertNotNull(repo.store.get("dirty", "guest"))
        val accepted = active.copyJson().put("epoch", 1)
        repo.receive(envelope("ack", JSONObject().put("accepted", true).put("ownerScope", "guest").put("document", accepted).put("source", active)))
        assertNull(repo.store.get("dirty", "guest"))
        assertEquals(1, repo.store.get("active", "guest")!!.getInt("epoch"))
    }
    @Test fun terminalStateCannotBeResurrectedByReplay() = runBlocking {
        val active = session()
        repo.store.put("active", active, "guest")
        repo.receive(envelope("terminal", Training.finish(active, false, 5000)))
        assertNull(repo.store.get("active", "guest"))
        assertNotNull(repo.store.get("finished", "guest/workout"))
        repo.receive(envelope("state", JSONObject().put("version", 1).put("ownerScope", "guest").put("generation", 1).put("session", active)))
        assertNull(repo.store.get("active", "guest"))
    }
    @Test fun oldAccountGenerationCannotSwitchAccountBack() = runBlocking {
        repo.receive(envelope("state", JSONObject().put("version", 1).put("ownerScope", "user:second").put("generation", 2)))
        repo.receive(envelope("state", JSONObject().put("version", 1).put("ownerScope", "guest").put("generation", 1).put("session", session())))
        assertEquals("user:second", repo.store.get("context")!!.getString("ownerScope"))
        repo.receive(envelope("food", JSONObject().put("ownerScope", "guest").put("calorieIntake", 1000)))
        assertNull(repo.store.get("food"))
    }
    @Test fun confirmedWaterOverlayDisappearsWhenSnapshotIncludesItsId() {
        val context = Document("context", "current", """{"ownerScope":"guest"}""")
        val entry = Document("water-confirmed", "guest/a", JSONObject().put("id", "a").put("ownerScope", "guest").put("milliliters", 250).put("timeMilliseconds", System.currentTimeMillis()).toString())
        val food = JSONObject().put("ownerScope", "guest").put("referenceDay", WatchRepository.today()).put("waterIntake", 500)
        assertEquals(750.0, WatchState(listOf(context, entry, Document("food", "current", food.toString()))).waterTotal, 0.0)
        food.put("waterEntryIds", org.json.JSONArray().put("a")).put("waterIntake", 750)
        assertEquals(750.0, WatchState(listOf(context, entry, Document("food", "current", food.toString()))).waterTotal, 0.0)
    }
    @Test fun deletingImportedWaterCannotBeUndoneByAnOldAcknowledgement() = runBlocking {
        val entry = JSONObject().put("id", "water").put("ownerScope", "guest").put("milliliters", 250).put("timeMilliseconds", System.currentTimeMillis())
        repo.store.put("water", entry, "guest/water")
        repo.receive(envelope("waterAck", entry))
        val food = JSONObject().put("ownerScope", "guest").put("referenceDay", WatchRepository.today()).put("waterIntake", 250).put("waterEntryIds", org.json.JSONArray().put("water"))
        repo.receive(envelope("food", food))
        assertNull(repo.store.get("water-confirmed", "guest/water"))
        repo.receive(envelope("food", food.put("waterIntake", 0).put("waterEntryIds", org.json.JSONArray())))
        repo.receive(envelope("waterAck", entry))
        assertNull(repo.store.get("water-confirmed", "guest/water"))
        assertNotNull(repo.store.get("water-seen", "guest/water"))
    }
    @Test fun quillBlockAttributesRenderListsAndRetainText() {
        val text = noteText("""[{"insert":"One"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"Two","attributes":{"bold":true}},{"insert":"\n","attributes":{"list":"ordered"}}]""", androidx.compose.ui.graphics.Color.Green)
        assertEquals("1. One\n2. Two", text.text)
    }
}
