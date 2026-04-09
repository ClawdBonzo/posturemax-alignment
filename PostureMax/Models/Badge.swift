import Foundation
import SwiftData

enum BadgeType: String, Codable, CaseIterable {
    case firstLog = "first_log"
    case firstPerfectScore = "first_perfect"
    case perfectWeek = "perfect_week"
    case sevenDayStreak = "streak_7"
    case thirtyDayStreak = "streak_30"
    case hundredDayStreak = "streak_100"
    case yearStreak = "streak_365"
    case level5 = "level_5"
    case level10 = "level_10"
    case level25 = "level_25"
    case level50 = "level_50"
    case tenRoutines = "routines_10"
    case twentyFiveRoutines = "routines_25"
    case fiftyRoutines = "routines_50"
    case photoTracker = "photo_tracker"
    case privacyGuardian = "privacy_guardian"
    case streakMaster = "streak_master"
    case posturePerfectionist = "posture_perfectionist"
    case weekWarrior = "week_warrior"
    case monthMaster = "month_master"

    var displayName: String {
        switch self {
        case .firstLog:
            return "Daily Starter"
        case .firstPerfectScore:
            return "Perfect Form"
        case .perfectWeek:
            return "Week Wonder"
        case .sevenDayStreak:
            return "Week Warrior"
        case .thirtyDayStreak:
            return "Month Master"
        case .hundredDayStreak:
            return "Century Centaur"
        case .yearStreak:
            return "Year Yogi"
        case .level5:
            return "Rising Star"
        case .level10:
            return "Upright Ascent"
        case .level25:
            return "Spine Sage"
        case .level50:
            return "Posture Warrior"
        case .tenRoutines:
            return "Routine Ranger"
        case .twentyFiveRoutines:
            return "Exercise Elite"
        case .fiftyRoutines:
            return "Fitness Fiend"
        case .photoTracker:
            return "Visual Tracker"
        case .privacyGuardian:
            return "Consistent Guardian"
        case .streakMaster:
            return "Streak Master"
        case .posturePerfectionist:
            return "Posture Perfectionist"
        case .weekWarrior:
            return "Week Warrior"
        case .monthMaster:
            return "Month Master"
        }
    }

    var description: String {
        switch self {
        case .firstLog:
            return "Log your first posture entry"
        case .firstPerfectScore:
            return "Achieve a perfect 10/10 posture score"
        case .perfectWeek:
            return "Log posture every day for a week"
        case .sevenDayStreak:
            return "Maintain a 7-day logging streak"
        case .thirtyDayStreak:
            return "Maintain a 30-day logging streak"
        case .hundredDayStreak:
            return "Maintain a 100-day logging streak"
        case .yearStreak:
            return "Maintain a 365-day logging streak"
        case .level5:
            return "Reach level 5"
        case .level10:
            return "Reach level 10"
        case .level25:
            return "Reach level 25"
        case .level50:
            return "Reach level 50 - Posture Warrior"
        case .tenRoutines:
            return "Complete 10 routines"
        case .twentyFiveRoutines:
            return "Complete 25 routines"
        case .fiftyRoutines:
            return "Complete 50 routines"
        case .photoTracker:
            return "Use photo tracking 10 times"
        case .privacyGuardian:
            return "Log 30 consecutive days without missing"
        case .streakMaster:
            return "Achieve a 60+ day streak"
        case .posturePerfectionist:
            return "Achieve 7+ posture score 20 times"
        case .weekWarrior:
            return "Maintain a 7-day streak"
        case .monthMaster:
            return "Maintain a 30-day streak"
        }
    }

    var iconName: String {
        switch self {
        case .firstLog:
            return "star.fill"
        case .firstPerfectScore:
            return "checkmark.circle.fill"
        case .perfectWeek:
            return "calendar.circle.fill"
        case .sevenDayStreak:
            return "flame.fill"
        case .thirtyDayStreak:
            return "flame.fill"
        case .hundredDayStreak:
            return "flame.fill"
        case .yearStreak:
            return "crown.fill"
        case .level5:
            return "level.5.fill"
        case .level10:
            return "level.10.fill"
        case .level25:
            return "level.25.fill"
        case .level50:
            return "crown.fill"
        case .tenRoutines:
            return "dumbbell.fill"
        case .twentyFiveRoutines:
            return "dumbbell.fill"
        case .fiftyRoutines:
            return "bolt.fill"
        case .photoTracker:
            return "camera.fill"
        case .privacyGuardian:
            return "shield.fill"
        case .streakMaster:
            return "bolt.fill"
        case .posturePerfectionist:
            return "sparkles"
        case .weekWarrior:
            return "flame.fill"
        case .monthMaster:
            return "flame.fill"
        }
    }
}

@Model
final class Badge {
    var id: UUID = UUID()
    var badgeType: BadgeType
    var unlockedDate: Date?
    var isUnlocked: Bool {
        unlockedDate != nil
    }

    var displayName: String {
        badgeType.displayName
    }

    var description: String {
        badgeType.description
    }

    var iconName: String {
        badgeType.iconName
    }

    init(badgeType: BadgeType) {
        self.badgeType = badgeType
    }
}
