//
//  WorkoutMetricsListener.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 29/12/25.
//

import Foundation

protocol WorkoutMetricsListener {
    func handleActiveEnergyUpdate(_ activeEnergy: Double)
    func handleHeartRateUpdate(_ heartRate: Double)
}
