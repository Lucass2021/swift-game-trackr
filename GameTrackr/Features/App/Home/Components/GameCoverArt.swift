import SwiftUI

struct GameCoverArt: View {
    let start: Color
    let end: Color
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [start, end],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width, height: height)
            .overlay {
                AppIconView(icon: .brand, size: min(width, height) * 0.32)
                    .foregroundStyle(Color.white.opacity(0.18))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            }
    }
}
