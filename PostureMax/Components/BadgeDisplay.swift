import SwiftUI

struct BadgeDisplay: View {
    let badge: Badge
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 80
            case .large: return 100
            }
        }

        var iconSize: Font {
            switch self {
            case .small: return .title3
            case .medium: return .title
            case .large: return .system(size: 40)
            }
        }

        var nameFont: Font {
            switch self {
            case .small: return .caption
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // Badge Circle
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ?
                        AnyShapeStyle(LinearGradient(
                            gradient: Gradient(colors: [.pmPrimary, .pmAccent]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )) :
                        AnyShapeStyle(Color.gray.opacity(0.3)))
                    .frame(width: size.dimension, height: size.dimension)

                if badge.isUnlocked {
                    Circle()
                        .stroke(Color.pmAccent.opacity(0.3), lineWidth: 2)
                        .frame(width: size.dimension, height: size.dimension)
                }

                Image(systemName: badge.iconName)
                    .font(size.iconSize.weight(.semibold))
                    .foregroundColor(badge.isUnlocked ? .white : .gray)
            }
            .opacity(badge.isUnlocked ? 1.0 : 0.6)

            // Badge Name
            Text(badge.displayName)
                .font(size.nameFont.weight(.semibold))
                .foregroundColor(.pmText)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Unlock Date or Locked
            if let unlockedDate = badge.unlockedDate {
                Text(unlockedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.pmSuccess)
            } else {
                Text("Locked")
                    .font(.caption2)
                    .foregroundColor(.pmSecondaryText)
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        VStack(spacing: 16) {
            BadgeDisplay(
                badge: {
                    let b = Badge(badgeType: .firstLog)
                    b.unlockedDate = Date()
                    return b
                }(),
                size: .small
            )

            BadgeDisplay(
                badge: Badge(badgeType: .sevenDayStreak),
                size: .small
            )
        }

        VStack(spacing: 16) {
            BadgeDisplay(
                badge: {
                    let b = Badge(badgeType: .level10)
                    b.unlockedDate = Date()
                    return b
                }(),
                size: .medium
            )

            BadgeDisplay(
                badge: Badge(badgeType: .thirtyDayStreak),
                size: .medium
            )
        }

        VStack(spacing: 16) {
            BadgeDisplay(
                badge: {
                    let b = Badge(badgeType: .level50)
                    b.unlockedDate = Date()
                    return b
                }(),
                size: .large
            )
        }
    }
    .padding()
    .background(Color.pmBackground)
}
