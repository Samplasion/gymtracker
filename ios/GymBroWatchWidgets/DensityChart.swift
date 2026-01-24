//
//  DensityChart.swift
//  GymBroWatchWidgetsExtension
//
//  Created by Francesco Arieti on 06/01/26.
//

import SwiftUI
import WidgetKit

struct DensityChart: View {
  var values: [Int] {
    didSet {
      max = values.max() ?? 0
    }
  }
  var max = 0
  
  init(values: [Int]) {
    self.values = values
    self.max = values.max() ?? 0
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Workouts")
        .foregroundStyle(.accent)
        .widgetAccentable()
        .font(.system(size: 16, weight: .bold))
      Grid(horizontalSpacing: 1.1, verticalSpacing: 1.1) {
        ForEach(0..<7, id: \.self) { index in
          GridRow {
            ForEach(0..<(Int(values.count)/7), id: \.self) { innerIndex in
              ZStack {
                RoundedRectangle(cornerRadius: 2, style: .circular)
                  .foregroundColor(.gray.opacity(0.2))
                RoundedRectangle(cornerRadius: 2, style: .circular)
                  .foregroundColor(.accent)
                  .widgetAccentable()
                  .opacity(getValue(index, innerIndex))
              }
            }
          }
        }
      }
      .frame(height: 50)
      .tint(.accent)
    }
    .frame(
      minWidth: 0,
      maxWidth: .infinity,
      minHeight: 0,
      maxHeight: .infinity,
      alignment: .topLeading
    )
  }
  
  func getValue(_ index: Int, _ innerIndex: Int) -> Double {
    let idx = calculateIndex(index, innerIndex)
    if idx >= values.count {
      return 0
    }
    if max == 0 {
      return 0
    }
    return Double(values[idx]) / Double(max)
  }
  
  func calculateIndex(_ index: Int, _ innerIndex: Int) -> Int {
    let col = 7*((values.count/7) - innerIndex - 1)
    return col + 6 - index
  }
}

#Preview {
  DensityChart(values: [
    1, 2, 0, 0, 0, 0, 0,
    0, 0, 1, 4, 5, 1, 0,
    0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 2, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 4, 5, 1, 0,
    0, 0, 1, 2, 5, 1, 4,
    0, 0, 1, 4, 5, 1, 0,
  ])
}
