//
//  StartRoutineIntent.swift
//  Runner
//
//  Created by Francesco Arieti on 06/07/2026.
//

import Foundation
import AppIntents
import flutter_app_intents // Ensure you import the plugin

enum AppIntentError: Error {
  case executionFailed(String)
}

struct StartRoutineIntent: AppIntent {
  static var title: LocalizedStringResource = "Start Gym Routine"
  static var persistentIdentifier: String = "start_routine"
  static var isDiscoverable = true
  static var openAppWhenRun = true  // Ensures app opens for navigation
  
  @Parameter(title: "Routine")
  var routine: RoutineEntity
  
  // AppIntents require an empty initializer
  init() {}
  
  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
    // Route the execution back to Dart via the plugin
    let plugin = FlutterAppIntentsPlugin.shared
    let result = await plugin.handleIntentInvocation(
      identifier: "start_routine",
      parameters: [
        "routineId": routine.id,
        "routineDisplayName": routine.name
      ]
    )
    if let success = result["success"] as? Bool, success {
      let value = result["value"] as? String ?? "Routine started"
      return .result(value: value)
    } else {
      let errorMessage = result["error"] as? String ?? "Failed to start routine"
      throw AppIntentError.executionFailed(errorMessage)
    }
  }
}
