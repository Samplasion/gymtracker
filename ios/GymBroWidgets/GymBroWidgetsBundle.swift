//
//  GymBroWidgetsBundle.swift
//  GymBroWidgets
//
//  Created by Francesco Arieti on 29/07/25.
//

import WidgetKit
import SwiftUI

@main
struct GymBroWidgetsBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 17.0, *) {
            GymBroWidgetsTotal()
            GymBroWidgetsStreak()
            GymBroWidgetsRest()
        }
        GymBroWidgetsLiveActivity()
    }
}
