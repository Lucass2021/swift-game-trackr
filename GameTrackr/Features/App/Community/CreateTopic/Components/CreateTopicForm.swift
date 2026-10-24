import SwiftUI

private enum Constants {
    static let titleCounterThreshold = 20
    static let bodyMinHeight: CGFloat = 160
    static let bodyLineLimit = 6 ... 12
    static let pickerZIndex: Double = 1
}

nonisolated enum CreateTopicFocusField {
    case title
    case body
}

struct CreateTopicForm: View {
    let viewModel: CreateTopicViewModel
    var focusedField: FocusState<CreateTopicFocusField?>.Binding

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                FormField(label: "Community", error: viewModel.communityError) {
                    CommunityPickerField(
                        selection: viewModel.community,
                        options: viewModel.communities,
                        onSelect: viewModel.onCommunityChange,
                        isLocked: viewModel.isCommunityLocked,
                        isLoading: viewModel.isLoadingCommunities,
                        isFailed: viewModel.communitiesFailed,
                        onRetry: { Task { await viewModel.retryCommunities() } }
                    )
                }
                .zIndex(Constants.pickerZIndex)

                FormField(label: "Title", error: viewModel.titleError, counter: titleCounter) {
                    FormTextField(
                        text: binding(viewModel.title, viewModel.onTitleChange),
                        placeholder: "What's the discussion about?"
                    )
                    .submitLabel(.next)
                    .focused(focusedField, equals: .title)
                    .onSubmit { focusedField.wrappedValue = .body }
                }

                FormField(label: "Body", error: viewModel.bodyError) {
                    FormTextField(
                        text: binding(viewModel.body, viewModel.onBodyChange),
                        placeholder: "Share your thoughts with the community…",
                        singleLine: false,
                        multiLineMinHeight: Constants.bodyMinHeight,
                        multiLineLimit: Constants.bodyLineLimit
                    )
                    .focused(focusedField, equals: .body)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xs)
            .padding(.bottom, Spacing.xxxl)
        }
    }

    private var titleCounter: Int? {
        viewModel.titleRemaining <= Constants.titleCounterThreshold ? viewModel.titleRemaining : nil
    }

    private func binding<Value>(_ value: Value, _ onChange: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: { value }, set: onChange)
    }
}

#Preview {
    @Previewable @FocusState var focusedField: CreateTopicFocusField?
    let viewModel = CreateTopicViewModel(
        community: CommunityMockData.all.first,
        repository: FakeCommunityRepository(),
        postUpdates: PostUpdates()
    )
    viewModel.onTitleChange("Best co-op games of the year?")
    return CreateTopicForm(viewModel: viewModel, focusedField: $focusedField)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
