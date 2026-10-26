import SwiftUI

struct FoodCalorieSummary: View {
    @EnvironmentObject var viewModel: FoodViewModel
    var disclosure = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            FoodCardHeading(title: "Calories", icon: "flame.fill", color: .orange, disclosure: disclosure)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(viewModel.calorieIntake, format: .number.precision(.fractionLength(0)))
                    .font(.system(.title, design: .rounded).weight(.bold)).monospacedDigit()
                    .minimumScaleFactor(0.6).lineLimit(1)
                Text("kcal").font(.caption).foregroundStyle(.secondary)
            }
            if viewModel.calorieGoal > 0 {
                ProgressView(value: viewModel.percentage).tint(.orange)
                HStack {
                    Text(viewModel.calorieIntake > viewModel.calorieGoal ? LocalizedStringKey("Over goal") : LocalizedStringKey("Remaining"))
                    Spacer(minLength: 2)
                    Text(abs(viewModel.calorieGoal - viewModel.calorieIntake), format: .number.precision(.fractionLength(0)))
                        .monospacedDigit()
                }.font(.caption2).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.75)
                HStack {
                    Text("Goal")
                    Spacer(minLength: 2)
                    Text(viewModel.calorieGoal.formatted(.number.precision(.fractionLength(0))) + " kcal")
                }.font(.caption2).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.75)
            } else {
                Text("No calorie goal").font(.caption2).foregroundStyle(.secondary)
            }
        }.foodCard(tint: .orange)
        .accessibilityElement(children: .combine)
    }
}

struct FoodGaugeView: View {
    var body: some View {
        ScrollView {
            FoodCalorieSummary().padding(.horizontal, 8).padding(.bottom, 12)
        }
        .navigationTitle("Calories")
        .navigationBarTitleDisplayMode(.inline)
    }
}
