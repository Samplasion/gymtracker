//
//  DensityChart.swift
//  Runner
//
//  Created by Francesco Arieti on 05/02/26.
//

import SwiftUI
import WidgetKit

struct DensityChart: View {
  @Environment(\.widgetFamily) var family: WidgetFamily
  
  var _values: [Int] {
    didSet {
      max = _values.max() ?? 0
    }
  }
  var values: [Int] {
    get {
      if family == .systemSmall {
        return Array(_values.prefix(7*7))
      } else {
        return Array(_values.prefix(18*7))
      }
    }
  }
  var max = 0
  
  init(values: [Int]) {
    self._values = values
    self.max = values.max() ?? 0
  }
  
  var body: some View {
    let columns = (Int(values.count)/7)
    VStack(alignment: .leading, spacing: 0) {
      Text("Workouts")
        .tint(.accentColor)
        .widgetAccentable()
        .font(.system(size: 16, weight: .bold))
      Grid(horizontalSpacing: 2, verticalSpacing: 2) {
        ForEach(0..<7, id: \.self) { index in
          GridRow {
            ForEach(0...columns, id: \.self) { innerIndex in
              if innerIndex == columns {
                Text(getWeekdayText(index))
                  .font(.system(.caption, design: .rounded, weight: .bold))
                  .scaleEffect(0.7)
              } else {
                ZStack {
                  RoundedRectangle(cornerRadius: 3, style: .circular)
                    .foregroundColor(.gray.opacity(0.2))
                  RoundedRectangle(cornerRadius: 3, style: .circular)
                    .foregroundColor(.accentColor)
                    .widgetAccentable()
                    .opacity(getValue(index, innerIndex))
                }
                .aspectRatio(1, contentMode: ContentMode.fit)
              }
            }
          }
        }
      }
      .tint(.accentColor)
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
  
  func getWeekdayText(_ index: Int) -> String {
    let relative = 6 - index;
    let formatter = DateFormatter()
    formatter.locale = .autoupdatingCurrent
    formatter.setLocalizedDateFormatFromTemplate("E")
    let calendar = Calendar(identifier: .gregorian)
    let now = Date()
    let targetDate = calendar.date(byAdding: .day, value: -relative, to: now)!
    return String(formatter.string(from: targetDate).initials())
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
