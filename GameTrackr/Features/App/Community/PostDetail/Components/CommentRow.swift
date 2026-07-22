import SwiftUI

struct CommentRow: View {
    let comment: PostComment
    var isReply = false
    var onLike: () -> Void = {}

    private var avatarSize: CGFloat {
        isReply ? 28 : 36
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
                    Text("·")
                    Text("Reply")
                }
                .font(.appLabel(12))
                .foregroundStyle(Color.appTextSecondary)
            }

            Spacer(minLength: 8)

            Button(action: onLike) {
                AppIconView(icon: .like, filled: comment.isLiked, size: 16)
                    .foregroundStyle(comment.isLiked ? Color.appPrimary : Color.appTextSecondary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel(comment.isLiked ? "Unlike comment" : "Like comment")
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
