import Foundation
import WatchConnectivity
import HealthKit

@MainActor
final class PhoneMessageResponder: NSObject {
    static let shared = PhoneMessageResponder()
    var workoutDelegate: WorkoutMessageDelegate? {
        didSet {
            if let cached = UserDefaults.standard.dictionary(forKey: "watch.receivedWorkoutState.v1"),
               let workout = cached["workout"] as? [String: Any] { applyWorkout(workout) }
            else if let cached = UserDefaults.standard.dictionary(forKey: "watch.receivedSnapshot.v2"),
                    let workout = cached["workout"] as? [String: Any] { applyWorkout(workout) }
        }
    }
    var foodDelegate: FoodMessageDelegate? {
        didSet {
            if let cached = UserDefaults.standard.dictionary(forKey: "watch.receivedSnapshot.v2"),
               let food = cached["food"] as? [String: Any],
               let decoded = NativeFoodStateMessage.decodeFoodState(from: food) { foodDelegate?.set(foodParameters: decoded) }
        }
    }
    private var sendingWater: Set<String> = []
    var session: WCSession?
    private var cursor = WatchSnapshotCursor(revision: (UserDefaults.standard.dictionary(forKey: "watch.receivedSnapshot.v2")?["revision"] as? NSNumber)?.int64Value ?? -1)
    private var workoutRevision: Int64 = (UserDefaults.standard.dictionary(forKey: "watch.receivedWorkoutState.v1")?["revision"] as? NSNumber)?.int64Value ?? -1
    private var commands: [String: [([String: Any]) -> Void]] = [:]
    var hasPendingCommands: Bool { !commands.isEmpty }
    var onWorkFinished: (() -> Void)?

    func receiveMessage(_ message: [String: Any]) {
        if WorkoutManager.shared.transport.receive(message) { return }
        if message["method"] as? String == "trainingAcknowledged" { TrainingViewModel.shared.acknowledge(message); return }
        if receiveWaterAcknowledgement(message) { return }
        if message["method"] as? String == "snapshot", let snapshot = message["data"] as? [String: Any] {
            receiveContext(snapshot)
        } else if message["method"] as? String == "updateHomeWidgetParameters",
                  let parameters = message["value"] as? [String: Int64], let chart = message["workoutDensityChartData"] as? [Int64] {
            workoutDelegate?.update(widgetParameters: parameters, workoutDensityChartData: chart)
        }
    }

    func receiveCommand(_ message: [String: Any], reply: @escaping ([String: Any]) -> Void) {
        let action = message["action"] as? String ?? "unknown"
        let id = message["workoutId"] as? String ?? "unknown"
        let key = message["requestId"] as? String ?? UUID().uuidString
        if commands[key] != nil { commands[key]?.append(reply); return }
        commands[key] = [reply]
        let manager = WorkoutManager.shared
        manager.diagnostic("Watch received command=\(action) workout=\(id); queued")
        let operation: @MainActor () async -> Void = {
            var response: [String: Any]
            do {
                guard !ScreenshotMode.enabled, message["method"] as? String == "workoutSensor" else {
                    throw WorkoutOperationError.unavailable
                }
                response = try await workoutDiagnosticOperation("Watch command=\(action) workout=\(id)", diagnostic: manager.diagnostic) {
                    try await manager.handleSensorCommand(message)
                }
            } catch {
                let permanent = manager.healthStore.authorizationStatus(for: .workoutType()) == .sharingDenied
                if permanent && manager.request?.id == id { manager.phase = .failed(error.localizedDescription) }
                response = ["success": false, "error": error.localizedDescription, "permanent": permanent]
            }
            response["workoutId"] = id
            response["requestId"] = key
            let callbacks = self.commands.removeValue(forKey: key) ?? []
            for callback in callbacks { callback(response) }
            self.onWorkFinished?()
        }
        // Status cannot sit behind a delayed HealthKit collection callback;
        // it only observes/reconnects and never mutates sensor ownership.
        if action == "status" { Task { @MainActor in await operation() } }
        else { manager.enqueue(operation) }
    }

    func receiveWorkoutState(_ workout: [String: Any], revision: Int64) {
        guard revision > workoutRevision else { return }
        workoutRevision = revision
        UserDefaults.standard.set(["revision": revision, "workout": workout], forKey: "watch.receivedWorkoutState.v1")
        applyWorkout(workout)
    }

