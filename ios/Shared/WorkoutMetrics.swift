import Foundation

/// Calories belong to a sensor segment, not to a transport connection.
/// Each device owns its segments and publishes their complete cumulative history.
struct WorkoutSegmentMetrics: Codable, Equatable {
    enum State: String, Codable { case prepared, running, paused, ended }
    let id: String
    let device: String
    var revision: Int64 = 0
    var energy: Double = 0
    var state: State = .prepared
    var heartRate: Double?
    var heartRateDate: Date?
    var heartRateInvalidatedAt: Date?
}

struct WorkoutMetricsPacket: Codable, Equatable {
    var version = 3
    let workoutID: String
    let device: String
    let revision: Int64
    let activeGeneration: String?
    let segments: [WorkoutSegmentMetrics]

    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
        return dictionary
    }
    static func decode(_ dictionary: [String: Any]) -> Self? {
        guard JSONSerialization.isValidJSONObject(dictionary),
              let data = try? JSONSerialization.data(withJSONObject: dictionary),
              let packet = try? JSONDecoder().decode(Self.self, from: data), packet.version == 3 else { return nil }
        return packet
    }
}

struct WorkoutMetricsLedger: Codable, Equatable {
    let workoutID: String
    private(set) var segments: [String: WorkoutSegmentMetrics] = [:]
    private(set) var revisions: [String: Int64] = [:]
    private(set) var activeGenerations: [String: String] = [:]

    var totalEnergy: Double { segments.values.reduce(0) { $0 + $1.energy } }

    /// Only used to migrate the old phone -> Watch offset, once, with a common
    /// identity on both devices so exchanging it never counts the prefix twice.
    mutating func seedLegacyOffset(_ energy: Double) {
        guard energy.isFinite, energy > 0, segments["legacy-prefix"] == nil else { return }
        segments["legacy-prefix"] = .init(id: "legacy-prefix", device: "legacy", energy: energy, state: .ended)
    }

    mutating func record(device: String, generation: String, energy: Double? = nil,
                         state: WorkoutSegmentMetrics.State? = nil,
                         heartRate: Double? = nil, heartRateDate: Date? = nil,
                         activate: Bool = false, stateDate: Date = Date()) {
        guard device == "phone" || device == "watch" else { return }
        var segment = segments[generation] ?? .init(id: generation, device: device)
        guard segment.device == device else { return }
        if let energy, energy.isFinite, energy >= 0 { segment.energy = max(segment.energy, energy) }
        if let state, state != segment.state, state == .paused || state == .ended {
            segment.heartRateInvalidatedAt = max(segment.heartRateInvalidatedAt ?? .distantPast, stateDate)
        }
        // A finished segment cannot be resurrected by a delayed builder callback.
        if let state, segment.state != .ended { segment.state = state }
        if let heartRate, heartRate.isFinite, heartRate > 0, let heartRateDate,
           heartRateDate >= (segment.heartRateDate ?? .distantPast) {
            segment.heartRate = heartRate
            segment.heartRateDate = heartRateDate
        }
        segment.revision += 1
        segments[generation] = segment
        revisions[device, default: 0] += 1
        if activate && segment.state != .ended { activeGenerations[device] = generation }
        if segment.state == .ended && activeGenerations[device] == generation { activeGenerations.removeValue(forKey: device) }
    }

    /// Replayed packets can refine a historical segment, but never change which
    /// session is active or revive an expired heart-rate measurement.
    @discardableResult
    mutating func merge(_ packet: WorkoutMetricsPacket) -> Bool {
        guard packet.workoutID == workoutID, packet.version == 3,
              packet.device == "phone" || packet.device == "watch", packet.revision >= 0 else { return false }
        let before = self
        for incoming in packet.segments {
            guard incoming.device == packet.device || (incoming.device == "legacy" && incoming.id == "legacy-prefix"),
                  incoming.energy.isFinite, incoming.energy >= 0, incoming.revision >= 0,
                  incoming.heartRate == nil || (incoming.heartRate!.isFinite && incoming.heartRate! > 0) else { continue }
            if let current = segments[incoming.id] {
                guard current.device == incoming.device else { continue }
                if incoming.device == "legacy" {
                    var prefix = current
                    prefix.energy = max(current.energy, incoming.energy)
                    segments[incoming.id] = prefix
                    continue
                }
                guard incoming.revision > current.revision else { continue }
                var updated = incoming
                updated.energy = max(current.energy, incoming.energy)
                if current.state == .ended { updated.state = .ended }
                segments[incoming.id] = updated
            } else { segments[incoming.id] = incoming }
        }
        if packet.revision > (revisions[packet.device] ?? -1) {
            revisions[packet.device] = packet.revision
            if let id = packet.activeGeneration, let segment = segments[id],
               segment.device == packet.device, segment.state != .ended { activeGenerations[packet.device] = id }
            else { activeGenerations.removeValue(forKey: packet.device) }
        }
        return self != before
    }

    func packet(device: String) -> WorkoutMetricsPacket {
        .init(workoutID: workoutID, device: device, revision: revisions[device] ?? 0,
              activeGeneration: activeGenerations[device],
              segments: segments.values.filter { $0.device == device || $0.device == "legacy" }.sorted { $0.id < $1.id })
    }

    func liveHeartRate(at now: Date, after invalidation: Date = .distantPast) -> Double? {
        activeGenerations.values.compactMap { segments[$0] }
            .filter { segment in
                guard segment.state == .running, let date = segment.heartRateDate else { return false }
                return date > max(invalidation, segment.heartRateInvalidatedAt ?? .distantPast) && date <= now.addingTimeInterval(5) && now.timeIntervalSince(date) <= 30
            }
            .max { ($0.heartRateDate ?? .distantPast) < ($1.heartRateDate ?? .distantPast) }?.heartRate
    }
}

@MainActor
final class WorkoutMetricsStore {
    static let shared = WorkoutMetricsStore()
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }
    func ledger(for id: String) -> WorkoutMetricsLedger {
        guard let data = defaults.data(forKey: key(id)),
              let ledger = try? JSONDecoder().decode(WorkoutMetricsLedger.self, from: data), ledger.workoutID == id else { return .init(workoutID: id) }
        return ledger
    }
    func save(_ ledger: WorkoutMetricsLedger) {
        guard let data = try? JSONEncoder().encode(ledger) else { return }
        defaults.set(data, forKey: key(ledger.workoutID))
    }
    @discardableResult
    func merge(_ packet: WorkoutMetricsPacket) -> Bool {
        var ledger = ledger(for: packet.workoutID)
        guard ledger.merge(packet) else { return false }
        save(ledger)
        return true
    }
    private func key(_ id: String) -> String { "workout.metrics.v3.\(id)" }
}
