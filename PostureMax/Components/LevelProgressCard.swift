import SwiftUI

struct LevelProgressCard: View {
    let currentLevel: Int
    let levelName: String
    let currentXP: Int
    let xpToNextLevel: Int
    let progressPercent: Double

    var body: some View {
        VStack(spacing: 12) {
            // Level Badge and Name
            HStack(spacing: 12) {
                // Animated Level Circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.pmPrimary, Color.pmSecondary]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    VStack(spacing: 2) {
                        Text("LV")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                        Text("\(currentLevel)")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(levelName)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.pmText)
                    Text("Level \(currentLevel) of 50")
                        .font(.caption)
                        .foregroundColor(.pmSecondaryText)
                }

                Spacer()
            }

            // XP Progress Bar with Animation
            VStack(spacing: 6) {
                HStack {
                    Text("Experience")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.pmText)

                    Spacer()

                    Text("\(currentXP) / \(xpToNextLevel)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.pmAccent)
                }

                // Animated Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.pmPrimary.opacity(0.1))

                        // Progress Fill
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.pmPrimary, Color.pmAccent]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressPercent)
                    }
                    .frame(height: 12)
                    .animation(.easeInOut(duration: 0.5), value: progressPercent)
                }
                .frame(height: 12)
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

#Preview {
    LevelProgressCard(
        currentLevel: 5,
        levelName: "Slouch Guard",
        currentXP: 250,
        xpToNextLevel: 460,
        progressPercent: 0.54
    )
    .padding()
    .background(Color.pmBackground)
}
