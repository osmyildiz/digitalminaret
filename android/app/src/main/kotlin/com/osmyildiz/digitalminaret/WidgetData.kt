package com.osmyildiz.digitalminaret

import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

data class PrayerEntry(
    val key: String,
    val localizedName: String,
    val time: Date,
)

data class WidgetState(
    val location: String,
    val activeKey: String,
    val activeName: String,
    val activeTime: Date,
    val nextKey: String,
    val nextName: String,
    val nextTime: Date,
    val periodStart: Date,
    val periodEnd: Date,
    val remaining: String,
    val progress: Int,
    val prayers: List<PrayerEntry>,
)

object WidgetData {

    private val prayerKeys = listOf("fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha")

    private val timeFormatter = SimpleDateFormat("h:mm a", Locale.US)

    // Mirrors the static map in iOS PrayerWidget.swift arabicName(_:).
    private val arabicNames = mapOf(
        "fajr" to "فجر", "sabah" to "فجر", "subuh" to "فجر",
        "sunrise" to "شروق", "güneş" to "شروق", "terbit" to "شروق", "chourouk" to "شروق",
        "dhuhr" to "ظهر", "öğle" to "ظهر", "dzuhur" to "ظهر", "dohr" to "ظهر",
        "asr" to "عصر", "ikindi" to "عصر", "ashar" to "عصر",
        "maghrib" to "مغرب", "akşam" to "مغرب",
        "isha" to "عشاء", "yatsı" to "عشاء", "isya" to "عشاء",
        "الفجر" to "فجر", "الشروق" to "شروق", "الظهر" to "ظهر",
        "العصر" to "عصر", "المغرب" to "مغرب", "العشاء" to "عشاء",
        // Japanese katakana transliterations
        "ファジュル" to "فجر", "日の出" to "شروق", "ドゥフル" to "ظهر",
        "アスル" to "عصر", "マグリブ" to "مغرب", "イシャー" to "عشاء",
    )

    private val hijriMonthNames = listOf(
        "Muharram", "Safar", "Rabi I", "Rabi II", "Jumada I", "Jumada II",
        "Rajab", "Shaban", "Ramadan", "Shawwal", "Dhu al-Qadah", "Dhu al-Hijjah",
    )

    fun load(prefs: SharedPreferences): WidgetState {
        val location = prefs.getString("location_name", "Digital Minaret") ?: "Digital Minaret"

        val raw = prayerKeys.mapNotNull { key ->
            val epoch = prefs.getLong("prayer_${key}_epoch_ms", 0L)
            if (epoch <= 0L) {
                null
            } else {
                val name = prefs.getString("prayer_${key}_name", key.replaceFirstChar { it.uppercase() })
                    ?: key.replaceFirstChar { it.uppercase() }
                PrayerEntry(key, name, Date(epoch))
            }
        }

        val rebased = rebaseToToday(raw).sortedBy { it.time }
        val now = Date()
        val resolved = resolveActiveAndNext(now, rebased)

        return WidgetState(
            location = location,
            activeKey = resolved.activeKey,
            activeName = resolved.activeName,
            activeTime = resolved.activeTime,
            nextKey = resolved.nextKey,
            nextName = resolved.nextName,
            nextTime = resolved.nextTime,
            periodStart = resolved.periodStart,
            periodEnd = resolved.periodEnd,
            remaining = formatRemaining(now, resolved.nextTime),
            progress = computeProgress(now, resolved.periodStart, resolved.periodEnd),
            prayers = rebased,
        )
    }

    fun formatTime(date: Date): String = timeFormatter.format(date)

    fun arabicNameFor(name: String): String =
        arabicNames[name.lowercase(Locale.ROOT)] ?: name

    fun isSunrise(name: String): Boolean {
        val l = name.lowercase(Locale.ROOT)
        return l == "sunrise" || l == "güneş" || l == "شروق" || l == "الشروق" ||
            l == "terbit" || l == "chourouk" || l == "طلوع آفتاب" || l == "日の出"
    }

    /// Returns "<day> <month-name>" for today in Umm al-Qura (mirrors iOS).
    fun hijriDateText(): String {
        val now = Calendar.getInstance()
        val hijri = gregorianToHijri(
            now.get(Calendar.YEAR),
            now.get(Calendar.MONTH) + 1,
            now.get(Calendar.DAY_OF_MONTH),
        )
        val month = hijriMonthNames[(hijri.second - 1).coerceIn(0, 11)]
        return "${hijri.third} $month"
    }

