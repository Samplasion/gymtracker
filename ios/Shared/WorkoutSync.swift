import Foundation

enum RecordingConfirmation: String, Codable {
    case pending, confirmed, unavailable, finished
}

struct WatchRecordingIntent: Codable {
    let request: WorkoutRequest
    var generation: String
    var confirmation: RecordingConfirmation = .pending
    var wasConfirmed = false
    var message: String?
}

enum WorkoutSyncLimits {
    static let launch: Double = 60
    static let command: Double = 30
    static let mirroring: Double = 15
    static let preparedLease: Double = 120
    static func retry(_ failure: Int) -> Double { [15.0, 30.0, 60.0][min(max(0, failure), 2)] }
}

/// Owns the phone's intent, not the Watch's sensors. Loss of a reply never
/// authorizes replacing, ending or saving a sensor session.
@MainActor
final class WatchRecordingController {
    private let defaults: UserDefaults
    private(set) var intent: WatchRecordingIntent?
    private(set) var pendingFinishes: [String: Bool]
    private var finishDates: [String: Double]
    private var operation: Task<Void, Never>?
    private var retryTask: Task<Void, Never>?
    private var failures = 0
    private var epoch = UUID()
    var canSend: () -> Bool = { false }
    var launch: (() async throws -> Void)?
    var command: (([String: Any]) async throws -> [String: Any])?
    var deferFinish: (([String: Any]) -> Void)?
    var onChange: ((WatchRecordingIntent) -> Void)?
    var onMetrics: (([String: Any]) -> Void)?
    var diagnostic: (String) -> Void = { _ in }
    var retryDelay: (Int) -> Double = WorkoutSyncLimits.retry

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        intent = defaults.data(forKey: "watch.recording.intent.v1").flatMap { try? JSONDecoder().decode(WatchRecordingIntent.self, from: $0) }
        pendingFinishes = defaults.dictionary(forKey: "workout.remoteFinishes.v2") as? [String: Bool] ?? [:]
        finishDates = defaults.dictionary(forKey: "watch.recording.finishDates.v1") as? [String: Double] ?? [:]
    }

    func start(_ request: WorkoutRequest) {
        if intent?.request != request {
            cancelAttempt()
            intent = .init(request: request, generation: UUID().uuidString)
            failures = 0
        }
        persist()
        if let intent { onChange?(intent) }
        reconnect()
    }

    func stop(id: String, save: Bool) {
        // Discard is terminal even when an earlier save is still in flight.
        pendingFinishes[id] = (pendingFinishes[id] ?? true) && save
        if finishDates[id] == nil { finishDates[id] = Date().timeIntervalSince1970 }
        if intent?.request.id == id {
            cancelAttempt()
            intent?.confirmation = .finished
            intent?.message = nil
        }
        persist()
        if let intent, intent.request.id == id { onChange?(intent) }
        deferFinish?(finishCommand(id: id, save: pendingFinishes[id] == true))
        reconnect()
    }

    func acknowledge(_ response: [String: Any]) {
        guard response["success"] as? Bool == true,
              let id = response["workoutId"] as? String,
              let save = response["save"] as? Bool,
              pendingFinishes[id] == save else { return }
        pendingFinishes.removeValue(forKey: id)
        finishDates.removeValue(forKey: id)
        persist()
        diagnostic("workout=\(id) terminal acknowledged save=\(save)")
    }

    func reconnect() {
        retryTask?.cancel(); retryTask = nil
        guard operation == nil else { return }
        let currentEpoch = epoch
        operation = Task { @MainActor in
            defer { if self.epoch == currentEpoch { self.operation = nil } }
            do {
                try await self.reconcile(epoch: currentEpoch)
                guard self.epoch == currentEpoch else { return }
                self.failures = 0
            } catch {
                guard self.epoch == currentEpoch, !(error is CancellationError) else { return }
                self.diagnostic("reconciliation pending: \(error.localizedDescription)")
                self.scheduleRetry()
            }
        }
    }

    func authorizationBecameAvailable() {
        guard intent?.confirmation == .unavailable, intent?.wasConfirmed == false else { return }
        intent?.confirmation = .pending
        intent?.message = nil
        persist()
        if let intent { onChange?(intent) }
        reconnect()
    }

    private func cancelAttempt() {
        epoch = UUID()
        operation?.cancel(); operation = nil
        retryTask?.cancel(); retryTask = nil
    }

    private func check(_ expected: UUID, request: WorkoutRequest? = nil) throws {
        try Task.checkCancellation()
        guard epoch == expected else { throw WorkoutOperationError.stale }
        if let request {
            guard intent?.request == request, intent?.confirmation != .finished else { throw WorkoutOperationError.stale }
        }
    }

    private func reconcile(epoch: UUID) async throws {
        guard let command else { throw WorkoutOperationError.unavailable }
        if !pendingFinishes.isEmpty {
            for (id, save) in pendingFinishes { deferFinish?(finishCommand(id: id, save: save)) }
            guard canSend() else { throw WorkoutOperationError.unavailable }
            for (id, save) in pendingFinishes {
                try check(epoch)
                let response = try await command(finishCommand(id: id, save: save))
                try check(epoch)
                guard response["success"] as? Bool == true else { throw WorkoutOperationError.unavailable }
                // Legacy peers don't include the terminal identity in their reply.
                acknowledge(response.merging(["workoutId": id, "save": save]) { current, _ in current })
            }
        }
        guard let initial = intent,
              initial.confirmation != .finished, initial.confirmation != .unavailable else { return }
        let request = initial.request
        if !canSend() {
            // An established recording remains on the Watch. Only an initial
            // pending start is allowed to ask HealthKit to wake its companion.
            guard !initial.wasConfirmed, let launch else { throw WorkoutOperationError.unavailable }
            try await workoutDiagnosticOperation("launch", diagnostic: diagnostic) {
                try await workoutDeadline(WorkoutSyncLimits.launch) { try await launch() }
            }
        }
        try check(epoch, request: request)
        guard canSend() else { throw WorkoutOperationError.unavailable }
        let status = try await command(["action": "status", "workoutId": request.id, "requestId": UUID().uuidString])
        try check(epoch, request: request)
        if let metrics = status["metrics"] as? [String: Any] { onMetrics?(metrics) }
        if status["running"] as? Bool == true, status["workoutId"] as? String == request.id {
            confirm(status)
            return
        }
        if status["permanent"] as? Bool == true || status["finished"] as? Bool == true
            || (initial.wasConfirmed && status["exists"] as? Bool == false) {
            unavailable(status["error"] as? String ?? "The Watch recording has ended.")
            return
        }
        // An unknown reply from a legacy peer must never restart a previously
        // confirmed session. Wait for its metrics/connection instead.
        guard !initial.wasConfirmed else { throw WorkoutOperationError.unavailable }
        if status["busy"] as? Bool == true { throw WorkoutOperationError.unavailable }
        if let generation = status["generation"] as? String, status["exists"] as? Bool == true {
            intent?.generation = generation
            persist()
        }
        guard let generation = intent?.generation else { return }
        var base: [String: Any] = ["workoutId": request.id, "generation": generation,
                                  "start": request.start.timeIntervalSince1970]
        if status["exists"] as? Bool != true {
            base["action"] = "prepare"
            base["requestId"] = "\(request.id):\(generation):prepare"
            let prepared = try await command(base)
            try check(epoch, request: request)
            guard try accept(prepared) else { return }
            if let metrics = prepared["metrics"] as? [String: Any] { onMetrics?(metrics) }
            if let token = prepared["generation"] as? String { intent?.generation = token; base["generation"] = token; persist() }
            if prepared["running"] as? Bool == true { confirm(prepared); return }
        }
        try check(epoch, request: request)
        base["action"] = "commit"
        base["requestId"] = "\(request.id):\(intent?.generation ?? generation):commit"
        let committed = try await command(base)
        try check(epoch, request: request)
        guard try accept(committed) else { return }
        confirm(committed)
    }

    private func accept(_ response: [String: Any]) throws -> Bool {
        if response["success"] as? Bool == true { return true }
        if response["permanent"] as? Bool == true {
            unavailable(response["error"] as? String ?? "Watch recording is unavailable.")
        } else { throw WorkoutOperationError.unavailable }
        return false
    }

    private func confirm(_ response: [String: Any]) {
        if let generation = response["generation"] as? String { intent?.generation = generation }
        intent?.confirmation = .confirmed
        intent?.wasConfirmed = true
        intent?.message = nil
        persist()
        if let intent { onChange?(intent) }
        diagnostic("workout=\(intent?.request.id ?? "") recording confirmed")
    }

    private func unavailable(_ message: String) {
        intent?.confirmation = .unavailable
        intent?.message = message
        persist()
        if let intent { onChange?(intent) }
    }

    private func scheduleRetry() {
        guard retryTask == nil else { return }
        let delay = retryDelay(failures)
        failures += 1
        diagnostic("next reconciliation in \(delay)s")
        retryTask = Task { @MainActor in
            do { try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) } catch { return }
            self.retryTask = nil
            self.reconnect()
        }
    }

    func finishCommand(id: String, save: Bool) -> [String: Any] {
        ["action": "stop", "workoutId": id, "save": save,
         "requestId": "\(id):stop:\(save)", "endedAt": finishDates[id] ?? Date().timeIntervalSince1970]
    }

    private func persist() {
        defaults.set(intent.flatMap { try? JSONEncoder().encode($0) }, forKey: "watch.recording.intent.v1")
        defaults.set(pendingFinishes, forKey: "workout.remoteFinishes.v2")
        defaults.set(finishDates, forKey: "watch.recording.finishDates.v1")
    }
}

