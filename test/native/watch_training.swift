import Foundation

@main struct WatchTrainingTests {
    static func main() throws {
        let runtime: Int64 = 60_000_000
        for stopwatch: [String: Any] in [[:],
            ["globalStopwatchPaused": true, "globalStopwatchNominalDuration": 0],
            ["globalStopwatchPaused": true, "globalStopwatchNominalDuration": 5000],
            ["globalStopwatchPaused": false, "globalStopwatch": 56000]] {
            var session = stopwatch; session["time"] = 1000
            assert(WatchTraining.elapsedDuration(session, endingAt: 61000) == runtime)
            assert(WatchTraining.elapsedDuration(session, endingAt: 500) == 0)
        }
        print("Workout runtime ignores stopped/running standard stopwatch across takeover")
        let sent: [String: Any] = ["id": "s", "ownerScope": "guest", "sequence": 2,
            "modified": 20, "epoch": 1, "cursor": "a", "exercises": [["sets": [["id": "a", "done": false]]]]]
        assert(WatchTraining.matchesOutgoing(sent, active: sent))
        var changed = sent; changed["modified"] = 21
        assert(!WatchTraining.matchesOutgoing(sent, active: changed))
        changed = sent; changed["epoch"] = 2
        assert(!WatchTraining.matchesOutgoing(sent, active: changed))
        changed = sent; changed["exercises"] = [["sets": [["id": "a", "done": true]]]]
        assert(!WatchTraining.matchesOutgoing(sent, active: changed))
        print("Adoption acknowledgements fence the entire immutable outgoing state")
        var large: [String: Any] = ["version": 1, "id": "large", "ownerScope": "guest",
            "time": 1, "end": 20, "status": "discarded", "exercises": [["notes": String(repeating: "x", count: 40000)]]]
        let terminal = WatchTraining.immediateDocument(large)!
        assert(terminal["id"] as? String == "large")
        assert(terminal["status"] as? String == "discarded")
        assert((terminal["exercises"] as? [Any])?.isEmpty == true)
        let terminalData = try JSONSerialization.data(withJSONObject: terminal)
        assert(terminalData.count < 35000)
        large["status"] = "completed"
        assert(WatchTraining.immediateDocument(large) == nil)
        print("Large discard delivers immediately; completed results await the full payload")
        let original: [String: Any] = ["modified": 10, "cursor": "a", "exercises": [["sets": [["id": "a", "done": false]]]]]
        let mirrored: [String: Any] = ["modified": 10, "cursor": "b", "exercises": [["sets": [["id": "a", "done": true]]]]]
        assert(!WatchTraining.acceptsSnapshot(original, after: mirrored))
        assert(WatchTraining.acceptsSnapshot(mirrored, after: mirrored))
        var newer = original; newer["modified"] = 11
        assert(WatchTraining.acceptsSnapshot(newer, after: mirrored))
        var older = mirrored; older["modified"] = 9
        assert(!WatchTraining.acceptsSnapshot(older, after: mirrored))
        let nullableOriginal: [String: Any] = ["modified": 10, "cursor": "a", "exercises": [["optional": NSNull()]]]
        let delivered = WatchTraining.propertyList(nullableOriginal)
        assert(WatchTraining.acceptsSnapshot(delivered, after: nullableOriginal))
        assert(WatchTraining.acceptsSnapshot(original, after: mirrored, acknowledged: true))
        assert(!WatchTraining.acceptsSnapshot(older, after: mirrored, acknowledged: true))
        print("Snapshot cursor fencing: old/equal replays rejected, newer navigation accepted")
        var haptic = WatchRestHaptic()
        let deadline = Date(timeIntervalSince1970: 100)
        assert(!haptic.update(deadline, now: deadline.addingTimeInterval(-10), running: true))
        assert(haptic.update(nil, now: deadline, running: true))
        assert(!haptic.due(now: deadline.addingTimeInterval(1), running: true))
        assert(!haptic.update(deadline.addingTimeInterval(20), now: deadline, running: true))
        assert(!haptic.update(nil, now: deadline.addingTimeInterval(21), running: false))
        assert(!haptic.due(now: deadline.addingTimeInterval(22), running: false))
        assert(!haptic.update(deadline, now: deadline.addingTimeInterval(-1), running: false))
        assert(!haptic.update(deadline, now: deadline.addingTimeInterval(-1), running: true))
        assert(haptic.due(now: deadline, running: true))
        assert(!haptic.due(now: deadline, running: true))
        print("Rest haptics: expiry/clear race, deduplication and cancellation passed")
        let nullable: [String: Any] = ["version": 2, "training": [
            "session": NSNull(), "catalog": ["routines": [[
                "parentID": NSNull(), "name": "Routine", "exercises": [[
                    "notes": "Note", "sets": [["rpe": NSNull(), "reps": 8]]
                ]]
            ]]]
        ]]
        assert(!PropertyListSerialization.propertyList(nullable, isValidFor: .binary))
        let snapshot = WatchTraining.propertyList(nullable)
        assert(PropertyListSerialization.propertyList(snapshot, isValidFor: .binary))
        let encoded = try PropertyListSerialization.data(fromPropertyList: snapshot, format: .binary, options: 0)
        assert(!encoded.isEmpty)
        let training = snapshot["training"] as! [String: Any]
        assert(training["session"] == nil)
        let suite = "watch-training-regression-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.set(snapshot, forKey: "watch.snapshot.v2")
        assert(defaults.dictionary(forKey: "watch.snapshot.v2") != nil)
        defaults.removePersistentDomain(forName: suite)
        assert((nullable["training"] as! [String: Any])["session"] is NSNull)
        print("Snapshot serialization: nested JSON nulls, property-list validation and UserDefaults persistence passed")

        let normal: (String) -> [String: Any] = { ["id": $0, "kind": "normal", "parameters": "repsWeight", "reps": 10, "weight": 20.0, "done": false] }
        let routine: [String: Any] = ["id": "routine", "name": "Routine", "unknown": "preserved", "exercises": [
            ["id": "superset", "type": "superset", "restTime": 60_000_000, "exercises": [
                ["id": "a", "name": "A", "sets": [normal("a1"), normal("a2")]],
                ["id": "b", "name": "B", "sets": [normal("b1"), normal("b2")]]
            ]]
        ]]
        var active = try WatchTraining.start(routine: routine, owner: "guest", weight: "kg", distance: "km")
        assert(active["unknown"] as? String == "preserved")
        assert(active["parentID"] as? String == "routine")
        assert(WatchTraining.setLabel(forSet: "a1", in: routine, italian: true) == "1")
        assert(WatchTraining.setLabel(forSet: "a2", in: routine, italian: false) == "2")
        let labelled: [String: Any] = ["exercises": [["sets": [
            ["id": "w", "kind": "warmUp"], ["id": "n", "kind": "normal"],
            ["id": "f", "kind": "failure"], ["id": "d", "kind": "drop"], ["id": "s", "kind": "failureStripping"]
        ]]]]
        assert(WatchTraining.setLabel(forSet: "n", in: labelled, italian: true) == "1")
        assert(WatchTraining.setLabel(forSet: "w", in: labelled, italian: true) == "R")
        assert(WatchTraining.setLabel(forSet: "w", in: labelled, italian: false) == "W")
        assert(WatchTraining.setLabel(forSet: "f", in: labelled, italian: true) == "C")
        assert(WatchTraining.setLabel(forSet: "f", in: labelled, italian: false) == "F")
        assert(WatchTraining.setLabel(forSet: "d", in: labelled, italian: true) == "D")
        assert(WatchTraining.setLabel(forSet: "s", in: labelled, italian: true) == "S")
        let order = WatchTraining.orderedSets(active)
        assert(order.count == 4 && order[0].exercise == order[2].exercise)
        assert(order[0].rest == 0 && order[1].rest == 60)
        WatchTraining.perform("markThisSetAsDone", values: [:], document: &active, now: 1000)
        assert(active["cursor"] as? String == order[1].set)
        assert(active["restEnd"] == nil)
        WatchTraining.perform("updateSetParameters", values: ["weight": 25.0, "reps": 8], document: &active, now: 1100)
        assert(WatchTraining.set(order[1].set, in: active)?["weight"] as? Double == 25)
        WatchTraining.perform("markThisSetAsDone", values: [:], document: &active, now: 2000)
        assert(active["restEnd"] as? Int64 == 62000)
        assert(active["cursor"] as? String == order[2].set)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        let archive = try WatchTrainingArchive(url: url)
        try archive.save(["active": active, "pending": [active]])
        let restored = try WatchTrainingArchive(url: url)
        assert((restored.value["active"] as? [String: Any])?["cursor"] as? String == order[2].set)
        active["status"] = "completed"
        let before = try JSONSerialization.data(withJSONObject: active, options: .sortedKeys)
        WatchTraining.perform("markThisSetAsDone", values: [:], document: &active, now: 3000)
        let after = try JSONSerialization.data(withJSONObject: active, options: .sortedKeys)
        assert(after == before)
        let delta = #"[{"insert":"Lento","attributes":{"bold":true,"highlighted":"primary","futureExtension":"kept"}},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"Controllato"},{"insert":"\n","attributes":{"list":"ordered"}}]"#
        let rich = QuillNoteDocument(delta)
        assert(rich.plainText == "Lento\nControllato")
        assert(rich.blocks.count == 2 && rich.blocks[1].number == 2)
        assert(rich.blocks[0].runs[0].highlighted)
        assert(rich.blocks[0].runs[0].attributes["futureExtension"] as? String == "kept")
        assert(QuillNoteDocument(#"[{"insert":"\n"}]"#).isEmpty)
        assert(QuillNoteDocument(#"[{"insert":"  \n"}]"#).isEmpty)
        assert(QuillNoteDocument("Legacy plain text").plainText == "Legacy plain text")
        assert(QuillNoteDocument(#"{"ops":[{"insert":"Linked","attributes":{"link":"https://example.com"}},{"insert":"\n"}]}"#).blocks[0].runs[0].attributes["link"] as? String == "https://example.com")
        let notesDocument: [String: Any] = ["exercises": [
            ["type": "superset", "notes": " Superset note ", "exercises": [
                ["notes": delta, "sets": [["id": "noted"]]]
            ]],
            ["notes": "Plain note", "sets": [["id": "single"]]]
        ]]
        assert(WatchTraining.notes(forSet: "noted", in: notesDocument).exercise == delta)
        assert(WatchTraining.notes(forSet: "noted", in: notesDocument).superset == "Superset note")
        assert(WatchTraining.notes(forSet: "single", in: notesDocument).superset.isEmpty)
        assert(WatchTraining.notes(forSet: nil, in: notesDocument).exercise.isEmpty)
        print("Quill notes: inline/custom attributes, ordered lists, empty deltas, plaintext and superset context passed")
        print("Watch training: clone, superset ordering, whole-set edits, rest, recovery and terminal state passed")
    }
}
