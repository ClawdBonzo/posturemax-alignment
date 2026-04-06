import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var createdAt: Date
    var onboardingCompleted: Bool
    var isPremium: Bool

    // Quiz answers
    var painAreas: [String]
    var painFrequency: String
    var dailySittingHours: Int
    var currentPostureRating: Int
    var goals: [String]

    // Selected routines
    var selectedRoutineIds: [String]

    // Initial photo ID
    var initialPhotoId: UUID?

    init(
        displayName: String = "",
        onboardingCompleted: Bool = false,
        isPremium: Bool = false,
        painAreas: [String] = [],
        painFrequency: String = "sometimes",
        dailySittingHours: Int = 6,
        currentPostureRating: Int = 5,
        goals: [String] = [],
        selectedRoutineIds: [String] = [],
        initialPhotoId: UUID? = nil
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.createdAt = Date()
        self.onboardingCompleted = onboardingCompleted
        self.isPremium = isPremium
        self.painAreas = painAreas
        self.painFrequency = painFrequency
        self.dailySittingHours = dailySittingHours
        self.currentPostureRating = currentPostureRating
        self.goals = goals
        self.selectedRoutineIds = selectedRoutineIds
        self.initialPhotoId = initialPhotoId
    }
}
