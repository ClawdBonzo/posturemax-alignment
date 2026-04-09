import SwiftUI

struct ScoreRing: View {
    let score:     Int
    let maxScore:  Int
    var size:      CGFloat = 100
    var lineWidth: CGFloat = 10
    var label:     String? = nil

    @State private var glowPulse = false

    private var progress: Double {
        Double(score) / Double(maxScore)
    }

    private var ringColors: [Color] {
        switch progress {
        case 0..<0.3:  return [.pmDanger,  .pmDanger]
        case 0.3..<0.6: return [.pmWarning, .pmWarning]
        case 0.6..<0.8: return [.pmGold,    .pmCyan]
        default:        return [.pmPrimary, .pmGold]     // neon teal → gold for high scores
        }
    }

    private var glowColor: Color {
        switch progress {
        case 0..<0.3:  return .pmDanger
        case 0.3..<0.6: return .pmWarning
        case 0.6..<0.8: return .pmGold
        default:        return .pmPrimary
        }
    }

    private var glowRadius: CGFloat {
        progress >= 0.8 ? (glowPulse ? 18 : 10) : 0
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Track ring
                Circle()
                    .stroke(glowColor.opacity(0.12), lineWidth: lineWidth)

                // Outer ambient glow ring (high scores only)
                if progress >= 0.8 {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(glowColor.opacity(glowPulse ? 0.25 : 0.12), lineWidth: lineWidth + 6)
                        .rotationEffect(.degrees(-90))
                        .blur(radius: 6)
                }

                // Progress ring with gradient
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: ringColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: glowColor.opacity(progress >= 0.6 ? 0.7 : 0), radius: glowRadius * 0.5)
                    .shadow(color: glowColor.opacity(progress >= 0.6 ? 0.35 : 0), radius: glowRadius)
                    .animation(.easeInOut(duration: 0.8), value: progress)

                // Score label
                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            progress >= 0.8
                                ? AnyShapeStyle(LinearGradient(colors: [.pmPrimary, .pmGold], startPoint: .top, endPoint: .bottom))
                                : AnyShapeStyle(Color.pmText)
                        )
                        .shadow(color: glowColor.opacity(progress >= 0.8 ? 0.6 : 0), radius: 8)

                    Text("/\(maxScore)")
                        .font(.system(size: size * 0.12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.pmSecondaryText)
                }
            }
            .frame(width: size, height: size)
            .onAppear {
                if progress >= 0.8 {
                    withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                        glowPulse = true
                    }
                }
            }

            if let label {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.pmSecondaryText)
            }
        }
    }
}
