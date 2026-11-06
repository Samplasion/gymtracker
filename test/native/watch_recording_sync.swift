import Foundation

@main
struct WatchRecordingSyncTests {
    @MainActor
    static func eventually(_ predicate: () -> Bool) async throws {
        for _ in 0..<1000 {
            if predicate() { return }
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        preconditionFailure("Condition did not become true")
    }

    @MainActor
    static func main() async throws {
        precondition(WorkoutSyncLimits.launch == 60 && WorkoutSyncLimits.command == 30)
        precondition((0...4).map(WorkoutSyncLimits.retry) == [15, 30, 60, 60, 60])
        let defaults = UserDefaults(suiteName: "gymbro.sync.tests.\(UUID())")!
        let controller = WatchRecordingController(defaults: defaults)
        let workout = WorkoutRequest(id: "A", start: Date(timeIntervalSince1970: 10))
        var reachable = true
        var running = false
        var created = 0
        var saved = 0
        var commands: [String] = []
        var generation: String?
        var loseCommitReply = true
        controller.canSend = { reachable }
        controller.command = { command in
            let action = command["action"] as! String
            commands.append(action)
            switch action {
            case "status": return ["success": true, "workoutId": "A", "exists": running, "running": running, "generation": generation ?? ""]
            case "prepare":
                created += 1
                generation = command["generation"] as? String
                return ["success": true, "generation": generation!]
            case "commit":
                running = true
                if loseCommitReply { loseCommitReply = false; throw WorkoutOperationError.timeout }
                return ["success": true]
            case "stop":
                if running && command["save"] as? Bool == true { saved += 1 }
                running = false
                return ["success": true]
            default: preconditionFailure("Unexpected \(action)")
            }
        }
        var pendingRetry = false
        controller.diagnostic = { if $0.contains("next reconciliation") { pendingRetry = true } }
        controller.start(workout)
        try await eventually { pendingRetry }
        precondition(controller.intent?.confirmation == .pending && running)
        precondition(created == 1 && saved == 0 && !commands.contains("abort"))
        let identity = controller.intent!.generation

        // A lost commit reply is recovered by status, never by preparing again.
        controller.reconnect()
        try await eventually { controller.intent?.confirmation == .confirmed }
        precondition(controller.intent?.generation == identity && created == 1 && saved == 0)
        reachable = false
        pendingRetry = false
        controller.reconnect()
        try await eventually { pendingRetry }
        precondition(controller.intent?.confirmation == .confirmed && running)
        precondition(created == 1 && saved == 0)

        // Terminal intent survives a process restart and an obsolete save ACK
        // cannot cancel a subsequent discard.
        var deferred: [[String: Any]] = []
        controller.deferFinish = { deferred.append($0) }
        controller.stop(id: "A", save: true)
        precondition(controller.intent?.confirmation == .finished && controller.pendingFinishes["A"] == true)
        let restored = WatchRecordingController(defaults: defaults)
        precondition(restored.pendingFinishes["A"] == true && restored.intent?.generation == identity)
        controller.stop(id: "A", save: false)
        controller.acknowledge(["success": true, "workoutId": "A", "save": true])
        precondition(controller.pendingFinishes["A"] == false)
        precondition(deferred.contains { $0["save"] as? Bool == false })
        reachable = true
        controller.reconnect()
        try await eventually { controller.pendingFinishes.isEmpty }
        precondition(saved == 0 && created == 1 && !running)

        // A confirmed recording explicitly reported ended is not restarted.
        let other = WatchRecordingController(defaults: UserDefaults(suiteName: "gymbro.sync.ended.\(UUID())")!)
        other.canSend = { true }
        other.command = { message in
            if message["action"] as? String == "stop" { return ["success": true] }
            precondition(message["action"] as? String == "status")
            return ["success": true, "workoutId": "B", "exists": false, "finished": true]
        }
        other.start(.init(id: "B", start: Date()))
        try await eventually { other.intent?.confirmation == .unavailable }
        other.stop(id: "B", save: false)

        let retrying = WatchRecordingController(defaults: UserDefaults(suiteName: "gymbro.sync.retry.\(UUID())")!)
        var retrySteps: [Int] = []
        var attempts = 0
        retrying.retryDelay = { step in retrySteps.append(step); return 0.002 }
        retrying.canSend = { true }
        retrying.command = { command in
            if command["action"] as? String == "stop" { return ["success": true] }
            precondition(command["action"] as? String == "status")
            attempts += 1
            if attempts <= 3 { throw WorkoutOperationError.timeout }
            return ["success": true, "workoutId": "retry", "running": true]
        }
        retrying.start(.init(id: "retry", start: Date()))
        try await eventually { retrying.intent?.confirmation == .confirmed }
        precondition(attempts == 4 && retrySteps == [0, 1, 2])
        retrying.stop(id: "retry", save: false)

        let switching = WatchRecordingController(defaults: UserDefaults(suiteName: "gymbro.sync.next.\(UUID())")!)
        var connected = false
        var order: [String] = []
        switching.canSend = { connected }
        switching.command = { command in
            let action = command["action"] as! String
            let id = command["workoutId"] as! String
            order.append("\(action):\(id)")
            if action == "status" { return ["success": true, "exists": false] }
            return ["success": true]
        }
        switching.stop(id: "old", save: true)
        switching.start(.init(id: "new", start: Date()))
        connected = true
        switching.reconnect()
        try await eventually { switching.intent?.confirmation == .confirmed }
        precondition(order == ["stop:old", "status:new", "prepare:new", "commit:new"])
        switching.acknowledge(["success": true, "workoutId": "old", "save": true])
        precondition(switching.intent?.request.id == "new" && switching.intent?.confirmation == .confirmed)
        switching.stop(id: "new", save: false)

        // Deadline cancellation releases a callback that never cooperates.
        let blocked = Task { @MainActor in
            try await workoutDeadline(60) {
                try await Task.sleep(nanoseconds: 60_000_000_000)
            }
        }
        await Task.yield()
        blocked.cancel()
        do { try await blocked.value; preconditionFailure("Expected cancellation") } catch is CancellationError {}

        let transport = WorkoutTransport()
        transport.timeout = 0.01
        transport.immediateAvailable = { true }
        var lateReply: (([String: Any]) -> Void)?
        transport.immediateSend = { _, reply, _ in lateReply = reply }
        do {
            _ = try await transport.request(["action": "status", "workoutId": "A"])
            preconditionFailure("Expected bounded transport timeout")
        } catch WorkoutOperationError.timeout {}
        lateReply?(["success": true]) // Must not resume the expired waiter twice.

        let phone = WorkoutTransport()
        let watch = WorkoutTransport()
        phone.mirrorAvailable = { true }
        watch.mirrorAvailable = { true }
        phone.mirrorSend = { data in
            _ = watch.receive(try JSONSerialization.jsonObject(with: data) as! [String: Any])
        }
        watch.mirrorSend = { data in
            _ = phone.receive(try JSONSerialization.jsonObject(with: data) as! [String: Any])
        }
        var mirroredCommands = 0
        watch.onCommand = { payload, reply in
            mirroredCommands += 1
            precondition(payload["workoutId"] as? String == "A")
            reply(["success": true, "running": true])
        }
        let response = try await phone.request(["action": "status", "workoutId": "A"])
        precondition(response["running"] as? Bool == true && mirroredCommands == 1)
        var receivedRevision: Int64?
        watch.onState = { _, revision in receivedRevision = revision }
        phone.publish(["id": "A"], revision: 42)
        try await eventually { receivedRevision == 42 }

        var cursor = WorkoutStateCursor()
        precondition(cursor.accept(20) && !cursor.accept(19) && !cursor.accept(20) && cursor.accept(21))
        print("Watch recording sync: lost replies, stable session, offline close/discard, persistence, cancellation and revisions passed")
    }
}
