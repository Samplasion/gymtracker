import SwiftUI

func trainingText(_ italian: String, _ english: String) -> String {
    Bundle.main.localizedString(forKey: english, value: Locale.current.languageCode == "it" ? italian : english, table: nil)
}

extension View {
    func watchCard(tint: Color = .accentColor, padding: CGFloat = 12) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(0.09), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(tint.opacity(0.18), lineWidth: 1))
    }
}

struct TrainingHomeView: View {
    @ObservedObject private var model = TrainingViewModel.shared
    private var routines: [[String: Any]] { model.catalog?["routines"] as? [[String: Any]] ?? [] }
    private var folders: [[String: Any]] { (model.catalog?["folders"] as? [[String: Any]] ?? []).sorted {
        ($0["name"] as? String ?? "").localizedStandardCompare($1["name"] as? String ?? "") == .orderedAscending
    } }
    private var pending: [[String: Any]] { model.pending.filter { $0["ownerScope"] as? String == model.owner } }
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if let error = model.error {
                    Label(trainingText("Sincronizzazione non riuscita", "Sync unavailable"), systemImage: "exclamationmark.triangle")
                        .font(.caption).watchCard(tint: .orange).accessibilityHint(error)
                }
                if !pending.isEmpty {
                    NavigationLink { TrainingQueueView() } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath").foregroundStyle(.cyan)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(trainingText("Da sincronizzare", "Waiting to sync")).font(.caption.weight(.semibold))
                                Text("\(pending.count) " + trainingText("allenamenti", "workouts")).font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.secondary).accessibilityHidden(true)
                        }.watchCard(tint: .cyan)
                    }.buttonStyle(.plain)
                }
                if model.catalog == nil {
                    empty(icon: "iphone", title: trainingText("Le tue routine, al polso", "Your routines, on your wrist"),
                          detail: trainingText("Apri Gym Bro su iPhone per scaricarle. Poi puoi allenarti anche offline.", "Open Gym Bro on iPhone to download them. Then train even when offline."))
                } else if routines.isEmpty {
                    empty(icon: "dumbbell", title: trainingText("Nessuna routine", "No routines yet"),
                          detail: trainingText("Crea la tua prima routine nella scheda Allenati su iPhone.", "Create your first routine in Train on iPhone."))
                } else {
                    ForEach(folders.indices, id: \.self) { index in
                        let folder = folders[index]
                        let entries = routines.filter { ($0["folder"] as? [String: Any])?["id"] as? String == folder["id"] as? String }
                        NavigationLink {
                            TrainingRoutineList(title: folder["name"] as? String ?? "", routines: entries)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "folder.fill").foregroundStyle(.orange)
                                    Text("\(entries.count) " + (entries.count == 1 ? "routine" : trainingText("routine", "routines")))
                                        .font(.caption2).foregroundStyle(.secondary)
                                    Spacer(minLength: 0)
                                    Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.secondary).accessibilityHidden(true)
                                }
                                Text(folder["name"] as? String ?? "").font(.headline).lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }.watchCard(tint: .orange)
                        }.buttonStyle(.plain)
                    }
                    ForEach(routines.indices, id: \.self) { index in
                        let routine = routines[index]
                        if routine["folder"] is NSNull || routine["folder"] == nil { TrainingRoutineLink(routine: routine) }
                    }
                    Label(trainingText("Disponibili offline", "Available offline"), systemImage: "checkmark.circle")
                        .font(.caption2).foregroundStyle(.secondary).padding(.top, 4)
                }
            }.padding(.horizontal, 8).padding(.bottom, 12)
        }
        .navigationTitle(trainingText("Allenati", "Train"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            model.flush()
            while !Task.isCancelled {
                do { try await Task.sleep(nanoseconds: 5_000_000_000) } catch { return }
                model.flush()
            }
        }
    }
    private func empty(icon: String, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(.tint)
            Text(title).font(.headline)
            Text(detail).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }.watchCard()
    }
}

private struct TrainingRoutineList: View {
    let title: String
    let routines: [[String: Any]]
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(routines.indices, id: \.self) { TrainingRoutineLink(routine: routines[$0]) }
                if routines.isEmpty { Text(trainingText("Nessuna routine", "No routines yet")).font(.caption).watchCard() }
            }.padding(.horizontal, 8).padding(.bottom, 12)
        }.navigationTitle(title).navigationBarTitleDisplayMode(.inline)
    }
}

private struct TrainingRoutineLink: View {
    let routine: [String: Any]
    private var name: String { routine["name"] as? String ?? "" }
    var body: some View {
        NavigationLink { TrainingRoutineDetail(routine: routine) } label: {
            HStack(alignment: .top, spacing: 9) {
                Text(String(name.isEmpty ? "R" : name.prefix(1).uppercased()))
                    .font(.headline.weight(.bold)).foregroundStyle(.tint)
                    .frame(width: 30, height: 30).background(.tint.opacity(0.16), in: Circle()).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 5) {
                    Text(name.isEmpty ? trainingText("Senza nome", "Unnamed") : name)
                        .font(.headline).lineLimit(2).multilineTextAlignment(.leading)
                    Text("\(WatchTraining.exercises(routine).count) " + trainingText("esercizi", "exercises"))
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.secondary).accessibilityHidden(true).padding(.top, 8)
            }.watchCard()
        }.buttonStyle(.plain)
    }
}

