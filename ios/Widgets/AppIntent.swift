//
//  AppIntent.swift
//  Widgets
//
//  Created by Francesco Arieti on 20/01/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Streaks" }
    static var description: IntentDescription { "Show off your weekly streak." }
}
