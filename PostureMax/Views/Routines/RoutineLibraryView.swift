import SwiftUI
import SwiftData

struct RoutineLibraryView: View {
    @Query(sort: \RoutineItem.category) private var routines: [RoutineItem]
    @State private var selectedCategory: String? = nil
    @State private var selectedRoutine: RoutineItem?
    @State private var searchText = ""
    @State private var showUpgradeSheet = false

    private var isPro: Bool { PurchaseManager.shared.isPro }
    private let freeRoutineLimit = 2

    private var categories: [String] {
        Array(Set(routines.map(\.category))).sorted()
    }

    private var filteredRoutines: [RoutineItem] {
        var result = routines
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.routineDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(categories, id: \.self) { cat in
                            CategoryChip(title: cat, isSelected: selectedCategory == cat) {
                                selectedCategory = selectedCategory == cat ? nil : cat
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // Routines list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(filteredRoutines.enumerated()), id: \.element.id) { index, routine in
                            let isLocked = !isPro && index >= freeRoutineLimit
                            Button {
                                if isLocked {
                                    showUpgradeSheet = true
                                } else {
                                    selectedRoutine = routine
                                }
                            } label: {
                                RoutineCard(routine: routine)
                                    .overlay {
                                        if isLocked {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(.ultraThinMaterial.opacity(0.8))
                                                HStack(spacing: 6) {
                                                    Image(systemName: "lock.fill")
                                                        .font(.caption)
                                                    Text("Pro")
                                                        .font(.caption.weight(.bold))
                                                }
                                                .foregroundStyle(Color.pmGold)
                                            }
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.pmGroupedBackground)
            .navigationTitle("Routines")
            .searchable(text: $searchText, prompt: "Search routines")
            .sheet(item: $selectedRoutine) { routine in
                RoutineDetailView(routine: routine)
            }
            .sheet(isPresented: $showUpgradeSheet) {
                ContextualPaywallSheet(
                    feature: "All Routines",
                    icon: "dumbbell.fill",
                    description: "Unlock the full library of \(routines.count)+ exercises, stretches, and mobility routines."
                )
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.pmPrimary : Color.pmCardBackground)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct RoutineCard: View {
    let routine: RoutineItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: routine.iconName)
                .font(.title2)
                .foregroundStyle(Color.pmPrimary)
                .frame(width: 44, height: 44)
                .background(Color.pmPrimary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label("\(routine.durationMinutes) min", systemImage: "clock")
                    Text("·")
                    Text(routine.difficulty.capitalized)
                    Text("·")
                    Text(routine.category)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color.pmCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct RoutineDetailView: View {
    let routine: RoutineItem
    @Environment(\.dismiss) private var dismiss
    @State private var completedSteps: Set<Int> = []
    @State private var timerSeconds = 0
    @State private var isTimerRunning = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: routine.iconName)
                            .font(.system(size: 44))
                            .foregroundStyle(Color.pmPrimary)
                            .frame(width: 80, height: 80)
                            .background(Color.pmPrimary.opacity(0.1))
                            .clipShape(Circle())

                        Text(routine.name)
                            .font(.title2.weight(.bold))

                        HStack(spacing: 16) {
                            Label("\(routine.durationMinutes) min", systemImage: "clock")
                            Label(routine.difficulty.capitalized, systemImage: "speedometer")
                            Label(routine.category, systemImage: "tag")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        if !routine.routineDescription.isEmpty {
                            Text(routine.routineDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }

                    // Timer
                    VStack(spacing: 8) {
                        Text(formatTime(timerSeconds))
                            .font(.system(size: 40, weight: .light, design: .monospaced))

                        HStack(spacing: 16) {
                            Button {
                                isTimerRunning.toggle()
                            } label: {
                                Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.pmPrimary)
                            }

                            Button {
                                timerSeconds = 0
                                isTimerRunning = false
                            } label: {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.pmCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)

                    // Steps
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Steps")
                                .font(.headline)
                            Spacer()
                            Text("\(completedSteps.count)/\(routine.steps.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        ForEach(Array(routine.steps.enumerated()), id: \.offset) { index, step in
                            Button {
                                if completedSteps.contains(index) {
                                    completedSteps.remove(index)
                                } else {
                                    completedSteps.insert(index)
                                }
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: completedSteps.contains(index) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(completedSteps.contains(index) ? Color.pmSuccess : .secondary)
                                        .font(.title3)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Step \(index + 1)")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                        Text(step)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                            .strikethrough(completedSteps.contains(index))
                                    }

                                    Spacer()
                                }
                                .padding(12)
                                .background(completedSteps.contains(index) ? Color.pmSuccess.opacity(0.08) : Color.pmCardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)

                    // Target areas
                    if !routine.targetAreas.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Areas")
                                .font(.headline)
                            HStack {
                                ForEach(routine.targetAreas, id: \.self) { area in
                                    Text(area.capitalized)
                                        .font(.caption.weight(.medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.pmPrimary.opacity(0.1))
                                        .foregroundStyle(Color.pmPrimary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                if isTimerRunning {
                    timerSeconds += 1
                }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
