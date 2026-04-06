import SwiftUI
import Observation

@Observable
final class AppCoordinator {
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    var selectedTab: AppTab = .dashboard

    enum AppTab: Int, CaseIterable {
        case dashboard = 0
        case logger = 1
        case photos = 2
        case progress = 3
        case routines = 4
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}
