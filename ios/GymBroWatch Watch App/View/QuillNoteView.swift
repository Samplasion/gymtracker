import SwiftUI

/// Native rendering of Quill inline/block styles plus Gym Bro's `highlighted`
/// extension (lib/data/rich_text.dart). Unknown attributes leave text readable.
struct QuillNoteView: View {
    let document: QuillNoteDocument
    let accent: Color

    init(_ source: String, accent: Color = .accentColor) { document = QuillNoteDocument(source); self.accent = accent }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(document.blocks.indices, id: \.self) { index in
                block(document.blocks[index])
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func block(_ block: QuillNoteDocument.Block) -> some View {
        let alignment = block.attributes["align"] as? String ?? "left"
        let quote = block.attributes["blockquote"] as? Bool == true
        let code = block.attributes["code-block"] != nil && !(block.attributes["code-block"] is NSNull) && block.attributes["code-block"] as? Bool != false
        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            if let marker = marker(block) { Text(marker).font(.body).foregroundStyle(.secondary) }
            Text(attributed(block))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: alignment == "center" ? .center : alignment == "right" ? .trailing : .leading)
                .multilineTextAlignment(alignment == "center" ? .center : alignment == "right" ? .trailing : .leading)
        }
        .padding(.leading, CGFloat(min(3, block.indent) * 8) + (quote ? 8 : 0))
        .padding(code ? 6 : 0)
        .background(code ? Color.white.opacity(0.07) : .clear, in: RoundedRectangle(cornerRadius: 6))
        .overlay(alignment: .leading) { if quote { Capsule().fill(.secondary).frame(width: 2) } }
        .accessibilityElement(children: .combine)
        .environment(\.layoutDirection, block.attributes["direction"] as? String == "rtl" ? .rightToLeft : .leftToRight)
    }

    private func marker(_ block: QuillNoteDocument.Block) -> String? {
        switch block.attributes["list"] as? String {
        case "ordered": return "\(block.number ?? 1)."
        case "bullet": return "•"
        case "checked": return "☑"
        case "unchecked": return "☐"
        default: return nil
        }
    }

    private func attributed(_ block: QuillNoteDocument.Block) -> AttributedString {
        var result = AttributedString()
        for run in block.runs {
            let text: String
            if run.text == "\u{FFFC}" {
                text = trainingText("Contenuto allegato", "Attached content")
            } else { text = run.text }
            var span = AttributedString(text)
            let attributes = run.attributes
            var font: Font
            let heading = (block.attributes["header"] as? NSNumber)?.intValue ?? 0
            if block.attributes["code-block"] != nil && block.attributes["code-block"] as? Bool != false || attributes["code"] as? Bool == true || attributes["font"] as? String == "monospace" {
                font = .system(.body, design: .monospaced)
            } else if heading == 1 { font = .title2.bold() }
            else if heading == 2 { font = .title3.bold() }
            else if heading > 2 { font = .headline }
            else {
                switch attributes["size"] as? String {
                case "small": font = .caption
                case "large": font = .title3
                case "huge": font = .title2
                default: font = attributes["font"] as? String == "serif" ? .system(.body, design: .serif) : .body
                }
            }
            if attributes["bold"] as? Bool == true { font = font.bold() }
            if attributes["italic"] as? Bool == true { font = font.italic() }
            span.font = font
            if attributes["underline"] as? Bool == true { span.underlineStyle = .single }
            if attributes["strike"] as? Bool == true { span.strikethroughStyle = .single }
            if let color = color(attributes["color"]) { span.foregroundColor = color }
            if let background = color(attributes["background"]) { span.backgroundColor = background }
            if run.highlighted {
                // Flutter's extension uses primary/onPrimary; the Watch uses the
                // same accent fill with a contrasting foreground.
                span.backgroundColor = accent
                span.foregroundColor = .black
            }
            if let value = attributes["link"] as? String, let url = URL(string: value),
               ["https", "http", "mailto", "tel"].contains(url.scheme?.lowercased() ?? "") {
                span.link = url
                if !run.highlighted { span.foregroundColor = accent }
            }
            result.append(span)
        }
        return result.characters.isEmpty ? AttributedString(" ") : result
    }

    private func color(_ value: Any?) -> Color? {
        guard let string = value as? String else { return nil }
        if string.hasPrefix("#"), [7, 9].contains(string.count), let hex = UInt64(string.dropFirst(), radix: 16) {
            let rgb = string.count == 9 ? hex >> 8 : hex
            return Color(red: Double((rgb >> 16) & 255) / 255, green: Double((rgb >> 8) & 255) / 255, blue: Double(rgb & 255) / 255,
                         opacity: string.count == 9 ? Double(hex & 255) / 255 : 1)
        }
        switch string.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "white": return .white
        case "black": return .black
        case "grey", "gray": return .gray
        default: return nil
        }
    }
}
