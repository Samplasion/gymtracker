import UIKit
import AppIntents
import WidgetKit
import HealthKit
import Flutter
import flutter_local_notifications
import WatchConnectivity
import ActivityKit
import GymBroWidgetsExtension
import flutter_app_intents

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    private let waterInbox = WatchWaterQueue(defaults: .standard, key: "watch.water.inbox.v1")
    private var waterReady = false
    private var importingWater = false
    private var waterRetry: DispatchWorkItem?
    var session: WCSession?
    private var latestFoodParameters: [String: Any]?
    private let watchRecording = WatchRecordingController()
    private let legacyTransport = WorkoutTransport()
    private let metricsStore = WorkoutMetricsStore.shared
    private var legacyMetricsMonitor: Task<Void, Never>?
    private var legacyHeartRateInvalidatedAt = Date()
    private var watchSnapshot = WatchSnapshot(dictionary: UserDefaults.standard.dictionary(forKey: "watch.snapshot.v2") ?? [:])
    var flutterNativeApi: GymBroNativeFlutterAPI?
    var applicationContext: TypedApplicationContext = TypedApplicationContext(isRunning: false, hasExercise: false, percentageDone: 0)
    var logger: FlutterLogger?;
    
    private var _workout: Any? = nil
    @available(iOS 17.0, *)
    fileprivate var workout: WorkoutManager {
        if _workout == nil {
            _workout = WorkoutManager.shared
        }
        return _workout as! WorkoutManager
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        liveActivityForegroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            guard let self, self.applicationContext.isRunning else { return }
            // Watch adoption can arrive while iOS disallows starting an activity
            // in the background. Retry when the phone becomes active.
            self.didUpdateApplicationContext(self.applicationContext)
        }
        // This is required to make any communication available in the action isolate.
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        if #available(iOS 17, *) {
            #if DEBUG
            if ProcessInfo.processInfo.environment["GYMBRO_SCREENSHOTS"] != "1" {
                requestHealthPermission()
                workout.retrieveRemoteSession()
            }
            #else
            requestHealthPermission()
            workout.retrieveRemoteSession()
            #endif
            
            workout.listener = self
            workout.onDiagnostic = { [weak self] message in self?.logger?.log(message) }
            workout.onMetricsPacket = { [weak self] packet in self?.publishPhoneMetrics(packet) }
            workout.watchConfigurationReady = { [weak self] in self?.session?.activationState == .activated }
            workout.watchConfigured = { [weak self] in
                self?.session?.isPaired == true && self?.session?.isWatchAppInstalled == true
            }
            workout.recordingController = watchRecording
            workout.onPhaseChanged = { [weak self] in self?.emitRecordingStatus() }
            workout.onError = { [weak self] id, message in self?.showWorkoutError(id: id, message: message) }
            for id in workout.discardedWorkoutIDs { workout.retryDiscard(id: id) }
        }
        
        configureRecordingSync()

        // Accept and persist deferred water before Flutter finishes starting.
        if WCSession.isSupported() {
            let watchSession = WCSession.default
            watchSession.delegate = self
            setSession(watchSession)
            watchSession.activate()
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let binaryMessenger = engineBridge.applicationRegistrar.messenger()
        TrainingPhoneBridge.shared.attach(binaryMessenger)
        TrainingPhoneBridge.shared.publish = { [weak self] in self?.publishWatchSnapshot() }
        TrainingPhoneBridge.shared.adoptSensors = { [weak self] document in
            guard let self, let id = document["id"] as? String,
                  let start = document["time"] as? NSNumber else { return }
            let date = Date(milliseconds: start.int64Value)
            self.applicationContext.isRunning = true
            self.applicationContext.startingTime = date
            var snapshot = self.watchSnapshot.workout["id"] as? String == id ? self.watchSnapshot.workout : [:]
            snapshot["id"] = id; snapshot["active"] = true; snapshot["save"] = true; snapshot["start"] = start
            snapshot["metrics"] = self.metricsStore.ledger(for: id).packet(device: "phone").dictionary
            self.watchSnapshot.update(workout: snapshot)
            if let parameters = document["parameters"] as? [String: Any],
               let decoded = NativeWorkoutStateMessage.decodeWorkoutState(from: parameters) {
                do { try self.applyWorkoutParameters(decoded) }
                catch { self.logger?.error(error, context: "Unable to adopt workout state") }
            } else {
                self.didUpdateApplicationContext(self.applicationContext)
                self.publishWatchSnapshot()
            }
            if #available(iOS 17, *) { self.workout.adoptWatchWorkout(id: id, start: date) }
            else {
                self.startLegacyMetricsMonitor(); self.publishLegacyMetrics()
                self.watchRecording.start(.init(id: id, start: date))
            }
        }
        FlutterMethodChannel(name: "gymbro/hydration", binaryMessenger: binaryMessenger).setMethodCallHandler { call, result in
            let store = HKHealthStore()
            guard HKHealthStore.isHealthDataAvailable(),
                  let type = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
                result(FlutterError(code: "unavailable", message: "Health is unavailable", details: nil)); return
            }
            func finish(_ error: Error?) {
                DispatchQueue.main.async {
                    if let error = error { result(FlutterError(code: "health", message: error.localizedDescription, details: nil)) }
                    else { result(nil) }
                }
            }
            if call.method == "permission" {
                switch store.authorizationStatus(for: type) {
                case .sharingAuthorized: result("granted")
                case .sharingDenied: result("denied")
                case .notDetermined: result("unknown")
                @unknown default: result("unavailable")
                }
                return
            }
            if call.method == "authorize" {
                store.requestAuthorization(toShare: [type], read: []) { _, error in
                    DispatchQueue.main.async {
                        if let error = error { result(FlutterError(code: "health", message: error.localizedDescription, details: nil)) }
                        else { result(store.authorizationStatus(for: type) == .sharingAuthorized) }
                    }
                }
                return
            }
            guard store.authorizationStatus(for: type) == .sharingAuthorized else {
                result(FlutterError(code: "permission", message: "Water write permission required", details: nil)); return
            }
            guard let args = call.arguments as? [String: Any], let id = args["id"] as? String,
                  id.hasPrefix("gymbro:") else {
                result(FlutterError(code: "arguments", message: "Invalid record identifier", details: nil)); return
            }
            if call.method == "write" {
                guard let ml = args["ml"] as? Double, ml.isFinite, ml > 0,
                      let version = args["version"] as? NSNumber, let milliseconds = args["time"] as? NSNumber else {
                    result(FlutterError(code: "arguments", message: "Invalid water entry", details: nil)); return
                }
                let time = Date(timeIntervalSince1970: milliseconds.doubleValue / 1000)
                let sample = HKQuantitySample(type: type, quantity: HKQuantity(unit: .literUnit(with: .milli), doubleValue: ml), start: time, end: time,
                    metadata: [HKMetadataKeySyncIdentifier: id, HKMetadataKeySyncVersion: version, HKMetadataKeyWasUserEntered: true])
                store.save(sample) { success, error in
                    if !success && error == nil { finish(NSError(domain: "GymBroHydration", code: 1)) }
                    else { finish(error) }
                }
            } else if call.method == "delete" {
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeySyncIdentifier, allowedValues: [id]),
                    HKQuery.predicateForObjects(from: HKSource.default())
                ])
                store.deleteObjects(of: type, predicate: predicate) { _, _, error in finish(error) }
            } else { result(FlutterMethodNotImplemented) }
        }

        waterReady = false
        GymBroNativeHostAPISetup.setUp(binaryMessenger: binaryMessenger, api: self)
        flutterNativeApi = GymBroNativeFlutterAPI(binaryMessenger: binaryMessenger)
        logger = FlutterLogger(binaryMessenger: binaryMessenger)

    }
    
    private var liveActivityForegroundObserver: NSObjectProtocol?

    // MARK: live activity functions
    
    private func liveActivityIsRunning(_ activity: Activity<GymBroWidgetsAttributes>) -> Bool {
        if #available(iOS 16.2, *) {
            return activity.activityState == .active || activity.activityState == .stale
        }
        return activity.activityState == .active
    }

    func getHasLiveActivity() -> Bool {
        return ActivityAuthorizationInfo().areActivitiesEnabled && Activity<GymBroWidgetsAttributes>.activities.contains {
            self.liveActivityIsRunning($0)
        }
    }
        
    func startLiveActivity() {
        if #available(iOS 16.1, *) {
            if ActivityAuthorizationInfo().areActivitiesEnabled && UIApplication.shared.applicationState == .active {
                do {
                    let attributes = GymBroWidgetsAttributes()
                    
                    let initialState = GymBroWidgetsAttributes.ContentState(
                        hasExercise: applicationContext.hasExercise,
                        exerciseName: applicationContext.exerciseName,
                        exerciseColor: applicationContext.exerciseColor,
                        exerciseParameters: applicationContext.exerciseParameters,
                        restTimeEnd: nil,
                        start: applicationContext.startingTime,
                        percentageDone: applicationContext.percentageDone
                    )
                    
                    let activity = try Activity.request(
                        attributes: attributes,
                        contentState: initialState
                    )
                    
                } catch {
                    let errorMessage = """
                        Couldn't start iOS Live Activity
                        ------------------------
                        \(String(describing: error))
                        \(error.localizedDescription)
                        """
                    logger!.error(errorMessage)
                }
            } else {
                logger!.error("Live Activities are not enabled.")
            }
        } else {
            logger!.error("Unsupported iOS version. Live Activities are only available on iOS 16.1 and later.")
        }
    }
    
    
    func updateLiveActivity() {
        guard let activity = Activity<GymBroWidgetsAttributes>.activities.first(where: { self.liveActivityIsRunning($0) }) else {
            logger!.log("There is no active live activity to update.")
            return
        }
        
        let contentState = GymBroWidgetsAttributes.ContentState(
            hasExercise: applicationContext.hasExercise,
            exerciseName: applicationContext.exerciseName,
            exerciseColor: applicationContext.exerciseColor,
            exerciseParameters: applicationContext.exerciseParameters,
            restTimeStart: applicationContext.restTimeStart,
            restTimeEnd: applicationContext.restTimeEnd,
            start: applicationContext.startingTime,
            percentageDone: applicationContext.percentageDone
        )
        
        Task {
            if #available(iOS 16.2, *) {
                await activity.update(
                    ActivityContent<GymBroWidgetsAttributes.ContentState>(
                        state: contentState,
                        staleDate: Date.now + 12 * 3600 // Content expires in 12 hours
                    )
                )
            } else {
                await activity.update(using: contentState)
            }
            logger!.log("Live Activity updated!")
        }
    }
    
    
    func stopLiveActivity() {
        guard let activity = Activity<GymBroWidgetsAttributes>.activities.first(where: { self.liveActivityIsRunning($0) }) else {
            logger!.log("No active Live Activity found.")
            return
        }
        
        Task {
            let state = GymBroWidgetsAttributes.ContentState(
                hasExercise: false,
                start: applicationContext.startingTime,
                percentageDone: 0
            )
            if #available(iOS 16.2, *) {
                await activity.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .immediate)
            } else {
                await activity.end(using: state, dismissalPolicy: .immediate)
            }
            logger!.log("Live Activity ended successfully.")
        }
    }
}

