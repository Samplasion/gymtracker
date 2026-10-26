package org.js.samplasion.gymtracker

import android.app.Application
import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import es.antonborri.home_widget.HomeWidgetPlugin
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.io.File
import java.time.LocalDate
import java.time.ZoneId

@RunWith(RobolectricTestRunner::class)
// Amazon's bundled IAP receiver lacks JVM stack maps; let Robolectric rebuild them.
@Config(sdk = [26, 36], application = Application::class, qualifiers = "it-rIT-mdpi",
    instrumentedPackages = ["com.amazon.device.iap"])
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class WidgetRenderingTest {
    private val context: Context get() = RuntimeEnvironment.getApplication()

    @Before fun clearCache() {
        context.getSharedPreferences("gymbro_widgets", Context.MODE_PRIVATE).edit().clear().commit()
        HomeWidgetPlugin.getData(context).edit().clear().commit()
    }

    @Test fun `old streak data migrates and complete snapshots survive subsequent reads`() {
        HomeWidgetPlugin.getData(context).edit().putInt("weekly_streak", 0).commit()
        assertEquals(0, WidgetStore.workouts(context).streak)
        val today = LocalDate.now()
        val timestamp = today.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()
        WidgetStore.saveWorkouts(context, mapOf(
            "weekly_streak" to 4L, "daily_rest_streak_since" to timestamp, "total_workouts" to 17L,
        ), listOf(1L, 2L))
        HomeWidgetPlugin.getData(context).edit().putInt("weekly_streak", 99).commit()
        assertEquals(4, WidgetStore.workouts(context).streak)
        assertEquals(timestamp, WidgetStore.workouts(context).lastWorkoutMillis)
        assertEquals(listOf(1, 2), WidgetStore.workouts(context).density)
    }

    @Test fun `food snapshot restores nested Pigeon data and real zero from persistent storage`() {
        WidgetStore.saveFood(context, mapOf(
            "referenceDay" to LocalDate.now().toString(), "waterIntake" to 0.0, "waterGoal" to 2000L,
            "totalNutritionSplit" to mapOf(
                "protein" to 10L, "proteinGoal" to 120.0, "carbs" to 20.0, "carbsGoal" to 250L,
                "fats" to 0L, "fatsGoal" to 70.0,
            ),
        ))
        val food = WidgetStore.food(context)!!.resolved(LocalDate.now(), true)
        assertEquals(0.0, food.water!!, 0.0)
        assertEquals(2000.0, food.waterGoal!!, 0.0)
        assertEquals(10.0, food.protein.amount, 0.0)
        context.getSharedPreferences("gymbro_widgets", Context.MODE_PRIVATE).edit().putString("food", "corrupt").commit()
        assertNull(WidgetStore.food(context))
    }

    @Test fun `all RemoteViews inflate and draw in light and dark Italian layouts`() {
        for ((locale, night) in listOf("en-rUS", "it-rIT").flatMap { locale -> listOf("notnight", "night").map { locale to it } }) {
            RuntimeEnvironment.setQualifiers("$locale-$night-xhdpi")
            for ((kind, size) in WidgetKind.entries.flatMap { kind ->
                (if (kind == WidgetKind.DENSITY || kind == WidgetKind.NUTRITION) listOf(130, 160, 300) else listOf(130, 160)).map { kind to it }
            }) {
                val view = render(kind, size, if (size == 300) 160 else size)
                assertNotNull(view.contentDescription)
                val root = view as android.view.ViewGroup
                for (index in 0 until root.childCount) {
                    val child = root.getChildAt(index)
                    if (child.visibility != View.VISIBLE) continue
                    assertTrue("$kind child $index overlaps top padding at $size", child.top >= root.paddingTop)
                    assertTrue("$kind child $index overlaps bottom padding at $size", child.bottom <= root.height - root.paddingBottom)
                }
                if (kind in listOf(WidgetKind.STREAK, WidgetKind.REST, WidgetKind.TOTAL)) {
                    val icon = view.findViewById<View>(R.id.widget_icon)
                    assertEquals("$kind icon must stay centered", view.width / 2, icon.left + icon.width / 2)
                    val value = view.findViewById<TextView>(R.id.widget_value)
                    assertTrue(value.bottom <= view.height - view.paddingBottom)
                    assertTrue(value.top >= icon.bottom)
                    for (line in 0 until value.layout.lineCount) assertEquals(0, value.layout.getEllipsisCount(line))
                }
                val bitmap = Bitmap.createBitmap(view.width, view.height, Bitmap.Config.ARGB_8888)
                view.draw(Canvas(bitmap))
                val folder = File(System.getProperty("java.io.tmpdir"), "gymbro-widget-previews").apply { mkdirs() }
                File(folder, "${android.os.Build.VERSION.SDK_INT}-${kind.name.lowercase()}-$size-$locale-$night.png").outputStream().use {
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, it)
                }
                bitmap.recycle()
            }
        }
    }

    @Test fun `wide charts and nutrient rows render and all widget providers are registered`() {
        render(WidgetKind.DENSITY, 300, 160)
        val nutrients = render(WidgetKind.NUTRITION, 300, 160)
        assertTrue(nutrients.findViewById<TextView>(R.id.protein_value).text.contains("g"))
        for ((_, receiver) in GymBroWidgetProvider.components) {
            val info = context.packageManager.getReceiverInfo(android.content.ComponentName(context, receiver), 0)
            assertNotNull(info)
        }
    }

    private fun render(kind: WidgetKind, width: Int, height: Int): View {
        val options = Bundle().apply {
            putInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, width)
            putInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, height)
        }
        val view = WidgetRenderer.views(context, kind, options).apply(context, FrameLayout(context))
        val density = context.resources.displayMetrics.density
        val pixelWidth = (width * density).toInt()
        val pixelHeight = (height * density).toInt()
        view.measure(View.MeasureSpec.makeMeasureSpec(pixelWidth, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(pixelHeight, View.MeasureSpec.EXACTLY))
        view.layout(0, 0, pixelWidth, pixelHeight)
        return view
    }
}
