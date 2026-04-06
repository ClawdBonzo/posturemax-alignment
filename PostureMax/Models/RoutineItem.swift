import Foundation
import SwiftData

@Model
final class RoutineItem {
    var id: UUID
    var name: String
    var category: String
    var routineDescription: String
    var durationMinutes: Int
    var steps: [String]
    var iconName: String
    var isCustom: Bool
    var difficulty: String // "beginner", "intermediate", "advanced"
    var targetAreas: [String]

    init(
        name: String,
        category: String,
        routineDescription: String = "",
        durationMinutes: Int = 10,
        steps: [String] = [],
        iconName: String = "figure.stand",
        isCustom: Bool = false,
        difficulty: String = "beginner",
        targetAreas: [String] = []
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.routineDescription = routineDescription
        self.durationMinutes = durationMinutes
        self.steps = steps
        self.iconName = iconName
        self.isCustom = isCustom
        self.difficulty = difficulty
        self.targetAreas = targetAreas
    }
}
