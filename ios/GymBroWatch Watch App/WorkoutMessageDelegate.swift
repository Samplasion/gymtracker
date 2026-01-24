//
//  WorkoutPhoneMessenger.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import WatchConnectivity

@MainActor
protocol WorkoutMessageDelegate {
    func set(isWorkoutRunning: Bool, shouldSave: Bool)
    func set(exerciseParameters: NativeWorkoutStateMessage)
    func update(widgetParameters: [String: Int64], workoutDensityChartData: [Int64])
    func sessionReachabilityDidChange(_ session: WCSession)
}
