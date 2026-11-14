import Foundation

nonisolated struct SetupImageDTO: Decodable {
    let id: Int
    let url: String
}

nonisolated struct SetupDTO: Decodable {
    let id: Int
    let title: String
    let description: String?
    let images: [SetupImageDTO]
}

nonisolated struct SetupResponse: Decodable {
    let message: String?
    let data: SetupDTO
}

nonisolated struct SetupsResponse: Decodable {
    let message: String?
    let data: [SetupDTO]
}
