import Foundation

nonisolated struct ProfileColor: Identifiable, Hashable {
    let key: String
    let name: String
    let hex: String

    var id: String {
        key
    }
}

nonisolated extension ProfileColor {
    init(dto: ProfileColorDTO) {
        self.init(key: dto.key, name: dto.name, hex: dto.hex)
    }
}
