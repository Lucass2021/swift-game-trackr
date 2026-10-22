import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 14
    static let labelSize: CGFloat = 14
    static let glowOpacity = 0.35
    static let glowRadius: CGFloat = 14
    static let borderWidth: CGFloat = 1
}

struct JoinButton: View {
    let isJoined: Bool
    var expanded = false
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        if isEnabled {
            Button(action: action) {
                label
            }
            .buttonStyle(PressableButtonStyle())
        } else {
            label
        }
    }

    private var label: some View {
        HStack(spacing: Spacing.xxs) {
            if isJoined {
                AppIconView(icon: .check, size: Constants.iconSize)
            }
            Text(isJoined ? "Joined" : "Join")
        }
        .font(.appLabel(Constants.labelSize))
        .foregroundStyle(isJoined ? Color.appTextPrimary : Color.appOnPrimary)
        .padding(.horizontal, expanded ? Spacing.xl : Spacing.lg)
        .padding(.vertical, expanded ? Spacing.md : Spacing.xs)
        .frame(maxWidth: expanded ? .infinity : nil)
        .background(Capsule().fill(isJoined ? Color.clear : Color.appPrimary))
        .shadow(
            color: isJoined ? .clear : Color.appPrimary.opacity(Constants.glowOpacity),
            radius: Constants.glowRadius
        )
        .overlay(Capsule().stroke(isJoined ? Color.appOutline : Color.clear, lineWidth: Constants.borderWidth))
        .contentShape(Capsule())
    }
}

#Preview {
    HStack(spacing: Spacing.sm) {
        JoinButton(isJoined: false, action: {})
        JoinButton(isJoined: true, action: {})
        JoinButton(isJoined: true, isEnabled: false, action: {})
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
