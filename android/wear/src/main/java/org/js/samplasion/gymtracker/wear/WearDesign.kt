package org.js.samplasion.gymtracker.wear

import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowRight
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.runtime.remember
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.distinctUntilChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.paint
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.painter.ColorPainter
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.lazy.*
import androidx.wear.compose.material3.*
import androidx.wear.compose.material3.lazy.*

internal val Orange = Color(0xFFFFB55B)
internal val Cyan = Color(0xFF76D8F0)
internal val Purple = Color(0xFFD0ACFF)
internal val Pink = Color(0xFFFFA9CB)
internal val Red = Color(0xFFFF9098)
internal val Muted = Color(0xFFB8BEC7)

@Composable internal fun GymBroTheme(content: @Composable () -> Unit) {
    val fallback = ColorScheme(primary = Color(0xFFA8CAFF), primaryDim = Color(0xFF78A9EE),
        primaryContainer = Color(0xFF123967), onPrimary = Color(0xFF062449),
        onPrimaryContainer = Color(0xFFD9E8FF), background = Color.Black,
        surfaceContainerLow = Color(0xFF11151C), surfaceContainer = Color(0xFF191E27),
        surfaceContainerHigh = Color(0xFF232A35))
    MaterialTheme(colorScheme = dynamicColorScheme(LocalContext.current) ?: fallback, content = content)
}

/** Native M3 scaffold, rotary scrolling and morphing cards at the round bezel. */
@Composable internal fun WearList(title: String, content: TransformingLazyColumnScope.() -> Unit) {
    val state = rememberTransformingLazyColumnState()
    var lastHeight by remember(title) { mutableIntStateOf(0) }
    LaunchedEffect(state) {
        snapshotFlow { state.layoutInfo.visibleItems.lastOrNull { it.index == state.layoutInfo.totalItemsCount - 1 }?.measuredHeight }
            .filterNotNull().distinctUntilChanged().collect { lastHeight = it }
    }
    BoxWithConstraints(Modifier.fillMaxSize()) {
        val lastHeightDp = with(LocalDensity.current) { lastHeight.toDp() }
        // Let the last actual item reach the round screen's readable center.
        // This space belongs to the list, never to the card's content padding.
        val endPadding = ((maxHeight - lastHeightDp) / 2).coerceAtLeast(maxHeight * 0.2f)
        ScreenScaffold(scrollState = state, contentPadding = PaddingValues(start = 12.dp, end = 12.dp, top = 24.dp, bottom = endPadding)) { padding ->
            TransformingLazyColumn(state = state, modifier = Modifier.fillMaxSize().testTag("wear-list-$title"), contentPadding = padding,
                verticalArrangement = Arrangement.spacedBy(8.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                item {
                    ListHeader(modifier = Modifier.fillMaxWidth(), contentPadding = PaddingValues(vertical = 6.dp)) {
                        Text(title, style = MaterialTheme.typography.titleMedium)
                    }
                }
                content()
            }
        }
    }
}

internal fun TransformingLazyColumnScope.surface(key: Any? = null,
    content: @Composable (Modifier, SurfaceTransformation) -> Unit) {
    item(key = key) {
        val spec = rememberTransformationSpec()
        content(Modifier.fillMaxWidth().transformedHeight(this, spec), SurfaceTransformation(spec))
    }
}

@Composable internal fun WatchCard(modifier: Modifier = Modifier, transformation: SurfaceTransformation? = null,
    tint: Color = MaterialTheme.colorScheme.primary, onClick: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit) {
    val shape = RoundedCornerShape(24.dp)
    val container = lerp(MaterialTheme.colorScheme.surfaceContainerLow, tint, 0.075f)
    val border = BorderStroke(1.dp, tint.copy(alpha = 0.13f))
    if (onClick != null) {
        Card(onClick = onClick, modifier = modifier, transformation = transformation, shape = shape,
            colors = CardDefaults.cardColors(containerColor = container), border = border,
            contentPadding = PaddingValues(12.dp)) {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp), content = content)
        }
    } else {
        // Informational surfaces have no fake click/disabled-button semantics.
        val painter = remember(container, transformation) { transformation?.createContainerPainter(ColorPainter(container), shape, border) }
        Box(Modifier.graphicsLayer { transformation?.let { with(it) { applyContainerTransformation() } } }.then(modifier)
            .then(if (painter != null) Modifier.paint(painter, sizeToIntrinsics = false)
                else Modifier.clip(shape).background(container).border(border, shape))) {
            Column(Modifier.fillMaxWidth().graphicsLayer { transformation?.let { with(it) { applyContentTransformation() } } }.padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp), content = content)
        }
    }
}

@Composable internal fun CardHeading(title: String, icon: ImageVector, tint: Color, disclosure: Boolean = false) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        Icon(icon, null, Modifier.size(17.dp), tint = tint)
        Text(title, Modifier.weight(1f), color = tint, style = MaterialTheme.typography.labelMedium)
        if (disclosure) Icon(androidx.compose.material.icons.Icons.AutoMirrored.Rounded.KeyboardArrowRight, null, Modifier.size(16.dp), tint = Muted)
    }
}

@Composable internal fun PrimaryAction(label: String, icon: ImageVector, tint: Color = MaterialTheme.colorScheme.primary,
    modifier: Modifier = Modifier, transformation: SurfaceTransformation? = null, enabled: Boolean = true,
    onClick: () -> Unit) {
    Button(onClick = onClick, enabled = enabled, modifier = modifier.fillMaxWidth(), transformation = transformation,
        colors = ButtonDefaults.buttonColors(containerColor = tint, contentColor = Color(0xFF10151C), iconColor = Color(0xFF10151C)),
        icon = { Icon(icon, null, Modifier.size(20.dp).testTag("action-icon-$label")) }, label = { Text(label) })
}

@Composable internal fun TonalAction(label: String, icon: ImageVector, tint: Color = MaterialTheme.colorScheme.primary,
    modifier: Modifier = Modifier, transformation: SurfaceTransformation? = null, enabled: Boolean = true,
    onClick: () -> Unit) {
    FilledTonalButton(onClick = onClick, enabled = enabled, modifier = modifier.fillMaxWidth(), transformation = transformation,
        colors = ButtonDefaults.filledTonalButtonColors(containerColor = tint.copy(alpha = 0.13f), contentColor = tint, iconColor = tint),
        icon = { Icon(icon, null, Modifier.size(20.dp).testTag("action-icon-$label")) }, label = { Text(label) })
}

@Composable internal fun Progress(value: Double, goal: Double, tint: Color) {
    LinearProgressIndicator(progress = { (value / goal.coerceAtLeast(1.0)).toFloat().coerceIn(0f, 1f) },
        modifier = Modifier.fillMaxWidth().height(5.dp), colors = ProgressIndicatorDefaults.colors(indicatorColor = tint, trackColor = tint.copy(alpha = 0.12f)))
}

@Composable internal fun ValueRow(label: String, value: String, color: Color = Muted) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(label, Modifier.weight(1f), style = MaterialTheme.typography.bodySmall, color = color)
        Spacer(Modifier.width(4.dp))
        Text(value, style = MaterialTheme.typography.bodySmall.copy(fontFeatureSettings = "tnum"), color = color)
    }
}
