import SwiftUI

struct NutritionSplit: View {
    var protein: Double
    var proteinGoal: Double
    var carbs: Double
    var carbsGoal: Double
    var fats: Double
    var fatsGoal: Double

    var compact = false

    var body: some View {
        VStack(spacing: compact ? 4 : 14) {
            nutrient("Protein", value: protein, goal: proteinGoal, color: .purple)
            nutrient("Carbs", value: carbs, goal: carbsGoal, color: .orange)
            nutrient("Fats", value: fats, goal: fatsGoal, color: .pink)
        }
    }

    private func nutrient(_ name: LocalizedStringKey, value: Double, goal: Double, color: Color) -> some View {
        let intake = DailyNutritionData.valid(value) ? value : 0
        let hasGoal = DailyNutritionData.valid(goal) && goal > 0
        return VStack(alignment: .leading, spacing: compact ? 2 : 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(name).foregroundStyle(color).font(.caption.weight(.semibold))
                Spacer(minLength: 4)
                Text(intake.formatted(.number.precision(.fractionLength(0))) + " g")
                    .font(.footnote.weight(.semibold)).monospacedDigit()
            }
            if hasGoal {
                ProgressView(value: DailyNutritionData.progress(intake, goal: goal)).tint(color)
                HStack {
                    Text("Goal")
                    Spacer()
                    Text(goal.formatted(.number.precision(.fractionLength(0))) + " g")
                }.font(.caption2).foregroundStyle(.secondary)
            } else {
                Text("No goal set").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NutritionSplit(protein: 50, proteinGoal: 70, carbs: 80, carbsGoal: 130, fats: 15, fatsGoal: 45)
}
