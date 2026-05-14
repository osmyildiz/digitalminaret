package com.osmyildiz.digitalminaret

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetMediumProvider : HomeWidgetProvider() {

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

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val state = WidgetData.load(widgetData)
        val goldActive = Color.parseColor("#FFE6A8")
        val whiteActive = Color.parseColor("#FFFFFF")
        val muted = Color.parseColor("#B8D2DAF3")

        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget_medium)

            views.setTextViewText(R.id.widget_active_prayer, state.activeName.uppercase())
            views.setTextViewText(R.id.widget_active_time, WidgetData.formatTime(state.activeTime))
            views.setTextViewText(R.id.widget_remaining, state.remaining)
            views.setProgressBar(R.id.widget_progress, 100, state.progress, false)

            for (item in state.prayers) {
                if (WidgetData.isSunrise(item.localizedName)) continue
                val nameId = nameViewIds[item.key] ?: continue
                val timeId = timeViewIds[item.key] ?: continue

                views.setTextViewText(nameId, item.localizedName.take(5).uppercase())
                views.setTextViewText(timeId, WidgetData.formatTime(item.time))

                val active = item.localizedName.equals(state.activeName, ignoreCase = true)
                views.setTextColor(nameId, if (active) goldActive else muted)
                views.setTextColor(timeId, if (active) whiteActive else muted)
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
}
