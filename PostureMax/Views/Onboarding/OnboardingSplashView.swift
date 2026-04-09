import SwiftUI

struct OnboardingSplashView: View {
    let onContinue: () -> Void

    // Staggered entrance states
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showFeatures = false
    @State private var showButton = false

    // Continuous animation states
    @State private var pulseRings = false
    @State private var rotateGlow = false
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        ZStack {
            // Animated background gradient
            LinearGradient(
                colors: [
                    Color.pmPrimary.opacity(0.03),
                    Color.clear,
                    Color.pmSecondary.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating particles
            FloatingParticlesView()
                .opacity(showIcon ? 0.6 : 0)
                .animation(.easeIn(duration: 2), value: showIcon)

            VStack(spacing: 0) {
                Spacer()

                // Hero section
                VStack(spacing: 28) {
                    // Animated icon with orbital rings
                    ZStack {
                        // Outer pulse ring 3
                        Circle()
                            .stroke(Color.pmPrimary.opacity(0.06), lineWidth: 1)
                            .frame(width: 260, height: 260)
                            .scaleEffect(pulseRings ? 1.1 : 0.9)

                        // Outer pulse ring 2
                        Circle()
                            .stroke(Color.pmPrimary.opacity(0.1), lineWidth: 1.5)
                            .frame(width: 200, height: 200)
                            .scaleEffect(pulseRings ? 1.05 : 0.95)

                        // Glow ring
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Color.pmPrimary.opacity(0.3),
                                        Color.pmSecondary.opacity(0.1),
                                        Color.pmPrimary.opacity(0.0),
                                        Color.pmPrimary.opacity(0.3)
                                    ]),
                                    center: .center
                                )
                            )
                            .frame(width: 170, height: 170)
                            .rotationEffect(.degrees(rotateGlow ? 360 : 0))
                            .blur(radius: 8)

                        // Inner glow
                        Circle()
                            .fill(Color.pmPrimary.opacity(0.12))
                            .frame(width: 150, height: 150)

                        // Brand icon
                        Image("BrandIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: Color.pmPrimary.opacity(0.5), radius: 20)
                    }
                    .scaleEffect(showIcon ? 1.0 : 0.3)
                    .opacity(showIcon ? 1 : 0)

                    // Title with shimmer
                    VStack(spacing: 10) {
                        Text("PostureMax")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.pmGradient)
                            .overlay(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.4), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .offset(x: shimmerOffset)
                                .mask(
                                    Text("PostureMax")
                                        .font(.system(size: 42, weight: .bold, design: .rounded))
                                )
                            )
                            .scaleEffect(showTitle ? 1.0 : 0.8)
                            .opacity(showTitle ? 1 : 0)

                        Text("Start Your Pain-Free Life")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.secondary)
                            .opacity(showSubtitle ? 1 : 0)
                            .offset(y: showSubtitle ? 0 : 10)
                    }

                    // Feature pills
                    HStack(spacing: 8) {
                        FeaturePill(icon: "figure.stand", text: "Track")
                        FeaturePill(icon: "chart.line.uptrend.xyaxis", text: "Improve")
                        FeaturePill(icon: "trophy.fill", text: "Achieve")
                    }
                    .opacity(showFeatures ? 1 : 0)
                    .offset(y: showFeatures ? 0 : 15)
                }

                Spacer()

                // CTA section
                VStack(spacing: 14) {
                    PMButton(title: "Begin Your Journey", icon: "arrow.right") {
                        onContinue()
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "lock.shield.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.pmPrimary.opacity(0.5))
                        Text("Your data stays 100% on your device")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
            }
        }
        .onAppear {
            runEntranceSequence()
            startContinuousAnimations()
        }
    }

    // MARK: - Entrance Animation Sequence
    private func runEntranceSequence() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            showIcon = true
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
            showTitle = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            showSubtitle = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
            showFeatures = true
        }

        withAnimation(.easeOut(duration: 0.6).delay(1.3)) {
            showButton = true
        }
    }

    // MARK: - Continuous Animations
    private func startContinuousAnimations() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            pulseRings = true
        }

        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            rotateGlow = true
        }

        // Shimmer loop
        runShimmer()
    }

    private func runShimmer() {
        withAnimation(.easeInOut(duration: 1.5).delay(2)) {
            shimmerOffset = 200
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            shimmerOffset = -200
            runShimmer()
        }
    }
}

// MARK: - Feature Pill

struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(Color.pmPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.pmPrimary.opacity(0.08))
        .clipShape(Capsule())
    }
}

// MARK: - Floating Particles

struct FloatingParticlesView: View {
    @State private var particles: [Particle] = (0..<15).map { _ in Particle() }

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat = CGFloat.random(in: 0...1)
        var y: CGFloat = CGFloat.random(in: 0...1)
        var size: CGFloat = CGFloat.random(in: 2...5)
        var opacity: Double = Double.random(in: 0.1...0.4)
        var duration: Double = Double.random(in: 4...8)
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                ParticleView(particle: particle, geoSize: geo.size)
            }
        }
    }
}

struct ParticleView: View {
    let particle: FloatingParticlesView.Particle
    let geoSize: CGSize
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(Color.pmPrimary)
            .frame(width: particle.size, height: particle.size)
            .opacity(isAnimating ? particle.opacity : 0)
            .position(
                x: geoSize.width * particle.x,
                y: isAnimating
                    ? geoSize.height * CGFloat.random(in: 0.1...0.4)
                    : geoSize.height * particle.y
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: particle.duration)
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...2))
                ) {
                    isAnimating = true
                }
            }
    }
}
