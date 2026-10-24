import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var expanded: HelpFaq?

    private let contactURL = URL(string: "https://github.com/lucianobcorrea/game-trackr-api")!

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(title: "Help & feedback", onBack: { dismiss() })

            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    HelpHero()

                    GroupedSection(title: "Get in touch") {
                        GroupedNavRow(icon: .envelope, title: "Send feedback") { openURL(contactURL) }
                        GroupedDivider()
                        GroupedNavRow(icon: .comment, title: "Report a bug") { openURL(contactURL) }
                    }

                    GroupedSection(title: "Common questions") {
                        ForEach(Array(HelpFaq.allCases.enumerated()), id: \.element) { index, faq in
                            HelpFaqRow(faq: faq, isExpanded: expanded == faq) { toggle(faq) }
                            if index < HelpFaq.allCases.count - 1 {
                                GroupedDivider()
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private func toggle(_ faq: HelpFaq) {
        withAnimation(.easeInOut(duration: Durations.short)) {
            expanded = expanded == faq ? nil : faq
        }
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
    .preferredColorScheme(.dark)
}
