import Foundation
import os
import HealthKit

@available(iOS 17, *)
extension WorkoutManager {
    func retrieveRemoteSession() {
        onSensorSessionEnded = { [weak self] in
            guard self?.desiredRequest != nil else { return }
            self?.watchBecameReachable()
        }

        healthStore.workoutSessionMirroringStartHandler = { mirrored in
            Task { @MainActor in
                // A mirror is never a local primary and must never create a builder.
                self.remoteSession = mirrored
                mirrored.delegate = self
                if self.device == "watch", self.desiredRequest != nil,
                   mirrored.state != .ended { self.session = mirrored; self.builder = nil }
            }
        }
    }

    func startPhoneWorkout(id: String, start: Date) {
        let next = WorkoutRequest(id: id, start: start)
        guard desiredRequest != next else {
            // Flutter can reconnect to the same native session after rebuilding
            // its providers. Republish the persisted totals without restarting it.
            selectWorkout(next)
            refreshPublishedMetrics()
            return
        }
        desiredRequest = next
        persistDesiredRequest()
        enqueue {
            guard self.desiredRequest == next else { return }
            if self.request?.id != id {
                self.invalidateHeartRate()
                self.summary = nil
            }
            self.selectWorkout(next)
            self.phase = .starting
            // Recover first; restoring Flutter must not create a second native session.
            if #available(iOS 26, *), self.session == nil,
               let recovered = try? await self.healthStore.recoverActiveWorkoutSession() {
                if recovered.type == .primary && (recovered.state == .running || recovered.state == .paused) {
                    let metadata = recovered.associatedWorkoutBuilder().metadata
                    if metadata[HKMetadataKeyExternalUUID] as? String == id {
                        self.attachPrimary(recovered, request: next, generation:
                            metadata["gymbro.segmentId"] as? String ?? UserDefaults.standard.string(forKey: "workout.localGeneration.\(id)") ?? UUID().uuidString)
                        self.recordSegment(generation: self.generation, state: recovered.state == .paused ? .paused : .running, activate: true)
                        self.device = "phone"
                        self.phase = .active
                    } else { recovered.end() }
                } else if recovered.type == .mirrored {
                    self.remoteSession = recovered
                    recovered.delegate = self
                }
            }
            guard self.desiredRequest == next else { return }
            if self.device == "phone" && self.session != nil { return }
            do {
                try await self.connectWatch(next)
            } catch {
                guard self.desiredRequest == next else { return }
                await self.startLocal(next)
            }
        }
    }

    func stopPhoneWorkout(id: String, save: Bool) {
        if desiredRequest?.id == id { desiredRequest = nil; persistDesiredRequest(); stopMonitoringMetrics() }
        if !save { markDiscarded(id) }
        pendingRemoteFinish[id] = save
        UserDefaults.standard.set(pendingRemoteFinish, forKey: "workout.remoteFinishes.v2")
        enqueue {
            do {
                if self.request?.id == id {
                    self.phase = .finalizing
                    if self.device == "watch" {
                        try await self.finishRemote(id: id, save: save)
                    } else {
                        try await self.finishSegment(save: save)
                        // Clear any prepared Watch from an interrupted startup.
                        try? await self.finishRemote(id: id, save: save)
                    }
                    if self.request?.id == id { self.device = "none"; self.phase = .idle; self.session = nil; self.builder = nil }
                } else if self.watchAvailable?() == true {
                    try await self.finishRemote(id: id, save: save)
                }
                if !save { try await self.deleteSavedSegments(id: id) }
            } catch {
                if self.request?.id == id {
                    self.phase = .failed(error.localizedDescription)
                    self.summary = .init(id: id, result: .failed(error.localizedDescription))
                }
                self.onError?(id, error.localizedDescription)
                Logger.shared.error("Workout finish: \(error)")
            }
        }
    }

    func watchBecameReachable() {
        guard !watchAttemptInProgress, !watchReconciliationQueued, Date() >= nextWatchProbe else { return }
        watchReconciliationQueued = true
        enqueue {
            defer { self.watchReconciliationQueued = false }
            let stored = UserDefaults.standard.dictionary(forKey: "workout.remoteFinishes.v2") as? [String: Bool] ?? [:]
            self.pendingRemoteFinish.merge(stored) { current, _ in current }
            for (id, save) in self.pendingRemoteFinish {
                try? await self.finishRemote(id: id, save: save)
            }
            guard let request = self.desiredRequest,
                  self.request == request, self.watchAvailable?() == true else { return }
            do { try await self.connectWatch(request) }
            catch {
                self.nextWatchProbe = Date().addingTimeInterval(15)
                if self.session == nil && self.device != "watch" && self.desiredRequest == request { await self.startLocal(request) }
            }
        }
    }

