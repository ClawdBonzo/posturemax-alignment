import SwiftUI

struct OnboardingLoadingView: View {
    let name: String
    let onComplete: () -> Void

    @State private var progress1: CGFloat = 0
    @State private var progress2: CGFloat = 0
    @State private var progress3: CGFloat = 0
    @State private var progress4: CGFloat = 0
    @State private var showCheckmark = false

    private let steps = [
        ("Analyzing your posture profile", "figure.stand"),
        ("Selecting alignment exercises", "figure.flexibility"),
        ("Calibrating daily targets", "target"),
        ("Finalizing your 30-day plan", "calendar.badge.checkmark")
    ]

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressBar(step: 5, total: 6)

            Spacer()

            VStack(spacing: 32) {
                if showCheckmark {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(Color.pmSuccess)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color.pmPrimary)
                }

                VStack(spacing: 8) {
                    Text(showCheckmark ? "Your Plan is Ready!" : "Building your 30-day\nAlignment Plan")
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)

                    if !showCheckmark {
                        Text("for \(name)")
                            .font(.title3)
                            .foregroundStyle(Color.pmPrimary)
                    }
                }

                VStack(spacing: 16) {
                    LoadingProgressRow(title: steps[0].0, icon: steps[0].1, progress: progress1)
                    LoadingProgressRow(title: steps[1].0, icon: steps[1].1, progress: progress2)
                    LoadingProgressRow(title: steps[2].0, icon: steps[2].1, progress: progress3)
                    LoadingProgressRow(title: steps[3].0, icon: steps[3].1, progress: progress4)
                }
                .padding(.horizontal, 32)
            }

            Spacer()
        }
        .task {
            await runLoading()
        }
    }

    private func runLoading() async {
        // Staggered progress animations
        withAnimation(.easeOut(duration: 1.0)) { progress1 = 1.0 }
        try? await Task.sleep(for: .seconds(0.8))

        withAnimation(.easeOut(duration: 1.2)) { progress2 = 1.0 }
        try? await Task.sleep(for: .seconds(1.0))

        withAnimation(.easeOut(duration: 1.0)) { progress3 = 1.0 }
        try? await Task.sleep(for: .seconds(0.8))

        withAnimation(.easeOut(duration: 0.8)) { progress4 = 1.0 }
        try? await Task.sleep(for: .seconds(0.6))

        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            showCheckmark = true
        }
        try? await Task.sleep(for: .seconds(1.0))

        onComplete()
    }
}

struct LoadingProgressRow: View {
    let title: String
    let icon: String
    let progress: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(progress >= 1 ? Color.pmSuccess : .secondary)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(progress >= 1 ? .primary : .secondary)

                Spacer()

                if progress >= 1 {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.pmSuccess)
                        .transition(.scale)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.pmPrimary.opacity(0.15))

                    Capsule()
                        .fill(Color.pmPrimary)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)
        }
    }
}