/// Workout-only revisions must not suppress a newer food/catalog snapshot.
struct WorkoutStateCursor {
    private(set) var revision: Int64 = -1
    mutating func accept(_ incoming: Int64) -> Bool {
        guard incoming > revision else { return false }
        revision = incoming
        return true
    }
}

/// The mirrored session has no request/reply API. Correlation and bounded
/// continuations are shared by it and the immediate WCSession fallback.
@MainActor
final class WorkoutTransport {
    var timeout = WorkoutSyncLimits.command
    var mirrorAvailable: () -> Bool = { false }
    var immediateAvailable: () -> Bool = { false }
    var mirrorSend: ((Data) async throws -> Void)?
    var immediateSend: (([String: Any], @escaping ([String: Any]) -> Void, @escaping (Error) -> Void) -> Void)?
    var onCommand: (([String: Any], @escaping ([String: Any]) -> Void) -> Void)?
    var onState: (([String: Any], Int64) -> Void)?
    var diagnostic: (String) -> Void = { _ in }
    private var replies: [String: CheckedContinuation<[String: Any], Error>] = [:]
    private var timers: [String: Task<Void, Never>] = [:]
    private var state: [String: Any]?
    private var stateTask: Task<Void, Never>?
    var available: Bool { mirrorAvailable() || immediateAvailable() }

