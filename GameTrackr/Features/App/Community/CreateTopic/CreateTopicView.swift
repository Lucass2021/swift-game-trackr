import SwiftUI

struct CreateTopicView: View {
    let onPost: (CommunityPost) -> Void

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var model: CreateTopicModel
    @State private var showDiscardConfirm = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case title
        case body
    }

    init(community: Community? = nil, onPost: @escaping (CommunityPost) -> Void) {
        _model = State(initialValue: CreateTopicModel(community: community))
        self.onPost = onPost
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if authStore.isGuest {
                guestState
            } else {
                form
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
        .alert("Discard this post?", isPresented: $showDiscardConfirm) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard", role: .destructive) { dismiss() }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                focusedField = nil
                if model.hasContent {
                    showDiscardConfirm = true
                } else {
                    dismiss()
                }
            } label: {
                AppIconView(icon: .close, size: 20)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Close")

            Text("New post")
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            if !authStore.isGuest {
                Button(action: submit) {
                    Text("Post")
                        .font(.appLabel(15))
                        .foregroundStyle(Color.appOnPrimary)
                        .padding(.horizontal, 20)
                        .frame(height: 38)
                        .background(Capsule().fill(Color.appPrimary))
                        .opacity(model.canSubmit ? 1 : 0.45)
                        .contentShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var guestState: some View {
        CommunityEmptyState(
            icon: .community,
            title: "Posting needs an account",
            message: "You're browsing as a guest. Create an account to start discussions in your communities.",
            actionTitle: "Create an account",
            action: { authStore.logout() }
        )
    }

    private var form: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                field("Community", error: model.visibleError(model.communityError)) {
                    CommunityPickerField(
                        selection: $model.community,
                        options: joinedCommunities,
                        isLocked: model.isCommunityLocked
                    )
                }
                .zIndex(1)

                field("Title", error: model.visibleError(model.titleError), counter: titleCounter) {
                    TextField(
                        "",
                        text: $model.title,
                        prompt: Text("What's the discussion about?")
                            .foregroundStyle(Color.appTextSecondary)
                    )
                    .font(.appBody(16))
                    .foregroundStyle(Color.appTextPrimary)
                    .tint(Color.appPrimary)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .title)
                    .onSubmit { focusedField = .body }
                    .fieldBox()
                }

                field("Body", error: model.visibleError(model.bodyError)) {
                    TextField(
                        "",
                        text: $model.body,
                        prompt: Text("Share your thoughts with the community...")
                            .foregroundStyle(Color.appTextSecondary),
                        axis: .vertical
                    )
                    .font(.appBody(16))
                    .foregroundStyle(Color.appTextPrimary)
                    .tint(Color.appPrimary)
                    .lineLimit(6 ... 12)
                    .focused($focusedField, equals: .body)
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appSurfaceCard)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.appOutline, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
    }

    private var joinedCommunities: [Community] {
        CommunityMockData.all.filter(\.isJoined)
    }

    private var titleCounter: String? {
        model.titleRemaining <= 20 ? "\(model.titleRemaining)" : nil
    }

    private func field(
        _ label: String,
        error: String?,
        counter: String? = nil,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionLabel(text: label)
                Spacer()
                if let counter {
                    Text(counter)
                        .font(.appBody(12))
                        .foregroundStyle(model.titleRemaining < 0 ? Color.appTertiary : Color.appTextSecondary)
                }
            }

            content()

            if let error {
                Text(error)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func submit() {
        focusedField = nil
        guard let post = model.submit() else { return }
        onPost(post)
        dismiss()
    }
}

#Preview {
    Color.appBackground
        .fullScreenCover(isPresented: .constant(true)) {
            CreateTopicView(onPost: { _ in })
        }
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}
