//
//  GymWatchApp.swift
//  GymWatch Watch App
//
//  Created by Francesco Arieti on 21/01/25.
//

import SwiftUI
import WatchKit

@main
struct GymWatchSwiftUIApp: App {
    @WKApplicationDelegateAdaptor(GBAppDelegate.self) private var appDelegate
    private let workoutManager = WorkoutManager.shared
    
    var body: some Scene {
        WindowGroup {
            PagingView()
                .environmentObject(workoutManager)
                .environmentObject(appDelegate.workoutViewModel)
                .environmentObject(appDelegate.foodViewModel)
        }
    }
}
