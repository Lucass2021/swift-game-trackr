import SwiftUI

private enum Constants {
    static let nameCounterThreshold = 20
    static let descriptionMinHeight: CGFloat = 160
    static let descriptionLineLimit = 6 ... 12
}

nonisolated enum CreateCommunityFocusField {
    case name
    case description
}

struct CreateCommunityForm: View {
    let viewModel: CreateCommunityViewModel
    var focusedField: FocusState<CreateCommunityFocusField?>.Binding

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                FormField(label: "Name", error: viewModel.nameError, hint: nameHint, counter: nameCounter) {
                    FormTextField(
                        text: binding(viewModel.name, viewModel.onNameChange),
                        placeholder: "RetroCollectors"
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused(focusedField, equals: .name)
                    .onSubmit { focusedField.wrappedValue = .description }
                }

                FormField(label: "Description", error: viewModel.descriptionError) {
                    FormTextField(
                        text: binding(viewModel.description, viewModel.onDescriptionChange),
                        placeholder: "What is this community about?",
                        singleLine: false,
                        multiLineMinHeight: Constants.descriptionMinHeight,
                        multiLineLimit: Constants.descriptionLineLimit
                    )
                    .focused(focusedField, equals: .description)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xs)
            .padding(.bottom, Spacing.xxxl)
        }
    }

    private var nameHint: String {
        viewModel.isRenamed
            ? "Listed as \(viewModel.handle) — spaces are removed."
            : "No spaces — this is how the community is listed."
    }

    private var nameCounter: Int? {
        viewModel.nameRemaining <= Constants.nameCounterThreshold ? viewModel.nameRemaining : nil
    }

    private func binding<Value>(_ value: Value, _ onChange: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: { value }, set: onChange)
    }
}

#Preview {
    @Previewable @FocusState var focusedField: CreateCommunityFocusField?
    let viewModel = CreateCommunityViewModel(repository: FakeCommunityRepository())
    viewModel.onNameChange("Retro Collectors")
    return CreateCommunityForm(viewModel: viewModel, focusedField: $focusedField)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
