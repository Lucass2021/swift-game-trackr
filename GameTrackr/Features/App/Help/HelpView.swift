import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let githubURL = URL(string: "https://github.com/lucianobcorrea/game-trackr-api")!

    @State private var expandedQuestion: Int?

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(title: "Help & feedback", onBack: { dismiss() })

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    hero

                    section("Get in touch") {
                        navRow(icon: .envelope, title: "Send feedback") { openURL(githubURL) }
                        sectionDivider
                        navRow(icon: .comment, title: "Report a bug") { openURL(githubURL) }
                    }

                    section("Common questions") {
                        faqRow(
                            index: 0,
                            question: "How do I add a game to my library?",
                            answer: "Search for a game using the search bar, open its detail page, and tap "
                                + "\"Add to library\". You can set a status like playing, completed, or backlog."
                        )
                        sectionDivider
                        faqRow(
                            index: 1,
                            question: "Can I track my playtime?",
                            answer: "Yes! Open any game in your library and edit its details. You can log "
                                + "hours played, start and finish dates, and even write a short review."
                        )
                        sectionDivider
                        faqRow(
                            index: 2,
                            question: "How do I connect with friends?",
                            answer: "Visit another user's profile and send them a friend request. Once "
                                + "accepted, you'll see their activity in your feed and can message them."
                        )
                        sectionDivider
                        faqRow(
                            index: 3,
                            question: "Is my data private?",
                            answer: "By default your profile is public, but you can change its visibility "
                                + "in Settings. Your library, stats, and activity respect your preferences."
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var hero: some View {
        VStack(spacing: 12) {
            AppIconView(icon: .help, filled: true, size: 48)
                .foregroundStyle(Color.appPrimary)

            Text("How can we help?")
                .font(.appHeadline(22))
                .foregroundStyle(Color.appTextPrimary)

            Text("Find answers below or reach out to us directly.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
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

    private func faqRow(index: Int, question: String, answer: String) -> some View {
        let isExpanded = expandedQuestion == index

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                expandedQuestion = isExpanded ? nil : index
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    AppIconView(icon: .help, size: 20)
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: 24)

                    Text(question)
                        .font(.appLabel(16))
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    AppIconView(icon: .caretDown, size: 14)
                        .foregroundStyle(Color.appTextSecondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)

                if isExpanded {
                    Text(answer)
                        .font(.appBody(14))
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, 16)
                        .padding(.leading, 38)
                        .padding(.bottom, 15)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
    .preferredColorScheme(.dark)
}
