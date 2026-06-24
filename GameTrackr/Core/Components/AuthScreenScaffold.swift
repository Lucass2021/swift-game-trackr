import SwiftUI

struct AuthScreenScaffold<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        content
                    }
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .top)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }
}
