import SwiftUI

struct StreakFlame: View {
    let streak: Int
    let isPulsing: Bool = true

    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.pmAccent.opacity(0.4),
                                Color.pmAccent.opacity(0.1),
                                Color.pmAccent.opacity(0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)

                // Flame icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.pmAccent)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
            }
            .frame(width: 80, height: 80)

            // Streak count
            Text("\(streak)")
                .font(.title2.weight(.bold))
                .foregroundColor(.pmText)

            // Multiplier display
            Text(String(format: "%.1fx", min(1.0 + Double(streak) / 10.0, 5.0)))
                .font(.caption.weight(.semibold))
                .foregroundColor(.pmAccent)
        }
        .onAppear {
            guard isPulsing, !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Streak: \(streak) days, \(String(format: "%.1f", min(1.0 + Double(streak) / 10.0, 5.0)))x XP multiplier")
    }
}

#Preview {
    HStack(spacing: 40) {
        StreakFlame(streak: 1)
        StreakFlame(streak: 7)
        StreakFlame(streak: 30)
    }
    .padding()
    .background(Color.pmBackground)
}
