import SwiftUI

struct SetupItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var photos: [SetupPhoto]
    var palette: AvatarPalette

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        photos: [SetupPhoto] = [],
        palette: AvatarPalette = .indigo
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.photos = photos
        self.palette = palette
    }
}

struct SetupPhoto: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage

    static func == (lhs: SetupPhoto, rhs: SetupPhoto) -> Bool {
        lhs.id == rhs.id
    }

    static func downsampled(from data: Data, maxDimension: CGFloat = 1200) -> SetupPhoto? {
        guard let original = UIImage(data: data) else { return nil }

        let longestSide = max(original.size.width, original.size.height)
        guard longestSide > maxDimension else { return SetupPhoto(image: original) }

        let scale = maxDimension / longestSide
        let target = CGSize(width: original.size.width * scale, height: original.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: target)
        let resized = renderer.image { _ in
            original.draw(in: CGRect(origin: .zero, size: target))
        }
        return SetupPhoto(image: resized)
    }
}
