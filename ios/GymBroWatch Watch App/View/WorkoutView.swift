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
    @State private var showRecordingError = false

    private var recordingStatus: WorkoutRecordingStatus {
        WorkoutRecordingStatus(
            matchesWorkout: workoutManager.request?.id == workoutViewModel.workoutID,
            phase: workoutManager.phase,
            sensorActive: workoutManager.sessionState == .running || workoutManager.sessionState == .paused
        )
    }

    // Use physical display width: nested page/navigation insets must not
    // classify a 44 mm Watch as a small model.
    private var isCompactWatch: Bool {
        WKInterfaceDevice.current().screenBounds.width < 180
    }

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
        .alert("Workout recording", isPresented: $showRecordingError) {
            Button("Close", role: .cancel) {}
        } message: {
            if case .unavailable(let message) = recordingStatus { Text(message) }
        }
    }

    @ViewBuilder private var metrics: some View {
        if workoutViewModel.state == .running || workoutViewModel.state == .paused {
            VStack(alignment: .leading, spacing: isCompactWatch ? 2 : nil) {
                TimelineView(MetricsTimelineSchedule()) { context in
                    ElapsedTimeView(elapsedTime: context.date.timeIntervalSince(workoutViewModel.workoutStart ?? context.date), showSubseconds: context.cadence == .live)
                }
                .font(.system(size: isCompactWatch ? 20 : 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.tint)
                Spacer()
                if workoutViewModel.hasNextSet {
                    Text(workoutViewModel.exerciseName)
                        .font(.system(size: isCompactWatch ? 15 : 18, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Button {
                        guard !workoutViewModel.isLoading else { return }
                        editingSetID = workoutViewModel.set?.id
                        presentEditSheet = true
                    } label: {
                        (SetTypeIndicatorView.richTextPrefix(set: workoutViewModel.set, label: workoutViewModel.setTypeLabel, primary: workoutViewModel.exerciseColor.asARGBColor())
                         + Text(workoutViewModel.exerciseParameters) + Text(" ") + Text(Image(systemName: "pencil")))
                        .font(.system(size: isCompactWatch ? 12 : 14)).multilineTextAlignment(.center)
                    }
                    .buttonStyle(.plain)
                    .disabled(!workoutViewModel.state.isRunning)
                }
                switch recordingStatus {
                case .starting:
                    Label("Starting recording…", systemImage: "hourglass")
                        .font(.caption)
                case .unavailable:
                    Button { showRecordingError = true } label: {
                        Label("Recording unavailable", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.yellow)
                case .recording:
                    HStack {
                        Image(systemName: "heart.fill").foregroundStyle(.red).frame(width: isCompactWatch ? 24 : 30)
                        Text(workoutManager.heartRate > 0 ? "\(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0)))) bpm" : "— bpm")
                    }
                }
                HStack {
                    Image(systemName: "flame.fill").foregroundStyle(.orange).frame(width: isCompactWatch ? 24 : 30)
                    Text("\(workoutManager.activeEnergy.formatted(.number.precision(.fractionLength(1)))) kcal")
                }
                Spacer()
                HStack {
                    Button { workoutViewModel.moveWorkoutCursorPrevious() } label: { Image(systemName: "chevron.left") }
                    .accessibilityLabel("Previous set")
                    Spacer()
                    Button { workoutViewModel.markThisSetAsDone() } label: {
                        Image(systemName: "checkmark.circle")
                            .font(isCompactWatch ? .system(size: 20) : .title2)
                            .opacity(workoutViewModel.isLoading ? 0 : 1)
                            .overlay {
                                ProgressView().opacity(workoutViewModel.isLoading ? 1 : 0)
                                    .allowsHitTesting(false)
                            }
                    }
                    .accessibilityLabel("Complete set")
                    .modifier(HandGestureShortcutIfAvailable())
                    Spacer()
                    Button { workoutViewModel.moveWorkoutCursorNext() } label: { Image(systemName: "chevron.right") }
                    .accessibilityLabel("Next set")
                }
                .buttonStyle(.bordered)
                .controlSize(isCompactWatch ? .small : .regular)
                // Keep the gesture target enabled while a request is in flight.
                // The model rejects repeated actions without changing its identity.
                .disabled(!workoutViewModel.state.isRunning || !workoutViewModel.hasNextSet)
                .padding(.vertical, isCompactWatch ? 4 : 8)
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    if let end = workoutViewModel.restTimeEnd, end >= context.date {
                        Label {
                            ElapsedTimeView(elapsedTime: end.timeIntervalSince(context.date).rounded(), showSubseconds: false)
                        } icon: { Image(systemName: "timer").frame(width: isCompactWatch ? 24 : 30) }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Rest timer")
                        .accessibilityValue(Text(end, style: .timer))
                    }
                }
                .font(isCompactWatch ? .system(size: 14) : .body)
                Spacer()
            }
            .font((isCompactWatch ? Font.system(size: 14, weight: .semibold, design: .rounded) : Font.system(.headline, design: .rounded)).monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
            .tint(workoutViewModel.exerciseColor == 0 ? .accentColor : workoutViewModel.exerciseColor.asARGBColor())
            .scenePadding()
            .padding(.top, isCompactWatch ? 12 : 20)
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
