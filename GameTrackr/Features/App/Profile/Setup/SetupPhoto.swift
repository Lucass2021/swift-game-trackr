import UIKit

nonisolated struct SetupPhoto: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
    var sourceId: String?

    static func == (lhs: SetupPhoto, rhs: SetupPhoto) -> Bool {
        lhs.id == rhs.id
    }

    static func downsampled(from data: Data, sourceId: String? = nil, maxDimension: CGFloat = 1200) -> SetupPhoto? {
        guard let original = UIImage(data: data) else { return nil }

        let longestSide = max(original.size.width, original.size.height)
        guard longestSide > maxDimension else { return SetupPhoto(image: original, sourceId: sourceId) }

        let scale = maxDimension / longestSide
        let target = CGSize(width: original.size.width * scale, height: original.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        let resized = renderer.image { _ in
            original.draw(in: CGRect(origin: .zero, size: target))
        }
        return SetupPhoto(image: resized, sourceId: sourceId)
    }
}
