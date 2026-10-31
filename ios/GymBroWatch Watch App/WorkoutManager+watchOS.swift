import Foundation
import os
import HealthKit

@available(watchOS 9, *)
extension WorkoutManager {
    /// This is the only entry point that creates a sensor session on Watch.
    /// Exercise snapshots never start, resume, or end HealthKit sessions.
    func handleSensorCommand(_ command: [String: Any]) async throws -> [String: Any] {
        guard let id = command["workoutId"] as? String,
              let action = command["action"] as? String else { throw WorkoutOperationError.stale }
        var fence = (UserDefaults.standard.data(forKey: "workout.commandFence.v2")
            .flatMap { try? JSONDecoder().decode(WorkoutCommandFence.self, from: $0) }) ?? WorkoutCommandFence()
        if action == "stop" {
            fence.finish(id: id)
            UserDefaults.standard.set(try? JSONEncoder().encode(fence), forKey: "workout.commandFence.v2")
            let save = command["save"] as? Bool ?? false
            if !save { markDiscarded(id) }
            if request?.id == id { try await finishSegment(save: save) }
            else if save && summary?.id != id {
                summary = .init(id: id, result: .failed("There is no Watch recording for this workout. Your workout is available in the iPhone app."))
            }
            if !save { try await deleteSavedSegments(id: id) }
            if request?.id == id { stopMonitoringMetrics() }
            return ["success": true]
        }
        guard let token = command["generation"] as? String else { throw WorkoutOperationError.stale }
        if action == "abort" {
            if request?.id == id && generation == token { try await finishSegment(save: false) }
            return ["success": true]
        }
        guard let deadline = command["deadline"] as? Double,
              Date().timeIntervalSince1970 <= deadline, !discardedWorkoutIDs.contains(id) else { throw WorkoutOperationError.stale }
        if action == "prepare" {
            guard fence.prepare(id: id, revision: (command["revision"] as? NSNumber)?.int64Value ?? 0) else { throw WorkoutOperationError.stale }
            UserDefaults.standard.set(try? JSONEncoder().encode(fence), forKey: "workout.commandFence.v2")
            if session == nil, let recovered = try? await healthStore.recoverActiveWorkoutSession() {
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
            if session != nil { try await finishSegment(save: true) }
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
            try await builder?.addMetadata([HKMetadataKeyExternalUUID: id, "gymbro.segmentId": token])
            persistWatchIdentity()
            primary.prepare()
            if #available(watchOS 10, *) {
                do { try await workoutDeadline(5) { try await primary.startMirroringToCompanionDevice() } }
                catch { Logger.shared.error("Mirroring unavailable; using WatchConnectivity: \(error)") }
            }
            // A prepared session must never linger after a timed-out phone launch.
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 12_000_000_000)
                guard self.session === primary, primary.state == .prepared || primary.state == .notStarted else { return }
                try? await self.finishSegment(save: false)
                if self.request?.id == request.id, self.generation == token {
                    self.phase = .failed("Recording was not confirmed by your iPhone. Reconnect your devices.")
                }
            }
            return sensorReply(running: false)
        }
        guard action == "commit", request?.id == id, generation == token else { throw WorkoutOperationError.stale }
        if let metrics = command["metrics"] as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: metrics) {
            try handleReceivedData(data)
        }
        persistWatchIdentity()
        try await commitPrimary(at: Date())
        phase = .active
        return ["success": true]
    }

    private func sensorReply(running: Bool) -> [String: Any] {
        var reply: [String: Any] = ["success": true, "generation": generation, "running": running]
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
            recovered.end()
            return
        }
        var ledger = metricsStore.ledger(for: request.id)
        ledger.seedLegacyOffset(UserDefaults.standard.double(forKey: "workout.watchOffset.v2"))
        metricsStore.save(ledger)
        let token = recovered.associatedWorkoutBuilder().metadata["gymbro.segmentId"] as? String
            ?? UserDefaults.standard.string(forKey: "workout.watchGeneration.v2") ?? UUID().uuidString
        attachPrimary(recovered, request: request, generation: token)
        recordSegment(generation: token, state: recovered.state == .paused ? .paused : .running, activate: true)
        phase = .active
        sessionState = recovered.state
        if #available(watchOS 10, *) { try? await recovered.startMirroringToCompanionDevice() }
    }
}
