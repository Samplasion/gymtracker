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
