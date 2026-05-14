package com.osmyildiz.digitalminaret

import android.content.Context
import android.util.Log
import com.google.android.gms.tasks.Tasks
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable

// Publishes the current prayer snapshot to all paired Wear OS devices.
// Synchronous body but called from a background coroutine on the Flutter
// platform thread; the actual network call is async via Tasks.await.
//
// The watch app's PrayerDataListenerService receives /prayer/state and
// mirrors the data into its local SharedPreferences cache.
object WearDataPusher {

    private const val TAG = "WearDataPusher"
    private const val PATH = "/prayer/state"

    fun push(
        context: Context,
        location: String,
        prayerEpochs: Map<String, Long>,
        prayerNames: Map<String, String>,
    ) {
        try {
            val request = PutDataMapRequest.create(PATH).apply {
                dataMap.putString("location_name", location)
                // Bump a monotonic counter so the DataItem is treated as
                // changed even if epoch values are the same as before.
                dataMap.putLong("_revision", System.currentTimeMillis())
                for ((key, epoch) in prayerEpochs) {
                    dataMap.putLong("prayer_${key}_epoch_ms", epoch)
                }
                for ((key, name) in prayerNames) {
                    dataMap.putString("prayer_${key}_name", name)
                }
            }
            val putRequest = request.asPutDataRequest().setUrgent()
            val client = Wearable.getDataClient(context)
            Tasks.await(client.putDataItem(putRequest))
        } catch (error: Throwable) {
            // No paired watch, GMS missing, or network down — silent.
            Log.d(TAG, "wear push skipped: ${error.message}")
        }
    }
}
