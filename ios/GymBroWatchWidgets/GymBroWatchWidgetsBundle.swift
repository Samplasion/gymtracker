//
//  GymBroWatchWidgetsBundle.swift
//  GymBroWatchWidgets
//
//  Created by Francesco Arieti on 25/12/25.
//

import WidgetKit
import SwiftUI

@main
struct GymBroWatchWidgetsBundle: WidgetBundle {
  var body: some Widget {
    if #available(iOS 17, *) {
      GymBroWidgetsTotal()
      GymBroWidgetsStreak()
      GymBroWidgetsRest()
      GymBroWidgetsDensity()
      if #available(iOS 17.0, watchOS 10.0, *) {
        GymBroWidgetsWater()
        GymBroWidgetsNutrition()
      }
    }
  }
}
