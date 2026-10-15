import SwiftUI

struct SetupItem: Identifiable, Equatable {
    let id: Int
    var title: String
    var description: String
    var images: [SetupImage]
    var photos: [SetupPhoto]
    var palette: SetupPalette

    init(
        id: Int,
        title: String,
        description: String,
        images: [SetupImage] = [],
        photos: [SetupPhoto] = [],
        palette: SetupPalette? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.images = images
        self.photos = photos
        self.palette = palette ?? .forId(id)
    }

    init(dto: SetupDTO) {
        self.init(
            id: dto.id,
            title: dto.title,
            description: dto.description ?? "",
            images: dto.images.map { SetupImage(id: $0.id, url: $0.url) }
        )
    }
}

struct SetupImage: Identifiable, Equatable {
    let id: Int
    let url: String
}

struct SetupImageUpload {
    let data: Data
    let fileName: String
    let mimeType: String
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