    private fun rebaseToToday(prayers: List<PrayerEntry>): List<PrayerEntry> {
        val cal = Calendar.getInstance()
        return prayers.map { item ->
            val src = Calendar.getInstance().apply { time = item.time }
            val dst = Calendar.getInstance().apply {
                set(Calendar.YEAR, cal.get(Calendar.YEAR))
                set(Calendar.MONTH, cal.get(Calendar.MONTH))
                set(Calendar.DAY_OF_MONTH, cal.get(Calendar.DAY_OF_MONTH))
                set(Calendar.HOUR_OF_DAY, src.get(Calendar.HOUR_OF_DAY))
                set(Calendar.MINUTE, src.get(Calendar.MINUTE))
                set(Calendar.SECOND, src.get(Calendar.SECOND))
                set(Calendar.MILLISECOND, 0)
            }
            PrayerEntry(item.key, item.localizedName, dst.time)
        }
    }

    private data class Resolved(
        val activeKey: String,
        val activeName: String,
        val activeTime: Date,
        val nextKey: String,
        val nextName: String,
        val nextTime: Date,
        val periodStart: Date,
        val periodEnd: Date,
    )

    private fun resolveActiveAndNext(now: Date, prayers: List<PrayerEntry>): Resolved {
        if (prayers.isEmpty()) {
            val next = Date(now.time + 3_600_000L)
            return Resolved(
                activeKey = "isha", activeName = "Isha", activeTime = now,
                nextKey = "fajr", nextName = "Fajr", nextTime = next,
                periodStart = now, periodEnd = next,
            )
        }

        var previous = prayers.last()
        var next = prayers.first()
        for (item in prayers) {
            if (!item.time.after(now)) {
                previous = item
            } else {
                next = item
                break
            }
        }

        val nextTime = if (!next.time.after(now)) Date(next.time.time + 86_400_000L) else next.time
        val previousTime = if (previous.time.after(now)) Date(previous.time.time - 86_400_000L) else previous.time

        return Resolved(
            activeKey = previous.key,
            activeName = previous.localizedName,
            activeTime = previousTime,
            nextKey = next.key,
            nextName = next.localizedName,
            nextTime = nextTime,
            periodStart = previousTime,
            periodEnd = nextTime,
        )
    }

    private fun formatRemaining(now: Date, next: Date): String {
        val ms = (next.time - now.time).coerceAtLeast(0L)
        val totalMinutes = ms / 60_000L
        val h = totalMinutes / 60L
        val m = totalMinutes % 60L
        return if (h == 0L) {
            String.format(Locale.US, "%02dm", m)
        } else {
            String.format(Locale.US, "%02dh %02dm", h, m)
        }
    }

    private fun computeProgress(now: Date, start: Date, end: Date): Int {
        val total = end.time - start.time
        if (total <= 0L) return 0
        val elapsed = now.time - start.time
        val ratio = elapsed.toDouble() / total.toDouble()
        return (ratio.coerceIn(0.0, 1.0) * 100.0).toInt()
    }

    // Same algorithm as lib/data/services/notification_service.dart _gregorianToHijri.
    // Returns Triple<year, month, day>.
    private fun gregorianToHijri(gy: Int, gm: Int, gd: Int): Triple<Int, Int, Int> {
        val a = (14 - gm) / 12
        val y = gy + 4800 - a
        val m = gm + 12 * a - 3
        val jdn = gd +
            (153 * m + 2) / 5 +
            365 * y +
            y / 4 -
            y / 100 +
            y / 400 -
            32045

        val l = jdn - 1948440 + 10632
        val n = (l - 1) / 10631
        val l1 = l - 10631 * n + 354
        val j = ((10985 - l1) / 5316) * ((50 * l1) / 17719) +
            (l1 / 5670) * ((43 * l1) / 15238)
        val l2 = l1 -
            ((30 - j) / 15) * ((17719 * j) / 50) -
            (j / 16) * ((15238 * j) / 43) +
            29
        val month = (24 * l2 / 709)
        val day = l2 - (709 * month / 24)
        val year = 30 * n + j - 30
        return Triple(year, month, day)
    }
}
