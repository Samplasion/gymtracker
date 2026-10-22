import Foundation
import os
import Combine
import HealthKit

struct WorkoutSummary: Identifiable {
    enum Result {
        case saving, saved(HKWorkout), failed(String), discarded
    }
    let id: String
    var result: Result
}

@available(iOS 17, watchOS 9, *)
@MainActor
final class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()
    @Published var sessionState: HKWorkoutSessionState = .notStarted
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var workout: HKWorkout?
    @Published var summary: WorkoutSummary?
    @Published var phase: WorkoutPhase = .idle

    let healthStore = HKHealthStore()
    let typesToShare: Set<HKSampleType> = [.workoutType()]
    let typesToRead: Set<HKObjectType> = [HKQuantityType(.heartRate), HKQuantityType(.activeEnergyBurned), HKObjectType.workoutType(), HKObjectType.activitySummaryType(), HKCharacteristicType(.activityMoveMode)]
    var session: HKWorkoutSession?
    var builder: HKWorkoutBuilder?
    var listener: WorkoutMetricsListener?
    var request: WorkoutRequest?
    var generation = UUID().uuidString
    var energyOffset: Double = 0
    var remoteSession: HKWorkoutSession?
    var remoteCommand: (([String: Any]) async throws -> [String: Any])?
    var watchAvailable: (() -> Bool)?
    var onError: ((String, String) -> Void)?
    var onAuthorizationChanged: (() -> Void)?
    var watchAttemptInProgress = false
    var device: String = "none"
    var desiredRequest: WorkoutRequest?
    let operationQueue = WorkoutOperationQueue()
    var terminalGenerations = Set<String>()
    var activeFinalization: Task<Void, Error>?
    var pendingRemoteFinish: [String: Bool] = [:]

    private struct Event {
        let session: HKWorkoutSession
        let state: HKWorkoutSessionState
        let date: Date
        let error: String?
    }
    // Never drop .stopped/.ended when several delegate callbacks arrive together.
    private nonisolated let events = AsyncStream.makeStream(of: Event.self)

    private override init() {
        super.init()
        pendingRemoteFinish = UserDefaults.standard.dictionary(forKey: "workout.remoteFinishes.v2") as? [String: Bool] ?? [:]
        Task { @MainActor in
            for await event in events.stream {
                guard self.session === event.session else { continue }
                self.sessionState = event.state
                if let error = event.error {
                    self.phase = .failed(error)
                    self.summary = .init(id: self.request?.id ?? self.generation, result: .failed(error))
                }
                if event.state == .stopped || event.state == .ended {
                    guard !self.terminalGenerations.contains(self.generation) else { continue }
                    // System interruptions must also release the builder.
                    self.enqueue {
                        guard self.session === event.session else { return }
                        try? await self.finishSegment(save: true)
                    }
                }
            }
        }
    }

    func enqueue(_ operation: @escaping @MainActor () async -> Void) {
        operationQueue.enqueue(operation)
    }

    func requestAuthorization() {
        Task { @MainActor in
            do {
                try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
                onAuthorizationChanged?()
            }
            catch { phase = .failed(error.localizedDescription) }
        }
    }

    @available(iOS 26, *)
    func attachPrimary(_ newSession: HKWorkoutSession, request: WorkoutRequest, generation: String) {
        terminalGenerations.removeAll()
        self.request = request
        self.generation = generation
        session = newSession
        let liveBuilder = newSession.associatedWorkoutBuilder()
        builder = liveBuilder
        newSession.delegate = self
        liveBuilder.delegate = self
        liveBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: newSession.workoutConfiguration)
        workout = nil
        heartRate = 0
        activeEnergy = energyOffset
        summary = nil
    }

    func commitPrimary(at date: Date) async throws {
        guard let session, let builder else { throw WorkoutOperationError.unavailable }
        if session.state == .running || session.state == .paused { return }
        session.startActivity(with: date)
        do {
            try await builder.beginCollection(at: date)
            try Task.checkCancellation()
            guard self.session === session else { throw WorkoutOperationError.stale }
            phase = .active
        } catch {
            builder.discardWorkout()
            session.end()
            if self.session === session { self.builder = nil; self.session = nil }
            throw error
        }
    }

    /// Captures the old session/builder before any await; a late completion cannot
    /// mutate or reset a newly started segment.
    func finishSegment(save: Bool) async throws {
        if let activeFinalization { return try await activeFinalization.value }
        guard let session else { return }
        let key = generation
        guard terminalGenerations.insert(key).inserted else { return }
        let builder = self.builder
        let id = request?.id ?? generation
        let endDate = Date()
        let finishingGeneration = generation
        let task = Task { @MainActor in
            if self.request?.id == id && self.generation == finishingGeneration { self.summary = .init(id: id, result: save ? .saving : .discarded) }
            if session.state == .running || session.state == .paused { session.stopActivity(with: endDate) }
            // Wait for .stopped before ending collection, without relying on the UI.
            for _ in 0..<200 {
                if session.state == .stopped || session.state == .ended || session.state == .notStarted || session.state == .prepared { break }
                try await Task.sleep(nanoseconds: 25_000_000)
            }
            session.end()
            // Mirrored sessions have no builder. Their primary device saves.
            guard let builder else { return }
            do {
                if save {
                    try await builder.endCollection(at: endDate)
                    if let result = try await builder.finishWorkout() {
                        self.remember(result, workoutID: id)
                        if self.discardedWorkoutIDs.contains(id) {
                            try await self.deleteSavedSegments(id: id)
                        } else if self.request?.id == id && self.generation == finishingGeneration {
                            self.workout = result
                            self.summary = .init(id: id, result: .saved(result))
                        }
                    } else { throw WorkoutOperationError.unavailable }
                } else {
                    builder.discardWorkout()
                }
            } catch {
                if self.request?.id == id && self.generation == finishingGeneration { self.summary = .init(id: id, result: .failed(error.localizedDescription)) }
                throw error
            }
        }
        activeFinalization = task
        defer {
            activeFinalization = nil
            if self.session === session { self.session = nil; self.builder = nil; self.sessionState = .ended }
        }
        try await workoutDeadline(30) { try await task.value }
    }

    private let journalKey = "workout.savedSegments.v2"
    private let discardKey = "workout.pendingDiscards.v2"
    var discardedWorkoutIDs: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: discardKey) ?? [])
    }
    func markDiscarded(_ id: String) {
        var ids = discardedWorkoutIDs
        ids.insert(id)
        UserDefaults.standard.set(Array(ids), forKey: discardKey)
    }
    func remember(_ workout: HKWorkout, workoutID: String) {
        var journal = UserDefaults.standard.dictionary(forKey: journalKey) as? [String: [String]] ?? [:]
        var segments = journal[workoutID] ?? []
        if !segments.contains(workout.uuid.uuidString) { segments.append(workout.uuid.uuidString) }
        journal[workoutID] = segments
        UserDefaults.standard.set(journal, forKey: journalKey)
    }
    func deleteSavedSegments(id: String) async throws {
        var journal = UserDefaults.standard.dictionary(forKey: journalKey) as? [String: [String]] ?? [:]
        for rawID in journal[id] ?? [] {
            guard let uuid = UUID(uuidString: rawID) else { continue }
            // Delete by the exact UUID returned by our builder. No read grant is
            // required and no samples from another app can match our journal.
            _ = try await healthStore.deleteObjects(of: HKObjectType.workoutType(), predicate: HKQuery.predicateForObject(with: uuid))
            journal = UserDefaults.standard.dictionary(forKey: journalKey) as? [String: [String]] ?? [:]
            journal[id]?.removeAll { $0 == rawID }
            UserDefaults.standard.set(journal, forKey: journalKey)
        }
    }
    func retryDiscard(id: String) {
        enqueue {
            do {
                try await self.deleteSavedSegments(id: id)
                self.summary = .init(id: id, result: .discarded)
            } catch {
                self.summary = .init(id: id, result: .failed(error.localizedDescription))
                self.onError?(id, error.localizedDescription)
            }
        }
    }

    func updateForStatistics(_ statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType(.heartRate):
            heartRate = statistics.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0
            listener?.handleHeartRateUpdate(heartRate)
        case HKQuantityType(.activeEnergyBurned):
            activeEnergy = energyOffset + (statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
            listener?.handleActiveEnergyUpdate(activeEnergy)
        default: break
        }
    }

    func sendData(_ data: Data) async {
        if #available(watchOS 10, *) {
            do { try await session?.sendToRemoteWorkoutSession(data: data) }
            catch { Logger.shared.error("Workout transport: \(error)") }
        }
    }

    func handleReceivedData(_ data: Data) throws {
        guard let packet = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              packet["workoutId"] as? String == request?.id,
              packet["generation"] as? String == generation else { return }
        if let energy = packet["energy"] as? Double { activeEnergy = energy; listener?.handleActiveEnergyUpdate(energy) }
        if let rate = packet["heartRate"] as? Double { heartRate = rate; listener?.handleHeartRateUpdate(rate) }
    }
}

