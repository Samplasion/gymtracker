//
//  PhoneMessageResponder.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import Foundation
import WatchConnectivity

class PhoneMessageResponder: NSObject {
    static let shared = PhoneMessageResponder()
    
    var workoutDelegate: WorkoutMessageDelegate?
    var foodDelegate: FoodMessageDelegate?
    var session: WCSession?
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // If we don't include @MainActor here, Swift gets all fussy about concurrence and whatnot
        Task { @MainActor in
            log("Received message: \(message)")
            
            guard let method = message["method"] as? String else { return }
            
            if method == "setIsWorkoutRunning" {
                workoutDelegate?.set(isWorkoutRunning: message["value"] as! Bool, shouldSave: message["shouldSave"] as? Bool ?? true)
            } else if method == "setExerciseParameters" {
                if let data = message["data"] as? [String: Any],
                   let decoded = NativeWorkoutStateMessage.decodeWorkoutState(from: data) {
                    workoutDelegate?.set(exerciseParameters: decoded)
                } else {
                    log("Unable to decode exercise parameters from phone message: \(message)")
                }
            } else if method == "updateHomeWidgetParameters" {
                guard message["value"] as? [String: Int64] != nil,
                      message["workoutDensityChartData"] as? [Int64] != nil else {
                    log("Invalid message format: \(message)\nReason: missing or malformed payload")
                    return
                }
                workoutDelegate?.update(widgetParameters: message["value"] as! [String: Int64], workoutDensityChartData: message["workoutDensityChartData"] as! [Int64])
            } else {
                log("Received unknown message from phone: \(method)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        log("Received user info: \(userInfo)")
        Task { @MainActor in
            switch (userInfo["kind"] as? String) {
            case "food":
                if let paramsMap = userInfo["parameters"] as? [String: Any],
                   let params = NativeFoodStateMessage.decodeFoodState(from: paramsMap) {
                    foodDelegate?.set(foodParameters: params)
                }
            default:
                log("Unknown user info kind: \(userInfo)")
                break
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        log("Received application context: \(applicationContext)")
        Task { @MainActor in
            switch (applicationContext["kind"] as? String) {
            case "food":
                if let paramsMap = applicationContext["parameters"] as? [String: Any],
                   let params = NativeFoodStateMessage.decodeFoodState(from: paramsMap) {
                    foodDelegate?.set(foodParameters: params)
                }
            default:
                log("Unknown application context kind: \(applicationContext)")
                break
            }
        }
    }
    
    func log(_ message: String) {
        NSLog(message)
        session?.sendMessage(["method": "log", "message": message], replyHandler: nil);
    }
    
    @MainActor
    func sessionReachabilityDidChange(_ session: WCSession) {
        workoutDelegate?.sessionReachabilityDidChange(session)
    }
}
