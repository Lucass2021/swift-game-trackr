import SwiftUI

struct ProfileColor: Identifiable, Hashable {
    let key: String
    let name: String
    let hex: String

    var id: String {
        key
    }

    var color: Color {
        Color(hex: hex)
    }
}

extension ProfileColor {
    init(dto: ProfileColorDTO) {
        self.init(key: dto.key, name: dto.name, hex: dto.hex)
    }
}
