package org.js.samplasion.gymtracker.wear

import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.rotary.onRotaryScrollEvent
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.*
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material3.*
import org.json.JSONObject
import org.js.samplasion.gymtracker.wearable.*
import kotlin.math.roundToInt

@Composable internal fun SetEditorScreen(set: JSONObject?, model: WatchViewModel, tint: Color, back: () -> Unit) {
    val values = remember(set?.text("id")) { mutableStateMapOf<String, Double>().apply {
        set?.let { value -> Training.fields(value.optString("parameters")).forEach { key -> put(key, value.optDouble(key, 0.0) / if (key == "time") 1_000_000 else 1) } }
    } }
    WearList(stringResource(R.string.edit_set)) {
        if (set == null) surface { modifier, transformation -> WatchCard(modifier, transformation) { Text(stringResource(R.string.no_set_data), style = MaterialTheme.typography.bodySmall) } }
        for (key in listOf("weight", "time", "reps", "distance").filter { it in values }) {
            surface(key) { modifier, transformation ->
                val title = stringResource(when (key) { "weight" -> R.string.weight; "time" -> R.string.time; "reps" -> R.string.reps; else -> R.string.distance })
                val step = when (key) { "weight" -> 0.1; "distance" -> 0.05; else -> 1.0 }
                val maximum = when (key) { "time" -> 600.0; "reps" -> 100.0; else -> 1000.0 }
                val value = values[key] ?: 0.0
                val formatted = if (key == "time") elapsed((value * 1000).toLong()) else number(value, if (key in listOf("weight", "distance")) 2 else 0)
                NumberAdjuster(title, value, formatted, 0.0, maximum, step, tint, modifier, transformation) { values[key] = it }
            }
        }
        if (set != null) surface { modifier, transformation -> PrimaryAction(stringResource(R.string.save), Icons.Rounded.Check, tint, modifier, transformation) {
            model.act { perform("updateSetParameters", JSONObject(values.toMap())) }
            back()
        } }
    }
}

@Composable internal fun CustomWater(state: WatchState, model: WatchViewModel, back: () -> Unit) {
    var amount by remember { mutableDoubleStateOf(250.0) }
    WearList(stringResource(R.string.amount)) {
        surface { modifier, transformation -> NumberAdjuster(stringResource(R.string.amount), amount, "${number(amount)} ml", 50.0, 2000.0, 50.0, Cyan, modifier, transformation, autoFocus = true) { amount = it } }
        surface { modifier, transformation -> PrimaryAction(stringResource(R.string.add_water), Icons.Rounded.WaterDrop, Cyan, modifier, transformation,
            enabled = state.food?.text("waterOwnerScope") == state.owner && state.owner != null) {
            model.act { addWater(amount) }; back()
        } }
    }
}

@Composable private fun NumberAdjuster(title: String, value: Double, formatted: String, minimum: Double, maximum: Double, step: Double,
    tint: Color, modifier: Modifier, transformation: SurfaceTransformation, autoFocus: Boolean = false, changed: (Double) -> Unit) {
    val focus = remember { FocusRequester() }
    var accumulated by remember { mutableFloatStateOf(0f) }
    LaunchedEffect(autoFocus) { if (autoFocus) focus.requestFocus() }
    fun adjust(direction: Int) { changed((((value / step).roundToInt() + direction) * step).coerceIn(minimum, maximum)) }
    val decrease = stringResource(R.string.decrease)
    val increase = stringResource(R.string.increase)
    WatchCard(modifier.onRotaryScrollEvent { event ->
        accumulated += event.verticalScrollPixels
        val steps = (accumulated / 12f).toInt()
        if (steps != 0) { adjust(steps); accumulated -= steps * 12f }; true
    }.focusRequester(focus).focusable().semantics {
        stateDescription = formatted
        customActions = listOf(CustomAccessibilityAction(decrease) { adjust(-1); true }, CustomAccessibilityAction(increase) { adjust(1); true })
    }, transformation, tint, onClick = { focus.requestFocus() }) {
        Text(title, style = MaterialTheme.typography.labelMedium, color = tint)
        Text(formatted, style = MaterialTheme.typography.titleLarge.copy(fontFeatureSettings = "tnum"))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Control(Icons.Rounded.Remove, "$decrease $title", tint, value > minimum) { adjust(-1) }
            Control(Icons.Rounded.Add, "$increase $title", tint, value < maximum) { adjust(1) }
        }
    }
}
