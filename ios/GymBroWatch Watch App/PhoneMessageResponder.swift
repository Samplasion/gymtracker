import Foundation
import WatchConnectivity

@MainActor
final class PhoneMessageResponder: NSObject {
    static let shared = PhoneMessageResponder()
    var workoutDelegate: WorkoutMessageDelegate? {
        didSet {
            if let cached = UserDefaults.standard.dictionary(forKey: "watch.receivedSnapshot.v2") {
                let workout = cached["workout"] as? [String: Any] ?? [:]
                workoutDelegate?.apply(workoutSnapshot: workout)
                if let id = workout["id"] as? String, let start = (workout["start"] as? NSNumber)?.int64Value {
                    WorkoutManager.shared.selectWorkout(.init(id: id, start: Date(milliseconds: start)))
                }
            }
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

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            if self.receiveWaterAcknowledgement(message) { return }
            if message["method"] as? String == "snapshot", let snapshot = message["data"] as? [String: Any] {
                self.apply(snapshot)
            } else if message["method"] as? String == "updateHomeWidgetParameters",
                      let parameters = message["value"] as? [String: Int64], let chart = message["workoutDensityChartData"] as? [Int64] {
                self.workoutDelegate?.update(widgetParameters: parameters, workoutDensityChartData: chart)
            }
        }
    }

    nonisolated func receiveCommand(_ message: [String: Any], reply: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            guard message["method"] as? String == "workoutSensor" else { reply(["success": false]); return }
            WorkoutManager.shared.enqueue {
                do { reply(try await WorkoutManager.shared.handleSensorCommand(message)) }
                catch {
                    let id = message["workoutId"] as? String ?? ""
                    if WorkoutManager.shared.request?.id == id {
                        WorkoutManager.shared.phase = .failed(error.localizedDescription)
                        WorkoutManager.shared.summary = .init(id: id, result: .failed(error.localizedDescription))
                    }
                    reply(["success": false, "error": error.localizedDescription])
                }
            }
        }
    }

    private func apply(_ snapshot: [String: Any]) {
        guard cursor.accept(snapshot) else { return }
        UserDefaults.standard.set(snapshot, forKey: "watch.receivedSnapshot.v2")
        if let workout = snapshot["workout"] as? [String: Any] {
            workoutDelegate?.apply(workoutSnapshot: workout)
            if let id = workout["id"] as? String, let start = (workout["start"] as? NSNumber)?.int64Value {
                WorkoutManager.shared.selectWorkout(.init(id: id, start: Date(milliseconds: start)))
                if let metrics = workout["metrics"] as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: metrics) {
                    try? WorkoutManager.shared.handleReceivedData(data)
                }
            }
            if workout["active"] as? Bool == false, let id = workout["id"] as? String {
                // Deferred delivery also closes a workout when direct messages failed.
                WorkoutManager.shared.enqueue {
                    _ = try? await WorkoutManager.shared.handleSensorCommand(["action": "stop", "workoutId": id, "save": workout["save"] as? Bool ?? false])
                }
            }
        }
        if let food = snapshot["food"] as? [String: Any], let decoded = NativeFoodStateMessage.decodeFoodState(from: food) { foodDelegate?.set(foodParameters: decoded) }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        Task { @MainActor in
            if context["version"] as? Int == 2 { self.apply(context) }
            else if self.cursor.revision < 0, context["kind"] as? String == "food",
                    let parameters = context["parameters"] as? [String: Any],
                    let decoded = NativeFoodStateMessage.decodeFoodState(from: parameters) { self.foodDelegate?.set(foodParameters: decoded) }
        }
    }
    nonisolated func session(_ session: WCSession, didReceiveUserInfo info: [String: Any]) {
        Task { @MainActor in
            if !self.receiveWaterAcknowledgement(info) { self.session(session, didReceiveApplicationContext: info) }
        }
    }
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.workoutDelegate?.sessionReachabilityDidChange(session)
            if session.isReachable { self.foodDelegate?.flushWaterEntries() }
        }
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
