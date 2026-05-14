package com.osmyildiz.digitalminaret.wear

import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.WearableListenerService

class PrayerDataListenerService : WearableListenerService() {

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        for (event in dataEvents) {
            if (event.type != DataEvent.TYPE_CHANGED) continue
            val item = event.dataItem
            if (!item.uri.path.orEmpty().startsWith("/prayer")) continue

            val map = DataMapItem.fromDataItem(item).dataMap
            val repo = PrayerRepository(applicationContext)
            repo.applyDataMap(map)
            repo.refresh()
        }
    }
}
