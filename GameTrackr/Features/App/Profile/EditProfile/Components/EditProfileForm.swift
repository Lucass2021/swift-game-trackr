import SwiftUI

private enum Constants {
    static let bioCounterThreshold = 40
}

nonisolated enum EditProfileFocusField {
    case name
    case username
    case bio
}

struct EditProfileForm: View {
    let viewModel: EditProfileViewModel
    var focusedField: FocusState<EditProfileFocusField?>.Binding

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                EditProfilePreviewCard(
                    name: viewModel.previewName,
                    username: viewModel.previewUsername,
                    avatarHex: viewModel.avatarHex
                )

                EditProfileField(label: "Avatar") {
                    if viewModel.colorsFailed {
                        AvatarColorsRetry { Task { await viewModel.loadColors() } }
                    } else {
                        AvatarColorPicker(
                            colors: viewModel.colors,
                            selection: binding(viewModel.avatarHex, viewModel.onAvatarColorChange)
                        )
                    }
                }

                EditProfileField(label: "Display name", error: viewModel.nameError) {
                    ProfileTextField(
                        text: binding(viewModel.name, viewModel.onNameChange),
                        placeholder: "How should we call you?"
                    )
                    .submitLabel(.next)
                    .focused(focusedField, equals: .name)
                    .onSubmit { focusedField.wrappedValue = .username }
                }

                EditProfileField(label: "Username", error: viewModel.usernameError) {
                    ProfileTextField(
                        text: binding(viewModel.username, viewModel.onUsernameChange),
                        placeholder: "lucasdias",
                        prefix: EditProfileViewModel.usernamePrefix
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused(focusedField, equals: .username)
                    .onSubmit { focusedField.wrappedValue = .bio }
                }

                EditProfileField(label: "Bio", error: viewModel.bioError, counter: bioCounter) {
                    ProfileTextField(
                        text: binding(viewModel.bio, viewModel.onBioChange),
                        placeholder: "Tell other players what you're into...",
                        singleLine: false
                    )
                    .focused(focusedField, equals: .bio)
                }

                EditProfileField(label: "Profile visibility") {
                    VisibilitySelector(selection: binding(viewModel.visibility, viewModel.onVisibilityChange))
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xs)
            .padding(.bottom, Spacing.xxxl)
        }
    }

    private var bioCounter: Int? {
        viewModel.bioRemaining <= Constants.bioCounterThreshold ? viewModel.bioRemaining : nil
    }

    private func binding<Value>(_ value: Value, _ onChange: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: { value }, set: onChange)
    }
}

#Preview {
    @Previewable @FocusState var focusedField: EditProfileFocusField?
    EditProfileForm(
        viewModel: EditProfileViewModel(profile: ProfileMockData.profile, repository: FakeProfileRepository()),
        focusedField: $focusedField
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
