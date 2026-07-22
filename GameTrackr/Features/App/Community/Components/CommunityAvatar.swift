import SwiftUI

struct CommunityAvatar: View {
    let start: Color
    let end: Color
    var size: CGFloat = 40

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [start, end],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay {
                AppIconView(icon: .avatar, size: size * 0.55)
                    .foregroundStyle(Color.white.opacity(0.55))
            }
    }
}

struct CommunityIcon: View {
    let start: Color
    let end: Color
    var size: CGFloat = 56
    var cornerRadius: CGFloat = 14

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [start, end],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay {
                AppIconView(icon: .community, size: size * 0.42)
                    .foregroundStyle(Color.white.opacity(0.65))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            }
    }
}

#Preview {
    HStack(spacing: 20) {
        CommunityAvatar(start: .coverVioletStart, end: .coverVioletEnd)
        CommunityIcon(start: .coverEmeraldStart, end: .coverEmeraldEnd)
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
