import Foundation

/// Read-only Quill Delta adapter. Attributes are kept verbatim so app-specific
/// extensions can be rendered without changing the stored/synchronized document.
struct QuillNoteDocument {
    struct Run {
        let text: String
        let attributes: [String: Any]
        let embed: [String: Any]?
        var highlighted: Bool { attributes["highlighted"] != nil && !(attributes["highlighted"] is NSNull) }
    }
    struct Block {
        var runs: [Run]
        let attributes: [String: Any]
        var number: Int?
        var text: String { runs.map(\.text).joined() }
        var indent: Int { max(0, min(8, (attributes["indent"] as? NSNumber)?.intValue ?? 0)) }
    }
    let blocks: [Block]
    var plainText: String { blocks.map(\.text).joined(separator: "\n") }
    var isEmpty: Bool { plainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    init(_ source: String) {
        let raw = source.trimmingCharacters(in: .whitespacesAndNewlines)
        let json = raw.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0) }
        let operations = (json as? [[String: Any]]) ?? (json as? [String: Any])?["ops"] as? [[String: Any]]
        guard let operations, operations.allSatisfy({ $0["insert"] is String || $0["insert"] is [String: Any] }) else {
            blocks = raw.isEmpty ? [] : raw.components(separatedBy: "\n").map {
                Block(runs: [Run(text: $0, attributes: [:], embed: nil)], attributes: [:])
            }
            return
        }
        var result: [Block] = []
        var runs: [Run] = []
        for operation in operations {
            let attributes = operation["attributes"] as? [String: Any] ?? [:]
            if let inserted = operation["insert"] as? String {
                let lines = inserted.components(separatedBy: "\n")
                for (index, text) in lines.enumerated() {
                    if !text.isEmpty { runs.append(Run(text: text, attributes: attributes, embed: nil)) }
                    if index < lines.count - 1 {
                        result.append(Block(runs: runs, attributes: attributes))
                        runs = []
                    }
                }
            } else if let embed = operation["insert"] as? [String: Any] {
                // Embeds are not offered by the Flutter editor. Preserve a useful
                // textual alternative for imported/future content instead of JSON.
                let alternative = embed["alt"] as? String ?? embed["formula"] as? String ?? "\u{FFFC}"
                runs.append(Run(text: alternative, attributes: attributes, embed: embed))
            }
        }
        if !runs.isEmpty { result.append(Block(runs: runs, attributes: [:])) }
        var counters: [Int: Int] = [:]
        for index in result.indices {
            let depth = result[index].indent
            let list = result[index].attributes["list"] as? String
            if list == "ordered" {
                counters = counters.filter { $0.key <= depth }
                counters[depth] = (counters[depth] ?? 0) + 1
                result[index].number = counters[depth]
            } else if list == nil { counters.removeAll() }
            else { counters.removeValue(forKey: depth) }
        }
        blocks = result
    }
}
