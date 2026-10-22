import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 26
    static let buttonSize: CGFloat = 58
    static let glowOpacity = 0.45
    static let glowRadius: CGFloat = 18
}

struct CreatePostButton: View {
    let action: () -> Void
    var accessibilityLabel = "Create post"

    var body: some View {
        Button(action: action) {
            AppIconView(icon: .plus, size: Constants.iconSize)
                .foregroundStyle(Color.appOnPrimary)
                .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                .background(Circle().fill(Color.appPrimary))
                .shadow(color: Color.appPrimary.opacity(Constants.glowOpacity), radius: Constants.glowRadius)
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.trailing, Spacing.lg)
        .padding(.bottom, Spacing.lg)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    CreatePostButton(action: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
