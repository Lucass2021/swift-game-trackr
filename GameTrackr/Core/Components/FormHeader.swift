import SwiftUI

private enum Constants {
    static let closeSize: CGFloat = 40
    static let closeIconSize: CGFloat = 22
    static let titleSize: CGFloat = 20
    static let actionHeight: CGFloat = 38
    static let actionTextSize: CGFloat = 15
}

struct FormHeader: View {
    let title: String
    let actionLabel: String
    let closeLabel: String
    let savingLabel: String
    let isSaving: Bool
    let onClose: () -> Void
    let onAction: () -> Void
    var closeIcon: AppIcon = .back

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onClose) {
                AppIconView(icon: closeIcon, size: Constants.closeIconSize)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: Constants.closeSize, height: Constants.closeSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel(closeLabel)

            Text(title)
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button(action: onAction) {
                Text(actionLabel)
                    .font(.appLabel(Constants.actionTextSize))
                    .foregroundStyle(isSaving ? Color.appPrimary : Color.appOnPrimary)
                    .overlay {
                        if isSaving {
                            ProgressView()
                                .tint(Color.appOnPrimary)
                                .accessibilityLabel(savingLabel)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .frame(height: Constants.actionHeight)
                    .background(Capsule().fill(Color.appPrimary))
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    VStack {
        FormHeader(
            title: "Edit profile",
            actionLabel: "Save",
            closeLabel: "Back",
            savingLabel: "Saving",
            isSaving: false,
            onClose: {},
            onAction: {}
        )
        FormHeader(
            title: "New community",
            actionLabel: "Create",
            closeLabel: "Close",
            savingLabel: "Creating",
            isSaving: true,
            onClose: {},
            onAction: {},
            closeIcon: .close
        )
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
