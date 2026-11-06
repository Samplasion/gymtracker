import Foundation

/// The app workout survives process restarts; a sensor segment never changes devices.
struct WorkoutRequest: Codable, Equatable {
    let id: String
    let start: Date
}

enum WorkoutPhase: Equatable {
    case idle, starting, active, switchingDevice, finalizing, failed(String)
}

/// App navigation and sensor recording have independent lifecycles.
enum WorkoutRecordingStatus: Equatable {
    case starting, recording, unavailable(String)

    init(matchesWorkout: Bool, phase: WorkoutPhase, sensorActive: Bool) {
        guard matchesWorkout else { self = .starting; return }
        if case .failed(let message) = phase { self = .unavailable(message) }
        else if phase == .active {
            self = sensorActive ? .recording : .unavailable("Recording is not active.")
        }
        else if phase == .idle { self = .unavailable("Recording is not active.") }
        else { self = .starting }
    }
}

/// Waking the companion must not consume the sensor handshake's time budget.
@MainActor
func prepareWorkoutAfterLaunch<T>(
    timeout: Double = 10,
    diagnostic: @escaping (String) -> Void = { _ in },
    launch: @escaping @MainActor () async throws -> Void,
    prepare: @escaping @MainActor (Date) async throws -> T
) async throws -> T {
    try await workoutDiagnosticOperation("launch", diagnostic: diagnostic) {
        try await workoutDeadline(timeout, operation: launch)
    }
    let deadline = Date().addingTimeInterval(timeout)
    return try await workoutDiagnosticOperation("prepare", diagnostic: diagnostic) {
        try await workoutDeadline(timeout) { try await prepare(deadline) }
    }
}

/// Keep timing and failures visible without changing the operation's result.
@MainActor
func workoutDiagnosticOperation<T>(
    _ stage: String,
    diagnostic: (String) -> Void,
    operation: () async throws -> T
) async throws -> T {
    let started = Date()
    diagnostic("\(stage) started")
    do {
        let result = try await operation()
        diagnostic("\(stage) succeeded after \(String(format: "%.2f", Date().timeIntervalSince(started)))s")
        return result
    } catch {
        let nsError = error as NSError
        diagnostic("\(stage) failed after \(String(format: "%.2f", Date().timeIntervalSince(started)))s: \(nsError.domain)/\(nsError.code) \(error.localizedDescription)")
        throw error
    }
}

/// A persisted, monotonically increasing revision shared by immediate and deferred delivery.
/// Food and workout snapshots must always travel together in applicationContext.
struct WatchSnapshot {
    private(set) var revision: Int64
    private(set) var workout: [String: Any]
    private(set) var food: [String: Any]

    init(dictionary: [String: Any] = [:]) {
        revision = (dictionary["revision"] as? NSNumber)?.int64Value ?? 0
        workout = dictionary["workout"] as? [String: Any] ?? [:]
        food = dictionary["food"] as? [String: Any] ?? [:]
    }

    mutating func update(workout: [String: Any]? = nil, food: [String: Any]? = nil) {
        if let workout { self.workout = workout }
        if let food { self.food = food }
        revision += 1
    }

    var dictionary: [String: Any] {
        ["version": 2, "revision": revision, "workout": workout, "food": food]
    }
}

struct WatchSnapshotCursor {
    private(set) var revision: Int64
    init(revision: Int64 = -1) { self.revision = revision }
    mutating func accept(_ dictionary: [String: Any]) -> Bool {
        guard dictionary["version"] as? Int == 2,
              let incoming = (dictionary["revision"] as? NSNumber)?.int64Value,
              incoming > revision else { return false }
        revision = incoming
        return true
    }
}

/// One completion wins. Unlike task groups this does not wait for an uncooperative
/// HealthKit/WatchConnectivity callback after the deadline has expired.
@MainActor
func workoutDeadline<T>(_ seconds: Double, operation: @escaping @MainActor () async throws -> T) async throws -> T {
    let race = WorkoutDeadlineRace<T>()
    return try await withTaskCancellationHandler {
        try Task.checkCancellation()
        return try await withCheckedThrowingContinuation { continuation in
            race.continuation = continuation
            race.operation = Task { @MainActor in
                do { race.finish(.success(try await operation())) }
                catch { race.finish(.failure(error)) }
            }
            race.timer = Task { @MainActor in
                do { try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000)) }
                catch { return }
                race.finish(.failure(WorkoutOperationError.timeout))
            }
        }
    } onCancel: { Task { @MainActor in race.finish(.failure(CancellationError())) } }
}

enum WorkoutOperationError: LocalizedError {
    case timeout, unavailable, stale
    var errorDescription: String? {
        switch self {
        case .timeout: return "The workout operation took too long."
        case .unavailable: return "The workout device is unavailable."
        case .stale: return "This workout is no longer active."
        }
    }
}

@MainActor
private final class WorkoutDeadlineRace<T> {
    var continuation: CheckedContinuation<T, Error>?
    var operation: Task<Void, Never>?
    var timer: Task<Void, Never>?
    func finish(_ result: Result<T, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        timer?.cancel()
        operation?.cancel()
        continuation.resume(with: result)
    }
}

/// Persisted fence for sensor commands. Finished app workouts cannot be restarted
/// by a delayed launch/prepare, even after the Watch process was terminated.
struct WorkoutCommandFence: Codable {
    private(set) var revision: Int64 = -1
    private(set) var finished: Set<String> = []
    mutating func prepare(id: String, revision: Int64) -> Bool {
        guard !finished.contains(id), revision >= self.revision else { return false }
        self.revision = revision
        return true
    }
    mutating func finish(id: String) { finished.insert(id) }
}

@MainActor
final class WorkoutOperationQueue {
    private var tail: Task<Void, Never>?
    func enqueue(_ operation: @escaping @MainActor () async -> Void) {
        let previous = tail
        tail = Task { @MainActor in
            await previous?.value
            await operation()
        }
    }
    func drain() async { await tail?.value }
}

/// A commit reply can be lost after the Watch has started. Only a confirmed
/// abort makes it safe to create another primary on the phone.
@MainActor
func commitWorkoutHandoff(
    isCurrent: () -> Bool,
    finishLocal: () async throws -> Void,
    commit: () async throws -> Void,
    abort: () async throws -> Void
) async throws -> Bool {
    guard isCurrent() else { try await abort(); throw WorkoutOperationError.stale }
    do {
        try await finishLocal()
        guard isCurrent() else { throw WorkoutOperationError.stale }
        try await commit()
        return true
    } catch {
        do { try await abort() }
        catch { return false }
        throw error
    }
}
