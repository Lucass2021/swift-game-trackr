import SwiftUI

private enum Constants {
    static let textSize: CGFloat = 14
}

struct AvatarColorsRetry: View {
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text("Couldn't load colors.")
                .font(.appBody(Constants.textSize))
                .foregroundStyle(Color.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Try again", action: onRetry)
                .font(.appLabel(Constants.textSize))
                .foregroundStyle(Color.appPrimary)
                .buttonStyle(.plain)
        }
    }
}

#Preview {
    AvatarColorsRetry(onRetry: {})
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
