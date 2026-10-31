import Foundation

@main
struct WatchWorkoutLifecycleTests {
    @MainActor
    static func main() async throws {
        try testMetricsAggregation()
        // The app can be active while its sensor session is still starting or failed.
        precondition(WorkoutRecordingStatus(matchesWorkout: false, phase: .active, sensorActive: true) == .starting)
        precondition(WorkoutRecordingStatus(matchesWorkout: true, phase: .starting, sensorActive: false) == .starting)
        precondition(WorkoutRecordingStatus(matchesWorkout: true, phase: .active, sensorActive: true) == .recording)
        precondition(WorkoutRecordingStatus(matchesWorkout: true, phase: .active, sensorActive: false) == .unavailable("Recording is not active."))
        precondition(WorkoutRecordingStatus(matchesWorkout: true, phase: .failed("Failed"), sensorActive: true) == .unavailable("Failed"))

        // A slow launch leaves a fresh budget for preparation, rather than the
        // few milliseconds remaining from the launch's own deadline.
        let prepared = try await prepareWorkoutAfterLaunch(timeout: 0.5, launch: {
            try await Task.sleep(nanoseconds: 300_000_000)
        }, prepare: { deadline in
            precondition(deadline.timeIntervalSinceNow > 0.4)
            try await Task.sleep(nanoseconds: 300_000_000)
            return 42
        })
        precondition(prepared == 42)
        var didPrepare = false
        do {
            _ = try await prepareWorkoutAfterLaunch(timeout: 0.01, launch: {
                try await Task.sleep(nanoseconds: 100_000_000)
            }, prepare: { _ in didPrepare = true })
            preconditionFailure("Expected launch timeout")
        } catch WorkoutOperationError.timeout {}
        precondition(!didPrepare)
        do {
            _ = try await prepareWorkoutAfterLaunch(timeout: 0.01, launch: {}, prepare: { _ in
                try await Task.sleep(nanoseconds: 100_000_000)
            })
            preconditionFailure("Expected preparation timeout")
        } catch WorkoutOperationError.timeout {}
        var snapshot = WatchSnapshot()
        snapshot.update(workout: ["id": "A", "active": true])
        let beforeFood = snapshot.dictionary
        snapshot.update(food: ["calorieIntake": 525])
        precondition(snapshot.workout["id"] as? String == "A")
        snapshot.update(workout: ["id": "B", "active": true])
        precondition(snapshot.food["calorieIntake"] as? Int == 525)
        precondition(PropertyListSerialization.propertyList(snapshot.dictionary, isValidFor: .binary))
        var cursor = WatchSnapshotCursor()
        precondition(cursor.accept(snapshot.dictionary))
        precondition(!cursor.accept(beforeFood))
        precondition(!cursor.accept(snapshot.dictionary))
        var restoredCursor = WatchSnapshotCursor(revision: cursor.revision)
        precondition(!restoredCursor.accept(beforeFood))
        snapshot.update(workout: ["id": "B", "active": false, "save": false])
        precondition(restoredCursor.accept(snapshot.dictionary))
        precondition(WatchSnapshot(dictionary: snapshot.dictionary).food["calorieIntake"] as? Int == 525)

        var fence = WorkoutCommandFence()
        precondition(fence.prepare(id: "A", revision: 10))
        precondition(fence.prepare(id: "A", revision: 10)) // idempotent retry
        precondition(!fence.prepare(id: "B", revision: 9))
        fence.finish(id: "A")
        precondition(!fence.prepare(id: "A", revision: 20))
        precondition(fence.prepare(id: "B", revision: 21))
        var recovered = try JSONDecoder().decode(WorkoutCommandFence.self, from: JSONEncoder().encode(fence))
        precondition(!recovered.prepare(id: "A", revision: 99))
        precondition(recovered.prepare(id: "B", revision: 22))

        let queue = WorkoutOperationQueue()
        var events: [Int] = []
        queue.enqueue { events.append(1); try? await Task.sleep(nanoseconds: 5_000_000); events.append(2) }
        queue.enqueue { events.append(3) }
        await queue.drain()
        precondition(events == [1, 2, 3])

        let value = try await workoutDeadline(1) { 42 }
        precondition(value == 42)
        do {
            _ = try await workoutDeadline(0.005) {
                // Deliberately ignores cancellation, like a delayed platform callback.
                await withCheckedContinuation { continuation in
                    Task { @MainActor in try? await Task.sleep(nanoseconds: 30_000_000); continuation.resume(returning: 7) }
                }
            }
            preconditionFailure("Expected timeout")
        } catch WorkoutOperationError.timeout {}
        // Late completion must not double-resume a continuation.
        try await Task.sleep(nanoseconds: 50_000_000)

        var handoff: [String] = []
        let committed = try await commitWorkoutHandoff(isCurrent: { true }, finishLocal: { handoff.append("finishPhone") }, commit: { handoff.append("startWatch") }, abort: { handoff.append("abort") })
        precondition(committed && handoff == ["finishPhone", "startWatch"])
        handoff = []
        do {
            _ = try await commitWorkoutHandoff(isCurrent: { true }, finishLocal: { handoff.append("finishPhone") }, commit: { throw WorkoutOperationError.timeout }, abort: { handoff.append("abort") })
            preconditionFailure("Expected commit failure")
        } catch WorkoutOperationError.timeout {}
        precondition(handoff == ["finishPhone", "abort"])
        let uncertain = try await commitWorkoutHandoff(isCurrent: { true }, finishLocal: {}, commit: { throw WorkoutOperationError.timeout }, abort: { throw WorkoutOperationError.unavailable })
        precondition(!uncertain) // no local fallback until a remote abort is confirmed
        handoff = []
        do {
            _ = try await commitWorkoutHandoff(isCurrent: { false }, finishLocal: { handoff.append("wrong") }, commit: { handoff.append("wrong") }, abort: { handoff.append("abort") })
            preconditionFailure("Expected stale request")
        } catch WorkoutOperationError.stale {}
        precondition(handoff == ["abort"])
        print("Workout lifecycle: snapshot coexistence/revisions, persisted command fences, ordered operations, deadline races and device handoff passed")
    }
    @MainActor
    static func testMetricsAggregation() throws {
        let now = Date(timeIntervalSince1970: 1000)
        var watch = WorkoutMetricsLedger(workoutID: "training")
        watch.record(device: "watch", generation: "A", energy: 80, state: .running, heartRate: 120, heartRateDate: now, activate: true)
        var phone = WorkoutMetricsLedger(workoutID: "training")
        let first = watch.packet(device: "watch")
        precondition(WorkoutMetricsPacket.decode(first.dictionary) == first)
        precondition(phone.merge(first) && phone.totalEnergy == 80)
        precondition(!phone.merge(first) && phone.totalEnergy == 80)
        precondition(phone.liveHeartRate(at: now.addingTimeInterval(29)) == 120)
        precondition(phone.liveHeartRate(at: now.addingTimeInterval(31)) == nil)
        precondition(phone.liveHeartRate(at: now, after: now) == nil)
        watch.record(device: "watch", generation: "A", state: .ended)
        precondition(phone.merge(watch.packet(device: "watch")))
        precondition(phone.totalEnergy == 80 && phone.liveHeartRate(at: now) == nil)
        watch.record(device: "watch", generation: "B", energy: 0, state: .running, activate: true)
        watch.record(device: "watch", generation: "B", energy: 15, heartRate: 130, heartRateDate: now.addingTimeInterval(10))
        precondition(phone.merge(watch.packet(device: "watch")))
        precondition(phone.totalEnergy == 95 && phone.liveHeartRate(at: now.addingTimeInterval(12)) == 130)
        let beforeLateFinalization = watch.packet(device: "watch")
        // A delayed final builder result refines A, without making it active again.
        watch.record(device: "watch", generation: "A", energy: 82, state: .ended,
                     heartRate: 200, heartRateDate: now.addingTimeInterval(11))
        precondition(phone.merge(watch.packet(device: "watch")))
        precondition(phone.totalEnergy == 97 && phone.liveHeartRate(at: now.addingTimeInterval(12)) == 130)
        precondition(!phone.merge(beforeLateFinalization))
        precondition(!phone.merge(first) && phone.totalEnergy == 97)
        watch.record(device: "watch", generation: "B", energy: 0)
        phone.merge(watch.packet(device: "watch"))
        precondition(phone.totalEnergy == 97)
        watch.record(device: "watch", generation: "B", state: .paused, stateDate: now.addingTimeInterval(15))
        phone.merge(watch.packet(device: "watch"))
        precondition(phone.liveHeartRate(at: now.addingTimeInterval(12)) == nil)
        watch.record(device: "watch", generation: "B", state: .running, activate: true)
        phone.merge(watch.packet(device: "watch"))
        precondition(phone.liveHeartRate(at: now.addingTimeInterval(16)) == nil)
        watch.record(device: "watch", generation: "B", state: .running,
                     heartRate: 135, heartRateDate: now.addingTimeInterval(20), activate: true)
        phone.merge(watch.packet(device: "watch"))
        precondition(phone.liveHeartRate(at: now.addingTimeInterval(21)) == 135)
        // Local fallback and Watch contributions are raw values: no nested offsets.
        phone.record(device: "phone", generation: "P", energy: 30, state: .ended)
        watch.merge(phone.packet(device: "phone"))
        precondition(watch.totalEnergy == 127 && phone.totalEnergy == 127)
        precondition(!watch.merge(phone.packet(device: "phone")))
        phone.record(device: "phone", generation: "P2", energy: 5, state: .running, activate: true)
        watch.merge(phone.packet(device: "phone"))
        precondition(watch.totalEnergy == 132)
        phone.merge(watch.packet(device: "watch"))
        precondition(phone.totalEnergy == 132)
        // Recovering a builder keeps its segment identity and cumulative counter.
        watch.record(device: "watch", generation: "B", energy: 16)
        phone.merge(watch.packet(device: "watch"))
        precondition(phone.totalEnergy == 133)
        let restored = try JSONDecoder().decode(WorkoutMetricsLedger.self, from: JSONEncoder().encode(phone))
        precondition(restored == phone)
        var other = WorkoutMetricsLedger(workoutID: "next-training")
        precondition(!other.merge(watch.packet(device: "watch")) && other.totalEnergy == 0)
        let suite = "GymBro.MetricsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        WorkoutMetricsStore(defaults: defaults).save(phone)
        let reopened = WorkoutMetricsStore(defaults: defaults)
        precondition(reopened.ledger(for: "training").totalEnergy == 133)
        precondition(!reopened.merge(watch.packet(device: "watch")))
        precondition(reopened.ledger(for: "next-training").totalEnergy == 0)
        // Migrating the old prefix on both devices must count it only once.
        var legacyPhone = WorkoutMetricsLedger(workoutID: "legacy")
        var legacyWatch = WorkoutMetricsLedger(workoutID: "legacy")
        legacyPhone.seedLegacyOffset(20)
        legacyWatch.seedLegacyOffset(10)
        legacyWatch.record(device: "watch", generation: "W", energy: 10, state: .running, activate: true)
        legacyPhone.merge(legacyWatch.packet(device: "watch"))
        precondition(legacyPhone.totalEnergy == 30)
        legacyWatch.merge(legacyPhone.packet(device: "phone"))
        precondition(legacyWatch.totalEnergy == 30)
        print("Workout aggregation: session restarts, duplicates, late packets/results, raw device totals, HR expiry/pauses, recovery, persistence and workout isolation passed")
    }

}
