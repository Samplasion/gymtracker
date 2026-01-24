//
//  GradientBackgroundView.swift
//  GymWatch Watch App
//
//  Created by Francesco Arieti on 22/01/25.
//

import SwiftUI
import Foundation

struct GradientBackgroundView: View {
    var color: Color
    
    var body: some View {
        if #available(watchOS 9.0, *) {
            MaybeGradientBackgroundView(color: color)
        } else {
            AlwaysGradientBackgroundView(color: color)
        }
    }
}

@available(watchOS 9.0, *)
struct MaybeGradientBackgroundView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    var color: Color
    
    var body: some View {
        if !isLuminanceReduced {
            AlwaysGradientBackgroundView(color: color)
        } else {
            EmptyView()
        }
    }
}

struct AlwaysGradientBackgroundView: View {
    var color: Color
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.5),
                    .black,
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    GradientBackgroundView(color: .red)
}
