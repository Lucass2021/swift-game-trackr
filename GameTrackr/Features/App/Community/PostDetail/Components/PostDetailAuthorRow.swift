import SwiftUI

private enum Constants {
    static let avatarSize: CGFloat = 44
    static let authorSize: CGFloat = 15
    static let timeSize: CGFloat = 13
}

struct PostDetailAuthorRow: View {
    let post: CommunityPost
    let onAuthorSelect: () -> Void

    var body: some View {
        Button(action: onAuthorSelect) {
            HStack(spacing: Spacing.sm) {
                CommunityAvatar(start: post.avatarStart, end: post.avatarEnd, size: Constants.avatarSize)

                VStack(alignment: .leading, spacing: Spacing.xxxs) {
                    Text(post.author)
                        .font(.appLabel(Constants.authorSize))
                        .foregroundStyle(Color.appPrimary)

                    Text(post.timeAgo)
                        .font(.appBody(Constants.timeSize))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("View \(post.author)'s profile")
    }
}

#Preview {
    PostDetailAuthorRow(post: CommunityMockData.detailPost, onAuthorSelect: {})
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
