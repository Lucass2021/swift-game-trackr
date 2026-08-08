import SwiftUI

struct NotificationsTopBar: View {
    let onBack: () -> Void
    let onMarkAllRead: () -> Void
    let onClearAll: () -> Void
    var showActions = true

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                AppIconView(icon: .back, size: 22)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            Text("Notifications")
                .font(.appHeadline(22))
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
                    AppIconView(icon: .overflow, size: 22)
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(width: 40, height: 40, alignment: .trailing)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.appBackground)
    }
}

#Preview {
    NotificationsTopBar(onBack: {}, onMarkAllRead: {}, onClearAll: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
