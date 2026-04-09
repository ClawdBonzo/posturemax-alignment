import SwiftUI
import SwiftData

struct GamificationDashboardWidget: View {
    @Query var gamificationProfiles: [GamificationProfile]
    @Query var activeQuests: [Quest]

    var gamificationProfile: GamificationProfile? {
        gamificationProfiles.first
    }

    var body: some View {
        VStack(spacing: 16) {
            if let profile = gamificationProfile {
                // Level Progress Card
                LevelProgressCard(
                    currentLevel: profile.currentLevel,
                    levelName: profile.levelName,
                    currentXP: profile.currentLevelXP,
                    xpToNextLevel: profile.xpToNextLevel,
                    progressPercent: profile.xpProgressPercent
                )

                // Active Quests Section
                if !activeQuests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Daily Quests")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.pmText)
                            Spacer()
                            Text("\(activeQuests.filter { $0.isCompleted }.count)/\(activeQuests.count)")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.pmAccent)
                        }

                        VStack(spacing: 8) {
                            ForEach(activeQuests.prefix(2), id: \.id) { quest in
                                QuestCard(quest: quest, isCompleted: quest.isCompleted)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.pmCardBackground)
                    .cornerRadius(14)
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
