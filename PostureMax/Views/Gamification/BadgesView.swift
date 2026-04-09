import SwiftUI
import SwiftData

struct BadgesView: View {
    @Query var badges: [Badge]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var unlockedBadges: [Badge] {
        badges.filter { $0.isUnlocked }.sorted { ($0.unlockedDate ?? Date()) > ($1.unlockedDate ?? Date()) }
    }

    var lockedBadges: [Badge] {
        badges.filter { !$0.isUnlocked }
    }

    var body: some View {
        ZStack {
            Color.pmBackground.ignoresSafeArea()
            AmbientParticleBackground(particleCount: 10)

            VStack(spacing: 24) {
                // Stats row
                HStack(spacing: 16) {
                    NeonStatBadge(title: "Unlocked", value: "\(unlockedBadges.count)", color: .pmSuccess)
                    Spacer()
                    NeonStatBadge(title: "Total",    value: "\(badges.count)",         color: .pmPrimary)
                }
                .padding(.horizontal)

                // Unlocked badges
                if !unlockedBadges.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Unlocked")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.pmText)

                            if !reduceMotion {
                                Image(systemName: "sparkles")
                                    .font(.caption)
                                    .foregroundStyle(Color.pmGold)
                                    .goldGlow(radius: 4)
                                    .accessibilityHidden(true)
                            }
                        }
                        .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(unlockedBadges, id: \.id) { badge in
                                    VStack(spacing: 8) {
                                        BadgeDisplay(badge: badge, size: .medium)
                                            .shadow(
                                                color: Color.pmPrimary.opacity(reduceMotion ? 0 : 0.35),
                                                radius: 10
                                            )

                                        if let date = badge.unlockedDate {
                                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption2)
                                                .foregroundStyle(Color.pmSecondaryText)
                                        }
                                    }
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel(badgeAccessibilityLabel(badge))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .accessibilityLabel("Unlocked badges")
                    }
                }

                // Locked badges
                if !lockedBadges.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Locked")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.pmText)
                            .padding(.horizontal)

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: 3),
                            spacing: 16
                        ) {
                            ForEach(lockedBadges, id: \.id) { badge in
                                BadgeDisplay(badge: badge, size: .small)
                                    .accessibilityLabel("\(badge.displayName) badge, locked")
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func badgeAccessibilityLabel(_ badge: Badge) -> String {
        var label = "\(badge.displayName) badge, unlocked"
        if let date = badge.unlockedDate {
            label += ", earned \(date.formatted(date: .abbreviated, time: .omitted))"
        }
        return label
    }
}

// MARK: - Neon Stat Badge (replaces StatBadge, adds glow)

struct NeonStatBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
                .neonGlow(color: color, radius: 6)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.pmSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.pmCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// Keep legacy StatBadge name as alias for any callers that still use it
typealias StatBadge = NeonStatBadge

#Preview {
    NavigationStack {
        BadgesView()
            .modelContainer(for: [Badge.self], inMemory: true)
    }
}
