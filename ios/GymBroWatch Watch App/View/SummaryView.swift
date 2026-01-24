//
//  SummaryView.swift
//  Runner
//
//  Created by Francesco Arieti on 27/12/25.
//

import Foundation
import HealthKit
import HealthKitUI
import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    @State private var activitySummary: HKActivitySummary?

    var body: some View {
        if let workout = workoutManager.workout {
            ScrollView {
                summaryListView(workout: workout)
                    .scenePadding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if activitySummary == nil, let workout = workoutManager.workout {
                    await loadActivitySummary(for: workout, healthStore: workoutManager.healthStore)
                }
            }
        } else {
            ProgressView("Saving Workout")
//                .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private func summaryListView(workout: HKWorkout) -> some View {
        VStack(alignment: .leading) {
            SummaryMetricView(title: LocalizedStringKey("Total Time"), value: stringFromTimeInterval(workoutViewModel.workoutStart!.timeIntervalSince(workout.endDate)))
                .foregroundStyle(.yellow)
            
            SummaryMetricView(title: LocalizedStringKey("Total Energy"), value: "\((workout.totalEnergyBurned ?? HKQuantity(unit: .kilocalorie(), doubleValue: 0)).doubleValue(for: .kilocalorie()).formatted(.number.precision(.fractionLength(1)))) kcal")
                .foregroundStyle(.pink)
            
            if #available(watchOS 9.0, *) {
                SummaryMetricView(title: LocalizedStringKey("Avg. Heart Rate"), value: "\(Int(workout.statistics(for: HKQuantityType(.heartRate))?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())).rounded() ?? 0)) bpm")
                    .foregroundStyle(.red)
            }
            
            Group {
                Text("Activity Rings")
                ActivityRingsView(healthStore: workoutManager.healthStore)
                    .frame(width: 50, height: 50)
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
            }
        }
    }
    
    private func stringFromTimeInterval(_ timeInterval: TimeInterval) -> String {
        let endingDate = Date()
        let startingDate = endingDate.addingTimeInterval(-timeInterval)
        let calendar = Calendar.current

        var componentsNow = calendar.dateComponents([.hour, .minute, .second], from: startingDate, to: endingDate)
        if let hour = componentsNow.hour, let minute = componentsNow.minute, let seconds = componentsNow.second {
            return "\(pad(Int(hour.magnitude))):\(pad(Int(minute.magnitude))):\(pad(Int(seconds.magnitude)))"
        } else {
            return "00:00:00"
        }
    }
    private func pad(_ v: Int) -> String { return (v < 10) ? "0\(v)" : "\(v)" }
    
    private func loadActivitySummary(for workout: HKWorkout, healthStore: HKHealthStore) async {
        let calendar = Calendar.current
        let date = calendar.dateComponents([.year, .month, .day, .calendar], from: workout.startDate)
        let predicate = HKQuery.predicate(forActivitySummariesBetweenStart: date, end: date)
        let query = HKActivitySummaryQuery(predicate: predicate) { _, summaries, _ in
            if let summary = summaries?.first {
                DispatchQueue.main.async {
                    self.activitySummary = summary
                }
            }
        }
        healthStore.execute(query)
    }
}

struct SummaryMetricView: View {
    var title: LocalizedStringKey
    var value: String

    var body: some View {
        Text(title)
            .foregroundStyle(.foreground)
        Text(value)
            .font(.system(.title2, design: .rounded).lowercaseSmallCaps())
        Divider()
    }
}

