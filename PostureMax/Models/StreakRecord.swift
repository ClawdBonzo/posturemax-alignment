import Foundation
import SwiftData

@Model
final class StreakRecord {
    var id: UUID
    var currentStreak: Int
    var longestStreak: Int
    var lastLogDate: Date?
    var totalDaysLogged: Int

    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastLogDate: Date? = nil,
        totalDaysLogged: Int = 0
    ) {
        self.id = UUID()
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastLogDate = lastLogDate
        self.totalDaysLogged = totalDaysLogged
    }
}
