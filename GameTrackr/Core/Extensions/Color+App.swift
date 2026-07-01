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
        let red, green, blue, alpha: UInt64
        switch hex.count {
        case 8:
            (red, green, blue, alpha) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (red, green, blue, alpha) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, 255)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
