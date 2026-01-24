//
//  FoodDiaryView.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import SwiftUI

struct FoodDiaryView: View {
    @EnvironmentObject var viewModel: FoodViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.categories, id: \.name) { category in
                NavigationLink {
                    ScrollView {
                        NutritionSplit(protein: category.nutritionSplit.protein, proteinGoal: category.nutritionSplit.proteinGoal, carbs: category.nutritionSplit.carbs, carbsGoal: category.nutritionSplit.carbsGoal, fats: category.nutritionSplit.fats, fatsGoal: category.nutritionSplit.fatsGoal)
                    }
                } label: {
                    Text("\(category.emoji) \(category.name)")
                }
            }
        }
        .navigationTitle(Text("Diary"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
