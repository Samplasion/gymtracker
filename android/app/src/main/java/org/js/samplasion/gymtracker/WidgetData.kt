package org.js.samplasion.gymtracker

import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.temporal.ChronoUnit

enum class WidgetKind { STREAK, REST, TOTAL, DENSITY, WATER, NUTRITION }

/** Pure date/value resolution shared by all Android widget instances. */
data class WorkoutWidgetData(
    val streak: Int?,
    val lastWorkoutMillis: Long?,
    val total: Int?,
    val density: List<Int>?,
) {
    fun restDays(today: LocalDate, zone: ZoneId): Int = lastWorkoutMillis?.let {
        ChronoUnit.DAYS.between(Instant.ofEpochMilli(it).atZone(zone).toLocalDate(), today)
            .coerceIn(0, Int.MAX_VALUE.toLong()).toInt()
    } ?: 0

    fun shiftedDensity(today: LocalDate, zone: ZoneId): List<Int> {
        if (density == null || lastWorkoutMillis == null) return example(today, zone).shiftedDensity(today, zone)
        val days = restDays(today, zone)
        return List(126) { index ->
            if (index < days) 0 else density.getOrElse(index - days) { 0 }.coerceAtLeast(0)
        }
    }

    companion object {
        fun from(parameters: Map<*, *>, density: List<*>?): WorkoutWidgetData = WorkoutWidgetData(
            parameters.number("weekly_streak")?.toInt()?.coerceAtLeast(0),
            parameters.number("daily_rest_streak_since")?.toLong(),
            parameters.number("total_workouts")?.toInt()?.coerceAtLeast(0),
            density?.take(126)?.map { (it as? Number)?.toInt()?.coerceAtLeast(0) ?: 0 },
        )

        fun example(today: LocalDate, zone: ZoneId) = WorkoutWidgetData(
            3, today.minusDays(2).atStartOfDay(zone).toInstant().toEpochMilli(), 54,
            List(126) { index -> when ((index * 37 + index / 7 * 13) % 100) {
                in 0..54 -> 0
                in 55..87 -> 1
                in 88..97 -> 2
                else -> 3
            } },
        )
    }
}

data class WidgetNutrient(val amount: Double, val goal: Double) {
    val valid: Boolean get() = amount.validAmount() && goal.validAmount()
    val progress: Double get() = widgetProgress(amount, goal)
}

data class NutritionWidgetData(
    val referenceDay: String?,
    val water: Double?,
    val waterGoal: Double?,
    val protein: WidgetNutrient,
    val carbs: WidgetNutrient,
    val fats: WidgetNutrient,
) {
    fun resolved(today: LocalDate, forWater: Boolean): NutritionWidgetData {
        // Use the diary day, never the delivery timestamp, to resolve today's totals.
        if (referenceDay != null && referenceDay != today.toString()) return copy(
            referenceDay = today.toString(), water = 0.0,
            waterGoal = waterGoal?.takeIf { it.validAmount() },
            protein = WidgetNutrient(0.0, protein.goal.takeIf { it.validAmount() } ?: 0.0),
            carbs = WidgetNutrient(0.0, carbs.goal.takeIf { it.validAmount() } ?: 0.0),
            fats = WidgetNutrient(0.0, fats.goal.takeIf { it.validAmount() } ?: 0.0),
        )
        val valid = referenceDay == today.toString() &&
            (waterGoal == null || waterGoal.validAmount()) &&
            (if (forWater) water?.validAmount() == true else protein.valid && carbs.valid && fats.valid)
        return if (valid) this else example(today)
    }

    companion object {
        fun from(parameters: Map<*, *>): NutritionWidgetData {
            val split = parameters["totalNutritionSplit"] as? Map<*, *> ?: emptyMap<Any, Any>()
            fun nutrient(key: String) = WidgetNutrient(
                split.number(key)?.toDouble() ?: Double.NaN,
                split.number("${key}Goal")?.toDouble() ?: Double.NaN,
            )
            return NutritionWidgetData(
                parameters["referenceDay"] as? String,
                parameters.number("waterIntake")?.toDouble(),
                parameters.number("waterGoal")?.toDouble(),
                nutrient("protein"), nutrient("carbs"), nutrient("fats"),
            )
        }

        fun example(today: LocalDate) = NutritionWidgetData(
            today.toString(), 1250.0, 2000.0,
            WidgetNutrient(75.0, 120.0), WidgetNutrient(150.0, 260.0), WidgetNutrient(35.0, 70.0),
        )
    }
}

private fun Map<*, *>.number(key: String): Number? = this[key] as? Number
private fun Double.validAmount() = isFinite() && this >= 0
fun widgetProgress(value: Double, goal: Double?): Double =
    if (!value.validAmount() || goal == null || !goal.validAmount() || goal == 0.0) 0.0
    else (value / goal).coerceIn(0.0, 1.0)
