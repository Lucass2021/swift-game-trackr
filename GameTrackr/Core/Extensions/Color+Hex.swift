import SwiftUI

nonisolated extension Color {
    func darkened(by amount: Double) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Color(
            hue: hue,
            saturation: saturation,
            brightness: max(0, brightness * (1 - amount)),
            opacity: alpha
        )
    }
}
