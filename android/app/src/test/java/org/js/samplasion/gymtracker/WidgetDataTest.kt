package org.js.samplasion.gymtracker

import org.junit.Assert.*
import org.junit.Test
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

class WidgetDataTest {
    private val today = LocalDate.of(2026, 10, 25)
    private val rome = ZoneId.of("Europe/Rome")
    private fun workout(day: LocalDate = today, density: List<Int> = listOf(1, 2, 3)) =
        WorkoutWidgetData(0, day.atStartOfDay(rome).toInstant().toEpochMilli(), 0, density)

    @Test fun `legacy Int and native Long statistics decode without changing real zero`() {
        for (zero in listOf<Number>(0, 0L)) {
            val data = WorkoutWidgetData.from(mapOf("weekly_streak" to zero, "total_workouts" to zero), null)
            assertEquals(0, data.streak)
            assertEquals(0, data.total)
            assertNull(data.lastWorkoutMillis)
        }
        assertNull(WorkoutWidgetData.from(emptyMap<Any, Any>(), null).streak)
    }

    @Test fun `rest uses calendar days through both DST transitions`() {
        assertEquals(1, workout(today).restDays(today.plusDays(1), rome))
        val spring = LocalDate.of(2026, 3, 29)
        assertEquals(1, workout(spring).restDays(spring.plusDays(1), rome))
        assertEquals(0, workout(today.plusDays(1)).restDays(today, rome))
    }

    @Test fun `rest resolves the stored instant in the current time zone`() {
        val data = workout().copy(lastWorkoutMillis = Instant.parse("2026-10-25T00:30:00Z").toEpochMilli())
        assertEquals(0, data.restDays(today, rome))
        assertEquals(1, data.restDays(today, ZoneId.of("America/Los_Angeles")))
    }

    @Test fun `density shifts from latest workout without rotation or loss of recent ordering`() {
        val data = workout(today.minusDays(2))
        assertEquals(listOf(0, 0, 1, 2, 3, 0), data.shiftedDensity(today, rome).take(6))
        assertEquals(126, data.shiftedDensity(today, rome).size)
        assertTrue(workout(today.minusDays(126)).shiftedDensity(today, rome).all { it == 0 })
        assertEquals(List(126) { 0 }, workout(density = emptyList()).shiftedDensity(today, rome))
    }

    @Test fun `missing density uses bounded populated examples without hiding a real empty history`() {
        val missing = WorkoutWidgetData(null, null, null, null).shiftedDensity(today, rome)
        assertEquals(126, missing.size)
        assertTrue(missing.sum() > 0)
        assertTrue(workout(density = List(126) { 0 }).shiftedDensity(today, rome).all { it == 0 })
    }

    @Test fun `density decoder bounds samples and clamps invalid counts`() {
        val data = WorkoutWidgetData.from(emptyMap<Any, Any>(), listOf(-1, "bad", 3L) + List(200) { 1 })
        assertEquals(126, data.density!!.size)
        assertEquals(listOf(0, 0, 3), data.density.take(3))
    }

    @Test fun `valid zero consumption and absent water goal stay real`() {
        val data = NutritionWidgetData.example(today).copy(water = 0.0, waterGoal = null)
        assertEquals(data, data.resolved(today, true))
        assertEquals(0.0, widgetProgress(0.0, null), 0.0)
        val zero = data.copy(protein = WidgetNutrient(0.0, 0.0))
        assertEquals(0.0, zero.resolved(today, false).protein.amount, 0.0)
    }

    @Test fun `diary reference day overrides generated timestamp and keeps goals on rollover`() {
        val old = NutritionWidgetData.example(today)
        val next = old.resolved(today.plusDays(1), true)
        assertEquals(0.0, next.water!!, 0.0)
        assertEquals(old.waterGoal, next.waterGoal)
        assertEquals(0.0, next.protein.amount, 0.0)
        assertEquals(old.protein.goal, next.protein.goal, 0.0)
        assertEquals(0.0, old.resolved(today.minusDays(1), false).carbs.amount, 0.0)
        assertEquals(1250.0, old.water!!, 0.0) // resolution never mutates the cached snapshot
    }

    @Test fun `missing reference day or invalid current intake uses examples`() {
        val example = NutritionWidgetData.example(today)
        assertEquals(example, example.copy(referenceDay = null, water = 0.0).resolved(today, true))
        for (bad in listOf(Double.NaN, Double.NEGATIVE_INFINITY, -1.0)) {
            assertEquals(example, example.copy(water = bad).resolved(today, true))
            assertEquals(example, example.copy(protein = WidgetNutrient(bad, 120.0)).resolved(today, false))
        }
    }

    @Test fun `stale invalid goals are sanitized rather than producing demo consumption`() {
        val data = NutritionWidgetData.example(today).copy(
            waterGoal = -1.0, protein = WidgetNutrient(10.0, Double.NaN),
        ).resolved(today.plusDays(1), false)
        assertNull(data.waterGoal)
        assertEquals(0.0, data.protein.goal, 0.0)
        assertEquals(0.0, data.carbs.amount, 0.0)
    }

    @Test fun `nutrition accepts Pigeon numeric types and isolates water from missing macros`() {
        val data = NutritionWidgetData.from(mapOf(
            "referenceDay" to today.toString(), "waterIntake" to 0L, "waterGoal" to 2000.0,
        ))
        assertEquals(0.0, data.resolved(today, true).water!!, 0.0)
        assertEquals(NutritionWidgetData.example(today), data.resolved(today, false))
    }

    @Test fun `progress is bounded and safe with missing zero and invalid goals`() {
        assertEquals(1.0, widgetProgress(2500.0, 2000.0), 0.0)
        for (goal in listOf(null, 0.0, -1.0, Double.NaN, Double.POSITIVE_INFINITY))
            assertEquals(0.0, widgetProgress(100.0, goal), 0.0)
        assertEquals(0.0, widgetProgress(-1.0, 2000.0), 0.0)
    }
}
