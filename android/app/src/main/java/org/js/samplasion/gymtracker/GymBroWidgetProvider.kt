package org.js.samplasion.gymtracker

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle

class RestWidget : GymBroWidgetProvider(WidgetKind.REST)
class TotalWorkoutsWidget : GymBroWidgetProvider(WidgetKind.TOTAL)
class WorkoutDensityWidget : GymBroWidgetProvider(WidgetKind.DENSITY)
class WaterWidget : GymBroWidgetProvider(WidgetKind.WATER)
class NutritionWidget : GymBroWidgetProvider(WidgetKind.NUTRITION)

open class GymBroWidgetProvider(private val kind: WidgetKind) : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { id ->
            manager.updateAppWidget(id, WidgetRenderer.views(context, kind, manager.getAppWidgetOptions(id)))
        }
    }

    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, id: Int, options: Bundle) {
        manager.updateAppWidget(id, WidgetRenderer.views(context, kind, options))
    }

    companion object {
        val components: Map<WidgetKind, Class<out GymBroWidgetProvider>> = linkedMapOf(
            WidgetKind.STREAK to StreakWidget::class.java,
            WidgetKind.REST to RestWidget::class.java,
            WidgetKind.TOTAL to TotalWorkoutsWidget::class.java,
            WidgetKind.DENSITY to WorkoutDensityWidget::class.java,
            WidgetKind.WATER to WaterWidget::class.java,
            WidgetKind.NUTRITION to NutritionWidget::class.java,
        )

        fun refresh(context: Context, kinds: Set<WidgetKind> = WidgetKind.entries.toSet()) {
            val manager = AppWidgetManager.getInstance(context)
            for ((kind, receiver) in components) {
                if (kind !in kinds) continue
                val ids = manager.getAppWidgetIds(ComponentName(context, receiver))
                ids.forEach { id ->
                    manager.updateAppWidget(id, WidgetRenderer.views(context, kind, manager.getAppWidgetOptions(id)))
                }
            }
        }
    }
}

class WidgetRefreshReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action in setOf(
                Intent.ACTION_DATE_CHANGED, Intent.ACTION_TIME_CHANGED, Intent.ACTION_TIMEZONE_CHANGED,
                Intent.ACTION_LOCALE_CHANGED, Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED,
                Intent.ACTION_CONFIGURATION_CHANGED,
            )) GymBroWidgetProvider.refresh(context)
    }
}
