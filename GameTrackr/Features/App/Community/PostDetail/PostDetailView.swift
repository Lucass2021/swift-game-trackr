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
    @State private var comments: [PostComment] = []
    @State private var commentsError = false
    @State private var selectedUser: UserProfile?

    init(post: CommunityPost, onCommunitySelect: @escaping () -> Void = {}) {
        self.post = post
        self.onCommunitySelect = onCommunitySelect
        _isLiked = State(initialValue: post.isLiked)
        _likes = State(initialValue: post.likes)
        _isBookmarked = State(initialValue: post.isBookmarked)
    }

    private var authorProfile: UserProfile {
        UserProfile(
            handle: post.author,
            avatarStart: post.avatarStart,
            avatarEnd: post.avatarEnd
        )
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
        .task { await loadComments() }
        .sheet(isPresented: $showComments) {
            PostCommentsSheet(postId: post.id, comments: comments)
        }
        .navigationDestination(isPresented: showUserBinding) {
            if let selectedUser {
                UserProfileView(user: selectedUser)
            }
        }
    }

    private var showUserBinding: Binding<Bool> {
        Binding(
            get: { selectedUser != nil },
            set: { if !$0 { selectedUser = nil } }
        )
    }

    private func loadComments() async {
        commentsError = false
        do {
            let dto = try await CommunityService.shared.fetchPost(id: post.id)
            comments = dto.comments?.map { PostComment(dto: $0) } ?? []
        } catch {
            commentsError = true
        }
    }

    private func toggleLike() {
        isLiked.toggle()
        likes += isLiked ? 1 : -1

        Task {
            do {
                let response = try await CommunityService.shared.toggleLike(postId: post.id)
                isLiked = response.isLiked
                likes = response.likes
            } catch {
                isLiked.toggle()
                likes += isLiked ? 1 : -1
            }
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
            Button {
                selectedUser = authorProfile
            } label: {
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
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("View \(post.author)'s profile")

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
                toggleLike()
            }

            action(icon: .comment, label: "Comment", value: comments.count.abbreviated) {
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
