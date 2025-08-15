import UIKit
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
        let api: GymBroNativeHostAPI = GymBroNativeHostAPIImpl(controller: controller, didUpdateApplicationContext: { ctx in
            self.applicationContext = ctx
            if ctx.isRunning && !self.getHasLiveActivity() {
                self.startLiveActivity()
            } else if !ctx.isRunning {
                self.stopLiveActivity()
            }
            self.updateLiveActivity()
        })
        
        GymBroNativeHostAPISetup.setUp(binaryMessenger: controller.binaryMessenger, api: api)
        flutterNativeApi = GymBroNativeFlutterAPI(binaryMessenger: controller.binaryMessenger)
        logger = FlutterLogger(binaryMessenger: controller.binaryMessenger)
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            
            (api as! GymBroNativeHostAPIImpl).setSession(session!)
            
            session?.activate()
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
                        Couldn't start activity
                        ------------------------
                        \(String(describing: error))
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
            } else {
                logger!.error("Received unknown message from watch: \(method)")
                fatalError("Received unknown message from watch: \(method)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task {
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

struct TypedApplicationContext {
    var isRunning: Bool
    var hasExercise: Bool
    var exerciseName: String?
    var exerciseColor: Int64?
    var exerciseParameters: String?
    var startingTime: Date = Date()
    var restTimeStart: Date?
    var restTimeEnd: Date?
    var percentageDone: Double
    
    func toDictionary() -> [String: Any] {
        if isRunning {
            return [
                "value": true,
                "hasExercise": hasExercise,
                "exerciseName": exerciseName as Any,
                "exerciseColor": exerciseColor as Any,
                "exerciseParameters": exerciseParameters as Any,
                "startingTime": startingTime as Any,
                "restTimeStart": restTimeStart as Any,
                "restTimeEnd": restTimeEnd as Any,
                "percentageDone": percentageDone as Any
            ]
        } else {
            return [
                "value": false
            ]
        }
    }
}

private class GymBroNativeHostAPIImpl: GymBroNativeHostAPI {
    var session: WCSession?
    let controller: UIViewController
    let didUpdateApplicationContext: (TypedApplicationContext) -> Void
    
    var applicationContext: TypedApplicationContext = TypedApplicationContext(isRunning: false, hasExercise: false, percentageDone: 0)
    
    init(controller: UIViewController, didUpdateApplicationContext: @escaping (TypedApplicationContext) -> Void) {
        self.controller = controller
        self.didUpdateApplicationContext = didUpdateApplicationContext
    }
    
    func startWorkout() throws {
        return try setIsWorkoutRunning(isWorkoutRunning: true)
    }
    
    func stopWorkout() throws {
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
        session?.sendMessage([
            "method": "setExerciseParameters",
            "value": true,
            "hasExercise": decoded.hasExercise,
            "exerciseName": decoded.exerciseName,
            "exerciseColor": decoded.exerciseColor.hexString,
            "exerciseParameters": decoded.exerciseParameters,
            "restTimeEnd": Int(decoded.restTimeEnd?.timeIntervalSinceReferenceDate ?? 0),
            "message": try decoded.toJSONString() as Any
        ], replyHandler: nil)
        
        didUpdateApplicationContext(applicationContext)
    }
    
    func setSession(_ session: WCSession) {
        self.session = session
    }
}

extension Int64 {
    var hexString: String {
        return "#" + String(self, radix: 16).padding(toLength: 8, withPad: "0", startingAt: 0).dropFirst(2)
    }
}
