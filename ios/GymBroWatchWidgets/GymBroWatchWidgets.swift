//
//  GymBroWatchWidgets.swift
//  GymBroWatchWidgets
//
//  Created by Francesco Arieti on 25/12/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> WorkoutStreakEntry {
    .example()
  }
  
  func getSnapshot(in context: Context, completion: @escaping (WorkoutStreakEntry) -> ()) {
    let entry: WorkoutStreakEntry
    if context.isPreview {
      entry = placeholder(in: context)
    } else {
      // Get the data from the user defaults to display
      let userDefaults = UserDefaults(suiteName: "group.samplasion.gymtracker")
      let streak = userDefaults?.integer(forKey: "weekly_streak") ?? 0
      let restTimestamp = Double(userDefaults?.integer(forKey: "daily_rest_streak_since") ?? 0)
      let rest = Date(timeIntervalSince1970: restTimestamp / 1000)
      let total = userDefaults?.integer(forKey: "total_workouts") ?? 0
      let workoutDensityChartData = userDefaults?.array(forKey: "workout_density_chart_data") as? [Int] ?? Array(repeating: 0, count: 7*18)
      entry = WorkoutStreakEntry(date: Date(), streak: streak, dailyRestStreak: rest, totalWorkouts: total, workoutDensityChartData: workoutDensityChartData)
    }
    completion(entry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    getSnapshot(in: context) { entry in
      completion(Timeline(entries: [entry], policy: .atEnd))
    }
  }
  
  //    func relevances() async -> WidgetRelevances<Void> {
  //        // Generate a list containing the contexts this widget is relevant in.
  //    }
}

enum GBWidgetView {
    case streak
    case rest
    case total
}

@available(iOS 17.0, *)
struct WidgetsEntryView: View {
  @Environment(\.widgetFamily) var widgetFamily
  var entry: Provider.Entry
  let widgetView: GBWidgetView
  
  init(entry: Provider.Entry, widgetView: GBWidgetView) {
    self.entry = entry.isExample ? entry : entry.displayingExampleIfMissing(
      widgetView == .streak ? "weekly_streak" : widgetView == .rest ? "daily_rest_streak_since" : "total_workouts",
      defaults: UserDefaults(suiteName: "group.samplasion.gymtracker"))
    self.widgetView = widgetView
  }

  var isOn: Bool {
    entry.streak > 0
  }
  
  var color: Color {
    isOn ? Color.accentColor : Color.secondary
  }
  
  private var title: LocalizedStringKey {
    switch widgetView {
    case .streak: "Streak"
    case .rest: "Rest"
    case .total: "Total"
    }
  }

  private var value: LocalizedStringKey {
    switch widgetView {
    case .streak: "\(entry.streak) weeks"
    case .rest: "\(entry.restStreakDays) days"
    case .total: "\(entry.totalWorkouts) workouts"
    }
  }

  private var count: Int {
    switch widgetView {
    case .streak: entry.streak
    case .rest: entry.restStreakDays
    case .total: entry.totalWorkouts
    }
  }

  var body: some View {
    @ViewBuilder
    var content: some View {
      switch widgetFamily {
      case .accessoryCircular:
        VStack(spacing: 2) {
          GBWidgetIcon(widgetView: widgetView, size: 20, color: color)
          Text("\(count)").font(.caption).fontWeight(.semibold)
        }
        .widgetLabel { Text(value) }
      case .accessoryRectangular:
        HStack(alignment: .center, spacing: 8) {
          GBWidgetIcon(widgetView: widgetView, size: 28, color: color)
          VStack(alignment: .center, spacing: 3) {
            Text(title).font(.caption)
            Text(value).font(.system(size: 14, weight: .semibold)).lineLimit(2).minimumScaleFactor(0.7)
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }
      case .accessoryInline:
        GBWidgetIcon(widgetView: widgetView, size: 0, color: color).asText + Text(" ") + Text(value)
      case .accessoryCorner:
        GBWidgetIcon(widgetView: widgetView, size: 12, color: color).asText
          .widgetCurvesContent().widgetLabel { Text(value) }
      default:
        EmptyView()
      }
    }
    return content
      .multilineTextAlignment(.center)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
  }
}

struct GBWidgetIcon: View {
  let widgetView: GBWidgetView
  let size: Double
  let color: Color
  
  var body: some View {
    asImage.resizable().scaledToFit()
      .foregroundStyle(color)
      .frame(width: size, height: size, alignment: .center)
  }

  var asImage: Image {
    switch widgetView {
    case .streak: Image(systemName: "flame.fill")
    case .rest: Image(systemName: "moon.fill")
    case .total: Image(systemName: "gym.bag.fill")
    }
  }

  var asText: Text { Text(asImage) }
}

@available(iOS 17, *)
struct GymBroWidgetsStreak: Widget {
  let kind: String = "GymBroWidgets"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(watchOS 10.0, *) {
        WidgetsEntryView(entry: entry, widgetView: .streak)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        WidgetsEntryView(entry: entry, widgetView: .streak)
          .background(.clear)
      }
    }
    .configurationDisplayName("Streaks")
    .description("Show off your weekly streak.")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
  }
}

@available(iOS 17, *)
struct GymBroWidgetsRest: Widget {
  let kind: String = "GymBroWidgetsRest"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(watchOS 10.0, *) {
        WidgetsEntryView(entry: entry, widgetView: .rest)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        WidgetsEntryView(entry: entry, widgetView: .rest)
          .background(.clear)
      }
    }
    .configurationDisplayName("Rest")
    .description("See your rest day streak.")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
  }
}

@available(iOS 17, *)
struct GymBroWidgetsTotal: Widget {
  let kind: String = "GymBroWidgetsTotal"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(watchOS 10.0, *) {
        WidgetsEntryView(entry: entry, widgetView: .total)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        WidgetsEntryView(entry: entry, widgetView: .total)
          .background(.clear)
      }
    }
    .configurationDisplayName("Workouts")
    .description("Keep track of your total workouts.")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
  }
}

struct GymBroWidgetsDensity: Widget {
  let kind: String = "GymBroWidgetsDensity"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(watchOS 10.0, *) {
        DensityChart(values: entry.densityDisplay)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        DensityChart(values: entry.densityDisplay)
          .background(.clear)
      }
    }
    .configurationDisplayName("Workout density")
    .description("Your workout density over the last 18 weeks.")
    .supportedFamilies([.accessoryRectangular])
    .contentMarginsDisabled()
  }
}

@available(iOS 17.0, watchOS 10.0, *)
#Preview("Serie", as: .accessoryRectangular) {
  GymBroWidgetsStreak()
} timeline: {
  WorkoutStreakEntry.example()
}
