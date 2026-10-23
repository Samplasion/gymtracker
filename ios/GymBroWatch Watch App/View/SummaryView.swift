import HealthKit
import SwiftUI

struct SummaryView: View {
    let workoutID: String
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var longWait = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                switch result {
                case .saved(let workout):
                    SummaryMetricView(title: "Total Time", value: duration(elapsedTime(for: workout)))
                        .foregroundStyle(.yellow)
                    SummaryMetricView(title: "Total Energy", value: "\(workoutManager.metricsStore.ledger(for: workoutID).totalEnergy.formatted(.number.precision(.fractionLength(1)))) kcal")
                        .foregroundStyle(.pink)
                    SummaryMetricView(title: "Avg. Heart Rate", value: "\(Int(workout.statistics(for: HKQuantityType(.heartRate))?.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0)) bpm")
                        .foregroundStyle(.red)
                    Text("Activity Rings")
                    ActivityRingsView(healthStore: workoutManager.healthStore).frame(width: 50, height: 50)
                case .saving:
                    ProgressView("Saving Workout")
                    if longWait { Text("Saving is taking longer than expected. You can close this screen.").font(.footnote) }
                case .failed(let message):
                    Text("Unable to save workout").font(.headline)
                    Text(message).font(.footnote)
                    if workoutManager.discardedWorkoutIDs.contains(workoutID) {
                        Button("Retry") { workoutManager.retryDiscard(id: workoutID) }
                    }
                case .discarded:
                    Text("Workout discarded")
                }
                Button("Done") { dismiss() }
            }
            .scenePadding()
        }
        .navigationTitle("Summary")
        .task {
            do { try await Task.sleep(nanoseconds: 30_000_000_000) }
            catch { return }
            longWait = true
        }
    }

    private var result: WorkoutSummary.Result {
        guard let summary = workoutManager.summary, summary.id == workoutID else { return .saving }
        return summary.result
    }
    private func elapsedTime(for workout: HKWorkout) -> TimeInterval {
        guard workoutViewModel.workoutID == workoutID else { return workout.duration }
        let start = workoutViewModel.workoutStart ?? workout.startDate
        let end = workoutViewModel.workoutEnd ?? workout.endDate
        return max(0, end.timeIntervalSince(start))
    }
    private func duration(_ interval: TimeInterval) -> String {
        let seconds = max(0, Int(interval))
        return String(format: "%02d:%02d:%02d", seconds / 3600, (seconds / 60) % 60, seconds % 60)
    }
}

struct SummaryMetricView: View {
    var title: LocalizedStringKey
    var value: String
    var body: some View {
        Text(title)
        Text(value).font(.system(.title2, design: .rounded).lowercaseSmallCaps())
        Divider()
    }
}
