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
            if let session, request?.id == id, session.state == .running || session.state == .paused {
                return ["success": true, "generation": generation, "running": true]
            }
            if request?.id == id && generation == token && session != nil { return ["success": true, "generation": token] }
            if session != nil { try await finishSegment(save: true) }
            guard Date().timeIntervalSince1970 <= deadline else { throw WorkoutOperationError.stale }
            let request = WorkoutRequest(id: id, start: Date(timeIntervalSince1970: command["start"] as? Double ?? Date().timeIntervalSince1970))
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .traditionalStrengthTraining
            configuration.locationType = .indoor
            let primary = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            attachPrimary(primary, request: request, generation: token)
            try await builder?.addMetadata([HKMetadataKeyExternalUUID: id])
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
            }
            return ["success": true, "generation": token]
        }
        guard action == "commit", request?.id == id, generation == token else { throw WorkoutOperationError.stale }
        energyOffset = command["offset"] as? Double ?? 0
        persistWatchIdentity()
        try await commitPrimary(at: Date())
        return ["success": true]
    }

    private func persistWatchIdentity() {
        UserDefaults.standard.set(try? JSONEncoder().encode(request), forKey: "workout.watchRequest.v2")
        UserDefaults.standard.set(generation, forKey: "workout.watchGeneration.v2")
        UserDefaults.standard.set(energyOffset, forKey: "workout.watchOffset.v2")
    }

    func recoverWorkout(with recovered: HKWorkoutSession) async throws {
        guard recovered.state == .running || recovered.state == .paused,
              let data = UserDefaults.standard.data(forKey: "workout.watchRequest.v2"),
              let request = try? JSONDecoder().decode(WorkoutRequest.self, from: data),
              recovered.associatedWorkoutBuilder().metadata[HKMetadataKeyExternalUUID] as? String == request.id else {
            recovered.end()
            return
        }
        energyOffset = UserDefaults.standard.double(forKey: "workout.watchOffset.v2")
        attachPrimary(recovered, request: request, generation: UserDefaults.standard.string(forKey: "workout.watchGeneration.v2") ?? UUID().uuidString)
        phase = .active
        sessionState = recovered.state
        if #available(watchOS 10, *) { try? await recovered.startMirroringToCompanionDevice() }
    }
}
