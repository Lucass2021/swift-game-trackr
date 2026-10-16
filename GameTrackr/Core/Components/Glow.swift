import SwiftUI

private enum Constants {
    static let blurToShadowRadius: CGFloat = 0.5
}

extension View {
    func glow(color: Color, blurRadius: CGFloat, alpha: Double) -> some View {
        shadow(color: color.opacity(alpha), radius: blurRadius * Constants.blurToShadowRadius)
    }
}
