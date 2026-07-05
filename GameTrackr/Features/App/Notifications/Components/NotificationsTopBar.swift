import SwiftUI

struct NotificationsTopBar: View {
    let onBack: () -> Void
    let onMarkAllRead: () -> Void
    var showMarkAllRead = true

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

            if showMarkAllRead {
                Button(action: onMarkAllRead) {
                    Text("Mark all read")
                        .font(.appLabel(14))
                        .foregroundStyle(Color.appPrimary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.appBackground)
    }
}

#Preview {
    NotificationsTopBar(onBack: {}, onMarkAllRead: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
