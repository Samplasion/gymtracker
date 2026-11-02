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
            Group {
                #if DEBUG
                if ScreenshotMode.enabled && ScreenshotMode.argument("--screenshot-scene") != nil {
                    ScreenshotSceneView()
                } else { PagingView() }
                #else
                PagingView()
                #endif
            }
                .environmentObject(workoutManager)
                .environmentObject(appDelegate.workoutViewModel)
                .environmentObject(appDelegate.foodViewModel)
        }
    }
}

// Available only in debug builds used by the screenshot lane.
enum ScreenshotMode {
    static func argument(_ name: String) -> String? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard enabled, let index = args.firstIndex(of: name), index+1 < args.count else { return nil }
        return args[index+1]
        #else
        return nil
        #endif
    }
    static var now: Date {
        #if DEBUG
        if enabled {
            let value = argument("--screenshot-reference") ?? "2026-11-01T09:41:00"
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: value) { return date }
        }
        #endif
        return .now
    }

    static var enabled: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("--screenshots")
        #else
        return false
        #endif
    }
}

#if DEBUG
/// Uses real views and received companion data; never compiled into Release.
private struct ScreenshotSceneView: View {
    @EnvironmentObject var workout: WorkoutViewModel
    @EnvironmentObject var food: FoodViewModel
    @State private var ready = false
    private let training = TrainingViewModel.shared
    private var scene: String { ScreenshotMode.argument("--screenshot-scene") ?? "workout" }
    private var run: String { ScreenshotMode.argument("--screenshot-run") ?? "" }

    var body: some View {
        Group {
            if ready {
                switch scene {
                case "workout": PagingView()
                case "routines": NavigationStack { TrainingHomeView() }
                case "edit-set": NavigationStack { SetEditSheet(model: workout, compactTitle: true) }
                case "notes": WorkoutNotesView(title: "Exercise notes", context: workout.exerciseName,
                    notes: workout.exerciseNotes, tint: workout.exerciseColor.asARGBColor())
                case "calories": NavigationStack { FoodGaugeView() }
                case "nutrients": NavigationStack { FoodNutritionView(compact: true) }
                case "water": NavigationStack { FoodWaterView() }
                default: Text("Unknown screenshot scene")
                }
            } else { ProgressView() }
        }
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.large)
        .task {
            food.clock = { ScreenshotMode.now }
            while !Task.isCancelled {
                food.refreshDisplayedData()
                let owner = "screenshot-\(run)"
                if workout.workoutID == owner, workout.set != nil,
                   !workout.exerciseNotes.isEmpty, training.owner == owner,
                   (training.catalog?["routines"] as? [Any])?.count == 3,
                   (training.catalog?["folders"] as? [Any])?.count == 2,
                   food.calorieIntake == 1141, food.waterIntake == 1250,
                   food.waterOwnerScope == owner {
                    ready = true
                    do {
                        try await Task.sleep(nanoseconds: 1_500_000_000)
                        let receipt: [String: String] = ["run": run, "scene": scene, "locale": Locale.current.identifier]
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            .appendingPathComponent("screenshot-ready.json")
                        try JSONSerialization.data(withJSONObject: receipt).write(to: url, options: .atomic)
                    } catch { }
                    return
                }
                do { try await Task.sleep(nanoseconds: 250_000_000) } catch { return }
            }
        }
    }
}
#endif
