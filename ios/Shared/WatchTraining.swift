import Foundation

/// Versioned JSON documents deliberately preserve fields the Watch cannot edit.
/// Durations use Dart microseconds; wall-clock timestamps use milliseconds.
enum WatchTraining {
    /// Workout runtime is independent of the optional standard stopwatch.
    /// Dates are milliseconds; the app's persisted Duration uses microseconds.
    static func elapsedDuration(_ document: [String: Any], endingAt end: Int64) -> Int64 {
        let start = (document["time"] as? NSNumber)?.int64Value ?? end
        return max(0, end - start) * 1000
    }
    static func immediateDocument(_ document: [String: Any], limit: Int = 35_000) -> [String: Any]? {
        guard let data = try? JSONSerialization.data(withJSONObject: propertyList(document)) else { return nil }
        if data.count <= limit { return document }
        // Discard has no results to import. A small terminal envelope can close
        // the phone ongoing without waiting for a large background file.
        guard document["status"] as? String == "discarded" else { return nil }
        var terminal: [String: Any] = ["exercises": []]
        for key in ["version", "id", "ownerScope", "status", "time", "end", "sequence", "modified", "transferID"] {
            terminal[key] = document[key]
        }
        return terminal
    }
    static func matchesOutgoing(_ sent: [String: Any], active: [String: Any]) -> Bool {
        for key in ["id", "ownerScope", "sequence", "modified", "cursor", "epoch"] {
            let a = sent[key] ?? NSNull(), b = active[key] ?? NSNull()
            if !NSDictionary(dictionary: ["value": a]).isEqual(to: ["value": b]) { return false }
        }
        return NSArray(array: propertyList(sent)["exercises"] as? [Any] ?? [])
            .isEqual(to: propertyList(active)["exercises"] as? [Any] ?? [])
    }
    static func setLabel(forSet id: String, in document: [String: Any], italian: Bool) -> String {
        guard let exercise = exercises(document).first(where: {
            ($0["sets"] as? [[String: Any]] ?? []).contains { $0["id"] as? String == id }
        }) else { return "" }
        let sets = exercise["sets"] as? [[String: Any]] ?? []
        guard let current = sets.first(where: { $0["id"] as? String == id }) else { return "" }
        switch current["kind"] as? String ?? "normal" {
        case "warmUp": return italian ? "R" : "W"
        case "drop": return "D"
        case "failure": return italian ? "C" : "F"
        case "failureStripping": return "S"
        default: return String((sets.filter { ($0["kind"] as? String ?? "normal") == "normal" }.firstIndex { $0["id"] as? String == id } ?? 0) + 1)
        }
    }
    static func acceptsSnapshot(_ incoming: [String: Any], after current: [String: Any]?, acknowledged: Bool = false) -> Bool {
        guard let current else { return true }
        let nextTime = (incoming["modified"] as? NSNumber)?.int64Value ?? 0
        let previousTime = (current["modified"] as? NSNumber)?.int64Value ?? 0
        if nextTime != previousTime { return nextTime > previousTime }
        if acknowledged { return true }
        // A mirrored acknowledged command keeps the phone timestamp. An older
        // equal-timestamp full document must not undo its cursor or set results.
        return incoming["cursor"] as? String == current["cursor"] as? String &&
            NSArray(array: propertyList(incoming)["exercises"] as? [Any] ?? []).isEqual(to: propertyList(current)["exercises"] as? [Any] ?? [])
    }
    static let version = 1
    /// JSON null is invalid in UserDefaults and WatchConnectivity property lists.
    /// Optional dictionary fields use absence on this boundary; the durable JSON
    /// archive keeps the original document, including its null values.
    static func propertyList(_ document: [String: Any]) -> [String: Any] {
        func value(_ input: Any) -> Any? {
            if input is NSNull { return nil }
            if let dictionary = input as? [String: Any] {
                return dictionary.compactMapValues { value($0) }
            }
            if let array = input as? [Any] { return array.compactMap { value($0) } }
            return input
        }
        return document.compactMapValues { value($0) }
    }
    static func copy(_ value: [String: Any]) throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: JSONSerialization.data(withJSONObject: value)) as! [String: Any]
    }
    static func milliseconds() -> Int64 { Int64(Date().timeIntervalSince1970 * 1000) }
    static func exercises(_ document: [String: Any]) -> [[String: Any]] {
        (document["exercises"] as? [[String: Any]] ?? []).flatMap {
            $0["type"] as? String == "superset" ? ($0["exercises"] as? [[String: Any]] ?? []) : [$0]
        }
    }
    static func orderedSets(_ document: [String: Any]) -> [(exercise: String, set: String, rest: Double)] {
        var result: [(String, String, Double)] = []
        for group in document["exercises"] as? [[String: Any]] ?? [] {
            let superset = group["type"] as? String == "superset"
            let children = superset ? group["exercises"] as? [[String: Any]] ?? [] : [group]
            let count = children.map { ($0["sets"] as? [[String: Any]] ?? []).count }.max() ?? 0
            for index in 0..<count {
                for (childIndex, exercise) in children.enumerated() {
                    let sets = exercise["sets"] as? [[String: Any]] ?? []
                    guard index < sets.count, let id = exercise["id"] as? String, let setID = sets[index]["id"] as? String else { continue }
                    let stripping = index + 1 < sets.count && sets[index + 1]["kind"] as? String == "failureStripping"
                    let rest = stripping || (superset && childIndex != children.count - 1) ? 0 : (group["restTime"] as? Double ?? 0) / 1_000_000
                    result.append((id, setID, rest))
                }
            }
        }
        return result
    }
    static func notes(forSet id: String?, in document: [String: Any]) -> (exercise: String, superset: String) {
        guard let id else { return ("", "") }
        for group in document["exercises"] as? [[String: Any]] ?? [] {
            let superset = group["type"] as? String == "superset"
            let children = superset ? group["exercises"] as? [[String: Any]] ?? [] : [group]
            for exercise in children where (exercise["sets"] as? [[String: Any]] ?? []).contains(where: { $0["id"] as? String == id }) {
                return ((exercise["notes"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                        superset ? (group["notes"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines) : "")
            }
        }
        return ("", "")
    }
    static func set(_ id: String, in document: [String: Any]) -> [String: Any]? {
        exercises(document).flatMap { $0["sets"] as? [[String: Any]] ?? [] }.first { $0["id"] as? String == id }
    }
    static func replaceSet(_ replacement: [String: Any], in document: inout [String: Any]) {
        var groups = document["exercises"] as? [[String: Any]] ?? []
        func update(_ exercise: inout [String: Any]) {
            var sets = exercise["sets"] as? [[String: Any]] ?? []
            if let i = sets.firstIndex(where: { $0["id"] as? String == replacement["id"] as? String }) { sets[i] = replacement }
            exercise["sets"] = sets
        }
        for i in groups.indices {
            if groups[i]["type"] as? String == "superset" {
                var children = groups[i]["exercises"] as? [[String: Any]] ?? []
                for j in children.indices { update(&children[j]) }
                groups[i]["exercises"] = children
            } else { update(&groups[i]) }
        }
        document["exercises"] = groups
    }
    static func start(routine: [String: Any], owner: String, weight: String, distance: String) throws -> [String: Any] {
        var result = try copy(routine)
        let id = UUID().uuidString
        result["parentID"] = routine["id"]
        result["id"] = id
        result["nativeWorkoutId"] = id
        result["ownerScope"] = owner
        result["version"] = version
        result["time"] = milliseconds()
        result["status"] = "active"
        result["weightUnit"] = weight
        result["distanceUnit"] = distance
        result.removeValue(forKey: "folder")
        var groups = result["exercises"] as? [[String: Any]] ?? []
        func clone(_ exercise: inout [String: Any]) {
            exercise["supersedesID"] = exercise["id"]
            exercise["id"] = UUID().uuidString
            exercise["workoutID"] = id
            exercise["rpe"] = NSNull()
            exercise["sets"] = (exercise["sets"] as? [[String: Any]] ?? []).map { source in
                var set = source
                set["id"] = UUID().uuidString
                set["done"] = false
                if ["failure", "failureStripping"].contains(set["kind"] as? String ?? "") { set["reps"] = 0 }
                return set
            }
        }
        for i in groups.indices {
            if groups[i]["type"] as? String == "superset" {
                groups[i]["supersedesID"] = groups[i]["id"]
                groups[i]["id"] = UUID().uuidString
                groups[i]["workoutID"] = id
                var children = groups[i]["exercises"] as? [[String: Any]] ?? []
                for j in children.indices { clone(&children[j]); children[j]["supersetID"] = groups[i]["id"] }
                groups[i]["exercises"] = children
            } else { clone(&groups[i]) }
        }
        result["exercises"] = groups
        result["cursor"] = orderedSets(result).first?.set
        result["stamps"] = [String: Any]()
        return result
    }
    static func perform(_ method: String, values: [String: Any], document: inout [String: Any], now: Int64 = milliseconds()) {
        guard document["status"] as? String == "active" else { return }
        let ordered = orderedSets(document)
        let cursor = document["cursor"] as? String
        guard let position = ordered.firstIndex(where: { $0.set == cursor }), var current = set(ordered[position].set, in: document) else { return }
        if method == "moveWorkoutCursorNext" || method == "moveWorkoutCursorPrevious" {
            let next = position + (method == "moveWorkoutCursorNext" ? 1 : -1)
            if ordered.indices.contains(next) { document["cursor"] = ordered[next].set }
            document["sequence"] = (document["sequence"] as? Int ?? 0) + 1
        } else {
            if method == "markThisSetAsDone" {
                current["done"] = true
                let rest = ordered[position].rest
                if rest > 0 { document["restStart"] = now; document["restEnd"] = now + Int64(rest * 1000) }
            } else if method == "updateSetParameters" {
                for key in ["weight", "reps", "distance"] { if let value = values[key] { current[key] = value } }
                if let seconds = values["time"] as? Double { current["time"] = Int64(seconds * 1_000_000) }
            } else { return }
            replaceSet(current, in: &document)
            var stamps = document["stamps"] as? [String: Any] ?? [:]
            let sequence = (document["sequence"] as? Int ?? 0) + 1
            document["sequence"] = sequence
            stamps[ordered[position].set] = ["time": now, "device": "watch", "sequence": sequence]
            document["stamps"] = stamps
            if method == "markThisSetAsDone" {
                document["cursor"] = (Array(ordered.dropFirst(position + 1)) + ordered).first { set($0.set, in: document)?["done"] as? Bool != true }?.set ?? NSNull()
            }
        }
        document["modified"] = now
    }
}

/// One atomic archive keeps catalog, active session and terminal outbox together.
/// Failed writes are surfaced; callers must not publish an unpersisted edit.
final class WatchTrainingArchive {
    private let url: URL
    private(set) var value: [String: Any]
    init(url: URL? = nil) throws {
        if let url { self.url = url }
        else {
            let base = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            self.url = base.appendingPathComponent("watch-training-v1.json")
        }
        if FileManager.default.fileExists(atPath: self.url.path) {
            guard let stored = try JSONSerialization.jsonObject(with: Data(contentsOf: self.url)) as? [String: Any] else {
                throw CocoaError(.fileReadCorruptFile)
            }
            value = stored
        } else { value = [:] }
    }
    func save(_ next: [String: Any]) throws {
        if NSDictionary(dictionary: value).isEqual(to: next) { return }
        let data = try JSONSerialization.data(withJSONObject: next, options: [.sortedKeys])
        try data.write(to: url, options: .atomic)
        value = next
    }
}

/// Keeps a rest deadline until it has been notified, including a clear update
/// delivered at the deadline before the sleeping task gets CPU time.
struct WatchRestHaptic {
    private(set) var deadline: Date?
    private var delivered: Date?
    mutating func update(_ next: Date?, now: Date, running: Bool) -> Bool {
        let notify = due(now: now, running: running)
        if !running { deadline = nil; delivered = nil }
        else if next != deadline { deadline = next }
        return notify
    }
    mutating func due(now: Date, running: Bool) -> Bool {
        guard running, let deadline, deadline <= now, delivered != deadline else { return false }
        delivered = deadline
        return true
    }
}
