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

enum WorkoutState {
    case notStarted, running, paused, ended, cancelled
    
    var isRunning: Bool {
        return self == .running
    }
}

@MainActor
class WorkoutViewModel: NSObject, ObservableObject {
    @Published var isWorkoutRunning: Bool = false
    @Published var hasNextSet: Bool = false
    @Published var exerciseName: String = ""
    @Published var exerciseColor: Int64 = 0
    @Published var exerciseParameters: String = ""
    @Published var setTypeLabel: String = ""
    @Published var restTimeEnd: Date? = nil {
        willSet {
            if newValue != restTimeEnd {
                vibrationTask?.cancel()
                if newValue != nil {
                    Task {
                        let now = Date.now
                        let delta = newValue!.millisecondsSinceEpoch - now.millisecondsSinceEpoch
                        if delta < 0 { return }
                        let nanoseconds = UInt64(delta) * 1_000_000
                        try? await Task.sleep(nanoseconds: nanoseconds)
                        if Task.isCancelled {
                            return;
                        }
                        log("[\(String(describing: newValue?.description))] Triggering vibration task after \(delta)ms (rest time over)")
                        await self.playVibration(pattern: .notification)
                    }
                }
            }
        }
    }
    @Published var workoutStart: Date?
    @Published var isLoading = false
    @Published var state: WorkoutState = .notStarted
    @Published var set: GTSet?
    
    var vibrationTask: Task<Void, Never>?
    
    var session: WCSession?
    
    init(session: WCSession = .default) {
        // WatchConnectivity
        self.session = session
        super.init()
    }
    
    func markThisSetAsDone() {
        isLoading = true
        session!.sendMessage(["method": "markThisSetAsDone"], replyHandler: { response in
            Task {
                await self.playVibration(pattern: (response["success"] != nil) && (response["success"] as? Bool) == true ? .success : .failure)
                self.isLoading = false
            }
        }, errorHandler: { error in
            self.log(error.localizedDescription)
            Task {
                await self.playVibration(pattern: .failure)
                self.isLoading = false
            }
        })
    }

    func moveWorkoutCursorNext() {
        isLoading = true
        session!.sendMessage(["method": "moveWorkoutCursorNext"], replyHandler: { response in
            Task {
                await self.playVibration(pattern: (response["success"] != nil) && (response["success"] as? Bool) == true ? .success : .failure)
                self.isLoading = false
            }
        }, errorHandler: { error in
            self.log(error.localizedDescription)
            Task {
                await self.playVibration(pattern: .failure)
                self.isLoading = false
            }
        })
    }