    private func applyWorkout(_ workout: [String: Any]) {
        workoutDelegate?.apply(workoutSnapshot: workout)
        if workout["active"] as? Bool == true, case .idle = WorkoutManager.shared.phase {
            WorkoutManager.shared.phase = .starting
        }
        if let id = workout["id"] as? String, let start = (workout["start"] as? NSNumber)?.int64Value {
            if TrainingViewModel.shared.active == nil || TrainingViewModel.shared.active?["id"] as? String == id {
                WorkoutManager.shared.selectWorkout(.init(id: id, start: Date(milliseconds: start)))
            }
            if let metrics = workout["metrics"] as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: metrics) {
                try? WorkoutManager.shared.handleReceivedData(data)
            }
        }
        if workout["active"] as? Bool == false, let id = workout["id"] as? String {
            let save = workout["save"] as? Bool ?? false
            receiveCommand(["method": "workoutSensor", "action": "stop", "workoutId": id,
                            "save": save, "requestId": "\(id):stop:\(save)"]) { response in
                self.sendTerminalAcknowledgement(response)
            }
        }
    }

    func receiveContext(_ context: [String: Any]) {
        if context["version"] as? Int == 2 {
            guard cursor.accept(context) else { return }
            if let training = context["training"] as? [String: Any] { TrainingViewModel.shared.receiveContext(training) }
            UserDefaults.standard.set(context, forKey: "watch.receivedSnapshot.v2")
            if let workout = context["workout"] as? [String: Any], let revision = (context["revision"] as? NSNumber)?.int64Value {
                receiveWorkoutState(workout, revision: revision)
            }
            if let food = context["food"] as? [String: Any], let decoded = NativeFoodStateMessage.decodeFoodState(from: food) { foodDelegate?.set(foodParameters: decoded) }
        } else if cursor.revision < 0, context["kind"] as? String == "food",
                  let parameters = context["parameters"] as? [String: Any],
                  let decoded = NativeFoodStateMessage.decodeFoodState(from: parameters) { foodDelegate?.set(foodParameters: decoded) }
    }

    func receiveUserInfo(_ info: [String: Any]) {
        if info["method"] as? String == "workoutSensor", info["action"] as? String == "stop" {
            receiveCommand(info) { self.sendTerminalAcknowledgement($0) }
            return
        }
        if info["method"] as? String == "trainingAcknowledged" { TrainingViewModel.shared.acknowledge(info); return }
        if !receiveWaterAcknowledgement(info) { receiveContext(info) }
    }

    private func sendTerminalAcknowledgement(_ response: [String: Any]) {
        guard response["success"] as? Bool == true, let session, session.activationState == .activated else { return }
        var message = response
        message["method"] = "workoutTerminalAcknowledged"
        if !session.outstandingUserInfoTransfers.contains(where: { $0.userInfo["requestId"] as? String == message["requestId"] as? String }) {
            session.transferUserInfo(message)
        }
        if session.isReachable { session.sendMessage(message, replyHandler: nil, errorHandler: { _ in }) }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        workoutDelegate?.sessionReachabilityDidChange(session)
        TrainingViewModel.shared.flush()
        WorkoutManager.shared.transport.flush()
        if session.isReachable { foodDelegate?.flushWaterEntries() }
    }
    func sendWater(_ entry: WatchWaterEntry) {
        guard let session, session.activationState == .activated else { return }
        if !session.outstandingUserInfoTransfers.contains(where: {
            $0.userInfo["method"] as? String == "addWater" &&
            $0.userInfo["id"] as? String == entry.id && $0.userInfo["ownerScope"] as? String == entry.ownerScope
        }) { session.transferUserInfo(entry.message) }
        guard session.isReachable, sendingWater.insert(entry.id).inserted else { return }
        session.sendMessage(entry.message, replyHandler: nil, errorHandler: { _ in })
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in self?.sendingWater.remove(entry.id) }
    }

    private func receiveWaterAcknowledgement(_ message: [String: Any]) -> Bool {
        guard message["method"] as? String == "waterAcknowledged",
              let ids = message["ids"] as? [String], let scope = message["ownerScope"] as? String else { return false }
        foodDelegate?.acknowledgeWater(ids: Set(ids), ownerScope: scope)
        for transfer in session?.outstandingUserInfoTransfers ?? [] {
            if let id = transfer.userInfo["id"] as? String, ids.contains(id),
               transfer.userInfo["ownerScope"] as? String == scope { transfer.cancel() }
        }
        return true
    }

}
