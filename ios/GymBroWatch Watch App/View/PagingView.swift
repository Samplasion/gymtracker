//
//  PagingView.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 26/12/25.
//

import SwiftUI

struct PagingView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @State private var selection: Tab = .workout
    @State private var isSheetActive = false

    private enum Tab {
        case workout, food
    }
    
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
        ZStack {
            if workoutViewModel.state.isRunning {
                GradientBackgroundView(color: workoutViewModel.exerciseColor.asARGBColor())
                    .clipShape(backgroundShape)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .ignoresSafeArea(.all, edges: safeAreaIgnoredEdges)
            }
            
            if #available(watchOS 10, *) {
                TabView(selection: $selection) {
                    WorkoutView().tag(Tab.workout)
                    if !workoutViewModel.isWorkoutRunning {
                        FoodView().tag(Tab.food)
                    }
                }
//                NavigationView {
//                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
                .tabViewStyle(.verticalPage)
                .onChange(of: isLuminanceReduced) {
                    displayMetricsView()
                }
                .onChange(of: workoutManager.sessionState) { _, newValue in
                    if newValue == .ended {
                        isSheetActive = true
                    } else if newValue == .running || newValue == .paused {
                        displayMetricsView()
                    }
                }
                .onChange(of: workoutViewModel.state) { _, newValue in
                    if newValue == .ended {
                        isSheetActive = true
                    } else if newValue == .running || newValue == .paused {
                        displayMetricsView()
                    }
                }
                .onAppear {
                    workoutManager.requestAuthorization()
                }
                .sheet(isPresented: $isSheetActive) {
                    workoutManager.resetWorkout()
                } content: {
                    SummaryView()
                }
            } else {
                WorkoutView()
            }
        }
    }

    private func displayMetricsView() {
        if !workoutViewModel.isWorkoutRunning {
            return
        }
        selection = .workout
    }
}

#Preview {
    PagingView()
}
