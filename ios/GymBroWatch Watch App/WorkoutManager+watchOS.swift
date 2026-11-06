import Foundation
import os
import HealthKit

@available(watchOS 9, *)
extension WorkoutManager {
    func startAutonomousWorkout(_ document: [String: Any]) async throws {
        guard let id = document["id"] as? String, let start = document["time"] as? NSNumber else { return }
        if let session {
            if request?.id == id && (session.state == .running || session.state == .paused) { return }
            throw WorkoutOperationError.unavailable
        }
        let request = WorkoutRequest(id: id, start: Date(milliseconds: start.int64Value))
        selectWorkout(request)
        phase = .starting
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        let primary = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        let token = UUID().uuidString
        attachPrimary(primary, request: request, generation: token)
        try await builder?.addMetadata([HKMetadataKeyExternalUUID: id, "gymbro.segmentId": token])
        persistWatchIdentity()
        try await commitPrimary(at: request.start)
        rememberRecordingStarted(id)
        phase = .active
        await ensureWorkoutMirroring()
    }

    /// Phone-controlled sensor starts use a bounded prepare/commit handshake.
    /// Exercise snapshots never start, resume, or end HealthKit sessions.
    func handleSensorCommand(_ command: [String: Any]) async throws -> [String: Any] {
        guard let id = command["workoutId"] as? String,
              let action = command["action"] as? String else { throw WorkoutOperationError.stale }
        var fence = (UserDefaults.standard.data(forKey: "workout.commandFence.v2")
            .flatMap { try? JSONDecoder().decode(WorkoutCommandFence.self, from: $0) }) ?? WorkoutCommandFence()
        if session == nil, let recovered = try? await healthStore.recoverActiveWorkoutSession() {
            try await recoverWorkout(with: recovered)
        }
        if action == "status" {
            await ensureWorkoutMirroring()
            var reply = sensorReply(running: request?.id == id && collectionStarted && (session?.state == .running || session?.state == .paused))
            reply["workoutId"] = id
            reply["exists"] = request?.id == id && session != nil && session?.state != .ended && session?.state != .stopped
            reply["busy"] = request?.id != id && session != nil
            let hasStarted = (UserDefaults.standard.stringArray(forKey: "workout.startedWatchIDs.v1") ?? []).contains(id)
            reply["finished"] = fence.finished.contains(id) || (hasStarted && (session == nil || request?.id != id))
                || (request?.id == id && (session?.state == .ended || session?.state == .stopped))
            if healthStore.authorizationStatus(for: .workoutType()) == .sharingDenied {
                reply["permanent"] = true
                reply["error"] = "Allow Gym Bro to record workouts in Health settings on your Watch."
            }
            return reply
        }
        if action == "stop" {
            fence.finish(id: id)
            UserDefaults.standard.set(try? JSONEncoder().encode(fence), forKey: "workout.commandFence.v2")
            let save = command["save"] as? Bool ?? false
            if !save { markDiscarded(id) }
            if request?.id == id {
                // Prepared sessions have no recorded activity and must never be
                // turned into one-second Fitness workouts by a delayed stop.
                let started = session?.state == .running || session?.state == .paused || session?.state == .stopped
                    || (UserDefaults.standard.stringArray(forKey: "workout.startedWatchIDs.v1") ?? []).contains(id)
                try await finishSegment(save: save && started)
            }
            else if save && summary?.id != id {
                summary = .init(id: id, result: .failed("There is no Watch recording for this workout. Your workout is available in the iPhone app."))
            }
            if !save { try await deleteSavedSegments(id: id) }
            if request?.id == id { stopMonitoringMetrics() }
            return ["success": true, "workoutId": id, "save": save]
        }
        guard let token = command["generation"] as? String else { throw WorkoutOperationError.stale }
        if action == "abort" {
            // A transport timeout from an older peer cannot discard an active
            // recording. Only a prepared, never-started session may be aborted.
            if request?.id == id && generation == token,
               session?.state == .prepared || session?.state == .notStarted { try await finishSegment(save: false) }
            return ["success": true]
        }
        if request?.id == id, session?.state == .running || session?.state == .paused {
            return sensorReply(running: true)
        }
        guard let deadline = command["deadline"] as? Double,
              Date().timeIntervalSince1970 <= deadline, !discardedWorkoutIDs.contains(id) else { throw WorkoutOperationError.stale }
        if action == "prepare" {
            guard fence.prepare(id: id, revision: (command["revision"] as? NSNumber)?.int64Value ?? 0) else { throw WorkoutOperationError.stale }
            UserDefaults.standard.set(try? JSONEncoder().encode(fence), forKey: "workout.commandFence.v2")
            if session == nil, let recovered = try? await healthStore.recoverActiveWorkoutSession() {
                diagnostic("workout=\(id) Watch recovering existing HealthKit session")
                try await recoverWorkout(with: recovered)
            }
            if request?.id == id, let metrics = command["metrics"] as? [String: Any],
               let data = try? JSONSerialization.data(withJSONObject: metrics) { try handleReceivedData(data) }
            if let session, request?.id == id, session.state == .running || session.state == .paused {
                phase = .active
                return sensorReply(running: true)
            }
            if request?.id == id && generation == token && session != nil {
                phase = .starting
                return sensorReply(running: false)
            }
            // A different session is not permission to save/replace it.
            guard session == nil else { throw WorkoutOperationError.unavailable }
            guard Date().timeIntervalSince1970 <= deadline else { throw WorkoutOperationError.stale }
            let request = WorkoutRequest(id: id, start: Date(timeIntervalSince1970: command["start"] as? Double ?? Date().timeIntervalSince1970))
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .traditionalStrengthTraining
            configuration.locationType = .indoor
            let primary = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            selectWorkout(request)
            phase = .starting
            if let metrics = command["metrics"] as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: metrics) {
                try handleReceivedData(data)
            }
            attachPrimary(primary, request: request, generation: token)
            diagnostic("workout=\(id) Watch HealthKit session created; adding metadata")
            try await builder?.addMetadata([HKMetadataKeyExternalUUID: id, "gymbro.segmentId": token])
            persistWatchIdentity()
            primary.prepare()
            diagnostic("workout=\(id) Watch HealthKit prepare requested")
            await ensureWorkoutMirroring()
            Task { @MainActor in
                do { try await Task.sleep(nanoseconds: UInt64(WorkoutSyncLimits.preparedLease * 1_000_000_000)) } catch { return }
                self.enqueue {
                    guard self.session === primary, self.generation == token,
                          primary.state == .prepared || primary.state == .notStarted else { return }
                    try? await self.finishSegment(save: false)
                    self.phase = .starting
                    self.diagnostic("workout=\(id) expired prepared session discarded without saving")
                }
            }
            return sensorReply(running: false)
        }
        guard action == "commit", request?.id == id, generation == token else { throw WorkoutOperationError.stale }
        if let metrics = command["metrics"] as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: metrics) {
            try handleReceivedData(data)
        }
        persistWatchIdentity()
        diagnostic("workout=\(id) Watch committing HealthKit recording")
        try await commitPrimary(at: Date())
        rememberRecordingStarted(id)
        phase = .active
        return sensorReply(running: true)
    }

    private func ensureWorkoutMirroring() async {
        guard !remoteConnected, let primary = session, primary.state != .ended else { return }
        if #available(watchOS 10, *) {
            do {
                try await workoutDeadline(WorkoutSyncLimits.mirroring) {
                    try await primary.startMirroringToCompanionDevice()
                    if self.session === primary { self.remoteConnected = true; self.transport.flush() }
                }
            } catch { diagnostic("mirroring pending; using WatchConnectivity: \(error.localizedDescription)") }
        }
    }

    private func rememberRecordingStarted(_ id: String) {
        var ids = Set(UserDefaults.standard.stringArray(forKey: "workout.startedWatchIDs.v1") ?? [])
        ids.insert(id)
        UserDefaults.standard.set(Array(ids), forKey: "workout.startedWatchIDs.v1")
    }

    private func sensorReply(running: Bool) -> [String: Any] {
        var reply: [String: Any] = ["success": true, "generation": generation, "running": running, "workoutId": request?.id ?? "", "sensorState": session?.state.rawValue ?? 0]
        if let packet = metricsPacket() { reply["metrics"] = packet.dictionary }
        return reply
    }

    private func persistWatchIdentity() {
        UserDefaults.standard.set(try? JSONEncoder().encode(request), forKey: "workout.watchRequest.v2")
        UserDefaults.standard.set(generation, forKey: "workout.watchGeneration.v2")

    }

    func recoverWorkout(with recovered: HKWorkoutSession) async throws {
        guard recovered.state == .running || recovered.state == .paused,
              let data = UserDefaults.standard.data(forKey: "workout.watchRequest.v2"),
              let request = try? JSONDecoder().decode(WorkoutRequest.self, from: data),
              recovered.associatedWorkoutBuilder().metadata[HKMetadataKeyExternalUUID] as? String == request.id else {
            // Recovery must not end an unrelated session just because this
            // process cannot identify its metadata yet.
            throw WorkoutOperationError.unavailable
        }
        var ledger = metricsStore.ledger(for: request.id)
        ledger.seedLegacyOffset(UserDefaults.standard.double(forKey: "workout.watchOffset.v2"))
        metricsStore.save(ledger)
        let token = recovered.associatedWorkoutBuilder().metadata["gymbro.segmentId"] as? String
            ?? UserDefaults.standard.string(forKey: "workout.watchGeneration.v2") ?? UUID().uuidString
        attachPrimary(recovered, request: request, generation: token)
        collectionStarted = true
        rememberRecordingStarted(request.id)
        recordSegment(generation: token, state: recovered.state == .paused ? .paused : .running, activate: true)
        phase = .active
        sessionState = recovered.state
        await ensureWorkoutMirroring()
    }
}
