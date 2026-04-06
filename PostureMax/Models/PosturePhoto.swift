import Foundation
import SwiftData

@Model
final class PosturePhoto {
    var id: UUID
    var imageData: Data
    var dateTaken: Date
    var category: String // "front", "side", "back", "progress"
    var notes: String
    var associatedLogId: UUID?

    init(
        imageData: Data,
        dateTaken: Date = .now,
        category: String = "progress",
        notes: String = "",
        associatedLogId: UUID? = nil
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.dateTaken = dateTaken
        self.category = category
        self.notes = notes
        self.associatedLogId = associatedLogId
    }
}
