import Foundation
import SwiftData

struct StreakService {
    @MainActor
    static func updateStreak(context: ModelContext) {
        let descriptor = FetchDescriptor<StreakRecord>()
        let records = (try? context.fetch(descriptor)) ?? []
        let streak = records.first ?? StreakRecord()

        if records.isEmpty {
            context.insert(streak)
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastLog = streak.lastLogDate {
            let lastDay = calendar.startOfDay(for: lastLog)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if dayDiff == 1 {
                streak.currentStreak += 1
            } else if dayDiff > 1 {
                streak.currentStreak = 1
            }
            // dayDiff == 0 means already logged today
        } else {
            streak.currentStreak = 1
        }

        streak.lastLogDate = today
        streak.totalDaysLogged += 1
        streak.longestStreak = max(streak.longestStreak, streak.currentStreak)
    }

    @MainActor
    static func getCurrentStreak(context: ModelContext) -> StreakRecord {
        let descriptor = FetchDescriptor<StreakRecord>()
        let records = (try? context.fetch(descriptor)) ?? []
        return records.first ?? StreakRecord()
    }
}
