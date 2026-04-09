import Foundation
import SwiftData

enum QuestType: String, Codable {
    case logTimes = "log_times"  // Log posture X times
    case achievePerfectScore = "perfect_score"  // Achieve avg posture 7+
    case completeRoutine = "complete_routine"  // Complete a routine
    case usePhotoTracking = "photo_tracking"  // Use camera to log

    var title: String {
        switch self {
        case .logTimes:
            return "Log posture %d times"
        case .achievePerfectScore:
            return "Achieve avg. posture 7+"
        case .completeRoutine:
            return "Complete a routine"
        case .usePhotoTracking:
            return "Use photo tracking %d times"
        }
    }

    var description: String {
        switch self {
        case .logTimes:
            return "Log your posture and alignment"
        case .achievePerfectScore:
            return "Achieve an average posture score of 7 or higher"
        case .completeRoutine:
            return "Complete one of your routines"
        case .usePhotoTracking:
            return "Use the camera to track your posture progress"
        }
    }
}

@Model
final class Quest {
    var id: UUID = UUID()
    var type: QuestType = QuestType.logTimes
    var targetValue: Int = 1  // e.g., 5 for "log posture 5 times"
    var currentProgress: Int = 0
    var xpReward: Int = 150
    var isWeekly: Bool = false
    var createdDate: Date = Date()
    var completedDate: Date?

    var isCompleted: Bool {
        currentProgress >= targetValue
    }

    var displayTitle: String {
        switch type {
        case .logTimes, .usePhotoTracking:
            return String(format: type.title, targetValue)
        case .achievePerfectScore, .completeRoutine:
            return type.title
        }
    }

    var progressPercent: Double {
        Double(currentProgress) / Double(targetValue)
    }

    init(
        type: QuestType,
        targetValue: Int = 1,
        xpReward: Int = 150,
        isWeekly: Bool = false
    ) {
        self.type = type
        self.targetValue = targetValue
        self.xpReward = xpReward
        self.isWeekly = isWeekly
    }
}
