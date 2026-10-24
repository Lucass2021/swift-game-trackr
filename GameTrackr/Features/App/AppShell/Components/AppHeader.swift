import SwiftUI

struct AppHeader: View {
    let onNotifications: () -> Void
    let onSearch: () -> Void
    let onMenu: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Image("logo-wordmark")
                .resizable()
                .scaledToFit()
                .frame(height: 26)
                .accessibilityLabel("GameTrackr")

            Spacer(minLength: 12)

            HStack(spacing: 6) {
                headerButton(.notifications, label: "Notifications", action: onNotifications)
                headerButton(.search, label: "Search", action: onSearch)
                headerButton(.settings, label: "Menu", action: onMenu)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.appBackground)
    }

    private func headerButton(_ icon: AppIcon, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            AppIconView(icon: icon, size: 22)
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(label)
    }
}

#Preview {
    VStack(spacing: 0) {
        AppHeader(onNotifications: {}, onSearch: {}, onMenu: {})
        Spacer()
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
