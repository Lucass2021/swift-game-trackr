import SwiftUI

private enum Constants {
    static let sheetHeightFraction: CGFloat = 0.85
}

struct PostCommentsSheet: View {
    @Bindable var viewModel: PostDetailViewModel
    let isGuest: Bool

    @Environment(\.dismiss) private var dismiss
    @FocusState private var composerFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            CommentsHeader(total: viewModel.commentCount, onClose: { dismiss() })

            CommentsBody(
                viewModel: viewModel,
                isGuest: isGuest,
                onReplyTap: { comment in
                    viewModel.onReplyTap(comment)
                    composerFocused = true
                }
            )
            .frame(maxHeight: .infinity)

            if !isGuest, viewModel.hasLoadedComments {
                VStack(spacing: 0) {
                    if let replyingTo = viewModel.replyingTo {
                        ReplyIndicator(author: replyingTo.author, onCancel: { viewModel.onReplyCancel() })
                    }
                    CommentComposer(
                        draft: $viewModel.draft,
                        isFocused: $composerFocused,
                        onSubmit: { Task { await viewModel.onSend() } }
                    )
                }
            }
        }
        .background(Color.appSurfaceCard)
        .toast(message: $viewModel.toastMessage)
        .presentationDragIndicator(.visible)
        .presentationDetents([.fraction(Constants.sheetHeightFraction), .large])
        .presentationBackground(Color.appSurfaceCard)
        .preferredColorScheme(.dark)
    }
}

private struct CommentsBody: View {
    let viewModel: PostDetailViewModel
    let isGuest: Bool
    let onReplyTap: (PostComment) -> Void

    var body: some View {
        if viewModel.commentsFailed {
            EmptyState(
                icon: .info,
                title: "Couldn't load comments",
                message: "Check your connection and try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.loadComments() } }
            )
        } else if !viewModel.hasLoadedComments {
            ProgressView()
                .tint(Color.appPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.comments.isEmpty {
            EmptyState(icon: .comment, title: "No comments yet", message: "Be the first to comment.")
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: Spacing.lg) {
                    ForEach(viewModel.comments) { thread in
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            row(thread, isReply: false)
                            ForEach(thread.replies) { reply in
                                row(reply, isReply: true)
                            }
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func row(_ comment: PostComment, isReply: Bool) -> some View {
        CommentRow(
            comment: comment,
            isReply: isReply,
            isGuest: isGuest,
            onLike: { Task { await viewModel.onCommentLike(comment.id) } },
            onReply: { onReplyTap(comment) }
        )
    }
}

#Preview {
    @Previewable @State var viewModel = PostDetailViewModel(
        post: CommunityMockData.detailPost,
        repository: FakeCommunityRepository(),
        feedRepository: FakeCommunityFeedRepository(remote: FakeCommunityRepository()),
        postUpdates: PostUpdates()
    )
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            PostCommentsSheet(viewModel: viewModel, isGuest: false)
        }
        .task { await viewModel.loadIfNeeded() }
        .preferredColorScheme(.dark)
}

#Preview("Error") {
    @Previewable @State var viewModel = PostDetailViewModel(
        post: CommunityMockData.detailPost,
        repository: FakeCommunityRepository(failure: APIError.networkFailure),
        feedRepository: FakeCommunityFeedRepository(remote: FakeCommunityRepository()),
        postUpdates: PostUpdates()
    )
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            PostCommentsSheet(viewModel: viewModel, isGuest: false)
        }
        .task { await viewModel.loadIfNeeded() }
        .preferredColorScheme(.dark)
}
