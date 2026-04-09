import Foundation
import UIKit

@Observable
final class HapticService: @unchecked Sendable {
    static let shared = HapticService()

    private init() {}

    // MARK: - Public Haptic Methods

    func playLevelUpHaptic() {
        playImpact(style: .heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playNotification(type: .success)
        }
    }

    func playStreakMilestoneHaptic() {
        // Triple pulse pattern
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                self.playImpact(style: .medium)
            }
        }
    }

    func playQuestCompletionHaptic() {
        playNotification(type: .success)
    }

    func playBadgeUnlockHaptic() {
        // Long + short pattern
        playImpact(style: .heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playImpact(style: .light)
        }
    }

    func playLogHaptic() {
        playSelection()
    }

    // MARK: - Helper Methods

    func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
