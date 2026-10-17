import SwiftUI

private enum Constants {
    static let backButtonSize: CGFloat = 40
    static let backIconSize: CGFloat = 22
    static let titleSize: CGFloat = 18
}

struct UserProfileTopBar: View {
    let username: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onBack) {
                AppIconView(icon: .back, size: Constants.backIconSize)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: Constants.backButtonSize, height: Constants.backButtonSize, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Back")

            Text(username)
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    UserProfileTopBar(username: "@avareyes", onBack: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
