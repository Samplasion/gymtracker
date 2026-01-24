//
//  NativeFoodNutritionSplit.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import Foundation

struct NativeFoodNutritionSplit: Codable {
    let protein: Double
    let proteinGoal: Double
    let carbs: Double
    let carbsGoal: Double
    let fats: Double
    let fatsGoal: Double

    enum CodingKeys: String, CodingKey {
        case protein
        case proteinGoal
        case carbs
        case carbsGoal
        case fats
        case fatsGoal
    }
}
