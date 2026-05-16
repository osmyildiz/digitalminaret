package com.osmyildiz.digitalminaret

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {

    companion object {
        private const val LIVE_ACTIVITY_CHANNEL =
            "com.osmyildiz.digitalminaret/live_activity"
        private const val WEAR_CHANNEL =
            "com.osmyildiz.digitalminaret/wear"
    }

    private val wearScope = CoroutineScope(Dispatchers.IO)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LIVE_ACTIVITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSupported" -> result.success(true)
                    "start", "update" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args == null) {
                            result.error("BAD_ARGS", "Missing arguments", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val scheduleRaw = args["schedule"] as? List<*>
                            val epochs = scheduleRaw?.mapNotNull { item ->
                                ((item as? Map<*, *>)?.get("epochMs")
                                    as? Number)?.toLong()
                            } ?: emptyList()
                            PrayerOngoingNotification.show(
                                context = applicationContext,
                                location = args["location"] as? String ?: "",
                                activePrayer = args["activePrayer"] as? String ?: "",
                                activePrayerArabic = args["activePrayerArabic"] as? String ?: "",
                                activePrayerTime = args["activePrayerTimeText"] as? String ?: "",
                                nextPrayer = args["nextPrayer"] as? String ?: "",
                                nextPrayerTime = args["nextPrayerTimeText"] as? String ?: "",
                                remaining = args["remainingText"] as? String ?: "",
                                progressPercent = (args["progressPercent"] as? Number)?.toInt() ?: 0,
                                prayerEpochs = epochs,
                            )
                            result.success(true)
                        } catch (error: Throwable) {
                            result.error("NOTIF_FAILED", error.message, null)
                        }
                    }
                    "end" -> {
                        PrayerOngoingNotification.cancel(applicationContext)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WEAR_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "push" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args == null) {
                            result.error("BAD_ARGS", "Missing arguments", null)
                            return@setMethodCallHandler
                        }
                        val location = args["location"] as? String ?: ""
                        @Suppress("UNCHECKED_CAST")
                        val epochs = (args["epochs"] as? Map<String, Number>)
                            ?.mapValues { it.value.toLong() } ?: emptyMap()
                        @Suppress("UNCHECKED_CAST")
                        val names = (args["names"] as? Map<String, String>) ?: emptyMap()
                        wearScope.launch {
                            WearDataPusher.push(applicationContext, location, epochs, names)
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
