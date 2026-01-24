//
//  AppDelegate.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 26/12/25.
//

import Foundation
import WatchKit
import HealthKit
import WatchConnectivity
import os

class GBAppDelegate: NSObject, WKApplicationDelegate {
    var workoutViewModel = WorkoutViewModel()
    var foodViewModel = FoodViewModel()
    
    var session: WCSession? = .default
    
    override init() {
        super.init()
        
        WorkoutManager.shared.listener = self
        PhoneMessageResponder.shared.workoutDelegate = workoutViewModel
        PhoneMessageResponder.shared.foodDelegate = foodViewModel
        
        session?.delegate = self
        session!.activate()
    }
    
    func applicationDidFinishLaunching() {
        
    }
    
    // Attempt dangling workout recovery
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        log("Handling active workout recovery... (handle(_:)")
        if #available(watchOS 10.0, *) {
            Task {
                do {
                    WorkoutManager.shared.resetWorkout()
                    try await WorkoutManager.shared.startWorkout(workoutConfiguration: workoutConfiguration)
                    log("Successfully started workout")
                } catch {
                    log("Failed started workout")
                }
            }
        } else {
            log("watchOS 10.0 not available")
        }
    }
    
    func handleActiveWorkoutRecovery() {
        log("Handling active workout recovery... (handleActiveWorkoutRecovery())")
        if #available(watchOS 10.0, *) {
            Task {
                let session = try await WorkoutManager.shared.healthStore.recoverActiveWorkoutSession()
                guard let session = session else {
                    log("Session object is null")
                    return
                }
                try await WorkoutManager.shared.recoverWorkout(with: session)
            }
        }
    }
}

extension GBAppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        log("GBAppDelegate: WCsession activationDidCompleteWith activationState: \(activationState)")
    }
    
    func log(_ message: String) {
        NSLog(message)
        session?.sendMessage(["method": "log", "message": message], replyHandler: nil);
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        PhoneMessageResponder.shared.session(session, didReceiveMessage: message)
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        PhoneMessageResponder.shared.sessionReachabilityDidChange(session)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        PhoneMessageResponder.shared.session(session, didReceiveUserInfo: userInfo)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        PhoneMessageResponder.shared.session(session, didReceiveApplicationContext: applicationContext)
    }
}

extension GBAppDelegate: WorkoutMetricsListener {
    func handleActiveEnergyUpdate(_ activeEnergy: Double) {
        session?.sendMessage(["method": "workoutMetrics", "energy": activeEnergy], replyHandler: nil);
    }
    
    func handleHeartRateUpdate(_ heartRate: Double) {
        session?.sendMessage(["method": "workoutMetrics", "heartRate": heartRate], replyHandler: nil);
    }
}
