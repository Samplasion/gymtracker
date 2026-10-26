import Foundation

@main
struct WidgetExamplesTest {
    static func main() {
        let now = Date()
        let entry = WorkoutStreakEntry(date: now, streak: 0, dailyRestStreak: now, totalWorkouts: 0, workoutDensityChartData: [])
        precondition(entry.date == now)
        precondition(entry.restStreakDays == 0)
        let example = WorkoutStreakEntry.example(at: now)
        precondition(example.isExample && example.streak > 0 && example.totalWorkouts > 0)
        precondition(example.restStreakDays == 2)
        precondition(example.calculatedWorkoutDensityChartData.count == 126)
        precondition(example.calculatedWorkoutDensityChartData.contains { $0 > 0 })
        let suite = "GymBro.WidgetExamplesTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        for key in ["weekly_streak", "total_workouts", "daily_rest_streak_since"] {
            precondition(entry.displayingExampleIfMissing(key, defaults: defaults).isExample)
            defaults.set(0, forKey: key)
            precondition(!entry.displayingExampleIfMissing(key, defaults: defaults).isExample)
        }
        let stale = WorkoutStreakEntry(date: now, streak: 0, dailyRestStreak: .distantPast, totalWorkouts: 1, workoutDensityChartData: [1, 2, 3])
        precondition(stale.calculatedWorkoutDensityChartData == [0, 0, 0])
        print("Widget examples: missing keys, real zero, entry date, populated preview and bounded density passed")
    }
}
