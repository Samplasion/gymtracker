import Foundation
import Combine
import WatchConnectivity
import WatchKit

@MainActor
final class TrainingViewModel: ObservableObject {
    static let shared = TrainingViewModel()
    @Published private(set) var catalog: [String: Any]?
    @Published private(set) var active: [String: Any]?
    @Published private(set) var pending: [[String: Any]] = []
    @Published private(set) var connected = false
    @Published private(set) var syncing = false
    @Published var error: String?
    weak var workout: WorkoutViewModel?
    private var archive: WatchTrainingArchive?
    private var storage: [String: Any] = [:]
    func isFinished(_ id: String) -> Bool {
        (storage["finished"] as? [String: Bool])?["\(owner ?? "")/\(id)"] == true
    }
    private var dirty = false
    private var clockOffset: Int64 = 0
    private var bestClockRoundTrip = Int64.max
    private var transfer: String?
    private var timeout: Task<Void, Never>?
    var owner: String? { catalog?["ownerScope"] as? String }
    private init() {
        do { archive = try WatchTrainingArchive(); storage = archive!.value }
        catch { self.error = error.localizedDescription }
        catalog = storage["catalog"] as? [String: Any]
        active = storage["active"] as? [String: Any]
        pending = storage["pending"] as? [[String: Any]] ?? []
        dirty = active != nil
    }
    private func commit(_ next: [String: Any]) throws {
        guard let archive else { throw CocoaError(.fileWriteUnknown) }
        try archive.save(next)
        storage = next
        catalog = next["catalog"] as? [String: Any]
        active = next["active"] as? [String: Any]
        pending = next["pending"] as? [[String: Any]] ?? []
        error = nil
    }
    func receiveCatalog(_ next: [String: Any]) {
        guard next["version"] as? Int == 1, next["ownerScope"] is String,
              (next["generation"] as? Int ?? 0) >= (catalog?["generation"] as? Int ?? 0) else { return }
        if next["ownerScope"] as? String == owner,
           (next["generation"] as? Int ?? 0) == (catalog?["generation"] as? Int ?? 0),
           (next["revision"] as? Int64 ?? 0) < (catalog?["revision"] as? Int64 ?? 0) { return }
        do {
            var state = storage
            var previousSensorID: String?
            var accountChanged = false
            if let previous = owner, previous != next["ownerScope"] as? String {
                var sessions = state["sessions"] as? [String: [String: Any]] ?? [:]
                if let active {
                    sessions[previous] = active
                    previousSensorID = active["id"] as? String
                }
                state["sessions"] = sessions
                state["active"] = sessions[next["ownerScope"] as? String ?? ""]
                accountChanged = true
            }
            state["catalog"] = next
            try commit(state)
            if accountChanged {
                dirty = active != nil
                timeout?.cancel(); transfer = nil; syncing = false
                connected = false
                workout?.set(isWorkoutRunning: false, shouldSave: false)
                if let oldID = previousSensorID {
                    WorkoutManager.shared.enqueue {
                        if WorkoutManager.shared.request?.id == oldID { try? await WorkoutManager.shared.finishSegment(save: true) }
                    }
                }
            }
            refresh()
            flush()
        } catch { self.error = error.localizedDescription }
    }
    func start(_ routine: [String: Any]) {
        guard active == nil, let owner else { return }
        do {
            let document = try WatchTraining.start(routine: routine, owner: owner,
                weight: routine["weightUnit"] as? String ?? "kg", distance: routine["distanceUnit"] as? String ?? "km")
            var next = storage; next["active"] = document
            try commit(next)
            dirty = true; connected = false
            refresh()
            WorkoutManager.shared.enqueue {
                do { try await WorkoutManager.shared.startAutonomousWorkout(document) }
                catch { WorkoutManager.shared.phase = .failed(error.localizedDescription) }
            }
            flush()
        } catch { self.error = error.localizedDescription }
    }
    func perform(_ method: String, values: [String: Any] = [:]) {
        guard var document = active, document["ownerScope"] as? String == owner else { return }
        do {
            WatchTraining.perform(method, values: values, document: &document, now: WatchTraining.milliseconds() + clockOffset)
            var next = storage; next["active"] = document
            try commit(next)
            dirty = true; connected = false
            refresh()
            WKInterfaceDevice.current().play(.success)
            flush()
        } catch { self.error = error.localizedDescription; WKInterfaceDevice.current().play(.failure) }
    }
    func mirrorRemoteCommand(_ method: String, values: [String: Any], workoutID: String, setID: String?) {
        guard var document = active, document["id"] as? String == workoutID,
              document["cursor"] as? String == setID else { return }
        // Keep an immediately usable offline shadow without inventing a newer
        // edit than the phone operation that was just acknowledged.
        let stamps = document["stamps"], sequence = document["sequence"], modified = document["modified"]
        WatchTraining.perform(method, values: values, document: &document, now: WatchTraining.milliseconds() + clockOffset)
        document["stamps"] = stamps; document["sequence"] = sequence; document["modified"] = modified
        do {
            var next = storage; next["active"] = document
            next.removeValue(forKey: "sent")
            try commit(next)
            refresh()
        } catch { self.error = error.localizedDescription }
    }

