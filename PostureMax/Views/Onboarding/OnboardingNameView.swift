import SwiftUI

struct OnboardingNameView: View {
    @Binding var name: String
    let onContinue: () -> Void
    @FocusState private var isFocused: Bool

    @State private var glowPulse = false

    var body: some View {
        ZStack {
            // Dark background matching splash
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.14),
                    Color(red: 0.02, green: 0.04, blue: 0.10),
                    Color(red: 0.04, green: 0.08, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient glow orbs
            Circle()
                .fill(Color.pmPrimary.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 50)
                .offset(x: -60, y: -120)
                .scaleEffect(glowPulse ? 1.08 : 0.95)

            Circle()
                .fill(Color.pmGold.opacity(0.06))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: 80, y: 180)
                .scaleEffect(glowPulse ? 0.95 : 1.08)

            VStack(spacing: 0) {
                // Progress
                OnboardingProgressBar(step: 1, total: 6)

                ScrollView {
                    VStack(spacing: 24) {
                        // Onboarding-1 header illustration
                        ZStack {
                            Circle()
                                .fill(Color.pmPrimary.opacity(0.15))
                                .frame(width: 200, height: 200)
                                .blur(radius: 25)

                            Image("Onboarding-1")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.pmPrimary.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.pmPrimary.opacity(0.4), radius: 16)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .padding(.top, 20)

                        VStack(spacing: 12) {
                            Text("What should we call\nyour pain-free self?")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)

                            Text("We'll personalize your alignment plan")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        TextField("Your name", text: $name)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.pmPrimary.opacity(0.3), lineWidth: 1)
                            )
                            .focused($isFocused)
                            .padding(.horizontal, 24)
                            .tint(Color.pmPrimary)

                        Spacer()
                    }
                }

                VStack {
                    Button {
                        onContinue()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right")
                                .font(.subheadline.weight(.semibold))
                            Text("Continue")
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
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isFocused = true
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

struct OnboardingProgressBar: View {
    let step: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...total, id: \.self) { index in
                Capsule()
                    .fill(
                        index <= step
                            ? AnyShapeStyle(LinearGradient(colors: [.pmPrimary, .pmCyan], startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Color.white.opacity(0.12))
                    )
                    .frame(height: 4)
                    .shadow(color: index <= step ? Color.pmPrimary.opacity(0.5) : .clear, radius: 3)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}
