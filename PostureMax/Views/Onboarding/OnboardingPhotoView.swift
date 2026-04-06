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
                        .padding(.horizontal, 40)
                        .padding(.top, 10)

                    VStack(spacing: 12) {
                        Text("Capture Your Starting Point")
                            .font(.title2.weight(.bold))

                        Text("Take a side-view photo to track your\nposture transformation over time")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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

                        PhotoTipRow(icon: "person.fill.viewfinder", text: "Stand naturally — don't try to correct")
                        PhotoTipRow(icon: "arrow.left.and.right", text: "Full body side view works best")
                        PhotoTipRow(icon: "light.max", text: "Good lighting, plain background")
                        PhotoTipRow(icon: "lock.fill", text: "Photos stay 100% on your device")
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }

            VStack(spacing: 12) {
                PMButton(title: "Continue", icon: "arrow.right") {
                    onContinue()
                }

                if selectedImage == nil {
                    Button("Skip for now") {
                        onContinue()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                .foregroundStyle(.secondary)
        }
    }
}
