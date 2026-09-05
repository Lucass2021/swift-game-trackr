import SwiftUI

struct ProfileColor: Identifiable, Hashable, Decodable {
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

struct ProfileColorsResponse: Decodable {
    let message: String?
    let data: [ProfileColor]
}
