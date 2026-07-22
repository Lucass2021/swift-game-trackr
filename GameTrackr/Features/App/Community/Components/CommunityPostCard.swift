import SwiftUI

struct CommunityPostCard: View {
    let post: CommunityPost
    var showsCommunityName = true
    var onSelect: () -> Void = {}
    var onLike: () -> Void = {}
    var onComment: () -> Void = {}
    var onShare: () -> Void = {}
    var onBookmark: () -> Void = {}

    private var metadata: String {
        showsCommunityName ? "\(post.timeAgo) · \(post.communityName)" : post.timeAgo
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    text
                    if post.hasMedia {
                        media
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            actions
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(spacing: 12) {
            CommunityAvatar(start: post.avatarStart, end: post.avatarEnd, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(post.author)
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appPrimary)

                Text(metadata)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer(minLength: 8)

            AppIconView(icon: .overflow, size: 20)
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    private var text: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.appHeadline(19))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(post.preview)
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var media: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [post.mediaStart, post.mediaEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(16 / 9, contentMode: .fit)
            .overlay {
                AppIconView(icon: .brand, size: 40)
                    .foregroundStyle(Color.white.opacity(0.15))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            }
    }

    private var actions: some View {
        HStack(spacing: 20) {
            action(
                icon: .like,
                label: post.isLiked ? "Unlike" : "Like",
                filled: post.isLiked,
                tint: post.isLiked ? .appPrimary : .appTextSecondary,
                value: post.likes.abbreviated,
                action: onLike
            )
            action(icon: .comment, label: "Comment", value: post.comments.abbreviated, action: onComment)
            action(icon: .share, label: "Share", action: onShare)

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

    private func action(
        icon: AppIcon,
        label: String,
        filled: Bool = false,
        tint: Color = .appTextSecondary,
        value: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                AppIconView(icon: icon, filled: filled, size: 20)
                if let value {
                    Text(value)
                        .font(.appBody(14))
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
    ScrollView {
        VStack(spacing: 16) {
            ForEach(CommunityMockData.feed) { post in
                CommunityPostCard(post: post)
            }
        }
        .padding(20)
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
