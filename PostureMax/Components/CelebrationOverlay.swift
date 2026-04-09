import SwiftUI

// MARK: - Celebration Overlay
// Full-screen celebration with light beams + particle burst.
// Usage: .overlay(CelebrationOverlay(isShowing: $showCelebration, title: "LEVEL UP!"))

struct CelebrationOverlay: View {
    @Binding var isShowing: Bool
    var title: String      = "LEVEL UP!"
    var subtitle: String   = "You're becoming stronger"

    @State private var particles:   [CelebParticle] = []
    @State private var titleScale:  CGFloat = 0.2
    @State private var titleOpacity: Double = 0
    @State private var bgOpacity:   Double = 0
    @State private var beamScale:   CGFloat = 0
    @State private var iconScale:   CGFloat = 0.3

    var body: some View {
        ZStack {
            // Dark scrim
            Color.black.opacity(bgOpacity * 0.72)
                .ignoresSafeArea()
                .allowsHitTesting(true) // swallow taps during celebration

            // Light beams radiating upward
            ZStack {
                ForEach(0..<16, id: \.self) { i in
                    LightBeamShape(angle: Double(i) * 22.5)
                        .opacity(beamScale * 0.6)
                }
            }
            .scaleEffect(beamScale)

            // Particle burst
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                ForEach(particles) { p in
                    CelebParticleView(particle: p, center: center)
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Title card
            VStack(spacing: 16) {
                // Sparkle icon
                Image(systemName: "sparkles")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pmPrimary, .pmGold, .pmCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .neonGlow(radius: 24)
                    .scaleEffect(iconScale)

                Text(title)
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pmPrimary, .pmGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .neonGlow(radius: 20)

                Text(subtitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .scaleEffect(titleScale)
            .opacity(titleOpacity)
        }
        .onChange(of: isShowing) { _, newValue in
            if newValue { play() }
        }
    }

    private func play() {
        particles = CelebParticle.generate(count: 60)

        withAnimation(.easeOut(duration: 0.25)) {
            bgOpacity = 1
        }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
            beamScale  = 1
            titleScale = 1.0
            titleOpacity = 1
            iconScale  = 1.0
        }

        // Dismiss after 2.2 s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeIn(duration: 0.4)) {
                bgOpacity    = 0
                beamScale    = 1.5
                titleOpacity = 0
                titleScale   = 1.3
                iconScale    = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                isShowing    = false
                particles    = []
                titleScale   = 0.2
                iconScale    = 0.3
                beamScale    = 0
            }
        }
    }
}

// MARK: - Light Beam

private struct LightBeamShape: View {
    let angle: Double
    @State private var flicker: Bool = false

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .pmGold.opacity(0.5), .pmPrimary.opacity(0.6), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: 4, height: 420)
            .offset(y: -210)
            .rotationEffect(.degrees(angle))
            .blur(radius: 3)
            .opacity(flicker ? 0.85 : 0.4)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 0.3...0.7))
                    .repeatForever(autoreverses: true)
                ) {
                    flicker = true
                }
            }
    }
}

// MARK: - Celebration Particle

private struct CelebParticle: Identifiable {
    let id    = UUID()
    let angle:    Double
    let distance: CGFloat
    let size:     CGFloat
    let color:    Color
    let delay:    Double

    static func generate(count: Int) -> [CelebParticle] {
        let colors: [Color] = [.pmPrimary, .pmGold, .pmCyan, .white, .yellow]
        return (0..<count).map { i in
            CelebParticle(
                angle:    Double(i) * (360.0 / Double(count)) + Double.random(in: -15...15),
                distance: CGFloat.random(in: 100...320),
                size:     CGFloat.random(in: 4...14),
                color:    colors[i % colors.count],
                delay:    Double.random(in: 0...0.4)
            )
        }
    }
}

private struct CelebParticleView: View {
    let particle: CelebParticle
    let center:   CGPoint
    @State private var launched = false

    private var dest: CGPoint {
        let rad = particle.angle * .pi / 180
        return CGPoint(
            x: center.x + cos(rad) * particle.distance,
            y: center.y + sin(rad) * particle.distance
        )
    }

    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .shadow(color: particle.color.opacity(0.9), radius: particle.size * 0.8)
            .position(launched ? dest : center)
            .opacity(launched ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).delay(particle.delay)) {
                    launched = true
                }
            }
    }
}
