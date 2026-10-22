import SwiftUI
import HealthKit
import WatchKit

struct WorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: Tab = .workout
    @State private var mediaIdentity = UUID()
    @State private var presentEditSheet = false
    @State private var editingSetID: String?
    private enum Tab { case workout, music }

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack { metrics }.tag(Tab.workout)
            // The system media controller is a page root, outside NavigationStack.
            NowPlayingView().id(mediaIdentity).tag(Tab.music)
        }
        .tabViewStyle(.page)
        .onChange(of: selection) { tab in if tab == .music { mediaIdentity = UUID() } }
        .onChange(of: scenePhase) { phase in if phase == .active { mediaIdentity = UUID() } }
        .onChange(of: isLuminanceReduced) { reduced in if reduced { selection = .workout } }
        .onChange(of: workoutViewModel.workoutID) { _ in presentEditSheet = false; selection = .workout }
        .onChange(of: workoutViewModel.set?.id) { id in
            if presentEditSheet && editingSetID != id { presentEditSheet = false }
        }
        .sheet(isPresented: $presentEditSheet, onDismiss: { editingSetID = nil }) {
            SetEditSheet(model: workoutViewModel)
        }
    }

    @ViewBuilder private var metrics: some View {
        if workoutViewModel.state == .running || workoutViewModel.state == .paused {
            VStack(alignment: .leading) {
                TimelineView(MetricsTimelineSchedule()) { context in
                    ElapsedTimeView(elapsedTime: context.date.timeIntervalSince(workoutViewModel.workoutStart ?? context.date), showSubseconds: context.cadence == .live)
                }
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.tint)
                Spacer()
                if workoutViewModel.hasNextSet {
                    Text(workoutViewModel.exerciseName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Button {
                        guard !workoutViewModel.isLoading else { return }
                        editingSetID = workoutViewModel.set?.id
                        presentEditSheet = true
                    } label: {
                        (SetTypeIndicatorView.richTextPrefix(set: workoutViewModel.set, label: workoutViewModel.setTypeLabel, primary: workoutViewModel.exerciseColor.asARGBColor())
                         + Text(workoutViewModel.exerciseParameters) + Text(" ") + Text(Image(systemName: "pencil")))
                        .font(.system(size: 14)).multilineTextAlignment(.center)
                    }
                    .buttonStyle(.plain)
                    .disabled(!workoutViewModel.state.isRunning)
                }
                HStack {
                    Image(systemName: "heart.fill").foregroundStyle(.red).frame(width: 30)
                    Text(workoutManager.heartRate > 0 ? "\(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0)))) bpm" : "— bpm")
                }
                HStack {
                    Image(systemName: "flame.fill").foregroundStyle(.orange).frame(width: 30)
                    Text("\(workoutManager.activeEnergy.formatted(.number.precision(.fractionLength(1)))) kcal")
                }
                Spacer()
                HStack {
                    Button { workoutViewModel.moveWorkoutCursorPrevious() } label: { Image(systemName: "chevron.left") }
                    Spacer()
                    Button { workoutViewModel.markThisSetAsDone() } label: {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .opacity(workoutViewModel.isLoading ? 0 : 1)
                            .overlay {
                                ProgressView().opacity(workoutViewModel.isLoading ? 1 : 0)
                                    .allowsHitTesting(false)
                            }
                    }
                    .modifier(HandGestureShortcutIfAvailable())
                    Spacer()
                    Button { workoutViewModel.moveWorkoutCursorNext() } label: { Image(systemName: "chevron.right") }
                }
                .buttonStyle(.bordered)
                // Keep the gesture target enabled while a request is in flight.
                // The model rejects repeated actions without changing its identity.
                .disabled(!workoutViewModel.state.isRunning || !workoutViewModel.hasNextSet)
                .padding(.vertical, 8)
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    if let end = workoutViewModel.restTimeEnd, end >= context.date {
                        Label {
                            ElapsedTimeView(elapsedTime: end.timeIntervalSince(context.date).rounded(), showSubseconds: false)
                        } icon: { Image(systemName: "timer").frame(width: 30) }
                    }
                }
                .font(.body)
                Spacer()
            }
            .font(.system(.headline, design: .rounded).monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
            .tint(workoutViewModel.exerciseColor == 0 ? .accentColor : workoutViewModel.exerciseColor.asARGBColor())
            .scenePadding()
            .padding(.top, 30)
            .ignoresSafeArea(edges: .bottom)
        } else {
            Text("Start a workout from your iPhone.")
                .multilineTextAlignment(.center)
                .font(.system(.headline).weight(.regular))
                .navigationTitle("Workout")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MetricsTimelineSchedule: TimelineSchedule {
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        var entries = PeriodicTimelineSchedule(from: startDate, by: mode == .lowFrequency ? 1 : 1.0 / 30).entries(from: startDate, mode: mode)
        return AnyIterator { entries.next() }
    }
}

private struct HandGestureShortcutIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        if #available(watchOS 11, *) { content.handGestureShortcut(.primaryAction) }
        else { content }
    }
}
