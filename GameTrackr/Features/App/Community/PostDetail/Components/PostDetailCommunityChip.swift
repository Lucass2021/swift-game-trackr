import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 16
    static let labelSize: CGFloat = 13
    static let borderWidth: CGFloat = 1
}

struct PostDetailCommunityChip: View {
    let name: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                AppIconView(icon: .community, size: Constants.iconSize)
                Text(name)
                    .font(.appLabel(Constants.labelSize))
            }
            .foregroundStyle(Color.appTextSecondary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(Capsule().fill(Color.appSurfaceCard))
            .overlay(Capsule().stroke(Color.appOutline, lineWidth: Constants.borderWidth))
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Open community \(name)")
    }
}

#Preview {
    PostDetailCommunityChip(name: "Elden Ring", action: {})
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
