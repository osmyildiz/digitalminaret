package com.osmyildiz.digitalminaret.wear

import android.content.Context
import android.content.SharedPreferences
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

data class PrayerEntry(val name: String, val time: Date)

data class PrayerState(
    val location: String = "—",
    val active: PrayerEntry = PrayerEntry("—", Date()),
    val next: PrayerEntry = PrayerEntry("—", Date(System.currentTimeMillis() + 3_600_000L)),
    val periodStart: Date = Date(),
    val periodEnd: Date = Date(System.currentTimeMillis() + 3_600_000L),
    val prayers: List<PrayerEntry> = emptyList(),
)

// Hybrid data source: (1) the paired phone pushes via Wearable DataLayer
// into local SharedPreferences in PrayerDataListenerService, (2) the
// repository reads + polls every 30 s so the UI auto-refreshes between
// phone pushes.
class PrayerRepository(private val context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private val _state = MutableStateFlow(PrayerState())
    val state: StateFlow<PrayerState> = _state.asStateFlow()

    private val scope = CoroutineScope(Dispatchers.Default)
    private var refreshJob: Job? = null

    fun startRefreshLoop() {
        refresh()
        // Pull from phone once on startup in case we missed an earlier push.
        scope.launch {
            try {
                pullFromPhone()
                refresh()
            } catch (_: Throwable) {
                // Phone unreachable — fall back to cached state.
            }
        }
        refreshJob?.cancel()
        refreshJob = scope.launch {
            while (true) {
                delay(30_000L)
                refresh()
            }
        }
    }

    fun stopRefreshLoop() {
        refreshJob?.cancel()
        refreshJob = null
    }

    fun refresh() {
        val location = prefs.getString("location_name", "—") ?: "—"
        val keys = listOf("fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha")
        val raw = keys.mapNotNull { key ->
            val epoch = prefs.getLong("prayer_${key}_epoch_ms", 0L)
            if (epoch <= 0L) {
                null
            } else {
                val name = prefs.getString("prayer_${key}_name", key.replaceFirstChar { it.uppercase() })
                    ?: key.replaceFirstChar { it.uppercase() }
                PrayerEntry(name, Date(epoch))
            }
        }
        val rebased = rebaseToToday(raw).sortedBy { it.time }
        val now = Date()
        val resolved = resolveActiveAndNext(now, rebased)

        _state.value = PrayerState(
            location = location,
            active = resolved.first,
            next = resolved.second,
            periodStart = resolved.first.time,
            periodEnd = resolved.second.time,
            prayers = rebased,
        )
    }

    /// Asks the paired phone to send a fresh snapshot via DataLayer. The
    /// phone-side handler (added later) writes a `DataMap` at
    /// `/prayer/state`; PrayerDataListenerService persists it.
    private suspend fun pullFromPhone() {
        val client = Wearable.getDataClient(context)
        val nodes = Wearable.getNodeClient(context).connectedNodes.await()
        if (nodes.isEmpty()) return

        val items = client.getDataItems(android.net.Uri.parse("wear://*/prayer/state")).await()
        for (item in items) {
            val map = DataMapItem.fromDataItem(item).dataMap
            applyDataMap(map)
        }
    }

    fun applyDataMap(map: com.google.android.gms.wearable.DataMap) {
        prefs.edit().apply {
            map.getString("location_name")?.let { putString("location_name", it) }
            for (key in listOf("fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha")) {
                val epoch = map.getLong("prayer_${key}_epoch_ms", 0L)
                if (epoch > 0L) putLong("prayer_${key}_epoch_ms", epoch)
                map.getString("prayer_${key}_name")?.let { putString("prayer_${key}_name", it) }
            }
            apply()
        }
    }

    private fun rebaseToToday(items: List<PrayerEntry>): List<PrayerEntry> {
        val cal = Calendar.getInstance()
        return items.map { item ->
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
            PrayerEntry(item.name, dst.time)
        }
    }

    private fun resolveActiveAndNext(
        now: Date,
        prayers: List<PrayerEntry>,
    ): Pair<PrayerEntry, PrayerEntry> {
        if (prayers.isEmpty()) {
            val active = PrayerEntry("—", now)
            val next = PrayerEntry("—", Date(now.time + 3_600_000L))
            return active to next
        }
        var previous = prayers.last()
        var next = prayers.first()
        for (item in prayers) {
            if (!item.time.after(now)) previous = item
            else {
                next = item
                break
            }
        }
        val activeTime = if (previous.time.after(now)) Date(previous.time.time - 86_400_000L) else previous.time
        val nextTime = if (!next.time.after(now)) Date(next.time.time + 86_400_000L) else next.time
        return PrayerEntry(previous.name, activeTime) to PrayerEntry(next.name, nextTime)
    }

    companion object {
        const val PREFS_NAME = "wear_prayer_state"
        val TIME_FORMAT: SimpleDateFormat = SimpleDateFormat("h:mm a", Locale.US)
    }
}
