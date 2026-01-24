//
//  MetricsView.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 26/12/25.
//

import SwiftUI
import HealthKit

struct WorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    
    @State var presentEditSheet = false
    
    @ViewBuilder
    var body: some View {
        NavigationView {
            innerBody
        }
    }
    
    @ViewBuilder
    var innerBody: some View {
        switch workoutViewModel.state {
        case .running, .paused:
            TimelineView(MetricsTimelineSchedule()) { context in
                VStack(alignment: .leading) {
                    // Timer view
                    ElapsedTimeView(elapsedTime: elapsedTime(with: context.date), showSubseconds: context.cadence == .live)
                        .foregroundStyle(.tint)
                        .if(workoutViewModel.exerciseColor != 0 && workoutViewModel.hasNextSet) {
                            $0.tint(workoutViewModel.exerciseColor.asARGBColor())
                        }
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .brightness(0.15)
                    
                    Spacer()
                    
                    // Exercise view
                    if workoutViewModel.hasNextSet {
                        Text(workoutViewModel.exerciseName)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.center)
                        if #available(watchOS 9, *) {
                            Button(action: {
                                presentEditSheet = true
                            }, label: {
                                Text("\(workoutViewModel.exerciseParameters) \(Image(systemName: "chevron.right"))")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .multilineTextAlignment(.center)
                            })
                            .buttonStyle(.plain)
                            .disabled(!workoutViewModel.state.isRunning || workoutViewModel.isLoading)
                        } else {
                            Text(workoutViewModel.exerciseParameters)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // BPM view
                    HStack {
                        Image(systemName: "heart.fill").foregroundStyle(.red).frame(width: 30)
                        Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
                    }
                    HStack {
                        Image(systemName: "flame.fill").foregroundStyle(.orange).frame(width: 30)
                        Text(workoutManager.activeEnergy.formatted(.number.precision(.fractionLength(1))) + " kcal")
                    }
                    
                    Spacer()
                    
                    // Control(s)
                    HStack {
                        Spacer()
                        Button(action: {
                            if !workoutViewModel.isLoading {
                                workoutViewModel.markThisSetAsDone()
                            }
                        }, label: {
                            ZStack {
                                Image(systemName: "checkmark.circle")
                                    .imageScale(.medium)
                                    .foregroundStyle(.tint)
                                    .font(.title2)
                                    .tint(workoutViewModel.exerciseColor.asARGBColor())
                                    .brightness(0.15)
                                    .opacity(workoutViewModel.isLoading ? 0.0 : 1.0)
                                
                                if (workoutViewModel.isLoading) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .imageScale(.medium)
                                        .foregroundStyle(.tint)
                                        .font(.title2)
                                        .tint(workoutViewModel.exerciseColor.asARGBColor())
                                        .brightness(0.15)
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        })
                        .buttonStyle(.plain)
                        .clipShape(Circle())
                        .modifier(HandGestureShortcutIfAvailable())
                        .disabled(!workoutViewModel.state.isRunning || workoutViewModel.isLoading || !workoutViewModel.hasNextSet)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    
                    // Rest time view
                    Label {
                        ElapsedTimeView(elapsedTime: restTime(with: context.date), showSubseconds: false)
                    } icon: {
                        if restTime(with: context.date) >= 0 {
                            Image(systemName: "timer").frame(width: 30)
                        }
                    }
                    .font(.system(.body, design: .default))
                    
                    Spacer()
                }
                .font(.system(.headline, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                .frame(maxWidth: .infinity, alignment: .leading)
                .ignoresSafeArea(edges: .bottom)
                .scenePadding()
                .padding([.top], 30)
                .onChange(of: workoutViewModel.set, perform: { _ in
                    presentEditSheet = false
                })
            }
            .sheet(isPresented: $presentEditSheet, content: {
                if #available(watchOS 9, *) {
                    SetEditSheet(model: workoutViewModel)
                        .tint(workoutViewModel.exerciseColor.asARGBColor())
                } else {
                    EmptyView()
                }
            })
        case .notStarted, .cancelled, .ended:
            Text("Start a workout from your iPhone.")
                .multilineTextAlignment(.center)
                .font(.system(.headline, design: .default).weight(.regular))
                .lineLimit(5)
                .navigationTitle(Text("Workout"))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func elapsedTime(with contextDate: Date) -> TimeInterval {
        return contextDate.timeIntervalSince(workoutViewModel.workoutStart ?? .now) // workoutManager.builder?.elapsedTime(at: contextDate) ?? 0
    }
    
    func restTime(with contextDate: Date) -> TimeInterval {
        if (workoutViewModel.restTimeEnd == nil) {
            return -1
        }
        return workoutViewModel.restTimeEnd!.timeIntervalSince(contextDate).rounded(.toNearestOrAwayFromZero);
    }
}

struct MetricsTimelineSchedule: TimelineSchedule {
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        let newMode = (mode == .lowFrequency ? 1.0 : 1.0 / 30.0)
        var baseSchedule = PeriodicTimelineSchedule(from: Date(), by: newMode).entries(from: Date(), mode: mode)
        
        return AnyIterator<Date> {
            return baseSchedule.next()
        }
    }
}

private struct HandGestureShortcutIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        if #available(watchOS 11, *) {
            content.handGestureShortcut(.primaryAction)
        } else {
            content
        }
    }
}
