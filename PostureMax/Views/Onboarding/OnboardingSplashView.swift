import SwiftUI

struct OnboardingSplashView: View {
    let onContinue: () -> Void
    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    // Teal glow rings
                    Circle()
                        .fill(Color.pmPrimary.opacity(0.15))
                        .frame(width: 180, height: 180)
                        .scaleEffect(animate ? 1.1 : 1.0)

                    Circle()
                        .fill(Color.pmPrimary.opacity(0.08))
                        .frame(width: 240, height: 240)
                        .scaleEffect(animate ? 1.15 : 1.0)

                    // Brand icon instead of SF Symbol
                    Image("BrandIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .shadow(color: Color.pmPrimary.opacity(0.35), radius: 16)
                        .scaleEffect(animate ? 1.05 : 0.95)
                }
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)

                // Onboarding-1 illustration
                Image("Onboarding-1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 40)

                VStack(spacing: 12) {
                    Text("PostureMax")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.pmGradient)

                    Text("Start Your Pain-Free Life")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                PMButton(title: "Begin Your Journey", icon: "arrow.right") {
                    onContinue()
                }

                Text("Your data stays 100% on your device")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear { animate = true }
    }
}
