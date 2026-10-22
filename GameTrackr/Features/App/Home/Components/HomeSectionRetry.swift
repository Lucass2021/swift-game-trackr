import SwiftUI

private enum Constants {
    static let textSize: CGFloat = 14
}

struct HomeSectionRetry: View {
    static let height: CGFloat = 240

    let message: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text(message)
                .font(.appBody(Constants.textSize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Button("Try again", action: action)
                .font(.appLabel(Constants.textSize))
                .foregroundStyle(Color.appPrimary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: Self.height)
        .padding(.horizontal, Spacing.lg)
    }
}

#Preview {
    HomeSectionRetry(message: "Couldn't load new releases.", action: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
