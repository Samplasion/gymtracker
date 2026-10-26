//
//  WorkoutStreakEntry.swift
//  Runner
//
//  Created by Francesco Arieti on 04/01/26.
//

import WidgetKit
import Foundation

struct WorkoutStreakEntry: TimelineEntry {
  var date: Date
  let isExample: Bool
  let streak: Int
  let dailyRestStreak: Date
  let totalWorkouts: Int
  let workoutDensityChartData: [Int]
  
  init(date: Date, streak: Int, dailyRestStreak: Date, totalWorkouts: Int, workoutDensityChartData: [Int], isExample: Bool = false) {
    self.date = date
    self.isExample = isExample
    
    self.streak = streak
    self.dailyRestStreak = dailyRestStreak
    self.totalWorkouts = totalWorkouts
    self.workoutDensityChartData = workoutDensityChartData
  }
  
  var restStreakDays: Int {
    max(0, Calendar.autoupdatingCurrent.dateComponents([.day], from: Calendar.autoupdatingCurrent.startOfDay(for: dailyRestStreak), to: Calendar.autoupdatingCurrent.startOfDay(for: date)).day ?? 0)
  }
  
  var calculatedWorkoutDensityChartData: [Int] {
    var currentData = workoutDensityChartData.map { $0 }
    if currentData.isEmpty {
      return []
    }
    
    if self.restStreakDays >= workoutDensityChartData.count {
      return Array(repeating: 0, count: workoutDensityChartData.count)
    } else {
      // "Slide" the workouts
      currentData.removeLast(self.restStreakDays)
      currentData.insert(contentsOf: Array(repeating: 0, count: self.restStreakDays), at: 0)
      return currentData
    }
  }
}


extension WorkoutStreakEntry {
  static func example(at date: Date = .now) -> WorkoutStreakEntry {
    .init(date: date, streak: 3,
          dailyRestStreak: Calendar.autoupdatingCurrent.date(byAdding: .day, value: -2, to: date)!,
          totalWorkouts: 54,
          workoutDensityChartData: exampleDensity, isExample: true)
  }

  /// Stable pseudo-random samples keep the gallery consistent across renders,
  /// without repeating the same pattern every week.
  private static var exampleDensity: [Int] {
    var seed: UInt64 = 0x47594D42524F
    return (0..<126).map { _ in
      seed ^= seed << 13
      seed ^= seed >> 7
      seed ^= seed << 17
      let roll = seed % 100
      return roll < 55 ? 0 : roll < 88 ? 1 : roll < 98 ? 2 : 3
    }
  }

  func displayingExampleIfMissing(_ key: String, defaults: UserDefaults?) -> WorkoutStreakEntry {
    return defaults?.object(forKey: key) == nil ? .example(at: date) : self
  }
}


extension WorkoutStreakEntry {
  var densityDisplay: [Int] {
    let defaults = UserDefaults(suiteName: DailyNutritionData.appGroup)
    let missing = defaults?.object(forKey: "workout_density_chart_data") == nil || defaults?.object(forKey: "daily_rest_streak_since") == nil
    return (isExample || missing) ? Self.example(at: date).calculatedWorkoutDensityChartData : calculatedWorkoutDensityChartData
  }
}
