import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let githubURL = URL(string: "https://github.com/lucianobcorrea/game-trackr-api")!

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(title: "About", onBack: { dismiss() })

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    hero

                    section("Legal") {
                        navRow(icon: .shieldCheck, title: "Terms of Use") { openURL(githubURL) }
                        sectionDivider
                        navRow(icon: .shieldCheck, title: "Privacy Policy") { openURL(githubURL) }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }

            Text("Made with ♥ by the GameTrackr team")
                .font(.appBody(13))
                .foregroundStyle(Color.appTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var hero: some View {
        VStack(spacing: 16) {
            AppIconView(icon: .brand, filled: true, size: 64)
                .foregroundStyle(Color.appPrimary)

            VStack(spacing: 6) {
                Text("GameTrackr")
                    .font(.appHeadline(28))
                    .foregroundStyle(Color.appTextPrimary)

                Text("Version 1.0.0")
                    .font(.appBody(14))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Text("Track your games, share your progress, and connect with fellow gamers.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 16))
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.appLabel(13))
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var sectionDivider: some View {
        Divider()
            .overlay(Color.appOutline)
            .padding(.leading, 54)
    }

    private func navRow(icon: AppIcon, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AppIconView(icon: icon, size: 20)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 24)

                Text(title)
                    .font(.appLabel(16))
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                AppIconView(icon: .forward, size: 16)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.dark)
}
