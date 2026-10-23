import SwiftUI

private enum Constants {
    static let backSize: CGFloat = 40
    static let backIconSize: CGFloat = 22
    static let titleSize: CGFloat = 20
    static let saveHeight: CGFloat = 38
    static let saveTextSize: CGFloat = 15
}

struct EditProfileHeader: View {
    let isSaving: Bool
    let onBack: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onBack) {
                AppIconView(icon: .back, size: Constants.backIconSize)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: Constants.backSize, height: Constants.backSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Back")

            Text("Edit profile")
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button(action: onSave) {
                Text("Save")
                    .font(.appLabel(Constants.saveTextSize))
                    .foregroundStyle(isSaving ? Color.appPrimary : Color.appOnPrimary)
                    .overlay {
                        if isSaving {
                            ProgressView()
                                .tint(Color.appOnPrimary)
                                .accessibilityLabel("Saving")
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .frame(height: Constants.saveHeight)
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
        EditProfileHeader(isSaving: false, onBack: {}, onSave: {})
        EditProfileHeader(isSaving: true, onBack: {}, onSave: {})
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
