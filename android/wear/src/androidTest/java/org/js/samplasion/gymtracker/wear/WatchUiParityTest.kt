package org.js.samplasion.gymtracker.wear

import android.content.Intent
import androidx.compose.ui.graphics.toPixelMap
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createEmptyComposeRule
import androidx.test.core.app.ActivityScenario
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import org.junit.*
import org.junit.Assert.*
import org.junit.runner.RunWith
import org.js.samplasion.gymtracker.wearable.*

/** Runs only against the isolated .preview app; never replaces a paired app's data. */
@RunWith(AndroidJUnit4::class)
class WatchUiParityTest {
    @get:Rule val compose = createEmptyComposeRule()
    private var scenario: ActivityScenario<MainActivity>? = null
    private val context get() = InstrumentationRegistry.getInstrumentation().targetContext
    @Before fun clearPreview() = runBlocking {
        assertTrue(context.packageName.endsWith(".preview"))
        withContext(Dispatchers.IO) { Store(context).db.clearAllTables() }
    }
    @After fun close() { scenario?.close() }
    private fun launch(scene: String) {
        scenario = ActivityScenario.launch(Intent(context, MainActivity::class.java)
            .putExtra("screenshots", true).putExtra("scene", scene).putExtra("locale", "en"))
        compose.waitUntil(10_000) { compose.onAllNodesWithText(if (scene == "workout") "Bench press" else if (scene == "custom-water") "250 ml" else if (scene == "calories") "Calories" else if (scene == "food") "1,141" else if (scene == "water") "1,250" else "Upper Body").fetchSemanticsNodes().isNotEmpty() }
    }
    @Test fun catalogueHasNoAddedShortcutsOrMusic() {
        launch("routines")
        compose.onNodeWithText("Train").assertExists()
        compose.onNodeWithText("Upper Body").assertExists()
        listOf("Sync", "Last workout", "Resume workout", "Music", "GYM BRO").forEach { compose.onNodeWithText(it).assertDoesNotExist() }
        compose.onNodeWithText("Upper Body").performClick()
        compose.onNodeWithText("Routine").assertExists()
        compose.onNodeWithText("1 exercise · 3 sets").assertExists()
        compose.onNodeWithText("Start").assertExists()
    }
    @Test fun startingRoutineInsideFolderOpensWorkoutAndClearsDetails() {
        launch("routines")
        compose.onNodeWithTag("wear-list-Train").performScrollToNode(hasText("Strength"))
        compose.onNodeWithText("Strength").performClick()
        compose.onNodeWithText("Lower Body").performClick()
        compose.waitUntil(10_000) { compose.onAllNodes(hasText("Start") and isEnabled()).fetchSemanticsNodes().isNotEmpty() }
        compose.onNodeWithText("Start").performClick()
        compose.waitUntil(10_000) { compose.onAllNodesWithContentDescription("Complete set").fetchSemanticsNodes().isNotEmpty() }
        compose.onNodeWithContentDescription("Complete set").assertIsDisplayed()
        compose.onNodeWithText("Start").assertDoesNotExist()
        compose.onNodeWithText("Routine").assertDoesNotExist()
        compose.onNodeWithText("Strength").assertDoesNotExist()
    }
    @Test fun workoutUsesRealIconsAndCompletesExactlyOneSet() {
        launch("workout")
        compose.onNodeWithText("132 bpm").assertExists()
        compose.onNodeWithText("164.0 kcal").assertExists()
        compose.onNodeWithContentDescription("Previous set").assertExists()
        compose.onNodeWithContentDescription("Complete set").performClick()
        compose.waitUntil(10_000) {
            runBlocking { Store(context).get("active", "guest")?.let { Training.ordered(it).count { p -> p.set.optBoolean("done") } == 2 } ?: false }
        }
        runBlocking {
            val active = Store(context).get("active", "guest")!!
            assertEquals(2, Training.ordered(active).count { it.set.optBoolean("done") })
            assertEquals(Training.ordered(active).last().set.getString("id"), active.getString("cursor"))
        }
        compose.onNodeWithText("Enable recording").assertDoesNotExist()
    }
    @Test fun customWaterUsesTheSameBoundsAndStepAsAppleWatch() {
        launch("custom-water")
        compose.onNodeWithContentDescription("Increase Amount").performClick()
        compose.onNodeWithText("300 ml").assertExists()
        compose.onNodeWithContentDescription("Decrease Amount").performClick()
        compose.onNodeWithText("250 ml").assertExists()
        compose.onNodeWithText("Add water").performClick()
        compose.waitUntil(10_000) { runBlocking { Store(context).list("water").size == 1 } }
        assertEquals(250.0, runBlocking { Store(context).list("water").single().getDouble("milliliters") }, 0.0)
    }
    @Test fun rapidWaterButtonsHaveEqualWidthsAndCenteredLabels() {
        launch("water")
        compose.onNodeWithTag("wear-list-Water").performScrollToNode(hasText("+100"))
        val widths = mutableListOf<Float>()
        for (amount in listOf(100, 250, 500)) {
            val button = compose.onNodeWithTag("quick-water-$amount").getBoundsInRoot()
            val label = compose.onNodeWithText("+$amount", useUnmergedTree = true).getBoundsInRoot()
            compose.onNodeWithText("+$amount").assertIsDisplayed()
            assertTrue("Water label must be centered", kotlin.math.abs((button.left.value + button.right.value - label.left.value - label.right.value) / 2) < 1f)
            widths.add(button.right.value - button.left.value)
        }
        assertTrue("Water buttons must be equal width", widths.max() - widths.min() < 1f)
    }
    @Test fun finalFoodActionScrollsIntoTheReadableArea() {
        launch("food")
        compose.onNodeWithTag("wear-list-Food").performScrollToNode(hasText("Diary"))
        compose.onNodeWithText("Diary").assertIsDisplayed()
        val diary = compose.onNodeWithText("Diary").getBoundsInRoot()
        val viewport = compose.onRoot().getBoundsInRoot()
        assertTrue("Last label must clear the lower round bezel", diary.bottom < viewport.bottom * 0.83f)
    }
    @Test fun diaryIconMatchesItsOrangeLabelInsteadOfThemeBlue() {
        launch("food")
        compose.onNodeWithTag("wear-list-Food").performScrollToNode(hasText("Diary"))
        val pixels = compose.onNodeWithTag("action-icon-Diary", useUnmergedTree = true).captureToImage().toPixelMap()
        var matching = 0
        for (y in 0 until pixels.height) for (x in 0 until pixels.width) {
            val c = pixels[x, y]
            if (kotlin.math.abs(c.red - Orange.red) < 0.04f &&
                kotlin.math.abs(c.green - Orange.green) < 0.04f &&
                kotlin.math.abs(c.blue - Orange.blue) < 0.04f) matching++
        }
        assertTrue("Diary icon must use the same orange as its label", matching > 10)
    }
    @Test fun calorieDetailsIncludeRemainingAndHandleAnUnsetGoal() {
        launch("calories")
        compose.onNodeWithText("Remaining").assertExists()
        compose.onNodeWithText("1,059").assertExists()
        runBlocking {
            val store = Store(context)
            store.put("food", store.get("food")!!.put("calorieGoal", 0))
        }
        compose.waitUntil(10_000) { compose.onAllNodesWithText("No calorie goal").fetchSemanticsNodes().isNotEmpty() }
        compose.onNodeWithText("Remaining").assertDoesNotExist()
    }
}
