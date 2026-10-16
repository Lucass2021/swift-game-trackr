import SwiftUI

private enum Constants {
    static let textSize: CGFloat = 14
}

struct LoadMoreErrorRow: View {
    let onRetry: () -> Void

    var body: some View {
        Button(action: onRetry) {
            VStack(spacing: Spacing.xxs) {
                Text("Couldn't load more.")
                    .font(.appBody(Constants.textSize))
                    .foregroundStyle(Color.appTextSecondary)
                Text("Try again")
                    .font(.appLabel(Constants.textSize))
                    .foregroundStyle(Color.appPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Couldn't load more. Try again")
    }
}

#Preview {
    LoadMoreErrorRow(onRetry: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
