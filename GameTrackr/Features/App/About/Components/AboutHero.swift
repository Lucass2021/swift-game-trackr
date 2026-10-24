import SwiftUI

struct AboutHero: View {
    let versionText: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            AppIconView(icon: .brand, filled: true, size: Constants.logoSize)
                .foregroundStyle(Color.appPrimary)

            VStack(spacing: Spacing.xxs) {
                Text("GameTrackr")
                    .font(.appHeadline(Constants.nameSize))
                    .foregroundStyle(Color.appTextPrimary)

                Text(versionText)
                    .font(.appBody(Constants.versionSize))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Text("Track your games, share your progress, and connect with fellow gamers.")
                .font(.appBody(Constants.descriptionSize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.md)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .padding(.horizontal, Spacing.md)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.lg))
    }
}

private enum Constants {
    static let logoSize: CGFloat = 64
    static let nameSize: CGFloat = 28
    static let versionSize: CGFloat = 14
    static let descriptionSize: CGFloat = 15
}

#Preview {
    AboutHero(versionText: AboutUiState(versionName: "1.0").versionText)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
