package org.js.samplasion.gymtracker.wear

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.*
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowRight
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.res.pluralStringResource
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material3.*
import org.json.JSONObject
import org.js.samplasion.gymtracker.wearable.*
import java.text.Collator
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle

@Composable internal fun TrainingHome(state: WatchState, error: String?, navigate: (String, JSONObject?) -> Unit) {
    WearList(stringResource(R.string.train)) {
        if (error != null) surface { modifier, transformation ->
            WatchCard(modifier, transformation, Orange) {
                CardHeading(stringResource(R.string.sync_unavailable), Icons.Rounded.WarningAmber, Orange)
            }
        }
        if (state.pending.isNotEmpty()) surface { modifier, transformation ->
            WatchCard(modifier, transformation, Cyan, onClick = { navigate("queue", null) }) {
                CardHeading(stringResource(R.string.waiting_to_sync), Icons.Rounded.Sync, Cyan, true)
                Text(stringResource(R.string.workout_count, state.pending.size), style = MaterialTheme.typography.bodySmall, color = Muted)
            }
        }
        val routines = state.catalog?.objects("routines").orEmpty()
        when {
            state.catalog == null -> surface { modifier, transformation ->
                EmptyCard(stringResource(R.string.routines_empty_title), stringResource(R.string.routines_sync_prompt), Icons.Rounded.Smartphone, modifier, transformation)
            }
            routines.isEmpty() -> surface { modifier, transformation ->
                EmptyCard(stringResource(R.string.no_routines), stringResource(R.string.create_routine_prompt), Icons.Rounded.FitnessCenter, modifier, transformation)
            }
            else -> {
                val collator = Collator.getInstance()
                state.catalog?.objects("folders")?.sortedWith { a, b -> collator.compare(a.optString("name"), b.optString("name")) }?.forEach { folder ->
                    surface(folder.text("id")) { modifier, transformation ->
                        WatchCard(modifier, transformation, Orange, onClick = { navigate("folder", folder) }) {
                            CardHeading(pluralStringResource(R.plurals.routine_count, routines.count { it.optJSONObject("folder")?.text("id") == folder.text("id") }, routines.count { it.optJSONObject("folder")?.text("id") == folder.text("id") }), Icons.Rounded.Folder, Orange, true)
                            Text(folder.optString("name"), style = MaterialTheme.typography.titleSmall)
                        }
                    }
                }
                routines.filter { it.isNull("folder") }.forEach { routine -> surface(routine.text("id")) { modifier, transformation -> RoutineCard(routine, modifier, transformation) { navigate("routine", routine) } } }
                item {
                    Row(Modifier.fillMaxWidth().padding(vertical = 4.dp, horizontal = 8.dp), verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                        Icon(Icons.Rounded.CheckCircleOutline, null, Modifier.size(14.dp), tint = Muted)
                        Text(stringResource(R.string.available_offline), style = MaterialTheme.typography.bodySmall, color = Muted)
                    }
                }
            }
        }
    }
}

@Composable private fun RoutineCard(routine: JSONObject, modifier: Modifier, transformation: SurfaceTransformation, onClick: () -> Unit) {
    val name = routine.optString("name").ifBlank { stringResource(R.string.unnamed) }
    val primary = MaterialTheme.colorScheme.primary
    WatchCard(modifier, transformation, onClick = onClick) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Box(Modifier.size(30.dp).background(primary.copy(alpha = 0.15f), CircleShape), contentAlignment = Alignment.Center) {
                Text(name.take(1).uppercase(), style = MaterialTheme.typography.labelLarge, color = primary)
            }
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                Text(name, style = MaterialTheme.typography.titleSmall, maxLines = 2, overflow = TextOverflow.Ellipsis)
                Text(pluralStringResource(R.plurals.exercise_count, routine.exercises().size, routine.exercises().size), style = MaterialTheme.typography.bodySmall, color = Muted)
            }
            Icon(Icons.AutoMirrored.Rounded.KeyboardArrowRight, null, Modifier.size(16.dp), tint = Muted)
        }
    }
}

@Composable internal fun RoutineFolder(state: WatchState, folder: JSONObject?, navigate: (String, JSONObject?) -> Unit) {
    WearList(folder?.optString("name").orEmpty()) {
        val routines = state.catalog?.objects("routines").orEmpty().filter { it.optJSONObject("folder")?.text("id") == folder?.text("id") }
        routines.forEach { routine -> surface(routine.text("id")) { modifier, transformation -> RoutineCard(routine, modifier, transformation) { navigate("routine", routine) } } }
        if (routines.isEmpty()) surface { modifier, transformation -> WatchCard(modifier, transformation) { Text(stringResource(R.string.no_routines)) } }
    }
}

