package org.js.samplasion.gymtracker.wear

import org.json.JSONObject
import org.json.JSONArray
import org.js.samplasion.gymtracker.wearable.*
import java.util.Locale

/** Explicit developer fixtures. Production never substitutes samples for missing data. */
internal object ScreenshotFixtures {
    suspend fun seed(repository: WatchRepository, scene: String, appStore: Boolean = false, restSeconds: Int = 90) {
        if (!BuildConfig.DEBUG) return
        val it = Locale.getDefault().language == "it"
        val owner = "guest"
        val routine = JSONObject("""{"id":"demo-routine","name":"Upper Body","weightUnit":"kg","distanceUnit":"km","exercises":[{"type":"exercise","id":"bench","name":"Bench press","wearableColor":4285442303,"restTime":90000000,"notes":"[{\"insert\":\"Technique\\n\",\"attributes\":{\"bold\":true}},{\"insert\":\"Keep your shoulders stable.\\n\"}]","sets":[{"id":"a","kind":"warmUp","parameters":"repsWeight","weight":20,"reps":12},{"id":"b","kind":"normal","parameters":"repsWeight","weight":60,"reps":8},{"id":"c","kind":"normal","parameters":"repsWeight","weight":60,"reps":8}]}]}""")
        if (it) routine.objects("exercises")[0].put("name", "Panca piana").put("notes", """[{"insert":"Tecnica\n","attributes":{"bold":true}},{"insert":"Mantieni le scapole stabili.\n"}]""")
        if (appStore) {
            val exercise = routine.objects("exercises")[0]
            exercise.put("wearableColor", 0xFF00BCD4L)
            exercise.objects("sets").drop(1).forEach { it.put("weight", 72.5) }
        }
        val folder = JSONObject().put("id", "strength").put("name", if (it) "Forza" else "Strength")
        val second = routine.copyJson().put("id", "lower").put("name", "Lower Body").put("folder", folder)
        val now = System.currentTimeMillis()
        repository.store.put("context", JSONObject().put("version", 1).put("generation", 1).put("ownerScope", owner)
            .put("catalog", JSONObject().put("version", 1).put("ownerScope", owner).put("generation", 1).put("revision", now)
                .put("routines", JSONArray().put(routine).put(second)).put("folders", JSONArray().put(folder))))
        repository.store.remove("recording-error")
        repository.error.value = null
        if (scene in listOf("workout", "notes", "edit-set", "actions", "summary")) {
            val active = Training.perform(Training.start(routine, owner, now - 24 * 60_000), "markThisSetAsDone", now = now - 15_000)
            if (appStore) active.put("screenshotRestMillis", restSeconds * 1000L)
            val metric = JSONObject().put("id", active.getString("id")).put("ownerScope", owner).put("segment", "screenshot")
                .put("energy", 164).put("heartRate", 132).put("heartRateTime", now).put("state", "running")
                .put("samples", JSONArray().put(JSONObject().put("time", now - 10_000).put("bpm", 132)))
            repository.store.put("metrics", metric, "$owner/${active.getString("id")}/screenshot")
            if (scene == "summary") {
                repository.store.put("summary", Training.finish(active, true, now))
                repository.store.remove("active", owner)
            } else repository.store.put("active", active, owner)
        } else repository.store.remove("active", owner)
        fun split(p: Int, c: Int, f: Int) = JSONObject().put("protein", p).put("proteinGoal", 140).put("carbs", c).put("carbsGoal", 260).put("fats", f).put("fatsGoal", 70)
        repository.store.put("food", JSONObject().put("ownerScope", owner).put("referenceDay", WatchRepository.today())
            .put("waterOwnerScope", owner).put("waterIntake", 1250).put("waterGoal", 2000).put("calorieIntake", 1141).put("calorieGoal", 2200)
            .put("totalNutritionSplit", split(82, 126, 34))
            .put("categories", JSONArray()
                .put(JSONObject().put("name", if (it) "Colazione" else "Breakfast").put("emoji", "🥣").put("nutritionSplit", split(32, 46, 12)))
                .put(JSONObject().put("name", if (it) "Pranzo" else "Lunch").put("emoji", "🥗").put("nutritionSplit", split(50, 80, 22)))))
    }
}
