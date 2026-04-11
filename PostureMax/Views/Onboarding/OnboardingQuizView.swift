import SwiftUI

struct OnboardingQuizView: View {
    @Binding var painAreas: Set<String>
    @Binding var painFrequency: String
    @Binding var sittingHours: Int
    @Binding var postureRating: Int
    @Binding var goals: Set<String>
    let onContinue: () -> Void

    @State private var quizStep = 0

    private let painAreaOptions = [
        ("Neck", "figure.wave"),
        ("Upper Back", "figure.arms.open"),
        ("Lower Back", "figure.stand"),
        ("Shoulders", "figure.cooldown"),
        ("Hips", "figure.run"),
        ("Headaches", "brain.head.profile")
    ]

    private let frequencyOptions = ["Rarely", "Sometimes", "Often", "Daily", "Constant"]

    private let goalOptions = [
        ("Eliminate pain", "cross.circle"),
        ("Better posture", "figure.stand"),
        ("More flexibility", "figure.flexibility"),
        ("Prevent future issues", "shield.checkered"),
        ("Look more confident", "star.fill"),
        ("Sleep better", "moon.fill")
    ]

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressBar(step: 2, total: 6)

            // Onboarding-2 header illustration
            Image("Onboarding-2")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.pmPrimary.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.pmPrimary.opacity(0.3), radius: 10)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 60)
                .padding(.top, 8)

            TabView(selection: $quizStep) {
                // Pain Areas
                quizPage(
                    title: "Where does it hurt?",
                    subtitle: "Select all that apply"
                ) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(painAreaOptions, id: \.0) { area in
                            MultiSelectChip(
                                title: area.0,
                                icon: area.1,
                                isSelected: painAreas.contains(area.0)
                            ) {
                                if painAreas.contains(area.0) {
                                    painAreas.remove(area.0)
                                } else {
                                    painAreas.insert(area.0)
                                }
                            }
                        }
                    }
                }
                .tag(0)

                // Pain Frequency
                quizPage(
                    title: "How often do you feel pain?",
                    subtitle: "Be honest — this helps us calibrate"
                ) {
                    VStack(spacing: 10) {
                        ForEach(frequencyOptions, id: \.self) { freq in
                            SingleSelectRow(
                                title: freq,
                                isSelected: painFrequency.lowercased() == freq.lowercased()
                            ) {
                                painFrequency = freq.lowercased()
                            }
                        }
                    }
                }
                .tag(1)

                // Sitting Hours
                quizPage(
                    title: "Hours sitting per day?",
                    subtitle: "Include desk, driving, couch time"
                ) {
                    VStack(spacing: 20) {
                        Text("\(sittingHours) hours")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.pmPrimary, .pmGold], startPoint: .leading, endPoint: .trailing)
                            )
                            .neonGlow(radius: 8)

                        Slider(value: Binding(
                            get: { Double(sittingHours) },
                            set: { sittingHours = Int($0) }
                        ), in: 1...16, step: 1)
                        .tint(Color.pmPrimary)
                        .padding(.horizontal)

                        HStack {
                            Text("1 hr").font(.caption).foregroundStyle(.white.opacity(0.4))
                            Spacer()
                            Text("16 hrs").font(.caption).foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.horizontal)
                    }
                }
                .tag(2)

                // Posture Self-Rating
                quizPage(
                    title: "Rate your current posture",
                    subtitle: "1 = very poor, 10 = excellent"
                ) {
                    VStack(spacing: 20) {
                        ScoreRing(score: postureRating, maxScore: 10, size: 140)

                        Slider(value: Binding(
                            get: { Double(postureRating) },
                            set: { postureRating = Int($0) }
                        ), in: 1...10, step: 1)
                        .tint(Color.pmPrimary)
                        .padding(.horizontal)

                        HStack {
                            Text("Poor").font(.caption).foregroundStyle(.white.opacity(0.4))
                            Spacer()
                            Text("Excellent").font(.caption).foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.horizontal)
                    }
                }
                .tag(3)

                // Goals
                quizPage(
                    title: "What are your goals?",
                    subtitle: "Select all that matter to you"
                ) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(goalOptions, id: \.0) { goal in
                            MultiSelectChip(
                                title: goal.0,
                                icon: goal.1,
                                isSelected: goals.contains(goal.0)
                            ) {
                                if goals.contains(goal.0) {
                                    goals.remove(goal.0)
                                } else {
                                    goals.insert(goal.0)
                                }
                            }
                        }
                    }
                }
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: quizStep)

            VStack(spacing: 12) {
                Button {
                    if quizStep < 4 {
                        withAnimation { quizStep += 1 }
                    } else {
                        onContinue()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right")
                            .font(.subheadline.weight(.semibold))
                        Text(quizStep < 4 ? "Next" : "Continue")
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

                if quizStep > 0 {
                    Button("Back") {
                        withAnimation { quizStep -= 1 }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func quizPage<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                VStack(spacing: 8) {
                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                }

                content()
                    .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

struct MultiSelectChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.pmPrimary.opacity(0.2) : Color.white.opacity(0.06))
            .foregroundStyle(isSelected ? Color.pmPrimary : .white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.pmPrimary.opacity(0.7) : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: isSelected ? Color.pmPrimary.opacity(0.25) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
    }
}

struct SingleSelectRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.pmPrimary : .white.opacity(0.3))
            }
            .padding()
            .background(isSelected ? Color.pmPrimary.opacity(0.15) : Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pmPrimary.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
