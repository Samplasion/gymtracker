package org.js.samplasion.gymtracker

import android.content.Context
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

/** Atomic snapshots avoid races with the old plugin's Int-valued preferences. */
object WidgetStore {
    private fun preferences(context: Context) =
        context.getSharedPreferences("gymbro_widgets", Context.MODE_PRIVATE)

    fun saveWorkouts(context: Context, parameters: Map<String, Long>, density: List<Long>) {
        val snapshot = JSONObject(parameters).put("workout_density_chart_data", JSONArray(density))
        preferences(context).edit().putString("workouts", snapshot.toString()).apply()
    }

    fun saveFood(context: Context, parameters: Map<String?, Any?>) {
        val snapshot = JSONObject(parameters.filterKeys { it != null })
        preferences(context).edit().putString("food", snapshot.toString()).apply()
    }

    fun workouts(context: Context): WorkoutWidgetData {
        val json = preferences(context).getString("workouts", null)
        val data = decode(json) ?: HomeWidgetPlugin.getData(context).all
        return WorkoutWidgetData.from(data, data["workout_density_chart_data"] as? List<*>)
    }

    fun food(context: Context): NutritionWidgetData? = decode(preferences(context).getString("food", null))
        ?.let(NutritionWidgetData::from)

    private fun decode(value: String?): Map<String, Any?>? = try {
        value?.let { objectToMap(JSONObject(it)) }
    } catch (_: Exception) { null }

    private fun objectToMap(json: JSONObject): Map<String, Any?> = json.keys().asSequence()
        .associateWith { key -> unwrap(json.get(key)) }

    private fun unwrap(value: Any?): Any? = when (value) {
        JSONObject.NULL -> null
        is JSONObject -> objectToMap(value)
        is JSONArray -> (0 until value.length()).map { unwrap(value.get(it)) }
        else -> value
    }
}
