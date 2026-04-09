import SwiftUI
import RevenueCat

// MARK: - Plan Model

private struct PaywallPlan: Identifiable {
    let id: Int
    let title: String
    let price: String
    let period: String
    let badge: String?
    let badgeColor: Color
    let perWeek: String
    let hasTrial: Bool
    var package: Package?
}

// MARK: - Paywall View

struct OnboardingPaywallView: View {
    let onContinue: () -> Void

    @State private var purchaseManager = PurchaseManager.shared
    @State private var selectedPlanIndex = 1
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorText = ""
    @State private var showRestoreSuccess = false
    @State private var shimmerOffset: CGFloat = -300
    @State private var glowPulse = false
    @State private var cardAppear = false

    private var plans: [PaywallPlan] {
        let offering = purchaseManager.currentOffering
        return [
            PaywallPlan(
                id: 0, title: "Weekly",
                price: offering?.package(identifier: "$rc_weekly")?.storeProduct.localizedPriceString ?? "$4.99",
                period: "/ week", badge: nil, badgeColor: .clear,
                perWeek: offering?.package(identifier: "$rc_weekly")?.storeProduct.localizedPriceString ?? "$4.99",
                hasTrial: false,
                package: offering?.package(identifier: "$rc_weekly")
            ),
            PaywallPlan(
                id: 1, title: "Monthly",
                price: offering?.package(identifier: "$rc_monthly")?.storeProduct.localizedPriceString ?? "$9.99",
                period: "/ month", badge: "BEST VALUE", badgeColor: Color.pmAccent,
                perWeek: "$2.50 / wk", hasTrial: true,
                package: offering?.package(identifier: "$rc_monthly")
            ),
            PaywallPlan(
                id: 2, title: "Yearly",
                price: offering?.package(identifier: "$rc_annual")?.storeProduct.localizedPriceString ?? "$49.99",
                period: "/ year", badge: "SAVE 58%", badgeColor: Color.pmSuccess,
                perWeek: "$0.96 / wk", hasTrial: true,
                package: offering?.package(identifier: "$rc_annual")
            ),
            PaywallPlan(
                id: 3, title: "Lifetime",
                price: offering?.package(identifier: "$rc_lifetime")?.storeProduct.localizedPriceString ?? "$79.99",
                period: " once", badge: nil, badgeColor: .clear,
                perWeek: "forever", hasTrial: false,
                package: offering?.package(identifier: "$rc_lifetime")
            )
        ]
    }

    var body: some View {
        ZStack {
            // Premium dark background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.15),
                    Color(red: 0.02, green: 0.04, blue: 0.10),
                    Color(red: 0.04, green: 0.10, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient orbs
            Circle()
                .fill(Color.pmPrimary.opacity(0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -80, y: -180)
                .scaleEffect(glowPulse ? 1.1 : 0.9)

            Circle()
                .fill(Color.pmAccent.opacity(0.08))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: 110, y: 200)
                .scaleEffect(glowPulse ? 0.9 : 1.1)

            VStack(spacing: 0) {
                // Restore
                HStack {
                    Spacer()
                    Button("Restore") {
                        Task { await restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .disabled(isPurchasing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.pmPrimary.opacity(0.2))
                                    .frame(width: 72, height: 72)
                                    .blur(radius: 12)
                                Image("BrandIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            }

                            Text("Go Pro")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .overlay(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.5), .clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .offset(x: shimmerOffset)
                                    .mask(
                                        Text("Go Pro")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                    )
                                )

                            Text("Unlock your full posture transformation")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 4)

                        // Feature grid
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            alignment: .leading,
                            spacing: 10
                        ) {
                            PremiumFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Posture analytics")
                            PremiumFeatureRow(icon: "calendar", text: "30-day plan")
                            PremiumFeatureRow(icon: "camera.fill", text: "Photo tracking")
                            PremiumFeatureRow(icon: "figure.flexibility", text: "Full routines")
                            PremiumFeatureRow(icon: "doc.richtext", text: "PDF reports")
                            PremiumFeatureRow(icon: "trophy.fill", text: "Gamification")
                        }
                        .padding(14)
                        .background(.ultraThinMaterial.opacity(0.5))
                        .background(Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .offset(y: cardAppear ? 0 : 20)
                        .opacity(cardAppear ? 1 : 0)

                        // Plan cards
                        VStack(spacing: 10) {
                            ForEach(plans) { plan in
                                GlassPlanCard(
                                    plan: plan,
                                    isSelected: selectedPlanIndex == plan.id
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedPlanIndex = plan.id
                                    }
                                }
                                .offset(y: cardAppear ? 0 : 30)
                                .opacity(cardAppear ? 1 : 0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.8)
                                        .delay(Double(plan.id) * 0.07),
                                    value: cardAppear
                                )
                            }
                        }

                        // Trial callout
                        if plans[selectedPlanIndex].hasTrial {
                            HStack(spacing: 6) {
                                Image(systemName: "gift.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.pmAccent)
                                Text("3-day free trial • Cancel anytime")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.pmAccent.opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.pmAccent.opacity(0.3), lineWidth: 1)
                            )
                        }

                        // CTA
                        VStack(spacing: 12) {
                            Button {
                                Task { await purchaseSelected() }
                            } label: {
                                HStack(spacing: 8) {
                                    if isPurchasing {
                                        ProgressView().tint(.white).scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "lock.open.fill")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    Text(isPurchasing ? "Processing..." : ctaTitle)
                                        .font(.headline)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.pmPrimary, Color.pmPrimary.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.pmPrimary.opacity(0.4), radius: 12, y: 6)
                            }
                            .disabled(isPurchasing)
                            .opacity(isPurchasing ? 0.7 : 1)

                            Button("Continue with limited access") {
                                onContinue()
                            }
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.35))
                        }

                        HStack(spacing: 20) {
                            Button("Terms") {}.font(.caption2).foregroundStyle(.white.opacity(0.25))
                            Button("Privacy") {}.font(.caption2).foregroundStyle(.white.opacity(0.25))
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                cardAppear = true
            }
            runShimmer()
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

    private var ctaTitle: String {
        plans[selectedPlanIndex].hasTrial ? "Start Free Trial" : "Unlock Now"
    }

    private func runShimmer() {
        withAnimation(.easeInOut(duration: 1.2).delay(1.0)) {
            shimmerOffset = 300
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            shimmerOffset = -300
            runShimmer()
        }
    }

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

// MARK: - Premium Feature Row

struct PremiumFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(Color.pmPrimary)
                .frame(width: 16)
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
        }
    }
}

// MARK: - Glass Plan Card

private struct GlassPlanCard: View {
    let plan: PaywallPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(plan.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .black))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(plan.badgeColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    HStack(spacing: 3) {
                        Text(plan.price)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Text(plan.period)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    if plan.hasTrial {
                        Text("3-day free trial")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.pmAccent.opacity(0.9))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.perWeek)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isSelected ? Color.pmPrimary : .white.opacity(0.55))
                }
                .padding(.trailing, 10)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.pmPrimary : .white.opacity(0.25))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                isSelected
                    ? Color.pmPrimary.opacity(0.18)
                    : Color.white.opacity(0.06)
            )
            .background(.ultraThinMaterial.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.pmPrimary.opacity(0.7) : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(color: isSelected ? Color.pmPrimary.opacity(0.2) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}
