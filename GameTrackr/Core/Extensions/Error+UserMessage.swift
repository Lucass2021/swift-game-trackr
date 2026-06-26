import Foundation

extension Error {
    func userMessage(fallback: String = "Something went wrong.") -> String {
        (self as? APIError)?.errorDescription ?? fallback
    }
}
