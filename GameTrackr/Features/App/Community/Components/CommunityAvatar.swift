import SwiftUI

private enum Constants {
    static let avatarSize: CGFloat = 40
    static let iconSize: CGFloat = 56
    static let borderWidth: CGFloat = 1
    static let avatarIconOpacity = 0.55
    static let avatarIconRatio: CGFloat = 0.55
    static let iconOpacity = 0.65
    static let iconRatio: CGFloat = 0.42
}

struct CommunityAvatar: View {
    let start: Color
    let end: Color
    var size: CGFloat = Constants.avatarSize

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
                AppIconView(icon: .avatar, size: size * Constants.avatarIconRatio)
                    .foregroundStyle(Color.white.opacity(Constants.avatarIconOpacity))
            }
    }
}

struct CommunityIcon: View {
    let start: Color
    let end: Color
    var size: CGFloat = Constants.iconSize
    var cornerRadius: CGFloat = Radius.md

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
                AppIconView(icon: .community, size: size * Constants.iconRatio)
                    .foregroundStyle(Color.white.opacity(Constants.iconOpacity))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
            }
    }
}

#Preview {
    HStack(spacing: Spacing.sm) {
        CommunityAvatar(start: .coverVioletStart, end: .coverVioletEnd)
        CommunityIcon(start: .coverEmeraldStart, end: .coverEmeraldEnd)
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
