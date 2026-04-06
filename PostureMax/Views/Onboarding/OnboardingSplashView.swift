import SwiftUI

struct OnboardingSplashView: View {
    let onContinue: () -> Void
    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.pmPrimary.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .scaleEffect(animate ? 1.1 : 1.0)

                    Circle()
                        .fill(Color.pmPrimary.opacity(0.08))
                        .frame(width: 220, height: 220)
                        .scaleEffect(animate ? 1.15 : 1.0)

                    Image(systemName: "figure.stand")
                        .font(.system(size: 70, weight: .light))
                        .foregroundStyle(Color.pmPrimary)
                        .scaleEffect(animate ? 1.05 : 0.95)
                }
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)

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
