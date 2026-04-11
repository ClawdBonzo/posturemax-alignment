import SwiftUI

struct OnboardingPhotoView: View {
    @Binding var selectedImage: UIImage?
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressBar(step: 3, total: 6)

            ScrollView {
                VStack(spacing: 24) {
                    // Onboarding-3 header illustration
                    Image("Onboarding-3")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.pmPrimary.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Color.pmPrimary.opacity(0.3), radius: 12)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)

                    VStack(spacing: 12) {
                        Text("Capture Your Starting Point")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        Text("Take a side-view photo to track your\nposture transformation over time")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }

                    PhotoPickerView(
                        selectedImage: $selectedImage,
                        label: "Upload Posture Photo"
                    )
                    .padding(.horizontal, 24)

                    // Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Photo Tips")
                            .font(.headline)
                            .foregroundStyle(.white)

                        PhotoTipRow(icon: "person.fill.viewfinder", text: "Stand naturally — don't try to correct")
                        PhotoTipRow(icon: "arrow.left.and.right", text: "Full body side view works best")
                        PhotoTipRow(icon: "light.max", text: "Good lighting, plain background")
                        PhotoTipRow(icon: "lock.fill", text: "Photos stay 100% on your device")
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }

            VStack(spacing: 12) {
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

                if selectedImage == nil {
                    Button("Skip for now") {
                        onContinue()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct PhotoTipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.pmPrimary)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}
