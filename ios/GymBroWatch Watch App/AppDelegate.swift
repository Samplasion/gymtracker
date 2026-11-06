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
    private var backgroundTasks: Set<WKWatchConnectivityRefreshBackgroundTask> = []
    private var connectivityObservations: [NSKeyValueObservation] = []
    
    override init() {
        super.init()
        
        WorkoutManager.shared.onMetricsPacket = { [weak self] packet in self?.sendMetrics(packet) }
        WorkoutManager.shared.onDiagnostic = { [weak self] message in self?.log(message) }
        WorkoutManager.shared.onSensorSessionEnded = { [weak self] in
            if self?.workoutViewModel.isWorkoutRunning == true { self?.workoutViewModel.requestFreshData() }
        }
        WorkoutManager.shared.onAuthorizationChanged = { [weak self] in
            self?.workoutViewModel.requestFreshData()
            if WorkoutManager.shared.healthStore.authorizationStatus(for: .workoutType()) == .sharingAuthorized {
                self?.session?.sendMessage(["method": "workoutAuthorizationGranted"], replyHandler: nil, errorHandler: { _ in })
            }
        }
        TrainingViewModel.shared.workout = workoutViewModel
        TrainingViewModel.shared.refresh()
        PhoneMessageResponder.shared.workoutDelegate = workoutViewModel
        PhoneMessageResponder.shared.session = session
        PhoneMessageResponder.shared.foodDelegate = foodViewModel
        foodViewModel.sendWaterEntry = { entry in PhoneMessageResponder.shared.sendWater(entry) }

        let transport = WorkoutManager.shared.transport
        transport.immediateAvailable = { [weak self] in self?.session?.isReachable == true }
        transport.immediateSend = { [weak self] message, reply, failure in
            guard let session = self?.session, session.isReachable else { failure(WorkoutOperationError.unavailable); return }
            session.sendMessage(message, replyHandler: { response in Task { @MainActor in reply(response) } },
                errorHandler: { error in Task { @MainActor in failure(error) } })
        }
        transport.onCommand = { PhoneMessageResponder.shared.receiveCommand($0, reply: $1) }
        transport.onState = { PhoneMessageResponder.shared.receiveWorkoutState($0, revision: $1) }
        PhoneMessageResponder.shared.onWorkFinished = { [weak self] in self?.completeBackgroundTasks() }
        if let session {
            connectivityObservations = [
                session.observe(\.activationState) { [weak self] _, _ in Task { @MainActor in self?.completeBackgroundTasks() } },
                session.observe(\.hasContentPending) { [weak self] _, _ in Task { @MainActor in self?.completeBackgroundTasks() } }
            ]
        }
        
        session?.delegate = self
        session!.activate()
    }
    
    func applicationDidFinishLaunching() {
        
    }

    func handle(_ tasks: Set<WKRefreshBackgroundTask>) {
        for task in tasks {
            if let connectivity = task as? WKWatchConnectivityRefreshBackgroundTask {
                backgroundTasks.insert(connectivity)
                connectivity.expirationHandler = { [weak self, weak connectivity] in
                    Task { @MainActor in
                        guard let connectivity else { return }
                        self?.backgroundTasks.remove(connectivity)
                        connectivity.setTaskCompletedWithSnapshot(false)
                    }
                }
            } else { task.setTaskCompletedWithSnapshot(false) }
        }
        // Defer until delegate callbacks already queued on the main actor can
        // register their asynchronous command work.
        Task { @MainActor in await Task.yield(); self.completeBackgroundTasks() }
    }

    private func completeBackgroundTasks() {
        guard !PhoneMessageResponder.shared.hasPendingCommands,
              session?.activationState != .activated || session?.hasContentPending == false else { return }
        let tasks = backgroundTasks
        backgroundTasks.removeAll()
        for task in tasks { task.setTaskCompletedWithSnapshot(false) }
    }
    
    // HealthKit launch only wakes the UI; the phone handshake owns sensor creation.
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        log("[WorkoutSync] HealthKit launch received on Watch")
        Task { @MainActor in workoutViewModel.requestFreshData() }
    }

    func handleActiveWorkoutRecovery() {
        if ScreenshotMode.enabled { return }
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
        log("[WorkoutSync] Watch activation=\(activationState.rawValue) reachable=\(session.isReachable) error=\(String(describing: error))")
        Task { @MainActor in
            if let packet = WorkoutManager.shared.metricsPacket() { self.sendMetrics(packet) }
            self.workoutViewModel.requestFreshData()
            self.foodViewModel.flushWaterEntries()
        }
    }
    
    func log(_ message: String) {
        NSLog("%@", message)
        session?.sendMessage(["method": "log", "message": message], replyHandler: nil);
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            if WorkoutManager.shared.transport.receive(message) { replyHandler(["success": true]) }
            else { PhoneMessageResponder.shared.receiveCommand(message, reply: replyHandler) }
            self.completeBackgroundTasks()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in PhoneMessageResponder.shared.receiveMessage(message); self.completeBackgroundTasks() }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        log("[WorkoutSync] Watch reachability changed: activation=\(session.activationState.rawValue) reachable=\(session.isReachable)")
        Task { @MainActor in
            PhoneMessageResponder.shared.sessionReachabilityDidChange(session)
            if session.isReachable, let packet = WorkoutManager.shared.metricsPacket() { self.sendMetrics(packet) }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        Task { @MainActor in PhoneMessageResponder.shared.receiveUserInfo(userInfo); self.completeBackgroundTasks() }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if fileTransfer.file.metadata?["kind"] as? String != nil {
            try? FileManager.default.removeItem(at: fileTransfer.file.fileURL)
        }
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // WCSession owns the URL only for the duration of this callback.
        guard let kind = file.metadata?["kind"] as? String,
              let data = try? Data(contentsOf: file.fileURL),
              let document = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        Task { @MainActor in
            if kind == "trainingCatalog" { TrainingViewModel.shared.receiveCatalog(document) }
            else if kind == "trainingAck" { TrainingViewModel.shared.acknowledge(document) }
            else if kind == "trainingPhoneSession" {
                TrainingViewModel.shared.receiveContext(["version": 1, "ownerScope": document["ownerScope"] ?? "", "session": document])
            }
            self.completeBackgroundTasks()
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in PhoneMessageResponder.shared.receiveContext(applicationContext); self.completeBackgroundTasks() }
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
