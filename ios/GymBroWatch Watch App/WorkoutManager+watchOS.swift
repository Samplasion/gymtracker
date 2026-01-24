//
//  WorkoutManager.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 26/12/25.
//

import Foundation
import os
import HealthKit

// MARK: - watchOS Workout session management
@available(watchOS 10.0, *)
extension WorkoutManager {
    /**
     Use healthStore.requestAuthorization to request authorization in watchOS when
     healthDataAccessRequest isn't available yet.
     */
    func requestAuthorization() {
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            } catch {
                Logger.shared.log("Failed to request authorization: \(error)")
            }
        }
    }
    
    func startWorkout(workoutType: HKWorkoutActivityType) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .indoor
        return try await startWorkout(workoutConfiguration: configuration)
    }
    
    func startWorkout(workoutConfiguration: HKWorkoutConfiguration) async throws {
        Logger.shared.log("Starting workout session: \(workoutConfiguration)")
        
        session = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
        builder = session?.associatedWorkoutBuilder()
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: workoutConfiguration)
        /**
          Start mirroring the session to the companion device.
         */
        session?.prepare()
        // TODO: Figure out how this works
//        let res = try await session?.startMirroringToCompanionDevice()
//        Logger.shared.log(level: .fault, "\(#function): [AW] Received \(String(describing: res)) from startMirroringToCompanionDevice")
        /**
          Start the workout session activity.
         */
        let startDate = Date()
        session?.startActivity(with: startDate)
        do {
            try await builder?.beginCollection(at: startDate)
        } catch {
            Logger.shared.error("\(#function): Couldn't begin data collection: \(error)")
        }
    }
    
    func handleReceivedData(_ data: Data) throws {
        guard let decodedQuantity = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQuantity.self, from: data) else {
            return
        }

//        let sampleDate = Date()
//        Task {
//            let waterSample = [HKQuantitySample(type: HKQuantityType(.dietaryWater), quantity: decodedQuantity, start: sampleDate, end: sampleDate)]
//            try await builder?.addSamples(waterSample)
//        }
    }
    
    func ensureStarted(workoutType: HKWorkoutActivityType) async throws {
        if session != nil && builder != nil {
            // The workout is already running or paused, do nothing.
            return
        }
//        // No active session; start a new workout session.
        try await startWorkout(workoutType: workoutType)
    }
    
    func recoverWorkout(with recoveredSession: HKWorkoutSession) async throws {
        guard recoveredSession.state == .running else {
            Logger.shared.info("\(#function): Recovered workout session is not running")
            recoveredSession.end()
            return
        }
        
        // Assign delegates
        let recoveredBuilder = recoveredSession.associatedWorkoutBuilder()
        recoveredSession.delegate = self
        recoveredBuilder.delegate = self
        
        // Assign data source for builder
        let config = HKWorkoutConfiguration()
        config.activityType = recoveredSession.workoutConfiguration.activityType
        config.locationType = recoveredSession.workoutConfiguration.locationType
        recoveredBuilder.dataSource = .init(healthStore: healthStore, workoutConfiguration: config)
        
        // Restart session mirroring
        do {
            try await recoveredSession.startMirroringToCompanionDevice()
        } catch {
            Logger.shared.error("\(#function): Failed to start mirroring to companion device: \(error)")
        }
        
        // Retain the session and the builder
        self.session = recoveredSession
        self.builder = recoveredBuilder
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
// HealthKit calls the delegate methods on an anonymous serial background queue,
// so the methods need to be nonisolated explicitly.
//
@available(watchOS 10.0, *)
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        Logger.shared.info("Collected workout data: \(collectedTypes.map(\.identifier).joined(separator: ", "))")
        
        /**
          HealthKit calls this method on an anonymous serial background queue.
          Use Task to provide an asynchronous context so MainActor can come to play.
         */
        Task { @MainActor in
            var allStatistics: [HKStatistics] = []
            
            for type in collectedTypes {
                if let quantityType = type as? HKQuantityType, let statistics = workoutBuilder.statistics(for: quantityType) {
                    updateForStatistics(statistics)
                    allStatistics.append(statistics)
                }
            }
            
            let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: allStatistics, requiringSecureCoding: true)
            guard let archivedData = archivedData, !archivedData.isEmpty else {
                Logger.shared.log("Encoded data is empty")
                return
            }
            /**
              Send a Data object to the connected remote workout session.
             */
            await sendData(archivedData)
        }
    }
    
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
}
