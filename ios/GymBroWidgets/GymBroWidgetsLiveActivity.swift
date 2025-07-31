//
//  GymBroWidgetsLiveActivity.swift
//  GymBroWidgets
//
//  Created by Francesco Arieti on 29/07/25.
//

import ActivityKit
import WidgetKit
import SwiftUI
import ContrastKit

struct GymBroWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var hasExercise: Bool
        var exerciseName: String?
        var exerciseColor: Int64?
        var exerciseParameters: String?
        var restTimeStart: Date?
        var restTimeEnd: Date?
        var start: Date
        var percentageDone: Double
        
        var hasRest: Bool {
            get {
                return restTimeStart != nil && restTimeEnd != nil
            }
        }
    }
}

extension Int64 {
    func toColor() -> Color {
        let blue = Double(self & 0xFF) / 255.0
        let green = Double((self >> 8) & 0xFF) / 255.0
        let red = Double((self >> 16) & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
}

struct GymBroWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GymBroWidgetsAttributes.self) { context in
            var primaryColor = Color.primary
            var boldPrimaryColor = Color.primary
            
            if let baseColor = context.state.exerciseColor?.toColor() {
                primaryColor = baseColor.level(.level700)
                boldPrimaryColor = baseColor.level(.level600)
            }
            
            let padding = 16.0
            
            return VStack(alignment: .leading) {
                if (!context.state.hasExercise) {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                        Spacer()
                    }
                } else {
                    Text("\(context.state.exerciseName!)")
                        .font(.headline)
                    Text("\(context.state.exerciseParameters!)")
                }
                Label {
                    TimerView(
                        context: context,
                        multilineTextAlignment: .leading
                    )
                } icon: {
                    Image(systemName: "clock")
                }
                    .font(.body)
                    .foregroundStyle(primaryColor)
                if (context.state.hasRest && context.state.restTimeEnd! > Date.now) {
                    Label {
                        Text(
                            context.state.restTimeEnd!,
                            style: .timer
                        )
                            .monospacedDigit()
                    } icon: {
                        Image(systemName: "timer")
                    }
                    .foregroundStyle(boldPrimaryColor)
                }
            }
                .padding(EdgeInsets(
                    top: padding,
                    leading: padding,
                    bottom: padding,
                    trailing: padding
                ))
                .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            var primaryColor = Color.primary
            var boldPrimaryColor = Color.primary
            
            if let baseColor = context.state.exerciseColor?.toColor() {
                primaryColor = baseColor.level(.level700, scheme: .dark)
                boldPrimaryColor = baseColor.level(.level600, scheme: .dark)
            }
            
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    if (context.state.hasRest) {
                        Label {
                            Text(
                                context.state.restTimeEnd!,
                                style: .timer
                            )
                            .frame(width: 75)
                            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                        } icon: {
                            Image(systemName: "timer")
                        }
                        .foregroundStyle(boldPrimaryColor)
                    }
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Label {
                        TimerView(context: context)
                            .frame(width: 75)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
                    } icon: {
                        Image(systemName: "clock")
                    }
                        .font(.body)
                        .foregroundStyle(primaryColor)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        if (!context.state.hasExercise) {
                            Image(systemName: "checkmark.circle")
                        } else {
                            Text("\(context.state.exerciseName!)")
                                .font(.headline)
                            Text("\(context.state.exerciseParameters!)")
                                .font(.caption)
                        }
                        
                        if (context.state.hasExercise) {
                            ProgressView(
                                value: context.state.percentageDone
                            )
                            .padding(EdgeInsets(
                                top: 0,
                                leading: 24,
                                bottom: 0,
                                trailing: 24
                            ))
                        }
                    }
                }
            } compactLeading: {
                if let countFrom = context.state.restTimeStart {
                    if let endDate = context.state.restTimeEnd {
                        if (endDate <= Date()) {
                            ExerciseInitials(context: context)
                        } else {
                            ProgressView(
                                timerInterval: countFrom...endDate,
                                countsDown: true,
                                label: { EmptyView() },
                                currentValueLabel: { ExerciseInitials(context: context)
                                }
                            )
                                .padding(EdgeInsets(
                                    top: 0,
                                    leading: 0,
                                    bottom: 0,
                                    trailing: context.state.hasExercise ? 7 : 0
                                ))
                                .frame(width: 30)
                                .progressViewStyle(.circular)
                        }
                    } else {
                        ExerciseInitials(context: context)
                            .frame(width: 30)
                    }
                } else {
                    ExerciseInitials(context: context)
                        .frame(width: 30)
                }
            } compactTrailing: {
                if context.state.hasExercise {
                    TimerView(context: context)
                        .font(.caption2)
                        .foregroundStyle(primaryColor)
                        .scaleEffect(0.85, anchor: .leading)
                        .frame(maxWidth: 50)
                } else {
                    TimerView(context: context)
                        .font(.caption2)
                        .scaleEffect(0.85, anchor: .leading)
                        .frame(maxWidth: 50)
                }
            } minimal: {
                HStack(alignment: .center) {
                    ProgressView(
                        value: context.state.percentageDone,
                        label: { Text("\(context.state.percentageDone, format: .percent)") },
                        currentValueLabel: {
                            if context.state.hasExercise {
                                ExerciseInitials(context: context)
                            } else {
                                Image(systemName: "checkmark")
                            }
                        }
                    )
                        .progressViewStyle(.circular)
                        .frame(width: 40)
                        .padding(EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 0,
                            trailing: context.state.hasExercise ? 7 : 0
                        ))
                }
            }
            .keylineTint(primaryColor)
        }
    }
}

