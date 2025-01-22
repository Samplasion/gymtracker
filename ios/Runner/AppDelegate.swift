import UIKit
import Flutter
import flutter_local_notifications
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate {
    var session: WCSession?
    var flutterWatchApi: GymWatchFlutterAPI?
    var applicationContext: [String: Any] = [:]
    
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
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            
            let controller = window?.rootViewController as! FlutterViewController
            let api: GymWatchHostAPI = GymWatchHostAPIImpl(session: session!, controller: controller, didUpdateApplicationContext: { ctx in
                self.applicationContext = ctx
            })
            
            GymWatchHostAPISetup.setUp(binaryMessenger: controller.binaryMessenger, api: api)
            flutterWatchApi = GymWatchFlutterAPI(binaryMessenger: controller.binaryMessenger)
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print("Error activating session: \(error)")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.flutterWatchApi?.requestTrainingData(completion: { result in
                switch result {
                case .success(_): break
                case .failure(let error):
                    print("Error requesting training data: \(error)")
                }
            })
        }

        print("Activated session with activationState: \(activationState)")
        // Request fresh data from the app
        do {
            try session.updateApplicationContext(applicationContext)
        } catch {
            print("Error updating application context: \(error)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task {
            guard let method = message["method"] as? String else { return }
            
            if method == "markThisSetAsDone" {
                self.flutterWatchApi?.markThisSetAsDone(completion: { result in
                    switch result {
                    case .success(): break
                    case .failure(let error):
                        print("Error marking set as done: \(error)")
                    }
                })
            } else if method == "requestTrainingData" {
                self.flutterWatchApi?.requestTrainingData(completion: { result in
                    switch result {
                    case .success(_): break
                    case .failure(let error):
                        print("Error requesting training data: \(error)")
                    }
                })
            } else {
                fatalError("Received unknown message from watch: \(method)")
            }
        }
    }
}

private class GymWatchHostAPIImpl: GymWatchHostAPI {
    let session: WCSession
    let controller: UIViewController
    let didUpdateApplicationContext: ([String: Any]) -> Void
    
    var applicationContext: [String: Any] = [
        "value": false,
    ]
    
    init(session: WCSession, controller: UIViewController, didUpdateApplicationContext: @escaping ([String: Any]) -> Void) {
        self.session = session
        self.controller = controller
        self.didUpdateApplicationContext = didUpdateApplicationContext
    }
    
    func setIsWorkoutRunning(isWorkoutRunning: Bool) throws {
        applicationContext["value"] = isWorkoutRunning
        session.sendMessage(["method": "setIsWorkoutRunning", "value": isWorkoutRunning], replyHandler: nil)
        
        didUpdateApplicationContext(applicationContext)
    }
    
    func setExerciseParameters(hasExercise: Bool, exerciseName: String, exerciseColor: Int64, exerciseParameters: String) throws {
        applicationContext.merge([
            "hasExercise": hasExercise,
            "exerciseName": exerciseName,
            "exerciseColor": exerciseColor,
            "exerciseParameters": exerciseParameters
        ], uniquingKeysWith: { old, new in new })
        session.sendMessage([
            "method": "setExerciseParameters",
            "hasExercise": hasExercise,
            "exerciseName": exerciseName,
            "exerciseColor": exerciseColor,
            "exerciseParameters": exerciseParameters
        ], replyHandler: nil)
        
        didUpdateApplicationContext(applicationContext)
    }
}