    func finish(save: Bool) {
        guard var document = active else { return }
        do {
            document["status"] = save ? "completed" : "discarded"
            let end = WatchTraining.milliseconds() + clockOffset
            document["end"] = end
            document["duration"] = WatchTraining.elapsedDuration(document, endingAt: end)
            var next = storage
            var queue = pending; queue.append(document)
            next["pending"] = queue
            next.removeValue(forKey: "active")
            var sessions = next["sessions"] as? [String: [String: Any]] ?? [:]
            sessions.removeValue(forKey: owner ?? "")
            next["sessions"] = sessions
            var finished = next["finished"] as? [String: Bool] ?? [:]
            finished["\(owner ?? "")/\(document["id"] as? String ?? "")"] = true
            next["finished"] = finished
            try commit(next)
            dirty = false; connected = false
            timeout?.cancel(); transfer = nil; syncing = false
            workout?.set(isWorkoutRunning: false, shouldSave: save)
            WorkoutManager.shared.enqueue {
                _ = try? await WorkoutManager.shared.handleSensorCommand([
                    "action": "stop", "workoutId": document["id"] ?? "", "save": save,
                ])
            }
            flush()
        } catch { self.error = error.localizedDescription }
    }
    func receiveContext(_ context: [String: Any]) {
        guard context["version"] as? Int == 1 else { return }
        if let catalog = context["catalog"] as? [String: Any] { receiveCatalog(catalog) }
        if let scope = context["ownerScope"] as? String, scope != owner,
           (context["generation"] as? Int ?? 0) > (catalog?["generation"] as? Int ?? 0) {
            receiveCatalog(["version": 1, "ownerScope": scope, "generation": context["generation"] ?? 0,
                "routines": [], "folders": []])
        }
        guard context["ownerScope"] as? String == owner else { return }
        if let document = context["session"] as? [String: Any], document["status"] as? String != "active" {
            acknowledge(["accepted": true, "terminal": true, "ownerScope": document["ownerScope"] ?? "", "id": document["id"] ?? "", "document": document])
        }
        if let document = context["session"] as? [String: Any], document["status"] as? String == "active" {
            // A dirty local copy must first be reconciled on the phone.
            if !dirty && !syncing { accept(document) }
        }
        flush()
    }
    private func accept(_ document: [String: Any], acknowledged: Bool = false) {
        guard document["ownerScope"] as? String == owner,
              !isFinished(document["id"] as? String ?? ""),
              pending.allSatisfy({ $0["id"] as? String != document["id"] as? String }),
              active == nil || active?["id"] as? String == document["id"] as? String,
              (document["epoch"] as? Int ?? 0) >= (active?["epoch"] as? Int ?? 0),
              WatchTraining.acceptsSnapshot(document, after: active, acknowledged: acknowledged) else { return }
        do {
            var next = storage; next["active"] = document
            try commit(next)
            dirty = false; connected = true
            timeout?.cancel(); transfer = nil; syncing = false
            refresh()
        } catch { self.error = error.localizedDescription }
    }
    func acknowledge(_ response: [String: Any]) {
        guard response["accepted"] as? Bool == true, response["ownerScope"] as? String == owner else { return }
        if response["terminal"] as? Bool == true, let id = response["id"] as? String {
            do {
                var next = storage
                var finished = next["finished"] as? [String: Bool] ?? [:]
                finished["\(owner ?? "")/\(id)"] = true
                next["finished"] = finished
                var sessions = next["sessions"] as? [String: [String: Any]] ?? [:]
                if sessions[owner ?? ""]?["id"] as? String == id { sessions.removeValue(forKey: owner ?? "") }
                next["sessions"] = sessions
                next["pending"] = pending.filter { $0["id"] as? String != id || $0["ownerScope"] as? String != owner }
                let closesActive = active?["id"] as? String == id
                let closesDisplay = workout?.workoutID == id
                if closesActive { next.removeValue(forKey: "active") }
                if closesActive || closesDisplay { next.removeValue(forKey: "sent") }
                try commit(next)
                if closesActive || closesDisplay {
                    timeout?.cancel(); transfer = nil; syncing = false; connected = false; dirty = false
                    workout?.set(isWorkoutRunning: false, shouldSave: (response["document"] as? [String: Any])?["status"] as? String != "discarded")
                }
                for transfer in WCSession.default.outstandingUserInfoTransfers {
                    let queued = transfer.userInfo["document"] as? [String: Any]
                    if queued?["id"] as? String == id && queued?["ownerScope"] as? String == owner { transfer.cancel() }
                }
            } catch { self.error = error.localizedDescription }
        } else if let document = response["document"] as? [String: Any],
                  response["transferID"] as? String == transfer ||
                    ((response["sourceSequence"] as? Int) == (active?["sequence"] as? Int) &&
                     (response["sourceModified"] as? Int64) == (active?["modified"] as? Int64)) {
            // Only a reply to this exact immutable outgoing state can hand off.
            if let sent = storage["sent"] as? [String: Any], let active,
               WatchTraining.matchesOutgoing(sent, active: active) {
                accept(document, acknowledged: true)
            }
        }
    }
    func flush() {
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        if !session.isReachable { connected = false }
        for entry in pending where entry["ownerScope"] as? String == owner {
            let message = WatchTraining.propertyList(["method": "trainingSync", "document": entry])
            if let data = try? JSONSerialization.data(withJSONObject: message), data.count > 35_000 {
                sendFile(document: entry, session: session)
                if session.isReachable, let terminal = WatchTraining.immediateDocument(entry) {
                    session.sendMessage(WatchTraining.propertyList(["method": "trainingSync", "document": terminal]), replyHandler: { response in
                        Task { @MainActor in self.acknowledge(response) }
                    }, errorHandler: { _ in })
                }
                continue
            }
            if !session.outstandingUserInfoTransfers.contains(where: {
                let queued = $0.userInfo["document"] as? [String: Any]
                return queued?["id"] as? String == entry["id"] as? String && queued?["ownerScope"] as? String == owner
            }) { session.transferUserInfo(message) }
            // The durable outbox is a fallback, not the only delivery path.
            // WatchConnectivity can defer user-info transfers even with an open
            // phone app; discard/completion should close that ongoing promptly.
            if session.isReachable {
                session.sendMessage(message, replyHandler: { response in
                    Task { @MainActor in self.acknowledge(response) }
                }, errorHandler: { _ in })
            }
        }
        guard !syncing, (dirty || !connected), var document = active,
              document["ownerScope"] as? String == owner else { return }
        let previous = storage["sent"] as? [String: Any]
        let sameState = previous?["id"] as? String == document["id"] as? String &&
            previous?["sequence"] as? Int == document["sequence"] as? Int &&
            previous?["modified"] as? Int64 == document["modified"] as? Int64 &&
            previous?["cursor"] as? String == document["cursor"] as? String
        let token = sameState ? (previous?["transferID"] as? String ?? UUID().uuidString) : UUID().uuidString
        document["transferID"] = token
        do { var next = storage; next["sent"] = document; try commit(next) }
        catch { self.error = error.localizedDescription; return }
        if let data = try? JSONSerialization.data(withJSONObject: document), data.count > 35_000 {
            sendFile(document: document, session: session)
            return
        }
        // Active sessions must survive an unreachable or not-yet-ready Flutter
        // engine, just like the terminal outbox. Keep only the newest queued copy.
        var queued = false
        for delivery in session.outstandingUserInfoTransfers {
            guard let old = delivery.userInfo["document"] as? [String: Any],
                  old["status"] as? String == "active",
                  old["id"] as? String == document["id"] as? String,
                  old["ownerScope"] as? String == owner else { continue }
            if old["transferID"] as? String == token { queued = true }
            else { delivery.cancel() }
        }
        if !queued { session.transferUserInfo(WatchTraining.propertyList(["method": "trainingSync", "document": document])) }
        guard session.isReachable else { return }
        transfer = token; syncing = true
        let sentAt = WatchTraining.milliseconds()
        timeout?.cancel()
        timeout = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            guard !Task.isCancelled, self.transfer == token else { return }
            self.syncing = false; self.connected = self.connected && session.isReachable; self.transfer = nil
        }
        session.sendMessage(WatchTraining.propertyList(["method": "trainingSync", "document": document]), replyHandler: { response in
            Task { @MainActor in
                guard self.transfer == token else { return }
                self.timeout?.cancel(); self.syncing = false
                let receivedAt = WatchTraining.milliseconds()
                let roundTrip = receivedAt - sentAt
                if let server = response["serverTime"] as? NSNumber, roundTrip < self.bestClockRoundTrip {
                    self.clockOffset = server.int64Value - (sentAt + receivedAt) / 2
                    self.bestClockRoundTrip = roundTrip
                }
                var reply = response; reply["transferID"] = token
                self.acknowledge(reply)
                // A busy/rejected exchange is not a lost WatchConnectivity link.
                if !session.isReachable { self.connected = false }
            }
        }, errorHandler: { _ in
            Task { @MainActor in
                guard self.transfer == token else { return }
                self.timeout?.cancel(); self.syncing = false; self.connected = self.connected && session.isReachable
            }
        })
    }
    private func sendFile(document: [String: Any], session: WCSession) {
        let id = document["id"] as? String ?? ""
        guard !session.outstandingFileTransfers.contains(where: {
            $0.file.metadata?["id"] as? String == id && $0.file.metadata?["ownerScope"] as? String == owner
        }) else { return }
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("training-\(UUID().uuidString).json")
            try JSONSerialization.data(withJSONObject: document).write(to: url, options: .atomic)
            session.transferFile(url, metadata: ["kind": "trainingDocument", "id": id, "ownerScope": owner ?? ""])
        } catch { self.error = error.localizedDescription }
    }
    func refresh() {
        // Connected rendering comes exclusively from the revisioned compact snapshot.
        // Full documents update the durable offline shadow, never an older UI cursor.
        if connected && workout?.isWorkoutRunning == true && workout?.workoutID == active?["id"] as? String { return }
        guard let active, active["ownerScope"] as? String == owner, let workout else { return }
        workout.workoutID = active["id"] as? String
        workout.workoutStart = (active["time"] as? NSNumber).map { Date(milliseconds: $0.int64Value) }
        if WorkoutManager.shared.request == nil, let id = workout.workoutID, let start = workout.workoutStart {
            // A restored app session may exist even when HealthKit was denied.
            // Recovery can attach a live sensor session later; do not show an
            // endless "starting" state when there is no recording to recover.
            WorkoutManager.shared.selectWorkout(.init(id: id, start: start))
        }
        workout.set(isWorkoutRunning: true, shouldSave: true)
        let cursor = active["cursor"] as? String
        let exercise = WatchTraining.exercises(active).first { ($0["sets"] as? [[String: Any]] ?? []).contains { $0["id"] as? String == cursor } }
        workout.hasNextSet = exercise != nil
        workout.exerciseName = exercise?["name"] as? String ?? ""
        workout.exerciseID = exercise?["id"] as? String ?? ""
        let notes = WatchTraining.notes(forSet: cursor, in: active)
        workout.exerciseNotes = notes.exercise
        workout.supersetNotes = notes.superset
        workout.exerciseColor = (exercise?["wearableColor"] as? NSNumber)?.int64Value ?? 0
        workout.set = cursor.flatMap { WatchTraining.set($0, in: active) }.flatMap { GTSet.decode(from: $0) }
        workout.setTypeLabel = cursor.map { WatchTraining.setLabel(forSet: $0, in: active, italian: Locale.current.languageCode == "it") } ?? ""
        if let set = workout.set {
            var parts: [String] = []
            if set.parameters.hasReps { parts.append("\(set.reps ?? 0) ×") }
            if set.parameters.hasWeight { parts.append("\((set.weight ?? 0).formatted()) \(active["weightUnit"] as? String ?? "kg")") }
            if set.parameters.hasTime { parts.append("\(Int(set.time ?? 0)) s") }
            if set.parameters.hasDistance { parts.append("\((set.distance ?? 0).formatted()) \(active["distanceUnit"] as? String ?? "km")") }
            workout.exerciseParameters = parts.joined(separator: " ")
        }
        workout.restTimeEnd = (active["restEnd"] as? NSNumber).map { Date(milliseconds: $0.int64Value) }
    }
}
