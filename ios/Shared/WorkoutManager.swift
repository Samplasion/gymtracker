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
    @Published var phase: WorkoutPhase = .idle { didSet { onPhaseChanged?() } }
    var onPhaseChanged: (() -> Void)?

    let healthStore = HKHealthStore()
    let typesToShare: Set<HKSampleType> = [.workoutType()]
    let typesToRead: Set<HKObjectType> = [HKQuantityType(.heartRate), HKQuantityType(.activeEnergyBurned), HKObjectType.workoutType(), HKObjectType.activitySummaryType(), HKCharacteristicType(.activityMoveMode)]
    var session: HKWorkoutSession?
    var builder: HKWorkoutBuilder?
    var collectionStarted = false
    var listener: WorkoutMetricsListener?
    var request: WorkoutRequest?
    var generation = UUID().uuidString
    let metricsStore = WorkoutMetricsStore.shared
    var metricsDevice: String {
        #if os(watchOS)
        return "watch"
        #else
        return "phone"
        #endif
    }
    var onMetricsPacket: ((WorkoutMetricsPacket) -> Void)?
    let transport = WorkoutTransport()
    var recordingController: WatchRecordingController?
    var onDiagnostic: ((String) -> Void)?

    func diagnostic(_ message: String) {
        let line = "[WorkoutSync] \(message)"
        Logger.shared.info("\(line, privacy: .public)")
        onDiagnostic?(line)
    }
    var onSensorSessionEnded: (() -> Void)?
    private var metricsMonitor: Task<Void, Never>?
    private var heartRateInvalidatedAt = Date()
    var remoteSession: HKWorkoutSession?
    var remoteConnected = false
    var watchConfigured: (() -> Bool)?
    var watchConfigurationReady: (() -> Bool)?
    var onError: ((String, String) -> Void)?
    var onAuthorizationChanged: (() -> Void)?
    var device: String = "none"
    var desiredRequest: WorkoutRequest?
    let operationQueue = WorkoutOperationQueue()
    var terminalGenerations = Set<String>()
    var activeFinalization: Task<Void, Error>?

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
        transport.mirrorAvailable = { [weak self] in self?.remoteConnected == true }
        transport.mirrorSend = { [weak self] data in
            guard let self, let session = self.remoteSession ?? self.session, self.remoteConnected else {
                throw WorkoutOperationError.unavailable
            }
            if #available(watchOS 10, *) { try await session.sendToRemoteWorkoutSession(data: data) }
            else { throw WorkoutOperationError.unavailable }
        }
        transport.diagnostic = { [weak self] in self?.diagnostic($0) }
        Task { @MainActor in
            for await event in events.stream {
                guard self.session === event.session else { continue }
                self.sessionState = event.state
                #if os(watchOS)
                if event.state == .running, let id = self.request?.id {
                    var ids = Set(UserDefaults.standard.stringArray(forKey: "workout.startedWatchIDs.v1") ?? [])
                    ids.insert(id)
                    UserDefaults.standard.set(Array(ids), forKey: "workout.startedWatchIDs.v1")
                }
                #endif
                if self.builder != nil {
                    self.recordSegment(generation: self.generation, state: self.metricsState(event.state), stateDate: event.date)
                }
                if event.state == .paused || event.state == .stopped || event.state == .ended { self.invalidateHeartRate() }
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
                        self.onSensorSessionEnded?()
                    }
                }
            }
        }
    }

    func enqueue(_ operation: @escaping @MainActor () async -> Void) {
        operationQueue.enqueue(operation)
    }

    func requestAuthorization() {
        #if DEBUG && os(watchOS)
        if ScreenshotMode.enabled { return }
        #endif
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
        selectWorkout(request)
        self.generation = generation
        session = newSession
        let liveBuilder = newSession.associatedWorkoutBuilder()
        builder = liveBuilder
        collectionStarted = false
        newSession.delegate = self
        liveBuilder.delegate = self
        liveBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: newSession.workoutConfiguration)
        workout = nil
        invalidateHeartRate()
        recordSegment(generation: generation, state: metricsState(newSession.state), activate: true)
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
            collectionStarted = true
            phase = .active
            recordSegment(generation: generation, state: .running, activate: true)
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
        if builder != nil { recordSegment(generation: finishingGeneration, state: .ended) }
        invalidateHeartRate()
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
                        self.recordSegment(workoutID: id, generation: finishingGeneration,
                            energy: result.totalEnergyBurned?.doubleValue(for: .kilocalorie()), state: .ended)
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
            if self.session === session { self.session = nil; self.builder = nil; self.collectionStarted = false; self.sessionState = .ended }
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

    func selectWorkout(_ next: WorkoutRequest) {
        let changed = request?.id != next.id
        request = next
        if changed {
            var ledger = metricsStore.ledger(for: next.id)
            ledger.seedLegacyOffset(UserDefaults.standard.double(forKey: "workout.offset.\(next.id)"))
            metricsStore.save(ledger)
            heartRateInvalidatedAt = Date()
        }
        refreshPublishedMetrics(emitPacket: false)
        if metricsMonitor == nil {
            metricsMonitor = Task { @MainActor in
                while !Task.isCancelled {
                    do { try await Task.sleep(nanoseconds: 5_000_000_000) } catch { return }
                    self.refreshPublishedMetrics(emitPacket: false)
                    #if os(iOS)
                    // Retry scheduling belongs to the controller. A metrics tick
                    // must never start/finish a sensor session or reset its backoff.
                    #endif
                }
            }
        }
    }

    func stopMonitoringMetrics() {
        metricsMonitor?.cancel()
        metricsMonitor = nil
        invalidateHeartRate()
    }

    func invalidateHeartRate() {
        heartRateInvalidatedAt = Date()
        heartRate = 0
        listener?.handleHeartRateUpdate(0)
    }

    func metricsPacket() -> WorkoutMetricsPacket? {
        guard let id = request?.id else { return nil }
        return metricsStore.ledger(for: id).packet(device: metricsDevice)
    }

    func refreshPublishedMetrics(emitPacket: Bool = true) {
        guard let id = request?.id else { return }
        let ledger = metricsStore.ledger(for: id)
        activeEnergy = ledger.totalEnergy
        heartRate = ledger.liveHeartRate(at: Date(), after: heartRateInvalidatedAt) ?? 0
        listener?.handleActiveEnergyUpdate(activeEnergy)
        listener?.handleHeartRateUpdate(heartRate)
        if emitPacket { onMetricsPacket?(ledger.packet(device: metricsDevice)) }
    }

    func recordSegment(workoutID: String? = nil, generation: String, energy: Double? = nil,
                       state: WorkoutSegmentMetrics.State? = nil, heartRate: Double? = nil,
                       heartRateDate: Date? = nil, activate: Bool = false, stateDate: Date = Date()) {
        guard let id = workoutID ?? request?.id else { return }
        var ledger = metricsStore.ledger(for: id)
        ledger.record(device: metricsDevice, generation: generation, energy: energy, state: state,
                      heartRate: heartRate, heartRateDate: heartRateDate, activate: activate, stateDate: stateDate)
        metricsStore.save(ledger)
        if request?.id == id { refreshPublishedMetrics() }
    }

    private func metricsState(_ state: HKWorkoutSessionState) -> WorkoutSegmentMetrics.State {
        switch state {
        case .running: return .running
        case .paused: return .paused
        case .stopped, .ended: return .ended
        default: return .prepared
        }
    }

    func updateForStatistics(_ statistics: HKStatistics, generation: String) {
        switch statistics.quantityType {
        case HKQuantityType(.heartRate):
            recordSegment(generation: generation,
                heartRate: statistics.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())),
                heartRateDate: statistics.mostRecentQuantityDateInterval()?.end)
        case HKQuantityType(.activeEnergyBurned):
            recordSegment(generation: generation, energy: statistics.sumQuantity()?.doubleValue(for: .kilocalorie()))
        default: break
        }
    }

    func sendData(_ data: Data) async {
        guard let session else { return }
        if #available(watchOS 10, *) {
            do {
                try await session.sendToRemoteWorkoutSession(data: data)
                remoteConnected = true
                transport.flush()
            }
            catch { Logger.shared.error("Workout transport: \(error)") }
        }
    }

    func handleReceivedData(_ data: Data) throws {
        let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        if transport.receive(raw) { return }
        guard let packet = WorkoutMetricsPacket.decode(raw["metrics"] as? [String: Any] ?? raw),
              packet.workoutID == request?.id, packet.device != metricsDevice else { return }
        if metricsStore.merge(packet) {
            refreshPublishedMetrics()
            #if os(iOS)
            if packet.device == "watch", device == "watch" {
                let ledger = metricsStore.ledger(for: packet.workoutID)
                switch ledger.activeGenerations["watch"].flatMap({ ledger.segments[$0]?.state }) {
                case .running?: sessionState = .running
                case .paused?: sessionState = .paused
                case .prepared?: sessionState = .prepared
                default: sessionState = .ended
                }
                if packet.activeGeneration == nil { onSensorSessionEnded?() }
            }
            #endif
        }
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
            guard self.session === workoutSession || self.remoteSession === workoutSession else { return }
            self.diagnostic("HealthKit link disconnected; recording stays on its primary")
            self.remoteConnected = false
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
            let id = workoutBuilder.metadata[HKMetadataKeyExternalUUID] as? String
            guard id == self.request?.id,
                  let token = workoutBuilder.metadata["gymbro.segmentId"] as? String ?? (self.builder === workoutBuilder ? self.generation : nil) else { return }
            for type in collectedTypes {
                if let quantity = type as? HKQuantityType, let statistics = workoutBuilder.statistics(for: quantity) {
                    self.updateForStatistics(statistics, generation: token)
                }
            }
            if let packet = self.metricsPacket(), let data = try? JSONEncoder().encode(packet) { await self.sendData(data) }
        }
    }
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}

@available(iOS 17, watchOS 9, *)
extension HKWorkoutSessionState {
    var isActive: Bool { self == .running || self == .paused || self == .prepared }
}
