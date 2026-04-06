import SwiftUI

struct OnboardingRoutinesView: View {
    @Binding var selectedIds: Set<String>
    let onContinue: () -> Void

    private let categories = ["Desk Setup", "Stretches", "Strengthening", "Mobility", "Breathing", "Breaks"]

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressBar(step: 4, total: 6)

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    VStack(spacing: 8) {
                        Text("Build Your Routine")
                            .font(.title2.weight(.bold))
                        Text("Select the routines you'd like in your plan")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(categories, id: \.self) { category in
                        let routines = RoutineDataService.defaultRoutines.filter { $0.category == category }
                        if !routines.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(category)
                                    .font(.headline)
                                    .padding(.horizontal, 24)

                                ForEach(routines, id: \.name) { routine in
                                    RoutineSelectRow(
                                        name: routine.name,
                                        duration: routine.duration,
                                        icon: routine.icon,
                                        difficulty: routine.difficulty,
                                        isSelected: selectedIds.contains(routine.name)
                                    ) {
                                        if selectedIds.contains(routine.name) {
                                            selectedIds.remove(routine.name)
                                        } else {
                                            selectedIds.insert(routine.name)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 20)
                }
            }

            VStack(spacing: 8) {
                PMButton(
                    title: "Continue (\(selectedIds.count) selected)",
                    icon: "arrow.right"
                ) {
                    onContinue()
                }
                .disabled(selectedIds.isEmpty)
                .opacity(selectedIds.isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct RoutineSelectRow: View {
    let name: String
    let duration: Int
    let icon: String
    let difficulty: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.pmPrimary : .secondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline.weight(.medium))
                    HStack(spacing: 6) {
                        Text("\(duration) min")
                        Text("·")
                        Text(difficulty.capitalized)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.pmPrimary : Color(.tertiaryLabel))
            }
            .padding(14)
            .background(isSelected ? Color.pmPrimary.opacity(0.08) : Color.pmCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pmPrimary.opacity(0.3) : .clear, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
