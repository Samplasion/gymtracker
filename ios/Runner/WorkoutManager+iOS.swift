import Foundation
import os
import HealthKit

@available(iOS 17, *)
extension WorkoutManager {
    func retrieveRemoteSession() {
        onSensorSessionEnded = { [weak self] in
            guard let self, self.desiredRequest != nil else { return }
            self.recordingController?.reconnect()
        }
        healthStore.workoutSessionMirroringStartHandler = { mirrored in
            Task { @MainActor in
                // Reconnection supplies a NEW mirror. Never create a local builder.
                self.remoteSession = mirrored
                self.remoteConnected = true
                mirrored.delegate = self
                if self.device == "watch", self.desiredRequest != nil, mirrored.state != .ended {
                    self.session = mirrored
                    self.builder = nil
                }
                self.transport.flush()
                self.recordingController?.reconnect()
            }
        }
    }

    func applyRecordingIntent(_ intent: WatchRecordingIntent) {
        guard desiredRequest == intent.request else { return }
        generation = intent.generation
        switch intent.confirmation {
        case .pending: phase = .starting
        case .confirmed:
            device = "watch"
            builder = nil
            if let mirror = remoteSession, mirror.state != .ended { session = mirror }
            phase = .active
        case .unavailable: phase = .failed(intent.message ?? "Watch recording is unavailable.")
        case .finished: phase = .idle
        }
    }

    /// Adopt app ownership, not sensor ownership. Switching control never saves
    /// a phone segment or starts a second primary.
    func adoptWatchWorkout(id: String, start: Date) {
        guard !(device == "phone" && session != nil) else { return }
        let adopted = WorkoutRequest(id: id, start: start)
        desiredRequest = adopted
        persistDesiredRequest()
        selectWorkout(adopted)
        device = "watch"
        recordingController?.start(adopted)
    }

    func startPhoneWorkout(id: String, start: Date) {
        let next = WorkoutRequest(id: id, start: start)
        if desiredRequest == next {
            refreshPublishedMetrics()
            return
        }
        desiredRequest = next
        persistDesiredRequest()
        phase = .starting
        enqueue {
            guard self.desiredRequest == next else { return }
            if self.watchConfigurationReady?() == false {
                do {
                    try await workoutDeadline(WorkoutSyncLimits.launch) {
                        while self.watchConfigurationReady?() == false {
                            try Task.checkCancellation()
                            try await Task.sleep(nanoseconds: 100_000_000)
                        }
                    }
                } catch {
                    guard self.desiredRequest == next else { return }
                    self.selectWorkout(next)
                    self.device = "watch"
                    self.recordingController?.start(next)
                    return
                }
            }
            guard self.desiredRequest == next else { return }
            if let existing = self.session, self.builder != nil, self.request?.id != id,
               existing.state != .ended && existing.state != .stopped {
                self.phase = .failed("Another recording is still active.")
                return
            }
            // The controller drains the old Watch's terminal intent before
            // starting this workout. Its old mirror may still deliver events;
            // retain it for transport, but do not attribute its events to the
            // newly selected app workout.
            if self.request?.id != id, self.builder == nil { self.session = nil }
            self.selectWorkout(next)
            let selected = UserDefaults.standard.string(forKey: "workout.recordingDevice.\(id)")
                ?? (self.recordingController?.intent?.request.id == id || self.watchConfigured?() == true ? "watch" : "phone")
            UserDefaults.standard.set(selected, forKey: "workout.recordingDevice.\(id)")
            // Recover an existing primary before attempting any creation.
            if #available(iOS 26, *), self.session == nil,
               let recovered = try? await self.healthStore.recoverActiveWorkoutSession() {
                if recovered.type == .primary {
                    let metadata = recovered.associatedWorkoutBuilder().metadata
                    guard metadata[HKMetadataKeyExternalUUID] as? String == id else {
                        self.phase = .failed("Another recording is still active.")
                        return
                    }
                    self.attachPrimary(recovered, request: next, generation:
                        metadata["gymbro.segmentId"] as? String ?? UUID().uuidString)
                    self.device = "phone"
                    self.phase = .active
                    UserDefaults.standard.set("phone", forKey: "workout.recordingDevice.\(id)")
                    return
                } else {
                    self.remoteSession = recovered
                    recovered.delegate = self
                }
            }
            guard self.desiredRequest == next else { return }
            if self.device == "phone", self.session != nil { return }
            if selected == "watch" {
                self.device = "watch"
                self.recordingController?.start(next)
            } else {
                await self.startLocal(next)
            }
        }
    }

    func stopPhoneWorkout(id: String, save: Bool) {
        if desiredRequest?.id == id { desiredRequest = nil; persistDesiredRequest(); stopMonitoringMetrics() }
        if !save { markDiscarded(id) }
        if device == "watch" || recordingController?.intent?.request.id == id {
            recordingController?.stop(id: id, save: save)
            if request?.id == id { phase = .idle }
            // The mirror is retained for the pending terminal acknowledgement.
            return
        }
        enqueue {
            do {
                if self.request?.id == id { try await self.finishSegment(save: save); self.phase = .idle }
                if !save { try await self.deleteSavedSegments(id: id) }
            } catch {
                self.phase = .failed(error.localizedDescription)
                self.onError?(id, error.localizedDescription)
            }
        }
    }

    func watchBecameReachable() {
        transport.flush()
        recordingController?.reconnect()
    }

    private func persistDesiredRequest() {
        UserDefaults.standard.set(try? JSONEncoder().encode(desiredRequest), forKey: "workout.desired.v2")
    }

    @available(iOS 26, *)
    private func createLocal(_ request: WorkoutRequest) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        let local = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        attachPrimary(local, request: request, generation: UUID().uuidString)
        UserDefaults.standard.set(generation, forKey: "workout.localGeneration.\(request.id)")
        try await builder?.addMetadata([HKMetadataKeyExternalUUID: request.id, "gymbro.segmentId": generation])
        guard desiredRequest == request, !Task.isCancelled else {
            local.end()
            builder?.discardWorkout()
            if session === local { session = nil; builder = nil }
            throw WorkoutOperationError.stale
        }
        try await commitPrimary(at: Date())
        device = "phone"
    }

    private func startLocal(_ request: WorkoutRequest) async {
        guard desiredRequest == request else { return }
        diagnostic("workout=\(request.id) attempting iPhone recording fallback")
        guard #available(iOS 26, *) else {
            device = "none"
            phase = .failed("Sensor recording is unavailable. Your workout remains available in the iPhone app.")
            return
        }
        // A UI/transport deadline must not cancel and recreate a real primary.
        do { try await self.createLocal(request) }
        catch {
            guard desiredRequest == request else { return }
            phase = .failed(error.localizedDescription)
            Logger.shared.error("Local workout: \(error)")
            onError?(request.id, error.localizedDescription)
        }
    }

}
