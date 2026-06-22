import SwiftUI

extension Color {
    static let appPrimary = Color(hex: "B5FF3A")
    static let appSecondary = Color(hex: "22D3EE")
    static let appTertiary = Color(hex: "FF5C6C")
    static let appNeutral = Color(hex: "747969")

    static let appBackground = Color(hex: "0B0D0A")
    static let appSurfaceCard = Color(hex: "1A1D17")
    static let appOutline = Color(hex: "2A2E26")

    static let appTextPrimary = Color.white
    static let appTextSecondary = Color(hex: "9BA197")
    static let appOnPrimary = Color.black
}

extension Color {
    init(hex: String) {
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 8:
            (r, g, b, a) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