@Composable internal fun RoutineDetail(routine: JSONObject?, active: Boolean, busy: Boolean, model: WatchViewModel, onStarted: () -> Unit) {
    WearList(stringResource(R.string.routine)) {
        if (routine != null) {
            surface { modifier, transformation -> WatchCard(modifier, transformation) {
                Text(routine.optString("name"), style = MaterialTheme.typography.titleMedium)
                Text(pluralStringResource(R.plurals.exercise_count, routine.exercises().size, routine.exercises().size) + " · " + pluralStringResource(R.plurals.set_count, Training.ordered(routine).size, Training.ordered(routine).size), style = MaterialTheme.typography.bodySmall, color = Muted)
            } }
            surface { modifier, transformation -> PrimaryAction(stringResource(R.string.start), Icons.Rounded.PlayArrow, modifier = modifier, transformation = transformation, enabled = !active && !busy) { model.act { start(routine); onStarted() } } }
            routine.exercises().forEach { exercise -> surface(exercise.text("id")) { modifier, transformation -> WatchCard(modifier, transformation) {
                Text(exercise.optString("name"), style = MaterialTheme.typography.titleSmall)
                Text(pluralStringResource(R.plurals.set_count, exercise.objects("sets").size, exercise.objects("sets").size), style = MaterialTheme.typography.bodySmall, color = Muted)
                if (visibleNote(exercise.optString("notes"))) RichNote(exercise.optString("notes"), MaterialTheme.colorScheme.primary)
            } } }
        }
    }
}

@Composable internal fun EmptyCard(title: String, detail: String, icon: ImageVector, modifier: Modifier = Modifier, transformation: SurfaceTransformation? = null) {
    WatchCard(modifier, transformation) {
        Icon(icon, null, Modifier.size(28.dp), tint = MaterialTheme.colorScheme.primary)
        Text(title, style = MaterialTheme.typography.titleSmall)
        Text(detail, style = MaterialTheme.typography.bodySmall, color = Muted)
    }
}

@Composable internal fun WorkoutMetrics(state: WatchState, now: Long, tint: Color, preview: Boolean, busy: Boolean,
    onEdit: () -> Unit, onCommand: (String) -> Unit, onRecordingError: () -> Unit) {
    val active = state.active ?: return
    val current = Training.current(active)
    val recording = state.get("recording")
    val recordingHere = preview || (recording?.text("id") == active.text("id") && recording?.optString("state") == "running" && WorkoutService.isRecording(active.getString("id")))
    val starting = !preview && recording?.text("id") == active.text("id") && recording?.optString("state") == "starting"
    val energy = state.metrics.sumOf { it.optDouble("energy", 0.0) }
    val heart = if (preview) 132.0 else state.metrics.maxByOrNull { it.optLong("heartRateTime") }?.takeIf { now - it.optLong("heartRateTime") in -5000..30_000 }?.optDouble("heartRate")
    val scale = LocalDensity.current.fontScale
    BoxWithConstraints(Modifier.fillMaxSize().background(Brush.verticalGradient(listOf(tint.copy(alpha = 0.29f), Color.Black), endY = 350f))) {
        val scrollable = scale > 1.15f || maxHeight < 190.dp
        Column(Modifier.fillMaxWidth().then(if (scrollable) Modifier.verticalScroll(rememberScrollState()) else Modifier)
            .padding(start = 23.dp, end = 23.dp, top = 24.dp, bottom = 12.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Text(elapsed(if (preview) 24 * 60_000L else now - active.optLong("time")), style = MaterialTheme.typography.titleLarge.copy(fontFeatureSettings = "tnum"), color = tint)
            if (current != null) {
                Column(Modifier.fillMaxWidth().heightIn(min = 43.dp).clickable(enabled = !busy, role = Role.Button, onClick = onEdit).padding(vertical = 2.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(current.exercise.optString("name"), style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        if (current.set.optBoolean("done")) Icon(Icons.Rounded.CheckCircle, null, Modifier.size(13.dp), tint = tint)
                        Text(setTypeLabel(current), color = setTypeColor(current.set.optString("kind"), tint), style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold))
                        Text(setParameters(current.set, active), style = MaterialTheme.typography.labelSmall.copy(fontFeatureSettings = "tnum"))
                        Icon(Icons.Rounded.Edit, null, Modifier.size(12.dp), tint = Muted)
                    }
                }
            }
            Row(Modifier.fillMaxWidth().heightIn(min = 44.dp), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.CenterVertically) {
                if (recordingHere) {
                    Metric(Icons.Rounded.Favorite, heart?.let { "${number(it)} bpm" } ?: "— bpm", Red)
                } else {
                    IconButton(onClick = onRecordingError) {
                        Icon(if (starting) Icons.Rounded.HourglassEmpty else Icons.Rounded.WarningAmber,
                            stringResource(if (starting) R.string.recording_starting else R.string.recording_unavailable), tint = Orange)
                    }
                }
                Metric(Icons.Rounded.LocalFireDepartment, "${number(energy, 1)} kcal", Orange)
            }
            Row(Modifier.fillMaxWidth().padding(top = 3.dp), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.CenterVertically) {
                Control(Icons.AutoMirrored.Rounded.KeyboardArrowLeft, stringResource(R.string.previous_set), tint, !busy && current != null) { onCommand("moveWorkoutCursorPrevious") }
                Control(if (current?.set?.optBoolean("done") == true) Icons.Rounded.CheckCircle else Icons.Rounded.CheckCircleOutline,
                    stringResource(if (current?.set?.optBoolean("done") == true) R.string.set_completed else R.string.complete_set), tint, !busy && current != null, prominent = true) { onCommand("markThisSetAsDone") }
                Control(Icons.AutoMirrored.Rounded.KeyboardArrowRight, stringResource(R.string.next_set), tint, !busy && current != null) { onCommand("moveWorkoutCursorNext") }
            }
            val rest = if (preview) active.optLong("screenshotRestMillis", 59_000L) else active.optLong("restEnd") - now - (state.get("clock")?.optLong("offset") ?: 0)
            if (rest > 0) Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp), modifier = Modifier.semantics(mergeDescendants = true) { }) {
                Icon(Icons.Rounded.Timer, stringResource(R.string.rest_timer), Modifier.size(14.dp), tint = tint)
                Text(elapsed(rest), style = MaterialTheme.typography.labelMedium.copy(fontFeatureSettings = "tnum"), color = tint)
            }
        }
    }
}

