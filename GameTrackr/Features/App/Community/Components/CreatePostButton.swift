import SwiftUI

struct CreatePostButton: View {
    let action: () -> Void
    var accessibilityLabel = "Create post"

    var body: some View {
        Button(action: action) {
            AppIconView(icon: .plus, size: 26)
                .foregroundStyle(Color.appOnPrimary)
                .frame(width: 58, height: 58)
                .background(Circle().fill(Color.appPrimary))
                .shadow(color: Color.appPrimary.opacity(0.45), radius: 18)
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    CreatePostButton(action: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
