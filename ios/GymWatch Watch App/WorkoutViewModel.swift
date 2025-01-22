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
#endif

@MainActor
class WorkoutViewModel: NSObject, ObservableObject {
    @Published var isWorkoutRunning: Bool = false
    @Published var hasNextSet: Bool = false
    @Published var exerciseName: String = ""
    @Published var exerciseColor: Int = 0
    @Published var exerciseParameters: String = ""
    
    var session: WCSession?
    
#if os(watchOS)
    var xrSession: WKExtendedRuntimeSession?
#endif
    
    init(session: WCSession = .default) {
        // WatchConnectivity
        self.session = session
        super.init()
        self.session!.delegate = self
        session.activate()
    }
    
    func markThisSetAsDone() {
        session!.sendMessage(["method": "markThisSetAsDone"], replyHandler: nil)
    }
    
    func createExtendedRuntimeSession() {
#if os(watchOS)
        self.xrSession = WKExtendedRuntimeSession()
        self.xrSession!.delegate = self
#endif
    }
}

extension WorkoutViewModel: WCSessionDelegate {
#if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) { }
    public func sessionDidDeactivate(_ session: WCSession) { }
#endif
    
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
    }
    
    private func onSetIsWorkoutRunning(_ message: [String: Any]) {
        let oldValue = self.isWorkoutRunning
        
        self.isWorkoutRunning = message["value"] as! Bool
        
#if os(watchOS)
        if self.isWorkoutRunning {
            if self.xrSession == nil {
                createExtendedRuntimeSession()
                self.xrSession?.start()
            } else if self.xrSession?.expirationDate != nil && self.xrSession!.expirationDate! < Date() {
                createExtendedRuntimeSession()
                self.xrSession?.start()
            } else if !oldValue {
                self.xrSession?.start()
            }
        } else if oldValue && !self.isWorkoutRunning {
            self.xrSession?.invalidate()
        }
#endif
    }
    
    private func onSetExerciseParameters(_ message: [String: Any]) {
        let hasNextSet = message["hasExercise"] as! Bool
        let exerciseName = message["exerciseName"] as! String
        let exerciseColor = message["exerciseColor"] as! Int
        let exerciseParameters = message["exerciseParameters"] as! String
        
        print("Received exercise: \(exerciseName), color: \(exerciseColor), parameters: \(exerciseParameters)")
        
        self.hasNextSet = hasNextSet
        if self.hasNextSet {
            self.isWorkoutRunning = true
        }
        self.exerciseName = exerciseName
        self.exerciseColor = exerciseColor
        self.exerciseParameters = exerciseParameters
    }
    
    // Receive message From AppDelegate.swift that send from ioS devices
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // If we don't include @MainActor here, Swift gets all fussy about concurrence and whatnot
        Task { @MainActor in
            guard let method = message["method"] as? String else { return }
            
            if method == "setIsWorkoutRunning" {
                onSetIsWorkoutRunning(message)
            } else if method == "setExerciseParameters" {
                onSetExerciseParameters(message)
            } else {
                fatalError("Received unknown message from phone: \(method)")
            }
        }
    }
}

#if os(watchOS)
extension WorkoutViewModel: @preconcurrency WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Started extended runtime session with expiry: \(String(describing: extendedRuntimeSession.expirationDate))")
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        print("Extended runtime session invalidated: \(reason)")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session is expiring")
    }
}
#endif
