import Foundation

nonisolated struct MessageResponse: Decodable {
    let error: String?
    let message: String?
}
