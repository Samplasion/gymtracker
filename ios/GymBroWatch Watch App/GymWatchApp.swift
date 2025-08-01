//
//  GymWatchApp.swift
//  GymWatch Watch App
//
//  Created by Francesco Arieti on 21/01/25.
//

import SwiftUI

@main
struct GymWatchSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: WorkoutViewModel())
        }
    }
}
