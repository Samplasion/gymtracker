import Foundation

@main
struct WatchWorkoutLifecycleTests {
    @MainActor
    static func main() async throws {
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
}
