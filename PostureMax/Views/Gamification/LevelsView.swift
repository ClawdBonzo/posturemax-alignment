import SwiftUI
import SwiftData

struct LevelsView: View {
    @Query var gamificationProfiles: [GamificationProfile]

    var gamificationProfile: GamificationProfile? {
        gamificationProfiles.first
    }

    var body: some View {
        ZStack {
            Color.pmBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                if let profile = gamificationProfile {
                    // Current Level Card
                    LevelProgressCard(
                        currentLevel: profile.currentLevel,
                        levelName: profile.levelName,
                        currentXP: profile.currentLevelXP,
                        xpToNextLevel: profile.xpToNextLevel,
                        progressPercent: profile.xpProgressPercent
                    )
                    .padding(.horizontal)

                    // Level Progression Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progression")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.pmText)
                            .padding(.horizontal)

                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                                ForEach(1...50, id: \.self) { level in
                                    VStack(spacing: 4) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    level <= profile.currentLevel ?
                                                    AnyShapeStyle(LinearGradient(
                                                        gradient: Gradient(colors: [.pmPrimary, .pmAccent]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )) :
                                                    AnyShapeStyle(Color.gray.opacity(0.2))
                                                )

                                            Text("\(level)")
                                                .font(.caption.weight(.bold))
                                                .foregroundColor(level <= profile.currentLevel ? .white : .gray)
                                        }
                                        .aspectRatio(1, contentMode: .fit)

                                        Text(GamificationProfile.getLevelName(for: level))
                                            .font(.caption2)
                                            .foregroundColor(.pmSecondaryText)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .padding()
                        }
                    }

                    Spacer()
                } else {
                    VStack(spacing: 12) {
                        Text("No Gamification Profile")
                            .font(.headline)
                            .foregroundColor(.pmSecondaryText)
                        Text("Start logging posture to begin your journey!")
                            .font(.caption)
                            .foregroundColor(.pmSecondaryText)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Levels")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LevelsView()
            .modelContainer(for: [GamificationProfile.self], inMemory: true)
    }
}
