package org.js.samplasion.gymtracker.wear

import android.app.*
import android.content.*
import android.os.*
import kotlinx.coroutines.*
import org.json.JSONObject
import org.js.samplasion.gymtracker.wearable.*

/** Independent of sensor permission; stale/replayed deadlines vibrate once. */
object RestAlarm {
    suspend fun schedule(context: Context, session: JSONObject) {
        val end = session.optLong("restEnd") - (Store(context).get("clock")?.optLong("offset") ?: 0)
        if (end <= 0) return
        val intent = Intent(context, RestAlarmReceiver::class.java).putExtra("id", session.optString("id"))
            .putExtra("ownerScope", session.optString("ownerScope")).putExtra("deadline", session.optLong("restEnd"))
        val pending = PendingIntent.getBroadcast(context, 10, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val alarms = context.getSystemService(AlarmManager::class.java)
        if (Build.VERSION.SDK_INT < 31 || alarms.canScheduleExactAlarms()) alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, end, pending)
        else alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, end, pending)
    }
    suspend fun notify(context: Context, session: JSONObject) {
        val deadline = session.optLong("restEnd")
        if (deadline <= 0 || deadline > System.currentTimeMillis() + (Store(context).get("clock")?.optLong("offset") ?: 0)) return
        val store = Store(context)
        val key = "${session.optString("id")}/$deadline"
        val shouldVibrate = store.transaction {
            if (store.get("rest-notified", key) != null) false
            else { store.put("rest-notified", JSONObject().put("deadline", deadline), key); true }
        }
        if (shouldVibrate) context.getSystemService(Vibrator::class.java).vibrate(VibrationEffect.createOneShot(300, VibrationEffect.DEFAULT_AMPLITUDE))
    }
}
class RestAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pending = goAsync()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val store = Store(context)
                val owner = store.get("context")?.text("ownerScope") ?: return@launch
                val active = store.get("active", owner) ?: return@launch
                if (intent.action == Intent.ACTION_BOOT_COMPLETED) RestAlarm.schedule(context, active)
                else if (intent.getStringExtra("id") == active.text("id") && intent.getStringExtra("ownerScope") == owner && intent.getLongExtra("deadline", 0) == active.optLong("restEnd")) RestAlarm.notify(context, active)
            } finally { pending.finish() }
        }
    }
}
