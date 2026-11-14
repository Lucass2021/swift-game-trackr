import Foundation

nonisolated struct SetupItem: Identifiable, Equatable {
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

nonisolated struct SetupImage: Identifiable, Equatable {
    let id: Int
    let url: String
}

nonisolated struct SetupImageUpload {
    let data: Data
    let fileName: String
    let mimeType: String
}
