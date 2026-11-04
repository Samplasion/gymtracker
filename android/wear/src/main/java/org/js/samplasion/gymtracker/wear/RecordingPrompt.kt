package org.js.samplasion.gymtracker.wear

import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

object RecordingPrompt {
    fun show(context: Context) {
        if (Build.VERSION.SDK_INT >= 33 && ContextCompat.checkSelfPermission(context, android.Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) return
        val manager = context.getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(NotificationChannel("recording-request", "Gym Bro", NotificationManager.IMPORTANCE_DEFAULT))
        val intent = PendingIntent.getActivity(context, 30, Intent(context, MainActivity::class.java).putExtra("screen", "workout"), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        manager.notify(30, NotificationCompat.Builder(context, "recording-request").setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("Gym Bro").setContentText(context.getString(R.string.confirm_recording)).setContentIntent(intent).setAutoCancel(true).build())
    }
}
