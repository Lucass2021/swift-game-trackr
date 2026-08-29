import SwiftUI

struct CreateCommunityView: View {
    let viewModel: CommunityViewModel
    var onCreated: (Community) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss

    @State private var model = CreateCommunityModel()
    @State private var showDiscardConfirm = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case description
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            form
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
        .alert("Discard this community?", isPresented: $showDiscardConfirm) {
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

            Text("New community")
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button(action: submit) {
                Text(model.isSubmitting ? "Creating..." : "Create")
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 20)
                    .frame(height: 38)
                    .background(Capsule().fill(Color.appPrimary))
                    .opacity(model.canSubmit ? 1 : 0.45)
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(!model.canSubmit)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var form: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                field(
                    "Name",
                    error: model.visibleError(model.nameError),
                    counter: nameCounter,
                    hint: nameHint
                ) {
                    TextField(
                        "",
                        text: $model.name,
                        prompt: Text("RetroCollectors")
                            .foregroundStyle(Color.appTextSecondary)
                    )
                    .font(.appBody(16))
                    .foregroundStyle(Color.appTextPrimary)
                    .tint(Color.appPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focusedField, equals: .name)
                    .onSubmit { focusedField = .description }
                    .fieldBox()
                }

                field("Description", error: model.visibleError(model.descriptionError)) {
                    TextField(
                        "",
                        text: $model.description,
                        prompt: Text("What is this community about?")
                            .foregroundStyle(Color.appTextSecondary),
                        axis: .vertical
                    )
                    .font(.appBody(16))
                    .foregroundStyle(Color.appTextPrimary)
                    .tint(Color.appPrimary)
                    .lineLimit(6 ... 12)
                    .focused($focusedField, equals: .description)
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

                if let submitError = model.submitError {
                    Text(submitError)
                        .font(.appBody(13))
                        .foregroundStyle(Color.appTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
    }

    private var nameHint: String {
        model.isRenamed
            ? "Listed as \(model.handle) — spaces are removed."
            : "No spaces — this is how the community is listed."
    }

    private var nameCounter: String? {
        model.nameRemaining <= 20 ? "\(model.nameRemaining)" : nil
    }

    private func field(
        _ label: String,
        error: String?,
        counter: String? = nil,
        hint: String? = nil,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionLabel(text: label)
                Spacer()
                if let counter {
                    Text(counter)
                        .font(.appBody(12))
                        .foregroundStyle(model.nameRemaining < 0 ? Color.appTertiary : Color.appTextSecondary)
                }
            }

            content()

            if let error {
                Text(error)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTertiary)
            } else if let hint {
                Text(hint)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func submit() {
        focusedField = nil
        Task {
            if let created = await model.submit(using: viewModel) {
                onCreated(created)
                dismiss()
            }
        }
    }
}

#Preview {
    Color.appBackground
        .fullScreenCover(isPresented: .constant(true)) {
            CreateCommunityView(viewModel: CommunityViewModel())
        }
        .preferredColorScheme(.dark)
}
