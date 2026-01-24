import UIKit
import WidgetKit
import HealthKit
import Flutter
import flutter_local_notifications
import WatchConnectivity
import ActivityKit
import GymBroWidgetsExtension

@main
@objc class AppDelegate: FlutterAppDelegate {
    var session: WCSession?
    var flutterNativeApi: GymBroNativeFlutterAPI?
    var applicationContext: TypedApplicationContext = TypedApplicationContext(isRunning: false, hasExercise: false, percentageDone: 0)
    var logger: FlutterLogger?;
    
    private var _workout: Any? = nil
    @available(iOS 26.0, *)
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
        
        GeneratedPluginRegistrant.register(with: self)
        
        // Init communication channel with Flutter
        let controller = window?.rootViewController as! FlutterViewController
        let api: GymBroNativeHostAPI = self
        
        GymBroNativeHostAPISetup.setUp(binaryMessenger: controller.binaryMessenger, api: api)
        flutterNativeApi = GymBroNativeFlutterAPI(binaryMessenger: controller.binaryMessenger)
        logger = FlutterLogger(binaryMessenger: controller.binaryMessenger)
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            
            self.setSession(session!)
            
            session?.activate()
        }
        
        if #available(iOS 26, *) {
            requestHealthPermission()
            workout.retrieveRemoteSession()
            
            workout.listener = self
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
        // Request fresh data from the app
        do {
            try session.updateApplicationContext(applicationContext.toDictionary())
        } catch {
            logger!.error("Error updating application context: \(error)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger!.log("Watch session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logger!.log("Watch session deactivated")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task {
            guard let method = message["method"] as? String else { return }
            
            if method == "requestTrainingData" {
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
                // TODO: Use standard workout mirroring methods
                self.flutterNativeApi?.handleWorkoutMetrics(energy: message["energy"] as? Double, heartRate: message["heartRate"] as? Double, completion: { result in
                    switch result {
                    case .success(): break
                    case .failure(let error):
                        self.logger!.error("Error handling workout metrics: \(error)")
                    }
                })
            } else {
                logger!.error("Received unknown message from watch: \(method)")
                fatalError("Received unknown message from watch: \(method)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task {
            logger?.log("\(#function): Received \(message)")
            guard let method = message["method"] as? String else { return }
            
            if method == "markThisSetAsDone" {
                self.flutterNativeApi?.markThisSetAsDone(completion: { result in
                    switch result {
                    case .success(): replyHandler(["success": true])
                    case .failure(let error):
                        replyHandler(["success": false])
                        self.logger!.error("Error marking set as done: \(error)")
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
                fatalError("Received unknown message from watch: \(method)")
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        logger!.log("Session \(session.hashValue) reachability did change: \(session.activationState)")
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
    
    func startWorkout() throws {
        self.logger!.log("Received startWorkout() from Flutter side")
        if #available(iOS 26, *) {
            Task {
                try await workout.startWatchWorkout(workoutType: .traditionalStrengthTraining)
                Task { @MainActor in
                    self.logger!.log("Started workout on Apple Watch")
                }
            }
        }
        return try setIsWorkoutRunning(isWorkoutRunning: true)
    }
    
    func stopWorkout() throws {
        if #available(iOS 26, *) {
            Task {
                workout.session?.stopActivity(with: .now)
            }
        }
        return try setIsWorkoutRunning(isWorkoutRunning: false)
    }
    
    func setIsWorkoutRunning(isWorkoutRunning: Bool) throws {
        applicationContext.isRunning = isWorkoutRunning
        session?.sendMessage(["method": "setIsWorkoutRunning", "value": isWorkoutRunning], replyHandler: nil)
        
        didUpdateApplicationContext(applicationContext)
    }
    
    func setExerciseParameters(parameters: [String?: Any?]) throws {
        let decoded = NativeWorkoutStateMessage.decodeWorkoutState(from: parameters)!
        
        applicationContext.hasExercise = decoded.hasExercise
        applicationContext.exerciseName = decoded.exerciseName
        applicationContext.exerciseColor = decoded.exerciseColor
        applicationContext.exerciseParameters = decoded.exerciseParameters
        applicationContext.startingTime = decoded.startingTime
        applicationContext.restTimeStart = decoded.restTimeStart
        applicationContext.restTimeEnd = decoded.restTimeEnd
        applicationContext.percentageDone = decoded.percentageDone
        applicationContext.set = decoded.set
//        var msg = [
//            "method": "setExerciseParameters",
//            "value": true,
//            "hasExercise": decoded.hasExercise,
//            "exerciseName": decoded.exerciseName,
//            "exerciseColor": decoded.exerciseColor.hexString,
//            "exerciseParameters": decoded.exerciseParameters,
//            "restTimeEnd": Int(decoded.restTimeEnd?.timeIntervalSinceReferenceDate ?? 0),
//            "startingTime": Int(decoded.startingTime.timeIntervalSinceReferenceDate),
//            "message": try decoded.toJSONString() as Any,
//        ]
//        if let set = try decoded.set?.toJSON() {
//            msg["set"] = set
//        }
//        session?.sendMessage(msg, replyHandler: nil, errorHandler: { [self] err in logger?.error("\(#file) \(#function): \(err.localizedDescription)\n\(msg)")})
        let msg = (try? decoded.toJSON()) ?? [:]
        session?.sendMessage(["method": "setExerciseParameters", "data": msg], replyHandler: nil, errorHandler: { [self] err in logger?.error("\(#file) \(#function): \(err.localizedDescription)\n\(msg)")})
        
        didUpdateApplicationContext(applicationContext)
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
        
        self.session?.sendMessage(["method": "updateHomeWidgetParameters", "value": parameters, "workoutDensityChartData": workoutDensityChartData], replyHandler: nil)
    }
    
    func requestHealthPermission() {
        guard #available(iOS 26.0, *) else {
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
                    fatalError("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
                }
            }
        }
    }
}

// MARK: - Health Data
@available(iOS 26.0, *)
extension AppDelegate {
    func handleHealthUpdate() {
        logger?.log("Updating data: \(workout.activeEnergy) kcal, \(workout.heartRate) bpm")
        self.flutterNativeApi?.handleWorkoutMetrics(energy: workout.activeEnergy == 0 ? nil : workout.activeEnergy, heartRate: workout.heartRate == 0 ? nil : workout.heartRate, completion: {_ in})
    }
    
    func resetHealthData() {
        self.flutterNativeApi?.handleWorkoutMetrics(energy: nil, heartRate: nil, completion: {_ in})
    }
}

@available(iOS 26.0, *)
extension AppDelegate: WorkoutMetricsListener {
    func handleHeartRateUpdate(_ heartRate: Double) {
        logger?.log("Updating data: \(heartRate) bpm")
        self.flutterNativeApi?.handleWorkoutMetrics(energy: nil, heartRate: heartRate == 0 ? nil : heartRate, completion: {_ in})
    }
    func handleActiveEnergyUpdate(_ activeEnergy: Double) {
        logger?.log("Updating data: \(activeEnergy) kcal")
        self.flutterNativeApi?.handleWorkoutMetrics(energy: activeEnergy == 0 ? nil : activeEnergy, heartRate: nil, completion: {_ in})
    }
}

// MARK: - Food data
extension AppDelegate {
    func updateFoodParameters(parameters: [String? : Any?]) throws {
        if let parameters = parameters as? [String: Any] {
            let msg = [
                "kind": "food",
                "parameters": parameters
            ] as [String : Any];
            if session?.activationState == .activated {
                session?.transferUserInfo(msg)
                try? session?.updateApplicationContext(msg)
            }
        }
    }
}
