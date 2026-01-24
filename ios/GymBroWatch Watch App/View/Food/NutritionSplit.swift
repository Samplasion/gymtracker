//
//  NutritionSplit.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 06/01/26.
//

import SwiftUI

struct NutritionSplit: View {
    var protein: Double
    var proteinGoal: Double
    var carbs: Double
    var carbsGoal: Double
    var fats: Double
    var fatsGoal: Double
    
    func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)).rounded()) + "g"
    }
    
    var body: some View {
        VStack {
            Gauge(value: protein / proteinGoal, label: {
                Text("Protein")
            }, currentValueLabel: {
                Text("\(format(protein))/\(format(proteinGoal))")
            })
            Gauge(value: carbs / carbsGoal, label: {
                Text("Carbs")
            }, currentValueLabel: {
                Text("\(format(carbs))/\(format(carbsGoal))")
            })
            Gauge(value: fats / fatsGoal, label: {
                Text("Fats")
            }, currentValueLabel: {
                Text("\(format(fats))/\(format(fatsGoal))")
            })
        }
        .modifier(GaugeStyleModifier())
        .tint(.accent)
    }
}

fileprivate struct GaugeStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(watchOS 9, *) {
            return content.gaugeStyle(.linearCapacity)
        } else {
            return content.gaugeStyle(.linear)
        }
    }
}

#Preview {
    NutritionSplit(protein: 50, proteinGoal: 70, carbs: 80, carbsGoal: 130, fats: 15, fatsGoal: 45)
}
