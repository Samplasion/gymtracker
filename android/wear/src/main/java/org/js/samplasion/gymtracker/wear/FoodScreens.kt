package org.js.samplasion.gymtracker.wear

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.style.TextAlign
import androidx.wear.compose.foundation.lazy.TransformingLazyColumnScope
import androidx.wear.compose.material3.*
import org.json.JSONObject
import org.js.samplasion.gymtracker.wearable.*
import java.time.Instant
import java.time.ZoneId

@Composable internal fun FoodHome(state: WatchState, navigate: (String, JSONObject?) -> Unit) {
    WearList(stringResource(R.string.food)) {
        if (state.food == null) surface { modifier, transformation -> EmptyCard(stringResource(R.string.food), stringResource(R.string.food_sync_prompt), Icons.Rounded.Smartphone, modifier, transformation) }
        surface { modifier, transformation -> CaloriesCard(state, modifier, transformation) { navigate("calories", null) } }
        surface { modifier, transformation -> WatchCard(modifier, transformation, Purple, onClick = { navigate("nutrients", null) }) {
            CardHeading(stringResource(R.string.nutrients), Icons.Rounded.BarChart, Purple, true)
            Nutrients(state.currentFood?.optJSONObject("totalNutritionSplit"), state.food?.optJSONObject("totalNutritionSplit"), compact = true)
        } }
        surface { modifier, transformation -> WaterCard(state, modifier, transformation, onClick = { navigate("water", null) }) }
        pendingWater(state)
        surface { modifier, transformation -> TonalAction(stringResource(R.string.diary), Icons.Rounded.Restaurant, Orange, modifier, transformation) { navigate("diary", null) } }
    }
}

@Composable private fun CaloriesCard(state: WatchState, modifier: Modifier, transformation: SurfaceTransformation, onClick: (() -> Unit)? = null) {
    val intake = state.currentFood?.optDouble("calorieIntake", 0.0) ?: 0.0
    val goal = state.food?.optDouble("calorieGoal", 0.0) ?: 0.0
    WatchCard(modifier, transformation, Orange, onClick) {
        CardHeading(stringResource(R.string.calories), Icons.Rounded.LocalFireDepartment, Orange, onClick != null)
        Amount(intake, "kcal")
        if (goal > 0) {
            Progress(intake, goal, Orange)
            ValueRow(stringResource(if (intake > goal) R.string.over_goal else R.string.remaining), number(kotlin.math.abs(goal - intake)))
            ValueRow(stringResource(R.string.goal), "${number(goal)} kcal")
        } else Text(stringResource(R.string.no_calorie_goal), style = MaterialTheme.typography.bodySmall, color = Muted)
    }
}
@Composable internal fun CalorieDetails(state: WatchState) {
    WearList(stringResource(R.string.calories)) { surface { modifier, transformation -> CaloriesCard(state, modifier, transformation) } }
}

@Composable private fun Amount(value: Double, unit: String) {
    Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
        Text(number(value), style = MaterialTheme.typography.numeralSmall)
        Text(unit, Modifier.padding(bottom = 3.dp), style = MaterialTheme.typography.bodySmall, color = Muted)
    }
}

@Composable private fun WaterCard(state: WatchState, modifier: Modifier, transformation: SurfaceTransformation, compact: Boolean = false, onClick: (() -> Unit)? = null) {
    val goal = state.food?.optDouble("waterGoal", 0.0) ?: 0.0
    WatchCard(modifier, transformation, Cyan, onClick) {
        if (!compact) CardHeading(stringResource(R.string.water), Icons.Rounded.WaterDrop, Cyan, onClick != null)
        Amount(state.waterTotal, "ml")
        if (goal > 0) {
            Progress(state.waterTotal, goal, Cyan)
            ValueRow(stringResource(R.string.goal), "${number(goal)} ml")
        } else Text(stringResource(R.string.no_water_goal), style = MaterialTheme.typography.bodySmall, color = Muted)
        if (!compact) Text(stringResource(R.string.includes_food_water), style = MaterialTheme.typography.bodySmall, color = Muted)
    }
}

@Composable internal fun Nutrients(values: JSONObject?, goals: JSONObject?, compact: Boolean = false) {
    Column(verticalArrangement = Arrangement.spacedBy(if (compact) 8.dp else 16.dp)) {
        for ((key, title, tint) in listOf(Triple("protein", R.string.protein, Purple), Triple("carbs", R.string.carbs, Orange), Triple("fats", R.string.fats, Pink))) {
            val intake = values?.optDouble(key, 0.0)?.takeIf { it.isFinite() && it >= 0 } ?: 0.0
            val goal = goals?.optDouble(key + "Goal", 0.0)?.takeIf { it.isFinite() && it > 0 } ?: 0.0
            Column(verticalArrangement = Arrangement.spacedBy(if (compact) 3.dp else 6.dp)) {
                ValueRow(stringResource(title), "${number(intake)} g", tint)
                if (goal > 0) {
                    Progress(intake, goal, tint)
                    ValueRow(stringResource(R.string.goal), "${number(goal)} g")
                } else Text(stringResource(R.string.no_goal), style = MaterialTheme.typography.bodySmall, color = Muted)
            }
        }
    }
}
@Composable internal fun NutrientDetails(state: WatchState) {
    WearList(stringResource(R.string.nutrients)) { surface { modifier, transformation -> WatchCard(modifier, transformation, Purple) {
        CardHeading(stringResource(R.string.today), Icons.Rounded.BarChart, Purple)
        Nutrients(state.currentFood?.optJSONObject("totalNutritionSplit"), state.food?.optJSONObject("totalNutritionSplit"))
    } } }
}

