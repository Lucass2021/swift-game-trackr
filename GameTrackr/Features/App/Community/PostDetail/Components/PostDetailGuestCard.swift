import SwiftUI

private enum Constants {
    static let titleSize: CGFloat = 18
    static let messageSize: CGFloat = 14
    static let actionSize: CGFloat = 14
    static let borderWidth: CGFloat = 1
}

struct PostDetailGuestCard: View {
    let onCreateAccount: () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text("Want to join the conversation?")
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Text("Create an account to like, comment, share, and follow other players.")
                .font(.appBody(Constants.messageSize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Button(action: onCreateAccount) {
                Text("Create an account")
                    .font(.appLabel(Constants.actionSize))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.sm)
                    .background(Capsule().fill(Color.appPrimary))
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, Spacing.xxs)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }
}

#Preview {
    PostDetailGuestCard(onCreateAccount: {})
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
