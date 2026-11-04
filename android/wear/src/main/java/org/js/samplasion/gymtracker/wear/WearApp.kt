package org.js.samplasion.gymtracker.wear

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.wear.compose.foundation.BasicSwipeToDismissBox
import androidx.wear.compose.foundation.pager.*
import androidx.wear.compose.material3.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.json.JSONObject
import org.js.samplasion.gymtracker.wearable.*

internal data class WatchRoute(val screen: String, val value: JSONObject? = null)

@Composable internal fun WearApp(model: WatchViewModel, resumed: Boolean, initial: String, preview: Boolean, record: () -> Unit) {
    val rows by model.documents.collectAsStateWithLifecycle()
    val error by model.error.collectAsStateWithLifecycle()
    val busy by model.busy.collectAsStateWithLifecycle()
    val connected by model.connected.collectAsStateWithLifecycle()
    val state = WatchState(rows)
    val routes = remember { mutableStateListOf<WatchRoute>() }
    val scope = rememberCoroutineScope()
    val active = state.active
    val current = active?.let(Training::current)
    val notes = current?.exercise?.optString("notes").orEmpty()
    val supersetNotes = current?.notes.orEmpty()
    val notePages = listOfNotNull(if (visibleNote(notes)) "notes" else null, if (visibleNote(supersetNotes)) "superset-notes" else null)
    val homePager = rememberPagerState(initialPage = if (initial == "food") 1 else 0) { 2 }
    val workoutPager = rememberPagerState(initialPage = if (initial == "actions") 1 else 0) { 2 + notePages.size }
    var previousSession by remember { mutableStateOf<String?>(null) }
    var recordingAsked by rememberSaveable { mutableStateOf<String?>(null) }
    var now by remember { mutableLongStateOf(System.currentTimeMillis()) }
    val tint = current?.exercise?.optLong("wearableColor")?.takeIf { it != 0L }?.let { Color(it.toInt()) } ?: MaterialTheme.colorScheme.primary
    val navigate: (String, JSONObject?) -> Unit = { screen, value -> routes.add(WatchRoute(screen, value)) }
    val back: () -> Unit = { if (routes.isNotEmpty()) routes.removeAt(routes.lastIndex) }

    LaunchedEffect(initial) {
        if (initial !in listOf("home", "routines", "food", "workout", "actions")) routes.add(WatchRoute(initial))
    }
    LaunchedEffect(resumed) {
        if (resumed) while (true) { now = System.currentTimeMillis(); delay(1000) }
    }
    LaunchedEffect(resumed) { if (resumed) while (true) { model.refreshConnection(); model.act { flush() }; delay(5000) } }
    LaunchedEffect(active?.text("id")) {
        val id = active?.text("id")
        if (id != null && previousSession != id) {
            if (!preview) { routes.clear(); workoutPager.scrollToPage(0) }
            if (!preview && recordingAsked != id) { recordingAsked = id; record() }
        } else if (id == null && previousSession != null) {
            val summary = state.get("summary")?.takeIf { it.text("ownerScope") == state.owner && it.text("id") == previousSession }
            if (!preview && summary != null) { routes.clear(); routes.add(WatchRoute("summary", summary)) }
        }
        previousSession = id
    }
    LaunchedEffect(current?.exercise?.text("id")) {
        if (!preview) {
            if (workoutPager.currentPage >= 2) workoutPager.scrollToPage(0)
            routes.removeAll { it.screen == "edit-set" }
        }
    }
    LaunchedEffect(current?.set?.text("id")) {
        routes.removeAll { it.screen == "edit-set" && it.value != null && it.value.text("id") != current?.set?.text("id") }
    }
    BackHandler(routes.isNotEmpty() || (if (active != null) workoutPager.currentPage else homePager.currentPage) != 0) {
        if (routes.isNotEmpty()) back() else scope.launch { (if (active != null) workoutPager else homePager).animateScrollToPage(0) }
    }
    AppScaffold {
        val root: @Composable () -> Unit = {
            val pager = if (active != null) workoutPager else homePager
            HorizontalPagerScaffold(pagerState = pager) {
                HorizontalPager(state = pager, modifier = Modifier.fillMaxSize()) { page ->
                    if (active == null) {
                        if (page == 0) TrainingHome(state, error, navigate)
                        else FoodHome(state, navigate)
                    } else when (page) {
                        0 -> WorkoutMetrics(state, now, tint, preview, busy,
                            onEdit = { current?.set?.let { navigate("edit-set", it) } },
                            onCommand = { method -> model.act { perform(method) } },
                            onRecordingError = { navigate("recording", null) })
                        1 -> WorkoutActions(state, error, tint, preview || connected, model, navigate)
                        else -> {
                            val kind = notePages.getOrNull(page - 2)
                            NotesScreen(kind == "superset-notes", current?.exercise?.optString("name").orEmpty(), if (kind == "superset-notes") supersetNotes else notes, tint)
                        }
                    }
                }
            }
        }
        if (routes.isEmpty()) root() else {
            val route = routes.last()
            key(route) {
                BasicSwipeToDismissBox(onDismissed = back) { background ->
                    if (background) Box(Modifier.fillMaxSize().background(Color.Black))
                    else when (route.screen) {
                        "folder" -> RoutineFolder(state, route.value, navigate)
                        "routine" -> RoutineDetail(route.value ?: if (preview) state.catalog?.objects("routines")?.firstOrNull() else null, state.active != null, busy, model) {
                            routes.clear()
                            scope.launch { workoutPager.scrollToPage(0) }
                        }
                        "queue" -> TrainingQueue(state)
                        "calories" -> CalorieDetails(state)
                        "nutrients" -> NutrientDetails(state)
                        "water" -> WaterDetails(state, model, navigate)
                        "custom-water" -> CustomWater(state, model, back)
                        "diary" -> FoodDiary(state, navigate)
                        "category" -> CategoryDetails(route.value)
                        "edit-set" -> SetEditorScreen(route.value ?: current?.set, model, tint, back)
                        "summary" -> WorkoutSummary(state, route.value ?: state.get("summary"), back)
                        "discard" -> DiscardConfirmation(model, tint, back)
                        "recording" -> RecordingDetails(state, error, back)
                        "notes" -> NotesScreen(false, current?.exercise?.optString("name").orEmpty(), notes, tint)
                        "superset-notes" -> NotesScreen(true, "", supersetNotes, tint)
                        "actions" -> WorkoutActions(state, error, tint, preview || connected, model, navigate)
                        else -> TrainingHome(state, error, navigate)
                    }
                }
            }
        }
    }
}
