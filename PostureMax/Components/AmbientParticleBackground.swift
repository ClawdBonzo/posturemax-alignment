import SwiftUI

/// Metal-accelerated ambient neon particle background.
///
/// Performance characteristics:
/// - Uses `Canvas` + `TimelineView` → single Metal draw call per frame
/// - `.drawingGroup()` composites the canvas as one layer (no per-particle view overhead)
/// - Capped at 30 fps via `minimumInterval` — plenty smooth for a background
/// - Automatically disabled when `accessibilityReduceMotion` is on
/// - Automatically reduces particle count in Low Power Mode
///
/// Usage: Place at the bottom of any `ZStack` and mark it `.accessibilityHidden(true)`.
struct AmbientParticleBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Desired maximum particle count. Actual count respects Low Power Mode.
    var particleCount: Int = 18

    private var effectiveCount: Int {
        guard !reduceMotion else { return 0 }
        return ProcessInfo.processInfo.isLowPowerModeEnabled
            ? max(4, particleCount / 3)
            : particleCount
    }

    var body: some View {
        if effectiveCount == 0 {
            // No animation at all — accessibility first
            Color.clear
                .ignoresSafeArea()
                .accessibilityHidden(true)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
                Canvas { ctx, size in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    for i in 0..<effectiveCount {
                        drawParticle(into: &ctx, size: size, index: i, time: t)
                    }
                }
            }
            .drawingGroup()         // ← composites all particles as a single Metal texture
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    // MARK: - Per-particle drawing (fully deterministic — no random state needed)

    private func drawParticle(into ctx: inout GraphicsContext, size: CGSize, index: Int, time: Double) {
        // Deterministic position, speed, phase — seeded by index only
        let baseX    = CGFloat((index * 137 + 23) % 100) / 100.0 * size.width
        let baseY    = CGFloat((index *  97 + 61) % 100) / 100.0 * size.height
        let pSize    = CGFloat((index *  53 + 11) %   5) + 2.0
        let speed    = Double( (index *  41 + 17) %   5) + 4.0
        let phaseOff = Double( (index *  29 +  7) %  30) / 10.0

        // Animate: oscillate Y position and opacity with a sine wave
        let yOff    = sin((time / speed + phaseOff) * .pi) * 25.0
        let opacity = (sin((time / speed + phaseOff) * .pi) + 1.0) / 2.0 * 0.45 + 0.05

        let color: Color = switch index % 3 {
            case 0:  .pmPrimary
            case 1:  .pmGold
            default: .pmCyan
        }

        // Soft glow halo — large transparent ellipse (cheaper than blur)
        let glow = pSize * 4.5
        ctx.fill(
            Path(ellipseIn: CGRect(x: baseX - glow / 2, y: baseY + yOff - glow / 2, width: glow, height: glow)),
            with: .color(color.opacity(opacity * 0.18))
        )

        // Bright core dot
        ctx.fill(
            Path(ellipseIn: CGRect(x: baseX - pSize / 2, y: baseY + yOff - pSize / 2, width: pSize, height: pSize)),
            with: .color(color.opacity(opacity))
        )
    }
}
