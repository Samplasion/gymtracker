import SwiftUI

struct FoodNutritionView: View {
    @EnvironmentObject var viewModel: FoodViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                FoodCardHeading(title: "Today", icon: "chart.bar.fill", color: .purple)
                NutritionSplit(protein: viewModel.totalNutritionSplit.protein,
                    proteinGoal: viewModel.totalNutritionSplit.proteinGoal,
                    carbs: viewModel.totalNutritionSplit.carbs,
                    carbsGoal: viewModel.totalNutritionSplit.carbsGoal,
                    fats: viewModel.totalNutritionSplit.fats,
                    fatsGoal: viewModel.totalNutritionSplit.fatsGoal)
            }.foodCard(tint: .purple).padding(.horizontal, 8).padding(.bottom, 12)
        }
        .navigationTitle("Nutrients")
        .navigationBarTitleDisplayMode(.inline)
    }
}
