import SwiftUI

struct EditProfileView: View {
    @Binding var profile: Profile

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthStore.self) private var authStore

    @State private var model: EditProfileModel
    @State private var showDiscardConfirm = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case username
        case bio
    }

    init(profile: Binding<Profile>) {
        _profile = profile
        _model = State(initialValue: EditProfileModel(profile: profile.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            form
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await model.loadColors()
        }
        .toast(message: $model.errorMessage)
        .alert("Discard your changes?", isPresented: $showDiscardConfirm) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard", role: .destructive) { dismiss() }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: requestClose) {
                AppIconView(icon: .back, size: 22)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Back")

            Text("Edit profile")
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button(action: save) {
                Text("Save")
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 20)
                    .frame(height: 38)
                    .background(Capsule().fill(Color.appPrimary))
                    .opacity(model.canSave && !model.isSaving ? 1 : 0.45)
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(model.isSaving)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var form: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                preview

                field("Avatar") {
                    AvatarColorPicker(colors: model.colors, selection: $model.avatarHex)
                }

                field("Display name", error: model.visibleError(model.nameError)) {
                    TextField(
                        "",
                        text: $model.name,
                        prompt: Text("How should we call you?")
                            .foregroundStyle(Color.appTextSecondary)
                    )
                    .font(.appBody(16))
                    .foregroundStyle(Color.appTextPrimary)
                    .tint(Color.appPrimary)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .name)
                    .onSubmit { focusedField = .username }
                    .fieldBox()
                }

                field("Username", error: model.visibleError(model.usernameError)) {
                    HStack(spacing: 2) {
                        Text("@")
                            .font(.appBody(16))
                            .foregroundStyle(Color.appTextSecondary)

                        TextField(
                            "",
                            text: $model.username,
                            prompt: Text("lucasdias")
                                .foregroundStyle(Color.appTextSecondary)
                        )
                        .font(.appBody(16))
                        .foregroundStyle(Color.appTextPrimary)
                        .tint(Color.appPrimary)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .focused($focusedField, equals: .username)
                        .onSubmit { focusedField = .bio }
                    }
                    .fieldBox()
                }

                field("Bio", error: model.visibleError(model.bioError), counter: bioCounter) {
                    TextField(
                        "",
                        text: $model.bio,
                        prompt: Text("Tell other players what you're into...")
                            .foregroundStyle(Color.appTextSecondary),
                        axis: .vertical
                    )
                    .font(.appBody(16))
                    .foregroundStyle(Color.appTextPrimary)
                    .tint(Color.appPrimary)
                    .lineLimit(3 ... 6)
                    .focused($focusedField, equals: .bio)
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appSurfaceCard)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.appOutline, lineWidth: 1)
                    )
                }

                field("Profile visibility") {
                    VisibilitySelector(selection: $model.visibility)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
    }

    private var preview: some View {
        HStack(spacing: 14) {
            CommunityAvatar(
                start: Color(hex: model.avatarHex),
                end: Color(hex: model.avatarHex).darkened(by: 0.28),
                size: 64
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(model.previewName)
                    .font(.appHeadline(18))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                Text(model.previewUsername)
                    .font(.appBody(14))
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(.easeOut(duration: 0.2), value: model.avatarHex)
    }

    private var bioCounter: String? {
        model.bioRemaining <= 40 ? "\(model.bioRemaining)" : nil
    }

    private func field(
        _ label: String,
        error: String? = nil,
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
                        .foregroundStyle(model.bioRemaining < 0 ? Color.appTertiary : Color.appTextSecondary)
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

    private func requestClose() {
        focusedField = nil
        if model.hasChanges {
            showDiscardConfirm = true
        } else {
            dismiss()
        }
    }

    private func save() {
        focusedField = nil
        Task {
            guard let (updated, user) = await model.save() else { return }
            profile = updated
            authStore.updateUser(user)
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var profile = ProfileMockData.profile
    NavigationStack {
        EditProfileView(profile: $profile)
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
