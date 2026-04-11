import SwiftUI

// MARK: - Pro Gate Overlay
// Shows a blur + lock + upgrade prompt over gated features.
// Contextual: tells the user exactly what they're unlocking.

struct ProGateOverlay: View {
    let feature: String
    let icon: String
    @State private var showPaywall = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            // Blur the content behind
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            // Dark scrim
            Color.black.opacity(0.3)

            // Lock card
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.pmPrimary.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .blur(radius: 10)
                        .scaleEffect(glowPulse ? 1.15 : 0.95)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(colors: [.pmPrimary, .pmGold], startPoint: .top, endPoint: .bottom)
                        )
                }

                VStack(spacing: 6) {
                    Text("Unlock \(feature)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Upgrade to Pro for full access")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Button {
                    showPaywall = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.subheadline.weight(.semibold))
                        Text("Start Free Trial")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: 260)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.pmPrimary, .pmGold.opacity(0.8), .pmCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.pmPrimary.opacity(0.5), radius: 12, y: 4)
                }
            }
            .padding(32)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
        .sheet(isPresented: $showPaywall) {
            OnboardingPaywallView {
                showPaywall = false
            }
        }
    }
}

// MARK: - View Modifier for easy gating

struct ProGatedModifier: ViewModifier {
    let feature: String
    let icon: String
    var isPro: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .allowsHitTesting(isPro)

            if !isPro {
                ProGateOverlay(feature: feature, icon: icon)
            }
        }
    }
}

extension View {
    /// Gates this view behind a Pro subscription with a contextual paywall.
    func proGated(feature: String, icon: String = "sparkles", isPro: Bool) -> some View {
        modifier(ProGatedModifier(feature: feature, icon: icon, isPro: isPro))
    }
}

// MARK: - Contextual Paywall Sheet
// Lighter-weight: shows as a bottom sheet with a single feature callout.

struct ContextualPaywallSheet: View {
    let feature: String
    let icon: String
    let description: String
    @Environment(\.dismiss) private var dismiss
    @State private var showFullPaywall = false

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            // Feature icon
            ZStack {
                Circle()
                    .fill(Color.pmPrimary.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .blur(radius: 8)

                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(colors: [.pmPrimary, .pmGold], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .neonGlow(radius: 10)
            }

            VStack(spacing: 8) {
                Text(feature)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                showFullPaywall = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lock.open.fill")
                        .font(.subheadline.weight(.semibold))
                    Text("Start Free Trial")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.pmPrimary, .pmGold.opacity(0.8), .pmCyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.pmPrimary.opacity(0.5), radius: 14, y: 6)
            }
            .padding(.horizontal, 24)

            Button("Not now") {
                dismiss()
            }
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.35))
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.16),
                    Color(red: 0.03, green: 0.05, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .presentationDetents([.height(380)])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $showFullPaywall) {
            OnboardingPaywallView {
                showFullPaywall = false
                dismiss()
            }
        }
    }
}
