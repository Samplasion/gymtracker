import SwiftUI

struct PagingView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State private var selection: Tab = .workout
    @State private var summaryID: String?
    private enum Tab { case workout, food }

    var body: some View {
        ZStack {
            if workoutViewModel.state.isRunning {
                GradientBackgroundView(color: workoutViewModel.exerciseColor.asARGBColor()).ignoresSafeArea()
            }
            if #available(watchOS 10, *) {
                pages.tabViewStyle(.verticalPage)
            } else {
                pages.tabViewStyle(.page)
            }
        }
        .onChange(of: workoutViewModel.workoutID) { _ in summaryID = nil; selection = .workout }
        .onChange(of: workoutViewModel.state) { state in
            if state == .running || state == .paused { summaryID = nil; selection = .workout }
            else if state == .ended { summaryID = workoutViewModel.workoutID }
        }
        .onAppear { workoutManager.requestAuthorization() }
        .sheet(isPresented: Binding(get: { summaryID != nil }, set: { if !$0 { summaryID = nil } })) {
            if let id = summaryID { SummaryView(workoutID: id) }
        }
    }

    private var pages: some View {
        TabView(selection: $selection) {
            WorkoutView().tag(Tab.workout)
            if !workoutViewModel.isWorkoutRunning { FoodView().tag(Tab.food) }
        }
    }
}
