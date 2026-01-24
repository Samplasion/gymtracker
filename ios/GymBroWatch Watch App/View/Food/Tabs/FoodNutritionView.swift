//
//  FoodNutritionView.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import SwiftUI

struct FoodNutritionView: View {
    @EnvironmentObject var viewModel: FoodViewModel
    
    var nutritionSplit: NativeFoodNutritionSplit {
        viewModel.totalNutritionSplit
    }
    
    var body: some View {
        ScrollView {
            NutritionSplit(protein: nutritionSplit.protein, proteinGoal: nutritionSplit.proteinGoal, carbs: nutritionSplit.carbs, carbsGoal: nutritionSplit.carbsGoal, fats: nutritionSplit.fats, fatsGoal: nutritionSplit.fatsGoal)
            .padding(.top)
            .navigationTitle(Text("Nutrition split"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
