//
//  FoodViewModel.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import Foundation

fileprivate let key: String = "foodParameters"

@MainActor
class FoodViewModel: NSObject, ObservableObject {
    @Published var lastUpdated = Date.now
    @Published var calorieGoal: Double = 2000
    @Published var calorieIntake: Double = 0
    @Published var categories: [NativeFoodCategory] = []
    @Published var totalNutritionSplit: NativeFoodNutritionSplit = .init(protein: 0, proteinGoal: 1, carbs: 0, carbsGoal: 1, fats: 0, fatsGoal: 1)
    
    override init() {
        super.init()
        restoreSavedData()
    }
    
    var percentage: Double {
        Double(calorieIntake) / Double(calorieGoal)
    }
    
    func update() {
        lastUpdated = .now
        save()
    }
    
    func save() {
        guard let defaults = UserDefaults(suiteName: "group.samplasion.gymtracker") else {
            return
        }
        
        let foodParameters: NativeFoodStateMessage = .init(
            calorieGoal: calorieGoal,
            calorieIntake: calorieIntake,
            categories: categories,
            totalNutritionSplit: totalNutritionSplit
        )
        
        guard let jsonString = try? foodParameters.toJSONString() else {
            return
        }
        
        defaults.set(jsonString, forKey: key)
        defaults.set(lastUpdated.millisecondsSinceEpoch, forKey: "_\(key)")
    }
    
    func restoreSavedData() {
        guard let defaults = UserDefaults(suiteName: "group.samplasion.gymtracker") else {
            return
        }
        
        guard let jsonString = defaults.string(forKey: key),
              let foodParameters: NativeFoodStateMessage = NativeFoodStateMessage.decodeFoodState(fromString: jsonString) else {
            return
        }
        
        let newCalorieGoal = foodParameters.calorieGoal
        var newCalorieIntake = foodParameters.calorieIntake
        var newCategories: [NativeFoodCategory] = foodParameters.categories
        var newTotalNutritionSplit: NativeFoodNutritionSplit = foodParameters.totalNutritionSplit
        
        guard let lastUpdatedTimestamp = defaults.value(forKey: "_\(key)") as? Int else {
            return
        }
        
        lastUpdated = Date(timeIntervalSince1970: TimeInterval(lastUpdatedTimestamp) / 1000.0)
        
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastUpdated) {
            newCalorieIntake = 0
            newTotalNutritionSplit = .init(protein: 0, proteinGoal: newTotalNutritionSplit.proteinGoal, carbs: 0, carbsGoal: newTotalNutritionSplit.carbsGoal, fats: 0, fatsGoal: newTotalNutritionSplit.fatsGoal)
            newCategories = newCategories.map { category in
                .init(name: category.name, emoji: category.emoji, nutritionSplit: .init(protein: 0, proteinGoal: category.nutritionSplit.proteinGoal, carbs: 0, carbsGoal: category.nutritionSplit.carbsGoal, fats: 0, fatsGoal: category.nutritionSplit.fatsGoal))
            }
        }
        
        DispatchQueue.main.async {
            self.calorieGoal = newCalorieGoal
            self.calorieIntake = newCalorieIntake
            self.categories = newCategories
            self.totalNutritionSplit = newTotalNutritionSplit
            
            self.update()
        }
    }
}

extension FoodViewModel: FoodMessageDelegate {
    func set(foodParameters: NativeFoodStateMessage) {
//        DispatchQueue.main.async {
//            self.calorieGoal = foodParameters.calorieGoal
//            self.calorieIntake = foodParameters.calorieIntake
//            self.categories = foodParameters.categories
//            self.totalNutritionSplit = foodParameters.totalNutritionSplit
//            self.update()
//        }
    }
}
