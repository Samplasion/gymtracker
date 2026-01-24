//
//  ElapsedTimeView.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 26/12/25.
//

import SwiftUI

struct ElapsedTimeView: View {
    var elapsedTime: TimeInterval = 0
    var showSubseconds = true
    @State private var timeFormatter = ElapsedTimeFormatter()
    
    init(elapsedTime: TimeInterval, showSubseconds: Bool = true) {
        self.elapsedTime = elapsedTime
        self.showSubseconds = showSubseconds
        self.timeFormatter = ElapsedTimeFormatter()
        timeFormatter.showSubseconds = showSubseconds
    }

    var body: some View {
        if elapsedTime < 0 {
            Text(" ")
        } else if #available(watchOS 10.0, *) {
            Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
                .fontWeight(.semibold)
                .onChange(of: showSubseconds) { (oldValue, newValue) in
                    timeFormatter.showSubseconds = newValue
                }
        } else {
            Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
                .fontWeight(.semibold)
        }
    }
}

class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var showSubseconds = true

    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        if showSubseconds {
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
        }

        return formattedString
    }
}