    func moveWorkoutCursorPrevious() {
        isLoading = true
        session!.sendMessage(["method": "moveWorkoutCursorPrevious"], replyHandler: { response in
            Task {
                await self.playVibration(pattern: (response["success"] != nil) && (response["success"] as? Bool) == true ? .success : .failure)
                self.isLoading = false
            }
        }, errorHandler: { error in
            self.log(error.localizedDescription)
            Task {
                await self.playVibration(pattern: .failure)
                self.isLoading = false
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
        }
    }
    
    func updateSetParameters(weight: Double?, time: TimeInterval?, reps: Int?, distance: Double?) {
        isLoading = true
        session?.sendMessage([
            "method": "updateSetParameters",
            "weight": weight as Any,
            "time": time as Any,
            "reps": reps as Any,
            "distance": distance as Any
        ], replyHandler: { response in
            Task {
                await self.playVibration(pattern: (response["success"] != nil) && (response["success"] as? Bool) == true ? .success : .failure)
                self.isLoading = false
            }
        }, errorHandler: { _ in
            Task {
                await self.playVibration(pattern: .failure)
                self.isLoading = false
            }
        })
    }
}

extension WorkoutViewModel: @MainActor WorkoutMessageDelegate {
    func set(isWorkoutRunning: Bool, shouldSave: Bool) {
        log("Setting isWorkoutRunning as \(isWorkoutRunning) (saving: \(shouldSave))")
        
        let oldValue = self.isWorkoutRunning
        let oldState = self.state
        
        self.isWorkoutRunning = isWorkoutRunning
        self.state = isWorkoutRunning
            ? .running
            : (shouldSave ? .ended : .cancelled)
        // Don't end what is not started
        if oldState == .notStarted && state == .ended {
            self.state = .notStarted
        }
        if [.ended, .cancelled].contains(where: { $0 == self.state }) && [.ended, .cancelled].contains(where: { $0 == oldState }) && oldState != self.state {
            // Moved "sideways" from an ended state to another; undo that
            log("Invalid sideways state movement detected")
            self.state = oldState
        }
        let newValue = self.isWorkoutRunning
        
        log("isWorkoutRunning: \(oldValue) -> \(newValue)")
        log("isWorkoutRunning: \(oldState) -> \(self.state)")
        
        if #available(watchOS 10.0, *) {
            //            Task {
            //                switch self.state {
            //                case .running:
            //                    if (oldState == .notStarted) {
            //                        try await WorkoutManager.shared.startWorkout(workoutType: .traditionalStrengthTraining)
            //                        try await WorkoutManager.shared.ensureStarted(workoutType: .traditionalStrengthTraining)
            //                    } else if (oldState == .paused) {
            //                        WorkoutManager.shared.session?.resume()
            //                    } else if (oldState == .running) {
            //                        try await WorkoutManager.shared.ensureStarted(workoutType: .traditionalStrengthTraining)
            //                    }
            //                    return
            //                case .paused:
            //                    if (oldState == .running) {
            //                        WorkoutManager.shared.session?.pause()
            //                    }
            //                    return
            //                case .ended:
            //                    WorkoutManager.shared.session?.stopActivity(with: .now)
            //                    return
            //                case .cancelled:
            //                    WorkoutManager.shared.builder?.discardWorkout()
            //                    WorkoutManager.shared.session?.stopActivity(with: .now)
            //                    return
            //                default:
            //                    return
            //                }
            //            }
            if (!oldValue && newValue) {
                // TODO: Remove watch-related workout starting code -
                Task {
                    try await WorkoutManager.shared.startWorkout(workoutType: .traditionalStrengthTraining)
                    //                    try await WorkoutManager.shared.ensureStarted(workoutType: .traditionalStrengthTraining)
                }
            } else if (oldValue && !newValue) {
                // TODO: Remove watch-related workout ending code -
                if (!shouldSave) {
                    WorkoutManager.shared.builder?.discardWorkout()
                }
                WorkoutManager.shared.session?.stopActivity(with: .now)
            } else if (newValue) {
                // TODO: Remove watch-related workout starting code -
                Task {
                    try await WorkoutManager.shared.ensureStarted(workoutType: .traditionalStrengthTraining)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func set(exerciseParameters: NativeWorkoutStateMessage) {
        // Ensuring there is an active workout
        Task {
            if #available(watchOS 10.0, *) {
                log("Ensuring there is an active workout")
                try await WorkoutManager.shared.ensureStarted(workoutType: .traditionalStrengthTraining)
            } else {
                // Fallback on earlier versions
            }
        }
        
//        guard message["hasExercise"] != nil, message["exerciseName"] != nil, message["exerciseParameters"] != nil else {
//            log("Invalid message format: \(message)\nReason: missing payload")
//            return
//        }
        
//        let hasNextSet = message["hasExercise"] as? Bool
//        let exerciseName = message["exerciseName"] as? String
//        let exerciseColor = message["exerciseColor"] as? String
//        let exerciseParameters = message["exerciseParameters"] as? String
//        let restTimeEnd = message["restTimeEnd"] as? Int
//        let workoutStart = message["startingTime"] as? Int
//        var set: GTSet?
//        if let setDict = message["set"] as? [String: Any] {
//            set = GTSet.decode(from: setDict)
//        }
//        
//        guard let hasNextSet = hasNextSet, let exerciseName = exerciseName, let exerciseParameters = exerciseParameters, let restTimeEnd = restTimeEnd, let workoutStart = workoutStart else {
//            log("Invalid message format: \(message)\nReason: missing required fields")
//            return
//        }
        
        self.hasNextSet = exerciseParameters.hasExercise
        if self.hasNextSet {
            self.state = .running
            self.isWorkoutRunning = true
        }
        self.exerciseName = exerciseParameters.exerciseName
        self.exerciseColor = exerciseParameters.exerciseColor
        self.exerciseParameters = exerciseParameters.exerciseParameters
        self.setTypeLabel = exerciseParameters.setTypeLabel
        self.restTimeEnd = exerciseParameters.restTimeEnd
        self.workoutStart = exerciseParameters.startingTime
        self.set = exerciseParameters.set
    }
    
    func update(widgetParameters: [String : Int64], workoutDensityChartData: [Int64]) {
        let defaults = UserDefaults(suiteName: "group.samplasion.gymtracker")
        guard let defaults = defaults else {
            log("Couldn't update home widget parameters.\nReason: UserDefault object is nil. Current defaults: \(String(describing: defaults))")
            return
        }
        for (key, numberPayload) in widgetParameters {
            defaults.set(numberPayload, forKey: key)
        }
        defaults.set(workoutDensityChartData, forKey: "workout_density_chart_data")
        
        log("Updated watch home data: \(widgetParameters)")
        if #available(watchOS 9.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        // Request fresh data when the user flicks their wrist
        if session.isReachable {
            requestFreshData()
        }
    }
}

//extension WorkoutViewModel: @preconcurrency WCSessionDelegate {
//#if os(iOS)
//    public func sessionDidBecomeInactive(_ session: WCSession) { }
//    public func sessionDidDeactivate(_ session: WCSession) { }
//#endif
//    
//    private func onSetIsWorkoutRunning(_ message: [String: Any]) {
//        
//    }
//    
//    private func onSetExerciseParameters(_ message: [String: Any]) {
//        
//    }
//    
//    private func onUpdateHomeWidgetParameters(_ message: [String: Any]) {
//        guard message["value"] != nil else {
//            log("Invalid message format: \(message)\nReason: missing payload")
//            return
//        }
//        
//        let defaults = UserDefaults(suiteName: "group.samplasion.gymtracker")
//        guard let defaults = defaults else {
//            log("Couldn't update home widget parameters.\nReason: UserDefault object is nil. Current defaults: \(String(describing: defaults))")
//            return
//        }
//        for (key, numberPayload) in (message["value"] as! [String: Int64]) {
//            defaults.set(numberPayload, forKey: key)
//        }
//        log("Updated watch home data: \(message)")
//        if #available(watchOS 9.0, *) {
//            WidgetCenter.shared.reloadAllTimelines()
//        } else {
//            // Fallback on earlier versions
//        }
//    }
//    
//#if os(watchOS)
//    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        // If we don't include @MainActor here, Swift gets all fussy about concurrence and whatnot
//        Task { @MainActor in
//            log("Received message: \(message)")
//            
//            guard let method = message["method"] as? String else { return }
//            
//            if method == "setIsWorkoutRunning" {
//                onSetIsWorkoutRunning(message)
//            } else if method == "setExerciseParameters" {
//                onSetExerciseParameters(message)
//            } else if method == "updateHomeWidgetParameters" {
//                onUpdateHomeWidgetParameters(message)
//            } else {
//                log("Received unknown message from phone: \(method)")
//            }
//        }
//    }
//#endif
//    
////    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
////        // Request fresh data when the user flicks their wrist
////        if session.isReachable {
////            requestFreshData()
////        }
////    }
//    
//    func parseHexString(_ hex: String?) -> Int64 {
//        guard let hex else {
//            log("[parseHexString] nil")
//            return 0xffc44040
//        }
//        
//        // Must be in the form "#RRGGBB"
//        guard hex.hasPrefix("#"), hex.count == 7 else {
//            log("[parseHexString] \(hex) is not in the correct format")
//            return 0xffc44040 // default/fallback value
//        }
//        
//        var rgbValue: UInt64 = 0
//        let scanner = Scanner(string: String(hex.dropFirst())) // skip '#'
//        
//        if scanner.scanHexInt64(&rgbValue) {
//            return Int64(rgbValue)
//        } else {
//            log("[parseHexString] Scanner failed to parse \(hex) \"\(hex.dropFirst())\"")
//            return 0xffc44040 // fallback if parsing fails
//        }
//    }
//}

