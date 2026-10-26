package org.js.samplasion.gymtracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProviderInfo
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.util.SizeF
import android.widget.RemoteViews
import java.text.NumberFormat
import java.time.LocalDate
import java.time.ZoneId

object WidgetRenderer {
    fun views(context: Context, kind: WidgetKind, options: Bundle): RemoteViews {
        if (Build.VERSION.SDK_INT >= 31) {
            // The launcher chooses the closest fitting layout, including across rotation.
            val sizes = if (kind == WidgetKind.DENSITY || kind == WidgetKind.NUTRITION)
                listOf(SizeF(130f, 130f), SizeF(260f, 130f))
            else listOf(SizeF(130f, 130f))
            return RemoteViews(sizes.associateWith { size -> render(context, kind, size.width, size.height) })
        }
        val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 130).coerceAtLeast(110)
        val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 130).coerceAtLeast(110)
        return render(context, kind, width.toFloat(), height.toFloat())
    }

    /** Publish real rendered examples once per app installation/update; previews never enter the data cache. */
    fun publishPreviews(context: Context) {
        if (Build.VERSION.SDK_INT < 35) return
        val preferences = context.getSharedPreferences("gymbro_widgets", Context.MODE_PRIVATE)
        val version = context.packageManager.getPackageInfo(context.packageName, 0).lastUpdateTime
        if (preferences.getLong("preview_version", -1) == version) return
        val manager = AppWidgetManager.getInstance(context)
        try {
            var complete = true
            for ((kind, receiver) in GymBroWidgetProvider.components) {
                val width = if (kind == WidgetKind.DENSITY || kind == WidgetKind.NUTRITION) 260f else 130f
                complete = manager.setWidgetPreview(
                    ComponentName(context, receiver), AppWidgetProviderInfo.WIDGET_CATEGORY_HOME_SCREEN,
                    render(context, kind, width, 130f, example = true),
                ) && complete
            }
            if (complete) preferences.edit().putLong("preview_version", version).apply()
        } catch (error: RuntimeException) {
            // Some launchers throttle generated previews. Static previews remain available.
            Log.w("GymBroWidgets", "Could not publish widget previews", error)
        }
    }

    private fun render(context: Context, kind: WidgetKind, width: Float, height: Float, example: Boolean = false): RemoteViews {
        val zone = ZoneId.systemDefault()
        val today = LocalDate.now(zone)
        val workouts = if (example) WorkoutWidgetData.example(today, zone) else WidgetStore.workouts(context)
        val sample = WorkoutWidgetData.example(today, zone)
        val layout = when (kind) {
            WidgetKind.WATER -> R.layout.water_widget
            WidgetKind.NUTRITION -> if (width < 220) R.layout.nutrition_widget_compact else R.layout.nutrition_widget
            WidgetKind.DENSITY -> R.layout.density_widget
            WidgetKind.REST -> R.layout.rest_widget
            WidgetKind.TOTAL -> R.layout.total_widget
            else -> R.layout.streak_widget
        }
        val views = RemoteViews(context.packageName, layout)
        val launch = Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        views.setOnClickPendingIntent(R.id.widget_root, PendingIntent.getActivity(
            context, 0, launch, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        ))
        val palette = WidgetPalette(context)
        when (kind) {
            WidgetKind.STREAK, WidgetKind.REST, WidgetKind.TOTAL -> {
                val count = when (kind) {
                    WidgetKind.STREAK -> workouts.streak ?: sample.streak!!
                    WidgetKind.REST -> (if (workouts.lastWorkoutMillis == null) sample else workouts).restDays(today, zone)
                    else -> workouts.total ?: sample.total!!
                }
                val title = context.getString(when (kind) {
                    WidgetKind.STREAK -> R.string.widget_streak
                    WidgetKind.REST -> R.string.widget_rest
                    else -> R.string.widget_total
                })
                val value = context.resources.getQuantityString(when (kind) {
                    WidgetKind.STREAK -> R.plurals.streak
                    WidgetKind.REST -> R.plurals.widget_days
                    else -> R.plurals.widget_workout_count
                }, count, count)
                views.setTextViewText(R.id.widget_title, title)
                views.setTextViewText(R.id.widget_value, value)
                views.setContentDescription(R.id.widget_root, "$title, $value")
                views.setInt(R.id.widget_icon, "setColorFilter", if (count > 0) palette.primary else palette.secondary)
            }
            WidgetKind.DENSITY -> {
                val values = workouts.shiftedDensity(today, zone)
                views.setImageViewBitmap(R.id.widget_chart, WidgetGraphics.density(context, palette, values, today, width, height))
                views.setContentDescription(R.id.widget_root, context.getString(R.string.widget_density) + ", " +
                    context.resources.getQuantityString(R.plurals.widget_workout_count, values.sum(), values.sum()))
            }
            WidgetKind.WATER, WidgetKind.NUTRITION -> {
                val raw = if (example) NutritionWidgetData.example(today) else WidgetStore.food(context)
                val food = raw?.resolved(today, kind == WidgetKind.WATER) ?: NutritionWidgetData.example(today)
                if (kind == WidgetKind.WATER) {
                    val intake = food.water ?: 0.0
                    val value = quantity(context, intake, food.waterGoal, "ml")
                    views.setTextViewText(R.id.widget_value, value)
                    views.setImageViewBitmap(R.id.widget_chart, WidgetGraphics.water(context, palette, widgetProgress(intake, food.waterGoal), width, height))
                    views.setContentDescription(R.id.widget_root, context.getString(R.string.widget_water) + ", " + value)
                } else {
                    val nutrients = listOf(
                        NutrientViews(R.id.protein_label, R.id.protein_value, R.id.protein_progress, R.string.widget_protein, food.protein),
                        NutrientViews(R.id.carbs_label, R.id.carbs_value, R.id.carbs_progress, R.string.widget_carbs, food.carbs),
                        NutrientViews(R.id.fats_label, R.id.fats_value, R.id.fats_progress, R.string.widget_fats, food.fats),
                    )
                    val descriptions = nutrients.map { nutrient ->
                        val value = quantity(context, nutrient.data.amount, nutrient.data.goal, "g")
                        views.setTextViewText(nutrient.value, value)
                        // Stack the label above its quantity in the compact layout, avoiding clipped Italian labels.
                        views.setViewVisibility(nutrient.label, if (width < 220) android.view.View.GONE else android.view.View.VISIBLE)
                        views.setTextViewText(nutrient.value, if (width < 220) context.getString(nutrient.title) + "\n" + value else value)
                        views.setTextViewTextSize(nutrient.value, android.util.TypedValue.COMPLEX_UNIT_SP, if (width < 220) 10f else 12f)
                        views.setProgressBar(nutrient.progress, 1000, (nutrient.data.progress * 1000).toInt(), false)
                        context.getString(nutrient.title) + ", " + value
                    }
                    views.setContentDescription(R.id.widget_root, context.getString(R.string.widget_nutrients) + ", " + descriptions.joinToString(", "))
                }
            }
        }
        return views
    }

    private data class NutrientViews(val label: Int, val value: Int, val progress: Int, val title: Int, val data: WidgetNutrient)

    private fun quantity(context: Context, amount: Double, goal: Double?, unit: String): String {
        val format = NumberFormat.getNumberInstance(context.resources.configuration.locales[0]).apply { maximumFractionDigits = 0 }
        return if (goal != null && goal > 0) "${format.format(amount)}/${format.format(goal)} $unit"
        else "${format.format(amount)} $unit"
    }
}