@Composable private fun Metric(icon: ImageVector, value: String, tint: Color) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
        Icon(icon, null, Modifier.size(14.dp), tint = tint)
        Text(value, style = MaterialTheme.typography.labelSmall.copy(fontFeatureSettings = "tnum"))
    }
}
@Composable internal fun Control(icon: ImageVector, label: String, tint: Color, enabled: Boolean = true, prominent: Boolean = false, onClick: () -> Unit) {
    FilledIconButton(onClick = onClick, enabled = enabled, modifier = Modifier.size(48.dp),
        shapes = IconButtonDefaults.animatedShapes(),
        colors = IconButtonDefaults.filledIconButtonColors(containerColor = if (prominent) tint else tint.copy(alpha = 0.14f), contentColor = if (prominent) Color(0xFF0D1720) else tint)) {
        Icon(icon, label, Modifier.size(if (prominent) 26.dp else 22.dp))
    }
}

@Composable internal fun WorkoutActions(state: WatchState, error: String?, tint: Color, connected: Boolean, model: WatchViewModel, navigate: (String, JSONObject?) -> Unit) {
    val active = state.active ?: return
    val sets = Training.ordered(active)
    val completed = sets.count { it.set.optBoolean("done") }
    val syncing = connected && state.get("dirty", state.owner.orEmpty()) != null
    WearList(stringResource(R.string.workout)) {
        surface { modifier, transformation -> WatchCard(modifier, transformation, tint) {
            Text(active.optString("name"), style = MaterialTheme.typography.titleSmall)
            Text(stringResource(R.string.set_progress, completed, sets.size), style = MaterialTheme.typography.bodySmall)
            Progress(completed.toDouble(), sets.size.toDouble(), tint)
            CardHeading(stringResource(if (syncing) R.string.syncing else if (connected) R.string.connected_phone else R.string.on_watch), if (syncing) Icons.Rounded.Sync else if (connected) Icons.Rounded.Smartphone else Icons.Rounded.Watch, Muted)
        } }
        surface { modifier, transformation -> PrimaryAction(stringResource(R.string.finish), Icons.Rounded.Check, tint, modifier, transformation) { model.act { finish(true) } } }
        surface { modifier, transformation -> TonalAction(stringResource(R.string.discard), Icons.Rounded.DeleteOutline, Red, modifier, transformation) { navigate("discard", null) } }
        if (error != null) surface { modifier, transformation -> WatchCard(modifier, transformation, Orange) { Text(error, style = MaterialTheme.typography.bodySmall, color = Orange) } }
    }
}

