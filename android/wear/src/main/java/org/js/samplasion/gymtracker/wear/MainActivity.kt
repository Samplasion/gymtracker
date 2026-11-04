package org.js.samplasion.gymtracker.wear

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.core.content.ContextCompat
import java.util.Locale

class MainActivity : ComponentActivity() {
    private val model: WatchViewModel by viewModels()
    private var resumed by mutableStateOf(false)
    private val permissions = registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) {
        if (requiredPermissions().all { permission -> ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED }) startSensors()
        else model.error.value = getString(R.string.sensors_denied)
    }
    private fun requiredPermissions() = listOf(Manifest.permission.ACTIVITY_RECOGNITION,
        if (Build.VERSION.SDK_INT >= 36) "android.permission.health.READ_HEART_RATE" else Manifest.permission.BODY_SENSORS)
    private fun record() {
        if (requiredPermissions().all { ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED }) startSensors()
        else permissions.launch((requiredPermissions() + if (Build.VERSION.SDK_INT >= 33) listOf(Manifest.permission.POST_NOTIFICATIONS) else emptyList()).toTypedArray())
    }
    private fun startSensors() {
        runCatching { ContextCompat.startForegroundService(this, Intent(this, WorkoutService::class.java)) }
            .onFailure { model.error.value = it.message }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        if (BuildConfig.DEBUG && intent.getBooleanExtra("screenshots", false)) {
            intent.getStringExtra("locale")?.takeIf { it in listOf("it", "en") }?.let { language ->
                val locale = Locale.forLanguageTag(language)
                Locale.setDefault(locale)
                val configuration = android.content.res.Configuration(resources.configuration).apply { setLocale(locale) }
                @Suppress("DEPRECATION")
                resources.updateConfiguration(configuration, resources.displayMetrics)
            }
        }
        super.onCreate(savedInstanceState)
        val initial = if (BuildConfig.DEBUG && intent.getBooleanExtra("screenshots", false)) intent.getStringExtra("scene") ?: "home" else intent.getStringExtra("screen") ?: "home"
        if (BuildConfig.DEBUG && intent.getBooleanExtra("screenshots", false)) model.screenshots(initial, intent.getBooleanExtra("app_store", false), intent.getIntExtra("screenshot_rest_seconds", 90))
        setContent { GymBroTheme { WearApp(model, resumed, initial, BuildConfig.DEBUG && intent.getBooleanExtra("screenshots", false), ::record) } }
    }
    override fun onResume() { super.onResume(); resumed = true; model.act { replay() } }
    override fun onPause() { resumed = false; super.onPause() }
}
