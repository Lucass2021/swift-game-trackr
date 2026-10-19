import SwiftUI

private enum Constants {
    static let avatarSize: CGFloat = 36
    static let replyAvatarSize: CGFloat = 28
    static let likeIconSize: CGFloat = 16
    static let authorSize: CGFloat = 14
    static let timeSize: CGFloat = 12
    static let contentSize: CGFloat = 14
    static let metaSize: CGFloat = 12
}

struct CommentRow: View {
    let comment: PostComment
    var isReply = false
    var isGuest = false
    var onLike: () -> Void = {}
    var onReply: () -> Void = {}

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            CommunityAvatar(
                start: comment.avatarStart,
                end: comment.avatarEnd,
                size: isReply ? Constants.replyAvatarSize : Constants.avatarSize
            )

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(spacing: Spacing.xs) {
                    Text(comment.author)
                        .font(.appLabel(Constants.authorSize))
                        .foregroundStyle(Color.appPrimary)

                    Text(comment.timeAgo)
                        .font(.appBody(Constants.timeSize))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Text(comment.content)
                    .font(.appBody(Constants.contentSize))
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: Spacing.xxs) {
                    Text("\(comment.likes) likes")
                    if !isGuest {
                        Text("·")
                        Button(action: onReply) {
                            Text("Reply")
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .font(.appLabel(Constants.metaSize))
                .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !isGuest {
                Button(action: onLike) {
                    AppIconView(icon: .like, filled: comment.isLiked, size: Constants.likeIconSize)
                        .foregroundStyle(comment.isLiked ? Color.appPrimary : Color.appTextSecondary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel(comment.isLiked ? "Unlike comment" : "Like comment")
            }
        }
        .padding(.leading, isReply ? Spacing.xxxl : 0)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.md) {
        CommentRow(comment: CommunityMockData.comments[0])
        CommentRow(comment: CommunityMockData.comments[0].replies[0], isReply: true)
        CommentRow(comment: CommunityMockData.comments[1], isGuest: true)
    }
    .padding(Spacing.lg)
    .background(Color.appSurfaceCard)
    .preferredColorScheme(.dark)
}
