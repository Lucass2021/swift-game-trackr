import SwiftUI

private enum Constants {
    static let titleSize: CGFloat = 28
    static let bodySize: CGFloat = 16
    static let bodyLineSpacing: CGFloat = 5
    static let bodyAlpha = 0.9
}

struct PostDetailContent: View {
    let post: CommunityPost
    let commentCount: Int
    let isGuest: Bool
    let onAuthorSelect: () -> Void
    let onCommunitySelect: () -> Void
    let onLike: () -> Void
    let onComment: () -> Void
    let onBookmark: () -> Void
    let onCreateAccount: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                PostDetailAuthorRow(post: post, onAuthorSelect: onAuthorSelect)
                PostDetailCommunityChip(name: post.communityName, action: onCommunitySelect)

                Text(post.title)
                    .font(.appHeadline(Constants.titleSize, weight: .heavy))
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(post.preview)
                    .font(.appBody(Constants.bodySize))
                    .foregroundStyle(Color.appTextPrimary.opacity(Constants.bodyAlpha))
                    .lineSpacing(Constants.bodyLineSpacing)
                    .fixedSize(horizontal: false, vertical: true)

                if post.hasMedia {
                    PostDetailMedia(post: post)
                }

                PostDetailEngagementBar(
                    post: post,
                    commentCount: commentCount,
                    isGuest: isGuest,
                    onLike: onLike,
                    onComment: onComment,
                    onBookmark: onBookmark
                )

                if isGuest {
                    PostDetailGuestCard(onCreateAccount: onCreateAccount)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }
}

#Preview {
    PostDetailContent(
        post: CommunityMockData.detailPost,
        commentCount: CommunityMockData.detailPost.comments,
        isGuest: false,
        onAuthorSelect: {},
        onCommunitySelect: {},
        onLike: {},
        onComment: {},
        onBookmark: {},
        onCreateAccount: {}
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

#Preview("Guest") {
    PostDetailContent(
        post: CommunityMockData.detailPost,
        commentCount: CommunityMockData.detailPost.comments,
        isGuest: true,
        onAuthorSelect: {},
        onCommunitySelect: {},
        onLike: {},
        onComment: {},
        onBookmark: {},
        onCreateAccount: {}
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
