import SwiftUI

struct PostDetailView: View {
    let post: CommunityPost
    var onCommunitySelect: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var isLiked: Bool
    @State private var likes: Int
    @State private var isBookmarked = false
    @State private var isFollowing = false
    @State private var showComments = false

    init(post: CommunityPost, onCommunitySelect: @escaping () -> Void = {}) {
        self.post = post
        self.onCommunitySelect = onCommunitySelect
        _isLiked = State(initialValue: post.isLiked)
        _likes = State(initialValue: post.likes)
        _isBookmarked = State(initialValue: post.isBookmarked)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    author
                    communityChip
                    title
                    postBody
                    highlights

                    if post.hasMedia {
                        media
                    }

                    engagementBar
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showComments) {
            PostCommentsSheet(comments: CommunityMockData.comments)
        }
    }

    private var topBar: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                AppIconView(icon: .back, size: 22)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Back")

            Spacer()

            Image("logo-wordmark")
                .resizable()
                .scaledToFit()
                .frame(height: 24)

            Spacer()

            Button {} label: {
                AppIconView(icon: .overflow, size: 22)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appOutline)
                .frame(height: 1)
        }
    }

    private var author: some View {
        HStack(spacing: 12) {
            CommunityAvatar(start: post.avatarStart, end: post.avatarEnd, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(post.author)
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appPrimary)

                Text(post.timeAgo)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            Button {
                isFollowing.toggle()
            } label: {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.appLabel(14))
                    .foregroundStyle(isFollowing ? Color.appOnPrimary : Color.appTextPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(isFollowing ? Color.appPrimary : Color.clear))
                    .overlay(Capsule().stroke(isFollowing ? Color.clear : Color.appOutline, lineWidth: 1))
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private var communityChip: some View {
        Button(action: onCommunitySelect) {
            HStack(spacing: 8) {
                AppIconView(icon: .community, size: 16)
                Text(post.communityName)
                    .font(.appLabel(13))
            }
            .foregroundStyle(Color.appTextSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.appSurfaceCard))
            .overlay(Capsule().stroke(Color.appOutline, lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var title: some View {
        Text(post.title)
            .font(.appHeadline(28, weight: .heavy))
            .foregroundStyle(Color.appTextPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var postBody: some View {
        Text(post.preview)
            .font(.appBody(16))
            .foregroundStyle(Color.appTextPrimary.opacity(0.9))
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var highlights: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(CommunityMockData.detailPostHighlights, id: \.self) { highlight in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: 6, height: 6)
                        .padding(.top, 8)

                    Text(highlight)
                        .font(.appBody(15))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
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
                AppIconView(icon: .brand, size: 44)
                    .foregroundStyle(Color.white.opacity(0.15))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            }
    }

    private var engagementBar: some View {
        HStack(spacing: 22) {
            action(
                icon: .like,
                label: isLiked ? "Unlike" : "Like",
                filled: isLiked,
                tint: isLiked ? .appPrimary : .appTextSecondary,
                value: likes.abbreviated
            ) {
                isLiked.toggle()
                likes += isLiked ? 1 : -1
            }

            action(icon: .comment, label: "Comment", value: post.comments.abbreviated) {
                showComments = true
            }

            action(icon: .share, label: "Share") {}

            Spacer()

            action(
                icon: .bookmark,
                label: isBookmarked ? "Remove bookmark" : "Bookmark",
                filled: isBookmarked,
                tint: isBookmarked ? .appPrimary : .appTextSecondary
            ) {
                isBookmarked.toggle()
            }
        }
        .padding(.vertical, 16)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.appOutline).frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.appOutline).frame(height: 1)
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
                AppIconView(icon: icon, filled: filled, size: 22)
                if let value {
                    Text(value)
                        .font(.appBody(15))
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
    NavigationStack {
        PostDetailView(post: CommunityMockData.detailPost)
    }
    .preferredColorScheme(.dark)
}
