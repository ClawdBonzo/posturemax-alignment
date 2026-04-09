import SwiftUI
import SwiftData

struct LevelsView: View {
    @Query var gamificationProfiles: [GamificationProfile]

    var gamificationProfile: GamificationProfile? { gamificationProfiles.first }

    var body: some View {
        ZStack {
            Color.pmBackground.ignoresSafeArea()
            AmbientParticleBackground(particleCount: 12)

            VStack(spacing: 24) {
                if let profile = gamificationProfile {
                    // Current Level Card — neon upgraded
                    NeonLevelProgressCard(profile: profile)
                        .padding(.horizontal)

                    // Level Progression Grid
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Progression")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.pmText)

                            Spacer()

                            Text("\(profile.currentLevel) / 50")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.pmPrimary)
                                .neonGlow(radius: 4)
                        }
                        .padding(.horizontal)

                        ScrollView {
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5),
                                spacing: 10
                            ) {
                                ForEach(1...50, id: \.self) { level in
                                    NeonLevelCell(
                                        level:       level,
                                        isCompleted: level <= profile.currentLevel,
                                        isCurrent:   level == profile.currentLevel
                                    )
                                }
                            }
                            .padding()
                        }
                    }

                    Spacer()

                } else {
                    VStack(spacing: 14) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.pmPrimary)
                            .neonGlow(radius: 12)

                        Text("No Gamification Profile")
                            .font(.headline)
                            .foregroundStyle(Color.pmSecondaryText)

                        Text("Start logging posture to begin your journey!")
                            .font(.caption)
                            .foregroundStyle(Color.pmSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Levels")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Neon Level Progress Card

private struct NeonLevelProgressCard: View {
    let profile: GamificationProfile
    @State private var glowPulse = false
    @State private var xpProgress: Double = 0

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                // Level badge with neon gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.pmPrimary, .pmGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.pmPrimary.opacity(glowPulse ? 0.8 : 0.4), radius: glowPulse ? 18 : 10)

                    VStack(spacing: 1) {
                        Text("LV")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                        Text("\(profile.currentLevel)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.levelName)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.pmPrimary, .pmGold], startPoint: .leading, endPoint: .trailing)
                        )
                        .neonGlow(radius: 6)

                    Text("Level \(profile.currentLevel) of 50")
                        .font(.caption)
                        .foregroundStyle(Color.pmSecondaryText)
                }

                Spacer()
            }

            // XP Progress Bar
            VStack(spacing: 6) {
                HStack {
                    Text("Experience")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.pmText)
                    Spacer()
                    Text("\(profile.currentLevelXP) / \(profile.xpToNextLevel) XP")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.pmGold)
                        .goldGlow(radius: 4)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.pmPrimary.opacity(0.1))

                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.pmPrimary, .pmGold, .pmCyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * xpProgress)
                            .shadow(color: Color.pmPrimary.opacity(0.5), radius: 6)
                    }
                    .frame(height: 12)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(height: 12)
                .animation(.easeInOut(duration: 0.8), value: xpProgress)
            }
        }
        .padding(16)
        .background(Color.pmCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.pmPrimary.opacity(0.5), Color.pmGold.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.pmPrimary.opacity(0.12), radius: 12)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                xpProgress = profile.xpProgressPercent
            }
        }
        .onChange(of: profile.xpProgressPercent) { _, new in
            withAnimation(.easeInOut(duration: 0.6)) {
                xpProgress = new
            }
        }
    }
}

// MARK: - Neon Level Cell

private struct NeonLevelCell: View {
    let level:       Int
    let isCompleted: Bool
    let isCurrent:   Bool

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isCurrent {
                    Circle()
                        .fill(Color.pmPrimary.opacity(0.2))
                        .scaleEffect(pulse ? 1.25 : 1.0)
                        .blur(radius: 4)
                }

                Circle()
                    .fill(
                        isCompleted
                            ? AnyShapeStyle(LinearGradient(
                                colors: isCurrent ? [.pmPrimary, .pmGold] : [.pmPrimary.opacity(0.7), .pmCyan.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              ))
                            : AnyShapeStyle(Color.gray.opacity(0.15))
                    )
                    .shadow(
                        color: isCurrent ? Color.pmPrimary.opacity(0.7) : .clear,
                        radius: pulse ? 10 : 6
                    )

                Text("\(level)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isCompleted ? .white : Color.gray.opacity(0.5))
            }
            .aspectRatio(1, contentMode: .fit)

            Text(GamificationProfile.getLevelName(for: level))
                .font(.system(size: 7, weight: .medium))
                .foregroundStyle(isCompleted ? Color.pmSecondaryText : Color.gray.opacity(0.4))
                .lineLimit(1)
        }
        .onAppear {
            if isCurrent {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LevelsView()
            .modelContainer(for: [GamificationProfile.self], inMemory: true)
    }
}
