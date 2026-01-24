//
//  NativeFoodCategory.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//


import Foundation

struct NativeFoodCategory: Codable {
    let name: String
    let emoji: String
    let nutritionSplit: NativeFoodNutritionSplit

    enum CodingKeys: String, CodingKey {
        case name
        case emoji
        case nutritionSplit
    }
}
