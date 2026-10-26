import SwiftUI
import WidgetKit

struct DailyNutritionEntry: TimelineEntry {
    let date: Date
    let source: NativeFoodStateMessage?
}

struct DailyNutritionProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyNutritionEntry {
        DailyNutritionEntry(date: .now, source: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyNutritionEntry) -> Void) {
        completion(.init(date: .now, source: context.isPreview ? nil : DailyNutritionData.load(from: UserDefaults(suiteName: DailyNutritionData.appGroup))))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyNutritionEntry>) -> Void) {
        let now = Date()
        let midnight = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: Calendar.autoupdatingCurrent.startOfDay(for: now))!
        let source = DailyNutritionData.load(from: UserDefaults(suiteName: DailyNutritionData.appGroup))
        completion(Timeline(entries: [.init(date: now, source: source), .init(date: midnight, source: source)], policy: .after(midnight)))
    }
}

@available(iOS 17.0, watchOS 10.0, *)
struct DailyNutritionWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DailyNutritionEntry
    let water: Bool

    private var compact: Bool {
        family == .accessoryRectangular || family == .accessoryCircular
    }

    private func quantity(_ value: Double, goal: Double?, unit: String) -> String {
        let amount = value.formatted(.number.precision(.fractionLength(0)))
        if let goal, goal > 0 {
            return "\(amount)/\(goal.formatted(.number.precision(.fractionLength(0)))) \(unit)"
        }
        return "\(amount) \(unit)"
    }

    var body: some View {
        let state = DailyNutritionData.resolved(entry.source, at: entry.date, water: water).state
        VStack(alignment: water ? .center : .leading, spacing: compact ? 2 : 8) {
            if family != .accessoryCircular && (water || !compact) {
                HStack {
                    Text(water ? LocalizedStringKey("Water") : LocalizedStringKey("Nutrients")).font(compact ? .caption2 : .headline)
                    Spacer(minLength: 2)
                }
            }
            if water {
                waterContent(state)
            } else {
                let split = state.totalNutritionSplit
                nutrient("Protein", value: split.protein, goal: split.proteinGoal, color: .blue)
                nutrient("Carbs", value: split.carbs, goal: split.carbsGoal, color: .orange)
                nutrient("Fats", value: split.fats, goal: split.fatsGoal, color: .purple)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    @ViewBuilder
    private func waterContent(_ state: NativeFoodStateMessage) -> some View {
        let intake = state.waterIntake ?? 0
        let progress = DailyNutritionData.progress(intake, goal: state.waterGoal)
        if family == .accessoryRectangular {
            HStack {
                waterGauge(progress, amount: intake)
                Text(quantity(intake, goal: state.waterGoal, unit: "ml")).font(.caption).minimumScaleFactor(0.7)
            }
        } else {
            waterGauge(progress, amount: intake)
            if family != .accessoryCircular {
                Text(quantity(intake, goal: state.waterGoal, unit: "ml")).font(.caption).minimumScaleFactor(0.7)
            }
        }
    }

    private func waterGauge(_ progress: Double, amount: Double) -> some View {
        Gauge(value: progress) {
            Text("Water")
        } currentValueLabel: {
            VStack(spacing: 0) {
                Image(systemName: "drop.fill").font(.system(size: compact ? 12 : 16))
                Text(amount.formatted(.number.precision(.fractionLength(0)))).font(.system(size: compact ? 10 : 13))
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(.cyan)
        .accessibilityLabel(Text("Water"))
        .accessibilityValue(Text("\(amount.formatted(.number.precision(.fractionLength(0)))) ml"))
    }

    private func nutrient(_ title: LocalizedStringKey, value: Double, goal: Double, color: Color) -> some View {
        VStack(spacing: compact ? 0 : 2) {
            HStack {
                Text(title)
                Spacer(minLength: 2)
                Text(quantity(value, goal: goal, unit: "g")).monospacedDigit()
            }
            .font(.system(size: compact ? 9 : 11))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.2))
                    Capsule().fill(color)
                        .frame(width: geometry.size.width * DailyNutritionData.progress(value, goal: goal))
                        .widgetAccentable()
                }
            }
            .frame(height: compact ? 3 : 5)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(quantity(value, goal: goal, unit: "g"))
    }
}

@available(iOS 17.0, watchOS 10.0, *)
struct GymBroWidgetsWater: Widget {
    let kind = "GymBroWidgetsWater"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyNutritionProvider()) { entry in
            DailyNutritionWidgetView(entry: entry, water: true)
        }
        .configurationDisplayName("Water")
        .description("Your daily hydration progress.")
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
        #else
        .supportedFamilies([.systemSmall, .accessoryCircular])
        #endif
    }
}

@available(iOS 17.0, watchOS 10.0, *)
struct GymBroWidgetsNutrition: Widget {
    let kind = "GymBroWidgetsNutrition"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyNutritionProvider()) { entry in
            DailyNutritionWidgetView(entry: entry, water: false)
        }
        .configurationDisplayName("Nutrients")
        .description("Your daily protein, carbs and fats.")
        #if os(watchOS)
        .supportedFamilies([.accessoryRectangular])
        #else
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
        #endif
    }
}
