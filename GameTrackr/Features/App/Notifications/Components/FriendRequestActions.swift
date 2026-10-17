import SwiftUI

private enum Constants {
    static let labelSize: CGFloat = 14
}

struct FriendRequestActions: View {
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onAccept) {
                Text("Accept")
                    .font(.appLabel(Constants.labelSize))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.appPrimary, in: Capsule())
            }
            .buttonStyle(PressableButtonStyle())

            Button(action: onDecline) {
                Text("Decline")
                    .font(.appLabel(Constants.labelSize))
                    .foregroundStyle(Color.appTertiary)
                    .padding(.vertical, Spacing.xs)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.top, Spacing.xxxs)
    }
}

#Preview {
    FriendRequestActions(onAccept: {}, onDecline: {})
        .padding(Spacing.md)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
