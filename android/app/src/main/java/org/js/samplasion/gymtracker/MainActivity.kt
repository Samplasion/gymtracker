package org.js.samplasion.gymtracker

import android.annotation.SuppressLint
import android.app.BroadcastOptions
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationCompat.Action
import androidx.core.app.NotificationCompat.EXTRA_NOTIFICATION_ID
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneOffset
import java.time.temporal.ChronoField


const val CHANNEL_ID = "org.js.samplasion.gymtracker.LiveActivityChannel"
const val PERMISSION_POST_NOTIFICATIONS = "android.permission.POST_NOTIFICATIONS"
const val ACTION_MARK = "org.js.samplasion.MARK_COMPLETED"

/// The ID for the platform-specific live activity notification
const val NOTIFICATION_ID = 1

class MainActivity: FlutterActivity() {
    lateinit var nativeApi: GymBroNativeFlutterAPI
    lateinit var logger: GymBroNativeLoggerChannel
    val api = GymBroNativeHostAPIImpl()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        nativeApi = GymBroNativeFlutterAPI(
            binaryMessenger = flutterEngine.dartExecutor.binaryMessenger,
            messageChannelSuffix = ""
        )
        logger = GymBroNativeLoggerChannel(
            binaryMessenger = flutterEngine.dartExecutor.binaryMessenger,
            messageChannelSuffix = ""
        )

        GymBroNativeHostAPI.setUp(flutterEngine.dartExecutor.binaryMessenger, api, "")
    }

    private fun log(message: String) {
        println(message)
        logger.logMessage(message, callback = {})
    }

    private fun error(message: String) {
        System.err.println(message)
        logger.logError(message, callback = {})
    }

    private fun createNotificationChannel() {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is not in the Support Library.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Live Activity"
            val descriptionText = "Live Activity"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            // Register the channel with the system.
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    inner class GymBroNativeHostAPIImpl: GymBroNativeHostAPI {
        private var state: NativeWorkoutStateMessage? = null
        private val notificationBuilder = NotificationCompat.Builder(this@MainActivity, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notifications)
            .setContentTitle("Live Activity")
            .setContentText("blah blah blah")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setOngoing(true)
            .setSilent(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_WORKOUT)

        override fun startWorkout() {
            createOrUpdateOngoingLiveNotification()
        }

        override fun stopWorkout() {
            removeOngoingLiveNotification()
        }

        override fun setExerciseParameters(parameters: Map<String?, Any?>) {
            val message = NativeWorkoutStateMessage.fromJson(parameters)
            state = message

            createOrUpdateOngoingLiveNotification()
        }

        private fun createOrUpdateOngoingLiveNotification() {
            log("Creating ongoing live notification")
            createNotificationChannel()

            if (state != null) with (state!!) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    notificationBuilder
                        .setChronometerCountDown(false)
                }
                notificationBuilder
                    .setWhen(startingTime)
                    .setUsesChronometer(true)
                    .setContentTitle(exerciseName)
                    .setContentText(exerciseParameters)
                    .setProgress(100, (percentageDone * 100).toInt(), false)
                    .setColor(exerciseColor)

                if (!hasExercise) {
                    notificationBuilder.setSmallIcon(R.drawable.check_circle)
                } else {
                    notificationBuilder.setSmallIcon(R.drawable.ic_notifications)
                }
            }
            if (state != null && state!!.restTimeEnd != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    notificationBuilder
                        .setChronometerCountDown(true)
                }

                notificationBuilder
                    .setUsesChronometer(true)
                    .setWhen(state!!.restTimeEnd!!)
                    .setShowWhen(true)
            }

            val intent = Intent(this@MainActivity, MainActivity::class.java)
            notificationBuilder.setContentIntent(PendingIntent.getActivity(this@MainActivity, 0, intent, PendingIntent.FLAG_IMMUTABLE))

            with(NotificationManagerCompat.from(this@MainActivity)) {
                if (ActivityCompat.checkSelfPermission(
                        this@MainActivity,
                        PERMISSION_POST_NOTIFICATIONS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    // TODO: Consider calling
                    // ActivityCompat#requestPermissions
                    // here to request the missing permissions, and then overriding
                    // public fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>,
                    //                                        grantResults: IntArray)
                    // to handle the case where the user grants the permission. See the documentation
                    // for ActivityCompat#requestPermissions for more details.

                    return@with
                }

                // notificationId is a unique int for each notification that you must define.
                notify(NOTIFICATION_ID, notificationBuilder.build())
            }
        }
        private fun removeOngoingLiveNotification() {
            with(NotificationManagerCompat.from(this@MainActivity)) {
                if (ActivityCompat.checkSelfPermission(
                        this@MainActivity,
                        PERMISSION_POST_NOTIFICATIONS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    // TODO: Consider calling
                    // ActivityCompat#requestPermissions
                    // here to request the missing permissions, and then overriding
                    // public fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>,
                    //                                        grantResults: IntArray)
                    // to handle the case where the user grants the permission. See the documentation
                    // for ActivityCompat#requestPermissions for more details.

                    return@with
                }

                cancel(NOTIFICATION_ID)
            }
        }
    }
}

private fun NotificationCompat.Builder.setWhen(ldt: LocalDateTime): NotificationCompat.Builder {
    val zone = ZoneOffset.systemDefault()
    val rules = zone.rules
    val offset = rules.getOffset(Instant.now())
    val time = ldt.toEpochSecond(offset) * 1000 + ldt.get(ChronoField.MILLI_OF_SECOND)
    if (time != null) setWhen(time)
    return this
}
