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
  let streak: Int
  let dailyRestStreak: Date
  let totalWorkouts: Int
  let workoutDensityChartData: [Int]
  
  init(date: Date, streak: Int, dailyRestStreak: Date, totalWorkouts: Int, workoutDensityChartData: [Int]) {
    let calendar = Calendar.autoupdatingCurrent
    self.date = calendar.startOfDay(for: dailyRestStreak)
    
    self.streak = streak
    self.dailyRestStreak = dailyRestStreak
    self.totalWorkouts = totalWorkouts
    self.workoutDensityChartData = workoutDensityChartData
  }
  
  var restStreakDays: Int {
    Int(Calendar.current.dateComponents([.day], from: .now, to: dailyRestStreak).day!.magnitude)
  }
  
  var calculatedWorkoutDensityChartData: [Int] {
    var currentData = workoutDensityChartData.map { $0 }
    if currentData.isEmpty {
      return []
    }
    
    if self.restStreakDays > workoutDensityChartData.count {
      return Array(repeating: 0, count: self.restStreakDays)
    } else {
      // "Slide" the workouts
      currentData.removeLast(self.restStreakDays)
      currentData.insert(contentsOf: Array(repeating: 0, count: self.restStreakDays), at: 0)
      return currentData
    }
  }
}
