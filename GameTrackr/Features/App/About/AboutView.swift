import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let state = AboutUiState(versionName: Bundle.main.versionName)
    private let legalURL = URL(string: "https://github.com/lucianobcorrea/game-trackr-api")!

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(title: "About", onBack: { dismiss() })

            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xxl) {
                    AboutHero(versionText: state.versionText)

                    GroupedSection(title: "Legal") {
                        GroupedNavRow(icon: .shieldCheck, title: "Terms of Use") { openURL(legalURL) }
                        GroupedDivider()
                        GroupedNavRow(icon: .shieldCheck, title: "Privacy Policy") { openURL(legalURL) }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
            }

            Text("Made with ♥ by the GameTrackr team")
                .font(.appBody(Constants.creditsSize))
                .foregroundStyle(Color.appTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.bottom, Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

private enum Constants {
    static let creditsSize: CGFloat = 13
}

#Preview {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.dark)
}
