import SwiftUI

struct PagingView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State private var selection: Tab = .workout
    @State private var summaryID: String?
    private enum Tab { case workout, food, exerciseNotes, supersetNotes }

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
            else { summaryID = nil; selection = .workout }
        }
        .onChange(of: workoutViewModel.exerciseID) { _ in selection = .workout }
        .onChange(of: workoutViewModel.exerciseNotes) { _ in
            if !workoutViewModel.hasExerciseNotes && selection == .exerciseNotes { selection = .workout }
        }
        .onChange(of: workoutViewModel.supersetNotes) { _ in
            if !workoutViewModel.hasSupersetNotes && selection == .supersetNotes { selection = .workout }
        }
        .onAppear { if !ScreenshotMode.enabled { workoutManager.requestAuthorization() } }
        .sheet(isPresented: Binding(get: { summaryID != nil }, set: { if !$0 { summaryID = nil } })) {
            if let id = summaryID { SummaryView(workoutID: id) }
        }
    }

    private var pages: some View {
        TabView(selection: $selection) {
            if workoutViewModel.isWorkoutRunning {
                WorkoutView().tag(Tab.workout)
            } else {
                NavigationStack {
                    TrainingHomeView()
                }.tag(Tab.workout)
            }
            if workoutViewModel.isWorkoutRunning {
                if workoutViewModel.hasExerciseNotes {
                    WorkoutNotesView(title: "Exercise notes", context: workoutViewModel.exerciseName,
                        notes: workoutViewModel.exerciseNotes, tint: workoutViewModel.exerciseColor == 0 ? .accentColor : workoutViewModel.exerciseColor.asARGBColor()).tag(Tab.exerciseNotes)
                }
                if workoutViewModel.hasSupersetNotes {
                    WorkoutNotesView(title: "Superset notes", context: "", notes: workoutViewModel.supersetNotes,
                        tint: workoutViewModel.exerciseColor == 0 ? .accentColor : workoutViewModel.exerciseColor.asARGBColor()).tag(Tab.supersetNotes)
                }
            } else { FoodView().tag(Tab.food) }
        }
    }
}

/// A vertical sibling of the workout controls, so horizontal music/actions pages
/// retain their gestures and long notes scroll without truncation.
struct WorkoutNotesView: View {
    let title: LocalizedStringKey
    let context: String
    let notes: String
    let tint: Color

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Label(title, systemImage: "note.text")
                        .font(.headline).foregroundStyle(tint)
                    if !context.isEmpty {
                        Text(context).font(.headline).fixedSize(horizontal: false, vertical: true)
                    }
                    QuillNoteView(notes, accent: tint)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .padding(.horizontal, 8).padding(.bottom, 12)
            }
            .tint(tint)
            .accentColor(tint)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
