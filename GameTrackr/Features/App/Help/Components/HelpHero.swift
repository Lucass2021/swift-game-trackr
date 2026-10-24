import SwiftUI

struct HelpHero: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            AppIconView(icon: .help, filled: true, size: Constants.iconSize)
                .foregroundStyle(Color.appPrimary)

            Text("How can we help?")
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Text("Find answers below or reach out to us directly.")
                .font(.appBody(Constants.subtitleSize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .padding(.horizontal, Spacing.md)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.lg))
    }
}

private enum Constants {
    static let iconSize: CGFloat = 48
    static let titleSize: CGFloat = 22
    static let subtitleSize: CGFloat = 15
}

#Preview {
    HelpHero()
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