// MARK: - Phone-Watch communication
extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            logger?.error("Error activating session: \(error)")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.flutterNativeApi?.requestTrainingData(completion: { result in
                switch result {
                case .success(_): break
                case .failure(let error):
                    self.logger?.error("Error requesting training data: \(error)")
                }
            })
        }

        logger?.log("Activated session with activationState: \(activationState)")
        Task { @MainActor in
            self.publishWatchSnapshot()
            self.drainWaterEntries()
            if #available(iOS 17, *) { if session.isReachable { self.workout.watchBecameReachable() } }
            else { self.synchronizeLegacyWorkout() }
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        Task { @MainActor in TrainingPhoneBridge.shared.fileTransferFinished(error: error) }
        if fileTransfer.file.metadata?["kind"] as? String != nil {
            try? FileManager.default.removeItem(at: fileTransfer.file.fileURL)
        }
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard file.metadata?["kind"] as? String == "trainingDocument",
              let data = try? Data(contentsOf: file.fileURL),
              let document = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        Task { @MainActor in _ = TrainingPhoneBridge.shared.receive(["method": "trainingSync", "document": document]) }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        Task { @MainActor in
            if self.handleWorkoutEnvelope(userInfo) { return }
            if !TrainingPhoneBridge.shared.receive(userInfo) { self.receiveWater(userInfo) }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        Task { @MainActor in
            if context["kind"] as? String == "workoutMetrics", let metrics = context["metrics"] as? [String: Any] {
                self.receiveWorkoutMetrics(metrics)
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        logger?.log("Watch session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logger?.log("Watch session deactivated")
        session.activate()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in self.publishWatchSnapshot() }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task {
            if self.handleWorkoutEnvelope(message) { return }
            if TrainingPhoneBridge.shared.receive(message) { return }
            guard let method = message["method"] as? String else { return }
            
            if method == "addWater" {
                self.receiveWater(message)
            } else if method == "requestTrainingData" {
                self.publishWatchSnapshot()
                if #available(iOS 17, *) { self.workout.watchBecameReachable() }
                else { self.synchronizeLegacyWorkout() }
                self.flutterNativeApi?.requestTrainingData(completion: { result in
                    switch result {
                    case .success(_): break
                    case .failure(let error):
                        self.logger?.error("Error requesting training data: \(error)")
                    }
                })
            } else if method == "log" {
                if let messageString = message["message"] as? String {
                    self.logger?.log("[Watch] \(messageString)")
                } else {
                    self.logger?.error("Unknown log message from watch")
                }
            } else if method == "workoutMetrics" {
                self.receiveWorkoutMetrics(message["metrics"] as? [String: Any] ?? [:])
            } else {
                logger?.error("Received unknown message from watch: \(method)")
                return
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task {
            if self.handleWorkoutEnvelope(message) { replyHandler(["success": true]); return }
            if TrainingPhoneBridge.shared.receive(message, reply: replyHandler) { return }
            logger?.log("\(#function): Received \(message)")
            guard let method = message["method"] as? String else { replyHandler(["success": false]); return }
            if method == "addWater" {
                self.receiveWater(message)
                // Transport receipt is deliberately not a diary acknowledgement.
                replyHandler(["received": true])
                return
            }
            guard message["workoutId"] as? String == self.watchSnapshot.workout["id"] as? String,
                  self.watchSnapshot.workout["active"] as? Bool == true,
                  message["setId"] as? String == self.applicationContext.set?.id,
                  self.flutterNativeApi != nil else { replyHandler(["success": false]); return }

            if method == "markThisSetAsDone" {
                self.flutterNativeApi?.markThisSetAsDone(completion: { result in
                    switch result {
                    case .success(): replyHandler(["success": true])
                    case .failure(let error):
                        replyHandler(["success": false])
                        self.logger?.error("Error marking set as done: \(error)")
                    }
                })
            } else if method == "moveWorkoutCursorNext" {
                self.flutterNativeApi?.moveWorkoutCursorNext(completion: { result in
                    switch result {
                    case .success(let moved): replyHandler(["success": moved])
                    case .failure(let error):
                        replyHandler(["success": false])
                        self.logger?.error("Error moving workout cursor to next set: \(error)")
                    }
                })
            } else if method == "moveWorkoutCursorPrevious" {
                self.flutterNativeApi?.moveWorkoutCursorPrevious(completion: { result in
                    switch result {
                    case .success(let moved): replyHandler(["success": moved])
                    case .failure(let error):
                        replyHandler(["success": false])
                        self.logger?.error("Error moving workout cursor to previous set: \(error)")
                    }
                })
            } else if method == "updateSetParameters" {
                self.flutterNativeApi?.updateSetParameters(weight: message["weight"] as? Double, timeSeconds: message["time"] as? Double, reps: Int64(message["reps"] as? Int ?? 0), distance: message["distance"] as? Double, completion: { result in
                    switch result {
                    case .success(): replyHandler(["success": true])
                    case .failure(let error):
                        replyHandler(["success": false])
                        self.logger?.error("Error updating set parameters: \(error)")
                    }
                })
            } else {
                logger?.error("Received unknown message from watch: \(method)")
                return
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        logger?.log("[WorkoutSync] reachability changed: activation=\(session.activationState.rawValue) paired=\(session.isPaired) installed=\(session.isWatchAppInstalled) reachable=\(session.isReachable)")
        Task { @MainActor in
            self.publishWatchSnapshot()
            self.drainWaterEntries()
            if #available(iOS 17, *) { if session.isReachable { self.workout.watchBecameReachable() } }
            else { self.synchronizeLegacyWorkout() }
        }
    }
}


// MARK: - Flutter-Native communication
extension AppDelegate: GymBroNativeHostAPI {
    func getRecordingStatus() throws -> [String?: Any?] {
        guard let id = watchSnapshot.workout["id"] as? String else { return [:] }
        if let intent = watchRecording.intent, intent.request.id == id {
            return ["workoutId": id, "status": intent.confirmation.rawValue, "message": intent.message]
        }
        if #available(iOS 17, *), workout.request?.id == id {
            var status = "pending"
            var message: String?
            switch workout.phase {
            case .active: status = "confirmed"
            case .failed(let reason): status = "unavailable"; message = reason
            case .idle: status = "finished"
            default: break
            }
            return ["workoutId": id, "status": status, "message": message]
        }
        return [:]
    }

    private func emitRecordingStatus() {
        guard let snapshot = try? getRecordingStatus(),
              let id = snapshot["workoutId"] as? String,
              let status = snapshot["status"] as? String else { return }
        flutterNativeApi?.handleRecordingStatus(workoutId: id, status: status, message: snapshot["message"] as? String, completion: { _ in })
    }

    func didUpdateApplicationContext(_ ctx: TypedApplicationContext) {
        self.applicationContext = ctx
        if ctx.isRunning && !self.getHasLiveActivity() {
            self.startLiveActivity()
        } else if !ctx.isRunning {
            self.stopLiveActivity()
        }
        self.updateLiveActivity()
    }
    
    func startWorkout(workoutId: String, startMilliseconds: Int64) throws {
        applicationContext.isRunning = true
        applicationContext.startingTime = Date(milliseconds: startMilliseconds)
        let old = watchSnapshot.workout
        var state: [String: Any] = ["id": workoutId, "active": true, "save": true, "start": startMilliseconds]
        state["metrics"] = metricsStore.ledger(for: workoutId).packet(device: "phone").dictionary
        if old["id"] as? String == workoutId { state["parameters"] = old["parameters"] }
        watchSnapshot.update(workout: state)
        publishWatchSnapshot()
        #if DEBUG
        // Screenshot fixtures synchronize the real companion UI without sensors.
        if workoutId.hasPrefix("screenshot-") { return }
        #endif
        didUpdateApplicationContext(applicationContext)
        if #available(iOS 17, *) { workout.startPhoneWorkout(id: workoutId, start: applicationContext.startingTime) }
        else { startLegacyMetricsMonitor(); publishLegacyMetrics(); watchRecording.start(.init(id: workoutId, start: applicationContext.startingTime)) }
    }

    func stopWorkout(workoutId: String, save: Bool) throws {
        legacyMetricsMonitor?.cancel()
        legacyMetricsMonitor = nil
        if watchSnapshot.workout["id"] as? String == workoutId {
            var state = watchSnapshot.workout
            state["active"] = false
            state["save"] = save
            state["end"] = Date().millisecondsSinceEpoch
            watchSnapshot.update(workout: state)
            applicationContext.isRunning = false
            publishWatchSnapshot()
            didUpdateApplicationContext(applicationContext)
        }
        if #available(iOS 17, *) { workout.stopPhoneWorkout(id: workoutId, save: save) }
        else { watchRecording.stop(id: workoutId, save: save) }
    }

    func setExerciseParameters(parameters: [String?: Any?]) throws {
        guard let id = parameters["workoutId"] as? String,
              id == watchSnapshot.workout["id"] as? String,
              watchSnapshot.workout["active"] as? Bool == true,
              let decoded = NativeWorkoutStateMessage.decodeWorkoutState(from: parameters) else { return }
        
        try applyWorkoutParameters(decoded)
    }

    private func applyWorkoutParameters(_ decoded: NativeWorkoutStateMessage) throws {
        applicationContext.hasExercise = decoded.hasExercise
        applicationContext.exerciseName = decoded.exerciseName
        applicationContext.exerciseColor = decoded.exerciseColor
        applicationContext.exerciseParameters = decoded.exerciseParameters
        applicationContext.startingTime = decoded.startingTime
        applicationContext.restTimeStart = decoded.restTimeStart
        applicationContext.restTimeEnd = decoded.restTimeEnd
        applicationContext.percentageDone = decoded.percentageDone
        applicationContext.set = decoded.set
        var state = watchSnapshot.workout
        state["parameters"] = try decoded.toJSON()
        watchSnapshot.update(workout: state)
        publishWatchSnapshot()

        didUpdateApplicationContext(applicationContext)
    }

    func sendMessage(_ message: [String: Any],
                                 replyHandler: (([String: Any]) -> Void)?,
                                 errorHandler: ((Error) -> Void)?) {
        guard let communicationReadySession = session else {
            // watchOS: A session is always valid, so it will never come here.
            print("Cannot send direct message: No reachable session")
            let error = NSError.init(domain: "WCErrorDomain",
                                    code: 7007,
                                    userInfo: nil)
            errorHandler?(error)
            return
        }

        /* The following trySendingMessageToWatch sometimews fails with
        Error Domain=WCErrorDomain Code=7007 "WatchConnectivity session on paired device is not reachable."
        In this case, the transfer is retried a number of times.
        */
        let maxNrRetries = 5
        var availableRetries = maxNrRetries

        func trySendingMessageToWatch(_ message: [String: Any]) {
            communicationReadySession.sendMessage(message, 
                replyHandler: replyHandler, 
                errorHandler: { [self] error in
                    self.logger?.error(error, context: "sending message to watch failed: error")
                    let nsError = error as NSError
                    if nsError.domain == "WCErrorDomain" && nsError.code == 7007 && availableRetries > 0 {
                        availableRetries = availableRetries - 1
                      let randomDelay = Double.random(in: 0.3...1.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay, execute: {
                            trySendingMessageToWatch(message)
                        })
                    } else {
                        errorHandler?(error)
                    }
            })
        } // trySendingMessageToWatch

        trySendingMessageToWatch(message)
    }
    
    func setSession(_ session: WCSession) {
        self.session = session
    }
    
    func updateHomeWidgetParameters(parameters: [String: Int64], workoutDensityChartData: [Int64]) throws {
        // Update the values on iPhone. Just in case the watch is off
        let defaults = UserDefaults(suiteName: "group.samplasion.gymtracker")
        guard let defaults = defaults else {
            logger?.error("Couldn't update home widget parameters.\nReason: UserDefault object is nil. Current defaults: \(String(describing: defaults))")
            return
        }
        for (key, numberPayload) in parameters {
            defaults.set(numberPayload, forKey: key)
        }
        defaults.set(workoutDensityChartData, forKey: "workout_density_chart_data")
        logger?.log("Updated home widget data: \(parameters)")
        WidgetCenter.shared.reloadAllTimelines()
        
        self.sendMessage(["method": "updateHomeWidgetParameters", "value": parameters, "workoutDensityChartData": workoutDensityChartData], replyHandler: nil, errorHandler: nil)
    }
    
    func requestHealthPermission() {
        guard #available(iOS 17.0, *) else {
            return
        }
        
        // Check that Health data is available on the device.
        if HKHealthStore.isHealthDataAvailable() {
            Task {
                do {
                    // Asynchronously request authorization to the data.
                    try await workout.healthStore.requestAuthorization(toShare: workout.typesToShare, read: workout.typesToRead)
                } catch {
                    
                    // Typically, authorization requests only fail if you haven't set the
                    // usage and share descriptions in your app's Info.plist, or if
                    // Health data isn't available on the current device.
                    self.logger?.error("HealthKit authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Health Data
@available(iOS 17.0, *)
extension AppDelegate {
    func handleHealthUpdate() {
        logger?.log("Updating data: \(workout.activeEnergy) kcal, \(workout.heartRate) bpm")
        self.flutterNativeApi?.handleWorkoutMetrics(energy: workout.activeEnergy == 0 ? nil : workout.activeEnergy, heartRate: workout.heartRate == 0 ? nil : workout.heartRate, completion: {_ in})
    }
    
    func resetHealthData() {
        self.flutterNativeApi?.handleWorkoutMetrics(energy: nil, heartRate: nil, completion: {_ in})
    }
}

@available(iOS 17.0, *)
extension AppDelegate: WorkoutMetricsListener {
    func handleHeartRateUpdate(_ heartRate: Double) {
        guard watchSnapshot.workout["active"] as? Bool == true,
              workout.request?.id == watchSnapshot.workout["id"] as? String else { return }
        logger?.log("Updating data: \(heartRate) bpm")
        self.flutterNativeApi?.handleWorkoutMetrics(energy: nil, heartRate: heartRate, completion: {_ in})
    }
    func handleActiveEnergyUpdate(_ activeEnergy: Double) {
        guard watchSnapshot.workout["active"] as? Bool == true,
              workout.request?.id == watchSnapshot.workout["id"] as? String else { return }
        logger?.log("Updating data: \(activeEnergy) kcal")
        self.flutterNativeApi?.handleWorkoutMetrics(energy: activeEnergy, heartRate: nil, completion: {_ in})
    }
}

// MARK: - Food data
extension AppDelegate {
    func updateFoodParameters(parameters: [String? : Any?]) throws {
        guard let parameters = parameters as? [String: Any] else { return }
        if let state = NativeFoodStateMessage.decodeFoodState(from: parameters) {
            DailyNutritionData.save(state, to: UserDefaults(suiteName: DailyNutritionData.appGroup))
            WidgetCenter.shared.reloadTimelines(ofKind: "GymBroWidgetsWater")
            WidgetCenter.shared.reloadTimelines(ofKind: "GymBroWidgetsNutrition")
        }
        drainWaterEntries()
        latestFoodParameters = parameters
        watchSnapshot.update(food: parameters)
        publishWatchSnapshot()
    }

    private func receiveWorkoutMetrics(_ dictionary: [String: Any]) {
        guard let packet = WorkoutMetricsPacket.decode(dictionary), packet.device == "watch",
              watchSnapshot.workout["active"] as? Bool == true,
              packet.workoutID == watchSnapshot.workout["id"] as? String else { return }
        if #available(iOS 17, *) {
            if let data = try? JSONSerialization.data(withJSONObject: dictionary) { try? workout.handleReceivedData(data) }
        } else if metricsStore.merge(packet) {
            publishLegacyMetrics()
        }
    }

    private func publishPhoneMetrics(_ packet: WorkoutMetricsPacket) {
        guard watchSnapshot.workout["id"] as? String == packet.workoutID else { return }
        let old = watchSnapshot.workout["metrics"] as? [String: Any] ?? [:]
        guard !(old as NSDictionary).isEqual(to: packet.dictionary) else { return }
        var state = watchSnapshot.workout
        state["metrics"] = packet.dictionary
        watchSnapshot.update(workout: state)
        publishWatchSnapshot()
    }

    private func publishLegacyMetrics() {
        guard watchSnapshot.workout["active"] as? Bool == true,
              let id = watchSnapshot.workout["id"] as? String else { return }
        let ledger = metricsStore.ledger(for: id)
        flutterNativeApi?.handleWorkoutMetrics(energy: ledger.totalEnergy,
            heartRate: ledger.liveHeartRate(at: Date(), after: legacyHeartRateInvalidatedAt) ?? 0, completion: { _ in })
        publishPhoneMetrics(ledger.packet(device: "phone"))
    }

    private func startLegacyMetricsMonitor() {
        legacyMetricsMonitor?.cancel()
        legacyHeartRateInvalidatedAt = Date()
        legacyMetricsMonitor = Task { @MainActor in
            while !Task.isCancelled {
                do { try await Task.sleep(nanoseconds: 5_000_000_000) } catch { return }
                self.publishLegacyMetrics()

            }
        }
    }

    private var workoutTransport: WorkoutTransport {
        if #available(iOS 17, *) { return workout.transport }
        return legacyTransport
    }

    private func configureRecordingSync() {
        let transport = workoutTransport
        transport.immediateAvailable = { [weak self] in self?.session?.isReachable == true }
        transport.immediateSend = { [weak self] message, reply, failure in
            guard let session = self?.session, session.isReachable else { failure(WorkoutOperationError.unavailable); return }
            session.sendMessage(message, replyHandler: { response in Task { @MainActor in reply(response) } },
                errorHandler: { error in Task { @MainActor in failure(error) } })
        }
        transport.diagnostic = { [weak self] in self?.logger?.log("[WorkoutSync] \($0)") }
        watchRecording.diagnostic = transport.diagnostic
        watchRecording.canSend = { [weak transport] in transport?.available == true }
        watchRecording.command = { [weak self] command in
            guard let self else { throw WorkoutOperationError.unavailable }
            var command = command
            command["revision"] = self.watchSnapshot.revision
            return try await self.workoutTransport.request(command)
        }
        watchRecording.launch = { [weak self] in
            let config = HKWorkoutConfiguration()
            config.activityType = .traditionalStrengthTraining
            config.locationType = .indoor
            try await HKHealthStore().startWatchApp(toHandle: config)
            while self?.session?.isReachable != true {
                try Task.checkCancellation()
                try await Task.sleep(nanoseconds: 100_000_000)
            }
        }
        watchRecording.deferFinish = { [weak self] command in self?.deferWorkoutFinish(command) }
        watchRecording.onMetrics = { [weak self] in self?.receiveWorkoutMetrics($0) }
        watchRecording.onChange = { [weak self] intent in
            guard let self else { return }
            if #available(iOS 17, *) { self.workout.applyRecordingIntent(intent) }
            self.emitRecordingStatus()
        }
    }

    private func deferWorkoutFinish(_ command: [String: Any]) {
        guard let session, session.activationState == .activated, session.isPaired, session.isWatchAppInstalled else { return }
        var message = command
        message["method"] = "workoutSensor"
        let id = message["requestId"] as? String
        if !session.outstandingUserInfoTransfers.contains(where: { $0.userInfo["requestId"] as? String == id }) {
            session.transferUserInfo(message)
        }
    }

    private func handleWorkoutEnvelope(_ message: [String: Any]) -> Bool {
        if message["method"] as? String == "workoutAuthorizationGranted" {
            watchRecording.authorizationBecameAvailable()
            return true
        }
        if message["method"] as? String == "workoutTerminalAcknowledged" {
            watchRecording.acknowledge(message)
            for transfer in session?.outstandingUserInfoTransfers ?? [] {
                if transfer.userInfo["requestId"] as? String == message["requestId"] as? String { transfer.cancel() }
            }
            return true
        }
        return workoutTransport.receive(message)
    }

    private func synchronizeLegacyWorkout() {
        legacyTransport.flush()
        watchRecording.reconnect()
    }

    private func publishWatchSnapshot() {
        // Training-only/catalog publications also need their own envelope revision.
        watchSnapshot.update()
        var snapshot = watchSnapshot.dictionary
        snapshot["training"] = TrainingPhoneBridge.shared.context
        snapshot = WatchTraining.propertyList(snapshot)
        UserDefaults.standard.set(snapshot, forKey: "watch.snapshot.v2")
        guard let session, session.activationState == .activated, session.isPaired, session.isWatchAppInstalled else { return }
        do { try session.updateApplicationContext(snapshot) }
        catch { logger?.error(error, context: "Unable to publish Watch snapshot") }
        var state = watchSnapshot.workout
        state["workoutId"] = state["id"]
        workoutTransport.publish(state, revision: watchSnapshot.revision)
        if session.isReachable { session.sendMessage(["method": "snapshot", "data": snapshot], replyHandler: nil, errorHandler: { _ in }) }
    }

    private func showWorkoutError(id: String, message: String) {
        guard UIApplication.shared.applicationState == .active,
              let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              var presenter = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
        while let presented = presenter.presentedViewController { presenter = presented }
        guard !(presenter is UIAlertController) else { return }
        let alert = UIAlertController(title: "Workout recording", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        if #available(iOS 17, *), workout.discardedWorkoutIDs.contains(id) {
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                self.workout.stopPhoneWorkout(id: id, save: false)
            })
        }
        presenter.present(alert, animated: true)
    }
}

// MARK: - Intents

extension AppDelegate {
  func updateShadowRoutines(routines: [String: String]) throws {
    print("Updating shadow routines: \(routines) (in key \(RoutineQuery.userDefaultsKey))")
    UserDefaults.standard.set(routines, forKey: RoutineQuery.userDefaultsKey)
  }
}

@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    return [
      AppShortcut(
        intent: StartRoutineIntent(),
        phrases: [
          "Start my \(\.$routine) routine in \(.applicationName)",
          "Begin \(\.$routine) in \(.applicationName)"
        ],
        shortTitle: "Start Routine",
        systemImageName: "dumbbell.fill"
      )
    ]
  }
}

// MARK: - Durable Watch hydration import
extension AppDelegate {
    func waterReceiverReady() throws {
        waterReady = true
        drainWaterEntries()
    }

    private func receiveWater(_ message: [String: Any]) {
        guard let entry = WatchWaterEntry(message: message) else { return }
        waterInbox.insert(entry)
        drainWaterEntries()
    }

    private func drainWaterEntries() {
        guard waterReady, !importingWater, let api = flutterNativeApi, !waterInbox.entries.isEmpty else { return }
        importingWater = true
        waterRetry?.cancel()
        let entries = waterInbox.entries
        func next(_ index: Int) {
            guard index < entries.count else {
                self.importingWater = false
                if !self.waterInbox.entries.isEmpty {
                    let retry = DispatchWorkItem { [weak self] in self?.drainWaterEntries() }
                    self.waterRetry = retry
                    DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: retry)
                }
                return
            }
            let entry = entries[index]
            api.importWaterEntry(id: entry.id, milliliters: entry.milliliters,
                timeMilliseconds: entry.timeMilliseconds, ownerScope: entry.ownerScope) { result in
                DispatchQueue.main.async {
                    if case .success(true) = result {
                        let ack: [String: Any] = ["method": "waterAcknowledged", "ids": [entry.id], "ownerScope": entry.ownerScope]
                        // Queue the acknowledgement before removing our copy. A crash
                        // between these operations only causes an idempotent replay.
                        if let session = self.session, session.activationState == .activated {
                            if !session.outstandingUserInfoTransfers.contains(where: {
                                $0.userInfo["method"] as? String == "waterAcknowledged" &&
                                $0.userInfo["ownerScope"] as? String == entry.ownerScope &&
                                ($0.userInfo["ids"] as? [String])?.contains(entry.id) == true
                            }) { session.transferUserInfo(ack) }
                            if session.isReachable { session.sendMessage(ack, replyHandler: nil, errorHandler: { _ in }) }
                            self.waterInbox.acknowledge(ids: [entry.id], ownerScope: entry.ownerScope)
                        }
                    }
                    next(index + 1)
                }
            }
        }
        next(0)
    }
}
