import Foundation

@main
struct DailyNutritionDataTest {
    static func main() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        let now = ISO8601DateFormatter().date(from: "2026-10-25T12:00:00Z")!
        func state(day: String? = "2026-10-25", water: Double? = 0, goal: Double? = nil) -> NativeFoodStateMessage {
            .init(calorieGoal: 2000, calorieIntake: 0, categories: [],
                  totalNutritionSplit: .init(protein: 0, proteinGoal: 0, carbs: 0, carbsGoal: 250, fats: 0, fatsGoal: 70),
                  referenceDay: day, generatedAt: 1792929600000, waterIntake: water, waterGoal: goal)
        }
        func resolved(_ source: NativeFoodStateMessage?, water: Bool = true, date: Date? = nil) -> (state: NativeFoodStateMessage, isExample: Bool) {
            DailyNutritionData.resolved(source, at: date ?? now, water: water, calendar: calendar)
        }
        precondition(resolved(nil).isExample)
        precondition(resolved(state(day: nil)).isExample)
        precondition(!resolved(state(day: "2026-10-24")).isExample)
        precondition(!resolved(state(day: "2026-10-26")).isExample)
        precondition(resolved(state(water: nil)).isExample)
        precondition(resolved(state(water: -.infinity)).isExample)
        precondition(!resolved(state()).isExample)
        precondition(resolved(state()).state.waterIntake == 0)
        precondition(!resolved(state(), water: false).isExample)
        precondition(DailyNutritionData.progress(2500, goal: 2000) == 1)
        precondition(DailyNutritionData.progress(100, goal: nil) == 0)
        precondition(DailyNutritionData.progress(100, goal: 0) == 0)
        let midnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let nextDay = resolved(state(water: 1500, goal: 2500), date: midnight)
        precondition(!nextDay.isExample && nextDay.state.waterIntake == 0)
        precondition(nextDay.state.waterGoal == 2500)
        let nutritionNextDay = resolved(DailyNutritionData.example(at: now), water: false, date: midnight)
        precondition(!nutritionNextDay.isExample)
        precondition(nutritionNextDay.state.totalNutritionSplit.protein == 0)
        precondition(nutritionNextDay.state.totalNutritionSplit.carbs == 0)
        precondition(nutritionNextDay.state.totalNutritionSplit.fats == 0)
        precondition(nutritionNextDay.state.totalNutritionSplit.proteinGoal == 120)
        // The autumn transition makes this local day 25 hours long.
        precondition(midnight.timeIntervalSince(calendar.startOfDay(for: now)) == 25 * 3600)
        var buddhist = Calendar(identifier: .buddhist)
        buddhist.timeZone = calendar.timeZone
        precondition(DailyNutritionData.isCurrent(state(), at: now, calendar: buddhist))
        var pacific = calendar
        pacific.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        let boundary = ISO8601DateFormatter().date(from: "2026-10-25T00:30:00Z")!
        precondition(DailyNutritionData.isCurrent(state(), at: boundary, calendar: calendar))
        precondition(!DailyNutritionData.isCurrent(state(), at: boundary, calendar: pacific))
        let spring = ISO8601DateFormatter().date(from: "2026-03-29T12:00:00Z")!
        let springStart = calendar.startOfDay(for: spring)
        precondition(calendar.date(byAdding: .day, value: 1, to: springStart)!.timeIntervalSince(springStart) == 23 * 3600)
        let suite = "GymBro.DailyNutritionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        precondition(DailyNutritionData.load(from: defaults) == nil)
        defaults.set("corrupt", forKey: DailyNutritionData.key)
        precondition(DailyNutritionData.load(from: defaults) == nil)
        let yesterday = state(day: "2026-10-24", water: 1500)
        DailyNutritionData.save(yesterday, to: defaults)
        let restored = DailyNutritionData.load(from: defaults)!
        precondition(restored.referenceDay == "2026-10-24")
        precondition(restored.generatedAt == yesterday.generatedAt)
        precondition(!resolved(restored).isExample && resolved(restored).state.waterIntake == 0)
        let legacy = NativeFoodStateMessage(calorieGoal: 2000, calorieIntake: 10, categories: [], totalNutritionSplit: state().totalNutritionSplit)
        let decoded = NativeFoodStateMessage.decodeFoodState(from: try legacy.toJSON()!)!
        precondition(decoded.referenceDay == nil && resolved(decoded).isExample)
        precondition(DailyNutritionData.load(from: defaults)?.waterIntake == 1500) // demo never persisted
        print("Daily nutrition: fallback, valid zero, goals, dates, DST, time zones, persistence and legacy decode passed")
    }
}
