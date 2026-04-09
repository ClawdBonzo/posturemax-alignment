import SwiftUI
import SwiftData

struct BadgesView: View {
    @Query var badges: [Badge]

    var unlockedBadges: [Badge] {
        badges.filter { $0.isUnlocked }.sorted { ($0.unlockedDate ?? Date()) > ($1.unlockedDate ?? Date()) }
    }

    var lockedBadges: [Badge] {
        badges.filter { !$0.isUnlocked }
    }

    var body: some View {
        ZStack {
            Color.pmBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                // Stats
                HStack(spacing: 16) {
                    StatBadge(
                        title: "Unlocked",
                        value: "\(unlockedBadges.count)",
                        color: .pmSuccess
                    )

                    Spacer()

                    StatBadge(
                        title: "Total",
                        value: "\(badges.count)",
                        color: .pmPrimary
                    )
                }
                .padding(.horizontal)

                // Unlocked Badges
                if !unlockedBadges.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unlocked")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.pmText)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(unlockedBadges, id: \.id) { badge in
                                    VStack(spacing: 8) {
                                        BadgeDisplay(badge: badge, size: .medium)
                                        if let date = badge.unlockedDate {
                                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption2)
                                                .foregroundColor(.pmSecondaryText)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Locked Badges
                if !lockedBadges.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Locked")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.pmText)
                            .padding(.horizontal)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                            ForEach(lockedBadges, id: \.id) { badge in
                                BadgeDisplay(badge: badge, size: .small)
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
}

// MARK: - Helper Component

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(color)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.pmSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.pmCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        BadgesView()
            .modelContainer(for: [Badge.self], inMemory: true)
    }
}
