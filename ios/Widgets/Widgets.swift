//
//  Widgets.swift
//  Widgets
//
//  Created by Francesco Arieti on 20/01/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WorkoutStreakEntry {
        WorkoutStreakEntry(date: Date(), streak: 3)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WorkoutStreakEntry {
        let entry: WorkoutStreakEntry
        if context.isPreview {
            entry = placeholder(in: context)
        } else {
            // Get the data from the user defaults to display
            let userDefaults = UserDefaults(suiteName: "group.gymtrackerwidget")
            let streak = userDefaults?.integer(forKey: "weekly_streak") ?? 0
            entry = WorkoutStreakEntry(date: Date(), streak: streak)
      }
        return entry
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WorkoutStreakEntry> {
        return Timeline(entries: [await snapshot(for: configuration, in: context)], policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct WorkoutStreakEntry: TimelineEntry {
    var date: Date
    
    let streak: Int
}

struct WidgetsEntryView  : View {
    var entry: Provider.Entry
    
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
    
    init(entry: Provider.Entry) {
        self.entry = entry
        CTFontManagerRegisterFontsForURL(bundle.appending(path: "/fonts/GymTracker.ttf") as CFURL, CTFontManagerScope.process, nil)
    }
    
    var isOn: Bool {
        entry.streak > 0
    }
    
    var color: Color {
        isOn ? Color.accentColor : Color.secondary
    }

    var body: some View {
        let k: LocalizedStringKey = "\(entry.streak) weeks"
        VStack {
            Spacer()
            Text("\u{f06d}").font(Font.custom("GymTracker", size: 48))
                .foregroundColor(color)
            Spacer()
            Text("Streak")
                .font(.caption)
            Text(k)
                .fontWeight(.semibold)
            Spacer()
        }
    }
}

struct Widgets: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
            .configurationDisplayName("Streaks")
            .description("Show off your weekly streak.")
            .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    Widgets()
} timeline: {
    WorkoutStreakEntry(date: .now, streak: 0)
    WorkoutStreakEntry(date: .now.advanced(by: 1), streak: 1)
}
