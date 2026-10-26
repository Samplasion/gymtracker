import SwiftUI
import WatchKit

struct FoodWaterView: View {
    @EnvironmentObject var viewModel: FoodViewModel
    @State private var showCustom = false

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                FoodWaterSummary(compact: true)
                if viewModel.waterOwnerScope == nil {
                    Label("Open Gym Bro on iPhone to enable water logging.", systemImage: "iphone")
                        .font(.caption).foregroundStyle(.secondary).foodCard(tint: .cyan)
                }
                HStack(spacing: 5) {
                    ForEach([100, 250, 500], id: \.self) { amount in
                        Button {
                            add(Double(amount))
                        } label: {
                            VStack(spacing: 2) {
                                Text("+" + amount.formatted()).font(.footnote.weight(.semibold)).monospacedDigit()
                                    .lineLimit(1).minimumScaleFactor(0.75)
                                Text("ml").font(.caption2)
                            }.frame(maxWidth: .infinity, minHeight: 32)
                        }.tint(.cyan)
                            .accessibilityLabel(Text("Add water") + Text(" ") + Text(amount.formatted() + " ml"))
                    }
                }.buttonStyle(.bordered).disabled(viewModel.waterOwnerScope == nil)
                Button("Custom amount") { showCustom = true }
                    .font(.footnote).frame(maxWidth: .infinity, minHeight: 36)
                    .disabled(viewModel.waterOwnerScope == nil)
                Text("Includes water from food").font(.caption2).foregroundStyle(.secondary)
                FoodPendingWater()
            }.padding(.horizontal, 8).padding(.bottom, 12)
        }
        .navigationTitle("Water")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCustom) {
            CustomWaterAmountView()
        }
    }

    private func add(_ amount: Double) {
        WKInterfaceDevice.current().play(viewModel.addWater(amount) ? .success : .failure)
    }
}

private struct CustomWaterAmountView: View {
    @EnvironmentObject var viewModel: FoodViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var amount = 250.0
    @FocusState private var amountFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    Text(amount.formatted(.number.precision(.fractionLength(0))) + " ml")
                        .font(.system(.title2, design: .rounded).weight(.bold)).monospacedDigit()
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .focusable().focused($amountFocused)
                        .digitalCrownRotation($amount, from: 50, through: 2000, by: 50, sensitivity: .low,
                            isContinuous: false, isHapticFeedbackEnabled: true)
                        .accessibilityLabel("Amount")
                        .accessibilityValue(amount.formatted() + " ml")
                        .accessibilityAdjustableAction { direction in
                            if direction == .increment { amount = min(2000, amount + 50) }
                            else if direction == .decrement { amount = max(50, amount - 50) }
                        }
                    HStack {
                        Button { amount = max(50, amount - 50) } label: { Image(systemName: "minus") }
                            .disabled(amount <= 50).accessibilityLabel("Decrease amount")
                        Button { amount = min(2000, amount + 50) } label: { Image(systemName: "plus") }
                            .disabled(amount >= 2000).accessibilityLabel("Increase amount")
                    }.buttonStyle(.bordered)
                    Button("Add water") {
                        let saved = viewModel.addWater((amount / 50).rounded() * 50)
                        WKInterfaceDevice.current().play(saved ? .success : .failure)
                        if saved { dismiss() }
                    }.buttonStyle(.borderedProminent).tint(.cyan)
                        .disabled(viewModel.waterOwnerScope == nil)
                }.padding(.horizontal, 8)
            }
            .navigationTitle("Amount").navigationBarTitleDisplayMode(.inline)
        }.onAppear { amountFocused = true }
    }
}
