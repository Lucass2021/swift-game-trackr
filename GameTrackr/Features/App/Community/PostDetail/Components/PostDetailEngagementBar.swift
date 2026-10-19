import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 22
    static let valueSize: CGFloat = 15
    static let dividerThickness: CGFloat = 1
}

struct PostDetailEngagementBar: View {
    let post: CommunityPost
    let commentCount: Int
    let isGuest: Bool
    let onLike: () -> Void
    let onComment: () -> Void
    let onBookmark: () -> Void

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

            action(icon: .comment, label: "Comment", value: commentCount.abbreviated, action: onComment)

            if !isGuest {
                ShareLink(item: "Check out this discussion on GameTrackr: \"\(post.title)\"") {
                    AppIconView(icon: .share, size: Constants.iconSize)
                        .foregroundStyle(Color.appTextSecondary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Share")

                Spacer()

                action(
                    icon: .bookmark,
                    label: post.isBookmarked ? "Remove bookmark" : "Bookmark",
                    filled: post.isBookmarked,
                    tint: post.isBookmarked ? .appPrimary : .appTextSecondary,
                    action: onBookmark
                )
            }
        }
        .padding(.vertical, Spacing.md)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.appOutline).frame(height: Constants.dividerThickness)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.appOutline).frame(height: Constants.dividerThickness)
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
    VStack {
        PostDetailEngagementBar(
            post: CommunityMockData.detailPost,
            commentCount: CommunityMockData.detailPost.comments,
            isGuest: false,
            onLike: {},
            onComment: {},
            onBookmark: {}
        )
        PostDetailEngagementBar(
            post: CommunityMockData.detailPost,
            commentCount: CommunityMockData.detailPost.comments,
            isGuest: true,
            onLike: {},
            onComment: {},
            onBookmark: {}
        )
    }
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
