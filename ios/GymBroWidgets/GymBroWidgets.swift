//
//  Widgets.swift
//  Widgets
//
//  Created by Francesco Arieti on 20/01/25.
//

import WidgetKit
import SwiftUI

@available(iOS 17.0, *)
struct Provider: AppIntentTimelineProvider, TimelineProvider {
  func getSnapshot(in context: Context, completion: @escaping @Sendable (WorkoutStreakEntry) -> Void) {
    Task {
      let snap = await snapshot(for: ConfigurationAppIntent(), in: context)
      DispatchQueue.main.async {
        completion(snap)
      }
    }
  }
  
  func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<WorkoutStreakEntry>) -> Void) {
    Task {
      let snap = await snapshot(for: ConfigurationAppIntent(), in: context)
      DispatchQueue.main.async {
        completion(Timeline(entries: [snap], policy: .atEnd))
      }
    }
  }
  
  typealias Entry = WorkoutStreakEntry
  
  typealias Intent = ConfigurationAppIntent
  
  func placeholder(in context: Context) -> WorkoutStreakEntry {
    .example()
  }
  
  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WorkoutStreakEntry {
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
    return entry
  }
  
  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WorkoutStreakEntry> {
    return Timeline(entries: [await snapshot(for: configuration, in: context)], policy: .atEnd)
  }
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
      case .systemSmall:
        VStack(spacing: 10) {
          GBWidgetIcon(widgetView: widgetView, size: 44, color: color)
          VStack(spacing: 3) {
            Text(title).font(.caption)
            Text(value).font(.headline)
          }
        }
      case .accessoryCircular:
        VStack(spacing: 2) {
          GBWidgetIcon(widgetView: widgetView, size: 20, color: color)
          Text("\(count)").font(.caption).fontWeight(.semibold)
        }
      case .accessoryRectangular:
        HStack(alignment: .center, spacing: 8) {
          GBWidgetIcon(widgetView: widgetView, size: 28, color: color)
          VStack(alignment: .center, spacing: 3) {
            Text(title).font(.caption)
            Text(value).font(.headline).lineLimit(2).minimumScaleFactor(0.7)
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }
      case .accessoryInline:
        HStack(alignment: .center, spacing: 4) {
          GBWidgetIcon(widgetView: widgetView, size: 14, color: color).asSFUI
          Text(value).font(.caption).fontWeight(.semibold)
        }
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
  
  // Gallery snapshots run without the containing Flutter app's asset layout.
  private static let fontAvailable: Bool = {
    guard let url = Bundle.main.url(forResource: "GymTracker", withExtension: "ttf") else { return false }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    return UIFont(name: "GymTracker", size: 12) != nil
  }()

  var body: some View {
    Group {
      if widgetView == .streak && Self.fontAvailable {
        Text("\u{f06d}").font(.custom("GymTracker", size: size))
      } else {
        asSFUI
      }
    }
    .foregroundStyle(color)
    .frame(width: size, height: size, alignment: .center)
  }

  var asSFUI: some View {
    Image(systemName: symbol).resizable().scaledToFit()
      .foregroundStyle(color)
      .frame(width: size, height: size, alignment: .center)
  }

  private var symbol: String {
    switch widgetView {
    case .streak: "flame.fill"
    case .rest: "moon.fill"
    case .total: "gym.bag.fill"
    }
  }
}

@available(iOS 17.0, *)
struct GymBroWidgetsStreak: Widget {
  let kind: String = "GymBroWidgets"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
      WidgetsEntryView(entry: entry, widgetView: .streak)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Streaks")
    .description("Show off your weekly streak.")
    .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
  }
}

@available(iOS 17.0, *)
struct GymBroWidgetsRest: Widget {
  let kind: String = "GymBroWidgetsRest"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
      WidgetsEntryView(entry: entry, widgetView: .rest)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Rest")
    .description("See your rest day streak.")
    .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
  }
}

@available(iOS 17.0, *)
struct GymBroWidgetsTotal: Widget {
  let kind: String = "GymBroWidgetsTotal"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
      WidgetsEntryView(entry: entry, widgetView: .total)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Workouts")
    .description("Keep track of your total workouts.")
    .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
  }
}

@available(iOS 17.0, *)
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
    .description("Your workout density over the last weeks.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@available(iOS 17.0, watchOS 10.0, *)
#Preview("Serie", as: .systemSmall) {
  GymBroWidgetsStreak()
} timeline: {
  WorkoutStreakEntry.example()
}
