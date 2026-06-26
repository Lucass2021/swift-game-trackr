import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let name: String
    let email: String
}
