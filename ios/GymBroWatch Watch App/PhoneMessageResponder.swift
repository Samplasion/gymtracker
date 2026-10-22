import Foundation
import WatchConnectivity

@MainActor
final class PhoneMessageResponder: NSObject {
    static let shared = PhoneMessageResponder()
    var workoutDelegate: WorkoutMessageDelegate? {
        didSet {
            if let cached = UserDefaults.standard.dictionary(forKey: "watch.receivedSnapshot.v2") {
                workoutDelegate?.apply(workoutSnapshot: cached["workout"] as? [String: Any] ?? [:])
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
    var session: WCSession?
    private var cursor = WatchSnapshotCursor(revision: (UserDefaults.standard.dictionary(forKey: "watch.receivedSnapshot.v2")?["revision"] as? NSNumber)?.int64Value ?? -1)

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
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
                    if WorkoutManager.shared.request?.id == id { WorkoutManager.shared.summary = .init(id: id, result: .failed(error.localizedDescription)) }
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
        self.session(session, didReceiveApplicationContext: info)
    }
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in self.workoutDelegate?.sessionReachabilityDidChange(session) }
    }
}
