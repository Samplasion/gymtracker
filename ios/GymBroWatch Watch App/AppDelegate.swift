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
        WorkoutManager.shared.onAuthorizationChanged = { [weak self] in self?.workoutViewModel.requestFreshData() }
        PhoneMessageResponder.shared.workoutDelegate = workoutViewModel
        PhoneMessageResponder.shared.session = session
        PhoneMessageResponder.shared.foodDelegate = foodViewModel
        
        session?.delegate = self
        session!.activate()
    }
    
    func applicationDidFinishLaunching() {
        
    }
    
    // HealthKit launch only wakes the UI; the phone handshake owns sensor creation.
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        Task { @MainActor in workoutViewModel.requestFreshData() }
    }

    func handleActiveWorkoutRecovery() {
        WorkoutManager.shared.enqueue {
            do {
                if let recovered = try await WorkoutManager.shared.healthStore.recoverActiveWorkoutSession() {
                    try await WorkoutManager.shared.recoverWorkout(with: recovered)
                }
                self.workoutViewModel.requestFreshData()
            } catch { self.log("Workout recovery failed: \(error)") }
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        PhoneMessageResponder.shared.receiveCommand(message, reply: replyHandler)
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
    private func sendMetrics() {
        Task { @MainActor in
            let manager = WorkoutManager.shared
            guard let id = manager.request?.id, session?.isReachable == true else { return }
            session?.sendMessage(["method": "workoutMetrics", "workoutId": id, "generation": manager.generation,
                "energy": manager.activeEnergy, "heartRate": manager.heartRate], replyHandler: nil)
        }
    }

    func handleActiveEnergyUpdate(_ activeEnergy: Double) {
        sendMetrics()
    }
    
    func handleHeartRateUpdate(_ heartRate: Double) {
        sendMetrics()
    }
}
