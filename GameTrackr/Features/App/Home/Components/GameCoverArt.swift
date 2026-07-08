import SwiftUI

struct GameCoverArt: View {
    let start: Color
    let end: Color
    var width: CGFloat?
    var height: CGFloat?

    private var brandSize: CGFloat {
        if let width, let height {
            return min(width, height) * 0.32
        }
        return 44
    }

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
                AppIconView(icon: .brand, size: brandSize)
                    .foregroundStyle(Color.white.opacity(0.18))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            }
    }
}
