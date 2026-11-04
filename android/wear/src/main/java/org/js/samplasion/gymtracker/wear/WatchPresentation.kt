package org.js.samplasion.gymtracker.wear

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.core.graphics.ColorUtils
import org.json.JSONObject
import org.js.samplasion.gymtracker.wearable.*
import java.text.NumberFormat
import java.util.Locale
import kotlin.math.abs
import kotlin.math.min

internal fun number(value: Double, decimals: Int = 0, locale: Locale = Locale.getDefault()): String = NumberFormat.getNumberInstance(locale).apply {
    minimumFractionDigits = decimals
    maximumFractionDigits = decimals
}.format(value.takeIf { it.isFinite() } ?: 0.0)
internal fun conciseNumber(value: Double): String = NumberFormat.getNumberInstance().apply { maximumFractionDigits = 2 }.format(value)
internal fun elapsed(milliseconds: Long): String = (milliseconds.coerceAtLeast(0) / 1000).let { "%02d:%02d".format(Locale.ROOT, it / 60, it % 60) }
internal fun summaryDuration(milliseconds: Long): String = (milliseconds.coerceAtLeast(0) / 1000).let { "%02d:%02d:%02d".format(Locale.ROOT, it / 3600, it / 60 % 60, it % 60) }
internal fun setTypeLabel(position: Training.Position, locale: Locale = Locale.getDefault()): String = when (position.set.optString("kind")) {
    "warmUp" -> if (locale.language == "it") "R" else "W"
    "drop" -> "D"
    "failure" -> if (locale.language == "it") "C" else "F"
    "failureStripping" -> "S"
    else -> (position.exercise.objects("sets").filter { it.optString("kind", "normal") == "normal" }.indexOfFirst { it.text("id") == position.set.text("id") } + 1).coerceAtLeast(1).toString()
}
internal fun setParameters(set: JSONObject, session: JSONObject): String = Training.fields(set.optString("parameters")).joinToString(" ") { key ->
    when (key) {
        "reps" -> "${set.optInt(key)} ×"
        "weight" -> "${conciseNumber(set.optDouble(key, 0.0) * if (set.optString("parameters") == "repsNegWeight") -1 else 1)} ${session.optString("weightUnit", "kg")}"
        "time" -> "${set.optLong(key) / 1_000_000} s"
        else -> "${conciseNumber(set.optDouble(key, 0.0))} ${session.optString("distanceUnit", "km")}"
    }
}
internal fun setTypeColor(kind: String, primary: Color): Color {
    if (kind == "drop") return Red
    if (kind !in listOf("failure", "failureStripping")) return primary
    val hsl = FloatArray(3)
    ColorUtils.colorToHSL(primary.toArgb(), hsl)
    if (hsl[1] < 0.001f) return primary
    val original = hsl[0]
    hsl[0] = (original + 72 * if (kind == "failure") 3 else 4) % 360
    val difference = min(abs(hsl[0] - original), 360 - abs(hsl[0] - original))
    val direction = if ((original - hsl[0] + 360) % 360 <= 180) 1 else -1
    hsl[0] = (hsl[0] + min(difference * 0.5f, 15f) * direction + 360) % 360
    return Color(ColorUtils.HSLToColor(hsl))
}
internal fun visibleNote(value: String) = noteText(value, Color.White).text.isNotBlank()
internal fun JSONObject.exercises() = Training.ordered(this).map { it.exercise }.distinctBy { it.text("id") }
