package com.osmyildiz.digitalminaret

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class PrayerWidgetProvider : HomeWidgetProvider() {

    private val prayerKeys = listOf("fajr", "dhuhr", "asr", "maghrib", "isha")

    private val nameViewIds = mapOf(
        "fajr" to R.id.widget_fajr_name,
        "dhuhr" to R.id.widget_dhuhr_name,
        "asr" to R.id.widget_asr_name,
        "maghrib" to R.id.widget_maghrib_name,
        "isha" to R.id.widget_isha_name,
    )

    private val timeViewIds = mapOf(
        "fajr" to R.id.widget_fajr_time,
        "dhuhr" to R.id.widget_dhuhr_time,
        "asr" to R.id.widget_asr_time,
        "maghrib" to R.id.widget_maghrib_time,
        "isha" to R.id.widget_isha_time,
    )

    private val rowViewIds = mapOf(
        "fajr" to R.id.widget_prayer_fajr,
        "dhuhr" to R.id.widget_prayer_dhuhr,
        "asr" to R.id.widget_prayer_asr,
        "maghrib" to R.id.widget_prayer_maghrib,
        "isha" to R.id.widget_prayer_isha,
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget)

            val location = widgetData.getString("location_name", "Digital Minaret") ?: "Digital Minaret"
            val activePrayer = widgetData.getString("active_prayer", "Isha") ?: "Isha"
            val remaining = widgetData.getString("time_remaining", "--") ?: "--"

            val activePrayerTime = formatEpochOrFallback(
                widgetData.getLong("active_prayer_epoch_ms", 0L),
                null,
            )

            views.setTextViewText(R.id.widget_location, location)
            views.setTextViewText(R.id.widget_active_prayer, activePrayer)
            views.setTextViewText(R.id.widget_active_time, activePrayerTime)
            views.setTextViewText(R.id.widget_remaining, remaining)

            // 5 prayer times
            val goldActive = Color.parseColor("#FFE6A8")
            val whiteActive = Color.parseColor("#FFFFFF")
            val muted = Color.parseColor("#B3D2DAF3")

            for (key in prayerKeys) {
                val localizedName = widgetData.getString("prayer_${key}_name", key.replaceFirstChar { it.uppercase() })
                    ?: key.replaceFirstChar { it.uppercase() }
                val time = formatEpochOrFallback(
                    widgetData.getLong("prayer_${key}_epoch_ms", 0L),
                    widgetData.getString("prayer_$key", null),
                )

                val isActive = localizedName.equals(activePrayer, ignoreCase = true)

                nameViewIds[key]?.let { views.setTextViewText(it, localizedName) }
                timeViewIds[key]?.let { views.setTextViewText(it, time) }

                // Highlight active prayer row
                if (isActive) {
                    nameViewIds[key]?.let { views.setTextColor(it, goldActive) }
                    timeViewIds[key]?.let { views.setTextColor(it, whiteActive) }
                } else {
                    nameViewIds[key]?.let { views.setTextColor(it, muted) }
                    timeViewIds[key]?.let { views.setTextColor(it, muted) }
                }
            }

            val launchIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun formatEpochOrFallback(epochMs: Long, fallbackIso: String?): String {
        if (epochMs > 0L) {
            val formatter = SimpleDateFormat("h:mm a", Locale.US)
            return formatter.format(Date(epochMs))
        }
        return fallbackIso ?: "--"
    }
}
