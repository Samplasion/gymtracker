import Foundation

@main
struct WatchFoodSyncTest {
    @MainActor
    static func main() throws {
        let suite = "GymBro.WatchFoodSyncTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let model = FoodViewModel(defaults: defaults)
        let split = NativeFoodNutritionSplit(protein: 25, proteinGoal: 100, carbs: 60, carbsGoal: 250, fats: 15, fatsGoal: 70)
        let state = NativeFoodStateMessage(calorieGoal: 2400, calorieIntake: 475,
            categories: [.init(name: "Pranzo", emoji: "🍴", nutritionSplit: split)], totalNutritionSplit: split)
        let payload = try state.toJSON()!
        let decoded = NativeFoodStateMessage.decodeFoodState(from: payload)!
        model.set(foodParameters: decoded)
        precondition(model.calorieIntake == 475 && model.calorieGoal == 2400)
        precondition(model.categories.first?.name == "Pranzo")
        precondition(model.totalNutritionSplit.protein == 25)
        let restored = FoodViewModel(defaults: defaults)
        precondition(restored.calorieIntake == 475 && restored.categories.count == 1)
        // A freshly received update must not be overwritten by deferred cache restore.
        restored.set(foodParameters: .init(calorieGoal: 2000, calorieIntake: 0, categories: [], totalNutritionSplit: split))
        precondition(FoodViewModel(defaults: defaults).calorieIntake == 0)
        model.set(foodParameters: state)
        defaults.set(Int64(Date().addingTimeInterval(-172800).timeIntervalSince1970 * 1000), forKey: "_foodParameters")
        let nextDay = FoodViewModel(defaults: defaults)
        precondition(nextDay.calorieIntake == 0 && nextDay.totalNutritionSplit.protein == 0)
        precondition(nextDay.categories.first?.nutritionSplit.protein == 0)
        precondition(nextDay.totalNutritionSplit.proteinGoal == 100)
        precondition(NativeFoodStateMessage.decodeFoodState(from: ["calorieGoal": "invalid"]) == nil)
        print("Watch food model: decode, apply, persist, restore and day reset passed")
    }
}
