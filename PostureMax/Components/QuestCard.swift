import SwiftUI

struct QuestCard: View {
    let quest: Quest
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Quest Icon
                VStack {
                    Image(systemName: questIcon)
                        .font(.title2)
                        .foregroundColor(.pmPrimary)
                }
                .frame(width: 44, height: 44)
                .background(Color.pmPrimary.opacity(0.1))
                .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.displayTitle)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.pmText)
                    Text(quest.type.description)
                        .font(.caption)
                        .foregroundColor(.pmSecondaryText)
                        .lineLimit(2)
                }

                Spacer()

                // XP Badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("+\(quest.xpReward)")
                        .font(.caption.weight(.semibold))
                }
                .padding(8)
                .background(Color.pmAccent.opacity(0.15))
                .foregroundColor(.pmAccent)
                .cornerRadius(8)
            }

            // Progress Bar
            if quest.targetValue > 1 {
                VStack(spacing: 6) {
                    HStack {
                        Text("Progress")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.pmSecondaryText)

                        Spacer()

                        Text("\(quest.currentProgress) / \(quest.targetValue)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.pmPrimary)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.pmPrimary.opacity(0.1))

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.pmSuccess)
                                .frame(width: geometry.size.width * min(quest.progressPercent, 1.0))
                                .animation(.easeInOut(duration: 0.3), value: quest.progressPercent)
                        }
                    }
                    .frame(height: 8)
                }
            }

            // Completion Status
            if isCompleted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.pmSuccess)
                    Text("Completed")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.pmSuccess)
                    Spacer()
                    if let completedDate = quest.completedDate {
                        Text(completedDate.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.pmSecondaryText)
                    }
                }
                .padding(8)
                .background(Color.pmSuccess.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color.pmCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isCompleted ? Color.pmSuccess.opacity(0.3) : Color.pmPrimary.opacity(0.15),
                    lineWidth: 1
                )
        )
    }

    private var questIcon: String {
        switch quest.type {
        case .logTimes:
            return "checkmark.circle.fill"
        case .achievePerfectScore:
            return "star.fill"
        case .completeRoutine:
            return "dumbbell.fill"
        case .usePhotoTracking:
            return "camera.fill"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        QuestCard(
            quest: Quest(type: .logTimes, targetValue: 5, xpReward: 150),
            isCompleted: false
        )
        QuestCard(
            quest: {
                let q = Quest(type: .completeRoutine, targetValue: 1, xpReward: 100)
                q.currentProgress = 1
                q.completedDate = Date()
                return q
            }(),
            isCompleted: true
        )
    }
    .padding()
    .background(Color.pmBackground)
}
