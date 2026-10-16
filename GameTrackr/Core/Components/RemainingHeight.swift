import SwiftUI

private struct RemainingHeightContainer: ViewModifier {
    @State private var viewportHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .frame(minHeight: viewportHeight, alignment: .top)
            .background(alignment: .top) {
                Color.clear
                    .containerRelativeFrame(.vertical)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { viewportHeight = $0 }
            }
    }
}

extension View {
    func remainingHeightContainer() -> some View {
        modifier(RemainingHeightContainer())
    }
}
