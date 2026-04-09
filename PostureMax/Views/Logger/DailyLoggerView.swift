import SwiftUI
import SwiftData

struct DailyLoggerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Query private var streaks: [StreakRecord]

    @State private var postureRating: Int = 5
    @State private var painLevel: Int = 3
    @State private var neckAlignment: Int = 5
    @State private var shoulderBalance: Int = 5
    @State private var spineAlignment: Int = 5
    @State private var hipAlignment: Int = 5
    @State private var overallMobility: Int = 5
    @State private var notes: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var completedChecklist: Set<String> = []

    private var profile: UserProfile? { profiles.first }
    private var streak: StreakRecord { streaks.first ?? StreakRecord() }

    private let checklistItems = [
        "Took stretch breaks every 30 min",
        "Used ergonomic desk setup",
        "Completed morning routine",
        "Completed evening routine",
        "Practiced posture awareness",
        "Kept shoulders back & down",
        "Took a walk",
        "Foam rolled / self-massage"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Posture Rating
                    ratingSection(title: "Overall Posture", value: $postureRating, icon: "figure.stand")

                    // Pain Level
                    ratingSection(title: "Pain Level", value: $painLevel, icon: "bolt.fill", inverted: true)

                    Divider().padding(.horizontal)

                    // Trait Ratings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Alignment Details")
                            .font(.headline)
                            .padding(.horizontal)

                        traitSlider("Neck Alignment", value: $neckAlignment, icon: "figure.wave")
                        traitSlider("Shoulder Balance", value: $shoulderBalance, icon: "figure.arms.open")
                        traitSlider("Spine Alignment", value: $spineAlignment, icon: "figure.stand")
                        traitSlider("Hip Alignment", value: $hipAlignment, icon: "figure.run")
                        traitSlider("Overall Mobility", value: $overallMobility, icon: "figure.flexibility")
                    }

                    Divider().padding(.horizontal)

                    // Checklist
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Checklist")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(checklistItems, id: \.self) { item in
                            Button {
                                if completedChecklist.contains(item) {
                                    completedChecklist.remove(item)
                                } else {
                                    completedChecklist.insert(item)
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: completedChecklist.contains(item) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(completedChecklist.contains(item) ? Color.pmSuccess : .secondary)
                                    Text(item)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Divider().padding(.horizontal)

                    // Photo
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress Photo")
                            .font(.headline)
                            .padding(.horizontal)

                        PhotoPickerView(
                            selectedImage: $selectedImage,
                            label: "Add Today's Photo"
                        )
                        .padding(.horizontal)
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                            .padding(.horizontal)

                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color.pmCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }

                    // Save Button
                    PMButton(title: "Save Log", icon: "checkmark.circle.fill") {
                        saveLog()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .navigationTitle("Daily Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func ratingSection(title: String, value: Binding<Int>, icon: String, inverted: Bool = false) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.pmPrimary)
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(value.wrappedValue)/10")
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(ratingColor(value.wrappedValue, inverted: inverted))
            }
            .padding(.horizontal)

            Slider(value: Binding(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Int($0) }
            ), in: 0...10, step: 1)
            .tint(ratingColor(value.wrappedValue, inverted: inverted))
            .padding(.horizontal)
        }
    }

    private func traitSlider(_ title: String, value: Binding<Int>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.pmPrimary)
                .frame(width: 20)

            Text(title)
                .font(.subheadline)
                .frame(width: 110, alignment: .leading)

            Slider(value: Binding(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Int($0) }
            ), in: 0...10, step: 1)
            .tint(Color.pmPrimary)

            Text("\(value.wrappedValue)")
                .font(.subheadline.weight(.bold).monospacedDigit())
                .frame(width: 24)
        }
        .padding(.horizontal)
    }

    private func ratingColor(_ value: Int, inverted: Bool = false) -> Color {
        let effective = inverted ? 10 - value : value
        switch effective {
        case 0...3: return .pmDanger
        case 4...5: return .pmWarning
        case 6...7: return .pmAccent
        default: return .pmSuccess
        }
    }

    private func saveLog() {
        var photoId: UUID? = nil
        if let image = selectedImage {
            if let photo = PhotoStorageService.savePhoto(image: image, category: "progress", context: modelContext) {
                photoId = photo.id
            }
        }

        let log = DailyLog(
            postureRating: postureRating,
            painLevel: painLevel,
            notes: notes,
            completedChecklist: Array(completedChecklist),
            photoId: photoId,
            neckAlignment: neckAlignment,
            shoulderBalance: shoulderBalance,
            spineAlignment: spineAlignment,
            hipAlignment: hipAlignment,
            overallMobility: overallMobility
        )

        modelContext.insert(log)
        StreakService.updateStreak(context: modelContext)

        // Check for streak milestones and trigger haptics
        let updatedStreak = StreakService.getCurrentStreak(context: modelContext)
        let streakMilestones = [7, 14, 30, 60, 90, 365]
        if streakMilestones.contains(updatedStreak.currentStreak) {
            HapticService.shared.playStreakMilestoneHaptic()
        }

        // Award XP for log
        if let userProfile = profile {
            GamificationService.shared.awardXPForLog(
                context: modelContext,
                userProfileId: userProfile.id,
                posture: postureRating,
                pain: painLevel,
                streak: updatedStreak.currentStreak
            )

            QuestService.shared.updateQuestProgress(context: modelContext, questType: .logTimes, increment: 1)

            HapticService.shared.playLogHaptic()
        }

        try? modelContext.save()
        dismiss()
    }
}
