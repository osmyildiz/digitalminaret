package com.osmyildiz.digitalminaret.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.wear.compose.material.MaterialTheme

class MainActivity : ComponentActivity() {
    private lateinit var prayerRepo: PrayerRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        prayerRepo = PrayerRepository(applicationContext)

        setContent {
            val state by prayerRepo.state.collectAsState()
            LaunchedEffect(Unit) {
                prayerRepo.startRefreshLoop()
            }
            MaterialTheme {
                PrayerWatchScreen(state = state, modifier = Modifier.fillMaxSize())
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        prayerRepo.stopRefreshLoop()
    }
}
