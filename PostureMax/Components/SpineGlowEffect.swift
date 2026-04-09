import SwiftUI

/// Living spine visualization — glows brighter and emits light particles as intensity (0-1) rises.
struct SpineGlowEffect: View {
    let intensity: Double  // 0 = dim, 1 = blazing

    @State private var pulse       = false
    @State private var particleSeed: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Vertebra count
    private let segmentCount = 7

    // Color shifts: teal at low → gold at high
    private var spineColor: Color {
        let t = intensity
        return Color(
            red:   t,
            green: 0.85 - t * 0.1,
            blue:  1.0  - t * 0.6
        )
    }

    var body: some View {
        ZStack {
            // --- Ambient glow layers ---
            ForEach(0..<3, id: \.self) { layer in
                RoundedRectangle(cornerRadius: 12)
                    .fill(spineColor.opacity(0.06 * intensity * Double(3 - layer)))
                    .frame(width: 44 + CGFloat(layer) * 14, height: 140 + CGFloat(layer) * 10)
                    .blur(radius: CGFloat(layer + 1) * 4)
                    .scaleEffect(pulse ? 1.08 : 0.95)
            }

            // --- Vertebra segments ---
            VStack(spacing: 4) {
                ForEach(0..<segmentCount, id: \.self) { seg in
                    VertebraSegment(
                        index:     seg,
                        total:     segmentCount,
                        intensity: intensity,
                        pulse:     pulse
                    )
                }
            }
            .frame(width: 22)

            // --- Rising light particles (high intensity only) ---
            if intensity > 0.55 {
                SpineParticleField(intensity: intensity, seed: particleSeed)
                    .frame(width: 60, height: 160)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
            particleSeed = Int.random(in: 0...1000)
        }
        .onChange(of: intensity) { _, _ in
            guard !reduceMotion else { return }
            particleSeed = Int.random(in: 0...1000)
        }
        .accessibilityLabel("Spine alignment: \(Int(intensity * 100))%")
        .accessibilityHidden(reduceMotion)
    }
}

// MARK: - Vertebra Segment

private struct VertebraSegment: View {
    let index:     Int
    let total:     Int
    let intensity: Double
    let pulse:     Bool

    private var segmentIntensity: Double {
        // Top segments glow at lower thresholds (intensity flows bottom-up metaphor)
        let threshold = Double(total - 1 - index) / Double(total)
        return max(0, min(1, (intensity - threshold * 0.3) * 2.5))
    }

    private var fillColors: [Color] {
        let t = segmentIntensity
        return [
            Color(red: t * 0.2, green: 0.85 + t * 0.15, blue: 1.0 - t * 0.55),
            Color(red: t,       green: 0.85 - t * 0.1,  blue: 1.0 - t * 0.65)
        ]
    }

    var body: some View {
        ZStack {
            // Inner glow
            RoundedRectangle(cornerRadius: 5)
                .fill(fillColors[0].opacity(0.35 * segmentIntensity))
                .blur(radius: 4)
                .frame(height: 13)
                .scaleEffect(x: 1.8, y: 1.0)

            // Segment body
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: fillColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 13)
                // Small scale pulse on each segment with offset delay
                .scaleEffect(pulse ? (1.0 + segmentIntensity * 0.05) : 1.0)
                .animation(
                    .easeInOut(duration: 1.8).delay(Double(index) * 0.12).repeatForever(autoreverses: true),
                    value: pulse
                )
        }
    }
}

// MARK: - Rising Particle Field

private struct SpineParticleField: View {
    let intensity: Double
    let seed:      Int

    private var particles: [SpineParticle] {
        let count = Int(intensity * 10)
        return (0..<count).map { i in
            let x:        CGFloat = CGFloat((i * 73 + seed) % 60) / 60
            let duration: Double  = Double((i * 41 + seed) % 8) / 10 + 0.8
            let size:     CGFloat = CGFloat((i * 37 + seed) % 4) + 2
            let delay:    Double  = Double((i * 29 + seed) % 20) / 10
            let color:    Color   = i % 2 == 0 ? Color.pmPrimary : Color.pmGold
            return SpineParticle(x: x, duration: duration, size: size, delay: delay, color: color)
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    RisingParticle(particle: p, height: geo.size.height)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct SpineParticle: Identifiable {
    let id       = UUID()
    let x:        CGFloat
    let duration: Double
    let size:     CGFloat
    let delay:    Double
    let color:    Color
}

private struct RisingParticle: View {
    let particle: SpineParticle
    let height:   CGFloat
    @State private var risen = false

    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .blur(radius: particle.size * 0.3)
            .opacity(risen ? 0 : 0.9)
            .offset(
                x: (particle.x - 0.5) * 60,
                y: risen ? -height * 0.8 : 0
            )
            .onAppear { startRise() }
    }

    private func startRise() {
        risen = false
        withAnimation(.easeOut(duration: particle.duration).delay(particle.delay)) {
            risen = true
        }
        // loop
        DispatchQueue.main.asyncAfter(deadline: .now() + particle.delay + particle.duration + 0.1) {
            risen = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                startRise()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 32) {
        ForEach([0.1, 0.5, 0.85, 1.0], id: \.self) { v in
            VStack(spacing: 10) {
                SpineGlowEffect(intensity: v)
                Text(String(format: "%.0f%%", v * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    .padding(32)
    .background(Color.black)
}
