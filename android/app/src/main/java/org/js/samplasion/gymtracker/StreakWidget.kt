package org.js.samplasion.gymtracker

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Build
import android.widget.RemoteViews

import es.antonborri.home_widget.HomeWidgetPlugin

class StreakWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            // Get reference to SharedPreferences
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.streak_widget).apply {
                val streak = widgetData.getInt("weekly_streak", 0)
                val streakText = context.resources.getQuantityString(R.plurals.streak, streak, streak)

                setTextViewText(R.id.streakText, streakText)

//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//                    if (streak == 0) {
////                        this.setColorAttr(R.id.flame, "setFill", android.R.attr.colorForeground)
////                        this.setTextColor(R.id.streakText, android.R.attr.colorForeground)
//                    } else {
////                        this.setInt(R.id.flame, "setFill", android.R.attr.colorPrimary)
////                        this.setTextColor(R.id.streakText, android.R.attr.colorPrimary)
//                    }
//                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}