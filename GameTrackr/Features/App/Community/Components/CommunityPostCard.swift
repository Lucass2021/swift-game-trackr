import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let avatarSize: CGFloat = 40
    static let mediaIconSize: CGFloat = 40
    static let titleSize: CGFloat = 19
    static let previewSize: CGFloat = 15
    static let authorSize: CGFloat = 15
    static let metadataSize: CGFloat = 13
    static let mediaAspectRatio: CGFloat = 16 / 9
    static let mediaIconOpacity = 0.15
    static let previewLineLimit = 2
}

struct CommunityPostCard: View {
    let post: CommunityPost
    var isGuest = false
    var showsCommunityName = true
    var onSelect: () -> Void = {}
    var onLike: () -> Void = {}
    var onComment: () -> Void = {}
    var onBookmark: () -> Void = {}

    private var metadata: String {
        showsCommunityName ? "\(post.timeAgo) · \(post.communityName)" : post.timeAgo
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    header
                    text
                    if post.hasMedia {
                        media
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            CommunityPostActions(
                post: post,
                isGuest: isGuest,
                onLike: onLike,
                onComment: onComment,
                onBookmark: onBookmark
            )
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }

    private var header: some View {
        HStack(spacing: Spacing.sm) {
            CommunityAvatar(start: post.avatarStart, end: post.avatarEnd, size: Constants.avatarSize)

            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(post.author)
                    .font(.appLabel(Constants.authorSize))
                    .foregroundStyle(Color.appPrimary)

                Text(metadata)
                    .font(.appBody(Constants.metadataSize))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer(minLength: Spacing.xs)
        }
    }

    private var text: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(post.title)
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(post.preview)
                .font(.appBody(Constants.previewSize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.leading)
                .lineLimit(Constants.previewLineLimit)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var media: some View {
        RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [post.mediaStart, post.mediaEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(Constants.mediaAspectRatio, contentMode: .fit)
            .overlay {
                AppIconView(icon: .brand, size: Constants.mediaIconSize)
                    .foregroundStyle(Color.white.opacity(Constants.mediaIconOpacity))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
            }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.md) {
            CommunityPostCard(post: CommunityMockData.feed[0])
            CommunityPostCard(post: CommunityMockData.feed[CommunityMockData.feed.count - 1], isGuest: true)
        }
        .padding(Spacing.lg)
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
