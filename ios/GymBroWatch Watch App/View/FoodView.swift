import SwiftUI

struct FoodView: View {
    @EnvironmentObject var viewModel: FoodViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    if !viewModel.hasData {
                        Label("Open Gym Bro on iPhone to sync your diary.", systemImage: "iphone")
                            .font(.caption).foregroundStyle(.secondary).foodCard()
                    }
                    NavigationLink {
                        FoodGaugeView()
                    } label: {
                        FoodCalorieSummary(disclosure: true)
                    }.buttonStyle(.plain)
                    NavigationLink {
                        FoodNutritionView()
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            FoodCardHeading(title: "Nutrients", icon: "chart.bar.fill", color: .purple, disclosure: true)
                            NutritionSplit(protein: viewModel.totalNutritionSplit.protein,
                                proteinGoal: viewModel.totalNutritionSplit.proteinGoal,
                                carbs: viewModel.totalNutritionSplit.carbs,
                                carbsGoal: viewModel.totalNutritionSplit.carbsGoal,
                                fats: viewModel.totalNutritionSplit.fats,
                                fatsGoal: viewModel.totalNutritionSplit.fatsGoal)
                        }.foodCard(tint: .purple)
                    }.buttonStyle(.plain)
                    NavigationLink {
                        FoodWaterView()
                    } label: {
                        FoodWaterSummary(disclosure: true)
                    }.buttonStyle(.plain)
                    FoodPendingWater()
                    NavigationLink {
                        FoodDiaryView()
                    } label: {
                        FoodCardHeading(title: "Diary", icon: "fork.knife", color: .orange, disclosure: true)
                            .padding(.vertical, 4).foodCard(tint: .orange)
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, 8).padding(.bottom, 12)
            }
            .navigationTitle("Food")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            viewModel.refreshDisplayedData()
            viewModel.flushWaterEntries()
            while !Task.isCancelled {
                do { try await Task.sleep(nanoseconds: 30_000_000_000) }
                catch { return }
                viewModel.refreshDisplayedData()
                viewModel.flushWaterEntries()
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                viewModel.refreshDisplayedData()
                viewModel.flushWaterEntries()
            }
        }
    }
}

#Preview {
    FoodView().environmentObject(FoodViewModel())
}