@Composable internal fun FoodDiary(state: WatchState, navigate: (String, JSONObject?) -> Unit) {
    WearList(stringResource(R.string.diary)) {
        val categories = state.currentFood?.objects("categories").orEmpty()
        if (categories.isEmpty()) surface { modifier, transformation -> EmptyCard(stringResource(R.string.no_meals), stringResource(R.string.meals_sync_prompt), Icons.Rounded.Restaurant, modifier, transformation) }
        categories.forEach { category -> surface(category.optString("name")) { modifier, transformation -> WatchCard(modifier, transformation, Orange, onClick = { navigate("category", category) }) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                // The emoji is original diary content, as on Apple Watch.
                Text(category.optString("emoji"), style = MaterialTheme.typography.titleSmall)
                Text(category.optString("name"), Modifier.weight(1f), style = MaterialTheme.typography.titleSmall)
                Icon(Icons.Rounded.ChevronRight, null, Modifier.size(16.dp), tint = Muted)
            }
            val split = category.optJSONObject("nutritionSplit")
            for ((key, title, color) in listOf(Triple("protein", R.string.protein, Purple), Triple("carbs", R.string.carbs, Orange), Triple("fats", R.string.fats, Pink)))
                ValueRow(stringResource(title), "${number(split?.optDouble(key, 0.0) ?: 0.0)} g", color)
        } } }
    }
}
@Composable internal fun CategoryDetails(category: JSONObject?) {
    WearList(category?.optString("name").orEmpty()) { surface { modifier, transformation -> WatchCard(modifier, transformation, Orange) {
        Nutrients(category?.optJSONObject("nutritionSplit"), category?.optJSONObject("nutritionSplit"))
    } } }
}

@Composable internal fun WaterDetails(state: WatchState, model: WatchViewModel, navigate: (String, JSONObject?) -> Unit) {
    val enabled = state.food?.text("waterOwnerScope") == state.owner && state.owner != null
    WearList(stringResource(R.string.water)) {
        surface { modifier, transformation -> WaterCard(state, modifier, transformation, compact = true) }
        if (!enabled) surface { modifier, transformation -> EmptyCard(stringResource(R.string.water), stringResource(R.string.enable_water_prompt), Icons.Rounded.Smartphone, modifier, transformation) }
        item {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                listOf(100, 250, 500).forEach { amount ->
                    FilledTonalButton(onClick = { model.act { addWater(amount.toDouble()) } }, enabled = enabled,
                        modifier = Modifier.weight(1f).heightIn(min = 52.dp).testTag("quick-water-$amount"), contentPadding = PaddingValues(horizontal = 0.dp, vertical = 8.dp),
                        colors = ButtonDefaults.filledTonalButtonColors(containerColor = Cyan.copy(alpha = 0.14f), contentColor = Cyan)) {
                        Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text("+${number(amount.toDouble())}", Modifier.fillMaxWidth(), textAlign = TextAlign.Center,
                                style = MaterialTheme.typography.labelMedium.copy(fontFeatureSettings = "tnum"))
                            Text("ml", Modifier.fillMaxWidth(), textAlign = TextAlign.Center,
                                style = MaterialTheme.typography.labelSmall)
                        }
                    }
                }
            }
        }
        surface { modifier, transformation -> TonalAction(stringResource(R.string.custom_amount), Icons.Rounded.Add, Cyan, modifier, transformation, enabled) { navigate("custom-water", null) } }
        item { Text(stringResource(R.string.includes_food_water), Modifier.padding(horizontal = 10.dp), style = MaterialTheme.typography.bodySmall, color = Muted) }
        pendingWater(state)
    }
}

private fun TransformingLazyColumnScope.pendingWater(state: WatchState) {
    if (state.water.isNotEmpty()) surface { modifier, transformation -> WatchCard(modifier, transformation, Cyan) {
        CardHeading(stringResource(R.string.awaiting_sync), Icons.Rounded.Sync, Cyan)
        val amount = state.water.filter { Instant.ofEpochMilli(it.optLong("timeMilliseconds")).atZone(ZoneId.systemDefault()).toLocalDate().toString() == WatchRepository.today() }.sumOf { it.optDouble("milliliters", 0.0) }
        if (amount > 0) {
            Text(stringResource(R.string.today), style = MaterialTheme.typography.bodySmall, color = Muted)
            Text("+${number(amount)} ml", style = MaterialTheme.typography.titleMedium)
        }
        ValueRow(stringResource(R.string.entries), number(state.water.size.toDouble()))
        Text(stringResource(R.string.saved_on_watch), style = MaterialTheme.typography.bodySmall, color = Muted)
    } }
    if (state.list("water").any { it.text("ownerScope") != state.owner }) surface { modifier, transformation -> WatchCard(modifier, transformation) {
        Text(stringResource(R.string.other_account_entries), style = MaterialTheme.typography.bodySmall, color = Muted)
    } }
}
