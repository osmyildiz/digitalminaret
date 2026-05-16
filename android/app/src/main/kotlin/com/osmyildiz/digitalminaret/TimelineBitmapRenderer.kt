package com.osmyildiz.digitalminaret

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BlurMaskFilter
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.TypedValue

// Android counterpart of the iOS DayTimelineView. RemoteViews can't host
// a Canvas, so we rasterise the timeline here and embed the Bitmap via
// setImageViewBitmap. Mirrors the iOS visual exactly:
//   - thin faint full track + bright elapsed track up to "now"
//   - one node per prayer, spaced by REAL time gaps
//   - filled white node = passed, hollow node = upcoming
//   - glowing gold marker at the current position
//   - no labels (kept minimal per design feedback)
//   - day/night schedule switch:
//       now >= Isha     -> Isha, Fajr(+1d), Sunrise(+1d)
//       now <  Sunrise   -> Isha(-1d), Fajr, Sunrise
//       otherwise        -> full day Fajr..Isha
object TimelineBitmapRenderer {

    private val accent = Color.parseColor("#FFE6A8")
    private const val DAY_MS = 86_400_000L

    /**
     * @param prayerEpochs ordered (any order ok, we sort) epoch-ms of the
     *   day's prayers: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha.
     * @param nowMs current time in epoch-ms.
     */
    fun render(
        context: Context,
        widthDp: Int = 320,
        heightDp: Int = 26,
        prayerEpochs: List<Long>,
        nowMs: Long,
    ): Bitmap {
        val dm = context.resources.displayMetrics
        fun dp(v: Float) = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, v, dm
        )

        val w = (widthDp * dm.density).toInt().coerceAtLeast(1)
        val h = (heightDp * dm.density).toInt().coerceAtLeast(1)
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)

        val stops = resolveStops(prayerEpochs.sorted(), nowMs)
        if (stops.size < 2) return bmp

        val pad = dp(14f)
        val usable = (w - pad * 2).coerceAtLeast(1f)
        val cy = h / 2f
        val t0 = stops.first()
        val tN = stops.last()
        val span = (tN - t0).coerceAtLeast(1L).toFloat()

        fun xFor(t: Long): Float =
            pad + usable * ((t - t0).toFloat() / span).coerceIn(0f, 1f)

        val nowX = xFor(nowMs.coerceIn(t0, tN))

        val linePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            strokeCap = Paint.Cap.ROUND
        }

        // Faint full track.
        linePaint.color = Color.argb(56, 255, 255, 255)
        linePaint.strokeWidth = dp(3f)
        canvas.drawLine(pad, cy, pad + usable, cy, linePaint)

        // Bright elapsed track.
        linePaint.color = Color.WHITE
        linePaint.strokeWidth = dp(4f)
        canvas.drawLine(pad, cy, nowX, cy, linePaint)

        // Nodes.
        val nodeFill = Paint(Paint.ANTI_ALIAS_FLAG)
        val nodeStroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = dp(1.5f)
        }
        val rNode = dp(5f)
        for (t in stops) {
            val x = xFor(t)
            val passed = t <= nowMs
            if (passed) {
                nodeFill.color = Color.WHITE
                canvas.drawCircle(x, cy, rNode, nodeFill)
            } else {
                // Hollow: punch background + white ring.
                nodeFill.color = Color.argb(255, 12, 18, 38) // bannerBottom
                canvas.drawCircle(x, cy, rNode, nodeFill)
                nodeStroke.color = Color.argb(128, 255, 255, 255)
                canvas.drawCircle(x, cy, rNode, nodeStroke)
            }
        }

        // Glowing "now" marker.
        val glow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = accent
            maskFilter = BlurMaskFilter(dp(6f), BlurMaskFilter.Blur.NORMAL)
        }
        canvas.drawCircle(nowX, cy, dp(8f), glow)
        val markerFill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = accent }
        canvas.drawCircle(nowX, cy, dp(5.5f), markerFill)
        val markerRing = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = dp(1.4f)
            color = Color.WHITE
        }
        canvas.drawCircle(nowX, cy, dp(5.5f), markerRing)

        return bmp
    }

    /** Day/night schedule resolution — mirrors iOS resolvedStops(). */
    private fun resolveStops(sorted: List<Long>, nowMs: Long): List<Long> {
        if (sorted.size < 6) return sorted
        val fajr = sorted[0]
        val sunrise = sorted[1]
        val isha = sorted[5]
        return when {
            nowMs >= isha -> listOf(isha, fajr + DAY_MS, sunrise + DAY_MS)
            nowMs < sunrise -> listOf(isha - DAY_MS, fajr, sunrise)
            else -> sorted
        }
    }
}
