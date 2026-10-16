import UIKit

nonisolated enum SetupPhotoEncoder {
    private static let jpegQuality: CGFloat = 0.85
    private static let jpegMimeType = "image/jpeg"
    private static let filePrefix = "setup-"

    static func encode(_ photo: SetupPhoto) -> SetupImageUpload? {
        guard let data = photo.image.jpegData(compressionQuality: jpegQuality) else { return nil }
        return SetupImageUpload(data: data, fileName: "\(filePrefix)\(photo.id.uuidString).jpg", mimeType: jpegMimeType)
    }
}
