package com.osmyildiz.digitalminaret.wear

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.Text
import kotlinx.coroutines.delay
import java.util.Date

private val gold = Color(0xFFFFE6A8)
private val navy = Color(0xFF050C1E)
private val muted = Color(0xB3D2DAF3)
private val warn = Color(0xFFFFA552)
private val urgent = Color(0xFFE85A5A)

@Composable
fun PrayerWatchScreen(state: PrayerState, modifier: Modifier = Modifier) {
    var now by remember { mutableStateOf(Date()) }
    LaunchedEffect(Unit) {
        while (true) {
            now = Date()
            delay(1_000L)
        }
    }

    val remainingMs = (state.next.time.time - now.time).coerceAtLeast(0L)
    val color = when {
        remainingMs < 5 * 60_000L -> urgent
        remainingMs < 15 * 60_000L -> warn
        else -> gold
    }

    Column(
        modifier = modifier
            .background(navy)
            .padding(horizontal = 12.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = state.active.name.uppercase(),
            color = gold,
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold,
        )
        Spacer(Modifier.height(2.dp))
        Text(
            text = PrayerRepository.TIME_FORMAT.format(state.active.time),
            color = Color.White,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
        )
        Spacer(Modifier.height(6.dp))
        Text(
            text = formatRemaining(remainingMs),
            color = color,
            fontSize = 26.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(4.dp))
        Text(
            text = "→ ${state.next.name.uppercase()}",
            color = muted,
            fontSize = 11.sp,
        )
        Spacer(Modifier.height(4.dp))
        Text(
            text = state.location,
            color = muted,
            fontSize = 10.sp,
        )
    }
}

private fun formatRemaining(ms: Long): String {
    val totalSeconds = (ms / 1000).coerceAtLeast(0L)
    val h = totalSeconds / 3600L
    val m = (totalSeconds % 3600L) / 60L
    val s = totalSeconds % 60L
    return if (h > 0L) {
        "%d:%02d:%02d".format(h, m, s)
    } else {
        "%02d:%02d".format(m, s)
    }
}
