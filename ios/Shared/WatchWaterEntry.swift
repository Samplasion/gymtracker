import Foundation

/// Stable identity and original timestamp survive every transport retry.
struct WatchWaterEntry: Codable, Equatable, Identifiable {
    let id: String
    let milliliters: Double
    let timeMilliseconds: Int64
    let ownerScope: String

    var date: Date { Date(timeIntervalSince1970: Double(timeMilliseconds) / 1000) }
    var isValid: Bool {
        UUID(uuidString: id) != nil && milliliters.isFinite && milliliters > 0 &&
        timeMilliseconds > 0 && !ownerScope.isEmpty
    }
    var message: [String: Any] {
        ["method": "addWater", "id": id, "milliliters": milliliters,
         "timeMilliseconds": timeMilliseconds, "ownerScope": ownerScope]
    }
    init(id: String = UUID().uuidString, milliliters: Double, timeMilliseconds: Int64, ownerScope: String) {
        self.id = id
        self.milliliters = milliliters
        self.timeMilliseconds = timeMilliseconds
        self.ownerScope = ownerScope
    }
    init?(message: [String: Any]) {
        guard message["method"] as? String == "addWater",
              let id = message["id"] as? String,
              let amount = message["milliliters"] as? Double,
              let time = message["timeMilliseconds"] as? NSNumber,
              let scope = message["ownerScope"] as? String else { return nil }
        self.init(id: id, milliliters: amount, timeMilliseconds: time.int64Value, ownerScope: scope)
        guard isValid else { return nil }
    }
}

/// Both ends keep their own durable queue until the next end confirms storage.
final class WatchWaterQueue {
    private let defaults: UserDefaults
    private let key: String
    private(set) var entries: [WatchWaterEntry]

    init(defaults: UserDefaults, key: String) {
        self.defaults = defaults
        self.key = key
        entries = defaults.data(forKey: key).flatMap { try? JSONDecoder().decode([WatchWaterEntry].self, from: $0) } ?? []
    }
    func insert(_ entry: WatchWaterEntry) {
        guard entry.isValid, !entries.contains(where: { $0.id == entry.id && $0.ownerScope == entry.ownerScope }) else { return }
        entries.append(entry)
        persist()
    }
    func acknowledge(ids: Set<String>, ownerScope: String) {
        entries.removeAll { $0.ownerScope == ownerScope && ids.contains($0.id) }
        persist()
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(entries) { defaults.set(data, forKey: key) }
    }
}
