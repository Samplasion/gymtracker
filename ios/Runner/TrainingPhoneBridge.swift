import Foundation
import Flutter
import WatchConnectivity

@MainActor
final class TrainingPhoneBridge {
    static let shared = TrainingPhoneBridge()
    private var channel: FlutterMethodChannel?
    private var archive: WatchTrainingArchive?
    private var storageError: Error?
    private var state: [String: Any] = [:]
    var publish: (() -> Void)?
    var adoptSensors: (([String: Any]) -> Void)?
    private var ready = false
    private var lastSessionFile: String?
    private var lastCatalogFile: String?
    private init() {
        do { archive = try WatchTrainingArchive(); state = archive!.value }
        catch { storageError = error }
    }
    var context: [String: Any] { state["context"] as? [String: Any] ?? [:] }
    private func save(_ next: [String: Any]) throws {
        guard let archive else { throw storageError ?? CocoaError(.fileWriteUnknown) }
        try archive.save(next)
        state = next
    }
    func attach(_ messenger: FlutterBinaryMessenger) {
        ready = false
        let channel = FlutterMethodChannel(name: "gymbro/training", binaryMessenger: messenger)
        self.channel = channel
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { result(nil); return }
            do {
                let args = call.arguments as? [String: Any] ?? [:]
                if call.method == "exchange" {
                    self.ready = true
                    var next = self.state
                    var context = self.context
                    context["version"] = 1
                    if context["ownerScope"] as? String != args["ownerScope"] as? String {
                        context["generation"] = (context["generation"] as? Int ?? 0) + 1
                        context.removeValue(forKey: "catalog")
                    }
                    context["ownerScope"] = args["ownerScope"]
                    if var catalog = args["catalog"] as? [String: Any] {
                        catalog["generation"] = context["generation"] ?? 1
                        catalog["revision"] = WatchTraining.milliseconds()
                        let data = try JSONSerialization.data(withJSONObject: catalog)
                        next["catalog"] = catalog
                        if data.count < 16_000 { context["catalog"] = catalog }
                        else { context.removeValue(forKey: "catalog") }
                    }
                    if let document = args["session"] as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: document)
                        if data.count < 16_000 { context["session"] = document }
                        else {
                            context["session"] = NSNull()
                            let identity = "\(document["ownerScope"] ?? "")/\(document["id"] ?? "")/\(document["sequence"] ?? 0)"
                            if self.lastSessionFile != identity, WCSession.default.activationState == .activated,
                               WCSession.default.isPaired, WCSession.default.isWatchAppInstalled {
                                let url = FileManager.default.temporaryDirectory.appendingPathComponent("phone-session-\(UUID().uuidString).json")
                                try data.write(to: url, options: .atomic)
                                WCSession.default.transferFile(url, metadata: ["kind": "trainingPhoneSession"])
                                self.lastSessionFile = identity
                            }
                        }
                    } else { context["session"] = NSNull() }
                    next["context"] = context
                    let contextChanged = !NSDictionary(dictionary: self.context).isEqual(to: context)
                    try self.save(next)
                    try self.flushCatalogFile()
                    if contextChanged { self.publish?() }
                    let inbox = self.state["inbox"] as? [String: [String: Any]] ?? [:]
                    result(inbox.values.sorted { ($0["time"] as? Double ?? 0) < ($1["time"] as? Double ?? 0) })
                } else if call.method == "terminal" {
                    var next = self.state
                    var context = self.context
                    context["session"] = ["id": args["id"] ?? "", "ownerScope": args["ownerScope"] ?? "",
                        "status": args["status"] ?? "discarded", "end": args["end"] ?? 0]
                    next["context"] = context
                    try self.save(next)
                    self.publish?()
                    let response: [String: Any] = ["accepted": true, "terminal": true,
                        "ownerScope": args["ownerScope"] ?? "", "id": args["id"] ?? "", "document": args]
                    try self.deliver(response)
                    result(nil)
                } else if call.method == "acknowledge" {
                    if let source = args["source"] as? [String: Any], let response = args["response"] as? [String: Any] { try self.acknowledge(source, response: response) }
                    result(nil)
                } else if call.method == "adoptSensors" {
                    self.adoptSensors?(args)
                    result(nil)
                } else { result(FlutterMethodNotImplemented) }
            } catch { result(FlutterError(code: "training_storage", message: error.localizedDescription, details: nil)) }
        }
    }
    func receive(_ message: [String: Any], reply: (([String: Any]) -> Void)? = nil) -> Bool {
        guard message["method"] as? String == "trainingSync", let document = message["document"] as? [String: Any],
              document["version"] as? Int == 1, let id = document["id"] as? String, let owner = document["ownerScope"] as? String else { return false }
        do {
            var next = state
            var inbox = next["inbox"] as? [String: [String: Any]] ?? [:]
            let key = "\(owner)/\(id)"
            if let current = inbox[key], current["status"] as? String != "active", document["status"] as? String == "active" {
                reply?(["accepted": false]); return true
            }
            if let current = inbox[key], current["status"] as? String == "active", document["status"] as? String == "active",
               (current["modified"] as? Double ?? 0) > (document["modified"] as? Double ?? 0) {
                reply?(["accepted": false]); return true
            }
            inbox[key] = document
            next["inbox"] = inbox
            try save(next)
            guard ready, let channel else { reply?(["accepted": false]); return true }
            channel.invokeMethod("receiveTraining", arguments: document) { response in
                guard let response = response as? [String: Any], response["accepted"] as? Bool == true else { reply?(["accepted": false]); return }
                do { try self.acknowledge(document, response: response)
                    if (try? JSONSerialization.data(withJSONObject: response).count) ?? 0 > 35_000 { reply?(["accepted": false, "deferred": true]) }
                    else { reply?(WatchTraining.propertyList(response)) } }
                catch { reply?(["accepted": false]) }
            }
        } catch { reply?(["accepted": false, "error": error.localizedDescription]) }
        return true
    }
    func fileTransferFinished(error: Error?) {
        if error != nil { lastCatalogFile = nil; lastSessionFile = nil }
    }
    private func flushCatalogFile() throws {
        let session = WCSession.default
        guard session.activationState == .activated, session.isPaired, session.isWatchAppInstalled,
              let catalog = state["catalog"] as? [String: Any], context["catalog"] == nil,
              catalog["ownerScope"] as? String == context["ownerScope"] as? String else { return }
        let identity = "\(catalog["ownerScope"] ?? "")/\(catalog["revision"] ?? 0)"
        guard lastCatalogFile != identity else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("catalog-\(UUID().uuidString).json")
        try JSONSerialization.data(withJSONObject: catalog).write(to: url, options: .atomic)
        session.transferFile(url, metadata: ["kind": "trainingCatalog", "version": 1, "ownerScope": catalog["ownerScope"] ?? ""])
        lastCatalogFile = identity
    }

    private func acknowledge(_ source: [String: Any], response: [String: Any]) throws {
        guard let id = source["id"] as? String, let owner = source["ownerScope"] as? String else { return }
        var next = state
        var inbox = next["inbox"] as? [String: [String: Any]] ?? [:]
        let key = "\(owner)/\(id)"
        if inbox[key]?["transferID"] as? String == source["transferID"] as? String { inbox.removeValue(forKey: key) }
        next["inbox"] = inbox
        try save(next)
        var message = response
        message["serverTime"] = WatchTraining.milliseconds()
        message["method"] = "trainingAcknowledged"
        message["transferID"] = source["transferID"]
        message["sourceSequence"] = source["sequence"]
        message["sourceModified"] = source["modified"]
        try deliver(message)
    }
    private func deliver(_ response: [String: Any]) throws {
        var message = response
        message["method"] = "trainingAcknowledged"
        message = WatchTraining.propertyList(message)
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        let data = try JSONSerialization.data(withJSONObject: message)
        if data.count > 35_000 {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("training-ack-\(UUID().uuidString).json")
            try data.write(to: url, options: .atomic)
            session.transferFile(url, metadata: ["kind": "trainingAck", "id": response["id"] ?? ""])
        } else {
            // Adoption acknowledgements must also survive an unreachable Watch.
            session.transferUserInfo(message)
            if session.isReachable { session.sendMessage(message, replyHandler: nil, errorHandler: { _ in }) }
        }
    }
}
