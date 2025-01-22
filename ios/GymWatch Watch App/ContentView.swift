//
//  ContentView.swift
//  GymWatch Watch App
//
//  Created by Francesco Arieti on 21/01/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var backgroundShape: some Shape {
        if #available(watchOS 9, iOS 16, *) {
            return .rect(cornerRadii: .init(topLeading: 0, bottomLeading: 0, bottomTrailing: 0, topTrailing: 0))
        } else if #available(watchOS 9, iOS 16, *) {
            return .rect(cornerRadii: .init(topLeading: 12, bottomLeading: 0, bottomTrailing: 0, topTrailing: 12))
        }
        return .rect(cornerRadius: 12)
    }
    
    var safeAreaIgnoredEdges: Edge.Set {
        if #available(watchOS 10, *) {
            return [.top, .leading, .trailing]
        }
        return [.leading, .trailing]
    }
    
    var body: some View {
        if (!viewModel.isWorkoutRunning && !viewModel.hasNextSet) {
            Text("Start a workout from your iPhone.")
                .multilineTextAlignment(.center)
        } else {
            ZStack {
                GradientBackgroundView(color: viewModel.exerciseColor.asARGBColor())
                    .clipShape(backgroundShape)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .ignoresSafeArea(.all, edges: safeAreaIgnoredEdges)
                
                VStack {
                    if (viewModel.hasNextSet) {
                        Text(viewModel.exerciseName)
                            .font(.system(size: 18, weight: .semibold))
                            .multilineTextAlignment(.center)
                        Text(viewModel.exerciseParameters)
                            .font(.system(size: 14, weight: .regular))
                            .multilineTextAlignment(.center)
                        Image(systemName: "checkmark.circle")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .font(.title)
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                            .onTapGesture {
                                viewModel.markThisSetAsDone()
                            }
                            .tint(viewModel.exerciseColor.asARGBColor())
                            .brightness(0.15)
                    } else {
                        Text("You're done! Use your iPhone to end the workout.")
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
        }
    }
}

extension Int {
    func asARGBColor() -> Color {
        let b = self & 0xff;
        let g = (self >> 8) & 0xff;
        let r = (self >> 16) & 0xff;
        let a = (self >> 24) & 0xff;
        
        return Color(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, opacity: Double(a) / 255.0)
    }
}
