import SwiftUI

struct FoodDiaryView: View {
    @EnvironmentObject var viewModel: FoodViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if viewModel.categories.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "fork.knife.circle").font(.largeTitle).foregroundStyle(.orange)
                        Text("No meals yet").font(.headline)
                        Text("Your meals will appear after syncing with iPhone.")
                            .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity).foodCard(tint: .orange)
                }
                ForEach(viewModel.categories, id: \.name) { category in
                    NavigationLink {
                        ScrollView {
                            NutritionSplit(protein: category.nutritionSplit.protein,
                                proteinGoal: category.nutritionSplit.proteinGoal,
                                carbs: category.nutritionSplit.carbs,
                                carbsGoal: category.nutritionSplit.carbsGoal,
                                fats: category.nutritionSplit.fats,
                                fatsGoal: category.nutritionSplit.fatsGoal)
                                .foodCard(tint: .orange).padding(.horizontal, 8).padding(.bottom, 12)
                        }.navigationTitle(category.name).navigationBarTitleDisplayMode(.inline)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Text(category.emoji).font(.title3)
                                Text(category.name).font(.headline)
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.secondary)
                                    .accessibilityHidden(true)
                            }
                            VStack(spacing: 4) {
                                macro("Protein", amount: category.nutritionSplit.protein, color: .purple)
                                macro("Carbs", amount: category.nutritionSplit.carbs, color: .orange)
                                macro("Fats", amount: category.nutritionSplit.fats, color: .pink)
                            }
                        }.foodCard(tint: .orange)
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 8).padding(.bottom, 12)
        }
        .navigationTitle("Diary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func macro(_ title: LocalizedStringKey, amount: Double, color: Color) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.caption2).foregroundStyle(color)
            Spacer(minLength: 4)
            Text((DailyNutritionData.valid(amount) ? amount : 0).formatted(.number.precision(.fractionLength(0))) + " g")
                .font(.caption.weight(.semibold)).monospacedDigit()
        }.frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
