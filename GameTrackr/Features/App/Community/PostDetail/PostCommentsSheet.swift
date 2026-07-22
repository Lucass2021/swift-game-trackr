import SwiftUI

struct PostCommentsSheet: View {
    @State var comments: [PostComment]

    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @FocusState private var composerFocused: Bool

    private var total: Int {
        comments.reduce(0) { $0 + 1 + $1.replies.count + $1.hiddenReplies }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if comments.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 22) {
                        ForEach(comments) { comment in
                            CommentRow(comment: comment, onLike: { toggleLike(comment) })

                            ForEach(comment.replies) { reply in
                                CommentRow(
                                    comment: reply,
                                    isReply: true,
                                    onLike: { toggleLike(reply, parent: comment) }
                                )
                            }

                            if comment.hiddenReplies > 0 {
                                Button {} label: {
                                    Text("View \(comment.hiddenReplies) more replies")
                                        .font(.appLabel(13))
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                                .buttonStyle(PressableButtonStyle())
                                .padding(.leading, 62)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                .scrollDismissesKeyboard(.interactively)
            }

            CommentComposer(draft: $draft, isFocused: $composerFocused)
        }
        .background(Color.appSurfaceCard)
        .presentationDragIndicator(.visible)
        .presentationDetents([.fraction(0.85), .large])
        .presentationBackground(Color.appSurfaceCard)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("Comments")
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)

            Text("\(total)")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)

            Spacer()

            Button {
                dismiss()
            } label: {
                AppIconView(icon: .close, size: 16)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.appBackground))
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appOutline)
                .frame(height: 1)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            AppIconView(icon: .comment, size: 44)
                .foregroundStyle(Color.appTextSecondary)

            Text("No comments yet")
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)

            Text("Be the first to comment.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toggleLike(_ comment: PostComment, parent: PostComment? = nil) {
        if let parent {
            guard
                let parentIndex = comments.firstIndex(where: { $0.id == parent.id }),
                let replyIndex = comments[parentIndex].replies.firstIndex(where: { $0.id == comment.id })
            else { return }
            comments[parentIndex].replies[replyIndex].isLiked.toggle()
            comments[parentIndex].replies[replyIndex].likes += comments[parentIndex].replies[replyIndex]
                .isLiked ? 1 : -1
        } else {
            guard let index = comments.firstIndex(where: { $0.id == comment.id }) else { return }
            comments[index].isLiked.toggle()
            comments[index].likes += comments[index].isLiked ? 1 : -1
        }
    }
}

#Preview {
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            PostCommentsSheet(comments: CommunityMockData.comments)
        }
        .preferredColorScheme(.dark)
}
