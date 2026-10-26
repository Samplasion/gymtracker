import Foundation

/// The reference day belongs to the diary, never to the message delivery time.
enum DailyNutritionData {
    static let key = "foodParameters"
    static let appGroup = "group.samplasion.gymtracker"

    static func day(_ date: Date, calendar: Calendar = .autoupdatingCurrent) -> String {
        // The wire day is Gregorian; respect the device time zone even when
        // its preferred display calendar uses a different year numbering.
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let parts = gregorian.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
    }

    static func isCurrent(_ state: NativeFoodStateMessage, at date: Date, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        state.referenceDay == day(date, calendar: calendar)
    }

    static func example(at date: Date) -> NativeFoodStateMessage {
        .init(calorieGoal: 2200, calorieIntake: 1250, categories: [],
              totalNutritionSplit: .init(protein: 75, proteinGoal: 120, carbs: 150, carbsGoal: 260, fats: 35, fatsGoal: 70),
              referenceDay: day(date), generatedAt: Int64(date.timeIntervalSince1970 * 1000), waterIntake: 1250, waterGoal: 2000)
    }

    static func load(from defaults: UserDefaults?) -> NativeFoodStateMessage? {
        guard let json = defaults?.string(forKey: key) else { return nil }
        return NativeFoodStateMessage.decodeFoodState(fromString: json)
    }

    static func save(_ state: NativeFoodStateMessage, to defaults: UserDefaults?) {
        guard let json = try? state.toJSONString() else { return }
        defaults?.set(json, forKey: key)
    }

    static func valid(_ value: Double) -> Bool { value.isFinite && value >= 0 }

    static func resolved(_ state: NativeFoodStateMessage?, at date: Date, water: Bool,
                         calendar: Calendar = .autoupdatingCurrent) -> (state: NativeFoodStateMessage, isExample: Bool) {
        // A new day is a real zero-consumption day, not a demo. Keep the last
        // known goals until the app publishes today's totals.
        if let state, state.referenceDay != nil, !isCurrent(state, at: date, calendar: calendar) {
            let split = state.totalNutritionSplit
            let zero = NativeFoodStateMessage(
                calorieGoal: valid(state.calorieGoal) ? state.calorieGoal : 0,
                calorieIntake: 0, categories: [],
                totalNutritionSplit: .init(
                    protein: 0, proteinGoal: valid(split.proteinGoal) ? split.proteinGoal : 0,
                    carbs: 0, carbsGoal: valid(split.carbsGoal) ? split.carbsGoal : 0,
                    fats: 0, fatsGoal: valid(split.fatsGoal) ? split.fatsGoal : 0),
                referenceDay: day(date, calendar: calendar), generatedAt: state.generatedAt,
                waterIntake: 0, waterGoal: state.waterGoal.flatMap { valid($0) ? $0 : nil })
            return (zero, false)
        }
        if let state, isCurrent(state, at: date, calendar: calendar) {
            let split = state.totalNutritionSplit
            let values = water ? [state.waterIntake ?? -1] : [split.protein, split.carbs, split.fats, split.proteinGoal, split.carbsGoal, split.fatsGoal]
            if values.allSatisfy(valid), state.waterGoal.map(valid) ?? true { return (state, false) }
        }
        return (example(at: date), true)
    }

    static func progress(_ value: Double, goal: Double?) -> Double {
        guard valid(value), let goal, valid(goal), goal > 0 else { return 0 }
        return min(value / goal, 1)
    }
}
