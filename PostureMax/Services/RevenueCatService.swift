import Foundation
import RevenueCat
import SwiftUI

// MARK: - RevenueCat Configuration
enum RCConstants {
    // TODO: Replace with live key before App Store release
    static let apiKey = "test_JYgyHftpBlZsQleHsnqldwQRscJ"
    static let entitlementID = "pro"

    // Product identifiers (must match App Store Connect)
    static let weeklyProductID   = "posturemax_weekly"
    static let monthlyProductID  = "posturemax_monthly"
    static let yearlyProductID   = "posturemax_yearly"
    static let lifetimeProductID = "posturemax_lifetime"
}

// MARK: - Purchase State
@Observable
final class PurchaseManager {
    static let shared = PurchaseManager()

    var isPro: Bool = false
    var offerings: Offerings?
    var currentOffering: Offering?
    var isLoading: Bool = false
    var errorMessage: String?

    private init() {}

    // MARK: - Configure on app launch
    func configure() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: RCConstants.apiKey)
    }

    // MARK: - Load offerings
    @MainActor
    func loadOfferings() async {
        isLoading = true
        errorMessage = nil
        do {
            let offerings = try await Purchases.shared.offerings()
            self.offerings = offerings
            self.currentOffering = offerings.current
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Check entitlement
    @MainActor
    func checkProStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPro = customerInfo.entitlements[RCConstants.entitlementID]?.isActive == true
        } catch {
            isPro = false
        }
    }

    // MARK: - Purchase a package
    @MainActor
    func purchase(_ package: Package) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Purchases.shared.purchase(package: package)
            isPro = result.customerInfo.entitlements[RCConstants.entitlementID]?.isActive == true
            isLoading = false
            return isPro
        } catch let error as ErrorCode {
            if error == .purchaseCancelledError {
                // User cancelled — not an error
            } else {
                errorMessage = error.localizedDescription
            }
            isLoading = false
            return false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Restore purchases
    @MainActor
    func restore() async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isPro = customerInfo.entitlements[RCConstants.entitlementID]?.isActive == true
            isLoading = false
            return isPro
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Helper to get packages from current offering
    var weeklyPackage: Package? {
        currentOffering?.package(identifier: "$rc_weekly")
    }

    var monthlyPackage: Package? {
        currentOffering?.package(identifier: "$rc_monthly")
    }

    var annualPackage: Package? {
        currentOffering?.package(identifier: "$rc_annual")
    }

    var lifetimePackage: Package? {
        currentOffering?.package(identifier: "$rc_lifetime")
    }
}
