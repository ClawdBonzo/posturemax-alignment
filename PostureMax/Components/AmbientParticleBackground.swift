import SwiftUI

/// Subtle animated neon particles for every screen background.
/// Drop inside a ZStack at the bottom layer.
struct AmbientParticleBackground: View {
    var particleCount: Int = 18
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { i in
                    AmbientParticle(index: i, geoSize: geo.size)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct AmbientParticle: View {
    let index: Int
    let geoSize: CGSize

    // Stable random values seeded by index
    private var startX:   CGFloat { CGFloat((index * 137 + 23) % 100) / 100 }
    private var startY:   CGFloat { CGFloat((index * 97  + 61) % 100) / 100 }
    private var size:     CGFloat { CGFloat((index * 53  + 11) % 5)   + 2 }
    private var duration: Double  { Double((index * 41  + 17) % 5)    + 4 }
    private var delay:    Double  { Double((index * 29  + 7)  % 30)   / 10 }

    private var color: Color {
        switch index % 4 {
        case 0: return .pmPrimary
        case 1: return .pmGold
        case 2: return .pmCyan
        default: return .pmPrimary
        }
    }

    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: size * 0.6)
            .opacity(isAnimating ? 0.55 : 0.08)
            .position(
                x: geoSize.width  * startX,
                y: isAnimating
                    ? geoSize.height * startY - 50
                    : geoSize.height * startY
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    isAnimating = true
                }
            }
    }
}
