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
    var session: WCSession?
    private var latestFoodParameters: [String: Any]?
    private var legacySensorGeneration: String?
    private let metricsStore = WorkoutMetricsStore.shared
    private var legacyMetricsMonitor: Task<Void, Never>?
    private var legacyHeartRateInvalidatedAt = Date()
    private var legacyReconciliationQueued = false
    private var legacyLastProbe = Date.distantPast
    private let legacyWorkoutQueue = WorkoutOperationQueue()
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
        // This is required to make any communication available in the action isolate.
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        if #available(iOS 17, *) {
            requestHealthPermission()
            workout.retrieveRemoteSession()
            
            workout.listener = self
            workout.onMetricsPacket = { [weak self] packet in self?.publishPhoneMetrics(packet) }
            workout.watchAvailable = { [weak self] in self?.session?.isReachable == true }
            workout.remoteCommand = { [weak self] command in
                guard let session = self?.session, session.isReachable else { throw WorkoutOperationError.unavailable }
                return try await withCheckedThrowingContinuation { continuation in
                    var command = command
                    command["revision"] = self?.watchSnapshot.revision ?? 0
                    session.sendMessage(command, replyHandler: { continuation.resume(returning: $0) }, errorHandler: { continuation.resume(throwing: $0) })
                }
            }
            workout.onError = { [weak self] id, message in self?.showWorkoutError(id: id, message: message) }
            for id in workout.discardedWorkoutIDs { workout.retryDiscard(id: id) }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let binaryMessenger = engineBridge.applicationRegistrar.messenger()
        GymBroNativeHostAPISetup.setUp(binaryMessenger: binaryMessenger, api: self)
        flutterNativeApi = GymBroNativeFlutterAPI(binaryMessenger: binaryMessenger)
        logger = FlutterLogger(binaryMessenger: binaryMessenger)

        if WCSession.isSupported() {
            let watchSession = WCSession.default
            watchSession.delegate = self
            setSession(watchSession)
            watchSession.activate()
        }
    }
    
    // MARK: live activity functions
    
    func getHasLiveActivity() -> Bool {
        return ActivityAuthorizationInfo().areActivitiesEnabled && !Activity<GymBroWidgetsAttributes>.activities.isEmpty
    }
        
    func startLiveActivity() {
        if #available(iOS 16.1, *) {
            if ActivityAuthorizationInfo().areActivitiesEnabled {
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
        guard let activity = Activity<GymBroWidgetsAttributes>.activities.first else {
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
        guard let activity = Activity<GymBroWidgetsAttributes>.activities.first else {
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
            logger!.error("Error activating session: \(error)")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.flutterNativeApi?.requestTrainingData(completion: { result in
                switch result {
                case .success(_): break
                case .failure(let error):
                    self.logger!.error("Error requesting training data: \(error)")
                }
            })
        }

        logger!.log("Activated session with activationState: \(activationState)")
        Task { @MainActor in
            self.publishWatchSnapshot()
            if #available(iOS 17, *) { if session.isReachable { self.workout.watchBecameReachable() } }
            else { self.synchronizeLegacyWorkout() }
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
        logger!.log("Watch session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logger!.log("Watch session deactivated")
        session.activate()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in self.publishWatchSnapshot() }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task {
            guard let method = message["method"] as? String else { return }
            
            if method == "requestTrainingData" {
                self.publishWatchSnapshot()
                if #available(iOS 17, *) { self.workout.watchBecameReachable() }
                else { self.synchronizeLegacyWorkout() }
                self.flutterNativeApi?.requestTrainingData(completion: { result in
                    switch result {
                    case .success(_): break
                    case .failure(let error):
                        self.logger!.error("Error requesting training data: \(error)")
                    }
                })
            } else if method == "log" {
                if let messageString = message["message"] as? String {
                    self.logger!.log("[Watch] \(messageString)")
                } else {
                    self.logger!.error("Unknown log message from watch")
                }
            } else if method == "workoutMetrics" {
                self.receiveWorkoutMetrics(message["metrics"] as? [String: Any] ?? [:])
            } else {
                logger!.error("Received unknown message from watch: \(method)")
                return
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task {
            logger?.log("\(#function): Received \(message)")
            guard let method = message["method"] as? String else { replyHandler(["success": false]); return }
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
                        self.logger!.error("Error marking set as done: \(error)")
                    }
                })
            } else if method == "moveWorkoutCursorNext" {
                self.flutterNativeApi?.moveWorkoutCursorNext(completion: { result in
                    switch result {
                    case .success(let moved): replyHandler(["success": moved])
                    case .failure(let error):
                        replyHandler(["success": false])
                        self.logger!.error("Error moving workout cursor to next set: \(error)")
                    }
                })
            } else if method == "moveWorkoutCursorPrevious" {
                self.flutterNativeApi?.moveWorkoutCursorPrevious(completion: { result in
                    switch result {
                    case .success(let moved): replyHandler(["success": moved])
                    case .failure(let error):
                        replyHandler(["success": false])
                        self.logger!.error("Error moving workout cursor to previous set: \(error)")
                    }
                })
            } else if method == "updateSetParameters" {
                self.flutterNativeApi?.updateSetParameters(weight: message["weight"] as? Double, timeSeconds: message["time"] as? Double, reps: Int64(message["reps"] as? Int ?? 0), distance: message["distance"] as? Double, completion: { result in
                    switch result {
                    case .success(): replyHandler(["success": true])
                    case .failure(let error):
                        replyHandler(["success": false])
                        self.logger!.error("Error updating set parameters: \(error)")
                    }
                })
            } else {
                logger!.error("Received unknown message from watch: \(method)")
                return
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            if !session.isReachable {
                if #available(iOS 17, *) {
                    if self.workout.device == "watch" { self.workout.invalidateHeartRate() }
                } else { self.legacyHeartRateInvalidatedAt = Date(); self.publishLegacyMetrics() }
            }
            self.publishWatchSnapshot()
            if #available(iOS 17, *) { if session.isReachable { self.workout.watchBecameReachable() } }
            else { self.synchronizeLegacyWorkout() }
        }
    }
}


