import SwiftUI

struct SetupItem: Identifiable, Equatable {
    let id: Int
    var title: String
    var description: String
    var images: [SetupImage]
    var palette: SetupPalette

    init(
        id: Int,
        title: String,
        description: String,
        images: [SetupImage] = [],
        palette: SetupPalette? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.images = images
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

nonisolated struct SetupImageUpload {
    let data: Data
    let fileName: String
    let mimeType: String
}

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