@available(iOS 17, watchOS 9, *)
extension WorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        events.continuation.yield(.init(session: workoutSession, state: toState, date: date, error: nil))
    }
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        events.continuation.yield(.init(session: workoutSession, state: .ended, date: Date(), error: error.localizedDescription))
    }
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didDisconnectFromRemoteDeviceWithError error: Error?) {
        Task { @MainActor in
            guard self.session === workoutSession else { return }
            if let error { Logger.shared.error("Workout disconnected: \(error)") }
        }
    }
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didReceiveDataFromRemoteWorkoutSession data: [Data]) {
        Task { @MainActor in
            guard self.session === workoutSession || self.remoteSession === workoutSession else { return }
            for packet in data { try? self.handleReceivedData(packet) }
        }
    }
}

@available(iOS 26, watchOS 9, *)
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        Task { @MainActor in
            guard self.builder === workoutBuilder else { return }
            for type in collectedTypes {
                if let quantity = type as? HKQuantityType, let statistics = workoutBuilder.statistics(for: quantity) { self.updateForStatistics(statistics) }
            }
            guard let id = self.request?.id else { return }
            let packet: [String: Any] = ["workoutId": id, "generation": self.generation, "energy": self.activeEnergy, "heartRate": self.heartRate]
            if let data = try? JSONSerialization.data(withJSONObject: packet) { await self.sendData(data) }
        }
    }
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}

@available(iOS 17, watchOS 9, *)
extension HKWorkoutSessionState {
    var isActive: Bool { self == .running || self == .paused || self == .prepared }
}
