package org.js.samplasion.gymtracker

import android.graphics.Color
import android.util.Log
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId

data class NativeWorkoutStateMessage(
    val hasExercise: Boolean,
    val exerciseName: String,
    val exerciseColor: Int,
    val exerciseParameters: String,
    val startingTime: LocalDateTime,
    val restTimeStart: LocalDateTime? = null,
    val restTimeEnd: LocalDateTime? = null,
    val percentageDone: Double
) {

    companion object {
        fun fromJson(map: Map<String?, Any?>): NativeWorkoutStateMessage {
            Log.d("tag", "$map")
            val hasExercise = map["hasExercise"] as? Boolean ?: false
            val exerciseName = map["exerciseName"] as? String ?: ""
            val exerciseColorHex = map["exerciseColor"] as? Long ?: 0
            val exerciseColorInt = exerciseColorHex.toInt() // Drop the alpha channel
            val exerciseParameters = map["exerciseParameters"] as? String ?: ""

            fun epochToLocalDateTime(value: Any?): LocalDateTime? {
                return (value as? Number)?.let {
                    LocalDateTime.ofInstant(
                        Instant.ofEpochMilli(it.toLong()),
                        ZoneId.systemDefault()
                    )
                }
            }

            val startingTime = epochToLocalDateTime(map["startingTime"])
                ?: LocalDateTime.now()
            val restTimeStart = epochToLocalDateTime(map["restTimeStart"])
            val restTimeEnd = epochToLocalDateTime(map["restTimeEnd"])
            val percentageDone = (map["percentageDone"] as? Number)?.toDouble() ?: 0.0

            return NativeWorkoutStateMessage(
                hasExercise,
                exerciseName,
                exerciseColorInt,
                exerciseParameters,
                startingTime,
                restTimeStart,
                restTimeEnd,
                percentageDone
            )
        }
    }
}