package org.js.samplasion.gymtracker

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import kotlin.math.min

class WidgetPalette(context: Context) {
    val primary = context.getColor(R.color.widget_primary)
    val secondary = context.getColor(R.color.widget_secondary)
    val track = context.getColor(R.color.widget_track)
}

object WidgetGraphics {
    // Only the small chart region is rasterized. Bound dimensions and use full widget updates
    // to keep RemoteViews comfortably below the launcher's bitmap memory budget.
    private fun pixels(context: Context, dp: Float) = (dp * context.resources.displayMetrics.density).toInt().coerceIn(1, 1024)

    fun water(context: Context, colors: WidgetPalette, progress: Double, width: Float, height: Float): Bitmap {
        val size = pixels(context, min(width - 32, height - 78).coerceAtLeast(28f))
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val stroke = size * 0.09f
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = stroke; strokeCap = Paint.Cap.ROUND }
        val bounds = RectF(stroke, stroke, size - stroke, size - stroke)
        paint.color = colors.track
        canvas.drawOval(bounds, paint)
        paint.color = colors.primary
        canvas.drawArc(bounds, -90f, (progress * 360).toFloat(), false, paint)
        context.getDrawable(R.drawable.widget_drop)?.apply {
            setTint(colors.primary)
            setBounds((size * 0.32).toInt(), (size * 0.32).toInt(), (size * 0.68).toInt(), (size * 0.68).toInt())
            draw(canvas)
        }
        return bitmap
    }

    fun density(context: Context, colors: WidgetPalette, values: List<Int>, today: LocalDate, width: Float, height: Float): Bitmap {
        val columns = if (width < 220) 7 else 18
        val chartWidth = pixels(context, width - 32).toFloat()
        val chartHeight = pixels(context, height - 58).toFloat()
        val labelWidth = pixels(context, 15f).toFloat()
        val gap = pixels(context, 2f).toFloat()
        val cell = min((chartWidth - labelWidth - columns * gap) / columns, (chartHeight - 6 * gap) / 7).coerceAtLeast(1f)
        val usedWidth = columns * (cell + gap) + labelWidth
        val usedHeight = 7 * cell + 6 * gap
        val bitmap = Bitmap.createBitmap(usedWidth.toInt().coerceAtLeast(1), usedHeight.toInt().coerceAtLeast(1), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val max = values.maxOrNull()?.coerceAtLeast(1) ?: 1
        val formatter = DateTimeFormatter.ofPattern("EEEEE", context.resources.configuration.locales[0])
        for (row in 0 until 7) {
            val top = row * (cell + gap)
            for (column in 0 until columns) {
                val index = 7 * (columns - column - 1) + 6 - row
                val value = values.getOrElse(index) { 0 }
                val rect = RectF(column * (cell + gap), top, column * (cell + gap) + cell, top + cell)
                paint.color = colors.track
                canvas.drawRoundRect(rect, cell * 0.2f, cell * 0.2f, paint)
                paint.color = colors.primary
                paint.alpha = (255f * value / max).toInt().coerceIn(0, 255)
                canvas.drawRoundRect(rect, cell * 0.2f, cell * 0.2f, paint)
            }
            paint.color = colors.secondary
            paint.textSize = min(cell, pixels(context, 10f).toFloat())
            val baseline = top + cell / 2 - (paint.ascent() + paint.descent()) / 2
            canvas.drawText(today.minusDays((6 - row).toLong()).format(formatter), columns * (cell + gap) + gap, baseline, paint)
        }
        return bitmap
    }
}
