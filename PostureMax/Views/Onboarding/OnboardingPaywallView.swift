import SwiftUI

struct OnboardingPaywallView: View {
    let onContinue: () -> Void
    @State private var selectedPlan = 1 // 0=weekly, 1=annual, 2=monthly

    private let plans: [(title: String, price: String, period: String, badge: String?, perWeek: String)] = [
        ("Weekly", "$4.99", "/week", nil, "$4.99"),
        ("Annual", "$39.99", "/year", "BEST VALUE", "$0.77"),
        ("Monthly", "$9.99", "/month", nil, "$2.50")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Close / Skip
                HStack {
                    Spacer()
                    Button("Restore") {
                        // RevenueCat restore
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Hero transformation teaser
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        TransformationCard(
                            title: "Before",
                            icon: "figure.stand",
                            color: .pmDanger,
                            rotation: -5
                        )
                        Image(systemName: "arrow.right")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.pmPrimary)
                        TransformationCard(
                            title: "After 30 Days",
                            icon: "figure.stand",
                            color: .pmSuccess,
                            rotation: 0
                        )
                    }

                    Text("Unlock Your\nPosture Transformation")
                        .font(.title.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text("Join thousands who eliminated back pain\nwith personalized alignment plans")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    PaywallFeatureRow(icon: "calendar", text: "Personalized 30-day alignment plan")
                    PaywallFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed posture analytics")
                    PaywallFeatureRow(icon: "camera.fill", text: "Progress photo comparisons")
                    PaywallFeatureRow(icon: "figure.flexibility", text: "Full routine library")
                    PaywallFeatureRow(icon: "doc.richtext", text: "PDF progress reports")
                    PaywallFeatureRow(icon: "bell.fill", text: "Smart posture reminders")
                }
                .padding(.horizontal, 32)

                // Plans
                VStack(spacing: 10) {
                    ForEach(0..<plans.count, id: \.self) { index in
                        PlanCard(
                            title: plans[index].title,
                            price: plans[index].price,
                            period: plans[index].period,
                            badge: plans[index].badge,
                            perWeek: plans[index].perWeek,
                            isSelected: selectedPlan == index
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPlan = index
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Trial info
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .foregroundStyle(Color.pmPrimary)
                        Text("3-DAY FREE TRIAL")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.pmPrimary)
                    }
                    Text("Cancel anytime. No charge during trial.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // CTA
                VStack(spacing: 12) {
                    PMButton(title: "Start Free Trial", icon: "lock.open.fill") {
                        // RevenueCat purchase will go here
                        onContinue()
                    }

                    Button("Continue with limited access") {
                        onContinue()
                    }
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 24)

                // Legal
                HStack(spacing: 16) {
                    Button("Terms") {}
                        .font(.caption2)
                        .foregroundStyle(.quaternary)
                    Button("Privacy") {}
                        .font(.caption2)
                        .foregroundStyle(.quaternary)
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct TransformationCard: View {
    let title: String
    let icon: String
    let color: Color
    let rotation: Double

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(color)
                .rotationEffect(.degrees(rotation))
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
        }
        .frame(width: 120, height: 110)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PaywallFeatureRow: View {
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
        }
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    let badge: String?
    let perWeek: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.pmAccent)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text("\(price)\(period)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(perWeek)
                        .font(.headline)
                    Text("/week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.pmPrimary : .secondary)
                    .padding(.leading, 8)
            }
            .padding(16)
            .background(isSelected ? Color.pmPrimary.opacity(0.08) : Color.pmCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.pmPrimary : .clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}
