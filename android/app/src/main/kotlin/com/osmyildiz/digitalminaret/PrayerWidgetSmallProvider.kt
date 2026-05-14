package com.osmyildiz.digitalminaret

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetSmallProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val state = WidgetData.load(widgetData)
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget_small)

            views.setTextViewText(R.id.widget_active_prayer, state.activeName.uppercase())
            views.setTextViewText(R.id.widget_active_time, WidgetData.formatTime(state.activeTime))
            views.setProgressBar(R.id.widget_progress, 100, state.progress, false)
            views.setTextViewText(
                R.id.widget_next_summary,
                "${state.nextName} ${WidgetData.formatTime(state.nextTime)}",
            )

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
