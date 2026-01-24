//
//  FoodGaugeView.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import SwiftUI

struct FoodGaugeView: View {
    @EnvironmentObject var viewModel: FoodViewModel
    
    var body: some View {
        GeometryReader { geo in
            Centering {
                Gauge(value: viewModel.percentage, label: {
                    Text("Calories")
                }, currentValueLabel: {
                    VStack {
                        Text("Eaten")
                            .font(.caption)
                        Text("\(viewModel.calorieIntake.formatted(.number.precision(.fractionLength(0)).rounded(rule: .toNearestOrAwayFromZero)))")
                            .font(.system(size: 20, weight: .bold).monospacedDigit())
                        
                        Text("Remaining")
                        Text("\(viewModel.calorieGoal.distance(to: viewModel.calorieIntake).magnitude.formatted(.number.precision(.fractionLength(0)).rounded(rule:.toNearestOrAwayFromZero)))")
                            .font(.system(size: 20, weight: .bold).monospacedDigit())
                            .foregroundStyle(.tint)
                    }
                })
                .gaugeStyle(FVGaugeStyle())
                .frame(width: geo.size.width - 25, height: geo.size.width - 25)
                .animation(.spring, value: viewModel.calorieIntake)
            }
            .padding()
            .navigationTitle(Text("Food"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct Centering<Content>: View where Content : View {
    var content: () -> Content
    
    var body: some View {
        HStack {
            Spacer()
            self.content()
            Spacer()
        }
    }
}

fileprivate struct FVGaugeStyle: GaugeStyle {
    func makeBody(configuration: Configuration) -> some View {
        let cfgValue = max(configuration.value, 0.0001)
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(.tint.opacity(0.5), style: StrokeStyle(
                    lineWidth: 5,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(135))
            
            Circle()
                .trim(from: 0, to: 0.75 * cfgValue)
                .stroke(.tint, style: StrokeStyle(
                    lineWidth: 15,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(135))

            configuration.currentValueLabel
        }
    }
}