struct TrainingRoutineDetail: View {
    let routine: [String: Any]
    @ObservedObject private var model = TrainingViewModel.shared
    private var exercises: [[String: Any]] { WatchTraining.exercises(routine) }
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(routine["name"] as? String ?? "").font(.title3.weight(.bold)).fixedSize(horizontal: false, vertical: true)
                    Text("\(exercises.count) " + trainingText("esercizi", "exercises") + " · \(WatchTraining.orderedSets(routine).count) " + trainingText("serie", "sets"))
                        .font(.caption2).foregroundStyle(.secondary)
                }.watchCard()
                Button { model.start(routine) } label: {
                    Label(trainingText("Avvia", "Start"), systemImage: "play.fill").font(.headline).frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent).disabled(model.active != nil)
                ForEach(exercises.indices, id: \.self) { index in
                    let exercise = exercises[index]
                    VStack(alignment: .leading, spacing: 5) {
                        Text(exercise["name"] as? String ?? "").font(.headline).fixedSize(horizontal: false, vertical: true)
                        Text("\((exercise["sets"] as? [Any] ?? []).count) " + trainingText("serie", "sets"))
                            .font(.caption).foregroundStyle(.secondary)
                        if let notes = exercise["notes"] as? String, !QuillNoteDocument(notes).isEmpty { QuillNoteView(notes) }
                    }.watchCard()
                }
            }.padding(.horizontal, 8).padding(.bottom, 12)
        }.navigationTitle(trainingText("Routine", "Routine")).navigationBarTitleDisplayMode(.inline)
    }
}

struct TrainingQueueView: View {
    @ObservedObject private var model = TrainingViewModel.shared
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(model.pending.indices, id: \.self) { index in
                    let document = model.pending[index]
                    if document["ownerScope"] as? String == model.owner {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(document["name"] as? String ?? "").font(.headline)
                            if let time = document["time"] as? NSNumber { Text(Date(milliseconds: time.int64Value), style: .date).font(.caption).foregroundStyle(.secondary) }
                            Label(trainingText("In attesa di iPhone", "Waiting for iPhone"), systemImage: "arrow.triangle.2.circlepath").font(.caption2).foregroundStyle(.cyan)
                        }.watchCard(tint: .cyan)
                    }
                }
            }.padding(.horizontal, 8).padding(.bottom, 12)
        }.navigationTitle(trainingText("Sincronizzazione", "Sync")).navigationBarTitleDisplayMode(.inline)
    }
}

struct TrainingSessionActions: View {
    @EnvironmentObject private var workout: WorkoutViewModel
    private var accent: Color { workout.exerciseColor == 0 ? .accentColor : workout.exerciseColor.asARGBColor() }
    @ObservedObject private var model = TrainingViewModel.shared
    @State private var discard = false
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if let active = model.active {
                    let sets = WatchTraining.orderedSets(active)
                    let done = sets.filter { WatchTraining.set($0.set, in: active)?["done"] as? Bool == true }.count
                    VStack(alignment: .leading, spacing: 8) {
                        Text(active["name"] as? String ?? "").font(.headline)
                        Text("\(done) / \(sets.count) " + trainingText("serie", "sets")).font(.caption).monospacedDigit()
                        ProgressView(value: Double(done), total: Double(max(1, sets.count)))
                        Label(model.syncing ? trainingText("Sincronizzazione", "Syncing") : model.connected ? trainingText("Collegato a iPhone", "Connected to iPhone") : trainingText("Sul Watch", "On Watch"),
                              systemImage: model.syncing ? "arrow.triangle.2.circlepath" : model.connected ? "iphone" : "applewatch")
                            .font(.caption2).foregroundStyle(.secondary)
                    }.watchCard(tint: accent)
                    Button { model.finish(save: true) } label: { Label(trainingText("Termina", "Finish"), systemImage: "checkmark").frame(maxWidth: .infinity) }
                        .buttonStyle(.borderedProminent)
                    Button(role: .destructive) { discard = true } label: { Label(trainingText("Scarta", "Discard"), systemImage: "trash").frame(maxWidth: .infinity) }
                }
                if let error = model.error { Text(error).font(.caption).foregroundStyle(.orange).watchCard(tint: .orange) }
            }.padding(.horizontal, 8).padding(.bottom, 12)
        }
        .tint(accent)
        .navigationTitle(trainingText("Allenamento", "Workout"))
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(trainingText("Scartare l’allenamento?", "Discard workout?"), isPresented: $discard, titleVisibility: .visible) {
            Button(trainingText("Scarta", "Discard"), role: .destructive) { model.finish(save: false) }
            Button(trainingText("Annulla", "Cancel"), role: .cancel) {}
        }
    }
}
