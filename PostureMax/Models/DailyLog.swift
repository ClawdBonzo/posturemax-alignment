import Foundation
import SwiftData

@Model
final class DailyLog {
    var id: UUID
    var date: Date
    var postureRating: Int // 0-10
    var painLevel: Int // 0-10
    var notes: String

    // Checklist items completed
    var completedChecklist: [String]

    // Associated photo
    var photoId: UUID?

    // Routine completion
    var completedRoutineIds: [String]

    // Traits
    var neckAlignment: Int // 0-10
    var shoulderBalance: Int // 0-10
    var spineAlignment: Int // 0-10
    var hipAlignment: Int // 0-10
    var overallMobility: Int // 0-10

    var createdAt: Date

    init(
        date: Date = .now,
        postureRating: Int = 5,
        painLevel: Int = 5,
        notes: String = "",
        completedChecklist: [String] = [],
        photoId: UUID? = nil,
        completedRoutineIds: [String] = [],
        neckAlignment: Int = 5,
        shoulderBalance: Int = 5,
        spineAlignment: Int = 5,
        hipAlignment: Int = 5,
        overallMobility: Int = 5
    ) {
        self.id = UUID()
        self.date = date
        self.postureRating = postureRating
        self.painLevel = painLevel
        self.notes = notes
        self.completedChecklist = completedChecklist
        self.photoId = photoId
        self.completedRoutineIds = completedRoutineIds
        self.neckAlignment = neckAlignment
        self.shoulderBalance = shoulderBalance
        self.spineAlignment = spineAlignment
        self.hipAlignment = hipAlignment
        self.overallMobility = overallMobility
        self.createdAt = Date()
    }
}
