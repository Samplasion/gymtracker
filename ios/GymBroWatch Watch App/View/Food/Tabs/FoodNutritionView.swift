import SwiftUI

struct FoodNutritionView: View {
    @EnvironmentObject var viewModel: FoodViewModel

    var compact = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if !compact { FoodCardHeading(title: "Today", icon: "chart.bar.fill", color: .purple) }
                NutritionSplit(protein: viewModel.totalNutritionSplit.protein,
                    proteinGoal: viewModel.totalNutritionSplit.proteinGoal,
                    carbs: viewModel.totalNutritionSplit.carbs,
                    carbsGoal: viewModel.totalNutritionSplit.carbsGoal,
                    fats: viewModel.totalNutritionSplit.fats,
                    fatsGoal: viewModel.totalNutritionSplit.fatsGoal, compact: compact)
            }.foodCard(tint: .purple, padding: compact ? 6 : 12).padding(.horizontal, 8).padding(.bottom, 12)
        }
        .navigationTitle("Nutrients")
        .navigationBarTitleDisplayMode(.inline)
    }
}
