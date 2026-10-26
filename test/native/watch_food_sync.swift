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
            categories: [.init(name: "Pranzo", emoji: "🍴", nutritionSplit: split)], totalNutritionSplit: split, referenceDay: DailyNutritionData.day(.now), waterIntake: 1000, waterGoal: 2000)
        let payload = try state.toJSON()!
        let decoded = NativeFoodStateMessage.decodeFoodState(from: payload)!
        model.set(foodParameters: decoded)
        precondition(model.calorieIntake == 475 && model.calorieGoal == 2400)
        precondition(model.categories.first?.name == "Pranzo")
        precondition(model.totalNutritionSplit.protein == 25)
        let restored = FoodViewModel(defaults: defaults)
        precondition(restored.calorieIntake == 475 && restored.categories.count == 1)
        // A freshly received update must not be overwritten by deferred cache restore.
        restored.set(foodParameters: .init(calorieGoal: 2000, calorieIntake: 0, categories: [], totalNutritionSplit: split, referenceDay: DailyNutritionData.day(.now), waterIntake: 1000, waterGoal: 2000))
        precondition(FoodViewModel(defaults: defaults).calorieIntake == 0)
        model.set(foodParameters: state)
        let yesterday = NativeFoodStateMessage(calorieGoal: 2400, calorieIntake: 475, categories: state.categories,
            totalNutritionSplit: split, referenceDay: DailyNutritionData.day(Date().addingTimeInterval(-172800)), generatedAt: 123,
            waterIntake: 1500, waterGoal: 2000)
        model.set(foodParameters: yesterday)
        precondition(model.calorieIntake == 0) // late delivery cannot become today's consumption
        precondition(DailyNutritionData.load(from: defaults)?.referenceDay == yesterday.referenceDay)
        precondition(DailyNutritionData.load(from: defaults)?.generatedAt == 123)
        let nextDay = FoodViewModel(defaults: defaults)
        precondition(DailyNutritionData.load(from: defaults)?.waterIntake == 1500)
        precondition(nextDay.calorieIntake == 0 && nextDay.totalNutritionSplit.protein == 0)
        precondition(nextDay.categories.first?.nutritionSplit.protein == 0)
        precondition(nextDay.totalNutritionSplit.proteinGoal == 100)
        precondition(NativeFoodStateMessage.decodeFoodState(from: ["calorieGoal": "invalid"]) == nil)
        let scope = "user:original"
        let synced = NativeFoodStateMessage(calorieGoal: 2000, calorieIntake: 2100,
            categories: [], totalNutritionSplit: split, referenceDay: DailyNutritionData.day(.now),
            waterIntake: 1200, waterGoal: 2000, waterOwnerScope: scope, waterEntryIds: [])
        model.set(foodParameters: synced)
        precondition(model.waterIntake == 1200 && model.waterGoal == 2000)
        precondition(model.percentage == 1) // overflowing progress stays drawable
        var sent: [WatchWaterEntry] = []
        model.sendWaterEntry = { sent.append($0) }
        precondition(model.addWater(250))
        precondition(model.waterIntake == 1200 && model.pendingWaterAmount == 250)
        precondition(sent.count == 1)
        let entry = sent[0]
        precondition(WatchWaterEntry(message: entry.message) == entry)
        let offlineRestart = FoodViewModel(defaults: defaults)
        precondition(offlineRestart.pendingWaterAmount == 250 && offlineRestart.pendingWaterEntries == [entry])
        precondition(!offlineRestart.addWater(.nan) && !offlineRestart.addWater(-50))
        offlineRestart.acknowledgeWater(ids: [entry.id], ownerScope: "user:other")
        precondition(offlineRestart.pendingWaterEntries.count == 1)
        offlineRestart.set(foodParameters: .init(calorieGoal: 0, calorieIntake: 50, categories: [],
            totalNutritionSplit: split, referenceDay: DailyNutritionData.day(.now), waterIntake: 0,
            waterOwnerScope: "user:other", waterEntryIds: [entry.id]))
        precondition(offlineRestart.hasOtherAccountEntries && offlineRestart.pendingWaterAmount == 0)
        precondition(offlineRestart.percentage == 0 && offlineRestart.waterGoal == nil)
        offlineRestart.set(foodParameters: synced)
        offlineRestart.refreshDisplayedData(at: .now.addingTimeInterval(172800))
        precondition(offlineRestart.waterIntake == 0 && offlineRestart.calorieIntake == 0 && offlineRestart.waterGoal == 2000)
        offlineRestart.acknowledgeWater(ids: [entry.id], ownerScope: scope)
        precondition(FoodViewModel(defaults: defaults).pendingWaterEntries.isEmpty)
        // A snapshot can reconcile today's entries even if the explicit receipt was lost.
        model.set(foodParameters: .init(calorieGoal: 2000, calorieIntake: 0, categories: [],
            totalNutritionSplit: split, referenceDay: DailyNutritionData.day(.now), waterIntake: 1450,
            waterGoal: 2000, waterOwnerScope: scope, waterEntryIds: [entry.id]))
        precondition(model.pendingWaterEntries.isEmpty && model.waterIntake == 1450)
        let queue = WatchWaterQueue(defaults: defaults, key: "test.phoneInbox")
        queue.insert(entry)
        queue.insert(entry)
        precondition(WatchWaterQueue(defaults: defaults, key: "test.phoneInbox").entries == [entry])
        queue.acknowledge(ids: [entry.id], ownerScope: scope)
        precondition(WatchWaterQueue(defaults: defaults, key: "test.phoneInbox").entries.isEmpty)
        let initial = FoodViewModel(defaults: UserDefaults(suiteName: suite + ".empty"))
        precondition(!initial.addWater(100) && !initial.hasData)
        print("Watch food model: decode, apply, persist, restore and day reset passed")
    }
}
