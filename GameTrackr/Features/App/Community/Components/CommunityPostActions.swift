import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 20
    static let valueSize: CGFloat = 14
}

struct CommunityPostActions: View {
    let post: CommunityPost
    let isGuest: Bool
    var onLike: () -> Void = {}
    var onComment: () -> Void = {}
    var onBookmark: () -> Void = {}

    var body: some View {
        HStack(spacing: Spacing.lg) {
            if !isGuest {
                action(
                    icon: .like,
                    label: post.isLiked ? "Unlike" : "Like",
                    filled: post.isLiked,
                    tint: post.isLiked ? .appPrimary : .appTextSecondary,
                    value: post.likes.abbreviated,
                    action: onLike
                )
            }
            action(icon: .comment, label: "Comment", value: post.comments.abbreviated, action: onComment)
            if !isGuest {
                ShareLink(item: "Check out this discussion on GameTrackr: \"\(post.title)\"") {
                    AppIconView(icon: .share, size: Constants.iconSize)
                        .foregroundStyle(Color.appTextSecondary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Share")
            }

            Spacer()

            if !isGuest {
                action(
                    icon: .bookmark,
                    label: post.isBookmarked ? "Remove bookmark" : "Bookmark",
                    filled: post.isBookmarked,
                    tint: post.isBookmarked ? .appPrimary : .appTextSecondary,
                    action: onBookmark
                )
            }
        }
    }

    private func action(
        icon: AppIcon,
        label: String,
        filled: Bool = false,
        tint: Color = .appTextSecondary,
        value: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                AppIconView(icon: icon, filled: filled, size: Constants.iconSize)
                if let value {
                    Text(value)
                        .font(.appBody(Constants.valueSize))
                }
            }
            .foregroundStyle(tint)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(label)
        .accessibilityValue(value ?? "")
    }
}

#Preview {
    CommunityPostActions(post: CommunityMockData.feed[0], isGuest: false)
        .padding(Spacing.md)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
