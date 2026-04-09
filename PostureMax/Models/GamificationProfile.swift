import Foundation
import SwiftData

@Model
final class GamificationProfile {
    var id: UUID = UUID()
    var userProfileId: UUID  // relation to UserProfile

    var totalXP: Int = 0  // cumulative XP, never decreases
    var lifetimeXP: Int = 0  // display stat
    var currentLevelXP: Int = 0  // XP toward next level

    // Level thresholds for exponential progression (50 levels total)
    var levelUpAt: [Int] = [
        0, 100, 200, 320, 460, 620, 800, 1000, 1220, 1460,
        1720, 2000, 2300, 2620, 2960, 3320, 3700, 4100, 4520, 4960,
        5420, 5900, 6400, 6920, 7460, 8020, 8600, 9200, 9820, 10460,
        11120, 11800, 12500, 13220, 13960, 14720, 15500, 16300, 17120, 17960,
        18820, 19700, 20600, 21520, 22460, 23420, 24400, 25400, 26420, 27460
    ]

    var lastQuestCompletedDate: Date = Date()
    var lastDailyQuestResetDate: Date = Date()
    var lastWeeklyQuestResetDate: Date = Date()

    var createdAt: Date = Date()

    // Computed properties
    var currentLevel: Int {
        for (index, threshold) in levelUpAt.enumerated() {
            if totalXP < threshold {
                return index  // Return 1-based level (index is 0-based but thresholds start at level 1)
            }
        }
        return levelUpAt.count  // Max level 50
    }

    var nextLevelThreshold: Int {
        // levelUpAt is 0-indexed; levelUpAt[currentLevel] is the XP to enter the next level
        guard currentLevel < levelUpAt.count else { return levelUpAt.last ?? 27460 }
        return levelUpAt[currentLevel]
    }

    var xpToNextLevel: Int {
        nextLevelThreshold - totalXP
    }

    var xpProgressPercent: Double {
        let currentThreshold = currentLevel > 0 && currentLevel <= levelUpAt.count ? levelUpAt[currentLevel - 1] : 0
        let nextThreshold = nextLevelThreshold
        let progress = Double(totalXP - currentThreshold) / Double(nextThreshold - currentThreshold)
        return min(max(progress, 0), 1)
    }

    // Level names progression
    var levelName: String {
        switch currentLevel {
        case 1: return "Slouch"
        case 2...5: return "Slouch Guard"
        case 6...10: return "Upright"
        case 11...15: return "Upright Defender"
        case 16...20: return "Posture Pro"
        case 21...25: return "Spine Master"
        case 26...30: return "Alignment Expert"
        case 31...35: return "Posture Champion"
        case 36...40: return "Spine Guardian"
        case 41...45: return "Alignment Sage"
        case 46...50: return "Posture Warrior"
        default: return "Posture Warrior"
        }
    }

    static func getLevelName(for level: Int) -> String {
        switch level {
        case 1: return "Slouch"
        case 2...5: return "Slouch Guard"
        case 6...10: return "Upright"
        case 11...15: return "Upright Defender"
        case 16...20: return "Posture Pro"
        case 21...25: return "Spine Master"
        case 26...30: return "Alignment Expert"
        case 31...35: return "Posture Champion"
        case 36...40: return "Spine Guardian"
        case 41...45: return "Alignment Sage"
        case 46...50: return "Posture Warrior"
        default: return "Posture Warrior"
        }
    }

    init(userProfileId: UUID) {
        self.userProfileId = userProfileId
    }
}
