import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 22
    static let buttonSize: CGFloat = 40
    static let titleSize: CGFloat = 22
}

struct NotificationsTopBar: View {
    let onBack: () -> Void
    let onMarkAllRead: () -> Void
    let onClearAll: () -> Void
    var showActions = true

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onBack) {
                AppIconView(icon: .back, size: Constants.iconSize)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: Constants.buttonSize, height: Constants.buttonSize, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            Text("Notifications")
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            if showActions {
                Menu {
                    Button(action: onMarkAllRead) {
                        Label("Mark all read", image: "check")
                    }
                    Button(role: .destructive, action: onClearAll) {
                        Label("Clear all", image: "trash")
                    }
                } label: {
                    AppIconView(icon: .overflow, size: Constants.iconSize)
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(width: Constants.buttonSize, height: Constants.buttonSize, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("More options")
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Color.appBackground)
    }
}

#Preview {
    NotificationsTopBar(onBack: {}, onMarkAllRead: {}, onClearAll: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
