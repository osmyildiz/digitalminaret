package com.osmyildiz.digitalminaret

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

// Android equivalent of the iOS Live Activity: a persistent "ongoing"
// notification with a custom RemoteViews layout that mirrors the lock
// screen prayer card. Unlike iOS Live Activity it cannot tick a timer
// view by itself — when called from Flutter we render the current
// remaining time as text. Re-publish whenever prayer state changes
// (worker task / app open / prayer-time scheduling).
object PrayerOngoingNotification {

    const val NOTIFICATION_ID = 9_000_001
    private const val CHANNEL_ID = "prayer_ongoing_channel"
    private const val CHANNEL_NAME = "Active Prayer Status"

    fun show(
        context: Context,
        location: String,
        activePrayer: String,
        activePrayerArabic: String,
        activePrayerTime: String,
        nextPrayer: String,
        nextPrayerTime: String,
        remaining: String,
        progressPercent: Int,
        prayerEpochs: List<Long> = emptyList(),
    ) {
        ensureChannel(context)

        val collapsed = RemoteViews(context.packageName, R.layout.notification_ongoing_collapsed).apply {
            setTextViewText(R.id.notif_active_prayer, activePrayer.uppercase())
            setTextViewText(R.id.notif_active_time, activePrayerTime)
            setTextViewText(R.id.notif_remaining, remaining)
            setTextViewText(R.id.notif_next_prayer, "→ $nextPrayer $nextPrayerTime")
            setProgressBar(R.id.notif_progress, 100, progressPercent, false)

            val urgentMs = 5 * 60 * 1000
            val warnMs = 15 * 60 * 1000
            // Color escalation matches home screen + Live Activity.
            val color = colorForRemaining(remaining, urgentMs, warnMs)
            setTextColor(R.id.notif_remaining, color)
        }

        // Full-day timeline, rasterised because RemoteViews can't host a
        // Canvas. Mirrors the iOS Live Activity DayTimelineView (nodes
        // on a proportional line, day/night switch, no labels). Falls
        // back to a progress-only bar if the schedule is missing.
        val timelineBitmap = TimelineBitmapRenderer.render(
            context = context,
            widthDp = 320,
            heightDp = 26,
            prayerEpochs = prayerEpochs,
            nowMs = System.currentTimeMillis(),
        )

        val expanded = RemoteViews(context.packageName, R.layout.notification_ongoing_expanded).apply {
            setTextViewText(R.id.notif_location, location)
            setImageViewBitmap(R.id.notif_arc, timelineBitmap)
            setTextViewText(R.id.notif_active_arabic, activePrayerArabic)
            setTextViewText(R.id.notif_active_prayer, activePrayer.uppercase())
            setTextViewText(R.id.notif_active_time, activePrayerTime)
            setTextViewText(R.id.notif_remaining, remaining)
            setTextViewText(R.id.notif_next_label, nextPrayer.uppercase())
            setTextViewText(R.id.notif_next_time, nextPrayerTime)
            setProgressBar(R.id.notif_progress, 100, progressPercent, false)
            val color = colorForRemaining(remaining, 5 * 60 * 1000, 15 * 60 * 1000)
            setTextColor(R.id.notif_remaining, color)
        }

        val launchIntent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCustomContentView(collapsed)
            .setCustomBigContentView(expanded)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setContentIntent(pendingIntent)
            .setShowWhen(false)

        // Android 15+ (API 35) — promote to "ongoing live update" surface so
        // it appears with elevated treatment on the lock screen.
        if (Build.VERSION.SDK_INT >= 35) {
            try {
                NotificationCompat::class.java
                    .getMethod("setOngoing", Boolean::class.javaPrimitiveType)
                    .invoke(builder, true)
            } catch (_: Throwable) {
                // Reflection guard — older support libs do not expose the API.
            }
        }

        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, builder.build())
    }

    fun cancel(context: Context) {
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NOTIFICATION_ID)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Live prayer status that stays in the notification shade."
            setSound(null, null)
            enableVibration(false)
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun colorForRemaining(remaining: String, urgentMs: Int, warnMs: Int): Int {
        // We receive an already-formatted string; parse "HHh MMm" or "MMm"
        // back into ms to decide the urgency color. Coarse but enough for
        // a status notification.
        val regex = Regex("(?:(\\d+)h\\s*)?(\\d+)m")
        val match = regex.find(remaining) ?: return Color.parseColor("#FFE6A8")
        val h = match.groupValues[1].toIntOrNull() ?: 0
        val m = match.groupValues[2].toIntOrNull() ?: 0
        val ms = (h * 3_600_000) + (m * 60_000)
        return when {
            ms < urgentMs -> Color.parseColor("#E85A5A")
            ms < warnMs -> Color.parseColor("#FFA552")
            else -> Color.parseColor("#FFE6A8")
        }
    }
}
