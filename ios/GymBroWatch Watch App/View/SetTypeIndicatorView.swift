//
//  SetTypeIndicatorView.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 17/04/26.
//

import SwiftUI

struct SetTypeIndicatorView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel

    let set: GTSet?
    let label: String

    var body: some View {
        if let set = set, !label.isEmpty {
            buildSetTypeIndicator(set: set, label: label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: 40)
                .cornerRadius(4)
        }
    }

    static func richTextPrefix(set: GTSet?, label: String, primary: Color) -> Text {
        guard let set = set, !label.isEmpty else {
            return Text("")
        }

        let palette = SetTypePalette(primary: primary)
        let color: Color = switch set.kind {
        case .warmUp:
            palette.tertiary
        case .normal:
            palette.primary
        case .drop:
            palette.error
        case .failure:
            palette.quinary
        case .failureStripping:
            palette.quaternary
        }

      if #available(watchOS 10.0, *) {
        return Text("\(label)  ")
          .foregroundStyle(color)
          .monospacedDigit()
      } else {
        return Text("\(label)  ")
          .foregroundColor(color)
          .monospacedDigit()
      }
    }

    @ViewBuilder
    private func buildSetTypeIndicator(set: GTSet, label: String) -> some View {
        let palette = SetTypePalette(primary: workoutViewModel.exerciseColor.asARGBColor())
        switch set.kind {
        case .warmUp:
            Text(label)
                .foregroundStyle(palette.tertiary)
        case .normal:
            Text(label)
                .foregroundStyle(palette.primary)
        case .drop:
            Text(label)
                .foregroundStyle(palette.error)
        case .failure:
            Text(label)
                .foregroundStyle(palette.quinary)
        case .failureStripping:
            Text(label)
                .foregroundStyle(palette.quaternary)
        }
    }
}

private struct SetTypePalette {
    let primary: Color
    let tertiary: Color
    let error: Color
    let quinary: Color
    let quaternary: Color

    init(primary: Color) {
        self.primary = primary
        self.error = Color.red

        let isGray = primary.isGray
        self.tertiary = primary

        if isGray {
            // Mirrors Flutter MoreColors.fromColorScheme grayscale path.
            self.quaternary = primary
            self.quinary = primary
        } else {
            // Mirrors Flutter MoreColors.fromColorScheme non-grayscale path.
            // quaternary <- primary.pentadicColors[4].harmonizeWith(primary)
            // quinary    <- primary.pentadicColors[3].harmonizeWith(primary)
            let pentadic = primary.pentadicColors
            self.quaternary = pentadic[4].harmonized(with: primary)
            self.quinary = pentadic[3].harmonized(with: primary)
        }
    }
}

private extension Color {
    var isGray: Bool {
        let rgb = rgbComponents
        return abs(rgb.r - rgb.g) < 0.001 && abs(rgb.g - rgb.b) < 0.001
    }

    var pentadicColors: [Color] {
        let baseHSL = hslComponents
        var result: [Color] = [self]
        for i in 1...4 {
            result.append(
                Color.fromHSL(
                    hue: fmod(baseHSL.h + (72.0 * Double(i)) + 360.0, 360.0),
                    saturation: baseHSL.s,
                    lightness: baseHSL.l
                )
            )
        }
        return result
    }

    func harmonized(with source: Color) -> Color {
        // Port of Material harmonize hue-shift idea used by Flutter dynamic_color.
        let from = hslComponents.h
        let to = source.hslComponents.h
        let difference = hueDifferenceDegrees(from, to)
        let rotation = min(difference * 0.5, 15.0)
        let direction = hueRotationDirection(from, to)
        let newHue = fmod(from + rotation * direction + 360.0, 360.0)

        let fromHSL = hslComponents
        return Color.fromHSL(hue: newHue, saturation: fromHSL.s, lightness: fromHSL.l)
    }

    static func fromHSL(hue: Double, saturation: Double, lightness: Double) -> Color {
        let h = hue / 360.0
        let s = max(0.0, min(1.0, saturation))
        let l = max(0.0, min(1.0, lightness))

        if s == 0 {
            return Color(red: l, green: l, blue: l)
        }

        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q

        func hueToRGB(_ p: Double, _ q: Double, _ t: Double) -> Double {
            var t = t
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1.0 / 6.0 { return p + (q - p) * 6 * t }
            if t < 1.0 / 2.0 { return q }
            if t < 2.0 / 3.0 { return p + (q - p) * (2.0 / 3.0 - t) * 6 }
            return p
        }

        let r = hueToRGB(p, q, h + 1.0 / 3.0)
        let g = hueToRGB(p, q, h)
        let b = hueToRGB(p, q, h - 1.0 / 3.0)
        return Color(red: r, green: g, blue: b)
    }

    private func hueDifferenceDegrees(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return min(diff, 360.0 - diff)
    }

    private func hueRotationDirection(_ from: Double, _ to: Double) -> Double {
        let increasing = fmod(to - from + 360.0, 360.0)
        return increasing <= 180.0 ? 1.0 : -1.0
    }

    private var rgbComponents: (r: Double, g: Double, b: Double) {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
        #else
        return (0, 0, 0)
        #endif
    }

    private var hslComponents: (h: Double, s: Double, l: Double) {
        let rgb = rgbComponents
        let maxV = max(rgb.r, max(rgb.g, rgb.b))
        let minV = min(rgb.r, min(rgb.g, rgb.b))
        let delta = maxV - minV
        let l = (maxV + minV) / 2.0

        if delta == 0 {
            return (0.0, 0.0, l)
        }

        let s = l > 0.5 ? delta / (2.0 - maxV - minV) : delta / (maxV + minV)

        var h: Double
        if maxV == rgb.r {
            h = (rgb.g - rgb.b) / delta + (rgb.g < rgb.b ? 6.0 : 0.0)
        } else if maxV == rgb.g {
            h = (rgb.b - rgb.r) / delta + 2.0
        } else {
            h = (rgb.r - rgb.g) / delta + 4.0
        }

        h *= 60.0
        return (h, s, l)
    }
}

#Preview {
    VStack(spacing: 20) {
      if #available(watchOS 10.0, *) {
        SetTypeIndicatorView(
          set: GTSet.decode(from: [
            "id": "1",
            "kind": "warmUp",
            "parameters": "repsWeight",
            "reps": 0,
            "weight": 0,
            "time": nil,
            "distance": nil,
            "done": false
          ]),
          label: "W"
        )
      } else {
        // Fallback on earlier versions
      }

      if #available(watchOS 10.0, *) {
        SetTypeIndicatorView(
          set: GTSet.decode(from: [
            "id": "2",
            "kind": "normal",
            "parameters": "repsWeight",
            "reps": 10,
            "weight": 50,
            "time": nil,
            "distance": nil,
            "done": false
          ]),
          label: "2"
        )
      } else {
        // Fallback on earlier versions
      }

      if #available(watchOS 10.0, *) {
        SetTypeIndicatorView(
          set: GTSet.decode(from: [
            "id": "3",
            "kind": "drop",
            "parameters": "repsWeight",
            "reps": 8,
            "weight": 45,
            "time": nil,
            "distance": nil,
            "done": false
          ]),
          label: "D"
        )
      } else {
        // Fallback on earlier versions
      }
    }
    .padding()
    .environmentObject(WorkoutViewModel())
}
