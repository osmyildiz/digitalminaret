package com.osmyildiz.digitalminaret

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetXLargeProvider : HomeWidgetProvider() {

    private val nameViewIds = mapOf(
        "fajr" to R.id.name_fajr,
        "sunrise" to R.id.name_sunrise,
        "dhuhr" to R.id.name_dhuhr,
        "asr" to R.id.name_asr,
        "maghrib" to R.id.name_maghrib,
        "isha" to R.id.name_isha,
    )

    private val timeViewIds = mapOf(
        "fajr" to R.id.time_fajr,
        "sunrise" to R.id.time_sunrise,
        "dhuhr" to R.id.time_dhuhr,
        "asr" to R.id.time_asr,
        "maghrib" to R.id.time_maghrib,
        "isha" to R.id.time_isha,
    )

    private val dotViewIds = mapOf(
        "fajr" to R.id.dot_fajr,
        "sunrise" to R.id.dot_sunrise,
        "dhuhr" to R.id.dot_dhuhr,
        "asr" to R.id.dot_asr,
        "maghrib" to R.id.dot_maghrib,
        "isha" to R.id.dot_isha,
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val state = WidgetData.load(widgetData)
        val gold = Color.parseColor("#FFE6A8")
        val whiteActive = Color.parseColor("#FFFFFF")
        val muted = Color.parseColor("#B8D2DAF3")

        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget_xlarge)

            views.setTextViewText(R.id.widget_location, state.location)
            views.setTextViewText(R.id.widget_hijri_date, WidgetData.hijriDateText())
            views.setProgressBar(R.id.widget_progress, 100, state.progress, false)

            for (item in state.prayers) {
                val nameId = nameViewIds[item.key] ?: continue
                val timeId = timeViewIds[item.key] ?: continue
                val dotId = dotViewIds[item.key] ?: continue

                views.setTextViewText(nameId, item.localizedName.uppercase())
                views.setTextViewText(timeId, WidgetData.formatTime(item.time))

                val active = item.localizedName.equals(state.activeName, ignoreCase = true)
                views.setTextColor(nameId, if (active) gold else muted)
                views.setTextColor(timeId, if (active) whiteActive else muted)
                views.setImageViewResource(
                    dotId,
                    if (active) R.drawable.widget_dot_active else R.drawable.widget_dot_inactive,
                )
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
