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

    static let coverEmeraldStart = Color(hex: "1B4332")
    static let coverEmeraldEnd = Color(hex: "081C15")
    static let coverCrimsonStart = Color(hex: "6A040F")
    static let coverCrimsonEnd = Color(hex: "1B1B3A")
    static let coverIndigoStart = Color(hex: "3A0CA3")
    static let coverIndigoEnd = Color(hex: "10002B")
    static let coverAzureStart = Color(hex: "023E8A")
    static let coverAzureEnd = Color(hex: "03071E")
    static let coverVioletStart = Color(hex: "9D4EDD")
    static let coverVioletEnd = Color(hex: "240046")
    static let coverCyanStart = Color(hex: "0077B6")
    static let coverCyanEnd = Color(hex: "03071E")
    static let coverPineStart = Color(hex: "2D6A4F")
    static let coverPineEnd = Color(hex: "1B263B")
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
