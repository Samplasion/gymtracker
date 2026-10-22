import Foundation
import Combine
import WatchConnectivity
import WatchKit
import WidgetKit

enum WorkoutState {
    case notStarted, running, paused, ended, cancelled
    var isRunning: Bool { self == .running }
}

@MainActor
final class WorkoutViewModel: NSObject, ObservableObject {
    @Published var isWorkoutRunning = false
    @Published var hasNextSet = false
    @Published var exerciseName = ""
    @Published var exerciseColor: Int64 = 0
    @Published var exerciseParameters = ""
    @Published var setTypeLabel = ""
    @Published var workoutStart: Date?
    @Published var isLoading = false
    @Published var state: WorkoutState = .notStarted
    @Published var set: GTSet?
    @Published var workoutID: String?
    @Published var restTimeEnd: Date? {
        didSet {
            guard oldValue != restTimeEnd else { return }
            vibrationTask?.cancel()
            guard let date = restTimeEnd, date > Date() else { return }
            vibrationTask = Task { @MainActor in
                do { try await Task.sleep(nanoseconds: UInt64(max(0, date.timeIntervalSinceNow) * 1_000_000_000)) }
                catch { return }
                guard !Task.isCancelled else { return }
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }
    var session: WCSession
    private var vibrationTask: Task<Void, Never>?
    private var requestTask: Task<Void, Never>?
    private var pendingRequest: UUID?

    init(session: WCSession = .default) { self.session = session; super.init() }

    func markThisSetAsDone() { perform("markThisSetAsDone") }
    func moveWorkoutCursorNext() { perform("moveWorkoutCursorNext") }
    func moveWorkoutCursorPrevious() { perform("moveWorkoutCursorPrevious") }
    func updateSetParameters(weight: Double?, time: TimeInterval?, reps: Int?, distance: Double?) {
        var values: [String: Any] = [:]
        if let weight { values["weight"] = weight }
        if let time { values["time"] = time }
        if let reps { values["reps"] = reps }
        if let distance { values["distance"] = distance }
        perform("updateSetParameters", values: values)
    }

    private func perform(_ method: String, values: [String: Any] = [:]) {
        guard !isLoading, state.isRunning, hasNextSet, let id = workoutID else { return }
        guard session.isReachable else { WKInterfaceDevice.current().play(.failure); return }
        let token = UUID()
        let setID = set?.id
        pendingRequest = token
        isLoading = true
        var message = values
        message["method"] = method
        message["workoutId"] = id
        message["setId"] = setID
        let complete: (Bool) -> Void = { success in
            Task { @MainActor in
                guard self.pendingRequest == token, self.workoutID == id else { return }
                self.pendingRequest = nil
                self.requestTask?.cancel()
                self.isLoading = false
                // A reply for an old set must not provide misleading feedback.
                if self.set?.id == setID { WKInterfaceDevice.current().play(success ? .success : .failure) }
            }
        }
        requestTask = Task { @MainActor in
            do { try await Task.sleep(nanoseconds: 10_000_000_000) }
            catch { return }
            complete(false)
        }
        session.sendMessage(message, replyHandler: { complete($0["success"] as? Bool == true) }, errorHandler: { _ in complete(false) })
    }

    private func cancelPendingRequest() {
        pendingRequest = nil
        requestTask?.cancel()
        isLoading = false
    }

    func requestFreshData() {
        guard session.isReachable else { return }
        session.sendMessage(["method": "requestTrainingData"], replyHandler: nil, errorHandler: { _ in })
    }
}

extension WorkoutViewModel: WorkoutMessageDelegate {
    func apply(workoutSnapshot: [String: Any]) {
        guard let id = workoutSnapshot["id"] as? String,
              let active = workoutSnapshot["active"] as? Bool else { return }
        if workoutID != id {
            cancelPendingRequest()
            restTimeEnd = nil
            set = nil
            hasNextSet = false
            exerciseName = ""
            exerciseParameters = ""
            workoutID = id
        }
        if let start = (workoutSnapshot["start"] as? NSNumber)?.int64Value { workoutStart = Date(milliseconds: start) }
        if let parameters = workoutSnapshot["parameters"] as? [String: Any],
           let decoded = NativeWorkoutStateMessage.decodeWorkoutState(from: parameters) { self.set(exerciseParameters: decoded) }
        self.set(isWorkoutRunning: active, shouldSave: workoutSnapshot["save"] as? Bool ?? true)
    }

    func set(isWorkoutRunning: Bool, shouldSave: Bool) {
        let wasRunning = self.isWorkoutRunning
        self.isWorkoutRunning = isWorkoutRunning
        if isWorkoutRunning { state = .running }
        else {
            cancelPendingRequest()
            restTimeEnd = nil
            if !shouldSave { state = .cancelled }
            else if wasRunning || state == .ended { state = .ended }
            else { state = .notStarted }
        }
    }

    func set(exerciseParameters: NativeWorkoutStateMessage) {
        hasNextSet = exerciseParameters.hasExercise
        exerciseName = exerciseParameters.exerciseName
        exerciseColor = exerciseParameters.exerciseColor
        self.exerciseParameters = exerciseParameters.exerciseParameters
        setTypeLabel = exerciseParameters.setTypeLabel
        restTimeEnd = exerciseParameters.restTimeEnd
        workoutStart = exerciseParameters.startingTime
        set = exerciseParameters.set
    }

    func update(widgetParameters: [String: Int64], workoutDensityChartData: [Int64]) {
        guard let defaults = UserDefaults(suiteName: "group.samplasion.gymtracker") else { return }
        for (key, value) in widgetParameters { defaults.set(value, forKey: key) }
        defaults.set(workoutDensityChartData, forKey: "workout_density_chart_data")
        WidgetCenter.shared.reloadAllTimelines()
    }
    func sessionReachabilityDidChange(_ session: WCSession) { if session.isReachable { requestFreshData() } }
}
