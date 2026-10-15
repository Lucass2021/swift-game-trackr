import Foundation

struct SetupImageDTO: Decodable {
    let id: Int
    let url: String
}

struct SetupDTO: Decodable {
    let id: Int
    let title: String
    let description: String?
    let images: [SetupImageDTO]
}

struct SetupResponse: Decodable {
    let message: String?
    let data: SetupDTO
}

struct SetupsResponse: Decodable {
    let message: String?
    let data: [SetupDTO]
}
