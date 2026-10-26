//
//  FoodViewModel.swift
//  Runner
//
//  Created by Francesco Arieti on 06/01/26.
//

import Foundation
import Combine
import WidgetKit

fileprivate let key: String = "foodParameters"

@MainActor
class FoodViewModel: NSObject, ObservableObject {
    private let defaults: UserDefaults?
    private let waterQueue: WatchWaterQueue
    var sendWaterEntry: ((WatchWaterEntry) -> Void)?
    @Published private(set) var pendingWaterEntries: [WatchWaterEntry] = []
    @Published private(set) var waterIntake: Double = 0
    @Published private(set) var waterGoal: Double?
    @Published private(set) var waterOwnerScope: String?
    @Published private(set) var hasData = false
    private var sourceState: NativeFoodStateMessage?
    @Published var lastUpdated = Date.now
    @Published var calorieGoal: Double = 0
    @Published var calorieIntake: Double = 0
    @Published var categories: [NativeFoodCategory] = []
    @Published var totalNutritionSplit: NativeFoodNutritionSplit = .init(protein: 0, proteinGoal: 0, carbs: 0, carbsGoal: 0, fats: 0, fatsGoal: 0)
    
    init(defaults: UserDefaults? = UserDefaults(suiteName: "group.samplasion.gymtracker")) {
        self.defaults = defaults
        waterQueue = WatchWaterQueue(defaults: defaults ?? .standard, key: "watch.water.pending.v1")
        super.init()
        pendingWaterEntries = waterQueue.entries
        restoreSavedData()
    }
    
    var percentage: Double {
        DailyNutritionData.progress(calorieIntake, goal: calorieGoal)
    }
    
    var pendingWaterAmount: Double {
        pendingWaterEntries.filter {
            $0.ownerScope == waterOwnerScope && DailyNutritionData.day($0.date) == DailyNutritionData.day(.now)
        }.reduce(0) { $0 + $1.milliliters }
    }
    var hasOtherAccountEntries: Bool {
        pendingWaterEntries.contains { $0.ownerScope != waterOwnerScope }
    }
    var currentPendingCount: Int {
        pendingWaterEntries.filter { $0.ownerScope == waterOwnerScope }.count
    }
    @discardableResult
    func addWater(_ milliliters: Double, at date: Date = .now) -> Bool {
        guard let scope = waterOwnerScope, milliliters.isFinite, milliliters > 0 else { return false }
        let entry = WatchWaterEntry(milliliters: milliliters,
            timeMilliseconds: Int64(date.timeIntervalSince1970 * 1000), ownerScope: scope)
        waterQueue.insert(entry)
        pendingWaterEntries = waterQueue.entries
        flushWaterEntries()
        return true
    }
    func flushWaterEntries() {
        for entry in pendingWaterEntries where entry.ownerScope == waterOwnerScope { sendWaterEntry?(entry) }
    }
    func acknowledgeWater(ids: Set<String>, ownerScope: String) {
        waterQueue.acknowledge(ids: ids, ownerScope: ownerScope)
        pendingWaterEntries = waterQueue.entries
    }
    func refreshDisplayedData(at date: Date = .now) {
        guard let state = sourceState else { return }
        let current = DailyNutritionData.isCurrent(state, at: date)
        hasData = state.referenceDay != nil
        calorieGoal = DailyNutritionData.valid(state.calorieGoal) ? state.calorieGoal : 0
        calorieIntake = current && DailyNutritionData.valid(state.calorieIntake) ? state.calorieIntake : 0
        waterIntake = current && DailyNutritionData.valid(state.waterIntake ?? -1) ? state.waterIntake! : 0
        waterGoal = state.waterGoal.flatMap { DailyNutritionData.valid($0) && $0 > 0 ? $0 : nil }
        waterOwnerScope = state.waterOwnerScope
        let s = state.totalNutritionSplit
        totalNutritionSplit = current ? s : .init(protein: 0, proteinGoal: s.proteinGoal,
            carbs: 0, carbsGoal: s.carbsGoal, fats: 0, fatsGoal: s.fatsGoal)
        categories = current ? state.categories : state.categories.map { category in
            let s = category.nutritionSplit
            return .init(name: category.name, emoji: category.emoji,
                nutritionSplit: .init(protein: 0, proteinGoal: s.proteinGoal,
                    carbs: 0, carbsGoal: s.carbsGoal, fats: 0, fatsGoal: s.fatsGoal))
        }
    }

    func update() {
        lastUpdated = .now
        save()
    }
    
    func save() {
        guard let defaults else {
            return
        }
        
        guard let foodParameters = sourceState else { return }

        guard let jsonString = try? foodParameters.toJSONString() else {
            return
        }
        
        defaults.set(jsonString, forKey: key)
        defaults.set(Int64(lastUpdated.timeIntervalSince1970 * 1000), forKey: "_\(key)")
        WidgetCenter.shared.reloadTimelines(ofKind: "GymBroWidgetsWater")
        WidgetCenter.shared.reloadTimelines(ofKind: "GymBroWidgetsNutrition")
    }
    
    func restoreSavedData() {
        guard let defaults else {
            return
        }
        
        guard let jsonString = defaults.string(forKey: key),
              let foodParameters: NativeFoodStateMessage = NativeFoodStateMessage.decodeFoodState(fromString: jsonString) else {
            return
        }
        
        set(foodParameters: foodParameters)
    }

}

extension FoodViewModel: FoodMessageDelegate {
    func set(foodParameters: NativeFoodStateMessage) {
        sourceState = foodParameters
        if let scope = foodParameters.waterOwnerScope, let ids = foodParameters.waterEntryIds {
            acknowledgeWater(ids: Set(ids), ownerScope: scope)
        }
        refreshDisplayedData()
        update()
        flushWaterEntries()
    }
}