struct TimerView: View {
    let context: ActivityViewContext<GymBroWidgetsAttributes>
    var short: Bool = false
    var multilineTextAlignment: TextAlignment = .trailing
    
    var body: some View {
        let delta = Date().timeIntervalSince(context.state.start)
        var text = Text(
            context.state.start,
            style: .timer
        )
        if (short && delta > 3600) {
            text = Text("\(Int(delta / 3600))h")
        }
        return text
            .contentTransition(.numericText())
            .multilineTextAlignment(multilineTextAlignment)
            .monospacedDigit()
    }
}

struct ExerciseInitials: View {
    let context: ActivityViewContext<GymBroWidgetsAttributes>
    
    var body: some View {
        if context.state.hasExercise {
            Text(context.state.exerciseName!.initials())
                .fontWeight(.semibold)
                .monospaced()
                .frame(width: 30)
        } else {
            Image(systemName: "checkmark.circle")
        }
    }
}

extension String {
    func initials() -> String {
        return String(self
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .compactMap { $0.first }
            .map { String($0).uppercased() }
            .filter { !"().".contains($0) }
            .joined()
            .prefix(2))
    }
}

fileprivate struct ContentStates {
    static let long = GymBroWidgetsAttributes.ContentState(
        hasExercise: true,
        exerciseName: "Exercise Name",
        exerciseColor: 0xFFC44040,
        exerciseParameters: "Params",
        restTimeStart: Date(),
        restTimeEnd: Date(timeIntervalSinceNow: 60),
        start: Date(timeIntervalSinceNow: -3600 * 1.5),
        percentageDone: 0.66
    )
    static let notResting = GymBroWidgetsAttributes.ContentState(
        hasExercise: true,
        exerciseName: "Exercise Name",
        exerciseColor: 0xFF40C440,
        exerciseParameters: "Params",
        restTimeStart: nil,
        restTimeEnd: nil,
        start: Date(timeIntervalSinceNow: -3600 * 1.5),
        percentageDone: 1
    )
    static let done = GymBroWidgetsAttributes.ContentState(
        hasExercise: false,
        exerciseName: "Exercise Name",
        exerciseColor: 0xFFC44040,
        exerciseParameters: "Params",
        restTimeStart: nil,
        restTimeEnd: nil,
        start: Date(timeIntervalSinceNow: -3600 * 1.5),
        percentageDone: 1
    )
}

@available(iOS 17, *)
#Preview("Live Activity", as: .content, using: GymBroWidgetsAttributes()) {
    GymBroWidgetsLiveActivity()
} contentStates: {
    ContentStates.long
    ContentStates.notResting
    ContentStates.done
}

@available(iOS 17, *)
#Preview("Expanded", as: .dynamicIsland(.expanded), using: GymBroWidgetsAttributes()) {
    GymBroWidgetsLiveActivity()
} contentStates: {
    ContentStates.long
    ContentStates.notResting
    ContentStates.done
}

@available(iOS 17, *)
#Preview("Compact", as: .dynamicIsland(.compact), using: GymBroWidgetsAttributes()) {
    GymBroWidgetsLiveActivity()
} contentStates: {
    ContentStates.long
    ContentStates.notResting
    ContentStates.done
}

@available(iOS 17, *)
#Preview("Minimal", as: .dynamicIsland(.minimal), using: GymBroWidgetsAttributes()) {
    GymBroWidgetsLiveActivity()
} contentStates: {
    ContentStates.long
    ContentStates.notResting
    ContentStates.done
}
