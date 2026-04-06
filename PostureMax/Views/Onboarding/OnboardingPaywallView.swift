import SwiftUI
import RevenueCat

struct OnboardingPaywallView: View {
    let onContinue: () -> Void

    @State private var purchaseManager = PurchaseManager.shared
    @State private var selectedPlanIndex = 1 // default to monthly (BEST VALUE)
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorText = ""
    @State private var showRestoreSuccess = false

    // Fallback static plans used when RevenueCat offerings haven't loaded
    private struct PlanInfo: Identifiable {
        let id: Int
        let title: String
        let price: String
        let period: String
        let badge: String?
        let perWeek: String
        let trialText: String?
        var package: Package?
    }

    private var plans: [PlanInfo] {
        let offering = purchaseManager.currentOffering
        return [
            PlanInfo(
                id: 0,
                title: "Weekly",
                price: offering?.package(identifier: "$rc_weekly")?.storeProduct.localizedPriceString ?? "$4.99",
                period: "/week",
                badge: nil,
                perWeek: offering?.package(identifier: "$rc_weekly")?.storeProduct.localizedPriceString ?? "$4.99",
                trialText: nil,
                package: offering?.package(identifier: "$rc_weekly")
            ),
            PlanInfo(
                id: 1,
                title: "Monthly",
                price: offering?.package(identifier: "$rc_monthly")?.storeProduct.localizedPriceString ?? "$9.99",
                period: "/month",
                badge: "BEST VALUE",
                perWeek: "$2.50",
                trialText: "3-day free trial",
                package: offering?.package(identifier: "$rc_monthly")
            ),
            PlanInfo(
                id: 2,
                title: "Yearly",
                price: offering?.package(identifier: "$rc_annual")?.storeProduct.localizedPriceString ?? "$49.99",
                period: "/year",
                badge: "SAVE 58%",
                perWeek: "$0.96",
                trialText: nil,
                package: offering?.package(identifier: "$rc_annual")
            ),
            PlanInfo(
                id: 3,
                title: "Lifetime",
                price: offering?.package(identifier: "$rc_lifetime")?.storeProduct.localizedPriceString ?? "$79.99",
                period: " once",
                badge: nil,
                perWeek: "forever",
                trialText: nil,
                package: offering?.package(identifier: "$rc_lifetime")
            )
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Restore
                HStack {
                    Spacer()
                    Button("Restore Purchases") {
                        Task { await restorePurchases() }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .disabled(isPurchasing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Brand icon + Paywall illustration hero
                VStack(spacing: 16) {
                    Image("BrandIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: Color.pmPrimary.opacity(0.3), radius: 12)

                    Image("Onboarding-5")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 32)

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
                    ForEach(plans) { plan in
                        PlanCard(
                            title: plan.title,
                            price: plan.price,
                            period: plan.period,
                            badge: plan.badge,
                            perWeek: plan.perWeek,
                            isSelected: selectedPlanIndex == plan.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPlanIndex = plan.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Trial callout (for monthly plan)
                if selectedPlanIndex == 1 {
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
                }

                // CTA
                VStack(spacing: 12) {
                    PMButton(
                        title: isPurchasing ? "Processing..." : (selectedPlanIndex == 1 ? "Start Free Trial" : "Subscribe Now"),
                        icon: isPurchasing ? nil : "lock.open.fill"
                    ) {
                        Task { await purchaseSelected() }
                    }
                    .disabled(isPurchasing)
                    .opacity(isPurchasing ? 0.7 : 1)

                    if isPurchasing {
                        ProgressView()
                            .tint(Color.pmPrimary)
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
        .task {
            await purchaseManager.loadOfferings()
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorText)
        }
        .alert("Purchases Restored", isPresented: $showRestoreSuccess) {
            Button("Continue") { onContinue() }
        } message: {
            Text("Your Pro subscription has been restored successfully.")
        }
    }

    // MARK: - Purchase
    private func purchaseSelected() async {
        let plan = plans[selectedPlanIndex]
        guard let package = plan.package else {
            errorText = "This plan is not available right now. Please try again later."
            showError = true
            return
        }

        isPurchasing = true
        let success = await purchaseManager.purchase(package)
        isPurchasing = false

        if success {
            onContinue()
        } else if let error = purchaseManager.errorMessage {
            errorText = error
            showError = true
        }
    }

    // MARK: - Restore
    private func restorePurchases() async {
        isPurchasing = true
        let success = await purchaseManager.restore()
        isPurchasing = false

        if success {
            showRestoreSuccess = true
        } else if let error = purchaseManager.errorMessage {
            errorText = error
            showError = true
        }
    }
}

// MARK: - Supporting Views

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
                    if perWeek != "forever" {
                        Text("/week")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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
