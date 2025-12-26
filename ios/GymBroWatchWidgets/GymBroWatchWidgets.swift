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
        WorkoutStreakEntry(date: Date(), streak: 3, dailyRestStreak: 2, totalWorkouts: 54)
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkoutStreakEntry) -> ()) {
        let entry: WorkoutStreakEntry
        if context.isPreview {
            entry = placeholder(in: context)
        } else {
            // Get the data from the user defaults to display
            let userDefaults = UserDefaults(suiteName: "group.samplasion.gymtracker")
            let streak = userDefaults?.integer(forKey: "weekly_streak") ?? 0
            let rest = userDefaults?.integer(forKey: "daily_rest_streak") ?? 0
            let total = userDefaults?.integer(forKey: "total_workouts") ?? 0
            entry = WorkoutStreakEntry(date: Date(), streak: streak, dailyRestStreak: rest, totalWorkouts: total)
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

struct WorkoutStreakEntry: TimelineEntry {
    var date: Date
    let streak: Int
    let dailyRestStreak: Int
    let totalWorkouts: Int
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
    }
    
    var isOn: Bool {
        entry.streak > 0
    }
    
    var color: Color {
        isOn ? Color.accentColor : Color.secondary
    }

    var body: some View {
        let streak: LocalizedStringKey = "\(entry.streak) weeks"
        let rest: LocalizedStringKey = "\(entry.dailyRestStreak) days"
        let total: LocalizedStringKey = "\(entry.totalWorkouts) workouts"
        
        @ViewBuilder
        var widgetContent: some View {
            switch (widgetFamily) {
            case .accessoryCircular:
                VStack {
                    Spacer()
                    GBWidgetIcon(widgetView: widgetView, size: 24, color: color)
                    Spacer()
                    switch (widgetView) {
                    case .streak: Text("\(entry.streak)")
                            .fontWeight(.semibold).widgetCurvesContent().widgetLabel(streak)
                    case .rest: Text("\(entry.dailyRestStreak)")
                            .fontWeight(.semibold).widgetCurvesContent().widgetLabel(rest)
                    case .total: Text("\(entry.totalWorkouts)")
                            .fontWeight(.semibold).widgetCurvesContent().widgetLabel(total)
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
                        case .streak: Text(streak).fontWeight(.semibold).font(.caption.scaled(by: 1.2))
                        case .rest: Text(rest).fontWeight(.semibold).font(.caption.scaled(by: 1.2))
                        case .total: Text(total).fontWeight(.semibold).font(.caption.scaled(by: 1.2))
                        }
                    }
                    Spacer()
                }
            case .accessoryInline:
                switch (widgetView) {
                case .streak: GBWidgetIcon(widgetView: widgetView, size: 0, color: color).asText + Text(streak)
                case .rest: GBWidgetIcon(widgetView: widgetView, size: 0, color: color).asText + Text(rest)
                case .total: GBWidgetIcon(widgetView: widgetView, size: 0, color: color).asText + Text(total)
                }
            case .accessoryCorner:
                switch (widgetView) {
                case .streak: GBWidgetIcon(widgetView: widgetView, size: 12, color: color).asText.widgetCurvesContent().widgetLabel(streak)
                case .rest: GBWidgetIcon(widgetView: widgetView, size: 12, color: color).asText.widgetCurvesContent().widgetLabel(rest)
                case .total: GBWidgetIcon(widgetView: widgetView, size: 12, color: color).asText.widgetCurvesContent().widgetLabel(total)
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
        asText.frame(width: CGFloat(size), height: CGFloat(size))
                .tint(color)
    }
    
    var asImage: Image {
        switch (widgetView) {
            case .streak: Image(systemName: "flame.fill")
            case .rest: Image(systemName: "moon.fill")
            case .total: Image(systemName: "gym.bag.fill")
        }
    }
    
    var asText: Text {
        Text(asImage)
    }
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
                    .padding()
                    .background()
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
                    .padding()
                    .background()
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
                    .padding()
                    .background()
            }
        }
            .configurationDisplayName("Workouts")
            .description("Keep track of your total workouts.")
            .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
    }
}

//#Preview(as: .accessoryRectangular) {
//    GymBroWatchWidgets()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}
