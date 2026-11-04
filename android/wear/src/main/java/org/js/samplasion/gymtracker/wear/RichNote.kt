package org.js.samplasion.gymtracker.wear

import androidx.compose.runtime.Composable
import androidx.compose.foundation.text.ClickableText
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.*
import androidx.compose.ui.text.font.*
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.sp
import org.json.JSONArray
import org.json.JSONObject

@Composable fun RichNote(source: String, tint: Color) {
    val uri = LocalUriHandler.current
    val text = noteText(source, tint)
    if (text.isNotBlank()) ClickableText(text, style = TextStyle(color = Color.White, fontSize = 14.sp)) { offset ->
        text.getStringAnnotations("URL", offset, offset).firstOrNull()?.let { runCatching { uri.openUri(it.item) } }
    }
}
/** Quill stores block styles on the newline; run styles stay on inserted text. */
internal fun noteText(source: String, tint: Color): AnnotatedString {
    val ops = runCatching { JSONArray(source) }.getOrNull() ?: runCatching { JSONObject(source).getJSONArray("ops") }.getOrNull()
    if (ops == null) return AnnotatedString(source)
    data class Run(val text: String, val attrs: JSONObject)
    val blocks = mutableListOf<Pair<List<Run>, JSONObject>>()
    var runs = mutableListOf<Run>()
    for (i in 0 until ops.length()) {
        val operation = ops.optJSONObject(i) ?: return AnnotatedString(source)
        val attrs = operation.optJSONObject("attributes") ?: JSONObject()
        val embed = operation.optJSONObject("insert")
        val insert = if (embed != null) embed.optString("alt", embed.optString("formula", "□")) else operation.optString("insert")
        insert.split('\n').forEachIndexed { index, part ->
            if (index > 0) { blocks.add(runs.toList() to attrs); runs = mutableListOf() }
            if (part.isNotEmpty()) runs.add(Run(part, attrs))
        }
    }
    if (runs.isNotEmpty()) blocks.add(runs to JSONObject())
    return buildAnnotatedString {
        val counters = mutableMapOf<Int, Int>()
        blocks.forEachIndexed { index, (runs, block) ->
            if (index > 0) append("\n")
            val depth = block.optInt("indent").coerceIn(0, 8)
            val list = block.optString("list")
            if (list.isNotEmpty()) {
                append("  ".repeat(depth))
                append(when (list) {
                    "ordered" -> { val number = (counters[depth] ?: 0) + 1; counters[depth] = number; "$number. " }
                    "checked" -> "☑ "; "unchecked" -> "☐ "; else -> "• "
                })
            } else counters.clear()
            if (block.has("blockquote")) append("│ ")
            for (run in runs) {
                val attrs = run.attrs
                val from = length
                append(run.text)
                fun color(key: String) = runCatching { Color(android.graphics.Color.parseColor(attrs.optString(key))) }.getOrNull() ?: Color.Unspecified
                addStyle(SpanStyle(
                    color = if (attrs.has("highlighted")) Color.Black else color("color"),
                    background = if (attrs.has("highlighted")) tint else color("background"),
                    fontWeight = if (attrs.optBoolean("bold") || block.optInt("header") > 0) FontWeight.Bold else null,
                    fontStyle = if (attrs.optBoolean("italic")) FontStyle.Italic else null,
                    fontFamily = when { attrs.optBoolean("code") || block.has("code-block") || attrs.optString("font") == "monospace" -> FontFamily.Monospace; attrs.optString("font") == "serif" -> FontFamily.Serif; else -> null },
                    textDecoration = TextDecoration.combine(buildList { if (attrs.optBoolean("strike")) add(TextDecoration.LineThrough); if (attrs.optBoolean("underline")) add(TextDecoration.Underline) }),
                    fontSize = when { block.optInt("header") == 1 -> 22.sp; block.optInt("header") > 1 -> 18.sp; attrs.optString("size") == "small" -> 12.sp; attrs.optString("size") in listOf("large", "huge") -> 20.sp; else -> 14.sp }
                ), from, length)
                val link = attrs.optString("link")
                if (link.substringBefore(':').lowercase() in listOf("https", "http", "mailto", "tel")) addStringAnnotation("URL", link, from, length)
            }
        }
    }
}