// MARK: - Flutter-Native communication
extension AppDelegate: GymBroNativeHostAPI {
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
        didUpdateApplicationContext(applicationContext)
        if #available(iOS 17, *) { workout.startPhoneWorkout(id: workoutId, start: applicationContext.startingTime) }
        else { startLegacyMetricsMonitor(); publishLegacyMetrics(); launchLegacyWatch(); synchronizeLegacyWorkout() }
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
        else {
            var pending = UserDefaults.standard.dictionary(forKey: "workout.remoteFinishes.v2") as? [String: Bool] ?? [:]
            pending[workoutId] = save
            UserDefaults.standard.set(pending, forKey: "workout.remoteFinishes.v2")
            synchronizeLegacyWorkout()
        }
    }

    func setExerciseParameters(parameters: [String?: Any?]) throws {
        guard let id = parameters["workoutId"] as? String,
              id == watchSnapshot.workout["id"] as? String,
              watchSnapshot.workout["active"] as? Bool == true,
              let decoded = NativeWorkoutStateMessage.decodeWorkoutState(from: parameters) else { return }
        
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
                if let id = self.watchSnapshot.workout["id"] as? String,
                   self.metricsStore.ledger(for: id).activeGenerations["watch"] == nil,
                   Date().timeIntervalSince(self.legacyLastProbe) >= 15 { self.synchronizeLegacyWorkout() }
            }
        }
    }

    private func launchLegacyWatch() {
        guard session?.isPaired == true, session?.isWatchAppInstalled == true else { return }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        Task { @MainActor in
            do {
                try await workoutDeadline(10) { try await HKHealthStore().startWatchApp(toHandle: configuration) }
                self.synchronizeLegacyWorkout()
            } catch { self.logger?.error(error, context: "Watch launch") }
        }
    }

    private func synchronizeLegacyWorkout() {
        guard session?.isReachable == true, !legacyReconciliationQueued,
              let id = watchSnapshot.workout["id"] as? String else { return }
        legacyReconciliationQueued = true
        legacyLastProbe = Date()
        let state = watchSnapshot.workout
        let revision = watchSnapshot.revision
        legacyWorkoutQueue.enqueue {
            defer { self.legacyReconciliationQueued = false }
            guard self.watchSnapshot.workout["id"] as? String == id else { return }
            do {
                let pending = UserDefaults.standard.dictionary(forKey: "workout.remoteFinishes.v2") as? [String: Bool] ?? [:]
                for (oldID, save) in pending {
                    let result = try await self.legacySensorCommand(["action": "stop", "workoutId": oldID, "save": save])
                    guard result["success"] as? Bool == true else { throw WorkoutOperationError.unavailable }
                    var remaining = UserDefaults.standard.dictionary(forKey: "workout.remoteFinishes.v2") as? [String: Bool] ?? [:]
                    if remaining[oldID] == save { remaining.removeValue(forKey: oldID) }
                    UserDefaults.standard.set(remaining, forKey: "workout.remoteFinishes.v2")
                }
                guard self.watchSnapshot.workout["id"] as? String == id,
                      self.watchSnapshot.workout["active"] as? Bool == state["active"] as? Bool else { return }
                if state["active"] as? Bool == true {
                    let token = UUID().uuidString
                    let prepared = try await self.legacySensorCommand(["action": "prepare", "workoutId": id,
                        "generation": token, "start": ((state["start"] as? NSNumber)?.doubleValue ?? 0) / 1000,
                        "revision": revision, "metrics": self.metricsStore.ledger(for: id).packet(device: "phone").dictionary,
                        "deadline": Date().addingTimeInterval(10).timeIntervalSince1970])
                    guard prepared["success"] as? Bool == true,
                          self.watchSnapshot.workout["id"] as? String == id,
                          self.watchSnapshot.workout["active"] as? Bool == true else { return }
                    if let metrics = prepared["metrics"] as? [String: Any] { self.receiveWorkoutMetrics(metrics) }
                    self.legacySensorGeneration = prepared["generation"] as? String ?? token
                    _ = try await self.legacySensorCommand(["action": "commit", "workoutId": id,
                        "generation": prepared["generation"] as? String ?? token, "revision": revision,
                        "deadline": Date().addingTimeInterval(10).timeIntervalSince1970])
                } else {
                    _ = try await self.legacySensorCommand(["action": "stop", "workoutId": id, "save": state["save"] as? Bool ?? false])
                }
            } catch { self.logger?.error(error, context: "Watch workout") }
        }
    }

    private func legacySensorCommand(_ command: [String: Any]) async throws -> [String: Any] {
        try await workoutDeadline(10) {
            guard let session = self.session, session.isReachable else { throw WorkoutOperationError.unavailable }
            return try await withCheckedThrowingContinuation { continuation in
                var message = command
                message["method"] = "workoutSensor"
                session.sendMessage(message, replyHandler: { continuation.resume(returning: $0) }, errorHandler: { continuation.resume(throwing: $0) })
            }
        }
    }

    private func publishWatchSnapshot() {
        let snapshot = watchSnapshot.dictionary
        UserDefaults.standard.set(snapshot, forKey: "watch.snapshot.v2")
        guard let session, session.activationState == .activated, session.isPaired, session.isWatchAppInstalled else { return }
        do { try session.updateApplicationContext(snapshot) }
        catch { logger?.error(error, context: "Unable to publish Watch snapshot") }
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
