import SwiftUI

struct OnboardingNameView: View {
    @Binding var name: String
    let onContinue: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Progress
            OnboardingProgressBar(step: 1, total: 6)

            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)

                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.pmPrimary)

                        Text("What should we call\nyour pain-free self?")
                            .font(.title2.weight(.bold))
                            .multilineTextAlignment(.center)

                        Text("We'll personalize your alignment plan")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    TextField("Your name", text: $name)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.pmCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .focused($isFocused)
                        .padding(.horizontal, 24)

                    Spacer()
                }
            }

            VStack {
                PMButton(title: "Continue", icon: "arrow.right") {
                    onContinue()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear { isFocused = true }
    }
}

struct OnboardingProgressBar: View {
    let step: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...total, id: \.self) { index in
                Capsule()
                    .fill(index <= step ? Color.pmPrimary : Color.pmPrimary.opacity(0.2))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}
