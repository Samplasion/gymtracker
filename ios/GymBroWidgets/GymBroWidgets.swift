//
//  Widgets.swift
//  Widgets
//
//  Created by Francesco Arieti on 20/01/25.
//

import WidgetKit
import SwiftUI

@available(iOS 17.0, *)
struct Provider: AppIntentTimelineProvider {
    typealias Entry = WorkoutStreakEntry
    
    typealias Intent = ConfigurationAppIntent
    
    func placeholder(in context: Context) -> WorkoutStreakEntry {
        WorkoutStreakEntry(date: Date(), streak: 3, dailyRestStreak: .now.addingTimeInterval(-60*60*24*2), totalWorkouts: 54, workoutDensityChartData: [])
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
            entry = WorkoutStreakEntry(date: Date(), streak: streak, dailyRestStreak: rest, totalWorkouts: total, workoutDensityChartData: [])
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
    
    var bundle: URL {
        let bundle = Bundle.main
        if bundle.bundleURL.pathExtension == "appex" {
            // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
            var url = bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
            url.append(component: "Frameworks/App.framework/flutter_assets")
            return url
        }
        return bundle.bundleURL
    }
    
    init(entry: Provider.Entry, widgetView: GBWidgetView) {
        self.entry = entry
        self.widgetView = widgetView
        CTFontManagerRegisterFontsForURL(bundle.appending(path: "/fonts/GymTracker.ttf") as CFURL, CTFontManagerScope.process, nil)
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
    
    var isOn: Bool {
        entry.streak > 0
    }
    
    var color: Color {
        isOn ? Color.accentColor : Color.secondary
    }

    var body: some View {
        let streak: LocalizedStringKey = "\(entry.streak) weeks"
        let rest: LocalizedStringKey = "\(entry.restStreakDays) days"
        let total: LocalizedStringKey = "\(entry.totalWorkouts) workouts"
        
        @ViewBuilder
        var widgetContent: some View {
            switch (widgetFamily) {
            case .systemSmall:
                VStack {
                    Spacer()
                    GBWidgetIcon(widgetView: widgetView, size: 48, color: color)
                    Spacer()
                    switch (widgetView) {
                    case .streak: Text("Streak").font(.caption)
                    case .rest: Text("Rest").font(.caption)
                    case .total: Text("Total").font(.caption)
                    }
                    switch (widgetView) {
                    case .streak: Text(streak).fontWeight(.semibold)
                    case .rest: Text(rest).fontWeight(.semibold)
                    case .total: Text(total).fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
            case .accessoryCircular:
                VStack {
                    Spacer()
                    GBWidgetIcon(widgetView: widgetView, size: 24, color: color)
                    Spacer()
                    switch (widgetView) {
                    case .streak: Text("\(entry.streak)").font(.caption)
                            .fontWeight(.semibold)
                    case .rest: Text("\(entry.restStreakDays)").font(.caption)
                            .fontWeight(.semibold)
                    case .total: Text("\(entry.totalWorkouts)").font(.caption)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
            case .accessoryRectangular:
                HStack {
                    Spacer()
                    GBWidgetIcon(widgetView: widgetView, size: 32, color: color)
                    Spacer()
                    VStack {
                        switch (widgetView) {
                        case .streak: Text("Streak").font(.caption)
                        case .rest: Text("Rest").font(.caption)
                        case .total: Text("Total").font(.caption)
                        }
                        switch (widgetView) {
                        case .streak: Text(streak).fontWeight(.semibold)
                        case .rest: Text(rest).fontWeight(.semibold)
                        case .total: Text(total).fontWeight(.semibold)
                        }
                    }
                    Spacer()
                }
            case .accessoryInline:
                let icon = GBWidgetIcon(widgetView: widgetView, size: 26, color: color)
                HStack {
                    icon.asSFUI
                    switch (widgetView) {
                    case .streak: Text(streak).font(.caption).fontWeight(.semibold)
                    case .rest: Text(rest).font(.caption).fontWeight(.semibold)
                    case .total: Text(total).font(.caption).fontWeight(.semibold)
                    }
                }
            @unknown default:
                fatalError()
            }
        }
        return widgetContent
    }
}

struct GBWidgetIcon: View {
    let widgetView: GBWidgetView
    let size: Double
    let color: Color
    
    var body: some View {
        switch (widgetView) {
            case .streak: Text("\u{f06d}").font(Font.custom("GymTracker", size: size))
                .foregroundColor(color)
            case .rest: Image(systemName: "moon.fill").frame(width: CGFloat(size), height: CGFloat(size))
                .tint(color)
            case .total: Image(systemName: "gym.bag.fill").frame(width: CGFloat(size), height: CGFloat(size))
                .tint(color)
        }
    }
    
    @ViewBuilder
    var asSFUI: some View {
        if widgetView == .streak {
            Image(systemName: "flame.fill").frame(width: CGFloat(size), height: CGFloat(size)).tint(color)
        } else {
            body
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

//@available(iOS 17, *)
//#Preview(as: .systemSmall) {
//    GymBroWidgets()
//} timeline: {
//    WorkoutStreakEntry(date: .now, streak: 0, dailyRestStreak: 0, totalWorkouts: 0)
//    WorkoutStreakEntry(date: .now.advanced(by: 1), streak: 1, dailyRestStreak: 0, totalWorkouts: 1)
//}
//
