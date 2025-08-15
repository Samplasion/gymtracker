//
//  TimerView.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 14/08/25.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var showTimer: Bool = false
    @State var timeDelta: TimeInterval = 0
    
    var timerEndDate: Date {
        didSet {
            timerLogic()
        }
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private func timerLogic() {
        timeDelta = timerEndDate.timeIntervalSinceNow.rounded(.toNearestOrAwayFromZero)
        showTimer = timeDelta > 0
    }
    
    var body: some View {
        VStack {
            if !showTimer {
                Text(" ")
                    .foregroundStyle(.tint)
            } else {
                _TimerViewInner(text: convertTimeInterval(timeDelta))
            }
        }
        .onReceive(timer) { _ in
            timerLogic()
        }
    }
}

private struct _TimerViewInner: View {
    var text: String
    
    var body: some View {
        Label {
            if #available(watchOS 9.0, *) {
                Text(verbatim: text)
                    .contentTransition(.numericText(countsDown: true))
            } else {
                Text(verbatim: text)
            }
        } icon: {
            Image(systemName: "timer")
        }
        .foregroundStyle(.tint)
    }
}

#Preview {
    TimerView(timerEndDate: .init(timeIntervalSinceNow: 10))
}

func convertTimeInterval(_ interval: TimeInterval) -> String {
    let hours = (interval / 3600).rounded(.down);
    let minutes = (interval / 60).truncatingRemainder(dividingBy: 60).rounded(.down);
    let seconds = interval.truncatingRemainder(dividingBy: 60).rounded(.down);
    
    let minutesString = String(format: "%02d", Int(minutes))
    let secondsString = String(format: "%02d", Int(seconds))
    
    if (hours > 0) {
        return "\(Int(hours))h, \(minutesString):\(secondsString)"
    } else {
        return "\(minutesString):\(secondsString)"
    }
}
