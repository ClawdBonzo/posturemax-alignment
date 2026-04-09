import Foundation
import SwiftData

@Observable
final class GamificationService: @unchecked Sendable {
    static let shared = GamificationService()

    private init() {}

    // MARK: - Initialization

    func initializeGamification(context: ModelContext, userProfileId: UUID) {
        // Check if gamification profile already exists
        let descriptor = FetchDescriptor<GamificationProfile>(predicate: #Predicate { $0.userProfileId == userProfileId })
        if let _ = try? context.fetch(descriptor).first {
            return  // Already initialized
        }

        // Create new profile
        let profile = GamificationProfile(userProfileId: userProfileId)
        context.insert(profile)
        try? context.save()
    }

    // MARK: - XP Award Logic

    func awardXPForLog(context: ModelContext, userProfileId: UUID, posture: Int, pain: Int, streak: Int) {
        guard let profile = getGamificationProfile(context: context, userProfileId: userProfileId) else { return }

        var xpToAward = 50  // Base XP

        // Streak multiplier: 1.0 + (streak / 10), capped at 5.0
        let multiplier = min(1.0 + Double(streak) / 10.0, 5.0)
        xpToAward = Int(Double(xpToAward) * multiplier)

        // Perfect posture bonus (all traits 8+)
        if posture >= 8 {
            xpToAward += 25
        }

        // Capture level BEFORE awarding XP so we can detect level-up
        let previousLevel = profile.currentLevel

        // Award XP
        profile.totalXP += xpToAward
        profile.lifetimeXP += xpToAward

        // Check for level up
        let newLevel = profile.currentLevel

        if newLevel > previousLevel {
            // Level up occurred — reset currentLevelXP to XP earned since new level's threshold
            HapticService.shared.playLevelUpHaptic()
            let currentThreshold = newLevel - 1 < profile.levelUpAt.count ? profile.levelUpAt[newLevel - 1] : 0
            profile.currentLevelXP = profile.totalXP - currentThreshold
        } else {
            profile.currentLevelXP += xpToAward
        }

        try? context.save()
    }

    func awardXPForQuestCompletion(context: ModelContext, userProfileId: UUID, xp: Int) {
        guard let profile = getGamificationProfile(context: context, userProfileId: userProfileId) else { return }

        let previousLevel = profile.currentLevel

        profile.totalXP += xp
        profile.lifetimeXP += xp

        let newLevel = profile.currentLevel

        if newLevel > previousLevel {
            HapticService.shared.playLevelUpHaptic()
            let currentThreshold = newLevel - 1 < profile.levelUpAt.count ? profile.levelUpAt[newLevel - 1] : 0
            profile.currentLevelXP = profile.totalXP - currentThreshold
        } else {
            profile.currentLevelXP += xp
        }

        try? context.save()
    }

    func awardXPForRoutineCompletion(context: ModelContext, userProfileId: UUID) {
        guard let profile = getGamificationProfile(context: context, userProfileId: userProfileId) else { return }

        profile.totalXP += 75
        profile.lifetimeXP += 75
        profile.currentLevelXP += 75

        try? context.save()
    }

    func awardXPForPhotoTracking(context: ModelContext, userProfileId: UUID) {
        guard let profile = getGamificationProfile(context: context, userProfileId: userProfileId) else { return }

        profile.totalXP += 30
        profile.lifetimeXP += 30
        profile.currentLevelXP += 30

        try? context.save()
    }

    // MARK: - Data Retrieval

    func getGamificationProfile(context: ModelContext, userProfileId: UUID) -> GamificationProfile? {
        let descriptor = FetchDescriptor<GamificationProfile>(predicate: #Predicate { $0.userProfileId == userProfileId })
        return try? context.fetch(descriptor).first
    }

    func getCurrentLevel(totalXP: Int) -> Int {
        // Level thresholds from GamificationProfile
        let levelUpAt = [
            0, 100, 200, 320, 460, 620, 800, 1000, 1220, 1460,
            1720, 2000, 2300, 2620, 2960, 3320, 3700, 4100, 4520, 4960,
            5420, 5900, 6400, 6920, 7460, 8020, 8600, 9200, 9820, 10460,
            11120, 11800, 12500, 13220, 13960, 14720, 15500, 16300, 17120, 17960,
            18820, 19700, 20600, 21520, 22460, 23420, 24400, 25400, 26420, 27460
        ]

        for (index, threshold) in levelUpAt.enumerated() {
            if totalXP < threshold {
                return max(1, index)  // Return 1-based level
            }
        }
        return 50  // Max level
    }

    func getNextLevelXP(level: Int) -> Int {
        let levelUpAt = [
            0, 100, 200, 320, 460, 620, 800, 1000, 1220, 1460,
            1720, 2000, 2300, 2620, 2960, 3320, 3700, 4100, 4520, 4960,
            5420, 5900, 6400, 6920, 7460, 8020, 8600, 9200, 9820, 10460,
            11120, 11800, 12500, 13220, 13960, 14720, 15500, 16300, 17120, 17960,
            18820, 19700, 20600, 21520, 22460, 23420, 24400, 25400, 26420, 27460
        ]

        let index = min(max(level, 1), levelUpAt.count - 1)
        return levelUpAt[index]
    }

    func getXPProgressToNextLevel(totalXP: Int) -> (current: Int, needed: Int) {
        let currentLevel = getCurrentLevel(totalXP: totalXP)
        let currentThreshold = currentLevel > 1 ? getNextLevelXP(level: currentLevel - 1) : 0
        let nextThreshold = getNextLevelXP(level: currentLevel + 1)

        let current = totalXP - currentThreshold
        let needed = nextThreshold - currentThreshold

        return (current, needed)
    }
}
