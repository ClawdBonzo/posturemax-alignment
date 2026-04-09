import SwiftUI
import SwiftData

struct GamificationDashboardWidget: View {
    @Query var gamificationProfiles: [GamificationProfile]
    @Query(filter: #Predicate<Quest> { !$0.isWeekly }) var dailyQuests: [Quest]

    var gamificationProfile: GamificationProfile? { gamificationProfiles.first }

    var incompleteDaily: [Quest] { dailyQuests.filter { !$0.isCompleted } }
    var completedCount:  Int     { dailyQuests.filter { $0.isCompleted }.count }

    var body: some View {
        VStack(spacing: 16) {
            if let profile = gamificationProfile {
                // Level Progress Card
                LevelProgressCard(
                    currentLevel:    profile.currentLevel,
                    levelName:       profile.levelName,
                    currentXP:       profile.currentLevelXP,
                    xpToNextLevel:   profile.xpToNextLevel,
                    progressPercent: profile.xpProgressPercent
                )

                // Active Quests Section
                if !dailyQuests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Daily Quests")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.pmText)
                            Spacer()
                            Text("\(completedCount)/\(dailyQuests.count)")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.pmAccent)
                        }

                        VStack(spacing: 8) {
                            ForEach(incompleteDaily.prefix(2), id: \.id) { quest in
                                QuestCard(quest: quest, isCompleted: false)
                            }
                            if incompleteDaily.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.pmSuccess)
                                    Text("All daily quests complete!")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.pmSuccess)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.pmCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.pmPrimary.opacity(0.15), lineWidth: 1)
                    )
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.pmBackground.ignoresSafeArea()

        VStack {
            GamificationDashboardWidget()
                .padding()
            Spacer()
        }
    }
    .modelContainer(for: [GamificationProfile.self, Quest.self, Badge.self], inMemory: true)
}
