import SwiftUI

// MARK: - Glow-Up Share Sheet

struct GlowUpShareView: View {
    let score:     Int
    let streak:    Int
    let level:     Int
    let levelName: String
    let userName:  String

    @Environment(\.dismiss) private var dismiss
    @State private var isGenerating = false
    @State private var shareImage:  UIImage? = nil
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color(red: 0.04, green: 0.06, blue: 0.12).ignoresSafeArea()
                AmbientParticleBackground(particleCount: 12)

                VStack(spacing: 24) {
                    Text("Share Your Glow-Up")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.pmPrimary, .pmGold], startPoint: .leading, endPoint: .trailing)
                        )
                        .neonGlow(radius: 8)

                    // Preview card
                    ShareTemplateCard(
                        score:     score,
                        streak:    streak,
                        level:     level,
                        levelName: levelName,
                        userName:  userName
                    )
                    .padding(.horizontal, 20)

                    // Share button
                    Button {
                        generateAndShare()
                    } label: {
                        HStack(spacing: 10) {
                            if isGenerating {
                                ProgressView().tint(.black).scaleEffect(0.8)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.subheadline.weight(.bold))
                            }
                            Text(isGenerating ? "Generating..." : "Share My Posture Glow-Up")
                                .font(.headline)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.pmPrimary, .pmGold, .pmCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .neonGlow(radius: 14)
                    }
                    .disabled(isGenerating)
                    .padding(.horizontal, 20)

                    Text("Watermarked with PostureMax branding")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(.top, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.pmPrimary)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ActivityViewController(activityItems: [img])
            }
        }
    }

    private func generateAndShare() {
        isGenerating = true
        // Render the template to UIImage using ImageRenderer
        let template = ShareTemplateCard(
            score:     score,
            streak:    streak,
            level:     level,
            levelName: levelName,
            userName:  userName
        )
        .frame(width: 390, height: 520) // Story dimensions

        Task { @MainActor in
            let renderer = ImageRenderer(content: template)
            renderer.scale = 3.0
            shareImage    = renderer.uiImage
            isGenerating  = false
            if shareImage != nil {
                showShareSheet = true
            }
        }
    }
}

// MARK: - Share Template Card

struct ShareTemplateCard: View {
    let score:     Int
    let streak:    Int
    let level:     Int
    let levelName: String
    let userName:  String

    @State private var shimmer: CGFloat = -300
    @State private var glowPulse = false

    var postureLabel: String {
        switch score {
        case 9...10: return "PERFECT"
        case 7...8:  return "EXCELLENT"
        case 5...6:  return "GOOD"
        default:     return "IMPROVING"
        }
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.04, blue: 0.10),
                    Color(red: 0.05, green: 0.10, blue: 0.18),
                    Color(red: 0.02, green: 0.04, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Ambient glow orbs
            Circle()
                .fill(Color.pmPrimary.opacity(0.15))
                .frame(width: 260, height: 260)
                .blur(radius: 50)
                .offset(x: -80, y: -120)
                .scaleEffect(glowPulse ? 1.1 : 0.9)

            Circle()
                .fill(Color.pmGold.opacity(0.10))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: 80, y: 120)
                .scaleEffect(glowPulse ? 0.9 : 1.1)

            // Neon border frame
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.pmPrimary, .pmGold, .pmCyan, .pmPrimary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .neonGlow(radius: 10)

            VStack(spacing: 20) {
                // Top branding
                HStack(spacing: 8) {
                    Image("BrandIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 7))

                    Text("PostureMax")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.pmPrimary, .pmGold], startPoint: .leading, endPoint: .trailing)
                        )
                        .neonGlow(radius: 6)

                    Spacer()

                    Text("My Posture Glow-Up")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Score ring (big)
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(Color.pmPrimary.opacity(0.15), lineWidth: 20)
                        .frame(width: 160, height: 160)
                        .blur(radius: 12)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: Double(score) / 10.0)
                        .stroke(
                            LinearGradient(
                                colors: [.pmPrimary, .pmGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 140, height: 140)
                        .neonGlow(radius: 12)

                    // Track ring
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 14)
                        .frame(width: 140, height: 140)

                    VStack(spacing: 2) {
                        Text("\(score)")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.pmPrimary, .pmGold], startPoint: .top, endPoint: .bottom)
                            )
                            .neonGlow(radius: 10)

                        Text("/10")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                // Posture label
                Text(postureLabel)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.pmPrimary, .pmGold, .pmCyan], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay(
                        LinearGradient(colors: [.clear, .white.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing)
                            .offset(x: shimmer)
                            .mask(
                                Text(postureLabel)
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                            )
                    )
                    .neonGlow(radius: 14)

                Text("POSTURE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .kerning(3)

                // Stats row
                HStack(spacing: 0) {
                    ShareStatPill(icon: "flame.fill",           value: "\(streak)", label: "Day Streak", color: .pmGold)
                    Divider().frame(height: 32).background(.white.opacity(0.15))
                    ShareStatPill(icon: "star.fill",            value: "LV \(level)", label: levelName,  color: .pmPrimary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 20)

                // User name
                if !userName.isEmpty {
                    Text("@\(userName.lowercased().replacingOccurrences(of: " ", with: ""))")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Spacer()

                // Watermark
                Text("Join me on PostureMax ↗")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.bottom, 16)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            runShimmer()
        }
    }

    private func runShimmer() {
        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
            shimmer = 300
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            shimmer = -300
            runShimmer()
        }
    }
}

private struct ShareStatPill: View {
    let icon:  String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(color)
                Text(value)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Activity View Controller

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
