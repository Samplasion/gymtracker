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
        
        WorkoutManager.shared.onMetricsPacket = { [weak self] packet in self?.sendMetrics(packet) }
        WorkoutManager.shared.onSensorSessionEnded = { [weak self] in
            if self?.workoutViewModel.isWorkoutRunning == true { self?.workoutViewModel.requestFreshData() }
        }
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
        Task { @MainActor in
            if let packet = WorkoutManager.shared.metricsPacket() { self.sendMetrics(packet) }
            self.workoutViewModel.requestFreshData()
        }
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
        Task { @MainActor in
            if session.isReachable, let packet = WorkoutManager.shared.metricsPacket() { self.sendMetrics(packet) }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        PhoneMessageResponder.shared.session(session, didReceiveUserInfo: userInfo)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        PhoneMessageResponder.shared.session(session, didReceiveApplicationContext: applicationContext)
    }
}

extension GBAppDelegate {
    private func sendMetrics(_ packet: WorkoutMetricsPacket) {
        guard let session, session.activationState == .activated else { return }
        let envelope: [String: Any] = ["kind": "workoutMetrics", "metrics": packet.dictionary]
        // Replaceable, complete history: offline collection never creates a queue
        // of incremental values that could be counted twice after reconnecting.
        try? session.updateApplicationContext(envelope)
        if session.isReachable {
            session.sendMessage(["method": "workoutMetrics", "metrics": packet.dictionary], replyHandler: nil, errorHandler: { _ in })
        }
    }
}
