import SwiftUI

struct SpineGlowEffect: View {
    let intensity: Double  // 0-1 range based on XP progress or streak

    @State private var isGlowing = false

    var body: some View {
        ZStack {
            // Glow layers
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.pmPrimary.opacity(0.1 * intensity * Double(3 - index) / 3))
                    .frame(width: 40 + CGFloat(index) * 10, height: 120)
                    .blur(radius: CGFloat(index) * 2)
                    .scaleEffect(isGlowing ? 1.1 : 1.0)
            }

            // Spine visualization
            VStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.pmPrimary.opacity(0.5 + intensity * 0.5),
                                    Color.pmAccent.opacity(0.3 + intensity * 0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 12)
                }
            }
            .frame(width: 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }
}

#Preview {
    HStack(spacing: 40) {
        VStack(spacing: 8) {
            SpineGlowEffect(intensity: 0.2)
            Text("Low")
                .font(.caption)
                .foregroundColor(.pmSecondaryText)
        }

        VStack(spacing: 8) {
            SpineGlowEffect(intensity: 0.5)
            Text("Medium")
                .font(.caption)
                .foregroundColor(.pmSecondaryText)
        }

        VStack(spacing: 8) {
            SpineGlowEffect(intensity: 1.0)
            Text("High")
                .font(.caption)
                .foregroundColor(.pmSecondaryText)
        }
    }
    .padding()
    .background(Color.pmBackground)
}