@Composable internal fun TrainingQueue(state: WatchState) {
    WearList(stringResource(R.string.sync)) {
        state.pending.forEach { document -> surface(document.text("id")) { modifier, transformation -> WatchCard(modifier, transformation, Cyan) {
            Text(document.optString("name"), style = MaterialTheme.typography.titleSmall)
            Text(Instant.ofEpochMilli(document.optLong("time")).atZone(ZoneId.systemDefault()).format(DateTimeFormatter.ofLocalizedDate(FormatStyle.MEDIUM)), style = MaterialTheme.typography.bodySmall, color = Muted)
            CardHeading(stringResource(R.string.waiting_phone), Icons.Rounded.Sync, Cyan)
        } } }
    }
}

@Composable internal fun NotesScreen(superset: Boolean, exercise: String, note: String, tint: Color) {
    WearList(stringResource(if (superset) R.string.superset_notes else R.string.exercise_notes)) {
        surface { modifier, transformation -> WatchCard(modifier, transformation, tint) {
            if (!superset && exercise.isNotEmpty()) Text(exercise, style = MaterialTheme.typography.titleSmall)
            RichNote(note, tint)
        } }
    }
}

@Composable internal fun DiscardConfirmation(model: WatchViewModel, tint: Color, back: () -> Unit) {
    WearList(stringResource(R.string.discard_title)) {
        surface { modifier, transformation -> PrimaryAction(stringResource(R.string.discard), Icons.Rounded.DeleteOutline, Red, modifier, transformation) { model.act { finish(false) }; back() } }
        surface { modifier, transformation -> TonalAction(stringResource(R.string.cancel), Icons.Rounded.Close, tint, modifier, transformation, onClick = back) }
    }
}

@Composable internal fun RecordingDetails(state: WatchState, error: String?, back: () -> Unit) {
    WearList(stringResource(R.string.recording_title)) {
        surface { modifier, transformation -> WatchCard(modifier, transformation, Orange) {
            CardHeading(stringResource(R.string.recording_unavailable), Icons.Rounded.WarningAmber, Orange)
            Text(state.get("recording-error")?.optString("message")?.takeIf { it.isNotBlank() } ?: error ?: stringResource(R.string.sensors_denied), style = MaterialTheme.typography.bodySmall)
        } }
        surface { modifier, transformation -> PrimaryAction(stringResource(R.string.close), Icons.Rounded.Close, modifier = modifier, transformation = transformation, onClick = back) }
    }
}

@Composable internal fun WorkoutSummary(state: WatchState, summary: JSONObject?, back: () -> Unit) {
    WearList(stringResource(R.string.summary)) {
        val doc = summary?.takeIf { it.text("ownerScope") == state.owner }
        if (doc != null && doc.optString("status") == "completed") {
            val metrics = state.list("metrics").filter { it.text("id") == doc.text("id") && it.text("ownerScope") == state.owner }
            val samples = metrics.flatMap { it.objects("samples") }
            val rows = listOf(
                Triple(R.string.total_time, summaryDuration(doc.optLong("duration") / 1000), Orange),
                Triple(R.string.total_energy, "${number(metrics.sumOf { it.optDouble("energy", 0.0) }, 1)} kcal", Pink),
                Triple(R.string.avg_heart_rate, if (samples.isEmpty()) "— bpm" else "${number(samples.map { it.optDouble("bpm") }.average())} bpm", Red))
            rows.forEach { (title, value, color) -> surface(title) { modifier, transformation -> WatchCard(modifier, transformation, color) {
                Text(stringResource(title), style = MaterialTheme.typography.labelMedium, color = color)
                Text(value, style = MaterialTheme.typography.titleLarge.copy(fontFeatureSettings = "tnum"), color = color)
            } } }
        } else surface { modifier, transformation -> WatchCard(modifier, transformation) {
            Text(stringResource(if (doc?.optString("status") == "discarded") R.string.workout_discarded else R.string.saving_workout), style = MaterialTheme.typography.bodyMedium)
        } }
        surface { modifier, transformation -> PrimaryAction(stringResource(R.string.done), Icons.Rounded.Check, modifier = modifier, transformation = transformation, onClick = back) }
    }
}
