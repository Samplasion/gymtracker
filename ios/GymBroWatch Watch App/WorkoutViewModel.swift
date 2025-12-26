//
//  WorkoutViewModel.swift
//  GymWatch Watch App
//
//  Created by Francesco Arieti on 21/01/25.
//

import Foundation
import WatchConnectivity
#if canImport(WatchKit)
import WatchKit
import WidgetKit
#endif

@MainActor
class WorkoutViewModel: NSObject, ObservableObject {
    @Published var isWorkoutRunning: Bool = false
    @Published var hasNextSet: Bool = false
    @Published var exerciseName: String = ""
    @Published var exerciseColor: Int64 = 0
    @Published var exerciseParameters: String = ""
    @Published var restTimeEnd: Date?
    @Published var isLoading = false
    
    var session: WCSession?
    
    init(session: WCSession = .default) {
        // WatchConnectivity
        self.session = session
        super.init()
        self.session!.delegate = self
        session.activate()
    }
    
    func markThisSetAsDone() {
        isLoading = true
        session!.sendMessage(["method": "markThisSetAsDone"], replyHandler: { response in
            Task {
                await self.playVibration(pattern: (response["success"] != nil) && (response["success"] as? Bool) == true ? .success : .failure)
            }
        }, errorHandler: { error in
            self.log(error.localizedDescription)
            Task {
                await self.playVibration(pattern: .failure)
            }
        })
    }
    
    func requestFreshData() {
        session!.sendMessage(["method": "requestTrainingData"], replyHandler: nil)
    }
    
    func log(_ message: String) {
        NSLog(message)
        session?.sendMessage(["method": "log", "message": message], replyHandler: nil);
    }
    
    func playVibration(pattern: WKHapticType) async {
        await MainActor.run {
            WKInterfaceDevice.current().play(pattern)
            self.isLoading = false
        }
    }
}

extension WorkoutViewModel: @preconcurrency WCSessionDelegate {
#if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) { }
    public func sessionDidDeactivate(_ session: WCSession) { }
#endif
    
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
    }
    
    private func onSetIsWorkoutRunning(_ message: [String: Any]) {
        let oldValue = self.isWorkoutRunning
        
        self.isWorkoutRunning = message["value"] as! Bool
    }
    
    private func onSetExerciseParameters(_ message: [String: Any]) {
        guard message["hasExercise"] != nil, message["exerciseName"] != nil, message["exerciseParameters"] != nil else {
            log("Invalid message format: \(message)\nReason: missing payload")
            return
        }
        
        let hasNextSet = message["hasExercise"] as? Bool
        let exerciseName = message["exerciseName"] as? String
        let exerciseColor = message["exerciseColor"] as? String
        let exerciseParameters = message["exerciseParameters"] as? String
        let restTimeEnd = message["restTimeEnd"] as? Int
        
        guard let hasNextSet = hasNextSet, let exerciseName = exerciseName, let exerciseParameters = exerciseParameters, let restTimeEnd = restTimeEnd else {
            log("Invalid message format: \(message)\nReason: missing required fields")
            return
        }
        
        log("\(message)")
        
        log("Received exercise: \(exerciseName), color: \(exerciseColor ?? "<nil>"), parameters: \(exerciseParameters), restTimeEnd: \(String(describing: restTimeEnd))")
        
        self.hasNextSet = hasNextSet
        if self.hasNextSet {
            self.isWorkoutRunning = true
        }
        self.exerciseName = exerciseName
        self.exerciseColor = parseHexString(exerciseColor)
        self.exerciseParameters = exerciseParameters
        self.restTimeEnd = restTimeEnd == 0 ? nil : Date(timeIntervalSinceReferenceDate: Double(restTimeEnd))
    }

    private func onUpdateHomeWidgetParameters(_ message: [String: Any]) {
        guard message["value"] != nil else {
            log("Invalid message format: \(message)\nReason: missing payload")
            return
        }
        
        let defaults = UserDefaults(suiteName: "group.samplasion.gymtracker")
        guard let defaults = defaults else {
            log("Couldn't update home widget parameters.\nReason: UserDefault object is nil. Current defaults: \(String(describing: defaults))")
            return
        }
        for (key, numberPayload) in (message["value"] as! [String: Int64]) {
            defaults.set(numberPayload, forKey: key)
        }
        log("Updated watch home data: \(message)")
        if #available(watchOS 9.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Fallback on earlier versions
        }
    }
    
#if os(watchOS)
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // If we don't include @MainActor here, Swift gets all fussy about concurrence and whatnot
        Task { @MainActor in
            guard let method = message["method"] as? String else { return }
            
            if method == "setIsWorkoutRunning" {
                onSetIsWorkoutRunning(message)
            } else if method == "setExerciseParameters" {
                onSetExerciseParameters(message)
            } else if method == "updateHomeWidgetParameters" {
                onUpdateHomeWidgetParameters(message)
            } else {
                log("Received unknown message from phone: \(method)")
            }
        }
    }
#endif
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        // Request fresh data when the user flicks their wrist
        if session.isReachable {
            requestFreshData()
        }
    }
    
    func parseHexString(_ hex: String?) -> Int64 {
        guard let hex else {
            log("[parseHexString] nil")
            return 0xffc44040
        }
        
        // Must be in the form "#RRGGBB"
        guard hex.hasPrefix("#"), hex.count == 7 else {
            log("[parseHexString] \(hex) is not in the correct format")
            return 0xffc44040 // default/fallback value
        }
        
        var rgbValue: UInt64 = 0
        let scanner = Scanner(string: String(hex.dropFirst())) // skip '#'
        
        if scanner.scanHexInt64(&rgbValue) {
            return Int64(rgbValue)
        } else {
            log("[parseHexString] Scanner failed to parse \(hex) \"\(hex.dropFirst())\"")
            return 0xffc44040 // fallback if parsing fails
        }
    }
}
