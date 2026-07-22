import Foundation

extension Int {
    var abbreviated: String {
        guard self >= 1000 else { return "\(self)" }
        let thousands = Double(self) / 1000
        return String(format: "%.1fk", thousands).replacingOccurrences(of: ".0k", with: "k")
    }
}
