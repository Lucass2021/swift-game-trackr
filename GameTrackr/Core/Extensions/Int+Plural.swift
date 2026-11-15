import Foundation

nonisolated extension Int {
    func plural(one: String, other: String) -> String {
        self == 1 ? one : other
    }
}