    func request(_ command: [String: Any]) async throws -> [String: Any] {
        var command = command
        let id = command["requestId"] as? String ?? UUID().uuidString
        command["requestId"] = id
        command["method"] = "workoutSensor"
        command["deadline"] = Date().addingTimeInterval(timeout).timeIntervalSince1970
        // A stable logical ID may be retried after its previous waiter expired.
        finish(id, .failure(CancellationError()))
        return try await withTaskCancellationHandler {
            try Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                replies[id] = continuation
                timers[id] = Task { @MainActor in
                    do { try await Task.sleep(nanoseconds: UInt64(self.timeout * 1_000_000_000)) } catch { return }
                    self.finish(id, .failure(WorkoutOperationError.timeout))
                }
                let payload = command
                Task { @MainActor in
                    do {
                        if self.mirrorAvailable(), let send = self.mirrorSend {
                            do {
                                try await workoutDeadline(WorkoutSyncLimits.mirroring) {
                                    try await send(self.encode(kind: "command", payload: payload))
                                }
                                return
                            } catch { self.diagnostic("mirrored command failed; trying WatchConnectivity: \(error)") }
                        }
                        guard self.replies[id] != nil, self.immediateAvailable(), let send = self.immediateSend else {
                            throw WorkoutOperationError.unavailable
                        }
                        send(payload, { self.finish(id, .success($0)) }, { self.finish(id, .failure($0)) })
                    } catch { self.finish(id, .failure(error)) }
                }
            }
        } onCancel: { Task { @MainActor in self.finish(id, .failure(CancellationError())) } }
    }

    func receive(_ envelope: [String: Any]) -> Bool {
        guard envelope["wireVersion"] as? Int == 1,
              let kind = envelope["kind"] as? String,
              let payload = envelope["payload"] as? [String: Any] else { return false }
        if kind == "reply", let id = payload["requestId"] as? String {
            finish(id, .success(payload))
        } else if kind == "command" {
            onCommand?(payload) { response in
                var response = response
                response["requestId"] = payload["requestId"]
                response["workoutId"] = payload["workoutId"]
                Task { @MainActor in await self.reply(response) }
            }
        } else if kind == "workoutState", let revision = envelope["revision"] as? Int64 {
            onState?(payload, revision)
        }
        return true
    }

    func reply(_ payload: [String: Any]) async {
        if mirrorAvailable(), let send = mirrorSend {
            do { try await send(encode(kind: "reply", payload: payload)); return } catch { diagnostic("mirrored reply failed: \(error)") }
        }
        if immediateAvailable() {
            immediateSend?(envelope(kind: "reply", payload: payload), { _ in }, { self.diagnostic("reply failed: \($0)") })
        }
    }

    func publish(_ payload: [String: Any], revision: Int64) {
        var envelope = envelope(kind: "workoutState", payload: payload)
        envelope["revision"] = revision
        state = envelope
        flush()
    }

    func flush() {
        guard stateTask == nil, state != nil, available else { return }
        stateTask = Task { @MainActor in
            defer { self.stateTask = nil }
            while let envelope = self.state, self.available {
                self.state = nil
                do {
                    if self.mirrorAvailable(), let send = self.mirrorSend {
                        do {
                            try await workoutDeadline(WorkoutSyncLimits.mirroring) { try await send(JSONSerialization.data(withJSONObject: envelope)) }
                        } catch {
                            guard self.immediateAvailable(), let immediate = self.immediateSend else { throw error }
                            immediate(envelope, { _ in }, { self.diagnostic("state send failed: \($0)"); if self.state == nil { self.state = envelope } })
                        }
                    } else if let send = self.immediateSend {
                        send(envelope, { _ in }, { self.diagnostic("state send failed: \($0)"); if self.state == nil { self.state = envelope } })
                    }
                } catch {
                    if self.state == nil { self.state = envelope }
                    self.diagnostic("state pending: \(error)")
                    return
                }
                do { try await Task.sleep(nanoseconds: 500_000_000) } catch { return }
            }
        }
    }

    private func finish(_ id: String, _ result: Result<[String: Any], Error>) {
        timers.removeValue(forKey: id)?.cancel()
        replies.removeValue(forKey: id)?.resume(with: result)
    }

    private func envelope(kind: String, payload: [String: Any]) -> [String: Any] {
        ["method": "workoutWire", "wireVersion": 1, "kind": kind, "payload": payload,
         "workoutId": payload["workoutId"] ?? payload["id"] ?? ""]
    }
    private func encode(kind: String, payload: [String: Any]) throws -> Data {
        try JSONSerialization.data(withJSONObject: envelope(kind: kind, payload: payload))
    }
}
