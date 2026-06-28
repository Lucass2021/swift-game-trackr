import SwiftUI

struct AuthScreenScaffold<Content: View>: View {
    @ViewBuilder var content: Content

    private let bottomPadding: CGFloat = 32

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        content
                    }
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height - bottomPadding, alignment: .top)
                    .padding(.horizontal, 24)
                    .padding(.bottom, bottomPadding)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }
}