    private func persistDesiredRequest() {
        UserDefaults.standard.set(try? JSONEncoder().encode(desiredRequest), forKey: "workout.desired.v2")
    }

    private func connectWatch(_ request: WorkoutRequest) async throws {
        guard let remoteCommand else { throw WorkoutOperationError.unavailable }
        nextWatchProbe = Date().addingTimeInterval(15)
        watchAttemptInProgress = true
        defer { watchAttemptInProgress = false }
        self.phase = device == "phone" ? .switchingDevice : .starting
        var token = UUID().uuidString
        let preparationDeadline = Date().addingTimeInterval(10)
        // Launch only prepares the companion UI. The command below owns the session.
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        try await workoutDeadline(10) {
            try await self.healthStore.startWatchApp(toHandle: configuration)
            while self.watchAvailable?() != true {
                try Task.checkCancellation()
                try await Task.sleep(nanoseconds: 100_000_000)
            }
        }
        guard desiredRequest == request else { throw WorkoutOperationError.stale }
        // Never replace an older Watch recording before applying its pending
        // save/discard disposition, even if the latest snapshot already names B.
        for (id, save) in pendingRemoteFinish where id != request.id {
            try await workoutDeadline(max(0.001, preparationDeadline.timeIntervalSinceNow)) {
                try await self.finishRemote(id: id, save: save)
            }
        }
        var command: [String: Any] = ["method": "workoutSensor", "action": "prepare", "workoutId": request.id,
            "generation": token, "start": request.start.timeIntervalSince1970,
            "deadline": preparationDeadline.timeIntervalSince1970]
        command["metrics"] = metricsPacket()?.dictionary
        let prepared = try await workoutDeadline(max(0.001, preparationDeadline.timeIntervalSinceNow)) { try await remoteCommand(command) }
        guard prepared["success"] as? Bool == true else { throw WorkoutOperationError.unavailable }
        token = prepared["generation"] as? String ?? token
        if let metrics = prepared["metrics"] as? [String: Any], let data = try? JSONSerialization.data(withJSONObject: metrics) {
            try handleReceivedData(data)
        }
        guard desiredRequest == request else {
            _ = try? await workoutDeadline(10) { try await remoteCommand(["method": "workoutSensor", "action": "abort", "workoutId": request.id, "generation": token]) }
            throw WorkoutOperationError.stale
        }
        let confirmed = try await commitWorkoutHandoff(
            isCurrent: { self.desiredRequest == request },
            finishLocal: {
                if self.device == "phone" {
                    try await self.finishSegment(save: true)
                }
            },
            commit: {
                self.generation = token
                var commit = command
                commit["action"] = "commit"
                commit["generation"] = token
                commit["metrics"] = self.metricsPacket()?.dictionary
                commit["deadline"] = Date().addingTimeInterval(10).timeIntervalSince1970
                let result = try await workoutDeadline(10) { try await remoteCommand(commit) }
                guard result["success"] as? Bool == true else { throw WorkoutOperationError.unavailable }
            },
            abort: {
                let response = try await workoutDeadline(10) {
                    try await remoteCommand(["method": "workoutSensor", "action": "abort", "workoutId": request.id, "generation": token])
                }
                guard response["success"] as? Bool == true else { throw WorkoutOperationError.unavailable }
            }
        )
        guard confirmed else {
            self.generation = token
            device = "watch"
            session = remoteSession?.state == .ended ? nil : remoteSession
            builder = nil
            phase = .failed("Unable to confirm the Watch session. Reconnect your Watch.")
            return
        }
        guard desiredRequest == request else { return }
        device = "watch"
        session = remoteSession?.state == .ended ? nil : remoteSession
        builder = nil
        summary = nil
        phase = .active

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
        guard #available(iOS 26, *) else { device = "none"; phase = .active; return }
        do { try await workoutDeadline(10) { try await self.createLocal(request) } }
        catch { phase = .failed(error.localizedDescription); Logger.shared.error("Local workout: \(error)") }
    }

    private func finishRemote(id: String, save: Bool) async throws {
        guard let remoteCommand else { throw WorkoutOperationError.unavailable }
        let response = try await workoutDeadline(30) {
            try await remoteCommand(["method": "workoutSensor", "action": "stop", "workoutId": id, "save": save])
        }
        guard response["success"] as? Bool == true else { throw WorkoutOperationError.unavailable }
        if !save { try await deleteSavedSegments(id: id) }
        if pendingRemoteFinish[id] == save { pendingRemoteFinish.removeValue(forKey: id) }
        UserDefaults.standard.set(pendingRemoteFinish, forKey: "workout.remoteFinishes.v2")
    }
}
