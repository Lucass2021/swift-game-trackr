import SwiftUI

struct CommentRow: View {
    let comment: PostComment
    var isReply = false
    var isGuest = false
    var currentUserId: Int?
    var onLike: () -> Void = {}
    var onReply: () -> Void = {}
    var onDelete: () -> Void = {}

    private var avatarSize: CGFloat {
        isReply ? 28 : 36
    }

    private var isOwnComment: Bool {
        guard let currentUserId, let authorId = comment.authorId else { return false }
        return authorId == currentUserId
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CommunityAvatar(start: comment.avatarStart, end: comment.avatarEnd, size: avatarSize)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(comment.author)
                        .font(.appLabel(14))
                        .foregroundStyle(Color.appPrimary)

                    Text(comment.timeAgo)
                        .font(.appBody(12))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Text(comment.content)
                    .font(.appBody(14))
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Text("\(comment.likes) likes")
                    if !isGuest {
                        Text("·")
                        Button(action: onReply) {
                            Text("Reply")
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .font(.appLabel(12))
                .foregroundStyle(Color.appTextSecondary)
            }

            Spacer(minLength: 8)

            if !isGuest {
                HStack(spacing: 8) {
                    if isOwnComment {
                        Button(action: onDelete) {
                            AppIconView(icon: .trash, size: 16)
                                .foregroundStyle(Color.appTextSecondary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PressableButtonStyle())
                        .accessibilityLabel("Delete comment")
                    }

                    Button(action: onLike) {
                        AppIconView(icon: .like, filled: comment.isLiked, size: 16)
                            .foregroundStyle(comment.isLiked ? Color.appPrimary : Color.appTextSecondary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel(comment.isLiked ? "Unlike comment" : "Like comment")
                }
            }
        }
        .padding(.leading, isReply ? 40 : 0)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 22) {
        CommentRow(comment: CommunityMockData.comments[0])
        CommentRow(comment: CommunityMockData.comments[0].replies[0], isReply: true)
    }
    .padding(20)
    .background(Color.appSurfaceCard)
    .preferredColorScheme(.dark)
}
