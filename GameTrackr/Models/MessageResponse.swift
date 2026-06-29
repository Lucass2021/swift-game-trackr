import Foundation

struct MessageResponse: Decodable {
    let error: String?
    let message: String?
}
