import Foundation
import RevenueCat
import SwiftUI

// MARK: - RevenueCat Configuration
enum RCConstants {
    // ⚠️  PRODUCTION SETUP REQUIRED ⚠️
    //
    // The RevenueCat account at app.revenuecat.com has no project configured yet.
    // Before submitting to the App Store:
    //
    // 1. Go to https://app.revenuecat.com → Create a project (name it "PostureMax")
    // 2. Under the project → Apps → "Add new app" → select "App Store" → paste bundle ID:
    //    com.clawdbonzo.PostureMax
    // 3. Set up 4 products in App Store Connect matching these IDs exactly:
    //    • com.clawdbonzo.posturemax.weekly   ($4.99/week,  auto-renewable)
    //    • com.clawdbonzo.posturemax.monthly  ($9.99/month, 3-day free trial)
    //    • com.clawdbonzo.posturemax.yearly   ($49.99/year, 3-day free trial)
    //    • com.clawdbonzo.posturemax.lifetime ($79.99, non-consumable)
    // 4. In RevenueCat → Entitlements → create "pro" → attach all 4 products
    // 5. In RevenueCat → Offerings → create "default" → create 4 packages:
    //    $rc_weekly, $rc_monthly, $rc_annual, $rc_lifetime
    // 6. In RevenueCat → Project Settings → API Keys → copy the PUBLIC key
    //    (starts with "appl_" for App Store) and replace the placeholder below.
    //
    // The current key is the placeholder from initial setup — it will not process
    // real purchases. Replace it before TestFlight external testing.
    static let apiKey = "test_JYgyHftpBlZsQleHsnqldwQRscJ"
    // ↑ Replace with: "appl_XXXXXXXXXXXXXXXXXXXXXXXXXXXX"

    static let entitlementID = "pro"

    // Product identifiers — must match App Store Connect exactly
    static let weeklyProductID   = "com.clawdbonzo.posturemax.weekly"
    static let monthlyProductID  = "com.clawdbonzo.posturemax.monthly"
    static let yearlyProductID   = "com.clawdbonzo.posturemax.yearly"
    static let lifetimeProductID = "com.clawdbonzo.posturemax.lifetime"
}

// MARK: - Purchase Manager

@Observable
final class PurchaseManager: @unchecked Sendable {
    static let shared = PurchaseManager()

    var isPro:            Bool      = false
    var offerings:        Offerings?
    var currentOffering:  Offering?
    var isLoading:        Bool      = false
    var errorMessage:     String?

    private init() {}

    // MARK: - Configure on app launch
    func configure() {
        Purchases.logLevel = .warn  // reduce console noise in production
        Purchases.configure(withAPIKey: RCConstants.apiKey)
    }

    // MARK: - Load offerings
    @MainActor
    func loadOfferings() async {
        isLoading    = true
        errorMessage = nil
        do {
            let result       = try await Purchases.shared.offerings()
            offerings        = result
            currentOffering  = result.current
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Check entitlement
    @MainActor
    func checkProStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            isPro = info.entitlements[RCConstants.entitlementID]?.isActive == true
        } catch {
            isPro = false
        }
    }

    // MARK: - Purchase a package
    @MainActor
    func purchase(_ package: Package) async -> Bool {
        isLoading    = true
        errorMessage = nil
        do {
            let result = try await Purchases.shared.purchase(package: package)
            isPro      = result.customerInfo.entitlements[RCConstants.entitlementID]?.isActive == true
            isLoading  = false
            return isPro
        } catch let error as ErrorCode {
            if error != .purchaseCancelledError {
                errorMessage = error.localizedDescription
            }
            isLoading = false
            return false
        } catch {
            errorMessage = error.localizedDescription
            isLoading    = false
            return false
        }
    }

    // MARK: - Restore purchases
    @MainActor
    func restore() async -> Bool {
        isLoading    = true
        errorMessage = nil
        do {
            let info  = try await Purchases.shared.restorePurchases()
            isPro     = info.entitlements[RCConstants.entitlementID]?.isActive == true
            isLoading = false
            return isPro
        } catch {
            errorMessage = error.localizedDescription
            isLoading    = false
            return false
        }
    }

    // MARK: - Package helpers (RevenueCat default identifiers)
    var weeklyPackage:  Package? { currentOffering?.package(identifier: "$rc_weekly")   }
    var monthlyPackage: Package? { currentOffering?.package(identifier: "$rc_monthly")  }
    var annualPackage:  Package? { currentOffering?.package(identifier: "$rc_annual")   }
    var lifetimePackage: Package? { currentOffering?.package(identifier: "$rc_lifetime") }
}
