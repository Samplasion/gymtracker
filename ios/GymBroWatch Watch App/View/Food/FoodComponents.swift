import SwiftUI

extension View {
    func foodCard(tint: Color = .accentColor, padding: CGFloat = 12) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(0.09), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(tint.opacity(0.18), lineWidth: 1))
    }
}

struct FoodCardHeading: View {
    let title: LocalizedStringKey
    let icon: String
    let color: Color
    var disclosure = false

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(color)
            Spacer(minLength: 2)
            if disclosure {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
    }
}

struct FoodWaterSummary: View {
    @EnvironmentObject var viewModel: FoodViewModel
    var disclosure = false
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            if !compact {
                FoodCardHeading(title: "Water", icon: "drop.fill", color: .cyan, disclosure: disclosure)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(viewModel.waterIntake, format: .number.precision(.fractionLength(0)))
                    .font(.system(compact ? .title2 : .title, design: .rounded).weight(.bold)).monospacedDigit()
                    .minimumScaleFactor(0.6).lineLimit(1)
                Text("ml").font(.caption).foregroundStyle(.secondary)
            }
            if let goal = viewModel.waterGoal {
                ProgressView(value: DailyNutritionData.progress(viewModel.waterIntake, goal: goal)).tint(.cyan)
                HStack {
                    Text("Goal")
                    Spacer(minLength: 2)
                    Text(goal.formatted(.number.precision(.fractionLength(0))) + " ml")
                }.font(.caption2).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.75)
            } else {
                Text("No water goal").font(.caption2).foregroundStyle(.secondary)
            }
            if !compact {
                Text("Includes water from food").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .foodCard(tint: .cyan, padding: compact ? 8 : 12)
        .accessibilityElement(children: .combine)
    }
}

struct FoodPendingWater: View {
    @EnvironmentObject var viewModel: FoodViewModel

    var body: some View {
        if viewModel.currentPendingCount > 0 {
            VStack(alignment: .leading, spacing: 6) {
                Label("Awaiting sync", systemImage: "arrow.triangle.2.circlepath")
                    .font(.footnote.weight(.semibold)).foregroundStyle(.cyan)
                if viewModel.pendingWaterAmount > 0 {
                    Text("Today").font(.caption2).foregroundStyle(.secondary)
                    Text("+" + viewModel.pendingWaterAmount.formatted(.number.precision(.fractionLength(0))) + " ml")
                        .font(.headline).monospacedDigit()
                }
                HStack {
                    Text("Entries")
                    Spacer()
                    Text(viewModel.currentPendingCount, format: .number)
                }.font(.caption2).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.75)
                Text("Saved on Watch. Syncs with iPhone when available.")
                    .font(.caption2).foregroundStyle(.secondary)
            }.foodCard(tint: .cyan)
        }
        if viewModel.hasOtherAccountEntries {
            Label("Some entries are waiting for the original account.", systemImage: "person.crop.circle.badge.clock")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }
}
