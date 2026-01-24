//
//  SetEditSheet.swift
//  Runner
//
//  Created by Francesco Arieti on 05/01/26.
//

import SwiftUI

@available(watchOS 9, *)
struct SetEditSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var model: WorkoutViewModel
    
    @State private var weight: Double
    @State private var time: TimeInterval
    // Will be converted to Int at saving time
    @State private var reps: Double
    @State private var distance: Double
    
    init(model: WorkoutViewModel) {
        if let wt = model.set?.weight {
            _weight = State(initialValue: wt)
        } else {
            _weight = State(initialValue: 0)
        }
        if let t = model.set?.time {
            _time = State(initialValue: t)
        } else {
            _time = State(initialValue: 0)
        }
        if let r = model.set?.reps {
            _reps = State(initialValue: Double(r.magnitude))
        } else {
            _reps = State(initialValue: 0)
        }
        if let d = model.set?.distance {
            _distance = State(initialValue: d)
        } else {
            _distance = State(initialValue: 0)
        }
    }
    
    var body: some View {
        if model.set != nil {
            okBody
        } else {
            Text("There's no data for this set. Please add some data from your iPhone first.")
        }
    }
    
    var okBody: some View {
        let set = model.set!
        return VStack {
            Form {
                // Weight
                if set.parameters.hasWeight {
                    Stepper(
                        "Weight",
                        value: $weight,
                        in: 0...1000,
                        step: 0.1,
                        format: .number.precision(.fractionLength(2)),
                    )
                    .font(.body)
                }
                
                // Time
                if set.parameters.hasTime {
                    Stepper(
                        "Time",
                        value: $time,
                        in: 0...(60 * 10), // 10 minutes
                        step: 1,
                        format: TimeDurationFormatStyle(),
                    )
                    .font(.body)
                }
                
                // Reps
                if set.parameters.hasReps {
                    Stepper(
                        "Reps",
                        value: $reps,
                        in: 0...100,
                        step: 1,
                        format: .number,
                    )
                    .font(.body)
                }
                
                // Distance
                if set.parameters.hasDistance {
                    Stepper(
                        "Distance",
                        value: $distance,
                        in: 0...1000,
                        step: 0.05,
                        format: .number.precision(.fractionLength(2)),
                    )
                    .font(.body)
                }
            }
            .font(.system(size: 20, design: .rounded).monospacedDigit())
        }
//            .padding()
            .tint(model.exerciseColor.asARGBColor())
            .navigationBarTitle("Edit Set")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        model.updateSetParameters(weight: weight, time: time, reps: Int(reps), distance: distance)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
    }
}

struct TimeDurationFormatStyle: FormatStyle, ParseableFormatStyle {
    typealias FormatInput = Double
    typealias FormatOutput = String

    func format(_ value: Double) -> String {
        let totalSeconds = max(0, Int(value.rounded(.down)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var parseStrategy: TimeDurationParseStrategy {
        TimeDurationParseStrategy()
    }
}

struct TimeDurationParseStrategy: ParseStrategy {
    typealias ParseInput = String
    typealias ParseOutput = Double

    func parse(_ value: String) throws -> Double {
        let components = value.split(separator: ":")

        guard components.count == 2,
              let minutes = Int(components[0]),
              let seconds = Int(components[1]),
              (0..<60).contains(seconds)
        else {
            throw ParseError.invalidFormat
        }

        return Double(minutes * 60 + seconds)
    }

    enum ParseError: Error {
        case invalidFormat
    }
}
