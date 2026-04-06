import UIKit
import SwiftData

struct PhotoStorageService {
    static func savePhoto(image: UIImage, category: String = "progress", context: ModelContext) -> PosturePhoto? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let photo = PosturePhoto(imageData: data, category: category)
        context.insert(photo)
        return photo
    }

    static func loadImage(from photo: PosturePhoto) -> UIImage? {
        UIImage(data: photo.imageData)
    }

    static func deletePhoto(_ photo: PosturePhoto, context: ModelContext) {
        context.delete(photo)
    }
}
