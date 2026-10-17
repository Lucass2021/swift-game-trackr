import SwiftUI

private enum Constants {
    static let buttonSize: CGFloat = 40
    static let iconSize: CGFloat = 20
    static let menuIconSize: CGFloat = 18
    static let backgroundAlpha = 0.55
    static let topInset: CGFloat = 60
}

struct CommunityDetailFloatingButton: View {
    let icon: AppIcon
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            FloatingCircle(icon: icon)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.top, Constants.topInset)
        .accessibilityLabel(label)
    }
}

struct CommunityDetailOwnerMenu: View {
    let onDeleteRequest: () -> Void

    var body: some View {
        Menu {
            Button(role: .destructive, action: onDeleteRequest) {
                Label {
                    Text("Delete community")
                } icon: {
                    AppIconView(icon: .trash, size: Constants.menuIconSize)
                }
            }
        } label: {
            FloatingCircle(icon: .overflow)
        }
        .padding(.top, Constants.topInset)
        .accessibilityLabel("More options")
    }
}

private struct FloatingCircle: View {
    let icon: AppIcon

    var body: some View {
        AppIconView(icon: icon, size: Constants.iconSize)
            .foregroundStyle(Color.appTextPrimary)
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            .background(Circle().fill(Color.appBackground.opacity(Constants.backgroundAlpha)))
            .contentShape(Circle())
    }
}

#Preview {
    HStack {
        CommunityDetailFloatingButton(icon: .back, label: "Back", action: {})
        CommunityDetailOwnerMenu(onDeleteRequest: {})
    }
    .padding(Spacing.md)
    .background(Color.appSurfaceCard)
    .preferredColorScheme(.dark)
}
