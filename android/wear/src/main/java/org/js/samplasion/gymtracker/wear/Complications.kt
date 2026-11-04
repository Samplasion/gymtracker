package org.js.samplasion.gymtracker.wear

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.drawable.Icon
import androidx.wear.watchface.complications.data.*
import androidx.wear.watchface.complications.datasource.*
import org.js.samplasion.gymtracker.wearable.*
import java.time.*

abstract class GymComplication : SuspendingComplicationDataSourceService() {
    abstract val kind: String
    override fun getPreviewData(type: ComplicationType): ComplicationData? = data(type, null)
    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        val state = WatchState(Store(this).dao.let { dao ->
            listOf("context", "statistics", "food", "water", "water-confirmed").flatMap { dao.list(it) }
        })
        return data(request.complicationType, state)
    }
    private fun data(type: ComplicationType, state: WatchState?): ComplicationData? {
        val stats = state?.statistics
        val food = state?.food
        val value = when (kind) {
            "streak" -> stats?.optInt("weekly_streak") ?: 0
            "total" -> stats?.optInt("total_workouts") ?: 0
            "rest" -> stats?.optLong("daily_rest_streak_since")?.takeIf { it > 0 }?.let {
                java.time.temporal.ChronoUnit.DAYS.between(Instant.ofEpochMilli(it).atZone(ZoneId.systemDefault()).toLocalDate(), LocalDate.now()).toInt().coerceAtLeast(0)
            } ?: 0
            "water" -> state?.waterTotal?.toInt() ?: 0
            "nutrition" -> state?.currentFood?.optDouble("calorieIntake", 0.0)?.toInt() ?: 0
            else -> 0
        }
        val title = when (kind) { "streak" -> getString(R.string.streak_title); "rest" -> getString(R.string.rest_title); "water" -> "ml"; "nutrition" -> "kcal"; "density" -> getString(R.string.complication_density); else -> getString(R.string.total_title) }
        val content = PlainComplicationText.Builder(if (kind == "density") title else "$title $value").build()
        val pending = PendingIntent.getActivity(this, kind.hashCode(), Intent(this, MainActivity::class.java).putExtra("screen", if (kind == "water") "water" else if (kind == "nutrition") "food" else "home"), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        return when (type) {
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(PlainComplicationText.Builder(value.toString()).build(), content)
                .setTitle(PlainComplicationText.Builder(title).build()).setTapAction(pending).build()
            ComplicationType.LONG_TEXT -> LongTextComplicationData.Builder(content, content).setTapAction(pending).build()
            ComplicationType.RANGED_VALUE -> {
                val goal = if (kind == "water") food?.optDouble("waterGoal", 0.0) ?: 0.0 else food?.optDouble("calorieGoal", 0.0) ?: 0.0
                if (!goal.isFinite() || goal <= 0) return NoDataComplicationData()
                RangedValueComplicationData.Builder(value.toFloat().coerceIn(0f, goal.toFloat().coerceAtLeast(1f)), 0f, goal.toFloat().coerceAtLeast(1f), content)
                    .setText(PlainComplicationText.Builder("$value $title").build()).setTapAction(pending).build()
            }
            ComplicationType.SMALL_IMAGE -> {
                val bitmap = Bitmap.createBitmap(180, 70, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bitmap)
                val paint = Paint().apply { color = android.graphics.Color.rgb(0, 220, 160) }
                val density = stats?.optJSONArray("density")
                repeat(126) { i -> paint.alpha = if ((density?.optInt(i) ?: 0) > 0) 255 else 45; canvas.drawRect((i / 7 * 10).toFloat(), (i % 7 * 10).toFloat(), (i / 7 * 10 + 8).toFloat(), (i % 7 * 10 + 8).toFloat(), paint) }
                SmallImageComplicationData.Builder(SmallImage.Builder(Icon.createWithBitmap(bitmap), SmallImageType.PHOTO).build(), content).setTapAction(pending).build()
            }
            else -> null
        }
    }
}
class StreakComplication : GymComplication() { override val kind = "streak" }
class RestComplication : GymComplication() { override val kind = "rest" }
class TotalComplication : GymComplication() { override val kind = "total" }
class DensityComplication : GymComplication() { override val kind = "density" }
class WaterComplication : GymComplication() { override val kind = "water" }
class NutritionComplication : GymComplication() { override val kind = "nutrition" }
object Complications {
    fun refresh(context: Context) {
        for (klass in listOf(StreakComplication::class.java, RestComplication::class.java, TotalComplication::class.java, DensityComplication::class.java, WaterComplication::class.java, NutritionComplication::class.java))
            ComplicationDataSourceUpdateRequester.create(context, ComponentName(context, klass)).requestUpdateAll()
    }
}
