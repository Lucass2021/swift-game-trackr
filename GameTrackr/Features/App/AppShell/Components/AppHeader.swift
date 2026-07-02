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

            Spacer(minLength: 12)

            HStack(spacing: 6) {
                headerButton("bell", action: onNotifications)
                headerButton("magnifyingglass", action: onSearch)
                headerButton("gearshape", action: onMenu)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.appBackground)
    }

    private func headerButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
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
