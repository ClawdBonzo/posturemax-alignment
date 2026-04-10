import Foundation
import SwiftData

@Observable
final class QuestService: @unchecked Sendable {
    static let shared = QuestService()

    private init() {}

    // MARK: - Quest Generation

    func generateDailyQuests(context: ModelContext, userProfileId: UUID) {
        // Check if quests were already generated today
        guard let profile = GamificationService.shared.getGamificationProfile(context: context, userProfileId: userProfileId) else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastReset = calendar.startOfDay(for: profile.lastDailyQuestResetDate)

        guard today > lastReset else { return }  // Already generated today

        // Remove old daily quests
        let dailyDescriptor = FetchDescriptor<Quest>(predicate: #Predicate { !$0.isWeekly })
        if let dailyQuests = try? context.fetch(dailyDescriptor) {
            for quest in dailyQuests {
                context.delete(quest)
            }
        }

        // Create new daily quests
        let quest1 = Quest(type: .logTimes, targetValue: 1, xpReward: 50, isWeekly: false)
        let quest2 = randomDailyQuest()

        context.insert(quest1)
        context.insert(quest2)

        profile.lastDailyQuestResetDate = Date()
        try? context.save()
    }

    func generateWeeklyQuests(context: ModelContext, userProfileId: UUID) {
        guard let profile = GamificationService.shared.getGamificationProfile(context: context, userProfileId: userProfileId) else { return }

        let calendar = Calendar.current
        let thisWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        let lastResetComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: profile.lastWeeklyQuestResetDate)

        guard thisWeek != lastResetComponents else { return }  // Already generated this week

        // Remove old weekly quests
        let weeklyDescriptor = FetchDescriptor<Quest>(predicate: #Predicate { $0.isWeekly })
        if let weeklyQuests = try? context.fetch(weeklyDescriptor) {
            for quest in weeklyQuests {
                context.delete(quest)
            }
        }

        // Create new weekly quests
        let quests = [
            Quest(type: .logTimes, targetValue: 5, xpReward: 150, isWeekly: true),
            Quest(type: .completeRoutine, targetValue: 3, xpReward: 150, isWeekly: true),
            Quest(type: .usePhotoTracking, targetValue: 3, xpReward: 100, isWeekly: true),
            Quest(type: .achievePerfectScore, targetValue: 2, xpReward: 200, isWeekly: true)
        ]

        for quest in quests {
            context.insert(quest)
        }

        profile.lastWeeklyQuestResetDate = Date()
        try? context.save()
    }

    // MARK: - Quest Progress Tracking

    func updateQuestProgress(context: ModelContext, questType: QuestType, increment: Int) {
        let descriptor = FetchDescriptor<Quest>(predicate: #Predicate { $0.type == questType })
        if let quests = try? context.fetch(descriptor) {
            for quest in quests where !quest.isCompleted {
                quest.currentProgress += increment
                if quest.isCompleted && quest.completedDate == nil {
                    quest.completedDate = Date()
                    HapticService.shared.playQuestCompletionHaptic()
                }
            }
        }
        try? context.save()
    }

    func getActiveQuests(context: ModelContext) -> [Quest] {
        let descriptor = FetchDescriptor<Quest>(predicate: #Predicate { !$0.isCompleted })
        return (try? context.fetch(descriptor).sorted { $0.isWeekly && !$1.isWeekly }) ?? []
    }

    func getCompletedQuests(context: ModelContext) -> [Quest] {
        let descriptor = FetchDescriptor<Quest>(predicate: #Predicate { $0.isCompleted })
        return (try? context.fetch(descriptor)) ?? []
    }

    func completeQuest(quest: Quest, context: ModelContext) {
        quest.completedDate = Date()
        try? context.save()
    }

    // MARK: - Private Helpers

    private func randomDailyQuest() -> Quest {
        let quests: [Quest] = [
            Quest(type: .achievePerfectScore, targetValue: 1, xpReward: 150, isWeekly: false),
            Quest(type: .completeRoutine, targetValue: 1, xpReward: 100, isWeekly: false),
            Quest(type: .usePhotoTracking, targetValue: 1, xpReward: 75, isWeekly: false)
        ]
        return quests.randomElement() ?? quests[0]
    }
}
